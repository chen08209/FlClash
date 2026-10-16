package core

import (
	"io"
	"net"
	"testing"

	"github.com/metacubex/mihomo/adapter/outbound"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel/statistic"
)

type pipeTracker interface {
	statistic.Tracker
	io.Writer
}

func newPipeTracker(t *testing.T) pipeTracker {
	t.Helper()
	local, remote := net.Pipe()
	go func() { _, _ = io.Copy(io.Discard, remote) }()
	direct := outbound.NewDirectWithOption(outbound.DirectOption{Name: "DIRECT"})
	tracker := statistic.NewTCPTracker(
		outbound.NewConn(local, direct),
		statistic.DefaultManager,
		&constant.Metadata{},
		nil,
		0,
		0,
		false,
	)
	t.Cleanup(func() {
		_ = tracker.Close()
		_ = remote.Close()
	})
	return tracker
}

func collectDelivered(watch *requestTrafficWatch, isOpen func(string) bool) (changed []RequestTraffic, watching bool) {
	watching = watch.collect(isOpen, func(traffic []RequestTraffic) bool {
		changed = traffic
		return true
	})
	return changed, watching
}

func TestRequestTrafficReportsChangesUntilTheRequestCloses(t *testing.T) {
	tracker := newPipeTracker(t)
	watch := requestTrafficWatch{requests: map[string]*watchedRequest{}}
	open := true
	isOpen := func(string) bool { return open }

	if !watch.add(tracker) {
		t.Fatal("the first request did not start the watch")
	}
	if changed, watching := collectDelivered(&watch, isOpen); len(changed) != 0 || !watching {
		t.Fatalf("idle request: changed %v, watching %v", changed, watching)
	}

	if _, err := tracker.Write([]byte("hello")); err != nil {
		t.Fatalf("write: %v", err)
	}
	changed, _ := collectDelivered(&watch, isOpen)
	if len(changed) != 1 || changed[0].Id != tracker.ID() || changed[0].Upload != 5 {
		t.Fatalf("after a write: %v", changed)
	}
	if changed, _ := collectDelivered(&watch, isOpen); len(changed) != 0 {
		t.Fatalf("unchanged traffic reported again: %v", changed)
	}

	if _, err := tracker.Write([]byte("bye")); err != nil {
		t.Fatalf("write: %v", err)
	}
	open = false
	changed, watching := collectDelivered(&watch, isOpen)
	if len(changed) != 1 || changed[0].Upload != 8 || watching {
		t.Fatalf("closed request: changed %v, watching %v", changed, watching)
	}
	if !watch.add(tracker) {
		t.Fatal("a request after the watch stopped did not restart it")
	}
}

func TestRequestTrafficKeepsARequestTheManagerHasNotStoredYet(t *testing.T) {
	tracker := newPipeTracker(t)
	watch := requestTrafficWatch{requests: map[string]*watchedRequest{}}
	closed := func(string) bool { return false }

	watch.add(tracker)
	if _, watching := collectDelivered(&watch, closed); !watching {
		t.Fatal("a request announced before it was stored was dropped on its first report")
	}
	if _, watching := collectDelivered(&watch, closed); watching {
		t.Fatal("a closed request was kept past its second report")
	}
}

func TestRequestTrafficResendsTheLastTotalsOfAClosedRequestUntilQueued(t *testing.T) {
	tracker := newPipeTracker(t)
	watch := requestTrafficWatch{requests: map[string]*watchedRequest{}}
	open := true
	isOpen := func(string) bool { return open }
	dropped := func([]RequestTraffic) bool { return false }

	watch.add(tracker)
	collectDelivered(&watch, isOpen)
	if _, err := tracker.Write([]byte("bye")); err != nil {
		t.Fatalf("write: %v", err)
	}
	open = false
	if !watch.collect(isOpen, dropped) {
		t.Fatal("a closed request whose last totals were dropped was let go")
	}
	changed, watching := collectDelivered(&watch, isOpen)
	if len(changed) != 1 || changed[0].Upload != 3 || watching {
		t.Fatalf("after the dropped report: changed %v, watching %v", changed, watching)
	}
}

func TestRequestTrafficGivesUpOnAClosedRequestItCannotReport(t *testing.T) {
	tracker := newPipeTracker(t)
	watch := requestTrafficWatch{requests: map[string]*watchedRequest{}}
	closed := func(string) bool { return false }
	dropped := func([]RequestTraffic) bool { return false }

	watch.add(tracker)
	watch.collect(closed, dropped)
	if _, err := tracker.Write([]byte("bye")); err != nil {
		t.Fatalf("write: %v", err)
	}
	for report := 1; report <= requestTrafficCloseRetries; report++ {
		if !watch.collect(closed, dropped) {
			t.Fatalf("let go after %d dropped reports", report)
		}
	}
	if watch.collect(closed, dropped) {
		t.Fatal("a closed request outlived its retries")
	}
}
