package core

import (
	"context"
	"fmt"
	"maps"
	"slices"
	"sync"
	"time"

	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"
)

// mihomo has no hook for a health check moving a URLTest or Fallback pick, so
// the picks are re-read on this timer while the host watches.
const routePollInterval = time.Second

// An answer outlives a move while the hosts it reached keep their exits.
type routeChange int

const (
	routeUnchanged routeChange = iota
	routeMoved
	routeReset
)

type routeTracker struct {
	mu               sync.Mutex
	epoch            uint64
	version          uint64
	picks            map[string]string
	providerVersions map[string]uint32
	ruleSets         map[string]any
	watched          bool
	watchSeq         uint64
	stopPoll         context.CancelFunc
}

var (
	currentRoute routeTracker

	publishRoute = func(state RouteState) {
		sendMessage(RouteChangedMessage, state)
	}
)

func routeStateLocked() RouteState {
	return RouteState{
		CoreEpoch:    currentRoute.epoch,
		RouteVersion: currentRoute.version,
	}
}

func routeState() RouteState {
	currentRoute.mu.Lock()
	defer currentRoute.mu.Unlock()
	return routeStateLocked()
}

func routeStamp() (epoch, version uint64) {
	currentRoute.mu.Lock()
	defer currentRoute.mu.Unlock()
	return currentRoute.epoch, currentRoute.version
}

func readPicks() (map[string]string, map[string]uint32) {
	picks := map[string]string{}
	for name, proxy := range tunnel.AllProxies() {
		if group, ok := adapterAs[pickableGroup](proxy); ok {
			picks[name] = group.Now()
		}
	}
	providers := tunnel.ProvidersSnapshot()
	versions := make(map[string]uint32, len(providers))
	for name, p := range providers {
		versions[name] = p.Version()
	}
	return picks, versions
}

// mihomo swaps in a new strategy each time a rule set, manually or on its
// interval, loads new content.
func readRuleSets() map[string]any {
	providers := tunnel.RuleProvidersSnapshot()
	ruleSets := make(map[string]any, len(providers))
	for name, p := range providers {
		ruleSets[name] = p.Strategy()
	}
	return ruleSets
}

func refreshRouteLocked(change routeChange) {
	picks, versions := readPicks()
	ruleSets := readRuleSets()

	currentRoute.mu.Lock()
	if currentRoute.providerVersions != nil && !maps.Equal(versions, currentRoute.providerVersions) ||
		currentRoute.ruleSets != nil && !maps.Equal(ruleSets, currentRoute.ruleSets) ||
		!maps.Equal(picks, currentRoute.picks) {
		change = max(change, routeMoved)
	}
	currentRoute.providerVersions = versions
	currentRoute.ruleSets = ruleSets
	currentRoute.picks = picks
	if change == routeReset {
		currentRoute.epoch++
	}
	if change == routeUnchanged {
		currentRoute.mu.Unlock()
		return
	}
	currentRoute.version++
	if !currentRoute.watched {
		currentRoute.mu.Unlock()
		return
	}
	state := routeStateLocked()
	currentRoute.mu.Unlock()
	publishRoute(state)
}

func changeRoute(change routeChange) {
	selectMu.Lock()
	defer selectMu.Unlock()
	refreshRouteLocked(change)
}

func refreshRoute() {
	changeRoute(routeUnchanged)
}

func bumpRouteEpoch() {
	changeRoute(routeReset)
}

func handleWatchRoute(watch bool, seq uint64) RouteState {
	refreshRoute()

	currentRoute.mu.Lock()
	defer currentRoute.mu.Unlock()
	if seq < currentRoute.watchSeq {
		return routeStateLocked()
	}
	currentRoute.watchSeq = seq
	currentRoute.watched = watch
	if watch && currentRoute.stopPoll == nil {
		ctx, cancel := context.WithCancel(context.Background())
		currentRoute.stopPoll = cancel
		go pollRoute(ctx)
	}
	if !watch {
		stopRoutePollLocked()
	}
	return routeStateLocked()
}

// The stop takes its own place in the call order: a watch dispatched before
// it, the newest one included, may still be waiting to run.
func stopRouteWatch() {
	currentRoute.mu.Lock()
	defer currentRoute.mu.Unlock()
	currentRoute.watchSeq = max(currentRoute.watchSeq, methodCallSeq.Add(1))
	currentRoute.watched = false
	stopRoutePollLocked()
}

func stopRoutePollLocked() {
	if currentRoute.stopPoll != nil {
		currentRoute.stopPoll()
		currentRoute.stopPoll = nil
	}
}

// With the listeners down the host pins every probe to DIRECT, so the picks
// do not matter until they come back.
func pollRoute(ctx context.Context) {
	ticker := time.NewTicker(routePollInterval)
	defer ticker.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			if isRunning.Load() {
				refreshRoute()
			}
		}
	}
}

type RouteHit struct {
	Host  string `json:"host"`
	Proxy string `json:"proxy,omitempty"`
	Exit  string `json:"exit"`
}

type CheckRoutesParams struct {
	Routes [][]RouteHit `json:"routes"`
}

type RouteCheck struct {
	CoreEpoch    uint64 `json:"core-epoch"`
	RouteVersion uint64 `json:"route-version"`
	Held         []bool `json:"held"`
}

// The stamp is read before any route resolves, so a move that lands meanwhile
// is checked again under its own version rather than missed.
func handleCheckRoutes(params *CheckRoutesParams) *RouteCheck {
	epoch, version := routeStamp()
	exits := map[RouteHit]string{}
	held := make([]bool, len(params.Routes))
	for index, route := range params.Routes {
		held[index] = len(route) > 0
		for _, hit := range route {
			key := RouteHit{Host: hit.Host, Proxy: hit.Proxy}
			exit, resolved := exits[key]
			if !resolved {
				exit = resolveExit(hit.Host, hit.Proxy)
				exits[key] = exit
			}
			if exit != hit.Exit {
				held[index] = false
				break
			}
		}
	}
	return &RouteCheck{CoreEpoch: epoch, RouteVersion: version, Held: held}
}

func resolveExit(host string, proxyName string) string {
	metadata, err := probeMetadata(host)
	if proxyName != "" {
		return exitThrough(lookupProxy(proxyName), metadata)
	}
	if err != nil {
		return ""
	}
	proxy, err := tunnel.ResolveRoute(metadata)
	if err != nil {
		return ""
	}
	return exitThrough(proxy, metadata)
}

func exitThrough(proxy constant.Proxy, metadata *constant.Metadata) string {
	for proxy != nil {
		if proxy.Type() == constant.LoadBalance {
			return exitName(proxy)
		}
		next := proxy.Unwrap(metadata, false)
		if next == nil {
			return exitName(proxy)
		}
		proxy = next
	}
	return ""
}

// Chains run from the hop that dialed out to the outermost group, so they are
// read from the end to meet the load balancer exitThrough stops at.
func exitOfChains(chains []string) string {
	if len(chains) == 0 {
		return ""
	}
	proxies := tunnel.AllProxies()
	for _, name := range slices.Backward(chains[1:]) {
		if proxy := proxies[name]; proxy != nil && proxy.Type() == constant.LoadBalance {
			return exitName(proxy)
		}
	}
	if leaf := proxies[chains[0]]; leaf != nil {
		return exitName(leaf)
	}
	return ""
}

// A load balancer spreads connections without the route moving, so it is the
// exit; the server counts since a provider can swap the node behind a name.
func exitName(proxy constant.Proxy) string {
	return fmt.Sprintf("%q %s %s", proxy.Name(), proxy.Type(), proxy.Addr())
}
