package main

import (
	"net/http"
	"net/http/httptest"
	"slices"
	"strings"
	"testing"
	"time"

	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"
)

func probeServer(t *testing.T, handler http.HandlerFunc) *httptest.Server {
	t.Helper()
	server := httptest.NewServer(handler)
	t.Cleanup(server.Close)
	return server
}

func withProbeProxies(t *testing.T, names ...string) {
	t.Helper()
	proxies := make(map[string]constant.Proxy, len(names))
	for _, name := range names {
		proxies[name] = namedProxy(name)
	}
	tunnel.UpdateProxies(proxies, nil)
	t.Cleanup(func() { tunnel.UpdateProxies(nil, nil) })
}

func TestHandleProbePinsTheNamedProxy(t *testing.T) {
	var userAgent string
	server := probeServer(t, func(w http.ResponseWriter, r *http.Request) {
		userAgent = r.UserAgent()
		w.WriteHeader(http.StatusForbidden)
		_, _ = w.Write([]byte("ip=203.0.113.7\nloc=US\n"))
	})
	withProbeProxies(t, "node-a")

	result := handleProbe(&ProbeParams{
		Url:       server.URL + "/trace",
		ProxyName: "node-a",
		Headers:   map[string]string{"User-Agent": "probe-test"},
		Timeout:   2000,
		MaxBody:   1024,
	})

	if result == nil {
		t.Fatal("handleProbe = nil, want a result")
	}
	if result.Error != "" {
		t.Fatalf("error = %q (%s), want none", result.Error, result.Message)
	}
	if result.StatusCode != http.StatusForbidden {
		t.Errorf("status = %d, want 403", result.StatusCode)
	}
	if result.Body != "ip=203.0.113.7\nloc=US\n" {
		t.Errorf("body = %q", result.Body)
	}
	if !slices.Equal(result.Chains, []string{"node-a"}) {
		t.Errorf("chains = %v, want [node-a]", result.Chains)
	}
	if result.Url != server.URL+"/trace" {
		t.Errorf("url = %q", result.Url)
	}
	if userAgent != "probe-test" {
		t.Errorf("user agent = %q, want the header the caller passed", userAgent)
	}
}

func TestHandleProbeFollowsRedirectsAndCapsTheBody(t *testing.T) {
	server := probeServer(t, func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path == "/" {
			http.Redirect(w, r, "/final", http.StatusFound)
			return
		}
		_, _ = w.Write([]byte(strings.Repeat("x", 100)))
	})
	withProbeProxies(t, "node-a")

	result := handleProbe(&ProbeParams{Url: server.URL, ProxyName: "node-a", Timeout: 2000, MaxBody: 8})

	if result == nil || result.Error != "" {
		t.Fatalf("result = %+v, want a success", result)
	}
	if result.StatusCode != http.StatusOK {
		t.Errorf("status = %d, want 200 after the redirect", result.StatusCode)
	}
	if result.Url != server.URL+"/final" {
		t.Errorf("url = %q, want the redirect target", result.Url)
	}
	if len(result.Body) != 8 {
		t.Errorf("body length = %d, want the cap", len(result.Body))
	}
}

func TestHandleProbeSkipsTheBodyWhenNotAsked(t *testing.T) {
	server := probeServer(t, func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusNoContent)
	})
	withProbeProxies(t, "node-a")

	result := handleProbe(&ProbeParams{Url: server.URL, ProxyName: "node-a", Timeout: 2000})

	if result == nil || result.Error != "" {
		t.Fatalf("result = %+v, want a success", result)
	}
	if result.StatusCode != http.StatusNoContent || result.Body != "" {
		t.Errorf("status = %d body = %q, want 204 with no body", result.StatusCode, result.Body)
	}
}

func TestHandleProbeReportsATimeout(t *testing.T) {
	addr := blackHoleServer(t)
	withProbeProxies(t, "node-a")

	start := time.Now()
	result := handleProbe(&ProbeParams{Url: "http://" + addr.String(), ProxyName: "node-a", Timeout: 200})

	if result == nil {
		t.Fatal("handleProbe = nil, want a result")
	}
	if result.Error != probeErrorTimeout {
		t.Errorf("error = %q (%s), want timeout", result.Error, result.Message)
	}
	if elapsed := time.Since(start); elapsed > 2*time.Second {
		t.Errorf("took %s, want the caller's budget", elapsed)
	}
}

func TestHandleProbeReportsARefusedConnection(t *testing.T) {
	server := probeServer(t, func(http.ResponseWriter, *http.Request) {})
	url := server.URL
	server.Close()
	withProbeProxies(t, "node-a")

	result := handleProbe(&ProbeParams{Url: url, ProxyName: "node-a", Timeout: 2000})

	if result == nil || result.Error != probeErrorFailed {
		t.Fatalf("result = %+v, want a failed probe", result)
	}
	if result.StatusCode != 0 || result.Message == "" {
		t.Errorf("status = %d message = %q, want no status and a reason", result.StatusCode, result.Message)
	}
}

func TestHandleProbeRejectsAnUnknownProxyWithoutWaitingForASlot(t *testing.T) {
	for i := 0; i < probeConcurrency; i++ {
		probeSlots <- struct{}{}
	}
	t.Cleanup(func() {
		for i := 0; i < probeConcurrency; i++ {
			<-probeSlots
		}
	})

	done := make(chan *ProbeResult, 1)
	go func() {
		done <- handleProbe(&ProbeParams{Url: "http://example.invalid", ProxyName: "missing", Timeout: 1})
	}()

	select {
	case result := <-done:
		if result == nil || result.Error != probeErrorFailed {
			t.Errorf("result = %+v, want a failed probe", result)
		}
	case <-time.After(time.Second):
		t.Fatal("an unknown proxy queued behind a saturated probe semaphore")
	}
}

func TestHandleProbeGivesUpQueueingOnTheDeadline(t *testing.T) {
	for i := 0; i < probeConcurrency; i++ {
		probeSlots <- struct{}{}
	}
	t.Cleanup(func() {
		for i := 0; i < probeConcurrency; i++ {
			<-probeSlots
		}
	})
	withProbeProxies(t, "node-a")

	if result := handleProbe(&ProbeParams{Url: "http://example.invalid", ProxyName: "node-a", Timeout: 50}); result != nil {
		t.Errorf("result = %+v, want nil when no slot was granted", result)
	}
}

func TestHandleProbeRoutesThroughTheTunnel(t *testing.T) {
	server := probeServer(t, func(w http.ResponseWriter, _ *http.Request) {
		_, _ = w.Write([]byte("routed"))
	})
	withProbeProxies(t, "DIRECT")
	tunnel.OnRunning()
	t.Cleanup(tunnel.OnSuspend)

	result := handleProbe(&ProbeParams{Url: server.URL, Timeout: 2000, MaxBody: 64})

	if result == nil || result.Error != "" {
		t.Fatalf("result = %+v, want a success", result)
	}
	if result.StatusCode != http.StatusOK || result.Body != "routed" {
		t.Errorf("status = %d body = %q", result.StatusCode, result.Body)
	}
	if !slices.Equal(result.Chains, []string{"DIRECT"}) {
		t.Errorf("chains = %v, want the outbound the tunnel picked", result.Chains)
	}
}

func TestHandleProbeFailsWhenTheTunnelIsSuspended(t *testing.T) {
	server := probeServer(t, func(w http.ResponseWriter, _ *http.Request) {
		_, _ = w.Write([]byte("unreachable"))
	})
	withProbeProxies(t, "DIRECT")
	tunnel.OnSuspend()

	result := handleProbe(&ProbeParams{Url: server.URL, Timeout: 2000})

	if result == nil || result.Error != probeErrorFailed {
		t.Fatalf("result = %+v, want a failed probe", result)
	}
}
