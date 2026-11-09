package core

import (
	"encoding/json"
	"errors"
	"fmt"
	"maps"
	"os"
	"strings"
	"sync"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/outboundgroup"
	"github.com/metacubex/mihomo/adapter/provider"
	"github.com/metacubex/mihomo/common/convert"
	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/log"
	"github.com/metacubex/mihomo/tunnel"
)

const globalProxyName = "GLOBAL"

var (
	// Selection writes need the mutual exclusion mihomo's Selector.Set lacks.
	// The lock order is configMu -> selectMu.
	selectMu sync.Mutex

	errGroupNotFound    = errors.New("Not found group")
	errGroupInvalidType = errors.New("Group has invalid proxy type")
	errGroupNotSelect   = errors.New("Group is not selectable")
)

type pickableGroup interface {
	outboundgroup.ProxyGroup
	outboundgroup.SelectAble
}

func lookupProxy(name string) constant.Proxy {
	return tunnel.AllProxies()[name]
}

func adapterAs[T any](proxy constant.Proxy) (group T, ok bool) {
	outbound, ok := proxy.(*adapter.Proxy)
	if !ok {
		return group, false
	}
	group, ok = outbound.ProxyAdapter.(T)
	return group, ok
}

func isProxyGroupType(adapterType constant.AdapterType) bool {
	switch adapterType {
	case constant.Selector, constant.URLTest, constant.Fallback, constant.Relay, constant.LoadBalance:
		return true
	default:
		return false
	}
}

func proxyGroupNames(
	nameList []string,
	typeOf func(name string) (constant.AdapterType, bool),
) []string {
	isGroup := func(name string) bool {
		adapterType, ok := typeOf(name)
		return ok && isProxyGroupType(adapterType)
	}

	hasGlobal := false
	names := make([]string, 0, len(nameList)+1)
	for _, name := range nameList {
		if name == globalProxyName {
			hasGlobal = true
		}
		if isGroup(name) {
			names = append(names, name)
		}
	}
	if !hasGlobal && isGroup(globalProxyName) {
		names = append([]string{globalProxyName}, names...)
	}
	return names
}

func handleGetProxies() ProxiesData {
	proxies := tunnel.AllProxies()

	names := proxyGroupNames(config.GetProxyNameList(), func(name string) (constant.AdapterType, bool) {
		p, ok := proxies[name]
		if !ok || p == nil {
			return 0, false
		}
		return p.Type(), true
	})

	views := make(map[string]any, len(proxies))
	for name, proxy := range proxies {
		views[name] = proxyView(proxy)
	}
	return ProxiesData{All: names, Proxies: views}
}

// Proxy.MarshalJSON encodes each node twice, with history the host never reads.
func proxyView(proxy constant.Proxy) any {
	node := nodeView{
		Name:         proxy.Name(),
		Type:         proxy.Type().String(),
		ProviderName: proxy.ProxyInfo().ProviderName,
	}
	if !isProxyGroupType(proxy.Type()) {
		return node
	}
	view, err := groupView(proxy)
	if err != nil {
		log.Warnln("[APP] encode group %s: %v", node.Name, err)
		return node
	}
	return view
}

// No group encodes its own name, so it is appended rather than re-encoded.
func groupView(proxy constant.Proxy) (json.RawMessage, error) {
	data, err := proxy.Adapter().MarshalJSON()
	if err != nil {
		return nil, err
	}
	if isBuiltInGlobal(proxy) {
		view := map[string]any{}
		if err := json.Unmarshal(data, &view); err != nil {
			return nil, err
		}
		view["hidden"] = true
		if data, err = json.Marshal(view); err != nil {
			return nil, err
		}
	}
	if len(data) < 2 || data[0] != '{' || data[len(data)-1] != '}' {
		return nil, fmt.Errorf("encoding is not an object: %.32s", data)
	}
	name, err := json.Marshal(proxy.Name())
	if err != nil {
		return nil, err
	}
	view := make(json.RawMessage, 0, len(data)+len(name)+len(`,"name":`))
	view = append(view, data[:len(data)-1]...)
	if len(data) > 2 {
		view = append(view, ',')
	}
	view = append(view, `"name":`...)
	view = append(view, name...)
	return append(view, '}'), nil
}

// mihomo builds its own GLOBAL over the reserved provider, which no configured
// group can use; a GLOBAL group from the config takes its place.
func isBuiltInGlobal(proxy constant.Proxy) bool {
	group, ok := proxy.Adapter().(outboundgroup.ProxyGroup)
	if !ok || proxy.Name() != globalProxyName {
		return false
	}
	for _, pd := range group.Providers() {
		if pd.Name() == provider.ReservedName {
			return true
		}
	}
	return false
}

func selectableGroup(groupName string) (pickableGroup, error) {
	group := lookupProxy(groupName)
	if group == nil {
		return nil, errGroupNotFound
	}
	adapterProxy, ok := group.(*adapter.Proxy)
	if !ok {
		return nil, errGroupInvalidType
	}
	selector, ok := adapterProxy.ProxyAdapter.(pickableGroup)
	if !ok {
		return nil, errGroupNotSelect
	}
	return selector, nil
}

func handleChangeProxy(params *ChangeProxyParams) *ChangeProxyResult {
	selectMu.Lock()
	defer selectMu.Unlock()

	selector, err := selectableGroup(params.GroupName)
	if err != nil {
		return &ChangeProxyResult{Message: err.Error()}
	}
	before := selector.Now()
	if params.ProxyName == "" {
		selector.ForceSet(params.ProxyName)
	} else if err := selector.Set(params.ProxyName); err != nil {
		return &ChangeProxyResult{Message: err.Error()}
	}
	changed := selector.Now() != before
	refreshRouteLocked(routeUnchanged)
	return &ChangeProxyResult{Changed: changed}
}

func patchSelectGroup(mapping map[string]string) {
	selectMu.Lock()
	defer selectMu.Unlock()
	proxies := tunnel.AllProxies()
	for name, selected := range mapping {
		if selector, ok := adapterAs[outboundgroup.SelectAble](proxies[name]); ok {
			selector.ForceSet(selected)
		}
	}
}

// Tailscale and EasyTier register a DNS client under the proxy name when built
// and drop that name's entry on Close, so a probe under the real name would
// take the resolver from a running proxy of the same name.
const validationNameSuffix = "\x00validate"

// The per-proxy parser the config load runs; checks across proxies, such as
// duplicate names, are left to the load itself.
func handleValidateProxies(params ProxiesParams) []ValidationIssue {
	issues := []ValidationIssue{}
	for i, mapping := range params.Proxies {
		name, _ := mapping["name"].(string)
		probe := mapping
		switch mapping["type"] {
		case "tailscale", "easytier":
			probe = maps.Clone(mapping)
			probe["name"] = name + validationNameSuffix
		}
		proxy, err := adapter.ParseProxy(probe)
		if err != nil {
			issues = append(issues, ValidationIssue{Index: i, Message: strings.ReplaceAll(err.Error(), validationNameSuffix, "")})
			continue
		}
		_ = proxy.Close()
	}
	return issues
}

// The share-link list a proxy provider also accepts, plain or base64.
func handleConvertProxies(params PathParams) ([]map[string]any, error) {
	buf, err := os.ReadFile(params.Path)
	if err != nil {
		return nil, err
	}
	return convert.ConvertsV2Ray(buf)
}
