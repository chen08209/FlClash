//go:build android

package platform

import (
	"os"
	"strconv"
	"syscall"
)

// ProtectExistingSockets keeps pre-VPN client pools outside the new tunnel.
func ProtectExistingSockets(protect func(int) bool) {
	entries, err := os.ReadDir("/proc/self/fd")
	if err != nil {
		return
	}
	for _, entry := range entries {
		fd, err := strconv.Atoi(entry.Name())
		if err != nil {
			continue
		}
		protectSocket(fd, protect)
	}
}

func protectSocket(fd int, protect func(int) bool) {
	duplicate, err := syscall.Dup(fd)
	if err != nil {
		return
	}
	defer syscall.Close(duplicate)
	address, err := syscall.Getsockname(duplicate)
	if err != nil {
		return
	}
	switch address.(type) {
	case *syscall.SockaddrInet4, *syscall.SockaddrInet6:
		protect(duplicate)
	}
}
