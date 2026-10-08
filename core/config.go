package core

import (
	"encoding/json"
	"errors"
	"os"
	"path/filepath"
	"runtime"
	"strings"
	"sync"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/inbound"
	"github.com/metacubex/mihomo/component/age"
	"github.com/metacubex/mihomo/component/auth"
	"github.com/metacubex/mihomo/component/dialer"
	"github.com/metacubex/mihomo/component/resolver"
	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/hub"
	"github.com/metacubex/mihomo/hub/executor"
	"github.com/metacubex/mihomo/hub/route"
	authStore "github.com/metacubex/mihomo/listener/auth"
	LC "github.com/metacubex/mihomo/listener/config"
	"github.com/metacubex/mihomo/log"
	"github.com/metacubex/mihomo/tunnel"
)

var (
	configMu      sync.Mutex
	currentConfig *config.Config

	errConfigNotApplied = errors.New("config is not applied")
	errNotInitialized   = errors.New("not initialized")
)

func defaultSetupParams() *SetupParams {
	return &SetupParams{
		TestURL:     defaultTestURL,
		SelectedMap: map[string]string{},
	}
}

// A missing test-url means the built-in probe, while an empty one keeps the
// URL already in force, so the defaults have to be in place before the decode.
func (params *SetupParams) UnmarshalJSON(data []byte) error {
	type wire SetupParams
	decoded := wire(*defaultSetupParams())
	if err := json.Unmarshal(data, &decoded); err != nil {
		return err
	}
	*params = SetupParams(decoded)
	return nil
}

var setupConfig = applyConfig

func handleSetupConfig(params *SetupParams) error {
	if !isInit.Load() {
		return errNotInitialized
	}
	return setupConfig(params)
}

func handleGetConfig(path string) (*config.RawConfig, error) {
	buf, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	return unmarshalRawConfig(buf)
}

func handleValidateConfig(path string) error {
	_, err := handleGetConfig(path)
	return err
}

func handleDecryptConfig(params DecryptConfigParams) (string, error) {
	buf, err := os.ReadFile(params.Path)
	if err != nil {
		return "", err
	}
	buf, err = age.DecryptBytes(buf, params.AgeSecretKey)
	if err != nil {
		return "", err
	}
	return string(buf), nil
}

// mihomo writes the NTP time with settimeofday, which Android's app seccomp
// policy answers by killing the process rather than with EPERM.
var systemTimeWritable = runtime.GOOS != "android"

func loadConfig(path string) (*config.Config, error) {
	buf, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	cfg, err := executor.ParseWithBytes(buf)
	if err != nil {
		return nil, err
	}
	if cfg.NTP.WriteToSystem && !systemTimeWritable {
		log.Warnln("ntp write-to-system ignored: Android does not let apps set the system time")
		cfg.NTP.WriteToSystem = false
	}
	return cfg, nil
}

func applyConfig(params *SetupParams) error {
	runtime.GC()
	configMu.Lock()
	defer configMu.Unlock()

	setTestURL(params.TestURL)
	skipCertVerify.Store(params.SkipCertVerify)
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
	bumpRouteEpoch()
	updateListeners(cfg)
	reconcileGeoUpdater()
	scheduleLoadMemoryRelease()
	return err
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
	// IPv6 belongs with mode: turning it on moves a direct dial to another exit address.
	routeChanged := false
	if params.Mode != nil {
		routeChanged = routeChanged || general.Mode != *params.Mode
		general.Mode = *params.Mode
		tunnel.SetMode(general.Mode)
	}
	if params.LogLevel != nil {
		general.LogLevel = *params.LogLevel
		log.SetLevel(general.LogLevel)
	}
	if params.IPv6 != nil {
		routeChanged = routeChanged || general.IPv6 != *params.IPv6
		general.IPv6 = *params.IPv6
		resolver.DisableIPv6 = !general.IPv6
	}
	if params.Tun != nil {
		patchTun(&general.Tun, params.Tun)
	}
	patchController(params)
	if params.Authentication != nil {
		applyAuthentication(currentConfig, *params.Authentication)
	}
	if params.SkipCertVerify != nil {
		skipCertVerify.Store(*params.SkipCertVerify)
	}

	updateListeners(currentConfig)
	for geoType, link := range params.GeoXUrl {
		setGeoResourceUrl(geoType, link)
	}
	syncGeoUpdater(params.GeoAutoUpdate, params.GeoUpdateInterval)
	if routeChanged {
		bumpRouteEpoch()
	}
	return nil
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
	if params.MTU != nil {
		target.MTU = *params.MTU
	}
	if params.CongestionController != nil {
		target.CongestionController = *params.CongestionController
	}
	if params.StrictRoute != nil {
		target.StrictRoute = *params.StrictRoute
	}
	if params.RouteExcludeAddress != nil {
		target.RouteExcludeAddress = *params.RouteExcludeAddress
	}
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

func patchController(params *UpdateParams) {
	controller := currentConfig.Controller
	address, secret := controller.ExternalController, controller.Secret
	if params.ExternalController != nil {
		address = *params.ExternalController
	}
	if params.Secret != nil {
		secret = *params.Secret
	}
	if address == controller.ExternalController && secret == controller.Secret {
		return
	}
	controller.ExternalController, controller.Secret = address, secret
	route.ReCreateServer(routeConfig(currentConfig))
}

func applyAuthentication(cfg *config.Config, authentication []string) {
	users := make([]auth.AuthUser, 0, len(authentication))
	for _, line := range authentication {
		if user, pass, found := strings.Cut(line, ":"); found {
			users = append(users, auth.AuthUser{User: user, Pass: pass})
		}
	}
	cfg.General.Authentication = authentication
	cfg.Users = users
	authStore.Default.SetAuthenticator(auth.NewAuthenticator(users))
	if len(users) > 0 {
		// A loopback exemption would let any local app bypass the credentials.
		cfg.General.SkipAuthPrefixes = nil
		inbound.SetSkipAuthPrefixes(nil)
	}
}
