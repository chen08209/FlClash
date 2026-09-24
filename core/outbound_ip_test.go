package main

import (
	"net/http"
	"sync/atomic"
	"testing"
	"time"
)

func TestHandleOutboundIpTakesTheFirstUsableAnswer(t *testing.T) {
	withProbeProxies(t, "node-a")
	slow := probeServer(t, func(w http.ResponseWriter, _ *http.Request) {
		time.Sleep(400 * time.Millisecond)
		_, _ = w.Write([]byte("slow"))
	})
	empty := probeServer(t, func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusNoContent)
	})
	quick := probeServer(t, func(w http.ResponseWriter, _ *http.Request) {
		_, _ = w.Write([]byte("ip=203.0.113.7"))
	})

	result := handleOutboundIp(&OutboundIpParams{
		ProxyName: "node-a",
		Urls:      []string{slow.URL, empty.URL, quick.URL},
		Timeout:   4000,
	})

	if result.Error != "" {
		t.Fatalf("error = %q, want none", result.Error)
	}
	if result.Body != "ip=203.0.113.7" {
		t.Errorf("body = %q, want the quick source's", result.Body)
	}
	if result.Url != quick.URL {
		t.Errorf("url = %q, want %q", result.Url, quick.URL)
	}
}

func TestHandleOutboundIpSkipsAnAnswerWithoutAnAddress(t *testing.T) {
	withProbeProxies(t, "node-a")
	limited := probeServer(t, func(w http.ResponseWriter, _ *http.Request) {
		_, _ = w.Write([]byte(`{"error":"rate limited"}`))
	})
	later := probeServer(t, func(w http.ResponseWriter, _ *http.Request) {
		time.Sleep(200 * time.Millisecond)
		_, _ = w.Write([]byte(`{"ip":"2001:db8::7","country":"JP"}`))
	})

	result := handleOutboundIp(&OutboundIpParams{
		ProxyName: "node-a",
		Urls:      []string{limited.URL, later.URL},
		Timeout:   4000,
	})

	if result.Url != later.URL {
		t.Errorf("url = %q, want the source that named an address", result.Url)
	}
}

func TestMentionsIpNeedsAWholeAddress(t *testing.T) {
	cases := map[string]bool{
		"fl=12f\nip=203.0.113.7\nts=1700000000.1": true,
		`{"ip":"2001:db8::7","country":"JP"}`:     true,
		`{"ip":"::ffff:203.0.113.7"}`:             true,
		`a::after{content:""}`:                    false,
		`div::before,li::marker{color:#fff}`:      false,
		`::-webkit-scrollbar{width:0}`:            false,
		`<a href="http://127.0.0.1/login">`:       false,
	}
	for body, want := range cases {
		if got := mentionsIp(body); got != want {
			t.Errorf("mentionsIp(%q) = %v, want %v", body, got, want)
		}
	}
}

func TestMentionsIpSkipsLocalAddresses(t *testing.T) {
	for _, body := range []string{
		"ip=192.168.1.1",
		`{"ip":"10.20.30.40"}`,
		"ip=172.16.0.9",
		"ip=100.64.12.34",
		`{"ip":"fd00::1"}`,
		`{"ip":"::ffff:192.168.1.1"}`,
	} {
		if mentionsIp(body) {
			t.Errorf("mentionsIp(%q) = true, want false", body)
		}
	}
}

func TestHandleOutboundIpCancelsTheLosers(t *testing.T) {
	withProbeProxies(t, "node-a")
	var cancelled atomic.Bool
	losing := probeServer(t, func(w http.ResponseWriter, r *http.Request) {
		select {
		case <-r.Context().Done():
			cancelled.Store(true)
		case <-time.After(3 * time.Second):
		}
	})
	winning := probeServer(t, func(w http.ResponseWriter, _ *http.Request) {
		_, _ = w.Write([]byte("ip=203.0.113.9"))
	})

	result := handleOutboundIp(&OutboundIpParams{
		ProxyName: "node-a",
		Urls:      []string{losing.URL, winning.URL},
		Timeout:   5000,
	})

	if result.Body != "ip=203.0.113.9" {
		t.Fatalf("body = %q, want the winning source's", result.Body)
	}
	deadline := time.Now().Add(2 * time.Second)
	for !cancelled.Load() && time.Now().Before(deadline) {
		time.Sleep(10 * time.Millisecond)
	}
	if !cancelled.Load() {
		t.Error("the losing request kept running, want it cancelled once the race was won")
	}
}

func TestHandleOutboundIpReportsWhenEverySourceFails(t *testing.T) {
	withProbeProxies(t, "node-a")
	broken := probeServer(t, func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusInternalServerError)
	})

	result := handleOutboundIp(&OutboundIpParams{
		ProxyName: "node-a",
		Urls:      []string{broken.URL, broken.URL},
		Timeout:   3000,
	})

	if result.Error != probeErrorFailed {
		t.Errorf("error = %q, want %q", result.Error, probeErrorFailed)
	}
}

func TestHandleOutboundIpRejectsAnEmptySourceList(t *testing.T) {
	result := handleOutboundIp(&OutboundIpParams{ProxyName: "node-a", Timeout: 1000})
	if result.Error != probeErrorFailed {
		t.Errorf("error = %q, want %q", result.Error, probeErrorFailed)
	}
}
