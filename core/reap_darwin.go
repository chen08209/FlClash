package core

import (
	"os"
	"os/signal"
	"sync"
	"syscall"

	"golang.org/x/sys/unix"
)

// sing-tun's flushDNSCache starts this on every TUN open and close and never waits.
const dnsCacheFlusher = "dscacheutil"

var reaping sync.Map

func init() {
	reapOnExit(dnsCacheFlusher)
}

func reapOnExit(name string) {
	exited := make(chan os.Signal, 1)
	signal.Notify(exited, syscall.SIGCHLD)
	go func() {
		for range exited {
			reapChildren(name)
		}
	}()
}

// Only for a command no exec.Cmd waits for; SIGCHLD can arrive before the zombie does.
func reapChildren(name string) {
	procs, err := unix.SysctlKinfoProcSlice("kern.proc.all")
	if err != nil {
		return
	}
	self := int32(os.Getpid())
	for _, proc := range procs {
		if proc.Eproc.Ppid != self || unix.ByteSliceToString(proc.Proc.P_comm[:]) != name {
			continue
		}
		pid := int(proc.Proc.P_pid)
		if _, waiting := reaping.LoadOrStore(pid, struct{}{}); waiting {
			continue
		}
		go func() {
			defer reaping.Delete(pid)
			for {
				if _, err := unix.Wait4(pid, nil, 0, nil); err != unix.EINTR {
					return
				}
			}
		}()
	}
}
