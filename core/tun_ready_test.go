//go:build linux

package main

import (
	"context"
	"errors"
	"net/netip"
	"testing"
	"time"

	"github.com/metacubex/mihomo/component/dialer"
	"github.com/metacubex/mihomo/config"
	listenerConfig "github.com/metacubex/mihomo/listener/config"
)

type sequenceInterfaceFinder struct {
	names []string
	index int
}

type signalingInterfaceFinder struct {
	called chan struct{}
}

func (f *sequenceInterfaceFinder) FindInterfaceName(netip.Addr) string {
	if f.index >= len(f.names) {
		return f.names[len(f.names)-1]
	}
	name := f.names[f.index]
	f.index++
	return name
}

func (f *signalingInterfaceFinder) FindInterfaceName(netip.Addr) string {
	select {
	case f.called <- struct{}{}:
	default:
	}
	return "<invalid>"
}

func TestWaitForTunInterfaceWaitsUntilReady(t *testing.T) {
	restoreTunReadyGlobals(t)
	currentConfig = tunReadyTestConfig(true)
	dialer.DefaultInterfaceFinder.Store(&sequenceInterfaceFinder{
		names: []string{"<invalid>", "eth0"},
	})

	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	defer cancel()
	if err := waitForTunInterfaceWithInterval(ctx, time.Millisecond); err != nil {
		t.Fatal(err)
	}
}

func TestWaitForTunInterfaceHonorsTimeout(t *testing.T) {
	restoreTunReadyGlobals(t)
	currentConfig = tunReadyTestConfig(true)
	dialer.DefaultInterfaceFinder.Store(&sequenceInterfaceFinder{
		names: []string{"<invalid>"},
	})

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Millisecond)
	defer cancel()
	err := waitForTunInterfaceWithInterval(ctx, time.Millisecond)
	if !errors.Is(err, context.DeadlineExceeded) {
		t.Fatalf("expected deadline exceeded, got %v", err)
	}
}

func TestWaitForTunInterfaceDoesNotHoldRunLock(t *testing.T) {
	restoreTunReadyGlobals(t)
	currentConfig = tunReadyTestConfig(true)
	finder := &signalingInterfaceFinder{called: make(chan struct{}, 1)}
	dialer.DefaultInterfaceFinder.Store(finder)

	ctx, cancel := context.WithCancel(context.Background())
	waitDone := make(chan error, 1)
	go func() {
		waitDone <- waitForTunInterfaceWithInterval(ctx, time.Millisecond)
	}()

	select {
	case <-finder.called:
	case <-time.After(time.Second):
		cancel()
		<-waitDone
		t.Fatal("interface readiness check did not start")
	}

	lockAcquired := make(chan struct{})
	go func() {
		runLock.Lock()
		close(lockAcquired)
		runLock.Unlock()
	}()
	select {
	case <-lockAcquired:
	case <-time.After(time.Second):
		cancel()
		<-waitDone
		t.Fatal("TUN readiness wait blocked runLock")
	}

	cancel()
	if err := <-waitDone; !errors.Is(err, context.Canceled) {
		t.Fatalf("expected canceled wait, got %v", err)
	}
}

func TestWaitForTunInterfaceSkipsDisabledTun(t *testing.T) {
	restoreTunReadyGlobals(t)
	currentConfig = tunReadyTestConfig(false)
	dialer.DefaultInterfaceFinder.Store(nil)

	if err := waitForTunInterfaceWithInterval(context.Background(), time.Millisecond); err != nil {
		t.Fatal(err)
	}
}

func restoreTunReadyGlobals(t *testing.T) {
	t.Helper()
	previousConfig := currentConfig
	previousFinder := dialer.DefaultInterfaceFinder.Load()
	t.Cleanup(func() {
		currentConfig = previousConfig
		dialer.DefaultInterfaceFinder.Store(previousFinder)
	})
}

func tunReadyTestConfig(enabled bool) *config.Config {
	return &config.Config{
		General: &config.General{
			Inbound: config.Inbound{
				Tun: listenerConfig.Tun{
					Enable:              enabled,
					AutoDetectInterface: enabled,
				},
			},
		},
	}
}
