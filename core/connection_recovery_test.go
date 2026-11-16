package core

import (
	"runtime"
	"testing"

	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/constant"
	LC "github.com/metacubex/mihomo/listener/config"
)

func TestNetworkChangeRetriesActiveTunOnlyOnDesktopAMD64(t *testing.T) {
	previousConfig := currentConfig
	previousRunning := isRunning.Load()
	previousRetry := retryTunOnNetworkChange
	t.Cleanup(func() {
		currentConfig = previousConfig
		setRunning(previousRunning)
		retryTunOnNetworkChange = previousRetry
	})

	var calls int
	retryTunOnNetworkChange = func(tun LC.Tun, _ constant.Tunnel) {
		if !tun.Enable {
			t.Fatal("attempted to recover a disabled TUN")
		}
		calls++
	}
	cfg := &config.Config{General: &config.General{}}
	currentConfig = cfg
	setRunning(true)

	handleNetworkChanged()
	if calls != 0 {
		t.Fatal("retried disabled TUN")
	}

	cfg.General.Tun.Enable = true
	handleNetworkChanged()
	want := 0
	if runtime.GOARCH == "amd64" && (runtime.GOOS == "windows" || runtime.GOOS == "linux") {
		want = 1
	}
	if calls != want {
		t.Fatalf("retried %d times, want %d", calls, want)
	}

	setRunning(false)
	handleNetworkChanged()
	if calls != want {
		t.Fatal("retried TUN while the core was stopped")
	}
}
