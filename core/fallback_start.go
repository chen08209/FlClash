package core

import (
	"runtime"
	"sync"
	"time"

	"github.com/metacubex/mihomo/adapter/outboundgroup"
	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/constant"
	cp "github.com/metacubex/mihomo/constant/provider"
)

const fallbackStartupProbeBudget = 1500 * time.Millisecond
const fallbackStartupProbeConcurrency = 4

// Warm fallback health states before opening listeners. Providers already run
// their initial checks asynchronously, so their health-check singleflight
// coalesces concurrent calls without duplicating network probes.
func warmFallbackGroups(cfg *config.Config) {
	if cfg == nil || runtime.GOARCH != "amd64" ||
		(runtime.GOOS != "windows" && runtime.GOOS != "linux") {
		return
	}

	providers := make(map[string]cp.ProxyProvider)
	for _, proxy := range cfg.Proxies {
		if proxy.Type() != constant.Fallback {
			continue
		}
		group, ok := adapterAs[*outboundgroup.Fallback](proxy)
		if !ok {
			continue
		}
		for _, pd := range group.Providers() {
			providers[pd.Name()] = pd
		}
	}
	if len(providers) == 0 {
		return
	}

	done := make(chan struct{})
	go func() {
		slots := make(chan struct{}, fallbackStartupProbeConcurrency)
		var running sync.WaitGroup
		for _, pd := range providers {
			slots <- struct{}{}
			running.Add(1)
			go func(pd cp.ProxyProvider) {
				defer running.Done()
				defer func() { <-slots }()
				pd.HealthCheck()
			}(pd)
		}
		running.Wait()
		close(done)
	}()

	timer := time.NewTimer(fallbackStartupProbeBudget)
	defer timer.Stop()
	select {
	case <-done:
	case <-timer.C:
	}
}
