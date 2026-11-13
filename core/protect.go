package core

import (
	"sync"
	"syscall"
)

// Android routes every socket of this app into the VPN once it is established, sockets opened
// before then included, and protect succeeds only while it is. A socket opened while it is not
// waits for the next activation: a WireGuard bind left out loops back through the core's own TUN.
type socketProtector struct {
	mu      sync.Mutex
	protect func(fd int) bool
	pending []syscall.RawConn
	limit   int
}

const minPendingSockets = 64

func newSocketProtector() *socketProtector {
	return &socketProtector{limit: minPendingSockets}
}

type protectResult int

const (
	socketProtected protectResult = iota
	socketRefused
	socketClosed
)

func protectSocket(conn syscall.RawConn, protect func(fd int) bool) protectResult {
	protected := false
	if err := conn.Control(func(fd uintptr) {
		protected = protect(int(fd))
	}); err != nil {
		return socketClosed
	}
	if protected {
		return socketProtected
	}
	return socketRefused
}

func (p *socketProtector) guard(conn syscall.RawConn) {
	p.mu.Lock()
	protect := p.protect
	if protect == nil {
		p.holdLocked(conn)
		p.mu.Unlock()
		return
	}
	p.mu.Unlock()
	if protectSocket(conn, protect) != socketRefused {
		return
	}
	// Refused: the VPN went away during the call, and may already be back.
	p.mu.Lock()
	defer p.mu.Unlock()
	if p.protect == nil || protectSocket(conn, p.protect) == socketRefused {
		p.holdLocked(conn)
	}
}

func (p *socketProtector) holdLocked(conn syscall.RawConn) {
	if len(p.pending) >= p.limit {
		live := p.pending[:0]
		for _, held := range p.pending {
			if held.Control(func(uintptr) {}) == nil {
				live = append(live, held)
			}
		}
		clear(p.pending[len(live):])
		p.pending = live
		p.limit = max(minPendingSockets, 2*len(live))
	}
	p.pending = append(p.pending, conn)
}

func (p *socketProtector) activate(protect func(fd int) bool) {
	p.mu.Lock()
	p.protect = protect
	pending := p.pending
	p.pending = nil
	p.limit = minPendingSockets
	p.mu.Unlock()
	for _, conn := range pending {
		p.guard(conn)
	}
}

func (p *socketProtector) deactivate() {
	p.mu.Lock()
	p.protect = nil
	p.mu.Unlock()
}
