package main

import (
	"os"
	"path/filepath"
	"slices"
	"strconv"
	"strings"
	"sync"
	"sync/atomic"
	"testing"
	"time"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/outbound"
	"github.com/metacubex/mihomo/common/utils"
	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/constant"
	cp "github.com/metacubex/mihomo/constant/provider"
	"github.com/metacubex/mihomo/log"
	"github.com/metacubex/mihomo/tunnel"
)

func namedProxy(name string) constant.Proxy {
	return adapter.NewProxy(outbound.NewDirectWithOption(outbound.DirectOption{Name: name}))
}

// typeMap turns a name -> adapter type table into the lookup proxyGroupNames
// expects, reporting a miss for any name outside the table.
func typeMap(types map[string]constant.AdapterType) func(string) (constant.AdapterType, bool) {
	return func(name string) (constant.AdapterType, bool) {
		adapterType, ok := types[name]
		return adapterType, ok
	}
}

func TestProxyGroupNamesKeepsOnlyGroups(t *testing.T) {
	names := proxyGroupNames(
		[]string{"GLOBAL", "Auto", "Direct node", "Fall", "Balance", "Chain"},
		typeMap(map[string]constant.AdapterType{
			"GLOBAL":      constant.Selector,
			"Auto":        constant.URLTest,
			"Direct node": constant.Direct,
			"Fall":        constant.Fallback,
			"Balance":     constant.LoadBalance,
			"Chain":       constant.Relay,
		}),
	)

	want := []string{"GLOBAL", "Auto", "Fall", "Balance", "Chain"}
	if strings.Join(names, ",") != strings.Join(want, ",") {
		t.Fatalf("proxyGroupNames = %v, want %v", names, want)
	}
}

func TestProxyGroupNamesPreservesListOrder(t *testing.T) {
	names := proxyGroupNames(
		[]string{"C", "A", "B"},
		typeMap(map[string]constant.AdapterType{
			"A": constant.Selector,
			"B": constant.Selector,
			"C": constant.Selector,
		}),
	)

	if strings.Join(names, ",") != "C,A,B" {
		t.Fatalf("proxyGroupNames = %v, want the config order C,A,B", names)
	}
}

func TestProxyGroupNamesSkipsUnknownNames(t *testing.T) {
	names := proxyGroupNames(
		[]string{"Known", "Missing"},
		typeMap(map[string]constant.AdapterType{"Known": constant.Selector}),
	)

	if len(names) != 1 || names[0] != "Known" {
		t.Fatalf("proxyGroupNames = %v, want only the registered name", names)
	}
}

func TestProxyGroupNamesPrependsUnlistedGlobal(t *testing.T) {
	names := proxyGroupNames(
		[]string{"Auto"},
		typeMap(map[string]constant.AdapterType{
			"Auto":   constant.URLTest,
			"GLOBAL": constant.Selector,
		}),
	)

	want := []string{"GLOBAL", "Auto"}
	if strings.Join(names, ",") != strings.Join(want, ",") {
		t.Fatalf("proxyGroupNames = %v, want %v", names, want)
	}
}

func TestProxyGroupNamesDoesNotDuplicateListedGlobal(t *testing.T) {
	names := proxyGroupNames(
		[]string{"Auto", "GLOBAL"},
		typeMap(map[string]constant.AdapterType{
			"Auto":   constant.URLTest,
			"GLOBAL": constant.Selector,
		}),
	)

	want := []string{"Auto", "GLOBAL"}
	if strings.Join(names, ",") != strings.Join(want, ",") {
		t.Fatalf("proxyGroupNames = %v, want %v", names, want)
	}
}

func TestProxyGroupNamesOmitsMissingGlobal(t *testing.T) {
	names := proxyGroupNames(
		[]string{"Auto"},
		typeMap(map[string]constant.AdapterType{"Auto": constant.URLTest}),
	)

	if len(names) != 1 || names[0] != "Auto" {
		t.Fatalf("proxyGroupNames = %v, want no GLOBAL entry", names)
	}
}

func TestProxyGroupNamesTreatsGlobalLikeAnyOtherName(t *testing.T) {
	types := map[string]constant.AdapterType{
		"Auto":   constant.URLTest,
		"GLOBAL": constant.Direct,
	}

	unlisted := proxyGroupNames([]string{"Auto"}, typeMap(types))
	listed := proxyGroupNames([]string{"GLOBAL", "Auto"}, typeMap(types))

	if strings.Join(unlisted, ",") != "Auto" {
		t.Fatalf("unlisted GLOBAL = %v, want it filtered out like a listed one", unlisted)
	}
	if strings.Join(listed, ",") != "Auto" {
		t.Fatalf("listed GLOBAL = %v, want it filtered out", listed)
	}
}

func TestProxyGroupNamesEmptyList(t *testing.T) {
	names := proxyGroupNames(nil, typeMap(nil))
	if len(names) != 0 {
		t.Fatalf("proxyGroupNames = %v, want empty", names)
	}
}

func TestIsProxyGroupType(t *testing.T) {
	groups := []constant.AdapterType{
		constant.Selector,
		constant.URLTest,
		constant.Fallback,
		constant.Relay,
		constant.LoadBalance,
	}
	for _, adapterType := range groups {
		if !isProxyGroupType(adapterType) {
			t.Errorf("isProxyGroupType(%v) = false, want true", adapterType)
		}
	}

	singles := []constant.AdapterType{constant.Direct, constant.Reject}
	for _, adapterType := range singles {
		if isProxyGroupType(adapterType) {
			t.Errorf("isProxyGroupType(%v) = true, want false", adapterType)
		}
	}
}

func TestDelayValue(t *testing.T) {
	tests := []struct {
		delay uint16
		want  int32
	}{
		{delay: 0, want: -1},
		{delay: 1, want: 1},
		{delay: 250, want: 250},
		{delay: 65535, want: 65535},
	}
	for _, test := range tests {
		if got := delayValue(test.delay); got != test.want {
			t.Errorf("delayValue(%d) = %d, want %d", test.delay, got, test.want)
		}
	}
}

func TestProviderPathsStayUnderTheRoot(t *testing.T) {
	home := filepath.Join("var", "home")
	root, target := providerPaths(home, 1234567890123)

	wantRoot := filepath.Join(home, "profiles", "providers")
	if root != wantRoot {
		t.Fatalf("root = %q, want %q", root, wantRoot)
	}
	wantTarget := filepath.Join(wantRoot, "1234567890123")
	if target != wantTarget {
		t.Fatalf("target = %q, want %q", target, wantTarget)
	}
}

// The ID is an int64 rendered through strconv, so no caller-supplied value can
// add a separator or climb out of the providers root.
func TestProviderPathsCannotEscape(t *testing.T) {
	home := t.TempDir()
	ids := []int64{1, -1, 0, 1 << 62, -(1 << 62)}

	for _, id := range ids {
		root, target := providerPaths(home, id)
		cleaned := filepath.Clean(target)
		if !strings.HasPrefix(cleaned, root+string(filepath.Separator)) {
			t.Errorf("providerPaths(%d) escaped: %q is outside %q", id, cleaned, root)
		}
		if filepath.Dir(cleaned) != root {
			t.Errorf("providerPaths(%d) = %q, want a direct child of %q", id, cleaned, root)
		}
	}
}

func TestHandleValidateConfigAcceptsAValidFile(t *testing.T) {
	path := filepath.Join(t.TempDir(), "config.yaml")
	if err := os.WriteFile(path, []byte("mixed-port: 7890\n"), 0o600); err != nil {
		t.Fatalf("write config: %v", err)
	}

	if got := handleValidateConfig(path); got != "" {
		t.Fatalf("handleValidateConfig = %q, want no error", got)
	}
}

func TestHandleValidateConfigReportsAMissingFile(t *testing.T) {
	got := handleValidateConfig(filepath.Join(t.TempDir(), "absent.yaml"))

	if got == "" {
		t.Fatal("handleValidateConfig accepted a path that does not exist")
	}
	if !strings.Contains(got, "absent.yaml") {
		t.Errorf("handleValidateConfig = %q, want it to name the missing file", got)
	}
}

func TestHandleValidateConfigReportsMalformedYaml(t *testing.T) {
	path := filepath.Join(t.TempDir(), "config.yaml")
	if err := os.WriteFile(path, []byte("proxies: [unterminated\n"), 0o600); err != nil {
		t.Fatalf("write config: %v", err)
	}

	if got := handleValidateConfig(path); got == "" {
		t.Fatal("handleValidateConfig accepted malformed yaml")
	}
}

// The provider entry has to win, because that is the one handleGetProxies
// reports under the shared name and the one the host is asking about.
func TestLookupProxyPrefersTheProviderEntry(t *testing.T) {
	base := namedProxy("shared")
	fromProvider := newCachingProvider("subscription", "shared", "node-a")

	tunnel.UpdateProxies(
		map[string]constant.Proxy{"shared": base, "DIRECT": namedProxy("DIRECT")},
		map[string]cp.ProxyProvider{"subscription": fromProvider},
	)
	t.Cleanup(func() { tunnel.UpdateProxies(nil, nil) })

	if got := lookupProxy("shared"); got == base {
		t.Error("lookupProxy(shared) returned the base entry, want the provider one")
	}
	if got := lookupProxy("node-a"); got == nil {
		t.Error("lookupProxy(node-a) = nil, want the provider entry")
	}
	if got := lookupProxy("DIRECT"); got != base && got == nil {
		t.Error("lookupProxy(DIRECT) = nil, want the base entry")
	}
	if got := lookupProxy("missing"); got != nil {
		t.Errorf("lookupProxy(missing) = %v, want nil", got)
	}
}

// A subscription refresh has to reach a delay test without a config apply,
// which is the whole reason lookupProxy may read a cache at all.
func TestLookupProxyFollowsAProviderUpdate(t *testing.T) {
	provider := newCachingProvider("subscription", "old-node")
	withTunnelProviders(t, map[string]cp.ProxyProvider{"subscription": provider}, nil)

	if lookupProxy("old-node") == nil {
		t.Fatal("lookupProxy(old-node) = nil before the update")
	}

	provider.setProxies("new-node")

	if lookupProxy("new-node") == nil {
		t.Error("lookupProxy(new-node) = nil, a subscription refresh did not reach the lookup")
	}
	if got := lookupProxy("old-node"); got != nil {
		t.Errorf("lookupProxy(old-node) = %v after the refresh dropped it, want nil", got)
	}
}

func TestHandleShutdownTearsDownBackgroundWork(t *testing.T) {
	withCurrentConfig(t, &config.Config{General: &config.General{}, Controller: &config.Controller{}})
	isInit.Store(true)

	cancelled := false
	logMu.Lock()
	logSubscriber = make(chan log.Event)
	logCancel = func() { cancelled = true }
	logMu.Unlock()

	handleShutdown()

	if currentConfig != nil {
		t.Error("currentConfig survived shutdown, so updateConfig would still patch a dead config")
	}
	if isInit.Load() {
		t.Error("isInit stayed true after shutdown")
	}

	logMu.Lock()
	subscriber, cancel := logSubscriber, logCancel
	logMu.Unlock()
	if subscriber != nil || cancel != nil {
		t.Error("shutdown left the log stream subscribed, so events keep being pumped to a host that stopped the core")
	}
	if !cancelled {
		t.Error("shutdown never cancelled the log pump")
	}
}

// The write itself touches one field on one group.
func TestHandleChangeProxyDoesNotWaitOutAConfigApply(t *testing.T) {
	configMu.Lock()
	defer configMu.Unlock()

	answered := make(chan string, 1)
	go func() {
		answered <- handleChangeProxy(&ChangeProxyParams{GroupName: "absent", ProxyName: "node"})
	}()

	select {
	case message := <-answered:
		if message != errGroupNotFound.Error() {
			t.Errorf("message = %q, want %q", message, errGroupNotFound)
		}
	case <-time.After(time.Second):
		t.Fatal("handleChangeProxy queued behind configMu, so selecting a node waits for the whole apply")
	}
}

// The exclusion it does need has to survive: patchSelectGroup and
// handleChangeProxy both write group selections with no lock inside mihomo.
func TestPatchSelectGroupSerialisesWithProxyChanges(t *testing.T) {
	selectMu.Lock()

	patched := make(chan struct{})
	go func() {
		patchSelectGroup(map[string]string{"group": "node"})
		close(patched)
	}()

	select {
	case <-patched:
		selectMu.Unlock()
		t.Fatal("patchSelectGroup wrote selections without taking selectMu")
	case <-time.After(20 * time.Millisecond):
	}

	selectMu.Unlock()
	select {
	case <-patched:
	case <-time.After(time.Second):
		t.Fatal("patchSelectGroup never ran after selectMu was released")
	}
}

// The hoisted constant has to keep meaning what the call meant, so a change to
// mihomo's parser cannot silently narrow which HTTP statuses a delay test
// accepts.
func TestAnyDelayTestStatusMatchesTheEmptyRange(t *testing.T) {
	built, err := utils.NewUnsignedRanges[uint16]("")
	if err != nil {
		t.Fatalf("NewUnsignedRanges(\"\") error: %v", err)
	}
	if len(built) != len(anyDelayTestStatus) {
		t.Fatalf("anyDelayTestStatus = %v, want %v", anyDelayTestStatus, built)
	}
	for _, status := range []uint16{0, 200, 204, 302, 404, 503} {
		if !anyDelayTestStatus.Check(status) {
			t.Errorf("status %d was rejected, so a reachable proxy reports as unreachable", status)
		}
	}
}

// The host reads the proxy tables — a proxy list for the UI, a provider lookup
// for an update — while a config apply replaces them. Those reads used to be
// serialised against the apply by a lock the host held for both; the tunnel's
// own accessors take none, so under -race this is what proves the reads were
// put back under the lock the apply writes with.
func TestProxyTableReadsAreSerialisedAgainstAnApply(t *testing.T) {
	withTunnelProviders(t, nil, nil)

	const rounds = 200
	var wg sync.WaitGroup
	stop := make(chan struct{})

	wg.Add(1)
	go func() {
		defer wg.Done()
		for round := 0; round < rounds; round++ {
			name := "subscription-" + strconv.Itoa(round)
			tunnel.UpdateProxies(
				map[string]constant.Proxy{"DIRECT": namedProxy("DIRECT")},
				map[string]cp.ProxyProvider{name: newCachingProvider(name, "node")},
			)
			tunnel.UpdateRules(nil, nil, map[string]cp.RuleProvider{
				name: &fakeRuleProvider{name: name, vehicle: cp.HTTP},
			})
		}
		close(stop)
	}()

	for reader := 0; reader < 4; reader++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			for {
				select {
				case <-stop:
					return
				default:
				}
				tunnel.AllProxies()
				externalProviders()
				lookupExternalProvider("subscription-0")
			}
		}()
	}

	wg.Wait()
}

// blockingProxyProvider holds its update open so a second request for the same
// provider can be observed while the first is still running.
type blockingProxyProvider struct {
	fakeProxyProvider
	started chan struct{}
	release chan struct{}
	calls   atomic.Int32
}

func (p *blockingProxyProvider) Update() error {
	p.calls.Add(1)
	p.started <- struct{}{}
	<-p.release
	return nil
}

func TestUpdateExternalProviderRunsOneAtATime(t *testing.T) {
	const name = "subscription"
	provider := &blockingProxyProvider{
		fakeProxyProvider: fakeProxyProvider{name: name, vehicle: cp.HTTP},
		started:           make(chan struct{}, 2),
		release:           make(chan struct{}, 2),
	}
	withTunnelProviders(t, map[string]cp.ProxyProvider{name: provider}, nil)
	// Released through the cleanup so a blocked update never wedges the run.
	t.Cleanup(func() { close(provider.release) })

	first := make(chan string, 1)
	go func() { first <- handleUpdateExternalProvider(name) }()

	select {
	case <-provider.started:
	case <-time.After(time.Second):
		t.Fatal("the first update never started")
	}

	second := make(chan string, 1)
	go func() { second <- handleUpdateExternalProvider(name) }()

	select {
	case message := <-second:
		if message != "" {
			t.Fatalf("the duplicate request reported %q", message)
		}
	case <-time.After(time.Second):
		t.Fatal("the duplicate request reached the provider instead of being coalesced")
	}
	select {
	case <-provider.started:
		t.Fatal("a second update started while the first was still running; both rewrite the same vehicle file")
	default:
	}

	provider.release <- struct{}{}
	if message := <-first; message != "" {
		t.Fatalf("the first update reported %q", message)
	}

	if got := provider.calls.Load(); got != 1 {
		t.Errorf("Update ran %d times, want 1", got)
	}
	if !claimUpdate(providerUpdateScope + name) {
		t.Fatal("the in-flight claim was never released, so the provider can never be updated again")
	}
	releaseUpdate(providerUpdateScope + name)
}

// cachingProvider counts how often the tunnel walked its proxy list, which is
// exactly what the AllProxies cache exists to avoid.
type cachingProvider struct {
	fakeProxyProvider
	mu      sync.Mutex
	proxies []constant.Proxy
	version uint32
	reads   int
}

func newCachingProvider(name string, proxyNames ...string) *cachingProvider {
	provider := &cachingProvider{
		fakeProxyProvider: fakeProxyProvider{name: name, vehicle: cp.HTTP},
	}
	provider.setProxies(proxyNames...)
	return provider
}

func (p *cachingProvider) Proxies() []constant.Proxy {
	p.mu.Lock()
	defer p.mu.Unlock()
	p.reads++
	return p.proxies
}

func (p *cachingProvider) Version() uint32 {
	p.mu.Lock()
	defer p.mu.Unlock()
	return p.version
}

// setProxies mirrors mihomo's baseProvider.setProxies: a new list and a bumped
// version, which is the only signal a runtime provider update leaves behind.
func (p *cachingProvider) setProxies(proxyNames ...string) {
	p.mu.Lock()
	defer p.mu.Unlock()
	p.proxies = nil
	for _, name := range proxyNames {
		p.proxies = append(p.proxies, namedProxy(name))
	}
	p.version++
}

func (p *cachingProvider) readCount() int {
	p.mu.Lock()
	defer p.mu.Unlock()
	return p.reads
}

func proxyNamesOf(proxies map[string]constant.Proxy) []string {
	names := make([]string, 0, len(proxies))
	for name := range proxies {
		names = append(names, name)
	}
	slices.Sort(names)
	return names
}

func TestAllProxiesServesRepeatedCallsFromCache(t *testing.T) {
	provider := newCachingProvider("subscription", "node-a", "node-b")
	withTunnelProviders(t, map[string]cp.ProxyProvider{"subscription": provider}, nil)

	first := tunnel.AllProxies()
	reads := provider.readCount()
	second := tunnel.AllProxies()

	if provider.readCount() != reads {
		t.Errorf("the provider list was walked again for an unchanged tunnel (%d -> %d reads)",
			reads, provider.readCount())
	}
	if got, want := proxyNamesOf(second), proxyNamesOf(first); !slices.Equal(got, want) {
		t.Errorf("cached answer = %v, want %v", got, want)
	}
}

// executor.ApplyConfig installs the providers (line 100, updateProxies) before
// it loads them (line 115, loadProvider -> Initial -> the fetcher's onUpdate ->
// setProxies), so a provider is in the tunnel with an empty list for as long as
// its subscription takes to parse. Nothing tells the cache the list arrived
// except the version the load bumps, and a read landing inside that window must
// not be what the cache keeps answering with.
func TestAllProxiesPicksUpAProviderThatLoadsAfterTheApply(t *testing.T) {
	loading := newCachingProvider("subscription")
	base := map[string]constant.Proxy{"DIRECT": namedProxy("DIRECT")}

	tunnel.UpdateProxies(base, map[string]cp.ProxyProvider{"subscription": loading})
	t.Cleanup(func() { tunnel.UpdateProxies(nil, nil) })

	// A UI poll landing between the two executor steps.
	during := proxyNamesOf(tunnel.AllProxies())
	if !slices.Equal(during, []string{"DIRECT"}) {
		t.Fatalf("mid-apply AllProxies = %v, want only the base proxies", during)
	}

	// Initial() finished parsing the subscription.
	loading.setProxies("node-a", "node-b")

	after := proxyNamesOf(tunnel.AllProxies())
	want := []string{"DIRECT", "node-a", "node-b"}
	if !slices.Equal(after, want) {
		t.Errorf("AllProxies = %v, want %v; a provider that loaded after the apply did not reach the tunnel", after, want)
	}
}

// forceGC is the host's "give the memory back" hook — Android calls it from
// onLowMemory and handleShutdown ends with it — and a cache the collection
// cannot reach defeats it.
func TestForceGCReleasesTheProxyCache(t *testing.T) {
	provider := newCachingProvider("subscription", "node-a", "node-b")
	withTunnelProviders(t, map[string]cp.ProxyProvider{"subscription": provider}, nil)

	tunnel.AllProxies()
	warm := provider.readCount()
	tunnel.AllProxies()
	if provider.readCount() != warm {
		t.Fatal("the cache was not warm, so this proves nothing about releasing it")
	}

	handleForceGC()

	tunnel.AllProxies()
	if provider.readCount() == warm {
		t.Error("AllProxies still answered from cache after a forced GC, so the replaced proxies stay pinned")
	}
}

func TestAllProxiesFollowsAProviderUpdate(t *testing.T) {
	provider := newCachingProvider("subscription", "node-a")
	withTunnelProviders(t, map[string]cp.ProxyProvider{"subscription": provider}, nil)

	tunnel.AllProxies()
	provider.setProxies("node-b", "node-c")

	got := proxyNamesOf(tunnel.AllProxies())
	if want := []string{"node-b", "node-c"}; !slices.Equal(got, want) {
		t.Errorf("proxies = %v, want %v; a subscription refresh did not reach the tunnel", got, want)
	}
}

// A config apply replaces the maps outright, and the replacements start their
// own version counts — so identical versions across an apply say nothing about
// whether the proxies are the same. Only the invalidation on UpdateProxies
// catches this.
func TestAllProxiesFollowsAConfigApplyThatKeepsEveryVersion(t *testing.T) {
	before := newCachingProvider("subscription", "old-node")
	tunnel.UpdateProxies(nil, map[string]cp.ProxyProvider{"subscription": before})
	t.Cleanup(func() { tunnel.UpdateProxies(nil, nil) })

	tunnel.AllProxies()

	after := newCachingProvider("subscription", "new-node")
	if after.Version() != before.Version() {
		t.Fatalf("the two providers must share a version for this to test anything (%d vs %d)",
			after.Version(), before.Version())
	}
	tunnel.UpdateProxies(nil, map[string]cp.ProxyProvider{"subscription": after})

	got := proxyNamesOf(tunnel.AllProxies())
	if want := []string{"new-node"}; !slices.Equal(got, want) {
		t.Errorf("proxies = %v, want %v; the previous profile's nodes survived the apply", got, want)
	}
}

func TestHandleGetProxiesSeesAProviderUpdate(t *testing.T) {
	provider := newCachingProvider("subscription", "node-a")
	withTunnelProviders(t, map[string]cp.ProxyProvider{"subscription": provider}, nil)

	if _, exist := handleGetProxies().Proxies["node-a"]; !exist {
		t.Fatal("the handler did not report the installed proxy")
	}

	provider.setProxies("node-b")

	data := handleGetProxies()
	if _, exist := data.Proxies["node-b"]; !exist {
		t.Error("the handler kept serving the pre-refresh proxy list")
	}
	if _, exist := data.Proxies["node-a"]; exist {
		t.Error("a proxy the refresh removed is still reported")
	}
}
