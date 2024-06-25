//go:build android

package main

import "C"
import (
	"core/platform"
	t "core/tun"
	"errors"
	"github.com/metacubex/mihomo/component/dialer"
	"github.com/metacubex/mihomo/log"
	"golang.org/x/sync/semaphore"
	"sync"
	"syscall"
	"time"
)

var tunLock sync.Mutex
var tun *t.Tun

//export startTUN
func startTUN(fd C.int) {
	go func() {
		tunLock.Lock()
		defer tunLock.Unlock()

		if tun != nil {
			tun.Close()
			tun = nil
		}
		f := int(fd)
		gateway := "172.16.0.1/30"
		portal := "172.16.0.2"
		dns := "0.0.0.0"

		tempTun := &t.Tun{Closed: false, Limit: semaphore.NewWeighted(4)}

		closer, err := t.Start(f, gateway, portal, dns)

		if err != nil {
			log.Errorln("startTUN error: %v", err)
			tempTun.Close()
		}

		tempTun.Closer = closer

		tun = tempTun
	}()
}

//export stopTun
func stopTun() {
	go func() {
		tunLock.Lock()
		defer tunLock.Unlock()

		if tun != nil {
			tun.Close()
			tun = nil
		}
	}()
}

var errBlocked = errors.New("blocked")

func init() {
	dialer.DefaultSocketHook = func(network, address string, conn syscall.RawConn) error {
		if platform.ShouldBlockConnection() {
			return errBlocked
		}
		return conn.Control(func(fd uintptr) {
			if tun != nil {
				tun.MarkSocket(int(fd))
				time.Sleep(time.Millisecond * 100)
			}
		})
	}
}
