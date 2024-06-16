//go:build android

package main

import "C"
import (
	t "core/tun"
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

		applyConfig(true)

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
			applyConfig(true)
			tun = nil
		}
	}()
}

func init() {
	dialer.DefaultSocketHook = func(network, address string, conn syscall.RawConn) error {
		return conn.Control(func(fd uintptr) {
			if tun != nil {
				tun.MarkSocket(int(fd))
				time.Sleep(time.Millisecond * 100)
			}
		})
	}
}
