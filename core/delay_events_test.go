//go:build !cgo

package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"
)

func capturedDelays(t *testing.T, run func()) []Delay {
	t.Helper()
	settleMessageBatcher()
	frames := captureFrames(t, func() {
		run()
		settleMessageBatcher()
	})
	var delays []Delay
	for _, frame := range frames {
		var batch struct {
			Arguments []struct {
				Type MessageType     `json:"type"`
				Data json.RawMessage `json:"data"`
			} `json:"arguments"`
		}
		if err := json.Unmarshal(frame, &batch); err != nil {
			t.Fatal(err)
		}
		for _, event := range batch.Arguments {
			if event.Type != DelayMessage {
				continue
			}
			var delay Delay
			if err := json.Unmarshal(event.Data, &delay); err != nil {
				t.Fatal(err)
			}
			delays = append(delays, delay)
		}
	}
	return delays
}

func TestHostDelayDoesNotPublishDuplicateHookEvent(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		time.Sleep(5 * time.Millisecond)
		w.WriteHeader(http.StatusNoContent)
	}))
	defer server.Close()
	tunnel.UpdateProxies(map[string]constant.Proxy{"host": namedProxy("host")}, nil)
	defer tunnel.UpdateProxies(nil, nil)
	delays := capturedDelays(t, func() {
		delay := handleTestDelay(&TestDelayParams{ProxyName: "host", TestUrl: server.URL, Timeout: 1000})
		if delay == nil || delay.Value < 1 {
			t.Fatalf("delay = %+v", delay)
		}
	})
	if len(delays) != 0 {
		t.Fatalf("host RPC also published stale-capable events: %+v", delays)
	}
	background := capturedDelays(t, func() { adapter.UrlTestHook(server.URL, "host", 23) })
	if len(background) != 1 || background[0].Value != 23 {
		t.Fatalf("background events = %+v", background)
	}
}

func TestOverlappingHostDelayHooksRemainSuppressedUntilBothSettle(t *testing.T) {
	entered := make(chan chan struct{}, 2)
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		release := make(chan struct{})
		entered <- release
		<-release
		w.WriteHeader(http.StatusNoContent)
	}))
	defer server.Close()
	tunnel.UpdateProxies(map[string]constant.Proxy{"host": namedProxy("host")}, nil)
	defer tunnel.UpdateProxies(nil, nil)
	done := make(chan *Delay, 2)
	delays := capturedDelays(t, func() {
		for i := 0; i < 2; i++ {
			go func() {
				done <- handleTestDelay(&TestDelayParams{ProxyName: "host", TestUrl: server.URL, Timeout: 2000})
			}()
		}
		first, second := <-entered, <-entered
		close(first)
		<-done
		adapter.UrlTestHook(server.URL, "host", 42)
		adapter.UrlTestHook(server.URL, "background", 24)
		adapter.UrlTestHook(server.URL+"/other", "host", 25)
		close(second)
		<-done
	})
	if len(delays) != 2 {
		t.Fatalf("events = %+v, want only unrelated background events", delays)
	}
	for _, delay := range delays {
		if delay.Name == "host" && delay.Url == server.URL {
			t.Fatalf("host event escaped: %+v", delay)
		}
	}
}
