//go:build android && cgo

package platform

import (
	"sync/atomic"
	"syscall"
	"time"

	"github.com/metacubex/mihomo/log"
)

const fdPressureWindow = 10 * time.Millisecond

var nullFd = -1
var maxFdCount int

var (
	lastProbeAt      atomic.Int64
	lastProbeBlocked atomic.Bool
)

func init() {
	// This runs while the shared library is being loaded, so a panic here takes
	// the application down before it has a chance to report anything. The probe
	// is a safety valve against fd exhaustion rather than something correctness
	// depends on, so a failure to arm it degrades to never blocking.
	fd, err := syscall.Open("/dev/null", syscall.O_WRONLY, 0644)
	if err != nil {
		log.Errorln("[APP] fd pressure probe disabled: %v", err)
		return
	}

	nullFd = fd

	var limit syscall.Rlimit

	if err := syscall.Getrlimit(syscall.RLIMIT_NOFILE, &limit); err != nil {
		maxFdCount = 1024
	} else {
		maxFdCount = int(limit.Cur)
	}

	maxFdCount = maxFdCount / 4 * 3
}

func ShouldBlockConnection() bool {
	if nullFd < 0 {
		return false
	}

	now := time.Now().UnixNano()
	if !lastProbeBlocked.Load() {
		if last := lastProbeAt.Load(); last != 0 && now-last < int64(fdPressureWindow) {
			return false
		}
	}

	blocked := probeFdPressure()
	lastProbeBlocked.Store(blocked)
	lastProbeAt.Store(now)
	return blocked
}

func probeFdPressure() bool {
	fd, err := syscall.Dup(nullFd)
	if err != nil {
		return true
	}

	_ = syscall.Close(fd)

	return fd > maxFdCount
}
