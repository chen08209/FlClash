//go:build !windows

package core

import "syscall"

var (
	timeoutErrnos     = []syscall.Errno{syscall.ETIMEDOUT}
	refusedErrnos     = []syscall.Errno{syscall.ECONNREFUSED}
	unreachableErrnos = []syscall.Errno{syscall.EHOSTUNREACH, syscall.ENETUNREACH, syscall.ENETDOWN, syscall.EADDRNOTAVAIL}
	handshakeErrnos   = []syscall.Errno{syscall.ECONNRESET, syscall.ECONNABORTED, syscall.EPIPE, syscall.ENOTCONN, syscall.EACCES, syscall.EPERM}
)
