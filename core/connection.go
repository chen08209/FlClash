package core

import (
	"github.com/metacubex/mihomo/component/resolver"
	"github.com/metacubex/mihomo/dns"
	"github.com/metacubex/mihomo/tunnel/statistic"
)

func handleGetTraffic(params TrafficParams) Traffic {
	up, down := statistic.DefaultManager.NowTraffic(params.OnlyProxy)
	return Traffic{Up: up, Down: down}
}

func handleGetTotalTraffic(params TrafficParams) Traffic {
	up, down := statistic.DefaultManager.TotalTraffic(params.OnlyProxy)
	return Traffic{Up: up, Down: down}
}

func handleResetTraffic() {
	statistic.DefaultManager.ResetStatistic()
}

type AppTrafficConnection struct {
	*statistic.TrackerInfo
	Direct bool `json:"direct"`
}

func appTrafficConnection(info *statistic.TrackerInfo) *AppTrafficConnection {
	return &AppTrafficConnection{
		TrackerInfo: info,
		Direct:      statistic.IsDirect(info.Chain.Last()),
	}
}

type ConnectionSnapshot struct {
	*statistic.Snapshot
	Connections []*AppTrafficConnection `json:"connections"`
}

func handleGetConnections() *ConnectionSnapshot {
	snapshot := statistic.DefaultManager.Snapshot()
	connections := make([]*AppTrafficConnection, 0, len(snapshot.Connections))
	for _, info := range snapshot.Connections {
		connections = append(connections, appTrafficConnection(info))
	}
	return &ConnectionSnapshot{Snapshot: snapshot, Connections: connections}
}

func handleGetConnectionCount() int {
	count := 0
	statistic.DefaultManager.Range(func(statistic.Tracker) bool {
		count++
		return true
	})
	return count
}

func handleCloseConnections() {
	statistic.DefaultManager.Range(func(c statistic.Tracker) bool {
		_ = c.Close()
		return true
	})
}

func handleResetConnections() {
	resolver.ResetConnection()
}

// A network change clears rather than waits out the TTLs: mihomo serves an
// expired entry once more before it refreshes it.
func handleClearDnsCache() {
	configMu.Lock()
	defer configMu.Unlock()
	dns.ClearAll()
}

// handleNetworkChanged is how the desktop host reports a new network, which
// Android's NetworkObserver reports through handleResetNetwork.
func handleNetworkChanged() {
	handleClearDnsCache()
}

// A connection that went out over a network the device has left hangs until
// TCP gives up on it, and so do the DNS clients' pooled connections.
func handleResetNetwork() {
	handleCloseConnections()
	handleNetworkChanged()
}

// A connection that is already gone is closed as far as the host is concerned.
func handleCloseConnection(params IDParams) error {
	if c := statistic.DefaultManager.Get(params.ID); c != nil {
		_ = c.Close()
	}
	return nil
}
