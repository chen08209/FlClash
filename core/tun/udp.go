//go:build android

package tun

import "net"

type packet struct {
	local     *net.UDPAddr
	data      []byte
	writeBack func(b []byte, addr net.Addr) (int, error)
	drop      func()
}

func (pkt *packet) Data() []byte {
	return pkt.data
}

func (pkt *packet) WriteBack(b []byte, addr net.Addr) (n int, err error) {
	return pkt.writeBack(b, addr)
}

func (pkt *packet) Drop() {
	pkt.drop()
}

func (pkt *packet) LocalAddr() net.Addr {
	return pkt.local
}
