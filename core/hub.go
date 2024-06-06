package main

import "C"
import (
	bridge "core/dart-bridge"
	"encoding/json"
	"fmt"
	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/outboundgroup"
	"github.com/metacubex/mihomo/adapter/provider"
	"github.com/metacubex/mihomo/common/structure"
	"github.com/metacubex/mihomo/common/utils"
	"github.com/metacubex/mihomo/component/mmdb"
	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/constant"
	cp "github.com/metacubex/mihomo/constant/provider"
	"github.com/metacubex/mihomo/hub/executor"
	"github.com/metacubex/mihomo/log"
	rp "github.com/metacubex/mihomo/rules/provider"
	"github.com/metacubex/mihomo/tunnel"
	"github.com/metacubex/mihomo/tunnel/statistic"
	"golang.org/x/net/context"
	"os"
	"runtime"
	"time"
	"unsafe"
)

var currentConfig = config.DefaultRawConfig()

var isInit = false

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
	executor.Shutdown()
	runtime.GC()
	isInit = false
	currentConfig = nil
	return true
}

//export validateConfig
func validateConfig(s *C.char, port C.longlong) {
	i := int64(port)
	go func() {
		bytes := []byte(C.GoString(s))
		_, err := config.UnmarshalRawConfig(bytes)
		if err != nil {
			bridge.SendToPort(i, err.Error())
			return
		}
		bridge.SendToPort(i, "")
	}()
}

//export updateConfig
func updateConfig(s *C.char, port C.longlong) {
	i := int64(port)
	go func() {
		paramsString := C.GoString(s)
		var params = &GenerateConfigParams{}
		err := json.Unmarshal([]byte(paramsString), params)
		if err != nil {
			bridge.SendToPort(i, err.Error())
			return
		}
		prof := decorationConfig(params.ProfilePath, *params.Config, *params.IsCompatible)
		currentConfig = prof
		if *params.IsPatch {
			applyConfig(true)
		} else {
			applyConfig(false)
		}
		bridge.SendToPort(i, "")
	}()
}

//export clearEffect
func clearEffect(s *C.char) {
	path := C.GoString(s)
	go func() {
		rawCfg := getRawConfigWithPath(&path)
		for _, mapping := range rawCfg.RuleProvider {
			schema := &ruleProviderSchema{}
			decoder := structure.NewDecoder(structure.Option{TagName: "provider", WeaklyTypedInput: true})
			if err := decoder.Decode(mapping, schema); err != nil {
				return
			}
			if schema.Type == "http" {
				_ = removeFile(constant.Path.Resolve(schema.Path))
			}
		}
		for _, mapping := range rawCfg.ProxyProvider {
			schema := &proxyProviderSchema{
				HealthCheck: healthCheckSchema{
					Lazy: true,
				},
			}
			decoder := structure.NewDecoder(structure.Option{TagName: "provider", WeaklyTypedInput: true})
			if err := decoder.Decode(mapping, schema); err != nil {
				return
			}
			if schema.Type == "http" {
				_ = removeFile(constant.Path.Resolve(schema.Path))
			}
		}
		_ = removeFile(path)
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
func changeProxy(s *C.char) bool {
	go func() {
		paramsString := C.GoString(s)
		var params = &ChangeProxyParams{}
		err := json.Unmarshal([]byte(paramsString), params)
		if err != nil {
			log.Infoln("Unmarshal ChangeProxyParams %v", err)
		}
		proxies := tunnel.ProxiesWithProviders()
		proxy := proxies[*params.GroupName]
		if proxy == nil {
			return
		}
		log.Infoln("change proxy %s", proxy.Name())
		adapterProxy := proxy.(*adapter.Proxy)
		selector, ok := adapterProxy.ProxyAdapter.(*outboundgroup.Selector)
		if !ok {
			return
		}
		if err := selector.Set(*params.ProxyName); err != nil {
			return
		}
	}()
	return true
}

//export getTraffic
func getTraffic() *C.char {
	up, down := statistic.DefaultManager.Now()
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

//export asyncTestDelay
func asyncTestDelay(s *C.char) {
	go func() {
		paramsString := C.GoString(s)
		var params = &TestDelayParams{}
		err := json.Unmarshal([]byte(paramsString), params)
		if err != nil {
			return
		}

		expectedStatus, err := utils.NewUnsignedRanges[uint16]("")
		if err != nil {
			return
		}

		ctx, cancel := context.WithTimeout(context.Background(), time.Millisecond*time.Duration(params.Timeout))
		defer cancel()

		proxies := tunnel.ProxiesWithProviders()
		proxy := proxies[params.ProxyName]

		delayData := &Delay{
			Name: params.ProxyName,
		}

		message := bridge.Message{
			Type: bridge.Delay,
			Data: delayData,
		}

		if proxy == nil {
			delayData.Value = -1
			bridge.SendMessage(message)
			return
		}

		delay, err := proxy.URLTest(ctx, constant.DefaultTestURL, expectedStatus)
		if err != nil || delay == 0 {
			delayData.Value = -1
			bridge.SendMessage(message)
			return
		}

		delayData.Value = int32(delay)
		bridge.SendMessage(message)
	}()
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
func closeConnections() bool {
	statistic.DefaultManager.Range(func(c statistic.Tracker) bool {
		err := c.Close()
		if err != nil {
			return false
		}
		return true
	})
	return true
}

//export closeConnection
func closeConnection(id *C.char) bool {
	connectionId := C.GoString(id)

	err := statistic.DefaultManager.Get(connectionId).Close()
	if err != nil {
		return false
	}
	return true
}

//export getProviders
func getProviders() *C.char {
	data, err := json.Marshal(tunnel.Providers())
	if err != nil {
		return C.CString("")
	}
	return C.CString(string(data))
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
	externalProviders := make([]ExternalProvider, 0)
	providers := tunnel.Providers()
	for n, p := range providers {
		if p.VehicleType() != cp.Compatible {
			p := p.(*provider.ProxySetProvider)
			externalProviders = append(externalProviders, ExternalProvider{
				Name:        n,
				Type:        p.Type().String(),
				VehicleType: p.VehicleType().String(),
				UpdateAt:    p.UpdatedAt,
			})
		}
	}
	for n, p := range tunnel.RuleProviders() {
		if p.VehicleType() != cp.Compatible {
			p := p.(*rp.RuleSetProvider)
			externalProviders = append(externalProviders, ExternalProvider{
				Name:        n,
				Type:        p.Type().String(),
				VehicleType: p.VehicleType().String(),
				UpdateAt:    p.UpdatedAt,
			})
		}
	}
	data, err := json.Marshal(externalProviders)
	if err != nil {
		return C.CString("")
	}
	return C.CString(string(data))
}

//export updateExternalProvider
func updateExternalProvider(providerName *C.char, providerType *C.char, port C.longlong) {
	i := int64(port)
	go func() {
		providerNameString := C.GoString(providerName)
		providerTypeString := C.GoString(providerType)

		switch providerTypeString {
		case "Proxy":
			providers := tunnel.Providers()
			err := providers[providerNameString].Update()
			if err != nil {
				bridge.SendToPort(i, err.Error())
				return
			}
		case "Rule":
			providers := tunnel.RuleProviders()
			err := providers[providerNameString].Update()
			if err != nil {
				bridge.SendToPort(i, err.Error())
				return
			}
		case "GeoIp":
			err := mmdb.DownloadMMDB(constant.Path.Resolve(providerNameString))
			if err != nil {
				bridge.SendToPort(i, err.Error())
				return
			}
		case "GeoSite":
			err := mmdb.DownloadGeoSite(constant.Path.Resolve(providerNameString))
			if err != nil {
				bridge.SendToPort(i, err.Error())
				return
			}
		case "ASN":
			err := mmdb.DownloadASN(constant.Path.Resolve(providerNameString))
			if err != nil {
				bridge.SendToPort(i, err.Error())
				return
			}
		}
		bridge.SendToPort(i, "")
	}()
}

//export healthcheck
func healthcheck() {
	hcCompatibleProvider(tunnel.Providers())
}

//export initNativeApiBridge
func initNativeApiBridge(api unsafe.Pointer, port C.longlong) {
	bridge.InitDartApi(api)
	i := int64(port)
	bridge.Port = &i
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
		bridge.SendMessage(bridge.Message{
			Type: bridge.Delay,
			Data: delayData,
		})
	}
}
