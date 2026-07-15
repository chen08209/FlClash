package main

import (
	"os"
	"path/filepath"
	"testing"
)

func TestHandleGetConfigOmitsTunIPv6WhenIPv6IsDisabled(t *testing.T) {
	path := filepath.Join(t.TempDir(), "config.yaml")
	if err := os.WriteFile(path, []byte("ipv6: false\ntun:\n  enable: true\n"), 0o600); err != nil {
		t.Fatalf("write config: %v", err)
	}

	config, err := handleGetConfig(path)
	if err != nil {
		t.Fatalf("get config: %v", err)
	}
	if len(config.Tun.Inet6Address) != 0 {
		t.Fatalf("tun inet6-address = %v, want no addresses when IPv6 is disabled", config.Tun.Inet6Address)
	}
}
