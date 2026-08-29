package main

import (
	b "bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"runtime"
	"sync"
	"sync/atomic"
	"time"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/inbound"
	"github.com/metacubex/mihomo/adapter/outboundgroup"
	"github.com/metacubex/mihomo/adapter/provider"
	"github.com/metacubex/mihomo/component/dialer"
	"github.com/metacubex/mihomo/component/resolver"
	"github.com/metacubex/mihomo/component/updater"
	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/constant/features"
	cp "github.com/metacubex/mihomo/constant/provider"
	"github.com/metacubex/mihomo/hub"
	"github.com/metacubex/mihomo/hub/executor"
	"github.com/metacubex/mihomo/hub/route"
	"github.com/metacubex/mihomo/listener"
	LC "github.com/metacubex/mihomo/listener/config"
	"github.com/metacubex/mihomo/log"
	rp "github.com/metacubex/mihomo/rules/provider"
	"github.com/metacubex/mihomo/tunnel"
)

const (
	delayTestConcurrency    = 50
	defaultTestURL          = "https://www.gstatic.com/generate_204"
	defaultDelayTestTimeout = 5 * time.Second
)

var (
	configMu      sync.Mutex
	currentConfig *config.Config

	// selectMu serialises proxy-group selection writes. mihomo's Selector.Set
	// writes s.selected with no lock of its own, so something has to; configMu
	// used to, which made a tap on a node wait out a whole config apply,
	// provider downloads included, for a write that touches one field.
	// patchSelectGroup takes it under configMu, fixing the order as
	// configMu -> selectMu.
	selectMu sync.Mutex

	isInit      atomic.Bool
	isRunning   atomic.Bool
	isSuspended atomic.Bool
	sdkVersion  atomic.Int32
	testURL     atomic.Pointer[string]

	delayTestSlots = make(chan struct{}, delayTestConcurrency)

	debugStderr = os.Getenv("FLCLASH_CORE_DEBUG") != ""
)

var (
	errConfigNotApplied    = errors.New("config is not applied")
	errNotExternalProvider = errors.New("not external provider")
)

func externalProviders() map[string]cp.Provider {
	eps := make(map[string]cp.Provider)
	for n, p := range tunnel.ProvidersSnapshot() {
		if p.VehicleType() != cp.Compatible {
			eps[n] = p
		}
	}
	for n, p := range tunnel.RuleProvidersSnapshot() {
		if p.VehicleType() != cp.Compatible {
			eps[n] = p
		}
	}
	return eps
}

func lookupExternalProvider(name string) (cp.Provider, bool) {
	if p, exist := tunnel.RuleProvidersSnapshot()[name]; exist && p.VehicleType() != cp.Compatible {
		return p, true
	}
	if p, exist := tunnel.ProvidersSnapshot()[name]; exist && p.VehicleType() != cp.Compatible {
		return p, true
	}
	return nil, false
}

func toExternalProvider(p cp.Provider) (*ExternalProvider, error) {
	switch typed := p.(type) {
	case *provider.ProxySetProvider:
		return &ExternalProvider{
			Name:             typed.Name(),
			Type:             typed.Type().String(),
			VehicleType:      typed.VehicleType().String(),
			Count:            typed.Count(),
			UpdateAt:         typed.UpdatedAt(),
			Path:             typed.Vehicle().Path(),
			SubscriptionInfo: typed.GetSubscriptionInfo(),
		}, nil
	case *rp.RuleSetProvider:
		return &ExternalProvider{
			Name:        typed.Name(),
			Type:        typed.Type().String(),
			VehicleType: typed.VehicleType().String(),
			Count:       typed.Count(),
			UpdateAt:    typed.UpdatedAt(),
			Path:        typed.Vehicle().Path(),
		}, nil
	default:
		return nil, errNotExternalProvider
	}
}

func sideUpdateExternalProvider(p cp.Provider, data []byte) error {
	switch typed := p.(type) {
	case *provider.ProxySetProvider:
		_, _, err := typed.SideUpdate(data)
		return err
	case *rp.RuleSetProvider:
		_, _, err := typed.SideUpdate(data)
		return err
	default:
		return errNotExternalProvider
	}
}

func updateListeners(cfg *config.Config) {
	if cfg == nil || !isRunning.Load() {
		return
	}
	general := cfg.General
	listener.PatchInboundListeners(cfg.Listeners, tunnel.Tunnel, true)

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

func patchSelectGroup(mapping map[string]string) {
	selectMu.Lock()
	defer selectMu.Unlock()
	for name, proxy := range tunnel.AllProxies() {
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

func defaultSetupParams() *SetupParams {
	return &SetupParams{
		TestURL:     defaultTestURL,
		SelectedMap: map[string]string{},
	}
}

func setTestURL(url string) {
	if url == "" {
		return
	}
	constant.DefaultTestURL = url
	testURL.Store(&url)
}

func currentTestURL() string {
	if url := testURL.Load(); url != nil && *url != "" {
		return *url
	}
	return defaultTestURL
}

func acquireDelayTestSlot(ctx context.Context) bool {
	select {
	case delayTestSlots <- struct{}{}:
		return true
	case <-ctx.Done():
		return false
	}
}

func releaseDelayTestSlot() {
	<-delayTestSlots
}

func routeConfig(cfg *config.Config) *route.Config {
	controller := cfg.Controller
	routeCfg := &route.Config{
		Addr:        controller.ExternalController,
		TLSAddr:     controller.ExternalControllerTLS,
		UnixAddr:    controller.ExternalControllerUnix,
		PipeAddr:    controller.ExternalControllerPipe,
		RoutingMark: controller.ExternalControllerRoutingMark,
		Secret:      controller.Secret,
		DohServer:   controller.ExternalDohServer,
		IsDebug:     cfg.General.LogLevel == log.DEBUG,
		Cors: route.Cors{
			AllowOrigins:        controller.Cors.AllowOrigins,
			AllowPrivateNetwork: controller.Cors.AllowPrivateNetwork,
		},
	}
	if cfg.TLS != nil {
		routeCfg.Certificate = cfg.TLS.Certificate
		routeCfg.PrivateKey = cfg.TLS.PrivateKey
		routeCfg.ClientAuthType = cfg.TLS.ClientAuthType
		routeCfg.ClientAuthCert = cfg.TLS.ClientAuthCert
		routeCfg.EchKey = cfg.TLS.EchKey
	}
	return routeCfg
}

func patchTun(target *LC.Tun, params *tunSchema) {
	target.Enable = params.Enable
	if params.AutoRoute != nil {
		target.AutoRoute = *params.AutoRoute
	}
	if params.Device != nil {
		target.Device = *params.Device
	}
	if params.RouteAddress != nil {
		target.RouteAddress = *params.RouteAddress
	}
	if params.DNSHijack != nil {
		target.DNSHijack = *params.DNSHijack
	}
	if params.Stack != nil {
		target.Stack = *params.Stack
	}
}

func updateConfig(params *UpdateParams) error {
	configMu.Lock()
	defer configMu.Unlock()
	if currentConfig == nil {
		return errConfigNotApplied
	}

	general := currentConfig.General
	if params.MixedPort != nil {
		general.MixedPort = *params.MixedPort
	}
	if params.AllowLan != nil {
		general.AllowLan = *params.AllowLan
	}
	if params.FindProcessMode != nil {
		general.FindProcessMode = *params.FindProcessMode
		tunnel.SetFindProcessMode(general.FindProcessMode)
	}
	if params.TCPConcurrent != nil {
		general.TCPConcurrent = *params.TCPConcurrent
		dialer.SetTcpConcurrent(general.TCPConcurrent)
	}
	if params.UnifiedDelay != nil {
		general.UnifiedDelay = *params.UnifiedDelay
		adapter.UnifiedDelay.Store(general.UnifiedDelay)
	}
	if params.Mode != nil {
		general.Mode = *params.Mode
		tunnel.SetMode(general.Mode)
	}
	if params.LogLevel != nil {
		general.LogLevel = *params.LogLevel
		log.SetLevel(general.LogLevel)
	}
	if params.IPv6 != nil {
		general.IPv6 = *params.IPv6
		resolver.DisableIPv6 = !general.IPv6
	}
	if params.Tun != nil {
		patchTun(&general.Tun, params.Tun)
	}
	if params.ExternalController != nil &&
		*params.ExternalController != currentConfig.Controller.ExternalController {
		currentConfig.Controller.ExternalController = *params.ExternalController
		route.ReCreateServer(routeConfig(currentConfig))
	}

	updateListeners(currentConfig)
	syncGeoUpdater(params.GeoAutoUpdate, params.GeoUpdateInterval)
	return nil
}

func syncGeoUpdater(autoUpdate *bool, interval *int) {
	changed := false
	if autoUpdate != nil && *autoUpdate != updater.GeoAutoUpdate() {
		updater.SetGeoAutoUpdate(*autoUpdate)
		changed = true
	}
	if interval != nil && *interval != updater.GeoUpdateInterval() {
		updater.SetGeoUpdateInterval(*interval)
		changed = true
	}
	if !changed {
		return
	}
	reconcileGeoUpdater()
}

var (
	registerGeoUpdater = updater.RegisterGeoUpdaterWithCancel
	stopGeoUpdater     = updater.StopGeoUpdater
)

func reconcileGeoUpdater() {
	if updater.GeoAutoUpdate() {
		registerGeoUpdater()
		return
	}
	stopGeoUpdater()
}

func loadConfig(path string) (*config.Config, error) {
	buf, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	return executor.ParseWithBytes(buf)
}

func applyConfig(params *SetupParams) error {
	runtime.GC()
	configMu.Lock()
	defer configMu.Unlock()

	setTestURL(params.TestURL)
	cfg, err := loadConfig(filepath.Join(constant.Path.HomeDir(), "config.yaml"))
	if err != nil {
		// The fallback is what keeps the listeners serving while the host
		// reports the error, but it applies a config with no proxies in it.
		// From the UI that is indistinguishable from a subscription that went
		// dead: the profile still lists every node, every delay test answers
		// Timeout, and nothing routes. Name the real cause in the log.
		logError(
			"config apply failed, falling back to the built-in default - no proxies will be available: %v",
			err,
		)
		fallback, fallbackErr := config.ParseRawConfig(config.DefaultRawConfig())
		if fallbackErr != nil {
			return err
		}
		cfg = fallback
	}

	currentConfig = cfg
	hub.ApplyConfig(cfg)
	patchSelectGroup(params.SelectedMap)
	updateListeners(cfg)
	reconcileGeoUpdater()
	return err
}

func UnmarshalJson(data []byte, v any) error {
	decoder := json.NewDecoder(b.NewReader(data))
	decoder.UseNumber()
	return decoder.Decode(v)
}

func logError(format string, args ...any) {
	log.Errorln(format, args...)
	if debugStderr {
		fmt.Fprintf(os.Stderr, "[ERROR] "+format+"\n", args...)
	}
}
