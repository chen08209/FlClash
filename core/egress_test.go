package core

import (
	"net/netip"
	"testing"

	"github.com/metacubex/mihomo/component/dialer"
	"github.com/metacubex/mihomo/config"
	LC "github.com/metacubex/mihomo/listener/config"
)

func withTunConfig(t *testing.T, device string) *config.Config {
	t.Helper()
	return &config.Config{
		General: &config.General{
			Tun: LC.Tun{
				Enable:              true,
				Device:              device,
				AutoRoute:           true,
				AutoDetectInterface: true,
			},
		},
	}
}

func withDetectEgress(t *testing.T, name string) {
	t.Helper()
	previous := detectEgress
	detectEgress = func() string { return name }
	t.Cleanup(func() {
		detectEgress = previous
		egressInterface = ""
		dialer.DefaultInterface.Store("")
	})
}

func withInstalledFinder(t *testing.T) {
	t.Helper()
	previous := dialer.DefaultInterfaceFinder.Load()
	dialer.DefaultInterfaceFinder.Store(fakeEgressFinder{})
	t.Cleanup(func() {
		dialer.DefaultInterfaceFinder.Store(previous)
	})
}

func TestEgressBootstrapPinsTheFirstApplyToTheDefaultInterface(t *testing.T) {
	withDetectEgress(t, "WLAN")
	cfg := withTunConfig(t, "FlClash")

	prepared := prepareEgress(cfg)

	if prepared == cfg {
		t.Fatal("expected the applied config to carry the bootstrap interface")
	}
	if prepared.General.Interface != "WLAN" {
		t.Fatalf("bootstrap interface = %q, want WLAN", prepared.General.Interface)
	}
	if cfg.General.Interface != "" {
		t.Fatalf("stored config interface = %q, want it untouched", cfg.General.Interface)
	}
	if egressInterface != "WLAN" {
		t.Fatalf("egressInterface = %q, want WLAN", egressInterface)
	}

	// The applied config is what executor stores as the default interface.
	dialer.DefaultInterface.Store(prepared.General.Interface)
	finishEgress()
	if loaded := dialer.DefaultInterface.Load(); loaded != "" {
		t.Fatalf("DefaultInterface after finish = %q, want empty", loaded)
	}
	if egressInterface != "" {
		t.Fatalf("egressInterface after finish = %q, want empty", egressInterface)
	}
}

func TestEgressBootstrapSkipsAnUnboundableDetection(t *testing.T) {
	for _, name := range []string{"", "FlClash"} {
		withDetectEgress(t, name)
		cfg := withTunConfig(t, "FlClash")

		if prepared := prepareEgress(cfg); prepared != cfg {
			t.Fatalf("detection %q pinned the egress", name)
		}
		if egressInterface != "" {
			t.Fatalf("detection %q set egressInterface", name)
		}
	}
}

func TestEgressBootstrapKeepsAConfiguredInterface(t *testing.T) {
	withDetectEgress(t, "WLAN")
	cfg := withTunConfig(t, "FlClash")
	cfg.General.Interface = "Ethernet"

	if prepared := prepareEgress(cfg); prepared != cfg {
		t.Fatal("a configured interface was replaced by the bootstrap")
	}
}

func TestEgressBootstrapSkipsAutoDetectOffAndLaterApplies(t *testing.T) {
	withDetectEgress(t, "WLAN")

	undetected := withTunConfig(t, "FlClash")
	undetected.General.Tun.AutoDetectInterface = false
	if prepared := prepareEgress(undetected); prepared != undetected {
		t.Fatal("bootstrapped with auto-detect-interface off")
	}

	unrouted := withTunConfig(t, "FlClash")
	unrouted.General.Tun.AutoRoute = false
	if prepared := prepareEgress(unrouted); prepared != unrouted {
		t.Fatal("bootstrapped with auto-route off")
	}

	disabled := withTunConfig(t, "FlClash")
	disabled.General.Tun.Enable = false
	if prepared := prepareEgress(disabled); prepared != disabled {
		t.Fatal("bootstrapped with the TUN off")
	}

	withInstalledFinder(t)
	if prepared := prepareEgress(withTunConfig(t, "FlClash")); prepared.General.Interface != "" {
		t.Fatal("bootstrapped while the TUN finder is already installed")
	}
}

func TestEgressFinishLeavesALaterInterfaceAlone(t *testing.T) {
	withDetectEgress(t, "WLAN")
	cfg := withTunConfig(t, "FlClash")
	prepareEgress(cfg)
	dialer.DefaultInterface.Store("Ethernet")

	finishEgress()

	if loaded := dialer.DefaultInterface.Load(); loaded != "Ethernet" {
		t.Fatalf("DefaultInterface after finish = %q, want the later value kept", loaded)
	}
}

type fakeEgressFinder struct{}

func (fakeEgressFinder) FindInterfaceName(destination netip.Addr) string {
	return "WLAN"
}
