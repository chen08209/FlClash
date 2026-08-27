//go:build (darwin || linux) && !android

package main

import (
	"errors"
	"io/fs"
	"os"
	"path/filepath"
	"sync/atomic"
	"syscall"
	"time"

	"github.com/metacubex/mihomo/log"
)

const reclaimDebounce = 2 * time.Second

var (
	realUid = os.Getuid()
	realGid = os.Getgid()

	reclaimPending atomic.Bool
	reclaimHomeDir atomic.Value
)

func isElevated() bool {
	return os.Geteuid() == 0 && realUid != 0
}

func canReclaim(homeDir string, uid int) bool {
	if homeDir == "" {
		return false
	}
	info, err := os.Lstat(homeDir)
	if err != nil || !info.IsDir() {
		return false
	}
	stat, ok := info.Sys().(*syscall.Stat_t)
	return ok && int(stat.Uid) == uid
}

func shouldReclaimEntry(info fs.FileInfo, uid int) bool {
	if info.Mode()&fs.ModeSymlink != 0 {
		return false
	}
	stat, ok := info.Sys().(*syscall.Stat_t)
	if !ok {
		return false
	}
	if int(stat.Uid) == uid {
		return false
	}
	return info.IsDir() || stat.Nlink <= 1
}

type reclaimTarget struct {
	path string
	dev  uint64
	ino  uint64
}

func collectReclaimTargets(homeDir string, uid int) []reclaimTarget {
	if !canReclaim(homeDir, uid) {
		return nil
	}
	var targets []reclaimTarget
	_ = filepath.WalkDir(homeDir, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return nil
		}
		info, infoErr := d.Info()
		if infoErr != nil {
			return nil
		}
		if !shouldReclaimEntry(info, uid) {
			return nil
		}
		stat, ok := info.Sys().(*syscall.Stat_t)
		if !ok {
			return nil
		}
		targets = append(targets, reclaimTarget{
			path: path,
			dev:  uint64(stat.Dev),
			ino:  uint64(stat.Ino),
		})
		return nil
	})
	return targets
}

func isReclaimableStat(stat *syscall.Stat_t, uid int) bool {
	switch stat.Mode & syscall.S_IFMT {
	case syscall.S_IFDIR:
	case syscall.S_IFREG:
		if stat.Nlink > 1 {
			return false
		}
	default:
		return false
	}
	return int(stat.Uid) != uid
}

func reclaimEntry(target reclaimTarget, uid int, gid int) (bool, error) {
	fd, err := syscall.Open(
		target.path,
		syscall.O_RDONLY|syscall.O_NOFOLLOW|syscall.O_NONBLOCK|syscall.O_CLOEXEC,
		0,
	)
	if err != nil {
		return false, err
	}
	defer syscall.Close(fd)
	var stat syscall.Stat_t
	if err := syscall.Fstat(fd, &stat); err != nil {
		return false, err
	}
	if uint64(stat.Dev) != target.dev || uint64(stat.Ino) != target.ino {
		return false, nil
	}
	if !isReclaimableStat(&stat, uid) {
		return false, nil
	}
	if err := syscall.Fchown(fd, uid, gid); err != nil {
		return false, err
	}
	return true, nil
}

func reclaimOwnership(homeDir string) {
	if !isElevated() {
		return
	}
	targets := collectReclaimTargets(homeDir, realUid)
	if len(targets) == 0 {
		return
	}
	reclaimed := 0
	for _, target := range targets {
		ok, err := reclaimEntry(target, realUid, realGid)
		if err != nil {
			if !errors.Is(err, fs.ErrNotExist) {
				log.Warnln("[APP] reclaim %s: %v", target.path, err)
			}
			continue
		}
		if ok {
			reclaimed++
		}
	}
	log.Infoln("[APP] reclaimed %d of %d elevated entries under %s", reclaimed, len(targets), homeDir)
}

func initOwnership(homeDir string) {
	reclaimHomeDir.Store(homeDir)
	reclaimOwnership(homeDir)
}

func scheduleReclaimOwnership() {
	if !isElevated() {
		return
	}
	homeDir, _ := reclaimHomeDir.Load().(string)
	if homeDir == "" {
		return
	}
	if !reclaimPending.CompareAndSwap(false, true) {
		return
	}
	go func() {
		time.Sleep(reclaimDebounce)
		reclaimPending.Store(false)
		reclaimOwnership(homeDir)
	}()
}
