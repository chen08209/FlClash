//go:build windows

package core

import (
	"net"

	"github.com/Microsoft/go-winio"
)

func dial(path string) (net.Conn, error) {
	return winio.DialPipe(path, nil)
}
