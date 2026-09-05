//go:build windows && !(android && cgo)

package main

import (
	"net"

	"github.com/Microsoft/go-winio"
)

func dial(path string) (net.Conn, error) {
	return winio.DialPipe(path, nil)
}
