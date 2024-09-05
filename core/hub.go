package main

/*
#include <stdlib.h>
*/
import "C"
import (
	"context"
	bridge "core/dart-bridge"
	"encoding/json"
	"fmt"
	"github.com/metacubex/mihomo/common/utils"
	"os"
	"runtime"
	"sort"
	"sync"
	"time"
	"unsafe"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/outboundgroup"
	"github.com/metacubex/mihomo/adapter/provider"
	"github.com/metacubex/mihomo/component/updater"
	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/constant"
	cp "github.com/metacubex/mihomo/constant/provider"
	"github.com/metacubex/mihomo/hub/executor"
	"github.com/metacubex/mihomo/log"
	"github.com/metacubex/mihomo/tunnel"
	"github.com/metacubex/mihomo/tunnel/statistic"
)

var currentRawConfig = config.DefaultRawConfig()

var configParams = ConfigExtendedParams{}

var externalProviders = map[string]cp.Provider{}

var isInit = false

//export start
func start() {
	runLock.Lock()
	defer runLock.Unlock()
	isRunning = true
}

//export stop
func stop() {
	runLock.Lock()
	go func() {
		defer runLock.Unlock()
		isRunning = false
		stopListeners()
	}()
}

//export initClash
func initClash(homeDirStr *C.char) bool {
	if !isInit {
		constant.SetHomeDir(C.GoString(homeDirStr))
		isInit = true
	}
	return isInit
}

//export getIsInit
func getIsInit() bool {
	return isInit
}

//export restartClash
func restartClash() bool {
	execPath, _ := os.Executable()
	go restartExecutable(execPath)
	return true
}

//export shutdownClash
func shutdownClash() bool {
	stopListeners()
	executor.Shutdown()
	runtime.GC()
	isInit = false
	return true
}

//export forceGc
func forceGc() {
	go func() {
		log.Infoln("[APP] request force GC")
		runtime.GC()
	}()
}

//export validateConfig
func validateConfig(s *C.char, port C.longlong) {
	i := int64(port)
	bytes := []byte(C.GoString(s))
	go func() {
		_, err := config.UnmarshalRawConfig(bytes)
		if err != nil {
			bridge.SendToPort(i, err.Error())
			return
		}
		bridge.SendToPort(i, "")
	}()
}

var updateLock sync.Mutex

//export updateConfig
func updateConfig(s *C.char, port C.longlong) {
	i := int64(port)
	paramsString := C.GoString(s)
	go func() {
		updateLock.Lock()
		defer updateLock.Unlock()
		var params = &GenerateConfigParams{}
		err := json.Unmarshal([]byte(paramsString), params)
		if err != nil {
			bridge.SendToPort(i, err.Error())
			return
		}
		configParams = params.Params
		prof := decorationConfig(params.ProfileId, params.Config)
		currentRawConfig = prof
		err = applyConfig()
		if err != nil {
			bridge.SendToPort(i, err.Error())
			return
		}
		bridge.SendToPort(i, "")
	}()
}

//export clearEffect
func clearEffect(s *C.char) {
	id := C.GoString(s)
	go func() {
		_ = removeFile(getProfilePath(id))
		_ = removeFile(getProfileProvidersPath(id))
	}()
}

//export getProxies
func getProxies() *C.char {
	data, err := json.Marshal(tunnel.ProxiesWithProviders())
	if err != nil {
		return C.CString("")
	}
	return C.CString(string(data))
}

//export changeProxy
func changeProxy(s *C.char) {
	paramsString := C.GoString(s)
	var params = &ChangeProxyParams{}
	err := json.Unmarshal([]byte(paramsString), params)
	if err != nil {
		log.Infoln("Unmarshal ChangeProxyParams %v", err)
	}
	groupName := *params.GroupName
	proxyName := *params.ProxyName
	proxies := tunnel.ProxiesWithProviders()
	group, ok := proxies[groupName]
	if !ok {
		return
	}
	adapterProxy := group.(*adapter.Proxy)
	selector, ok := adapterProxy.ProxyAdapter.(outboundgroup.SelectAble)
	if !ok {
		return
	}
	if proxyName == "" {
		selector.ForceSet(proxyName)
	} else {
		err = selector.Set(proxyName)
	}
	if err == nil {
		log.Infoln("[SelectAble] %s selected %s", groupName, proxyName)
	}
}

//export getTraffic
func getTraffic() *C.char {
	up, down := statistic.DefaultManager.Current(state.OnlyProxy)
	traffic := map[string]int64{
		"up":   up,
		"down": down,
	}
	data, err := json.Marshal(traffic)
	if err != nil {
		fmt.Println("Error:", err)
		return C.CString("")
	}
	return C.CString(string(data))
}

//export getTotalTraffic
func getTotalTraffic() *C.char {
	up, down := statistic.DefaultManager.Total(state.OnlyProxy)
	traffic := map[string]int64{
		"up":   up,
		"down": down,
	}
	data, err := json.Marshal(traffic)
	if err != nil {
		fmt.Println("Error:", err)
		return C.CString("")
	}
	return C.CString(string(data))
}

//export resetTraffic
func resetTraffic() {
	statistic.DefaultManager.ResetStatistic()
}

//export asyncTestDelay
func asyncTestDelay(s *C.char, port C.longlong) {
	i := int64(port)
	paramsString := C.GoString(s)
	b.Go(paramsString, func() (bool, error) {
		var params = &TestDelayParams{}
		err := json.Unmarshal([]byte(paramsString), params)
		if err != nil {
			bridge.SendToPort(i, "")
			return false, nil
		}

		expectedStatus, err := utils.NewUnsignedRanges[uint16]("")
		if err != nil {
			bridge.SendToPort(i, "")
			return false, nil
		}

		ctx, cancel := context.WithTimeout(context.Background(), time.Millisecond*time.Duration(params.Timeout))
		defer cancel()

		proxies := tunnel.ProxiesWithProviders()
		proxy := proxies[params.ProxyName]

		delayData := &Delay{
			Name: params.ProxyName,
		}

		if proxy == nil {
			delayData.Value = -1
			data, _ := json.Marshal(delayData)
			bridge.SendToPort(i, string(data))
			return false, nil
		}

		delay, err := proxy.URLTest(ctx, constant.DefaultTestURL, expectedStatus)
		if err != nil || delay == 0 {
			delayData.Value = -1
			data, _ := json.Marshal(delayData)
			bridge.SendToPort(i, string(data))
			return false, nil
		}

		delayData.Value = int32(delay)
		data, _ := json.Marshal(delayData)
		bridge.SendToPort(i, string(data))
		return false, nil
	})
}

//export getVersionInfo
func getVersionInfo() *C.char {
	versionInfo := map[string]string{
		"clashName": constant.Name,
		"version":   "1.18.5",
	}
	data, err := json.Marshal(versionInfo)
	if err != nil {
		fmt.Println("Error:", err)
		return C.CString("")
	}
	return C.CString(string(data))
}

//export getConnections
func getConnections() *C.char {
	snapshot := statistic.DefaultManager.Snapshot()
	data, err := json.Marshal(snapshot)
	if err != nil {
		fmt.Println("Error:", err)
		return C.CString("")
	}
	return C.CString(string(data))
}

//export closeConnections
func closeConnections() {
	statistic.DefaultManager.Range(func(c statistic.Tracker) bool {
		err := c.Close()
		if err != nil {
			return false
		}
		return true
	})
}

//export closeConnection
func closeConnection(id *C.char) {
	connectionId := C.GoString(id)
	c := statistic.DefaultManager.Get(connectionId)
	if c == nil {
		return
	}
	_ = c.Close()
}

//export getProviders
func getProviders() *C.char {
	data, err := json.Marshal(tunnel.Providers())
	var msg *C.char
	if err != nil {
		msg = C.CString("")
		return msg
	}
	msg = C.CString(string(data))
	return msg
}

//export getProvider
func getProvider(name *C.char) *C.char {
	providerName := C.GoString(name)
	providers := tunnel.Providers()
	data, err := json.Marshal(providers[providerName])
	if err != nil {
		return C.CString("")
	}
	return C.CString(string(data))
}

//export getExternalProviders
func getExternalProviders() *C.char {
	eps := make([]ExternalProvider, 0)
	for _, p := range externalProviders {
		externalProvider, err := toExternalProvider(p)
		if err != nil {
			continue
		}
		eps = append(eps, *externalProvider)
	}
	sort.Sort(ExternalProviders(eps))
	data, err := json.Marshal(eps)
	if err != nil {
		return C.CString("")
	}
	return C.CString(string(data))
}

//export getExternalProvider
func getExternalProvider(name *C.char) *C.char {
	externalProviderName := C.GoString(name)
	externalProvider, exist := externalProviders[externalProviderName]
	if !exist {
		return C.CString("")
	}
	e, err := toExternalProvider(externalProvider)
	if err != nil {
		return C.CString("")
	}
	data, err := json.Marshal(e)
	if err != nil {
		return C.CString("")
	}
	return C.CString(string(data))
}

//export updateGeoData
func updateGeoData(geoType *C.char, geoName *C.char, port C.longlong) {
	i := int64(port)
	geoTypeString := C.GoString(geoType)
	geoNameString := C.GoString(geoName)
	go func() {
		switch geoTypeString {
		case "MMDB":
			err := updater.UpdateMMDB(constant.Path.Resolve(geoNameString))
			if err != nil {
				bridge.SendToPort(i, err.Error())
				return
			}
		case "ASN":
			err := updater.UpdateASN(constant.Path.Resolve(geoNameString))
			if err != nil {
				bridge.SendToPort(i, err.Error())
				return
			}
		case "GeoIp":
			err := updater.UpdateGeoIp(constant.Path.Resolve(geoNameString))
			if err != nil {
				bridge.SendToPort(i, err.Error())
				return
			}
		case "GeoSite":
			err := updater.UpdateGeoSite(constant.Path.Resolve(geoNameString))
			if err != nil {
				bridge.SendToPort(i, err.Error())
				return
			}
		}
		bridge.SendToPort(i, "")
	}()
}

//export updateExternalProvider
func updateExternalProvider(providerName *C.char, port C.longlong) {
	i := int64(port)
	providerNameString := C.GoString(providerName)
	go func() {
		externalProvider, exist := externalProviders[providerNameString]
		if !exist {
			bridge.SendToPort(i, "external provider is not exist")
			return
		}
		err := externalProvider.Update()
		if err != nil {
			bridge.SendToPort(i, err.Error())
			return
		}
		bridge.SendToPort(i, "")
	}()
}

//export sideLoadExternalProvider
func sideLoadExternalProvider(providerName *C.char, data *C.char, port C.longlong) {
	i := int64(port)
	bytes := []byte(C.GoString(data))
	providerNameString := C.GoString(providerName)
	go func() {
		externalProvider, exist := externalProviders[providerNameString]
		if !exist {
			bridge.SendToPort(i, "external provider is not exist")
			return
		}
		err := sideUpdateExternalProvider(externalProvider, bytes)
		if err != nil {
			bridge.SendToPort(i, err.Error())
			return
		}
		bridge.SendToPort(i, "")
	}()
}

//export initNativeApiBridge
func initNativeApiBridge(api unsafe.Pointer) {
	bridge.InitDartApi(api)
}

//export initMessage
func initMessage(port C.longlong) {
	i := int64(port)
	Port = i
}

//export freeCString
func freeCString(s *C.char) {
	C.free(unsafe.Pointer(s))
}

func init() {
	provider.HealthcheckHook = func(name string, delay uint16) {
		delayData := &Delay{
			Name: name,
		}
		if delay == 0 {
			delayData.Value = -1
		} else {
			delayData.Value = int32(delay)
		}
		SendMessage(Message{
			Type: DelayMessage,
			Data: delayData,
		})
	}
	statistic.DefaultRequestNotify = func(c statistic.Tracker) {
		SendMessage(Message{
			Type: RequestMessage,
			Data: c,
		})
	}
	executor.DefaultProviderLoadedHook = func(providerName string) {
		SendMessage(Message{
			Type: LoadedMessage,
			Data: providerName,
		})
	}
}
