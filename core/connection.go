package core

import (
	"github.com/metacubex/mihomo/component/resolver"
	"github.com/metacubex/mihomo/dns"
	"github.com/metacubex/mihomo/hub"
	"github.com/metacubex/mihomo/tunnel/statistic"
)

func handleGetTraffic(onlyStatisticsProxy bool) Traffic {
	up, down := statistic.DefaultManager.NowTraffic(onlyStatisticsProxy)
	return Traffic{Up: up, Down: down}
}

func handleGetTotalTraffic(onlyStatisticsProxy bool) Traffic {
	up, down := statistic.DefaultManager.TotalTraffic(onlyStatisticsProxy)
	return Traffic{Up: up, Down: down}
}

func handleResetTraffic() {
	statistic.DefaultManager.ResetStatistic()
}

func handleGetConnections() *statistic.Snapshot {
	return statistic.DefaultManager.Snapshot()
}

func handleGetConnectionCount() int {
	count := 0
	statistic.DefaultManager.Range(func(statistic.Tracker) bool {
		count++
		return true
	})
	return count
}

func handleCloseConnections() bool {
	statistic.DefaultManager.Range(func(c statistic.Tracker) bool {
		_ = c.Close()
		return true
	})
	return true
}

func handleResetConnections() bool {
	resolver.ResetConnection()
	return true
}

// A network change clears rather than waits out the TTLs: mihomo serves an
// expired entry once more before it refreshes it.
func handleClearDnsCache() {
	configMu.Lock()
	defer configMu.Unlock()
	dns.ClearAll()
}

// A connection that went out over a network the device has left hangs until
// TCP gives up on it, and so do the DNS clients' pooled connections.
func handleResetNetwork() {
	handleCloseConnections()
	handleClearDnsCache()
	reloadOutboundsOnNetworkChange()
}

// Outbound state such as a WireGuard tunnel keeps the socket it was created
// with, bound to whatever network was in use at the time. When the device
// switches networks (e.g. cellular -> Wi-Fi) the old network can stay up but
// stop carrying traffic, and the tunnel never notices: it keeps dialing over
// the dead path until the app restarts. Reapplying the running config
// rebuilds every outbound, so its sockets are created on the network now in
// use and tunnels re-handshake right away.
func reloadOutboundsOnNetworkChange() {
	configMu.Lock()
	defer configMu.Unlock()
	if !isRunning.Load() || currentConfig == nil {
		return
	}
	cfg, err := loadConfig(runningConfigPath())
	if err != nil {
		return
	}
	currentConfig = cfg
	hub.ApplyConfig(cfg)
	bumpRouteEpoch()
	updateListeners(cfg)
}

func handleCloseConnection(connectionId string) bool {
	c := statistic.DefaultManager.Get(connectionId)
	if c == nil {
		return false
	}
	_ = c.Close()
	return true
}
