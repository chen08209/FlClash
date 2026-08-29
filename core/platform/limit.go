//go:build android && cgo

package platform

import (
	"errors"
	"os"
	"sync/atomic"
	"syscall"
	"time"

	"github.com/metacubex/mihomo/log"
)

const (
	fdPressureWindow = 10 * time.Millisecond
	fallbackFdLimit  = 1024
	// A sanity bound for RLIMIT_NOFILE. RLIM_INFINITY does not fit an int on
	// 32-bit ABIs (armeabi-v7a), and no Android process has a real budget
	// anywhere near this.
	maxFdLimit = 1 << 20
)

var nullFd = -1

var (
	probeArmed       atomic.Bool
	fdCeiling        atomic.Int64
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
	probeArmed.Store(true)
}

// fdCeilingValue is read lazily rather than at load time. The Go runtime raises
// RLIMIT_NOFILE towards the hard limit while it starts, and a ceiling captured
// before that lands would pin the probe to three quarters of the *old* soft
// limit and cut off every dial in a process that still has thousands of
// descriptors to spare.
func fdCeilingValue() int {
	if value := fdCeiling.Load(); value != 0 {
		return int(value)
	}
	return refreshFdCeiling()
}

func refreshFdCeiling() int {
	limit := fallbackFdLimit

	var rlimit syscall.Rlimit
	if err := syscall.Getrlimit(syscall.RLIMIT_NOFILE, &rlimit); err == nil {
		current := rlimit.Cur
		if current > maxFdLimit {
			current = maxFdLimit
		}
		if current > 0 {
			limit = int(current)
		}
	}

	ceiling := limit / 4 * 3
	fdCeiling.Store(int64(ceiling))
	return ceiling
}

func disarmProbe(err error) {
	if !probeArmed.CompareAndSwap(true, false) {
		return
	}
	lastProbeBlocked.Store(false)
	log.Errorln("[APP] fd pressure probe disabled after an unexpected error: %v", err)
}

// openFdCount reports how many descriptors the process actually holds, or -1
// when that cannot be established.
func openFdCount() int {
	dir, err := os.Open("/proc/self/fd")
	if err != nil {
		return -1
	}
	defer dir.Close()

	names, err := dir.Readdirnames(-1)
	if err != nil {
		return -1
	}
	// dir itself is one of the entries it just listed.
	return len(names) - 1
}

func ShouldBlockConnection() bool {
	if !probeArmed.Load() {
		return false
	}

	now := time.Now().UnixNano()
	if !lastProbeBlocked.Load() {
		if last := lastProbeAt.Load(); last != 0 && now-last < int64(fdPressureWindow) {
			return false
		}
	}

	blocked := probeFdPressure()
	if lastProbeBlocked.Swap(blocked) != blocked {
		if blocked {
			log.Warnln(
				"[APP] refusing new connections: %d of %d descriptors in use",
				openFdCount(),
				fdCeilingValue(),
			)
		} else {
			log.Warnln("[APP] descriptor pressure cleared, accepting new connections")
		}
	}
	lastProbeAt.Store(now)
	return blocked
}

func probeFdPressure() bool {
	fd, err := syscall.Dup(nullFd)
	if err != nil {
		// Running out of descriptors is the one condition this probe exists
		// for. Any other error means the probe itself is broken - most likely
		// nullFd was closed elsewhere and its number handed to something else -
		// and blocking every dial in the process forever on a broken probe is
		// far worse than not probing at all.
		if errors.Is(err, syscall.EMFILE) || errors.Is(err, syscall.ENFILE) {
			return true
		}
		disarmProbe(err)
		return false
	}

	lowestFree := fd
	_ = syscall.Close(fd)

	if lowestFree <= fdCeilingValue() {
		return false
	}

	// dup() reports the lowest free descriptor, not how many are open: a single
	// long-lived descriptor high in the table pushes it past the ceiling while
	// the process is nowhere near its limit. Re-read the limit the runtime may
	// have raised since, then count for real before cutting off every dial.
	refreshFdCeiling()
	count := openFdCount()
	if count < 0 {
		return false
	}
	return count > fdCeilingValue()
}
