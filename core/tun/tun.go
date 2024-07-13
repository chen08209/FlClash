//go:build android

package tun

import "C"
import (
	"context"
	"encoding/binary"
	"github.com/Kr328/tun2socket"
	"github.com/Kr328/tun2socket/nat"
	"github.com/metacubex/mihomo/adapter/inbound"
	"github.com/metacubex/mihomo/common/pool"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/log"
	"github.com/metacubex/mihomo/transport/socks5"
	"github.com/metacubex/mihomo/tunnel"
	"golang.org/x/sync/semaphore"
	"io"
	"net"
	"os"
	"time"
)

type Tun struct {
	Closer io.Closer

	Closed bool
	Limit  *semaphore.Weighted
}

func (t *Tun) Close() {
	_ = t.Limit.Acquire(context.TODO(), 4)
	defer t.Limit.Release(4)

	t.Closed = true

	if t.Closer != nil {
		_ = t.Closer.Close()
	}
}

var _, ipv4LoopBack, _ = net.ParseCIDR("127.0.0.0/8")

func Start(fd int, gateway, portal, dns string) (io.Closer, error) {
	device := os.NewFile(uintptr(fd), "/dev/tun")
	ip, network, err := net.ParseCIDR(gateway)
	if err != nil {
		panic(err.Error())
	} else {
		network.IP = ip
	}
	stack, err := tun2socket.StartTun2Socket(device, network, net.ParseIP(portal))

	if err != nil {
		_ = device.Close()
		return nil, err
	}

	dnsAddr := net.ParseIP(dns)

	tcp := func() {
		defer func(tcp *nat.TCP) {
			_ = tcp.Close()
		}(stack.TCP())
		defer log.Debugln("TCP: closed")

		for stack.TCP().SetDeadline(time.Time{}) == nil {
			conn, err := stack.TCP().Accept()
			if err != nil {
				log.Errorln("Accept connection: %v", err)
				continue
			}
			lAddr := conn.LocalAddr().(*net.TCPAddr)
			rAddr := conn.RemoteAddr().(*net.TCPAddr)

			if ipv4LoopBack.Contains(rAddr.IP) {
				_ = conn.Close()

				continue
			}

			if shouldHijackDns(dnsAddr, rAddr.IP, rAddr.Port) {
				go func() {
					defer func(conn net.Conn) {
						_ = conn.Close()
					}(conn)

					buf := pool.Get(pool.UDPBufferSize)
					defer func(buf []byte) {
						_ = pool.Put(buf)
					}(buf)

					for {
						_ = conn.SetReadDeadline(time.Now().Add(constant.DefaultTCPTimeout))

						length := uint16(0)
						if err := binary.Read(conn, binary.BigEndian, &length); err != nil {
							return
						}

						if int(length) > len(buf) {
							return
						}

						n, err := conn.Read(buf[:length])
						if err != nil {
							return
						}

						msg, err := relayDns(buf[:n])
						if err != nil {
							return
						}

						_, _ = conn.Write(msg)
					}
				}()

				continue
			}

			go tunnel.Tunnel.HandleTCPConn(conn, createMetadata(lAddr, rAddr))
		}
	}

	udp := func() {
		defer func(udp *nat.UDP) {
			_ = udp.Close()
		}(stack.UDP())
		defer log.Debugln("UDP: closed")

		for {
			buf := pool.Get(pool.UDPBufferSize)

			n, lRAddr, rRAddr, err := stack.UDP().ReadFrom(buf)
			if err != nil {
				return
			}

			raw := buf[:n]
			lAddr := lRAddr.(*net.UDPAddr)
			rAddr := rRAddr.(*net.UDPAddr)

			if ipv4LoopBack.Contains(rAddr.IP) {
				_ = pool.Put(buf)

				continue
			}

			if shouldHijackDns(dnsAddr, rAddr.IP, rAddr.Port) {
				go func() {
					defer func(buf []byte) {
						_ = pool.Put(buf)
					}(buf)

					msg, err := relayDns(raw)
					if err != nil {
						return
					}

					_, _ = stack.UDP().WriteTo(msg, rAddr, lAddr)
				}()

				continue
			}

			pkt := &packet{
				local: lAddr,
				data:  raw,
				writeBack: func(b []byte, addr net.Addr) (int, error) {
					return stack.UDP().WriteTo(b, addr, lAddr)
				},
				drop: func() {
					_ = pool.Put(buf)
				},
			}

			tunnel.Tunnel.HandleUDPPacket(inbound.NewPacket(socks5.ParseAddrToSocksAddr(rAddr), pkt, constant.SOCKS5))
		}
	}

	go tcp()
	go udp()

	return stack, nil
}
