package core

import (
	"runtime"
	"sync"
	"testing"
	"time"

	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/constant"
	LC "github.com/metacubex/mihomo/listener/config"
)

func TestNetworkChangeDropsObsoleteQueuedRecoveries(t *testing.T) {
	if runtime.GOARCH != "amd64" || (runtime.GOOS != "windows" && runtime.GOOS != "linux") {
		t.Skip("network change coalescing is scoped to desktop amd64")
	}

	previousConfig := currentConfig
	previousRunning := isRunning.Load()
	previousRetry := retryTunOnNetworkChange
	t.Cleanup(func() {
		currentConfig = previousConfig
		setRunning(previousRunning)
		retryTunOnNetworkChange = previousRetry
	})

	currentConfig = &config.Config{General: &config.General{}}
	currentConfig.General.Tun.Enable = true
	setRunning(true)

	calls := 0
	retryTunOnNetworkChange = func(_ LC.Tun, _ constant.Tunnel) {
		calls++
	}

	const burst = 32
	var waiting sync.WaitGroup
	before := networkChangeVersion.Load()

	// Keep the recovery lock occupied until all reports are queued.
	configMu.Lock()
	for range burst {
		waiting.Add(1)
		go func() {
			defer waiting.Done()
			handleNetworkChanged()
		}()
	}
	deadline := time.Now().Add(3 * time.Second)
	for networkChangeVersion.Load() < before+burst && time.Now().Before(deadline) {
		runtime.Gosched()
	}
	observed := networkChangeVersion.Load() - before
	configMu.Unlock()

	waiting.Wait()
	if observed != burst {
		t.Fatalf("only %d of %d network-change reports arrived", observed, burst)
	}
	if calls != 1 {
		t.Fatalf("recovery attempts = %d, want only the latest report", calls)
	}
}
