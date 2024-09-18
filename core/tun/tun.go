//go:build android

package tun

import "C"
import (
	"github.com/metacubex/mihomo/constant"
	LC "github.com/metacubex/mihomo/listener/config"
	"github.com/metacubex/mihomo/listener/sing_tun"
	"github.com/metacubex/mihomo/log"
	"github.com/metacubex/mihomo/tunnel"
	"net"
	"net/netip"
)

type Props struct {
	Fd       int    `json:"fd"`
	Gateway  string `json:"gateway"`
	Gateway6 string `json:"gateway6"`
	Portal   string `json:"portal"`
	Portal6  string `json:"portal6"`
	Dns      string `json:"dns"`
	Dns6     string `json:"dns6"`
}

func Start(tunProps Props) (*sing_tun.Listener, error) {
	var prefix4 []netip.Prefix
	tempPrefix4, err := netip.ParsePrefix(tunProps.Gateway)
	if err != nil {
		log.Errorln("startTUN error:", err)
		return nil, err
	}
	prefix4 = append(prefix4, tempPrefix4)

	var prefix6 []netip.Prefix
	tempPrefix6, err := netip.ParsePrefix(tunProps.Gateway6)
	if err != nil {
		log.Errorln("startTUN error:", err)
		return nil, err
	}
	prefix6 = append(prefix6, tempPrefix6)

	var dnsHijack []string
	dnsHijack = append(dnsHijack, net.JoinHostPort(tunProps.Dns, "53"))
	dnsHijack = append(dnsHijack, net.JoinHostPort(tunProps.Dns6, "53"))

	options := LC.Tun{
		Enable:              true,
		Device:              sing_tun.InterfaceName,
		Stack:               constant.TunMixed,
		DNSHijack:           dnsHijack,
		AutoRoute:           false,
		AutoDetectInterface: false,
		Inet4Address:        prefix4,
		Inet6Address:        prefix6,
		MTU:                 9000,
		FileDescriptor:      tunProps.Fd,
	}

	listener, err := sing_tun.New(options, tunnel.Tunnel)

	if err != nil {
		log.Errorln("startTUN error:", err)
		return nil, err
	}

	return listener, nil
}
