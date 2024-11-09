package main

import "C"
import (
	"context"
	"core/state"
	"errors"
	"fmt"
	"github.com/metacubex/mihomo/constant/features"
	"github.com/metacubex/mihomo/hub/route"
	"github.com/samber/lo"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
	"sync"
	"syscall"
	"time"

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
	"github.com/metacubex/mihomo/listener"
	"github.com/metacubex/mihomo/log"
	rp "github.com/metacubex/mihomo/rules/provider"
	"github.com/metacubex/mihomo/tunnel"
)

type ConfigExtendedParams struct {
	IsPatch      bool              `json:"is-patch"`
	IsCompatible bool              `json:"is-compatible"`
	SelectedMap  map[string]string `json:"selected-map"`
	TestURL      *string           `json:"test-url"`
	OverrideDns  bool              `json:"override-dns"`
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
	Name             string                     `json:"name"`
	Type             string                     `json:"type"`
	VehicleType      string                     `json:"vehicle-type"`
	Count            int                        `json:"count"`
	Path             string                     `json:"path"`
	UpdateAt         time.Time                  `json:"update-at"`
	SubscriptionInfo *provider.SubscriptionInfo `json:"subscription-info"`
}

type ExternalProviders []ExternalProvider

func (a ExternalProviders) Len() int           { return len(a) }
func (a ExternalProviders) Less(i, j int) bool { return a[i].Name < a[j].Name }
func (a ExternalProviders) Swap(i, j int)      { a[i], a[j] = a[j], a[i] }

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
		if configParams.TestURL != nil {
			if mapping["health-check"] != nil {
				hc := mapping["health-check"].(map[string]any)
				if hc != nil {
					if hc["url"] != nil {
						hc["url"] = *configParams.TestURL
					}
				}
			}
		}
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

func getExternalProvidersRaw() map[string]cp.Provider {
	eps := make(map[string]cp.Provider)
	for n, p := range tunnel.Providers() {
		if p.VehicleType() != cp.Compatible {
			eps[n] = p
		}
	}
	for n, p := range tunnel.RuleProviders() {
		if p.VehicleType() != cp.Compatible {
			eps[n] = p
		}
	}
	return eps
}

func toExternalProvider(p cp.Provider) (*ExternalProvider, error) {
	switch p.(type) {
	case *provider.ProxySetProvider:
		psp := p.(*provider.ProxySetProvider)
		return &ExternalProvider{
			Name:             psp.Name(),
			Type:             psp.Type().String(),
			VehicleType:      psp.VehicleType().String(),
			Count:            psp.Count(),
			UpdateAt:         psp.UpdatedAt(),
			Path:             psp.Vehicle().Path(),
			SubscriptionInfo: psp.GetSubscriptionInfo(),
		}, nil
	case *rp.RuleSetProvider:
		rsp := p.(*rp.RuleSetProvider)
		return &ExternalProvider{
			Name:        rsp.Name(),
			Type:        rsp.Type().String(),
			VehicleType: rsp.VehicleType().String(),
			Count:       rsp.Count(),
			UpdateAt:    rsp.UpdatedAt(),
			Path:        rsp.Vehicle().Path(),
		}, nil
	default:
		return nil, errors.New("not external provider")
	}
}

func sideUpdateExternalProvider(p cp.Provider, bytes []byte) error {
	switch p.(type) {
	case *provider.ProxySetProvider:
		psp := p.(*provider.ProxySetProvider)
		_, _, err := psp.SideUpdate(bytes)
		if err == nil {
			return err
		}
		return nil
	case rp.RuleSetProvider:
		rsp := p.(*rp.RuleSetProvider)
		_, _, err := rsp.SideUpdate(bytes)
		if err == nil {
			return err
		}
		return nil
	default:
		return errors.New("not external provider")
	}
}

func decorationConfig(profileId string, cfg config.RawConfig) *config.RawConfig {
	prof := getRawConfigWithId(profileId)
	overwriteConfig(prof, cfg)
	return prof
}

func genHosts(hosts, patchHosts map[string]any) {
	for k, v := range patchHosts {
		hosts[k] = v
	}
}

func trimArr(arr []string) (r []string) {
	for _, e := range arr {
		r = append(r, strings.Trim(e, " "))
	}
	return
}

var ips = []string{"ipinfo.io", "ipapi.co", "api.ip.sb", "ipwho.is"}

func overrideRules(rules *[]string) {
	var target = ""
	for _, line := range *rules {
		rule := trimArr(strings.Split(line, ","))
		l := len(rule)
		if l != 2 {
			return
		}
		if strings.ToUpper(rule[0]) == "MATCH" {
			target = rule[1]
			break
		}
	}
	if target == "" {
		return
	}
	var rulesExt = lo.Map(ips, func(ip string, index int) string {
		return fmt.Sprintf("DOMAIN %s %s", ip, target)
	})
	*rules = append(rulesExt, *rules...)
}

func overwriteConfig(targetConfig *config.RawConfig, patchConfig config.RawConfig) {
	targetConfig.ExternalController = patchConfig.ExternalController
	targetConfig.ExternalUI = ""
	targetConfig.Interface = ""
	targetConfig.ExternalUIURL = ""
	targetConfig.TCPConcurrent = patchConfig.TCPConcurrent
	targetConfig.UnifiedDelay = patchConfig.UnifiedDelay
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
	if configParams.TestURL != nil {
		constant.DefaultTestURL = *configParams.TestURL
	}
	for idx := range targetConfig.ProxyGroup {
		targetConfig.ProxyGroup[idx]["url"] = ""
	}
	genHosts(targetConfig.Hosts, patchConfig.Hosts)
	if configParams.OverrideDns {
		targetConfig.DNS = patchConfig.DNS
	} else {
		if targetConfig.DNS.Enable == false {
			targetConfig.DNS.Enable = true
		}
	}
	overrideRules(&targetConfig.Rule)
	//if runtime.GOOS == "android" {
	//	targetConfig.DNS.NameServer = append(targetConfig.DNS.NameServer, "dhcp://"+dns.SystemDNSPlaceholder)
	//} else if runtime.GOOS == "windows" {
	//	targetConfig.DNS.NameServer = append(targetConfig.DNS.NameServer, dns.SystemDNSPlaceholder)
	//}
	//if configParams.IsCompatible == false {
	//	targetConfig.ProxyProvider = make(map[string]map[string]any)
	//	targetConfig.RuleProvider = make(map[string]map[string]any)
	//	generateProxyGroupAndRule(&targetConfig.ProxyGroup, &targetConfig.Rule)
	//}
}

func patchConfig(general *config.General, controller *config.Controller, tls *config.TLS) {
	log.Infoln("[Apply] patch")
	tunnel.SetSniffing(general.Sniffing)
	tunnel.SetFindProcessMode(general.FindProcessMode)
	dialer.SetTcpConcurrent(general.TCPConcurrent)
	dialer.DefaultInterface.Store(general.Interface)
	adapter.UnifiedDelay.Store(general.UnifiedDelay)
	tunnel.SetMode(general.Mode)
	log.SetLevel(general.LogLevel)
	resolver.DisableIPv6 = !general.IPv6

	route.ReCreateServer(&route.Config{
		Addr:        controller.ExternalController,
		TLSAddr:     controller.ExternalControllerTLS,
		UnixAddr:    controller.ExternalControllerUnix,
		PipeAddr:    controller.ExternalControllerPipe,
		Secret:      controller.Secret,
		Certificate: tls.Certificate,
		PrivateKey:  tls.PrivateKey,
		DohServer:   controller.ExternalDohServer,
		IsDebug:     false,
		Cors: route.Cors{
			AllowOrigins:        controller.Cors.AllowOrigins,
			AllowPrivateNetwork: controller.Cors.AllowPrivateNetwork,
		},
	})
}

var isRunning = false

var runLock sync.Mutex

func updateListeners(general *config.General, listeners map[string]constant.InboundListener) {
	if !isRunning {
		return
	}
	runLock.Lock()
	defer runLock.Unlock()
	stopListeners()
	listener.PatchInboundListeners(listeners, tunnel.Tunnel, true)
	listener.SetAllowLan(general.AllowLan)
	inbound.SetSkipAuthPrefixes(general.SkipAuthPrefixes)
	inbound.SetAllowedIPs(general.LanAllowedIPs)
	inbound.SetDisAllowedIPs(general.LanDisAllowedIPs)
	listener.SetBindAddress(general.BindAddress)
	listener.ReCreateHTTP(general.Port, tunnel.Tunnel)
	listener.ReCreateSocks(general.SocksPort, tunnel.Tunnel)
	listener.ReCreateRedir(general.RedirPort, tunnel.Tunnel)
	listener.ReCreateTProxy(general.TProxyPort, tunnel.Tunnel)
	listener.ReCreateMixed(general.MixedPort, tunnel.Tunnel)
	listener.ReCreateShadowSocks(general.ShadowSocksConfig, tunnel.Tunnel)
	listener.ReCreateVmess(general.VmessConfig, tunnel.Tunnel)
	listener.ReCreateTuic(general.TuicServer, tunnel.Tunnel)
	if !features.Android {
		listener.ReCreateTun(general.Tun, tunnel.Tunnel)
	}
}

func stopListeners() {
	listener.StopListener()
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

func applyConfig() error {
	cfg, err := config.ParseRawConfig(state.CurrentRawConfig)
	if err != nil {
		cfg, _ = config.ParseRawConfig(config.DefaultRawConfig())
	}
	if configParams.IsPatch {
		patchConfig(cfg.General, cfg.Controller, cfg.TLS)
	} else {
		closeConnections()
		runtime.GC()
		hub.ApplyConfig(cfg)
		patchSelectGroup()
	}
	updateListeners(cfg.General, cfg.Listeners)
	return err
}
