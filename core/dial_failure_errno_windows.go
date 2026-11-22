package core

import "syscall"

// A dial reports Winsock codes, and ConnectEx the system ones; syscall names
// neither, and its ECONNREFUSED family never matches them.
var (
	timeoutErrnos     = []syscall.Errno{10060, 121}
	refusedErrnos     = []syscall.Errno{10061, 1225}
	unreachableErrnos = []syscall.Errno{10065, 10051, 10050, 10049, 1231, 1232}
	handshakeErrnos   = []syscall.Errno{10054, 10053, 10057, 10013, 1236, 64}
)
