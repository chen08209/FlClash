package main

import (
	"maps"
	"net/http"
	"path/filepath"
	"sync"
	"testing"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/outboundgroup"
	"github.com/metacubex/mihomo/adapter/provider"
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
	currentRoute.picksVersion = 0
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

func stampRoute(epoch, picksVersion uint64) {
	currentRoute.mu.Lock()
	defer currentRoute.mu.Unlock()
	currentRoute.epoch = epoch
	currentRoute.picksVersion = picksVersion
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
	if state.Picks["group"] != "node-a" {
		t.Fatalf("picks = %v, want the group's first member before any selection", state.Picks)
	}

	result := handleChangeProxy(&ChangeProxyParams{GroupName: "group", ProxyName: "node-b"})
	if result.Message != "" || !result.Changed {
		t.Fatalf("result = %+v, want a silent change", result)
	}
	published := recorder.published()
	if len(published) != 1 {
		t.Fatalf("published %d route states, want 1", len(published))
	}
	if published[0].Picks["group"] != "node-b" || published[0].PicksVersion != state.PicksVersion+1 {
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
	if len(published) != 1 || !maps.Equal(published[0].Picks, want) {
		t.Fatalf("published = %+v, want one state with picks %v", published, want)
	}
}

func TestRouteEpochFollowsStructuralChanges(t *testing.T) {
	recorder := recordRoutes(t)
	handleWatchRoute(true, 0)
	before := routeState().CoreEpoch

	bumpRouteEpoch()
	if got := routeState().CoreEpoch; got != before+1 {
		t.Fatalf("epoch = %d after an apply, want %d", got, before+1)
	}
	if len(recorder.published()) != 1 {
		t.Error("an apply did not publish the new epoch")
	}

	general := &config.General{}
	general.Mode = tunnel.Rule
	withCurrentConfig(t, &config.Config{General: general, Controller: &config.Controller{}})
	global := tunnel.Global
	if err := updateConfig(&UpdateParams{Mode: &global}); err != nil {
		t.Fatalf("updateConfig: %v", err)
	}
	if got := routeState().CoreEpoch; got != before+2 {
		t.Errorf("epoch = %d after a mode switch, want %d", got, before+2)
	}
	if err := updateConfig(&UpdateParams{Mode: &global}); err != nil {
		t.Fatalf("updateConfig: %v", err)
	}
	if got := routeState().CoreEpoch; got != before+2 {
		t.Errorf("epoch = %d after an unchanged mode, want it left at %d", got, before+2)
	}
}

func TestProviderRefreshAdvancesTheEpoch(t *testing.T) {
	recordRoutes(t)
	subscription := newCachingProvider("subscription", "node-a")
	withTunnelProviders(t, map[string]cp.ProxyProvider{"subscription": subscription}, nil)
	before := handleWatchRoute(true, 0).CoreEpoch

	refreshRoute()
	if got := routeState().CoreEpoch; got != before {
		t.Fatalf("epoch = %d after a refresh without a provider change, want %d", got, before)
	}

	subscription.setProxies("node-b")
	refreshRoute()
	if got := routeState().CoreEpoch; got != before+1 {
		t.Errorf("epoch = %d after the provider swapped its list, want %d", got, before+1)
	}
}

func TestRuleSetContentAdvancesTheEpoch(t *testing.T) {
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
	before := handleWatchRoute(true, 0).CoreEpoch

	load("payload:\n  - example.com\n")
	refreshRoute()
	if got := routeState().CoreEpoch; got != before {
		t.Fatalf("epoch = %d after the rule set reloaded the same content, want %d", got, before)
	}

	load("payload:\n  - example.org\n")
	refreshRoute()
	if got := routeState().CoreEpoch; got != before+1 {
		t.Errorf("epoch = %d after the rule set loaded new content, want %d", got, before+1)
	}
	if published := recorder.published(); len(published) != 1 || published[0].CoreEpoch != before+1 {
		t.Errorf("published = %+v, want the new epoch once", published)
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
	if answer.CoreEpoch != 7 || answer.PicksVersion != 42 {
		t.Errorf("outbound ip stamp = %d/%d, want 7/42", answer.CoreEpoch, answer.PicksVersion)
	}

	failed := handleOutboundIp(&OutboundIpParams{ProxyName: "node-a", Timeout: 1000})
	if failed.Error == "" || failed.CoreEpoch != 7 || failed.PicksVersion != 42 {
		t.Errorf("failed outbound ip = %+v, want an error stamped 7/42", failed)
	}

	withServiceCheckers(t, stubChecker("alpha", ServiceCheckItem{Status: serviceAvailable}))
	items := handleServiceCheck(&ServiceCheckParams{Timeout: 1000})
	if items[0].CoreEpoch != 7 || items[0].PicksVersion != 42 {
		t.Errorf("service check stamp = %d/%d, want 7/42", items[0].CoreEpoch, items[0].PicksVersion)
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
	handleWatchRoute(true, previous+4)
	currentRoute.mu.Lock()
	polling := currentRoute.stopPoll != nil
	currentRoute.mu.Unlock()
	if polling {
		t.Fatal("a watch issued before the stop restarted the poll")
	}

	handleWatchRoute(true, previous+6)
	currentRoute.mu.Lock()
	polling = currentRoute.stopPoll != nil
	currentRoute.mu.Unlock()
	handleWatchRoute(false, previous+7)
	if !polling {
		t.Error("a watch issued after the stop was ignored")
	}
}
