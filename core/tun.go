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
	"strconv"
	"sync"
	"syscall"
	"time"
)

var tunLock sync.Mutex
var tun *t.Tun
var runTime *time.Time

//export startTUN
func startTUN(fd C.int) {
	tunLock.Lock()

	now := time.Now()
	runTime = &now

	go func() {
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

		applyConfig(true)
	}()
}

//export getRunTime
func getRunTime() *C.char {
	if runTime == nil {
		return C.CString("")
	}
	return C.CString(strconv.FormatInt(runTime.UnixMilli(), 10))
}

//export stopTun
func stopTun() {
	tunLock.Lock()

	runTime = nil

	go func() {
		defer tunLock.Unlock()

		if tun != nil {
			tun.Close()
			tun = nil
		}
	}()
}

func init() {
	dialer.DefaultSocketHook = func(network, address string, conn syscall.RawConn) error {
		if platform.ShouldBlockConnection() {
			return errors.New("blocked")
		}
		return conn.Control(func(fd uintptr) {
			if tun != nil {
				tun.MarkSocket(int(fd))
				time.Sleep(time.Millisecond * 100)
			}
		})
	}
}
