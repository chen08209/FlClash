package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/inbound"
	"github.com/metacubex/mihomo/adapter/outboundgroup"
	"github.com/metacubex/mihomo/adapter/provider"
	"github.com/metacubex/mihomo/common/batch"
	"github.com/metacubex/mihomo/component/dialer"
	"github.com/metacubex/mihomo/component/resolver"
	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/constant/features"
	cp "github.com/metacubex/mihomo/constant/provider"
	"github.com/metacubex/mihomo/hub"
	"github.com/metacubex/mihomo/hub/route"
	"github.com/metacubex/mihomo/listener"
	"github.com/metacubex/mihomo/log"
	rp "github.com/metacubex/mihomo/rules/provider"
	"github.com/metacubex/mihomo/tunnel"
	"github.com/samber/lo"
	"os"
	"path/filepath"
	"runtime"
	"strings"
	"sync"
)

var (
	isRunning = false
	runLock   sync.Mutex
	ips       = []string{"ipinfo.io", "ipapi.co", "api.ip.sb", "ipwho.is"}
	b, _      = batch.New[bool](context.Background(), batch.WithConcurrencyNum[bool](50))
)

type ExternalProviders []ExternalProvider

func (a ExternalProviders) Len() int           { return len(a) }
func (a ExternalProviders) Less(i, j int) bool { return a[i].Name < a[j].Name }
func (a ExternalProviders) Swap(i, j int)      { a[i], a[j] = a[j], a[i] }

func (message *Message) Json() (string, error) {
	data, err := json.Marshal(message)
	return string(data), err
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
}

func patchConfig() {
	log.Infoln("[Apply] patch")
	general := currentConfig.General
	controller := currentConfig.Controller
	tls := currentConfig.TLS
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

func updateListeners(force bool) {
	if !isRunning {
		return
	}
	general := currentConfig.General
	listeners := currentConfig.Listeners
	if force == true {
		stopListeners()
	}
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

func applyConfig(rawConfig *config.RawConfig) error {
	runLock.Lock()
	defer runLock.Unlock()
	var err error
	currentConfig, err = config.ParseRawConfig(rawConfig)
	if err != nil {
		currentConfig, _ = config.ParseRawConfig(config.DefaultRawConfig())
	}
	if configParams.IsPatch {
		patchConfig()
	} else {
		handleCloseConnectionsUnLock()
		runtime.GC()
		hub.ApplyConfig(currentConfig)
		patchSelectGroup()
	}
	updateListeners(false)
	return err
}
