package core

import (
	"crypto/x509"
	"sync/atomic"

	"github.com/metacubex/mihomo/log"
	"github.com/metacubex/tls"
)

// The inverse of checkCertificate, which FlClashHttpOverrides applies to Dart's own downloads.
var skipCertVerify atomic.Bool

func relaxCertVerify(tlsConfig *tls.Config) {
	if !skipCertVerify.Load() {
		return
	}
	tlsConfig.InsecureSkipVerify = true
	tlsConfig.VerifyConnection = func(state tls.ConnectionState) error {
		if len(state.PeerCertificates) == 0 {
			return nil
		}
		leaf := state.PeerCertificates[0]
		if err := verifyPeer(tlsConfig, state); err != nil {
			log.Warnln("[TLS] accepting untrusted certificate %s issued by %s, certificate check is off: %v", leaf.Subject, leaf.Issuer, err)
		}
		return nil
	}
}

func verifyPeer(tlsConfig *tls.Config, state tls.ConnectionState) error {
	opts := x509.VerifyOptions{
		Roots:         tlsConfig.RootCAs,
		DNSName:       state.ServerName,
		Intermediates: x509.NewCertPool(),
	}
	if tlsConfig.Time != nil {
		opts.CurrentTime = tlsConfig.Time()
	}
	for _, cert := range state.PeerCertificates[1:] {
		opts.Intermediates.AddCert(cert)
	}
	_, err := state.PeerCertificates[0].Verify(opts)
	return err
}
