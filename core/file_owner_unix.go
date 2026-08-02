//go:build !windows

package main

import "os"

func restoreFileOwnership(path string) error {
	return restoreFileOwnershipAs(
		path,
		os.Getuid(),
		os.Getgid(),
		os.Geteuid(),
		os.Getegid(),
		os.Chown,
	)
}

func restoreFileOwnershipAs(
	path string,
	uid int,
	gid int,
	effectiveUID int,
	effectiveGID int,
	chown func(string, int, int) error,
) error {
	if uid == effectiveUID && gid == effectiveGID {
		return nil
	}
	return chown(path, uid, gid)
}
