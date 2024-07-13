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
	"sync/atomic"
	"syscall"
	"time"
)

var tunLock sync.Mutex
var tun *t.Tun
var runTime *time.Time

type FdMap struct {
	m sync.Map
}

func (cm *FdMap) Store(key int64) {
	cm.m.Store(key, struct{}{})
}

func (cm *FdMap) Load(key int64) bool {
	_, ok := cm.m.Load(key)
	return ok
}

var fdMap FdMap

//export startTUN
func startTUN(fd C.int, port C.longlong) {
	i := int64(port)
	ServicePort = i
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

		now := time.Now()

		runTime = &now

		SendMessage(Message{
			Type: StartedMessage,
			Data: strconv.FormatInt(runTime.UnixMilli(), 10),
		})
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
	go func() {
		tunLock.Lock()
		defer tunLock.Unlock()

		runTime = nil

		if tun != nil {
			tun.Close()
			tun = nil
		}
	}()
}

var errBlocked = errors.New("blocked")

//export setFdMap
func setFdMap(fd C.long) {
	fdInt := int64(fd)
	go func() {
		fdMap.Store(fdInt)
	}()
}

type Fd struct {
	Id    int64 `json:"id"`
	Value int64 `json:"value"`
}

func markSocket(fd Fd) {
	SendMessage(Message{
		Type: ProtectMessage,
		Data: fd,
	})
}

var fdCounter int64 = 0

func init() {
	dialer.DefaultSocketHook = func(network, address string, conn syscall.RawConn) error {
		if platform.ShouldBlockConnection() {
			return errBlocked
		}
		return conn.Control(func(fd uintptr) {
			if tun == nil {
				return
			}

			fdInt := int64(fd)
			timeout := time.After(100 * time.Millisecond)
			id := atomic.AddInt64(&fdCounter, 1)

			markSocket(Fd{
				Id:    id,
				Value: fdInt,
			})

			for {
				select {
				case <-timeout:
					return
				default:
					exists := fdMap.Load(id)
					if exists {
						return
					}
					time.Sleep(10 * time.Millisecond)
				}
			}
		})
	}
}
