use std::fs;
use std::mem::{size_of, zeroed};
use std::path::Path;

use super::netlink::{dump_request, Tracker, RTM_GETADDR, RTM_GETLINK, RTM_GETROUTE};
use super::procfs::default_interface;
use super::Notifier;
use crate::api::network::NetworkState;

const ARPHRD_PPP: &str = "512";
const ARPHRD_NONE: &str = "65534";
const GROUPS: u32 = (libc::RTMGRP_LINK
    | libc::RTMGRP_IPV4_IFADDR
    | libc::RTMGRP_IPV6_IFADDR
    | libc::RTMGRP_IPV4_ROUTE
    | libc::RTMGRP_IPV6_ROUTE) as u32;

/// The interface the main table routes through by default. A Wi-Fi interface
/// there is Wi-Fi; a PPP, TUN or WireGuard one is a VPN. The Core's own TUN
/// routes from a table of its own and stays out of both.
pub fn state() -> Option<NetworkState> {
    let route = fs::read_to_string("/proc/net/route").unwrap_or_default();
    let ipv6_route = fs::read_to_string("/proc/net/ipv6_route").unwrap_or_default();
    let Some(interface) = default_interface(&route, &ipv6_route) else {
        return Some(NetworkState {
            wifi: false,
            vpn: false,
        });
    };
    let device = Path::new("/sys/class/net").join(&interface);
    let kind = fs::read_to_string(device.join("type")).unwrap_or_default();
    Some(NetworkState {
        wifi: device.join("wireless").exists() || device.join("phy80211").exists(),
        vpn: matches!(kind.trim(), ARPHRD_PPP | ARPHRD_NONE) || device.join("tun_flags").exists(),
    })
}

pub fn watch(notifier: Notifier) {
    let Some(socket) = Socket::open() else {
        return;
    };
    let _ = std::thread::Builder::new()
        .name("network-netlink".to_owned())
        .spawn(move || socket.run(notifier));
}

struct Socket(libc::c_int);

impl Socket {
    fn open() -> Option<Self> {
        // SAFETY: plain socket calls on a zeroed sockaddr_nl.
        unsafe {
            let fd = libc::socket(
                libc::AF_NETLINK,
                libc::SOCK_RAW | libc::SOCK_CLOEXEC,
                libc::NETLINK_ROUTE,
            );
            if fd < 0 {
                return None;
            }
            let socket = Self(fd);
            let mut address: libc::sockaddr_nl = zeroed();
            address.nl_family = libc::AF_NETLINK as libc::sa_family_t;
            address.nl_groups = GROUPS;
            let bound = libc::bind(
                fd,
                (&address as *const libc::sockaddr_nl).cast(),
                size_of::<libc::sockaddr_nl>() as libc::socklen_t,
            );
            (bound == 0).then_some(socket)
        }
    }

    fn send(&self, message: &[u8]) -> bool {
        // SAFETY: `message` is a live buffer of its length.
        unsafe { libc::send(self.0, message.as_ptr().cast(), message.len(), 0) >= 0 }
    }

    fn receive<'a>(&self, buffer: &'a mut [u8]) -> Result<(&'a [u8], bool), i32> {
        // SAFETY: `buffer` is writable for its length, `source` for `length`.
        let (read, source) = unsafe {
            let mut source: libc::sockaddr_nl = zeroed();
            let mut length = size_of::<libc::sockaddr_nl>() as libc::socklen_t;
            let read = libc::recvfrom(
                self.0,
                buffer.as_mut_ptr().cast(),
                buffer.len(),
                0,
                (&mut source as *mut libc::sockaddr_nl).cast(),
                &mut length,
            );
            (read, source)
        };
        if read < 0 {
            return Err(std::io::Error::last_os_error().raw_os_error().unwrap_or(0));
        }
        Ok((&buffer[..read as usize], source.nl_groups != 0))
    }

    fn run(self, notifier: Notifier) {
        let mut tracker = Tracker::default();
        let mut buffer = vec![0u8; 64 * 1024];
        let mut changed_while_dumping = false;
        for (sequence, kind) in [RTM_GETLINK, RTM_GETADDR, RTM_GETROUTE]
            .into_iter()
            .enumerate()
        {
            if !self.send(&dump_request(kind, sequence as u32 + 1)) {
                continue;
            }
            while let Ok((batch, multicast)) = self.receive(&mut buffer) {
                let applied = tracker.apply(batch);
                changed_while_dumping |= multicast && applied.changed;
                if applied.done {
                    break;
                }
            }
        }
        if changed_while_dumping {
            notifier.changed();
        }
        loop {
            match self.receive(&mut buffer) {
                Ok((batch, _)) => {
                    if tracker.apply(batch).changed {
                        notifier.changed();
                    }
                }
                Err(libc::EINTR) => {}
                Err(libc::ENOBUFS) => notifier.changed(),
                Err(_) => return,
            }
        }
    }
}

impl Drop for Socket {
    fn drop(&mut self) {
        // SAFETY: the descriptor is owned by this value.
        unsafe {
            libc::close(self.0);
        }
    }
}
