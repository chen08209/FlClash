package main

import "C"
import (
	"github.com/metacubex/mihomo/adapter/inbound"
	"github.com/metacubex/mihomo/component/dialer"
	"github.com/metacubex/mihomo/component/process"
	"github.com/metacubex/mihomo/component/resolver"
	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/dns"
	"github.com/metacubex/mihomo/hub/executor"
	"github.com/metacubex/mihomo/listener"
	"github.com/metacubex/mihomo/log"
	"github.com/metacubex/mihomo/tunnel"
	"os"
	"os/exec"
	"runtime"
	"syscall"
)

type GenerateConfigParams struct {
	ProfilePath *string           `json:"profile-path"`
	Config      *config.RawConfig `json:"config" `
	IsPatch     *bool             `json:"is-patch"`
}

type ChangeProxyParams struct {
	GroupName *string `json:"group-name"`
	ProxyName *string `json:"proxy-name"`
}

type TestDelayParams struct {
	ProxyName string `json:"proxy-name"`
	Timeout   int64  `json:"timeout"`
}

type Delay struct {
	Name  string `json:"name"`
	Value int32  `json:"value"`
}

type Process struct {
	Uid     uint32 `json:"uid"`
	Network string `json:"network"`
	Source  string `json:"source"`
	Target  string `json:"target"`
}

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

func getRawConfigWithPath(path *string) *config.RawConfig {
	if path == nil {
		return config.DefaultRawConfig()
	} else {
		bytes, err := readFile(*path)
		if err != nil {
			log.Errorln("getProfile readFile error %v", err)
			return config.DefaultRawConfig()
		}
		prof, err := config.UnmarshalRawConfig(bytes)
		if err != nil {
			log.Errorln("getProfile UnmarshalRawConfig error %v", err)
			return config.DefaultRawConfig()
		}
		return prof
	}
}

func decorationConfig(profilePath *string, cfg config.RawConfig) *config.RawConfig {
	prof := getRawConfigWithPath(profilePath)
	overwriteConfig(prof, cfg)
	return prof
}

func overwriteConfig(targetConfig *config.RawConfig, patchConfig config.RawConfig) {
	targetConfig.ExternalController = ""
	targetConfig.ExternalUI = ""
	targetConfig.Interface = ""
	targetConfig.ExternalUIURL = ""
	targetConfig.IPv6 = patchConfig.IPv6
	targetConfig.LogLevel = patchConfig.LogLevel
	targetConfig.FindProcessMode = process.FindProcessAlways
	targetConfig.AllowLan = patchConfig.AllowLan
	targetConfig.MixedPort = patchConfig.MixedPort
	targetConfig.Mode = patchConfig.Mode
	targetConfig.Tun.Enable = patchConfig.Tun.Enable
	targetConfig.Tun.Device = patchConfig.Tun.Device
	targetConfig.Tun.DNSHijack = patchConfig.Tun.DNSHijack
	targetConfig.Tun.Stack = patchConfig.Tun.Stack
	targetConfig.Profile.StoreSelected = false
	if targetConfig.DNS.Enable == false {
		targetConfig.DNS = patchConfig.DNS
	} else {
		targetConfig.DNS.UseHosts = patchConfig.DNS.UseHosts
		targetConfig.DNS.EnhancedMode = patchConfig.DNS.EnhancedMode
		targetConfig.DNS.IPv6 = patchConfig.DNS.IPv6
		targetConfig.DNS.DefaultNameserver = append(patchConfig.DNS.DefaultNameserver, targetConfig.DNS.DefaultNameserver...)
		targetConfig.DNS.NameServer = append(patchConfig.DNS.NameServer, targetConfig.DNS.NameServer...)
		targetConfig.DNS.FakeIPFilter = append(patchConfig.DNS.FakeIPFilter, targetConfig.DNS.FakeIPFilter...)
		targetConfig.DNS.Fallback = append(patchConfig.DNS.Fallback, targetConfig.DNS.Fallback...)
		if runtime.GOOS == "android" {
			targetConfig.DNS.NameServer = append(targetConfig.DNS.NameServer, "dhcp://"+dns.SystemDNSPlaceholder)
		} else if runtime.GOOS == "windows" {
			targetConfig.DNS.NameServer = append(targetConfig.DNS.NameServer, dns.SystemDNSPlaceholder)
		}
	}
}

func patchConfig(general *config.General) {
	log.Infoln("[Apply] patch")
	listener.SetAllowLan(general.AllowLan)
	inbound.SetSkipAuthPrefixes(general.SkipAuthPrefixes)
	inbound.SetAllowedIPs(general.LanAllowedIPs)
	inbound.SetDisAllowedIPs(general.LanDisAllowedIPs)
	listener.SetBindAddress(general.BindAddress)
	tunnel.SetSniffing(general.Sniffing)
	dialer.SetTcpConcurrent(general.TCPConcurrent)
	dialer.DefaultInterface.Store(general.Interface)
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

func applyConfig(isPatch bool) {
	cfg, err := config.ParseRawConfig(currentConfig)
	if err != nil {
		cfg, _ = config.ParseRawConfig(config.DefaultRawConfig())
	}
	if isPatch {
		patchConfig(cfg.General)
	} else {
		executor.ApplyConfig(cfg, true)
	}
}
