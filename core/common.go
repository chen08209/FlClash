package main

import "C"
import (
	"context"
	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/inbound"
	"github.com/metacubex/mihomo/adapter/outboundgroup"
	"github.com/metacubex/mihomo/adapter/provider"
	"github.com/metacubex/mihomo/common/batch"
	"github.com/metacubex/mihomo/component/dialer"
	"github.com/metacubex/mihomo/component/resolver"
	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/constant"
	cp "github.com/metacubex/mihomo/constant/provider"
	"github.com/metacubex/mihomo/hub"
	"github.com/metacubex/mihomo/hub/executor"
	"github.com/metacubex/mihomo/hub/route"
	"github.com/metacubex/mihomo/listener"
	"github.com/metacubex/mihomo/log"
	rp "github.com/metacubex/mihomo/rules/provider"
	"github.com/metacubex/mihomo/tunnel"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
	"sync"
	"syscall"
	"time"
)

//type healthCheckSchema struct {
//	Enable         bool   `provider:"enable"`
//	URL            string `provider:"url"`
//	Interval       int    `provider:"interval"`
//	TestTimeout    int    `provider:"timeout,omitempty"`
//	Lazy           bool   `provider:"lazy,omitempty"`
//	ExpectedStatus string `provider:"expected-status,omitempty"`
//}

//type proxyProviderSchema struct {
//	Type          string `provider:"type"`
//	Path          string `provider:"path,omitempty"`
//	URL           string `provider:"url,omitempty"`
//	Proxy         string `provider:"proxy,omitempty"`
//	Interval      int    `provider:"interval,omitempty"`
//	Filter        string `provider:"filter,omitempty"`
//	ExcludeFilter string `provider:"exclude-filter,omitempty"`
//	ExcludeType   string `provider:"exclude-type,omitempty"`
//	DialerProxy   string `provider:"dialer-proxy,omitempty"`
//
//	HealthCheck healthCheckSchema   `provider:"health-check,omitempty"`
//	Override    ap.OverrideSchema   `provider:"override,omitempty"`
//	Header      map[string][]string `provider:"header,omitempty"`
//}
//
//type ruleProviderSchema struct {
//	Type     string `provider:"type"`
//	Behavior string `provider:"behavior"`
//	Path     string `provider:"path,omitempty"`
//	URL      string `provider:"url,omitempty"`
//	Proxy    string `provider:"proxy,omitempty"`
//	Format   string `provider:"format,omitempty"`
//	Interval int    `provider:"interval,omitempty"`
//}

type ConfigExtendedParams struct {
	IsPatch      bool              `json:"is-patch"`
	IsCompatible bool              `json:"is-compatible"`
	SelectedMap  map[string]string `json:"selected-map"`
	TestURL      *string           `json:"test-url"`
}

type GenerateConfigParams struct {
	ProfileId string               `json:"profile-id"`
	Config    config.RawConfig     `json:"config" `
	Params    ConfigExtendedParams `json:"params"`
}

type ChangeProxyParams struct {
	GroupName *string `json:"group-name"`
	ProxyName *string `json:"proxy-name"`
}

type TestDelayParams struct {
	ProxyName string `json:"proxy-name"`
	Timeout   int64  `json:"timeout"`
}

type ProcessMapItem struct {
	Id    int64  `json:"id"`
	Value string `json:"value"`
}

type ExternalProvider struct {
	Name        string    `json:"name"`
	Type        string    `json:"type"`
	VehicleType string    `json:"vehicle-type"`
	Count       int       `json:"count"`
	Path        string    `json:"path"`
	UpdateAt    time.Time `json:"update-at"`
}

var b, _ = batch.New[bool](context.Background(), batch.WithConcurrencyNum[bool](50))

func restartExecutable(execPath string) {
	var err error
	executor.Shutdown()
	if runtime.GOOS == "windows" {
		cmd := exec.Command(execPath, os.Args[1:]...)
		log.Infoln("restarting: %q %q", execPath, os.Args[1:])
		cmd.Stdin = os.Stdin
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		err = cmd.Start()
		if err != nil {
			log.Fatalln("restarting: %s", err)
		}

		os.Exit(0)
	}

	log.Infoln("restarting: %q %q", execPath, os.Args[1:])
	err = syscall.Exec(execPath, os.Args, os.Environ())
	if err != nil {
		log.Fatalln("restarting: %s", err)
	}
}

func readFile(path string) ([]byte, error) {
	if _, err := os.Stat(path); os.IsNotExist(err) {
		return nil, err
	}
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}

	return data, err
}

func removeFile(path string) error {
	absPath, err := filepath.Abs(path)
	if err != nil {
		return err
	}
	err = os.Remove(absPath)
	if err != nil {
		return err
	}

	return nil
}

func getProfilePath(id string) string {
	return filepath.Join(constant.Path.HomeDir(), "profiles", id+".yaml")
}

func getProfileProvidersPath(id string) string {
	return filepath.Join(constant.Path.HomeDir(), "providers", id)
}

func getRawConfigWithId(id string) *config.RawConfig {
	path := getProfilePath(id)
	bytes, err := readFile(path)
	if err != nil {
		log.Errorln("profile is not exist")
		return config.DefaultRawConfig()
	}
	prof, err := config.UnmarshalRawConfig(bytes)
	if err != nil {
		log.Errorln("unmarshalRawConfig error %v", err)
		return config.DefaultRawConfig()
	}
	for _, mapping := range prof.ProxyProvider {
		value, exist := mapping["path"].(string)
		if !exist {
			continue
		}
		mapping["path"] = filepath.Join(getProfileProvidersPath(id), value)
	}
	for _, mapping := range prof.RuleProvider {
		value, exist := mapping["path"].(string)
		if !exist {
			continue
		}
		mapping["path"] = filepath.Join(getProfileProvidersPath(id), value)
	}
	return prof
}

func getExternalProvidersRaw() map[string]ExternalProvider {
	externalProviders := make(map[string]ExternalProvider)
	for n, p := range tunnel.Providers() {
		if p.VehicleType() != cp.Compatible {
			p := p.(*provider.ProxySetProvider)
			externalProviders[n] = ExternalProvider{
				Name:        n,
				Type:        p.Type().String(),
				VehicleType: p.VehicleType().String(),
				Count:       p.Count(),
				Path:        p.Vehicle().Path(),
				UpdateAt:    p.UpdatedAt,
			}
		}
	}
	for n, p := range tunnel.RuleProviders() {
		if p.VehicleType() != cp.Compatible {
			p := p.(*rp.RuleSetProvider)
			externalProviders[n] = ExternalProvider{
				Name:        n,
				Type:        p.Type().String(),
				VehicleType: p.VehicleType().String(),
				Count:       p.Count(),
				Path:        p.Vehicle().Path(),
				UpdateAt:    p.UpdatedAt,
			}
		}
	}
	return externalProviders
}

func decorationConfig(profileId string, cfg config.RawConfig) *config.RawConfig {
	prof := getRawConfigWithId(profileId)
	overwriteConfig(prof, cfg)
	return prof
}

func Reduce[T any, U any](s []T, initVal U, f func(U, T) U) U {
	for _, v := range s {
		initVal = f(initVal, v)
	}
	return initVal
}

func Map[T, U any](slice []T, fn func(T) U) []U {
	result := make([]U, len(slice))
	for i, v := range slice {
		result[i] = fn(v)
	}
	return result
}

func replaceFromMap(s string, m map[string]string) string {
	for k, v := range m {
		s = strings.ReplaceAll(s, k, v)
	}
	return s
}

func removeDuplicateFromSlice[T any](slice []T) []T {
	result := make([]T, 0)
	seen := make(map[any]struct{})
	for _, value := range slice {
		if _, ok := seen[value]; !ok {
			result = append(result, value)
			seen[value] = struct{}{}
		}
	}
	return result
}

func generateProxyGroupAndRule(proxyGroup *[]map[string]any, rule *[]string) {
	var replacements = map[string]string{}
	var selectArr []map[string]any
	var urlTestArr []map[string]any
	var fallbackArr []map[string]any
	for _, group := range *proxyGroup {
		switch group["type"] {
		case "select":
			selectArr = append(selectArr, group)
			replacements[group["name"].(string)] = "Proxy"
			break
		case "url-test":
			urlTestArr = append(urlTestArr, group)
			replacements[group["name"].(string)] = "Auto"
			break
		case "fallback":
			fallbackArr = append(fallbackArr, group)
			replacements[group["name"].(string)] = "Fallback"
			break
		default:
			break
		}
	}

	ProxyProxies := Reduce(selectArr, []string{}, func(res []string, cur map[string]any) []string {
		if cur["proxies"] == nil {
			return res
		}
		for _, proxyName := range cur["proxies"].([]interface{}) {
			if str, ok := proxyName.(string); ok {
				str = replaceFromMap(str, replacements)
				if str != "Proxy" {
					res = append(res, str)
				}
			}
		}
		return res
	})

	ProxyProxies = removeDuplicateFromSlice(ProxyProxies)

	AutoProxies := Reduce(urlTestArr, []string{}, func(res []string, cur map[string]any) []string {
		if cur["proxies"] == nil {
			return res
		}
		for _, proxyName := range cur["proxies"].([]interface{}) {
			if str, ok := proxyName.(string); ok {
				str = replaceFromMap(str, replacements)
				if str != "Auto" {
					res = append(res, str)
				}
			}
		}
		return res
	})

	AutoProxies = removeDuplicateFromSlice(AutoProxies)

	FallbackProxies := Reduce(fallbackArr, []string{}, func(res []string, cur map[string]any) []string {
		if cur["proxies"] == nil {
			return res
		}
		for _, proxyName := range cur["proxies"].([]interface{}) {
			if str, ok := proxyName.(string); ok {
				str = replaceFromMap(str, replacements)
				if str != "Fallback" {
					res = append(res, str)
				}
			}
		}
		return res
	})

	FallbackProxies = removeDuplicateFromSlice(FallbackProxies)

	var computedProxyGroup []map[string]any

	if len(ProxyProxies) > 0 {
		computedProxyGroup = append(computedProxyGroup,
			map[string]any{
				"name":    "Proxy",
				"type":    "select",
				"proxies": ProxyProxies,
			})
	}

	if len(AutoProxies) > 0 {
		computedProxyGroup = append(computedProxyGroup,
			map[string]any{
				"name":    "Auto",
				"type":    "url-test",
				"proxies": AutoProxies,
			})
	}

	if len(FallbackProxies) > 0 {
		computedProxyGroup = append(computedProxyGroup,
			map[string]any{
				"name":    "Fallback",
				"type":    "fallback",
				"proxies": FallbackProxies,
			})
	}

	computedRule := Map(*rule, func(value string) string {
		return replaceFromMap(value, replacements)
	})

	*proxyGroup = computedProxyGroup
	*rule = computedRule
}

func overwriteConfig(targetConfig *config.RawConfig, patchConfig config.RawConfig) {
	targetConfig.ExternalController = patchConfig.ExternalController
	targetConfig.ExternalUI = ""
	targetConfig.Interface = ""
	targetConfig.ExternalUIURL = ""
	targetConfig.TCPConcurrent = patchConfig.TCPConcurrent
	targetConfig.UnifiedDelay = patchConfig.UnifiedDelay
	//targetConfig.GeodataMode = false
	targetConfig.IPv6 = patchConfig.IPv6
	targetConfig.LogLevel = patchConfig.LogLevel
	targetConfig.Port = 0
	targetConfig.SocksPort = 0
	targetConfig.KeepAliveInterval = patchConfig.KeepAliveInterval
	targetConfig.MixedPort = patchConfig.MixedPort
	targetConfig.FindProcessMode = patchConfig.FindProcessMode
	targetConfig.AllowLan = patchConfig.AllowLan
	targetConfig.Mode = patchConfig.Mode
	targetConfig.Tun.Enable = patchConfig.Tun.Enable
	targetConfig.Tun.Device = patchConfig.Tun.Device
	targetConfig.Tun.DNSHijack = patchConfig.Tun.DNSHijack
	targetConfig.Tun.Stack = patchConfig.Tun.Stack
	targetConfig.GeodataLoader = patchConfig.GeodataLoader
	targetConfig.Profile.StoreSelected = false
	targetConfig.GeoXUrl = patchConfig.GeoXUrl
	targetConfig.GlobalUA = patchConfig.GlobalUA
	if targetConfig.DNS.Enable == false {
		targetConfig.DNS = patchConfig.DNS
	}
	//if runtime.GOOS == "android" {
	//	targetConfig.DNS.NameServer = append(targetConfig.DNS.NameServer, "dhcp://"+dns.SystemDNSPlaceholder)
	//} else if runtime.GOOS == "windows" {
	//	targetConfig.DNS.NameServer = append(targetConfig.DNS.NameServer, dns.SystemDNSPlaceholder)
	//}
	if configParams.IsCompatible == false {
		targetConfig.ProxyProvider = make(map[string]map[string]any)
		targetConfig.RuleProvider = make(map[string]map[string]any)
		generateProxyGroupAndRule(&targetConfig.ProxyGroup, &targetConfig.Rule)
	}
}

func patchConfig(general *config.General) {
	log.Infoln("[Apply] patch")
	route.ReStartServer(general.ExternalController)
	listener.SetAllowLan(general.AllowLan)
	inbound.SetSkipAuthPrefixes(general.SkipAuthPrefixes)
	inbound.SetAllowedIPs(general.LanAllowedIPs)
	inbound.SetDisAllowedIPs(general.LanDisAllowedIPs)
	listener.SetBindAddress(general.BindAddress)
	tunnel.SetSniffing(general.Sniffing)
	tunnel.SetFindProcessMode(general.FindProcessMode)
	dialer.SetTcpConcurrent(general.TCPConcurrent)
	dialer.DefaultInterface.Store(general.Interface)
	adapter.UnifiedDelay.Store(general.UnifiedDelay)
	listener.ReCreateHTTP(general.Port, tunnel.Tunnel)
	listener.ReCreateSocks(general.SocksPort, tunnel.Tunnel)
	listener.ReCreateRedir(general.RedirPort, tunnel.Tunnel)
	listener.ReCreateAutoRedir(general.EBpf.AutoRedir, tunnel.Tunnel)
	listener.ReCreateTProxy(general.TProxyPort, tunnel.Tunnel)
	listener.ReCreateTun(general.Tun, tunnel.Tunnel)
	listener.ReCreateMixed(general.MixedPort, tunnel.Tunnel)
	listener.ReCreateShadowSocks(general.ShadowSocksConfig, tunnel.Tunnel)
	listener.ReCreateVmess(general.VmessConfig, tunnel.Tunnel)
	listener.ReCreateTuic(general.TuicServer, tunnel.Tunnel)
	tunnel.SetMode(general.Mode)
	log.SetLevel(general.LogLevel)

	resolver.DisableIPv6 = !general.IPv6
}

func patchSelectGroup() {
	mapping := configParams.SelectedMap
	if mapping == nil {
		return
	}
	for name, proxy := range tunnel.ProxiesWithProviders() {
		outbound, ok := proxy.(*adapter.Proxy)
		if !ok {
			continue
		}

		selector, ok := outbound.ProxyAdapter.(outboundgroup.SelectAble)
		if !ok {
			continue
		}

		selected, exist := mapping[name]
		if !exist {
			continue
		}

		selector.ForceSet(selected)
	}
}

var applyLock sync.Mutex

func applyConfig() error {
	applyLock.Lock()
	defer applyLock.Unlock()
	cfg, err := config.ParseRawConfig(currentConfig)
	if err != nil {
		cfg, _ = config.ParseRawConfig(config.DefaultRawConfig())
	}
	if configParams.TestURL != nil {
		constant.DefaultTestURL = *configParams.TestURL
	}
	if configParams.IsPatch {
		patchConfig(cfg.General)
	} else {
		closeConnections()
		runtime.GC()
		hub.UltraApplyConfig(cfg, true)
		patchSelectGroup()
	}
	return err
}
