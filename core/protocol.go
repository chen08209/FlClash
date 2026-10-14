package core

import (
	"net/netip"
	"time"

	"github.com/metacubex/http"
	"github.com/metacubex/mihomo/adapter/provider"
	P "github.com/metacubex/mihomo/component/process"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/log"
	"github.com/metacubex/mihomo/tunnel"
)

type CoreMethod string

const (
	messageMethod                  CoreMethod = "message"
	initClashMethod                CoreMethod = "initClash"
	getIsInitMethod                CoreMethod = "getIsInit"
	forceGcMethod                  CoreMethod = "forceGc"
	shutdownMethod                 CoreMethod = "shutdown"
	validateConfigMethod           CoreMethod = "validateConfig"
	decryptConfigMethod            CoreMethod = "decryptConfig"
	validateProxiesMethod          CoreMethod = "validateProxies"
	validateFiltersMethod          CoreMethod = "validateFilters"
	convertProxiesMethod           CoreMethod = "convertProxies"
	encodeShareLinksMethod         CoreMethod = "encodeShareLinks"
	decodeShareLinksMethod         CoreMethod = "decodeShareLinks"
	updateConfigMethod             CoreMethod = "updateConfig"
	getProxiesMethod               CoreMethod = "getProxies"
	changeProxyMethod              CoreMethod = "changeProxy"
	getTrafficMethod               CoreMethod = "getTraffic"
	getTotalTrafficMethod          CoreMethod = "getTotalTraffic"
	resetTrafficMethod             CoreMethod = "resetTraffic"
	asyncTestDelayMethod           CoreMethod = "asyncTestDelay"
	probeMethod                    CoreMethod = "probe"
	outboundIpMethod               CoreMethod = "outboundIp"
	serviceCheckMethod             CoreMethod = "serviceCheck"
	getConnectionsMethod           CoreMethod = "getConnections"
	getConnectionCountMethod       CoreMethod = "getConnectionCount"
	closeConnectionsMethod         CoreMethod = "closeConnections"
	resetConnectionsMethod         CoreMethod = "resetConnections"
	closeConnectionMethod          CoreMethod = "closeConnection"
	getExternalProvidersMethod     CoreMethod = "getExternalProviders"
	getExternalProviderMethod      CoreMethod = "getExternalProvider"
	getMemoryStatsMethod           CoreMethod = "getMemoryStats"
	updateGeoDataMethod            CoreMethod = "updateGeoData"
	updateExternalProviderMethod   CoreMethod = "updateExternalProvider"
	sideLoadExternalProviderMethod CoreMethod = "sideLoadExternalProvider"
	startLogMethod                 CoreMethod = "startLog"
	stopLogMethod                  CoreMethod = "stopLog"
	startListenerMethod            CoreMethod = "startListener"
	stopListenerMethod             CoreMethod = "stopListener"
	updateDnsMethod                CoreMethod = "updateDns"
	crashMethod                    CoreMethod = "crash"
	setupConfigMethod              CoreMethod = "setupConfig"
	getConfigMethod                CoreMethod = "getConfig"
	dumpRuleSetMethod              CoreMethod = "dumpRuleSet"
	compileRuleSetMethod           CoreMethod = "compileRuleSet"
	clearEffectMethod              CoreMethod = "clearEffect"
	watchRouteMethod               CoreMethod = "watchRoute"
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
	RouteChangedMessage MessageType = "routeChanged"
	DialerLoopMessage   MessageType = "dialerLoop"
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
	SelectedMap    map[string]string `json:"selected-map"`
	TestURL        string            `json:"test-url"`
	SkipCertVerify bool              `json:"skip-cert-verify"`
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
	SkipCertVerify     *bool              `json:"skip-cert-verify"`
}

type tunSchema struct {
	Enable               bool               `yaml:"enable" json:"enable"`
	Device               *string            `yaml:"device" json:"device"`
	Stack                *constant.TUNStack `yaml:"stack" json:"stack"`
	DNSHijack            *[]string          `yaml:"dns-hijack" json:"dns-hijack"`
	AutoRoute            *bool              `yaml:"auto-route" json:"auto-route"`
	RouteAddress         *[]netip.Prefix    `yaml:"route-address" json:"route-address,omitempty"`
	MTU                  *uint32            `yaml:"mtu" json:"mtu"`
	CongestionController *string            `yaml:"congestion-controller" json:"congestion-controller"`
	StrictRoute          *bool              `yaml:"strict-route" json:"strict-route"`
	RouteExcludeAddress  *[]netip.Prefix    `yaml:"route-exclude-address" json:"route-exclude-address"`
}

type SideLoadParams struct {
	ProviderName string `json:"providerName"`
	Data         string `json:"data"`
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
	CoreEpoch    uint64            `json:"core-epoch"`
	PicksVersion uint64            `json:"picks-version"`
	Picks        map[string]string `json:"picks"`
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

type ProbeParams struct {
	Url       string            `json:"url"`
	ProxyName string            `json:"proxy-name"`
	Headers   map[string]string `json:"headers"`
	Timeout   int64             `json:"timeout"`
	MaxBody   int64             `json:"max-body"`
}

type ProbeResult struct {
	StatusCode  int      `json:"status-code"`
	Delay       int64    `json:"delay"`
	Body        string   `json:"body"`
	Url         string   `json:"url"`
	Chains      []string `json:"chains"`
	Rule        string   `json:"rule"`
	RulePayload string   `json:"rule-payload"`
	Error       string   `json:"error,omitempty"`
	Message     string   `json:"message,omitempty"`

	CoreEpoch    uint64 `json:"core-epoch"`
	PicksVersion uint64 `json:"picks-version"`

	// Unexported, so it never reaches Dart: only the in-core checks read
	// response headers, and ProbeResult is the shape the Dart side decodes.
	header    http.Header
	lowerBody string
}

type Traffic struct {
	Up   int64 `json:"up"`
	Down int64 `json:"down"`
}

type MemoryStats struct {
	Rss          uint64 `json:"rss"`
	HeapInuse    uint64 `json:"heapInuse"`
	HeapIdle     uint64 `json:"heapIdle"`
	StackInuse   uint64 `json:"stackInuse"`
	RuntimeOther uint64 `json:"runtimeOther"`
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
	Name string `json:"name"`
	Type string `json:"type"`
}

type GeoUpdateStatus struct {
	Type     string `json:"type"`
	Updating bool   `json:"updating"`
	Skipped  bool   `json:"skipped,omitempty"`
	Error    string `json:"error,omitempty"`
}
