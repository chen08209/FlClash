//go:build windows

package core

import (
	"github.com/metacubex/mihomo/listener/sing_tun"
	"github.com/metacubex/mihomo/log"
	tun "github.com/metacubex/sing-tun"
)

func init() {
	detectEgress = detectWindowsEgress
}

func detectWindowsEgress() string {
	network, err := tun.NewNetworkUpdateMonitor(log.SingLogger)
	if err != nil {
		return ""
	}
	defer network.Close()
	monitor, err := tun.NewDefaultInterfaceMonitor(network, log.SingLogger, tun.DefaultInterfaceMonitorOptions{
		InterfaceFinder: sing_tun.DefaultInterfaceFinder,
	})
	if err != nil {
		return ""
	}
	defer monitor.Close()
	if err := monitor.Start(); err != nil {
		return ""
	}
	if selected := monitor.DefaultInterface(); selected != nil {
		return selected.Name
	}
	return ""
}
