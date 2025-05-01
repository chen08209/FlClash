//go:build android && cgo

package main

import "C"
import (
	"context"
	bridge "core/dart-bridge"
	"core/platform"
	"core/state"
	t "core/tun"
	"encoding/json"
	"errors"
	"fmt"
	"github.com/metacubex/mihomo/component/dialer"
	"github.com/metacubex/mihomo/component/process"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/dns"
	"github.com/metacubex/mihomo/listener/sing_tun"
	"github.com/metacubex/mihomo/log"
	"golang.org/x/sync/semaphore"
	"net"
	"strconv"
	"strings"
	"sync"
	"syscall"
	"time"
	"unsafe"
)

type TunHandler struct {
	listener *sing_tun.Listener
	callback unsafe.Pointer

	limit *semaphore.Weighted
}

func (t *TunHandler) close() {
	_ = t.limit.Acquire(context.TODO(), 4)
	defer t.limit.Release(4)
	removeTunHook()
	if t.listener != nil {
		_ = t.listener.Close()
	}

	if t.callback != nil {
		releaseObject(t.callback)
	}
	t.callback = nil
	t.listener = nil
}

func (t *TunHandler) handleProtect(fd int) {
	_ = t.limit.Acquire(context.Background(), 1)
	defer t.limit.Release(1)

	if t.listener == nil {
		return
	}

	Protect(t.callback, fd)
}

func (t *TunHandler) handleResolveProcess(source, target net.Addr) string {
	_ = t.limit.Acquire(context.Background(), 1)
	defer t.limit.Release(1)

	if t.listener == nil {
		return ""
	}
	var protocol int
	uid := -1
	switch source.Network() {
	case "udp", "udp4", "udp6":
		protocol = syscall.IPPROTO_UDP
	case "tcp", "tcp4", "tcp6":
		protocol = syscall.IPPROTO_TCP
	}
	if version < 29 {
		uid = platform.QuerySocketUidFromProcFs(source, target)
	}
	return ResolveProcess(t.callback, protocol, source.String(), target.String(), uid)
}

var (
	tunLock    sync.Mutex
	runTime    *time.Time
	errBlocked = errors.New("blocked")
	tunHandler *TunHandler
)

func handleStopTun() {
	tunLock.Lock()
	defer tunLock.Unlock()
	runTime = nil
	if tunHandler != nil {
		tunHandler.close()
	}
}

func handleStartTun(fd int, callback unsafe.Pointer) {
	handleStopTun()
	tunLock.Lock()
	defer tunLock.Unlock()
	now := time.Now()
	runTime = &now
	if fd != 0 {
		tunHandler = &TunHandler{
			callback: callback,
			limit:    semaphore.NewWeighted(4),
		}
		initTunHook()
		tunListener, _ := t.Start(fd, currentConfig.General.Tun.Device, currentConfig.General.Tun.Stack)
		if tunListener != nil {
			log.Infoln("TUN address: %v", tunListener.Address())
			tunHandler.listener = tunListener
		} else {
			removeTunHook()
		}
	}
}

func handleGetRunTime() string {
	if runTime == nil {
		return ""
	}
	return strconv.FormatInt(runTime.UnixMilli(), 10)
}

func initTunHook() {
	dialer.DefaultSocketHook = func(network, address string, conn syscall.RawConn) error {
		if platform.ShouldBlockConnection() {
			return errBlocked
		}
		return conn.Control(func(fd uintptr) {
			tunHandler.handleProtect(int(fd))
		})
	}
	process.DefaultPackageNameResolver = func(metadata *constant.Metadata) (string, error) {
		src, dst := metadata.RawSrcAddr, metadata.RawDstAddr
		if src == nil || dst == nil {
			return "", process.ErrInvalidNetwork
		}
		return tunHandler.handleResolveProcess(src, dst), nil
	}
}

func removeTunHook() {
	dialer.DefaultSocketHook = nil
	process.DefaultPackageNameResolver = nil
}

func handleGetAndroidVpnOptions() string {
	tunLock.Lock()
	defer tunLock.Unlock()
	options := state.AndroidVpnOptions{
		Enable:           state.CurrentState.VpnProps.Enable,
		Port:             currentConfig.General.MixedPort,
		Ipv4Address:      state.DefaultIpv4Address,
		Ipv6Address:      state.GetIpv6Address(),
		AccessControl:    state.CurrentState.VpnProps.AccessControl,
		SystemProxy:      state.CurrentState.VpnProps.SystemProxy,
		AllowBypass:      state.CurrentState.VpnProps.AllowBypass,
		RouteAddress:     currentConfig.General.Tun.RouteAddress,
		BypassDomain:     state.CurrentState.BypassDomain,
		DnsServerAddress: state.GetDnsServerAddress(),
	}
	data, err := json.Marshal(options)
	if err != nil {
		fmt.Println("Error:", err)
		return ""
	}
	return string(data)
}

func handleUpdateDns(value string) {
	go func() {
		log.Infoln("[DNS] updateDns %s", value)
		dns.UpdateSystemDNS(strings.Split(value, ","))
		dns.FlushCacheWithDefaultResolver()
	}()
}

func handleGetCurrentProfileName() string {
	if state.CurrentState == nil {
		return ""
	}
	return state.CurrentState.CurrentProfileName
}

func nextHandle(action *Action, result ActionResult) bool {
	switch action.Method {
	case getAndroidVpnOptionsMethod:
		result.success(handleGetAndroidVpnOptions())
		return true
	case updateDnsMethod:
		data := action.Data.(string)
		handleUpdateDns(data)
		result.success(true)
		return true
	case getRunTimeMethod:
		result.success(handleGetRunTime())
		return true
	case getCurrentProfileNameMethod:
		result.success(handleGetCurrentProfileName())
		return true
	}
	return false
}

//export quickStart
func quickStart(initParamsChar *C.char, paramsChar *C.char, stateParamsChar *C.char, port C.longlong) {
	i := int64(port)
	paramsString := C.GoString(initParamsChar)
	bytes := []byte(C.GoString(paramsChar))
	stateParams := C.GoString(stateParamsChar)
	go func() {
		res := handleInitClash(paramsString)
		if res == false {
			bridge.SendToPort(i, "init error")
		}
		handleSetState(stateParams)
		bridge.SendToPort(i, handleSetupConfig(bytes))
	}()
}

//export startTUN
func startTUN(fd C.int, callback unsafe.Pointer) bool {
	go func() {
		handleStartTun(int(fd), callback)
	}()
	return true
}

//export getRunTime
func getRunTime() *C.char {
	return C.CString(handleGetRunTime())
}

//export stopTun
func stopTun() {
	go func() {
		handleStopTun()
	}()
}

//export getCurrentProfileName
func getCurrentProfileName() *C.char {
	return C.CString(handleGetCurrentProfileName())
}

//export getAndroidVpnOptions
func getAndroidVpnOptions() *C.char {
	return C.CString(handleGetAndroidVpnOptions())
}

//export setState
func setState(s *C.char) {
	paramsString := C.GoString(s)
	handleSetState(paramsString)
}

//export updateDns
func updateDns(s *C.char) {
	dnsList := C.GoString(s)
	handleUpdateDns(dnsList)
}
