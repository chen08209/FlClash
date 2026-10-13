package core

import (
	"net"
	"testing"

	mihomoTLS "github.com/metacubex/mihomo/component/tls"
	utls "github.com/metacubex/utls"
)

func TestBrowserFingerprintsOfferPostQuantumKeyShare(t *testing.T) {
	for _, name := range []string{"safari", "chrome", "firefox"} {
		t.Run(name, func(t *testing.T) {
			fingerprint, ok := mihomoTLS.GetFingerprint(name)
			if !ok {
				t.Fatalf("fingerprint %q is unknown", name)
			}
			client, server := net.Pipe()
			defer client.Close()
			defer server.Close()

			conn := utls.UClient(client, &utls.Config{ServerName: "example.com"}, fingerprint)
			if err := conn.BuildHandshakeState(); err != nil {
				t.Fatal(err)
			}
			for _, share := range conn.HandshakeState.Hello.KeyShares {
				if share.Group == utls.X25519MLKEM768 {
					return
				}
			}
			t.Fatalf("%s-%s sends no X25519MLKEM768 key share", fingerprint.Client, fingerprint.Version)
		})
	}
}
