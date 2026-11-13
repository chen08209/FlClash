use std::collections::{HashMap, HashSet};

pub const RTM_GETLINK: u16 = 18;
pub const RTM_GETADDR: u16 = 22;
pub const RTM_GETROUTE: u16 = 26;
const RTM_NEWLINK: u16 = 16;
const RTM_DELLINK: u16 = 17;
const RTM_NEWADDR: u16 = 20;
const RTM_DELADDR: u16 = 21;
const RTM_NEWROUTE: u16 = 24;
const RTM_DELROUTE: u16 = 25;
const NLMSG_ERROR: u16 = 2;
const NLMSG_DONE: u16 = 3;
const NLM_F_REQUEST: u16 = 0x1;
const NLM_F_DUMP: u16 = 0x300;
const NLM_F_REPLACE: u16 = 0x100;

const IFF_UP: u32 = 0x1;
const IFF_RUNNING: u32 = 0x40;
const IFF_LOWER_UP: u32 = 0x10000;
const IFA_ADDRESS: u16 = 1;
const IFA_LOCAL: u16 = 2;
const RTA_OIF: u16 = 4;
const RTA_GATEWAY: u16 = 5;
const RTA_PRIORITY: u16 = 6;
const RTA_TABLE: u16 = 15;
const RTN_UNICAST: u8 = 1;

const HEADER: usize = 16;

fn align(len: usize) -> usize {
    (len + 3) & !3
}

fn u16_at(bytes: &[u8], at: usize) -> Option<u16> {
    Some(u16::from_ne_bytes(bytes.get(at..at + 2)?.try_into().ok()?))
}

fn u32_at(bytes: &[u8], at: usize) -> Option<u32> {
    Some(u32::from_ne_bytes(bytes.get(at..at + 4)?.try_into().ok()?))
}

/// A dump request for links, addresses or routes of every family.
pub fn dump_request(kind: u16, sequence: u32) -> Vec<u8> {
    let payload = match kind {
        RTM_GETLINK => 16,
        RTM_GETADDR => 8,
        _ => 12,
    };
    let mut message = Vec::with_capacity(HEADER + payload);
    message.extend_from_slice(&((HEADER + payload) as u32).to_ne_bytes());
    message.extend_from_slice(&kind.to_ne_bytes());
    message.extend_from_slice(&(NLM_F_REQUEST | NLM_F_DUMP).to_ne_bytes());
    message.extend_from_slice(&sequence.to_ne_bytes());
    message.extend_from_slice(&0u32.to_ne_bytes());
    message.resize(HEADER + payload, 0);
    message
}

fn messages(buffer: &[u8]) -> impl Iterator<Item = (u16, u16, &[u8])> {
    let mut offset = 0;
    std::iter::from_fn(move || {
        let len = u32_at(buffer, offset)? as usize;
        if len < HEADER || offset + len > buffer.len() {
            return None;
        }
        let kind = u16_at(buffer, offset + 4)?;
        let flags = u16_at(buffer, offset + 6)?;
        let payload = &buffer[offset + HEADER..offset + len];
        offset += align(len);
        Some((kind, flags, payload))
    })
}

fn attributes(bytes: &[u8]) -> impl Iterator<Item = (u16, &[u8])> {
    let mut offset = 0;
    std::iter::from_fn(move || {
        let len = u16_at(bytes, offset)? as usize;
        if len < 4 || offset + len > bytes.len() {
            return None;
        }
        let kind = u16_at(bytes, offset + 2)?;
        let data = &bytes[offset + 4..offset + len];
        offset += align(len);
        Some((kind, data))
    })
}

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
struct DefaultRoute {
    family: u8,
    table: u32,
    interface: u32,
    gateway: Vec<u8>,
    priority: u32,
}

impl DefaultRoute {
    fn shares_slot(&self, other: &Self) -> bool {
        self.family == other.family && self.table == other.table && self.priority == other.priority
    }
}

#[derive(Debug, Default, PartialEq, Eq)]
pub struct Applied {
    pub changed: bool,
    pub done: bool,
}

/// What the network looks like to a socket: which links are up, which
/// addresses they hold and which default routes exist. Kernels resend links
/// for wireless events and addresses for every lifetime refresh, so only a
/// difference in this state counts as a change.
#[derive(Debug, Default)]
pub struct Tracker {
    links: HashMap<u32, u32>,
    addresses: HashSet<(u32, Vec<u8>)>,
    routes: HashSet<DefaultRoute>,
}

impl Tracker {
    pub fn apply(&mut self, buffer: &[u8]) -> Applied {
        let mut applied = Applied::default();
        for (kind, flags, payload) in messages(buffer) {
            applied.changed |= match kind {
                RTM_NEWLINK | RTM_DELLINK => self.link(kind, payload),
                RTM_NEWADDR | RTM_DELADDR => self.address(kind, payload),
                RTM_NEWROUTE | RTM_DELROUTE => self.route(kind, flags, payload),
                NLMSG_DONE | NLMSG_ERROR => {
                    applied.done = true;
                    false
                }
                _ => false,
            };
        }
        applied
    }

    fn link(&mut self, kind: u16, payload: &[u8]) -> bool {
        let (Some(index), Some(flags)) = (u32_at(payload, 4), u32_at(payload, 8)) else {
            return false;
        };
        if kind == RTM_DELLINK {
            return self.links.remove(&index).is_some();
        }
        let state = flags & (IFF_UP | IFF_RUNNING | IFF_LOWER_UP);
        self.links.insert(index, state) != Some(state)
    }

    fn address(&mut self, kind: u16, payload: &[u8]) -> bool {
        let Some(index) = u32_at(payload, 4) else {
            return false;
        };
        let mut address = None;
        for (attribute, data) in attributes(payload.get(8..).unwrap_or_default()) {
            match attribute {
                IFA_LOCAL => address = Some(data),
                IFA_ADDRESS if address.is_none() => address = Some(data),
                _ => {}
            }
        }
        let Some(address) = address else {
            return false;
        };
        let key = (index, address.to_vec());
        if kind == RTM_DELADDR {
            self.addresses.remove(&key)
        } else {
            self.addresses.insert(key)
        }
    }

    fn route(&mut self, kind: u16, flags: u16, payload: &[u8]) -> bool {
        if payload.len() < 12 || payload[1] != 0 || payload[7] != RTN_UNICAST {
            return false;
        }
        let mut route = DefaultRoute {
            family: payload[0],
            table: u32::from(payload[4]),
            interface: 0,
            gateway: Vec::new(),
            priority: 0,
        };
        for (attribute, data) in attributes(&payload[12..]) {
            match attribute {
                RTA_OIF => route.interface = u32_at(data, 0).unwrap_or(0),
                RTA_GATEWAY => route.gateway = data.to_vec(),
                RTA_PRIORITY => route.priority = u32_at(data, 0).unwrap_or(0),
                RTA_TABLE => route.table = u32_at(data, 0).unwrap_or(route.table),
                _ => {}
            }
        }
        if kind == RTM_DELROUTE {
            return self.routes.remove(&route);
        }
        // The kernel sends no RTM_DELROUTE for the route a replace takes over.
        let replaced = flags & NLM_F_REPLACE != 0 && {
            let before = self.routes.len();
            self.routes
                .retain(|other| other == &route || !route.shares_slot(other));
            self.routes.len() != before
        };
        self.routes.insert(route) || replaced
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn message(kind: u16, payload: &[u8]) -> Vec<u8> {
        flagged(kind, 0, payload)
    }

    fn flagged(kind: u16, flags: u16, payload: &[u8]) -> Vec<u8> {
        let mut bytes = Vec::new();
        bytes.extend_from_slice(&((HEADER + payload.len()) as u32).to_ne_bytes());
        bytes.extend_from_slice(&kind.to_ne_bytes());
        bytes.extend_from_slice(&flags.to_ne_bytes());
        bytes.extend_from_slice(&[0; 8]);
        bytes.extend_from_slice(payload);
        bytes.resize(align(bytes.len()), 0);
        bytes
    }

    fn attribute(kind: u16, data: &[u8]) -> Vec<u8> {
        let mut bytes = Vec::new();
        bytes.extend_from_slice(&((4 + data.len()) as u16).to_ne_bytes());
        bytes.extend_from_slice(&kind.to_ne_bytes());
        bytes.extend_from_slice(data);
        bytes.resize(align(bytes.len()), 0);
        bytes
    }

    fn link(kind: u16, index: u32, flags: u32) -> Vec<u8> {
        let mut payload = vec![0; 4];
        payload.extend_from_slice(&index.to_ne_bytes());
        payload.extend_from_slice(&flags.to_ne_bytes());
        payload.extend_from_slice(&[0; 4]);
        message(kind, &payload)
    }

    fn address(kind: u16, index: u32, local: [u8; 4]) -> Vec<u8> {
        let mut payload = vec![2, 24, 0, 0];
        payload.extend_from_slice(&index.to_ne_bytes());
        payload.extend(attribute(IFA_ADDRESS, &local));
        payload.extend(attribute(IFA_LOCAL, &local));
        message(kind, &payload)
    }

    fn route(kind: u16, dst_len: u8, interface: u32, gateway: [u8; 4]) -> Vec<u8> {
        message(kind, &route_payload(dst_len, interface, gateway))
    }

    fn route_payload(dst_len: u8, interface: u32, gateway: [u8; 4]) -> Vec<u8> {
        let mut payload = vec![2, dst_len, 0, 0, 254, 3, 0, RTN_UNICAST, 0, 0, 0, 0];
        payload.extend(attribute(RTA_OIF, &interface.to_ne_bytes()));
        payload.extend(attribute(RTA_GATEWAY, &gateway));
        payload
    }

    #[test]
    fn a_link_counts_only_when_its_state_changes() {
        let mut tracker = Tracker::default();
        assert!(tracker.apply(&link(RTM_NEWLINK, 2, IFF_UP)).changed);
        assert!(
            !tracker
                .apply(&link(RTM_NEWLINK, 2, IFF_UP | 0x1000))
                .changed
        );
        assert!(
            tracker
                .apply(&link(RTM_NEWLINK, 2, IFF_UP | IFF_RUNNING | IFF_LOWER_UP))
                .changed
        );
        assert!(tracker.apply(&link(RTM_DELLINK, 2, 0)).changed);
        assert!(!tracker.apply(&link(RTM_DELLINK, 2, 0)).changed);
    }

    #[test]
    fn an_address_lifetime_refresh_is_not_a_change() {
        let mut tracker = Tracker::default();
        assert!(
            tracker
                .apply(&address(RTM_NEWADDR, 2, [192, 168, 1, 5]))
                .changed
        );
        assert!(
            !tracker
                .apply(&address(RTM_NEWADDR, 2, [192, 168, 1, 5]))
                .changed
        );
        assert!(
            tracker
                .apply(&address(RTM_NEWADDR, 2, [192, 168, 1, 6]))
                .changed
        );
        assert!(
            tracker
                .apply(&address(RTM_DELADDR, 2, [192, 168, 1, 5]))
                .changed
        );
    }

    #[test]
    fn only_default_routes_count() {
        let mut tracker = Tracker::default();
        assert!(!tracker.apply(&route(RTM_NEWROUTE, 24, 2, [0; 4])).changed);
        assert!(
            tracker
                .apply(&route(RTM_NEWROUTE, 0, 2, [192, 168, 1, 1]))
                .changed
        );
        assert!(
            !tracker
                .apply(&route(RTM_NEWROUTE, 0, 2, [192, 168, 1, 1]))
                .changed
        );
        assert!(
            tracker
                .apply(&route(RTM_DELROUTE, 0, 2, [192, 168, 1, 1]))
                .changed
        );
    }

    #[test]
    fn a_replaced_default_route_leaves_nothing_behind() {
        let mut tracker = Tracker::default();
        let wired = route_payload(0, 2, [192, 168, 1, 1]);
        let wireless = route_payload(0, 3, [10, 0, 0, 1]);
        assert!(tracker.apply(&message(RTM_NEWROUTE, &wired)).changed);
        assert!(
            tracker
                .apply(&flagged(RTM_NEWROUTE, NLM_F_REPLACE, &wireless))
                .changed
        );
        assert!(
            tracker
                .apply(&flagged(RTM_NEWROUTE, NLM_F_REPLACE, &wired))
                .changed
        );
        assert!(
            !tracker
                .apply(&flagged(RTM_NEWROUTE, NLM_F_REPLACE, &wired))
                .changed
        );
        assert_eq!(tracker.routes.len(), 1);
    }

    #[test]
    fn reads_every_message_of_a_batch_and_the_end_of_a_dump() {
        let mut batch = link(RTM_NEWLINK, 3, IFF_UP);
        batch.extend(address(RTM_NEWADDR, 3, [10, 0, 0, 2]));
        batch.extend(message(NLMSG_DONE, &[0; 4]));
        let mut tracker = Tracker::default();
        assert_eq!(
            tracker.apply(&batch),
            Applied {
                changed: true,
                done: true
            }
        );
        assert_eq!(tracker.addresses.len(), 1);
    }

    #[test]
    fn builds_a_dump_request() {
        let request = dump_request(RTM_GETROUTE, 7);
        assert_eq!(request.len(), 28);
        assert_eq!(u32_at(&request, 0), Some(28));
        assert_eq!(u16_at(&request, 4), Some(RTM_GETROUTE));
        assert_eq!(u16_at(&request, 6), Some(NLM_F_REQUEST | NLM_F_DUMP));
        assert_eq!(u32_at(&request, 8), Some(7));
    }
}
