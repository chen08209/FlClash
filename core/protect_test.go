package core

import (
	"net"
	"sync"
	"syscall"
	"testing"
)

type protectLog struct {
	mu     sync.Mutex
	fds    []int
	refuse bool
}

func (l *protectLog) protect(fd int) bool {
	l.mu.Lock()
	defer l.mu.Unlock()
	l.fds = append(l.fds, fd)
	return !l.refuse
}

func (l *protectLog) seen() []int {
	l.mu.Lock()
	defer l.mu.Unlock()
	return append([]int(nil), l.fds...)
}

func udpSocket(t *testing.T) (*net.UDPConn, syscall.RawConn, int) {
	t.Helper()
	conn, err := net.ListenUDP("udp4", &net.UDPAddr{IP: net.IPv4(127, 0, 0, 1)})
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { _ = conn.Close() })
	raw, err := conn.SyscallConn()
	if err != nil {
		t.Fatal(err)
	}
	fd := -1
	if err := raw.Control(func(f uintptr) { fd = int(f) }); err != nil {
		t.Fatal(err)
	}
	return conn, raw, fd
}

func TestSocketProtectorProtectsWhileActive(t *testing.T) {
	p := newSocketProtector()
	log := &protectLog{}
	p.activate(log.protect)
	_, raw, fd := udpSocket(t)

	p.guard(raw)

	if got := log.seen(); len(got) != 1 || got[0] != fd {
		t.Fatalf("protected %v, want [%d]", got, fd)
	}
	if len(p.pending) != 0 {
		t.Fatalf("held %d sockets while active", len(p.pending))
	}
}

func TestSocketProtectorProtectsEarlierSocketsOnActivation(t *testing.T) {
	p := newSocketProtector()
	_, live, liveFd := udpSocket(t)
	closed, gone, _ := udpSocket(t)
	p.guard(live)
	p.guard(gone)
	_ = closed.Close()

	log := &protectLog{}
	p.activate(log.protect)

	if got := log.seen(); len(got) != 1 || got[0] != liveFd {
		t.Fatalf("protected %v, want only the live socket %d", got, liveFd)
	}
}

func TestSocketProtectorHoldsRefusedSocketsForTheNextVpn(t *testing.T) {
	p := newSocketProtector()
	revoked := &protectLog{refuse: true}
	p.activate(revoked.protect)
	_, raw, fd := udpSocket(t)
	p.guard(raw)
	p.deactivate()

	next := &protectLog{}
	p.activate(next.protect)

	if got := next.seen(); len(got) != 1 || got[0] != fd {
		t.Fatalf("next VPN protected %v, want [%d]", got, fd)
	}
}

func TestSocketProtectorDropsClosedSocketsItHolds(t *testing.T) {
	p := newSocketProtector()
	for range 3 * minPendingSockets {
		conn, raw, _ := udpSocket(t)
		p.guard(raw)
		_ = conn.Close()
	}
	if len(p.pending) > minPendingSockets {
		t.Fatalf("held %d closed sockets, want at most %d", len(p.pending), minPendingSockets)
	}
}

func TestSocketProtectorRacesActivation(t *testing.T) {
	p := newSocketProtector()
	log := &protectLog{}
	var wg sync.WaitGroup
	fds := make(chan int, 32)
	for range cap(fds) {
		_, raw, fd := udpSocket(t)
		fds <- fd
		wg.Go(func() { p.guard(raw) })
	}
	p.activate(log.protect)
	wg.Wait()
	close(fds)

	seen := map[int]bool{}
	for _, fd := range log.seen() {
		seen[fd] = true
	}
	for fd := range fds {
		if !seen[fd] {
			t.Fatalf("socket %d opened around activation was never protected", fd)
		}
	}
}
