//go:build (darwin || linux) && !android

package main

import (
	"errors"
	"io/fs"
	"os"
	"path/filepath"
	"syscall"
	"testing"
)

func TestCanReclaimRequiresADirectoryOwnedByTheCaller(t *testing.T) {
	homeDir := t.TempDir()
	uid := os.Getuid()

	if !canReclaim(homeDir, uid) {
		t.Fatal("a directory owned by the caller must be reclaimable")
	}
	if canReclaim(homeDir, uid+1) {
		t.Error("a directory owned by somebody else must be refused")
	}
	if canReclaim("", uid) {
		t.Error("an empty home directory must be refused")
	}
	if canReclaim(filepath.Join(homeDir, "missing"), uid) {
		t.Error("a missing path must be refused")
	}

	file := filepath.Join(homeDir, "config.yaml")
	if err := os.WriteFile(file, []byte("mixed-port: 7890\n"), 0o600); err != nil {
		t.Fatalf("write error: %v", err)
	}
	if canReclaim(file, uid) {
		t.Error("a regular file must be refused")
	}

	link := filepath.Join(homeDir, "link")
	if err := os.Symlink(homeDir, link); err != nil {
		t.Fatalf("symlink error: %v", err)
	}
	if canReclaim(link, uid) {
		t.Error("a symlink to a directory must be refused")
	}
}

func TestShouldReclaimEntrySkipsOwnedLinkedAndSymlinkedEntries(t *testing.T) {
	homeDir := t.TempDir()
	uid := os.Getuid()
	foreign := uid + 1

	file := filepath.Join(homeDir, "provider")
	if err := os.WriteFile(file, []byte("proxies: []\n"), 0o600); err != nil {
		t.Fatalf("write error: %v", err)
	}
	info, err := os.Lstat(file)
	if err != nil {
		t.Fatalf("lstat error: %v", err)
	}
	if !shouldReclaimEntry(info, foreign) {
		t.Error("a file owned by another user must be reclaimed")
	}
	if shouldReclaimEntry(info, uid) {
		t.Error("a file already owned by the caller must be skipped")
	}

	hardLink := filepath.Join(homeDir, "hardlink")
	if err := os.Link(file, hardLink); err != nil {
		t.Fatalf("link error: %v", err)
	}
	linkInfo, err := os.Lstat(hardLink)
	if err != nil {
		t.Fatalf("lstat error: %v", err)
	}
	if shouldReclaimEntry(linkInfo, foreign) {
		t.Error("a hard link must be skipped so it cannot smuggle in a foreign inode")
	}

	symLink := filepath.Join(homeDir, "symlink")
	if err := os.Symlink(file, symLink); err != nil {
		t.Fatalf("symlink error: %v", err)
	}
	symInfo, err := os.Lstat(symLink)
	if err != nil {
		t.Fatalf("lstat error: %v", err)
	}
	if shouldReclaimEntry(symInfo, foreign) {
		t.Error("a symlink must be skipped")
	}

	dirInfo, err := os.Lstat(homeDir)
	if err != nil {
		t.Fatalf("lstat error: %v", err)
	}
	if !shouldReclaimEntry(dirInfo, foreign) {
		t.Error("a directory must be reclaimed even though its link count exceeds one")
	}
}

func TestCollectReclaimTargetsWalksWithoutFollowingSymlinks(t *testing.T) {
	homeDir := t.TempDir()
	uid := os.Getuid()

	providers := filepath.Join(homeDir, "profiles", "providers", "1", "proxies")
	if err := os.MkdirAll(providers, 0o755); err != nil {
		t.Fatalf("mkdir error: %v", err)
	}
	if err := os.WriteFile(filepath.Join(providers, "abc"), []byte("proxies: []\n"), 0o600); err != nil {
		t.Fatalf("write error: %v", err)
	}

	if targets := collectReclaimTargets(homeDir, uid); len(targets) != 0 {
		t.Errorf("targets = %v, want nothing when the caller already owns the tree", targets)
	}
	if targets := collectReclaimTargets(homeDir, uid+1); targets != nil {
		t.Errorf("targets = %v, want nil when the home directory belongs to somebody else", targets)
	}

	outside := t.TempDir()
	if err := os.WriteFile(filepath.Join(outside, "secret"), []byte("secret"), 0o600); err != nil {
		t.Fatalf("write error: %v", err)
	}
	if err := os.Symlink(outside, filepath.Join(homeDir, "escape")); err != nil {
		t.Fatalf("symlink error: %v", err)
	}
	for _, target := range collectReclaimTargets(homeDir, uid) {
		if target.path == filepath.Join(outside, "secret") {
			t.Fatal("the walk must not follow a symlink out of the home directory")
		}
	}
}

func reclaimTargetFor(t *testing.T, path string) reclaimTarget {
	t.Helper()
	info, err := os.Lstat(path)
	if err != nil {
		t.Fatalf("lstat error: %v", err)
	}
	stat, ok := info.Sys().(*syscall.Stat_t)
	if !ok {
		t.Fatalf("stat type = %T, want *syscall.Stat_t", info.Sys())
	}
	return reclaimTarget{path: path, dev: uint64(stat.Dev), ino: uint64(stat.Ino)}
}

func TestReclaimEntryVerifiesTheInodeItChowns(t *testing.T) {
	homeDir := t.TempDir()
	uid := os.Getuid()
	gid := os.Getgid()
	foreign := uid + 1

	file := filepath.Join(homeDir, "provider")
	if err := os.WriteFile(file, []byte("proxies: []\n"), 0o600); err != nil {
		t.Fatalf("write error: %v", err)
	}

	if ok, err := reclaimEntry(reclaimTargetFor(t, file), uid, gid); ok || err != nil {
		t.Errorf("reclaimEntry = (%v, %v), want no work for an entry the caller owns", ok, err)
	}

	hardLink := filepath.Join(homeDir, "hardlink")
	if err := os.Link(file, hardLink); err != nil {
		t.Fatalf("link error: %v", err)
	}
	if ok, err := reclaimEntry(reclaimTargetFor(t, hardLink), foreign, gid); ok || err != nil {
		t.Errorf("reclaimEntry = (%v, %v), want a hard link left alone", ok, err)
	}

	symLink := filepath.Join(homeDir, "symlink")
	if err := os.Symlink(file, symLink); err != nil {
		t.Fatalf("symlink error: %v", err)
	}
	if _, err := reclaimEntry(reclaimTargetFor(t, symLink), foreign, gid); !errors.Is(err, syscall.ELOOP) {
		t.Errorf("reclaimEntry error = %v, want ELOOP so a swapped final component cannot redirect the chown", err)
	}

	fifo := filepath.Join(homeDir, "fifo")
	if err := syscall.Mkfifo(fifo, 0o600); err != nil {
		t.Fatalf("mkfifo error: %v", err)
	}
	if ok, err := reclaimEntry(reclaimTargetFor(t, fifo), foreign, gid); ok || err != nil {
		t.Errorf("reclaimEntry = (%v, %v), want a fifo skipped without blocking", ok, err)
	}

	missing := reclaimTarget{path: filepath.Join(homeDir, "missing")}
	if _, err := reclaimEntry(missing, foreign, gid); !errors.Is(err, fs.ErrNotExist) {
		t.Errorf("reclaimEntry error = %v, want a missing entry reported as absent", err)
	}

	plain := filepath.Join(homeDir, "plain")
	if err := os.WriteFile(plain, []byte("proxies: []\n"), 0o600); err != nil {
		t.Fatalf("write error: %v", err)
	}
	if _, err := reclaimEntry(reclaimTargetFor(t, plain), foreign, gid); err == nil {
		t.Error("a foreign-owned regular file must reach fchown, which only root may complete")
	}
}

func TestReclaimEntryRefusesAPathSwappedThroughAnIntermediateComponent(t *testing.T) {
	homeDir := t.TempDir()
	outside := t.TempDir()
	gid := os.Getgid()
	foreign := os.Getuid() + 1

	profiles := filepath.Join(homeDir, "profiles")
	if err := os.Mkdir(profiles, 0o755); err != nil {
		t.Fatalf("mkdir error: %v", err)
	}
	entry := filepath.Join(profiles, "provider")
	if err := os.WriteFile(entry, []byte("proxies: []\n"), 0o600); err != nil {
		t.Fatalf("write error: %v", err)
	}
	target := reclaimTargetFor(t, entry)

	if err := os.WriteFile(filepath.Join(outside, "provider"), []byte("secret"), 0o600); err != nil {
		t.Fatalf("write error: %v", err)
	}
	if err := os.Rename(profiles, filepath.Join(homeDir, "moved")); err != nil {
		t.Fatalf("rename error: %v", err)
	}
	if err := os.Symlink(outside, profiles); err != nil {
		t.Fatalf("symlink error: %v", err)
	}

	if ok, err := reclaimEntry(target, foreign, gid); ok || err != nil {
		t.Errorf("reclaimEntry = (%v, %v), want the chown refused once an intermediate component was swapped", ok, err)
	}
}

func TestScheduleReclaimOwnershipOnlyUsesTheHomeDirInitPassed(t *testing.T) {
	t.Cleanup(func() { reclaimHomeDir.Store("") })
	reclaimHomeDir.Store("")

	scheduleReclaimOwnership()

	if homeDir, _ := reclaimHomeDir.Load().(string); homeDir != "" {
		t.Errorf("home dir = %q, want the sweep to stay unarmed until init records one", homeDir)
	}

	initOwnership(t.TempDir())

	if homeDir, _ := reclaimHomeDir.Load().(string); homeDir == "" {
		t.Error("init must record the home directory the app handed the core")
	}
}
