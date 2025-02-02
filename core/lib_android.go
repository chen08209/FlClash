//go:build android && cgo

package main

import "C"
import (
	bridge "core/dart-bridge"
	"core/platform"
	"core/state"
	t "core/tun"
	"encoding/json"
	"errors"
	"fmt"
	"github.com/metacubex/mihomo/common/utils"
	"github.com/metacubex/mihomo/component/dialer"
	"github.com/metacubex/mihomo/component/process"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/dns"
	"github.com/metacubex/mihomo/listener/sing_tun"
	"github.com/metacubex/mihomo/log"
	"strconv"
	"strings"
	"sync"
	"syscall"
	"time"
)

type Fd struct {
	Id    string `json:"id"`
	Value int64  `json:"value"`
}

type Process struct {
	Id       string             `json:"id"`
	Metadata *constant.Metadata `json:"metadata"`
}

type ProcessMapItem struct {
	Id    string `json:"id"`
	Value string `json:"value"`
}

type InvokeManager struct {
	invokeMap sync.Map
	chanMap   map[string]chan struct{}
	chanLock  sync.Mutex
}

func NewInvokeManager() *InvokeManager {
	return &InvokeManager{
		chanMap: make(map[string]chan struct{}),
	}
}

func (m *InvokeManager) load(id string) string {
	res, ok := m.invokeMap.Load(id)
	if ok {
		return res.(string)
	}
	return ""
}

func (m *InvokeManager) delete(id string) {
	m.invokeMap.Delete(id)
}

func (m *InvokeManager) completer(id string, value string) {
	m.invokeMap.Store(id, value)
	m.chanLock.Lock()
	if ch, ok := m.chanMap[id]; ok {
		close(ch)
		delete(m.chanMap, id)
	}
	m.chanLock.Unlock()
}

func (m *InvokeManager) await(id string) {
	m.chanLock.Lock()
	if _, ok := m.chanMap[id]; !ok {
		m.chanMap[id] = make(chan struct{})
	}
	ch := m.chanMap[id]
	m.chanLock.Unlock()

	timeout := time.After(500 * time.Millisecond)
	select {
	case <-ch:
		return
	case <-timeout:
		m.completer(id, "")
		return
	}

}

var (
	invokePort       int64 = -1
	tunListener      *sing_tun.Listener
	fdInvokeMap      = NewInvokeManager()
	processInvokeMap = NewInvokeManager()
	tunLock          sync.Mutex
	runTime          *time.Time
	errBlocked       = errors.New("blocked")
)

func handleStartTun(fd int) string {
	handleStopTun()
	tunLock.Lock()
	defer tunLock.Unlock()
	if fd == 0 {
		now := time.Now()
		runTime = &now
	} else {
		initSocketHook()
		tunListener, _ = t.Start(fd, currentConfig.General.Tun.Device, currentConfig.General.Tun.Stack)
		if tunListener != nil {
			log.Infoln("TUN address: %v", tunListener.Address())
		}
		now := time.Now()
		runTime = &now
	}
	return handleGetRunTime()
}

func handleStopTun() {
	tunLock.Lock()
	defer tunLock.Unlock()
	removeSocketHook()
	runTime = nil
	if tunListener != nil {
		log.Infoln("TUN close")
		_ = tunListener.Close()
	}
}

func handleGetRunTime() string {
	if runTime == nil {
		return ""
	}
	return strconv.FormatInt(runTime.UnixMilli(), 10)
}

func handleSetProcessMap(params string) {
	var processMapItem = &ProcessMapItem{}
	err := json.Unmarshal([]byte(params), processMapItem)
	if err == nil {
		processInvokeMap.completer(processMapItem.Id, processMapItem.Value)
	}
}

//export attachInvokePort
func attachInvokePort(mPort C.longlong) {
	invokePort = int64(mPort)
}

func sendInvokeMessage(message InvokeMessage) {
	if invokePort == -1 {
		return
	}
	bridge.SendToPort(invokePort, message.Json())
}

func handleMarkSocket(fd Fd) {
	sendInvokeMessage(InvokeMessage{
		Type: ProtectInvoke,
		Data: fd,
	})
}

func handleParseProcess(process Process) {
	sendInvokeMessage(InvokeMessage{
		Type: ProcessInvoke,
		Data: process,
	})
}

func handleSetFdMap(id string) {
	go func() {
		fdInvokeMap.completer(id, "")
	}()
}

func initSocketHook() {
	dialer.DefaultSocketHook = func(network, address string, conn syscall.RawConn) error {
		if platform.ShouldBlockConnection() {
			return errBlocked
		}
		return conn.Control(func(fd uintptr) {
			fdInt := int64(fd)
			id := utils.NewUUIDV1().String()

			handleMarkSocket(Fd{
				Id:    id,
				Value: fdInt,
			})

			fdInvokeMap.await(id)
			fdInvokeMap.delete(id)
		})
	}
}

func removeSocketHook() {
	dialer.DefaultSocketHook = nil
}

func init() {
	process.DefaultPackageNameResolver = func(metadata *constant.Metadata) (string, error) {
		if metadata == nil {
			return "", process.ErrInvalidNetwork
		}
		id := utils.NewUUIDV1().String()
		handleParseProcess(Process{
			Id:       id,
			Metadata: metadata,
		})
		processInvokeMap.await(id)
		res := processInvokeMap.load(id)
		processInvokeMap.delete(id)
		return res, nil
	}
}

func handleGetAndroidVpnOptions() string {
	tunLock.Lock()
	defer tunLock.Unlock()
	options := state.AndroidVpnOptions{
		Enable:           state.CurrentState.Enable,
		Port:             currentConfig.General.MixedPort,
		Ipv4Address:      state.DefaultIpv4Address,
		Ipv6Address:      state.GetIpv6Address(),
		AccessControl:    state.CurrentState.AccessControl,
		SystemProxy:      state.CurrentState.SystemProxy,
		AllowBypass:      state.CurrentState.AllowBypass,
		RouteAddress:     state.CurrentState.RouteAddress,
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

func handleSetState(params string) {
	_ = json.Unmarshal([]byte(params), state.CurrentState)
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

func nextHandle(action *Action, send func([]byte)) bool {
	switch action.Method {
	case startTunMethod:
		data := action.Data.(string)
		var fd int
		_ = json.Unmarshal([]byte(data), &fd)
		send(action.wrapMessage(handleStartTun(fd)))
		return true
	case stopTunMethod:
		handleStopTun()
		send(action.wrapMessage(true))
		return true
	case setStateMethod:
		data := action.Data.(string)
		handleSetState(data)
		send(action.wrapMessage(true))
		return true
	case getAndroidVpnOptionsMethod:
		send(action.wrapMessage(handleGetAndroidVpnOptions()))
		return true
	case updateDnsMethod:
		data := action.Data.(string)
		handleUpdateDns(data)
		send(action.wrapMessage(true))
		return true
	case setFdMapMethod:
		fdId := action.Data.(string)
		handleSetFdMap(fdId)
		send(action.wrapMessage(true))
		return true
	case setProcessMapMethod:
		data := action.Data.(string)
		handleSetProcessMap(data)
		send(action.wrapMessage(true))
		return true
	case getRunTimeMethod:
		send(action.wrapMessage(handleGetRunTime()))
		return true
	case getCurrentProfileNameMethod:
		send(action.wrapMessage(handleGetCurrentProfileName()))
		return true
	}
	return false
}

//export quickStart
func quickStart(dirChar *C.char, paramsChar *C.char, stateParamsChar *C.char, port C.longlong) {
	i := int64(port)
	dir := C.GoString(dirChar)
	bytes := []byte(C.GoString(paramsChar))
	stateParams := C.GoString(stateParamsChar)
	go func() {
		res := handleInitClash(dir)
		if res == false {
			bridge.SendToPort(i, "init error")
		}
		handleSetState(stateParams)
		bridge.SendToPort(i, handleUpdateConfig(bytes))
	}()
}

//export startTUN
func startTUN(fd C.int) *C.char {
	f := int(fd)
	return C.CString(handleStartTun(f))
}

//export getRunTime
func getRunTime() *C.char {
	return C.CString(handleGetRunTime())
}

//export stopTun
func stopTun() {
	handleStopTun()
}

//export setFdMap
func setFdMap(fdIdChar *C.char) {
	fdId := C.GoString(fdIdChar)
	handleSetFdMap(fdId)
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

//export setProcessMap
func setProcessMap(s *C.char) {
	if s == nil {
		return
	}
	paramsString := C.GoString(s)
	handleSetProcessMap(paramsString)
}
