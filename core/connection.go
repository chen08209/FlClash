package core

import (
	"runtime"
	"sync/atomic"

	"github.com/metacubex/mihomo/component/resolver"
	"github.com/metacubex/mihomo/dns"
	"github.com/metacubex/mihomo/listener"
	"github.com/metacubex/mihomo/tunnel"
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

// retryTunOnNetworkChange reopens a failed TUN listener, or refreshes the
// existing listener's interface binding, after the underlying network moves.
var retryTunOnNetworkChange = listener.ReCreateTun

var networkChangeVersion atomic.Uint64

// handleNetworkChanged is how the desktop host reports a new network, which
// Android's NetworkObserver reports through handleResetNetwork.
func handleNetworkChanged() {
	var version uint64
	if runtime.GOARCH == "amd64" && (runtime.GOOS == "windows" || runtime.GOOS == "linux") {
		version = networkChangeVersion.Add(1)
	}
	configMu.Lock()
	defer configMu.Unlock()
	// A newer network state supersedes reports queued behind a slow config
	// apply or listener restart. Only the latest one resets DNS and TUN.
	if version != 0 && version != networkChangeVersion.Load() {
		return
	}
	dns.ClearAll()
	if runtime.GOARCH == "amd64" &&
		(runtime.GOOS == "windows" || runtime.GOOS == "linux") &&
		isRunning.Load() && currentConfig != nil && currentConfig.General.Tun.Enable {
		retryTunOnNetworkChange(currentConfig.General.Tun, tunnel.Tunnel)
	}
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
