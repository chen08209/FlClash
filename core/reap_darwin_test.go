package core

import (
	"errors"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"syscall"
	"testing"
	"time"

	"golang.org/x/sys/unix"
)

const reapHelperEnv = "FLCLASH_REAP_HELPER_SLEEP"

// SZOMB in <sys/proc.h>.
const zombieState = 5

func TestReapHelperProcess(t *testing.T) {
	sleep := os.Getenv(reapHelperEnv)
	if sleep == "" {
		t.Skip("runs only as a child of the reap tests")
	}
	duration, _ := time.ParseDuration(sleep)
	time.Sleep(duration)
	os.Exit(0)
}

// startNamed starts this test binary under name, which the child's process
// name is taken from, and leaves it unwaited.
func startNamed(t *testing.T, name string, sleep time.Duration) int {
	t.Helper()
	self, err := os.Executable()
	if err != nil {
		t.Fatal(err)
	}
	named := filepath.Join(t.TempDir(), name)
	if err := os.Link(self, named); err != nil {
		copyFile(t, self, named)
	}
	cmd := exec.Command(named, "-test.run=^TestReapHelperProcess$")
	cmd.Env = append(os.Environ(), reapHelperEnv+"="+sleep.String())
	if err := cmd.Start(); err != nil {
		t.Fatal(err)
	}
	return cmd.Process.Pid
}

func copyFile(t *testing.T, from, to string) {
	t.Helper()
	source, err := os.Open(from)
	if err != nil {
		t.Fatal(err)
	}
	defer source.Close()
	target, err := os.OpenFile(to, os.O_CREATE|os.O_WRONLY, 0o755)
	if err != nil {
		t.Fatal(err)
	}
	defer target.Close()
	if _, err := io.Copy(target, source); err != nil {
		t.Fatal(err)
	}
}

func gone(pid int) bool {
	return errors.Is(syscall.Kill(pid, 0), syscall.ESRCH)
}

func isZombie(t *testing.T, pid int) bool {
	t.Helper()
	proc, err := unix.SysctlKinfoProc("kern.proc.pid", pid)
	if err != nil {
		t.Fatal(err)
	}
	return proc.Proc.P_stat == zombieState
}

func eventually(t *testing.T, what string, done func() bool) {
	t.Helper()
	deadline := time.Now().Add(10 * time.Second)
	for !done() {
		if time.Now().After(deadline) {
			t.Fatal(what)
		}
		time.Sleep(10 * time.Millisecond)
	}
}

func TestReapChildrenTakesOnlyChildrenOfItsName(t *testing.T) {
	exited := startNamed(t, "reap-exited", 0)
	running := startNamed(t, "reap-running", time.Second)
	other := startNamed(t, "reap-other", 0)
	t.Cleanup(func() { _, _ = syscall.Wait4(other, nil, 0, nil) })

	eventually(t, "the children never exited", func() bool {
		return isZombie(t, exited) && isZombie(t, other)
	})
	reapChildren("reap-exited")
	reapChildren("reap-running")

	eventually(t, "the exited child stayed a zombie", func() bool { return gone(exited) })
	eventually(t, "the child running when asked stayed a zombie once it exited", func() bool { return gone(running) })
	if gone(other) {
		t.Fatal("a child of another name was reaped")
	}
}

func TestReapOnExitTakesTheChildOnceItExits(t *testing.T) {
	reapOnExit("reap-flush")
	pid := startNamed(t, "reap-flush", 0)

	eventually(t, "the exited child stayed a zombie", func() bool { return gone(pid) })
}
