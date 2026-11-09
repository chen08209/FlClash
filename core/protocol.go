package core

import (
	"time"

	"github.com/metacubex/mihomo/adapter/provider"
	P "github.com/metacubex/mihomo/component/process"
	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/log"
	"github.com/metacubex/mihomo/tunnel"
)

type CoreMethod string

// Named area.verb. A method's arguments are an object or nothing, and a
// command answers null: whatever goes wrong is a MethodError.
const (
	coreInitMethod        CoreMethod = "core.init"
	coreInitializedMethod CoreMethod = "core.initialized"
	coreGCMethod          CoreMethod = "core.gc"
	coreMemoryMethod      CoreMethod = "core.memory"
	coreCrashMethod       CoreMethod = "core.crash"

	configSetupMethod    CoreMethod = "config.setup"
	configUpdateMethod   CoreMethod = "config.update"
	configValidateMethod CoreMethod = "config.validate"
	configDecryptMethod  CoreMethod = "config.decrypt"
	configReadMethod     CoreMethod = "config.read"

	profileBaseMethod        CoreMethod = "profile.base"
	profileOutboundsMethod   CoreMethod = "profile.outbounds"
	profileBuildMethod       CoreMethod = "profile.build"
	profileClearEffectMethod CoreMethod = "profile.clearEffect"

	proxyListMethod       CoreMethod = "proxy.list"
	proxySelectMethod     CoreMethod = "proxy.select"
	proxyDefinitionMethod CoreMethod = "proxy.definition"
	proxyTestDelayMethod  CoreMethod = "proxy.testDelay"
	proxyValidateMethod   CoreMethod = "proxy.validate"
	proxyConvertMethod    CoreMethod = "proxy.convert"
	shareLinkEncodeMethod CoreMethod = "shareLink.encode"
	shareLinkDecodeMethod CoreMethod = "shareLink.decode"
	filterValidateMethod  CoreMethod = "filter.validate"

	providerListMethod     CoreMethod = "provider.list"
	providerGetMethod      CoreMethod = "provider.get"
	providerUpdateMethod   CoreMethod = "provider.update"
	providerSideLoadMethod CoreMethod = "provider.sideLoad"
	ruleSetDumpMethod      CoreMethod = "ruleSet.dump"
	ruleSetCompileMethod   CoreMethod = "ruleSet.compile"
	geoUpdateMethod        CoreMethod = "geo.update"

	trafficCurrentMethod     CoreMethod = "traffic.current"
	trafficTotalMethod       CoreMethod = "traffic.total"
	trafficResetMethod       CoreMethod = "traffic.reset"
	connectionListMethod     CoreMethod = "connection.list"
	connectionCountMethod    CoreMethod = "connection.count"
	connectionCloseMethod    CoreMethod = "connection.close"
	connectionCloseAllMethod CoreMethod = "connection.closeAll"
	connectionResetMethod    CoreMethod = "connection.reset"
	dnsClearCacheMethod      CoreMethod = "dns.clearCache"
	networkChangedMethod     CoreMethod = "network.changed"

	logStartMethod      CoreMethod = "log.start"
	logStopMethod       CoreMethod = "log.stop"
	listenerStartMethod CoreMethod = "listener.start"
	listenerStopMethod  CoreMethod = "listener.stop"
	routeWatchMethod    CoreMethod = "route.watch"
	routeCheckMethod    CoreMethod = "route.check"

	probeOutboundIPMethod CoreMethod = "probe.outboundIp"
	probeServicesMethod   CoreMethod = "probe.services"

	mitmCertificateMethod         CoreMethod = "mitm.certificate"
	mitmGenerateCertificateMethod CoreMethod = "mitm.generateCertificate"
	mitmValidateMethod            CoreMethod = "mitm.validate"
	mitmIssueCertificateMethod    CoreMethod = "mitm.issueCertificate"
	mitmRunScriptMethod           CoreMethod = "mitm.runScript"
	mitmExchangesMethod           CoreMethod = "mitm.exchanges"
	mitmExchangeMethod            CoreMethod = "mitm.exchange"
	mitmBodyMethod                CoreMethod = "mitm.body"

	// The envelope of a batch of events, which the Core sends and never receives.
	messageMethod CoreMethod = "message"
)

type MessageType string

const (
	LogMessage       MessageType = "log"
	DelayMessage     MessageType = "delay"
	RequestMessage   MessageType = "request"
	DnsMessage       MessageType = "dns"
	LoadedMessage    MessageType = "loaded"
	GeoUpdateMessage MessageType = "geoUpdate"
	// Named after the Dart enum value, which is how CoreEvent.fromJson decodes it.
	RouteChangedMessage   MessageType = "routeChanged"
	DialerLoopMessage     MessageType = "dialerLoop"
	RequestTrafficMessage MessageType = "requestTraffic"
)

type Message struct {
	Type MessageType `json:"type"`
	Data any         `json:"data"`
}

type InitParams struct {
	HomeDir string `json:"home-dir"`
	Version int    `json:"version"`
}

type DecryptConfigParams struct {
	Path         string `json:"path"`
	AgeSecretKey string `json:"age-secret-key"`
}

type SetupParams struct {
	Base        *SetupBase        `json:"base,omitempty"`
	SelectedMap map[string]string `json:"selected-map"`
	Options     CoreOptions       `json:"options"`
}

type CoreOptions struct {
	// An empty one keeps the URL in force.
	TestURL        string `json:"test-url"`
	SkipCertVerify bool   `json:"skip-cert-verify"`
	// In milliseconds, for every delay test whose config names no timeout; zero
	// keeps the timeout in force.
	DelayTestTimeout int64 `json:"delay-test-timeout"`
	MITMCapture      bool  `json:"mitm-capture"`
}

type SetupBase struct {
	Path    string `json:"path"`
	Overlay string `json:"overlay"`
}

type ProfileBase struct {
	Config      *config.RawConfig `json:"config"`
	Digest      string            `json:"digest"`
	MatchRules  []string          `json:"match-rules"`
	Proxies     int               `json:"proxies"`
	ProxyGroups int               `json:"proxy-groups"`
	Rules       int               `json:"rules"`
}

type ProfileOutbounds struct {
	Proxies     []ProfileOutbound `json:"proxies"`
	ProxyGroups []ProfileOutbound `json:"proxy-groups"`
}

type ProfileOutbound struct {
	Name string `json:"name"`
	Type string `json:"type"`
}

type UpdateParams struct {
	Tun                *tunSchema         `json:"tun"`
	AllowLan           *bool              `json:"allow-lan"`
	MixedPort          *int               `json:"mixed-port"`
	FindProcessMode    *P.FindProcessMode `json:"find-process-mode"`
	Mode               *tunnel.TunnelMode `json:"mode"`
	LogLevel           *log.LogLevel      `json:"log-level"`
	IPv6               *bool              `json:"ipv6"`
	TCPConcurrent      *bool              `json:"tcp-concurrent"`
	ExternalController *string            `json:"external-controller"`
	Secret             *string            `json:"secret"`
	UnifiedDelay       *bool              `json:"unified-delay"`
	Authentication     *[]string          `json:"authentication"`
	GeoAutoUpdate      *bool              `json:"geo-auto-update"`
	GeoUpdateInterval  *int               `json:"geo-update-interval"`
	GeoXUrl            map[string]string  `json:"geox-url"`
	Options            *CoreOptions       `json:"options"`
}

type tunSchema struct {
	Enable    bool               `yaml:"enable" json:"enable"`
	Device    *string            `yaml:"device" json:"device"`
	Stack     *constant.TUNStack `yaml:"stack" json:"stack"`
	AutoRoute *bool              `yaml:"auto-route" json:"auto-route"`
}

type PathParams struct {
	Path string `json:"path"`
}

type NameParams struct {
	Name string `json:"name"`
}

type IDParams struct {
	ID string `json:"id"`
}

type WatchParams struct {
	Watch bool `json:"watch"`
}

type TrafficParams struct {
	OnlyProxy bool `json:"only-proxy"`
}

type ClearEffectParams struct {
	ProfileID int64 `json:"profile-id"`
}

type GeoUpdateParams struct {
	Type string `json:"type"`
}

type ProxiesParams struct {
	Proxies []map[string]any `json:"proxies"`
}

type LinesParams struct {
	Lines []string `json:"lines"`
}

type FiltersParams struct {
	Filters []string `json:"filters"`
}

type ValidationIssue struct {
	Index   int    `json:"index"`
	Message string `json:"message"`
}

type SideLoadParams struct {
	Name string `json:"name"`
	Data string `json:"data"`
}

type CompileRuleSetParams struct {
	Name string `json:"name"`
	URL  string `json:"url"`
}

type RuleSetInfo struct {
	Behavior string `json:"behavior"`
	Format   string `json:"format"`
}

type ChangeProxyParams struct {
	GroupName string `json:"group-name"`
	ProxyName string `json:"proxy-name"`
}

type ChangeProxyResult struct {
	Message string `json:"message"`
	Changed bool   `json:"changed"`
}

type RouteState struct {
	CoreEpoch    uint64 `json:"core-epoch"`
	RouteVersion uint64 `json:"route-version"`
}

type TestDelayParams struct {
	ProxyName string `json:"proxy-name"`
	TestUrl   string `json:"test-url"`
	Timeout   int64  `json:"timeout"`
}

type Delay struct {
	Url   string `json:"url"`
	Name  string `json:"name"`
	Value int32  `json:"value"`
}

type Traffic struct {
	Up   int64 `json:"up"`
	Down int64 `json:"down"`
}

type MemoryStats struct {
	Rss          uint64 `json:"rss"`
	HeapInuse    uint64 `json:"heap-inuse"`
	HeapIdle     uint64 `json:"heap-idle"`
	StackInuse   uint64 `json:"stack-inuse"`
	RuntimeOther uint64 `json:"runtime-other"`
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

type ProxiesData struct {
	Proxies map[string]any `json:"proxies"`
	All     []string       `json:"all"`
}

type nodeView struct {
	Name         string `json:"name"`
	Type         string `json:"type"`
	ProviderName string `json:"provider-name,omitempty"`
}

type GeoUpdateStatus struct {
	Type     string `json:"type"`
	Updating bool   `json:"updating"`
	Skipped  bool   `json:"skipped,omitempty"`
	Error    string `json:"error,omitempty"`
}
