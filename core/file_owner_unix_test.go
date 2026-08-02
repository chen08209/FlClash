//go:build !windows

package main

import "testing"

func TestRestoreFileOwnershipAsRestoresRealUser(t *testing.T) {
	called := false
	err := restoreFileOwnershipAs(
		"/tmp/profile.yaml",
		1000,
		1000,
		0,
		0,
		func(path string, uid int, gid int) error {
			called = true
			if path != "/tmp/profile.yaml" || uid != 1000 || gid != 1000 {
				t.Fatalf("unexpected chown arguments: %s %d:%d", path, uid, gid)
			}
			return nil
		},
	)
	if err != nil {
		t.Fatal(err)
	}
	if !called {
		t.Fatal("expected chown to be called")
	}
}

func TestRestoreFileOwnershipAsSkipsMatchingUser(t *testing.T) {
	err := restoreFileOwnershipAs(
		"/tmp/profile.yaml",
		1000,
		1000,
		1000,
		1000,
		func(string, int, int) error {
			t.Fatal("chown should not be called")
			return nil
		},
	)
	if err != nil {
		t.Fatal(err)
	}
}
