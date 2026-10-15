package core

import (
	"encoding/json"
	"os"
	"path/filepath"
	"runtime"
	"testing"

	"github.com/metacubex/mihomo/constant"
)

func withSpillHome(t *testing.T, threshold int) string {
	t.Helper()
	previousHome := constant.Path.HomeDir()
	previousThreshold := spillThreshold
	home := t.TempDir()
	constant.SetHomeDir(home)
	spillThreshold = threshold
	t.Cleanup(func() {
		constant.SetHomeDir(previousHome)
		spillThreshold = previousThreshold
	})
	return home
}

func getConfigCall(t *testing.T, id string) *MethodCall {
	t.Helper()
	path := filepath.Join(t.TempDir(), "profile.yaml")
	if err := os.WriteFile(path, []byte("mode: rule\nrules:\n  - MATCH,DIRECT\n"), 0o600); err != nil {
		t.Fatalf("write profile: %v", err)
	}
	arguments, _ := json.Marshal(path)
	return &MethodCall{ID: id, Method: getConfigMethod, Arguments: arguments}
}

func TestHandleMethodCallSpillsALargeResultToAFile(t *testing.T) {
	home := withSpillHome(t, 64)

	frame := handleMethodCall(getConfigCall(t, "7"))

	var envelope MethodResponse
	if err := json.Unmarshal(frame, &envelope); err != nil {
		t.Fatalf("response is not valid JSON: %v", err)
	}
	if envelope.ID != "7" || envelope.Result != nil || envelope.Error != nil {
		t.Fatalf("envelope = %+v, want only the id and the file", envelope)
	}
	if filepath.Dir(envelope.File) != filepath.Join(home, spilledResponseDirName) {
		t.Fatalf("file = %s, want it under the home directory's spill directory", envelope.File)
	}
	data, err := os.ReadFile(envelope.File)
	if err != nil {
		t.Fatalf("read spilled response: %v", err)
	}
	var spilled struct {
		ID     string         `json:"id"`
		Result map[string]any `json:"result"`
	}
	if err := json.Unmarshal(data, &spilled); err != nil {
		t.Fatalf("spilled response is not valid JSON: %v", err)
	}
	if spilled.ID != "7" || spilled.Result["mode"] != "rule" {
		t.Errorf("spilled response = %+v, want the full answer to call 7", spilled)
	}
	if runtime.GOOS != "windows" {
		info, _ := os.Stat(envelope.File)
		if info.Mode().Perm() != 0o644 {
			t.Errorf("mode = %v, want the host to be able to read it", info.Mode().Perm())
		}
	}
}

func TestHandleMethodCallAnswersInlineUnderTheThreshold(t *testing.T) {
	home := withSpillHome(t, responseSpillThreshold)

	frame := handleMethodCall(getConfigCall(t, "8"))

	var envelope MethodResponse
	if err := json.Unmarshal(frame, &envelope); err != nil {
		t.Fatalf("response is not valid JSON: %v", err)
	}
	if envelope.File != "" || envelope.Result == nil {
		t.Errorf("envelope = %+v, want the result inline", envelope)
	}
	if _, err := os.Stat(filepath.Join(home, spilledResponseDirName)); !os.IsNotExist(err) {
		t.Errorf("stat spill directory = %v, want nothing written", err)
	}
}

func TestClearSpilledResponsesKeepsTheDirectory(t *testing.T) {
	home := withSpillHome(t, 64)
	handleMethodCall(getConfigCall(t, "9"))

	clearSpilledResponses()

	entries, err := os.ReadDir(filepath.Join(home, spilledResponseDirName))
	if err != nil {
		t.Fatalf("read spill directory: %v", err)
	}
	if len(entries) != 0 {
		t.Errorf("entries = %v, want none left", entries)
	}
}
