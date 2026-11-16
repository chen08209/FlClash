package core

import (
	"net/http"
	"net/http/httptest"
	"runtime"
	"testing"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/outbound"
	"github.com/metacubex/mihomo/adapter/outboundgroup"
	"github.com/metacubex/mihomo/adapter/provider"
	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/constant"
	cp "github.com/metacubex/mihomo/constant/provider"
)

func TestFallbackWarmupSelectsFirstReachableProxyBeforeListening(t *testing.T) {
	if runtime.GOARCH != "amd64" || (runtime.GOOS != "windows" && runtime.GOOS != "linux") {
		t.Skip("startup warmup is limited to Windows/Linux amd64")
	}

	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusNoContent)
	}))
	defer server.Close()

	dead := adapter.NewProxy(outbound.NewRejectWithOption(outbound.RejectOption{Name: "dead"}))
	good := adapter.NewProxy(outbound.NewDirectWithOption(outbound.DirectOption{Name: "good"}))
	candidates := []constant.Proxy{dead, good}
	health := provider.NewHealthCheck(candidates, server.URL, 1000, 0, true, nil)
	pd, err := provider.NewCompatibleProvider("fallback-candidates", candidates, health)
	if err != nil {
		t.Fatal(err)
	}
	defer pd.Close()
	fallback, err := outboundgroup.NewFallback(
		outboundgroup.GroupCommonOption{Name: "auto", URL: server.URL},
		outboundgroup.FallbackOption{}, good, []cp.ProxyProvider{pd},
	)
	if err != nil {
		t.Fatal(err)
	}

	if got := fallback.Now(); got != "dead" {
		t.Fatalf("unverified fallback selected %s, want the first candidate", got)
	}

	warmFallbackGroups(&config.Config{Proxies: map[string]constant.Proxy{
		"auto": adapter.NewProxy(fallback),
	}})
	if got := fallback.Now(); got != "good" {
		t.Fatalf("after startup warmup fallback selected %s, want good", got)
	}
}
