package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"
)

func TestDownloadFile(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if got := r.Header.Get("User-Agent"); got != "FlClash/Test" {
			t.Errorf("unexpected User-Agent: %q", got)
		}
		w.Header().Set("Content-Disposition", "attachment; filename=profile.yaml")
		w.Header().Set("Subscription-Userinfo", "upload=1; total=10")
		_, _ = w.Write([]byte("proxies: []\n"))
	}))
	defer server.Close()

	path := filepath.Join(t.TempDir(), "profile.yaml")
	params, err := json.Marshal(&DownloadFileParams{
		URL:       server.URL,
		Path:      path,
		UserAgent: "FlClash/Test",
	})
	if err != nil {
		t.Fatal(err)
	}

	result, err := downloadFile(string(params))
	if err != nil {
		t.Fatalf("unexpected download error: %s", err)
	}
	if result.ContentDisposition != "attachment; filename=profile.yaml" {
		t.Errorf("unexpected Content-Disposition: %q", result.ContentDisposition)
	}
	if result.SubscriptionUserinfo != "upload=1; total=10" {
		t.Errorf("unexpected Subscription-Userinfo: %q", result.SubscriptionUserinfo)
	}
	content, err := os.ReadFile(path)
	if err != nil {
		t.Fatal(err)
	}
	if string(content) != "proxies: []\n" {
		t.Errorf("unexpected file content: %q", content)
	}
}

func TestDownloadFileDoesNotLeaveFileOnHTTPError(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusBadGateway)
	}))
	defer server.Close()

	path := filepath.Join(t.TempDir(), "profile.yaml")
	params, err := json.Marshal(&DownloadFileParams{URL: server.URL, Path: path})
	if err != nil {
		t.Fatal(err)
	}

	if _, err := downloadFile(string(params)); err == nil {
		t.Fatal("expected download error")
	}
	if _, err := os.Stat(path); !os.IsNotExist(err) {
		t.Fatalf("download file should not exist after an HTTP error: %v", err)
	}
}

func TestDownloadFilePreservesExistingTarget(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_, _ = w.Write([]byte("replacement"))
	}))
	defer server.Close()

	path := filepath.Join(t.TempDir(), "profile.yaml")
	if err := os.WriteFile(path, []byte("original"), 0o600); err != nil {
		t.Fatal(err)
	}
	params, err := json.Marshal(&DownloadFileParams{URL: server.URL, Path: path})
	if err != nil {
		t.Fatal(err)
	}

	if _, err := downloadFile(string(params)); err == nil {
		t.Fatal("expected download error")
	}
	content, err := os.ReadFile(path)
	if err != nil {
		t.Fatal(err)
	}
	if string(content) != "original" {
		t.Fatalf("existing target was modified: %q", content)
	}
}
