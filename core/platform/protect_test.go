//go:build android

package platform

import (
	"net"
	"os"
	"syscall"
	"testing"
)

func TestProtectExistingSocketsAcrossRepeatedVpnStarts(t *testing.T) {
	first, err := net.ListenPacket("udp4", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	defer first.Close()
	firstPort := first.LocalAddr().(*net.UDPAddr).Port
	seen := make(map[int]int)
	protect := func(fd int) bool {
		address, err := syscall.Getsockname(fd)
		if err != nil {
			t.Fatal(err)
		}
		if address, ok := address.(*syscall.SockaddrInet4); ok {
			seen[address.Port]++
		}
		return true
	}
	ProtectExistingSockets(protect)
	second, err := net.ListenPacket("udp4", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	defer second.Close()
	secondPort := second.LocalAddr().(*net.UDPAddr).Port
	ProtectExistingSockets(protect)
	if seen[firstPort] != 2 || seen[secondPort] != 1 {
		t.Fatalf("existing sockets were not protected on each start: first=%d second=%d", seen[firstPort], seen[secondPort])
	}
	if _, err := second.WriteTo([]byte("still-open"), first.LocalAddr()); err != nil {
		t.Fatalf("protecting a duplicated descriptor closed the original socket: %v", err)
	}
}

func TestProtectSocketSkipsFilesAndPipes(t *testing.T) {
	reader, writer, err := os.Pipe()
	if err != nil {
		t.Fatal(err)
	}
	defer reader.Close()
	defer writer.Close()
	file, err := os.CreateTemp(t.TempDir(), "regular")
	if err != nil {
		t.Fatal(err)
	}
	defer file.Close()
	for _, fd := range []int{int(reader.Fd()), int(file.Fd()), -1} {
		protectSocket(fd, func(int) bool {
			t.Fatalf("non-network descriptor %d was passed to VPN protection", fd)
			return false
		})
	}
}
