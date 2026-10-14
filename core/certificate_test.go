package core

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/metacubex/mihomo/component/ca"
	mihomoHttp "github.com/metacubex/mihomo/component/http"
	"github.com/metacubex/mihomo/config"
)

func withSkipCertVerify(t *testing.T, skip bool) {
	t.Helper()
	previous := skipCertVerify.Load()
	skipCertVerify.Store(skip)
	t.Cleanup(func() { skipCertVerify.Store(previous) })
}

func fetchSelfSigned(t *testing.T, options ...mihomoHttp.Option) error {
	t.Helper()
	server := httptest.NewTLSServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		_, _ = w.Write([]byte("ok"))
	}))
	t.Cleanup(server.Close)
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	resp, err := mihomoHttp.HttpRequest(ctx, server.URL, http.MethodGet, nil, nil, options...)
	if err != nil {
		return err
	}
	return resp.Body.Close()
}

func TestDownloadRejectsAnUntrustedCertificateByDefault(t *testing.T) {
	withSkipCertVerify(t, false)

	err := fetchSelfSigned(t)

	if err == nil || providerRequestFailureReason(err) != "tls" {
		t.Fatalf("error = %v, want a tls failure", err)
	}
}

func TestDownloadAcceptsAnUntrustedCertificateWhenCheckIsOff(t *testing.T) {
	withSkipCertVerify(t, true)

	if err := fetchSelfSigned(t); err != nil {
		t.Fatalf("error = %v, want the self-signed server accepted", err)
	}
}

func TestSkipCertVerifyLeavesExplicitCAOptionsStrict(t *testing.T) {
	withSkipCertVerify(t, true)

	err := fetchSelfSigned(t, mihomoHttp.WithCAOption(ca.Option{ZeroTrust: true}))

	if err == nil || providerRequestFailureReason(err) != "tls" {
		t.Fatalf("error = %v, want a tls failure for a zero-trust request", err)
	}
}

func TestUpdateConfigAppliesSkipCertVerify(t *testing.T) {
	withCurrentConfig(t, &config.Config{General: &config.General{}, Controller: &config.Controller{}})
	withSkipCertVerify(t, false)
	skip := true

	if err := updateConfig(&UpdateParams{SkipCertVerify: &skip}); err != nil {
		t.Fatalf("updateConfig error: %v", err)
	}
	if !skipCertVerify.Load() {
		t.Fatal("skip-cert-verify never reached the download policy")
	}
	if err := updateConfig(&UpdateParams{}); err != nil {
		t.Fatalf("updateConfig error: %v", err)
	}
	if !skipCertVerify.Load() {
		t.Error("an update without skip-cert-verify reset the download policy")
	}
}
