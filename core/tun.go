//go:build android

package main

import "C"
import (
	"core/platform"
	t "core/tun"
	"encoding/json"
	"errors"
	"github.com/metacubex/mihomo/listener/sing_tun"
	"strconv"
	"sync"
	"sync/atomic"
	"syscall"
	"time"

	"github.com/metacubex/mihomo/component/dialer"
	"github.com/metacubex/mihomo/log"
)

var tunLock sync.Mutex
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

var (
	tunListener *sing_tun.Listener
	fdMap       FdMap
	fdCounter   int64 = 0
)

//export startTUN
func startTUN(s *C.char, port C.longlong) {
	i := int64(port)
	ServicePort = i
	paramsString := C.GoString(s)
	if paramsString == "" {
		tunLock.Lock()
		defer tunLock.Unlock()
		now := time.Now()
		runTime = &now
		SendMessage(Message{
			Type: StartedMessage,
			Data: strconv.FormatInt(runTime.UnixMilli(), 10),
		})
		return
	}
	initSocketHook()
	go func() {
		tunLock.Lock()
		defer tunLock.Unlock()

		var tunProps = &t.Props{}
		err := json.Unmarshal([]byte(paramsString), tunProps)
		if err != nil {
			log.Errorln("startTUN error: %v", err)
			return
		}

		tunListener, err = t.Start(*tunProps)

		if err != nil {
			return
		}

		if tunListener != nil {
			log.Infoln("TUN address: %v", tunListener.Address())
		}

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
	removeSocketHook()
	go func() {
		tunLock.Lock()
		defer tunLock.Unlock()

		runTime = nil

		if tunListener != nil {
			_ = tunListener.Close()
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

func initSocketHook() {
	dialer.DefaultSocketHook = func(network, address string, conn syscall.RawConn) error {
		if platform.ShouldBlockConnection() {
			return errBlocked
		}
		return conn.Control(func(fd uintptr) {
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

func removeSocketHook() {
	dialer.DefaultSocketHook = nil
}
