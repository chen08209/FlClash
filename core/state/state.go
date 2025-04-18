package state

import "net/netip"

var DefaultIpv4Address = "172.19.0.1/30"
var DefaultDnsAddress = "172.19.0.2"
var DefaultIpv6Address = "fdfe:dcba:9876::1/126"

type AndroidVpnOptions struct {
	Enable           bool           `json:"enable"`
	Port             int            `json:"port"`
	AccessControl    *AccessControl `json:"accessControl"`
	AllowBypass      bool           `json:"allowBypass"`
	SystemProxy      bool           `json:"systemProxy"`
	BypassDomain     []string       `json:"bypassDomain"`
	RouteAddress     []netip.Prefix `json:"routeAddress"`
	Ipv4Address      string         `json:"ipv4Address"`
	Ipv6Address      string         `json:"ipv6Address"`
	DnsServerAddress string         `json:"dnsServerAddress"`
}

type AccessControl struct {
	Enable            bool     `json:"enable"`
	Mode              string   `json:"mode"`
	AcceptList        []string `json:"acceptList"`
	RejectList        []string `json:"rejectList"`
}

type AndroidVpnRawOptions struct {
	Enable        bool           `json:"enable"`
	AccessControl *AccessControl `json:"accessControl"`
	AllowBypass   bool           `json:"allowBypass"`
	SystemProxy   bool           `json:"systemProxy"`
	Ipv6          bool           `json:"ipv6"`
}

type State struct {
	VpnProps            AndroidVpnRawOptions `json:"vpn-props"`
	CurrentProfileName  string               `json:"current-profile-name"`
	OnlyStatisticsProxy bool                 `json:"only-statistics-proxy"`
	BypassDomain        []string             `json:"bypass-domain"`
}

var CurrentState = &State{
	OnlyStatisticsProxy: false,
	CurrentProfileName:  "",
}

func GetIpv6Address() string {
	if CurrentState.VpnProps.Ipv6 {
		return DefaultIpv6Address
	} else {
		return ""
	}
}

func GetDnsServerAddress() string {
	return DefaultDnsAddress
}
