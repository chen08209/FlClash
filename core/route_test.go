package core

import (
	"maps"
	"net/http"
	"path/filepath"
	"slices"
	"strings"
	"sync"
	"testing"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/outboundgroup"
	"github.com/metacubex/mihomo/adapter/provider"
	"github.com/metacubex/mihomo/component/resolver"
	"github.com/metacubex/mihomo/component/resource"
	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/constant"
	cp "github.com/metacubex/mihomo/constant/provider"
	"github.com/metacubex/mihomo/rules"
	rp "github.com/metacubex/mihomo/rules/provider"
	"github.com/metacubex/mihomo/tunnel"
)

type routeRecorder struct {
	mu     sync.Mutex
	states []RouteState
}

func (r *routeRecorder) record(state RouteState) {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.states = append(r.states, state)
}

func (r *routeRecorder) published() []RouteState {
	r.mu.Lock()
	defer r.mu.Unlock()
	return append([]RouteState(nil), r.states...)
}

func clearRoute() {
	stopRouteWatch()
	currentRoute.mu.Lock()
	defer currentRoute.mu.Unlock()
	currentRoute.epoch = 0
	currentRoute.version = 0
	currentRoute.picks = nil
	currentRoute.providerVersions = nil
	currentRoute.ruleSets = nil
	currentRoute.watchSeq = 0
}

func recordRoutes(t *testing.T) *routeRecorder {
	t.Helper()
	clearRoute()
	recorder := &routeRecorder{}
	previous := publishRoute
	publishRoute = recorder.record
	t.Cleanup(func() {
		clearRoute()
		publishRoute = previous
	})
	return recorder
}

func stampRoute(epoch, version uint64) {
	currentRoute.mu.Lock()
	defer currentRoute.mu.Unlock()
	currentRoute.epoch = epoch
	currentRoute.version = version
}

func currentPicks() map[string]string {
	currentRoute.mu.Lock()
	defer currentRoute.mu.Unlock()
	return maps.Clone(currentRoute.picks)
}

func selectorOver(t *testing.T, name string, members ...constant.Proxy) constant.Proxy {
	t.Helper()
	health := provider.NewHealthCheck(members, "", 0, 0, true, nil)
	pd, err := provider.NewCompatibleProvider(name+"-provider", members, health)
	if err != nil {
		t.Fatalf("NewCompatibleProvider: %v", err)
	}
	group, err := outboundgroup.NewSelector(
		outboundgroup.GroupCommonOption{Name: name},
		outboundgroup.SelectorOption{},
		nil,
		[]cp.ProxyProvider{pd},
	)
	if err != nil {
		t.Fatalf("NewSelector: %v", err)
	}
	return adapter.NewProxy(group)
}

func TestHandleChangeProxyReportsWhetherThePickMoved(t *testing.T) {
	recorder := recordRoutes(t)
	group := selectorGroup(t, "group", "node-a", "node-b")
	tunnel.UpdateProxies(map[string]constant.Proxy{"group": group}, nil)
	t.Cleanup(func() { tunnel.UpdateProxies(nil, nil) })

	state := handleWatchRoute(true, 0)
	if picks := currentPicks(); picks["group"] != "node-a" {
		t.Fatalf("picks = %v, want the group's first member before any selection", picks)
	}

	result := handleChangeProxy(&ChangeProxyParams{GroupName: "group", ProxyName: "node-b"})
	if result.Message != "" || !result.Changed {
		t.Fatalf("result = %+v, want a silent change", result)
	}
	published := recorder.published()
	if len(published) != 1 {
		t.Fatalf("published %d route states, want 1", len(published))
	}
	if currentPicks()["group"] != "node-b" || published[0] != (RouteState{CoreEpoch: state.CoreEpoch, RouteVersion: state.RouteVersion + 1}) {
		t.Errorf("published = %+v, want the new pick under the next version", published[0])
	}

	result = handleChangeProxy(&ChangeProxyParams{GroupName: "group", ProxyName: "node-b"})
	if result.Changed {
		t.Error("re-selecting the current node reported a change")
	}
	if len(recorder.published()) != 1 {
		t.Error("re-selecting the current node published a route state")
	}
}

func TestNestedGroupSwitchPublishesEveryPick(t *testing.T) {
	recorder := recordRoutes(t)
	nested := selectorGroup(t, "Nested", "HK-01", "HK-02")
	outer := selectorOver(t, "Proxy", nested, namedProxy("JP-01"))
	tunnel.UpdateProxies(map[string]constant.Proxy{"Proxy": outer, "Nested": nested}, nil)
	t.Cleanup(func() { tunnel.UpdateProxies(nil, nil) })
	handleWatchRoute(true, 0)

	handleChangeProxy(&ChangeProxyParams{GroupName: "Nested", ProxyName: "HK-02"})

	published := recorder.published()
	want := map[string]string{"Proxy": "Nested", "Nested": "HK-02"}
	if picks := currentPicks(); len(published) != 1 || !maps.Equal(picks, want) {
		t.Fatalf("published = %+v with picks %v, want one state with picks %v", published, picks, want)
	}
}

func TestRouteChangesSplitResetsFromMoves(t *testing.T) {
	recorder := recordRoutes(t)
	handleWatchRoute(true, 0)
	before := routeState()

	bumpRouteEpoch()
	if got := routeState(); got != (RouteState{CoreEpoch: before.CoreEpoch + 1, RouteVersion: before.RouteVersion + 1}) {
		t.Fatalf("state = %+v after an apply, want both counters advanced from %+v", got, before)
	}
	if len(recorder.published()) != 1 {
		t.Error("an apply did not publish the new epoch")
	}

	general := &config.General{}
	general.Mode = tunnel.Rule
	withCurrentConfig(t, &config.Config{General: general, Controller: &config.Controller{}})
	previousMode := tunnel.Mode()
	previousIPv6 := resolver.DisableIPv6
	t.Cleanup(func() {
		tunnel.SetMode(previousMode)
		resolver.DisableIPv6 = previousIPv6
	})
	global := tunnel.Global
	for range 2 {
		if err := updateConfig(&UpdateParams{Mode: &global}); err != nil {
			t.Fatalf("updateConfig: %v", err)
		}
	}
	if got := routeState(); got != (RouteState{CoreEpoch: before.CoreEpoch + 1, RouteVersion: before.RouteVersion + 2}) {
		t.Errorf("state = %+v after one mode switch, want it to move the route once", got)
	}

	ipv6 := !general.IPv6
	if err := updateConfig(&UpdateParams{IPv6: &ipv6}); err != nil {
		t.Fatalf("updateConfig: %v", err)
	}
	if got := routeState().CoreEpoch; got != before.CoreEpoch+2 {
		t.Errorf("epoch = %d after IPv6 changed, want %d", got, before.CoreEpoch+2)
	}
}

func TestStartingTheListenersAdvancesTheEpoch(t *testing.T) {
	recorder := recordRoutes(t)
	withCurrentConfig(t, nil)
	t.Cleanup(func() { isRunning.Store(false) })
	handleWatchRoute(true, 0)
	before := routeState().CoreEpoch

	handleStartListener()

	if got := routeState().CoreEpoch; got != before+1 {
		t.Errorf("epoch = %d after the listeners came up, want %d", got, before+1)
	}
	if len(recorder.published()) != 1 {
		t.Error("starting the listeners did not publish the new epoch")
	}
}

func TestProviderRefreshMovesTheRoute(t *testing.T) {
	recordRoutes(t)
	subscription := newCachingProvider("subscription", "node-a")
	withTunnelProviders(t, map[string]cp.ProxyProvider{"subscription": subscription}, nil)
	before := handleWatchRoute(true, 0)

	refreshRoute()
	if got := routeState(); got != before {
		t.Fatalf("state = %+v after a refresh without a provider change, want %+v", got, before)
	}

	subscription.setProxies("node-b")
	refreshRoute()
	if got := routeState(); got != (RouteState{CoreEpoch: before.CoreEpoch, RouteVersion: before.RouteVersion + 1}) {
		t.Errorf("state = %+v after the provider swapped its list, want only the version advanced", got)
	}
}

func TestRuleSetContentMovesTheRoute(t *testing.T) {
	recorder := recordRoutes(t)
	rp.SetTunnel(tunnel.Tunnel)
	ruleSet := rp.NewRuleSetProvider(
		"ruleset", cp.Domain, cp.YamlRule, 0,
		resource.NewFileVehicle(filepath.Join(t.TempDir(), "ruleset.yaml")),
		nil, nil, rules.ParseRule,
	).(*rp.RuleSetProvider)
	load := func(payload string) {
		t.Helper()
		if _, _, err := ruleSet.SideUpdate([]byte(payload)); err != nil {
			t.Fatalf("SideUpdate: %v", err)
		}
	}
	load("payload:\n  - example.com\n")
	withTunnelProviders(t, nil, map[string]cp.RuleProvider{"ruleset": ruleSet})
	before := handleWatchRoute(true, 0)

	load("payload:\n  - example.com\n")
	refreshRoute()
	if got := routeState(); got != before {
		t.Fatalf("state = %+v after the rule set reloaded the same content, want %+v", got, before)
	}

	load("payload:\n  - example.org\n")
	refreshRoute()
	want := RouteState{CoreEpoch: before.CoreEpoch, RouteVersion: before.RouteVersion + 1}
	if published := recorder.published(); len(published) != 1 || published[0] != want {
		t.Errorf("published = %+v, want %+v once", published, want)
	}
}

func TestProbeAnswersCarryTheRouteStamp(t *testing.T) {
	recordRoutes(t)
	stampRoute(7, 42)
	withProbeProxies(t, "node-a")
	server := probeServer(t, func(w http.ResponseWriter, _ *http.Request) {
		_, _ = w.Write([]byte("ip=203.0.113.7"))
	})

	answer := handleOutboundIp(&OutboundIpParams{ProxyName: "node-a", Urls: []string{server.URL}, Timeout: 4000})
	if answer.CoreEpoch != 7 || answer.RouteVersion != 42 {
		t.Errorf("outbound ip stamp = %d/%d, want 7/42", answer.CoreEpoch, answer.RouteVersion)
	}

	failed := handleOutboundIp(&OutboundIpParams{ProxyName: "node-a", Timeout: 1000})
	if failed.Error == "" || failed.CoreEpoch != 7 || failed.RouteVersion != 42 {
		t.Errorf("failed outbound ip = %+v, want an error stamped 7/42", failed)
	}

	withServiceCheckers(t, stubChecker("alpha", ServiceCheckItem{Status: serviceAvailable}))
	items := handleServiceCheck(&ServiceCheckParams{Timeout: 1000})
	if items[0].CoreEpoch != 7 || items[0].RouteVersion != 42 {
		t.Errorf("service check stamp = %d/%d, want 7/42", items[0].CoreEpoch, items[0].RouteVersion)
	}
}

func TestProbeAnswersCarryTheExitsTheyReached(t *testing.T) {
	recordRoutes(t)
	withProbeProxies(t, "DIRECT", "node-a")
	tunnel.OnRunning()
	t.Cleanup(tunnel.OnSuspend)
	server := probeServer(t, func(w http.ResponseWriter, _ *http.Request) {
		_, _ = w.Write([]byte("ip=203.0.113.7"))
	})
	host := strings.TrimPrefix(server.URL, "http://")

	routed := handleOutboundIp(&OutboundIpParams{Urls: []string{server.URL}, Timeout: 4000})
	want := []RouteHit{{Host: host, Exit: exitName(namedProxy("DIRECT"))}}
	if !slices.Equal(routed.Hits, want) {
		t.Errorf("routed hits = %+v, want %+v", routed.Hits, want)
	}

	server.Close()
	failed := handleOutboundIp(&OutboundIpParams{ProxyName: "node-a", Urls: []string{server.URL}, Timeout: 2000})
	want = []RouteHit{{Host: host, Proxy: "node-a", Exit: exitName(namedProxy("node-a"))}}
	if failed.Error == "" || !slices.Equal(failed.Hits, want) {
		t.Errorf("failed lookup = %+v, want an error that still names its exit %+v", failed, want)
	}

	missing := handleOutboundIp(&OutboundIpParams{ProxyName: "gone", Urls: []string{server.URL}, Timeout: 2000})
	want = []RouteHit{{Proxy: "gone"}}
	if !slices.Equal(missing.Hits, want) {
		t.Errorf("missing proxy hits = %+v, want %+v", missing.Hits, want)
	}
}

func TestRouteCheckFollowsTheRulesToTheExit(t *testing.T) {
	recordRoutes(t)
	group := selectorGroup(t, "Proxy", "node-a", "node-b")
	tunnel.UpdateProxies(map[string]constant.Proxy{"Proxy": group, "DIRECT": namedProxy("DIRECT")}, nil)
	domain, err := rules.ParseRule("DOMAIN", "example.com", "Proxy", nil, nil)
	if err != nil {
		t.Fatalf("ParseRule: %v", err)
	}
	tunnel.UpdateRules([]constant.Rule{domain}, nil, nil)
	previousMode := tunnel.Mode()
	tunnel.SetMode(tunnel.Rule)
	t.Cleanup(func() {
		tunnel.SetMode(previousMode)
		tunnel.UpdateProxies(nil, nil)
		tunnel.UpdateRules(nil, nil, nil)
	})
	handleWatchRoute(true, 0)

	proxied := RouteHit{Host: "example.com:443", Exit: exitName(namedProxy("node-a"))}
	direct := RouteHit{Host: "example.org:443", Exit: exitName(namedProxy("DIRECT"))}
	routes := [][]RouteHit{{proxied}, {direct}, {proxied, direct}, {}}
	check := handleCheckRoutes(&CheckRoutesParams{Routes: routes})
	if !slices.Equal(check.Held, []bool{true, true, true, false}) {
		t.Fatalf("held = %v, want every route with hits to hold", check.Held)
	}

	handleChangeProxy(&ChangeProxyParams{GroupName: "Proxy", ProxyName: "node-b"})
	check = handleCheckRoutes(&CheckRoutesParams{Routes: routes})
	if !slices.Equal(check.Held, []bool{false, true, false, false}) {
		t.Errorf("held = %v, want only the routes through the switched group to fall", check.Held)
	}
	if check.RouteVersion != routeState().RouteVersion {
		t.Errorf("check stamped %d, want the version it resolved under, %d", check.RouteVersion, routeState().RouteVersion)
	}
}

func TestRouteCheckKeepsAMissingProxyMissing(t *testing.T) {
	recordRoutes(t)
	withProbeProxies(t, "node-a")
	missing := [][]RouteHit{{{Proxy: "gone"}}}

	if check := handleCheckRoutes(&CheckRoutesParams{Routes: missing}); !slices.Equal(check.Held, []bool{true}) {
		t.Errorf("held = %v while the proxy is still missing, want it to hold", check.Held)
	}

	withProbeProxies(t, "node-a", "gone")
	if check := handleCheckRoutes(&CheckRoutesParams{Routes: missing}); !slices.Equal(check.Held, []bool{false}) {
		t.Errorf("held = %v once the proxy is back, want it to fall", check.Held)
	}
}

func balanceOver(t *testing.T, name string, members ...constant.Proxy) constant.Proxy {
	t.Helper()
	health := provider.NewHealthCheck(members, "", 0, 0, true, nil)
	pd, err := provider.NewCompatibleProvider(name+"-provider", members, health)
	if err != nil {
		t.Fatalf("NewCompatibleProvider: %v", err)
	}
	group, err := outboundgroup.NewLoadBalance(
		outboundgroup.GroupCommonOption{Name: name},
		outboundgroup.LoadBalanceOption{Strategy: "round-robin"},
		namedProxy("COMPATIBLE"),
		[]cp.ProxyProvider{pd},
	)
	if err != nil {
		t.Fatalf("NewLoadBalance: %v", err)
	}
	return adapter.NewProxy(group)
}

func TestALoadBalancerStandsAsTheExit(t *testing.T) {
	node := namedProxy("node-a")
	balance := balanceOver(t, "Balance", node, namedProxy("node-b"))
	outer := selectorOver(t, "Proxy", balance)
	tunnel.UpdateProxies(map[string]constant.Proxy{"Proxy": outer, "Balance": balance, "node-a": node}, nil)
	t.Cleanup(func() { tunnel.UpdateProxies(nil, nil) })

	want := exitName(balance)
	if got := exitOfChains([]string{"node-a", "Balance", "Proxy"}); got != want {
		t.Errorf("exit of a balanced chain = %q, want %q", got, want)
	}
	for range 3 {
		if got := resolveExit("example.com:443", "Proxy"); got != want {
			t.Fatalf("resolved exit = %q, want %q whichever member is next", got, want)
		}
	}
}

func TestTheOutermostLoadBalancerStandsAsTheExit(t *testing.T) {
	node := namedProxy("node-a")
	inner := balanceOver(t, "Inner", node, namedProxy("node-b"))
	balance := balanceOver(t, "Outer", inner, namedProxy("node-c"))
	outer := selectorOver(t, "Proxy", balance)
	tunnel.UpdateProxies(map[string]constant.Proxy{"Proxy": outer, "Outer": balance, "Inner": inner, "node-a": node}, nil)
	t.Cleanup(func() { tunnel.UpdateProxies(nil, nil) })

	want := exitName(balance)
	if got := exitOfChains([]string{"node-a", "Inner", "Outer", "Proxy"}); got != want {
		t.Errorf("exit of a nested balanced chain = %q, want %q", got, want)
	}
	if got := resolveExit("example.com:443", "Proxy"); got != want {
		t.Errorf("resolved exit = %q, want %q", got, want)
	}
}

func TestTheNodeUnderALoadBalancerHoldsOnItsOwn(t *testing.T) {
	recordRoutes(t)
	node := namedProxy("node-a")
	balance := balanceOver(t, "Balance", node, namedProxy("node-b"))
	outer := selectorOver(t, "Proxy", balance)
	tunnel.UpdateProxies(map[string]constant.Proxy{"Proxy": outer, "Balance": balance, "node-a": node}, nil)
	t.Cleanup(func() { tunnel.UpdateProxies(nil, nil) })

	hits := []RouteHit{{Host: "example.com:443", Proxy: "Proxy", Exit: exitName(balance)}}
	through := nodeHits([]string{"node-a", "Balance", "Proxy"}, "Proxy", hits)
	want := []RouteHit{{Host: "example.com:443", Proxy: "node-a", Exit: exitName(node)}}
	if !slices.Equal(through, want) {
		t.Fatalf("node hits = %+v, want %+v", through, want)
	}
	check := handleCheckRoutes(&CheckRoutesParams{Routes: [][]RouteHit{hits, through}})
	if !slices.Equal(check.Held, []bool{true, true}) {
		t.Errorf("held = %v, want the target and its node to hold", check.Held)
	}
	if got := nodeHits([]string{"node-a"}, "node-a", hits); got != nil {
		t.Errorf("hits of a node asked for itself = %+v, want none", got)
	}
}

func TestWatchRoutePollsOnlyWhileWatched(t *testing.T) {
	recordRoutes(t)

	handleWatchRoute(true, 0)
	currentRoute.mu.Lock()
	polling := currentRoute.stopPoll != nil
	currentRoute.mu.Unlock()
	if !polling {
		t.Fatal("watching the route did not start the poll")
	}

	handleWatchRoute(false, 0)
	currentRoute.mu.Lock()
	polling = currentRoute.stopPoll != nil
	watched := currentRoute.watched
	currentRoute.mu.Unlock()
	if polling || watched {
		t.Error("releasing the route left the poll running")
	}
}

func TestWatchRouteIgnoresAnOlderIntent(t *testing.T) {
	recordRoutes(t)

	handleWatchRoute(false, 2)
	handleWatchRoute(true, 1)
	currentRoute.mu.Lock()
	polling := currentRoute.stopPoll != nil
	watched := currentRoute.watched
	currentRoute.mu.Unlock()
	if polling || watched {
		t.Error("a watch overtaken by a later release restarted the poll")
	}
}

func TestStopRouteWatchOutranksEarlierWatches(t *testing.T) {
	recordRoutes(t)
	previous := methodCallSeq.Load()
	t.Cleanup(func() { methodCallSeq.Store(previous) })
	methodCallSeq.Store(previous + 5)

	stopRouteWatch()
	for _, seq := range []uint64{previous + 4, previous + 5} {
		handleWatchRoute(true, seq)
		currentRoute.mu.Lock()
		polling := currentRoute.stopPoll != nil
		currentRoute.mu.Unlock()
		if polling {
			t.Fatalf("watch %d, dispatched before the stop, restarted the poll", seq-previous)
		}
	}

	handleWatchRoute(true, methodCallSeq.Add(1))
	currentRoute.mu.Lock()
	polling := currentRoute.stopPoll != nil
	currentRoute.mu.Unlock()
	handleWatchRoute(false, methodCallSeq.Add(1))
	if !polling {
		t.Error("a watch issued after the stop was ignored")
	}
}
