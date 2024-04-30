//go:build android

package tun

import (
	"github.com/metacubex/mihomo/constant"
	"net"
)

func createMetadata(lAddr, rAddr *net.TCPAddr) *constant.Metadata {
	return &constant.Metadata{
		NetWork: constant.TCP,
		Type:    constant.SOCKS5,
		SrcIP:   lAddr.AddrPort().Addr(),
		DstIP:   rAddr.AddrPort().Addr(),
		SrcPort: uint16(lAddr.Port),
		DstPort: uint16(rAddr.Port),
		Host:    "",
	}
}
