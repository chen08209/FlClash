package main

import (
	"context"
	"errors"
	"os"
	"path/filepath"
	"strings"
	"sync/atomic"
	"testing"
	"time"

	"github.com/metacubex/mihomo/component/updater"
	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/log"
	"github.com/metacubex/mihomo/tunnel"
)

func withCurrentConfig(t *testing.T, cfg *config.Config) {
	t.Helper()
	previous := currentConfig
	currentConfig = cfg
	t.Cleanup(func() { currentConfig = previous })
}

func TestRouteConfigCarriesControllerCredentials(t *testing.T) {
	cfg := &config.Config{
		General: &config.General{LogLevel: log.DEBUG},
		Controller: &config.Controller{
			ExternalController:            "127.0.0.1:9090",
			ExternalControllerTLS:         "127.0.0.1:9443",
			ExternalControllerUnix:        "/tmp/flclash.sock",
			ExternalControllerPipe:        `\\.\pipe\flclash`,
			ExternalControllerRoutingMark: 1234,
			ExternalDohServer:             "/dns-query",
			Secret:                        "s3cret",
			Cors: config.Cors{
				AllowOrigins:        []string{"https://example.test"},
				AllowPrivateNetwork: true,
			},
		},
		TLS: &config.TLS{
			Certificate:    "cert",
			PrivateKey:     "key",
			ClientAuthType: "require",
			ClientAuthCert: "clientCert",
			EchKey:         "ech",
		},
	}

	got := routeConfig(cfg)

	if got.Secret != "s3cret" {
		t.Errorf("Secret = %q, want it preserved; an empty secret unauthenticates the controller", got.Secret)
	}
	if got.Addr != "127.0.0.1:9090" || got.TLSAddr != "127.0.0.1:9443" {
		t.Errorf("addresses = %q/%q, want the controller's own listen addresses", got.Addr, got.TLSAddr)
	}
	if got.UnixAddr != "/tmp/flclash.sock" || got.PipeAddr != `\\.\pipe\flclash` {
		t.Errorf("local addresses = %q/%q, want them preserved", got.UnixAddr, got.PipeAddr)
	}
	if got.RoutingMark != 1234 || got.DohServer != "/dns-query" {
		t.Errorf("routingMark/dohServer = %d/%q, want 1234//dns-query", got.RoutingMark, got.DohServer)
	}
	if got.Certificate != "cert" || got.PrivateKey != "key" ||
		got.ClientAuthType != "require" || got.ClientAuthCert != "clientCert" || got.EchKey != "ech" {
		t.Errorf("TLS material = %+v, want it carried over from cfg.TLS", got)
	}
	if len(got.Cors.AllowOrigins) != 1 || got.Cors.AllowOrigins[0] != "https://example.test" ||
		!got.Cors.AllowPrivateNetwork {
		t.Errorf("Cors = %+v, want the configured origins", got.Cors)
	}
	if !got.IsDebug {
		t.Error("IsDebug = false, want it derived from a DEBUG log level")
	}
}

func TestRouteConfigToleratesMissingTLSSection(t *testing.T) {
	cfg := &config.Config{
		General:    &config.General{},
		Controller: &config.Controller{ExternalController: "127.0.0.1:9090"},
	}

	got := routeConfig(cfg)

	if got.Certificate != "" || got.PrivateKey != "" {
		t.Errorf("TLS material = %q/%q, want empty when cfg.TLS is absent", got.Certificate, got.PrivateKey)
	}
}

func TestUpdateConfigRejectsAnUnappliedConfig(t *testing.T) {
	withCurrentConfig(t, nil)

	if err := updateConfig(&UpdateParams{}); err != errConfigNotApplied {
		t.Errorf("updateConfig error = %v, want errConfigNotApplied", err)
	}
}

func TestHandleUpdateConfigReportsAnUnappliedConfig(t *testing.T) {
	withCurrentConfig(t, nil)

	if message := handleUpdateConfig(&UpdateParams{}); message == "" {
		t.Error("handleUpdateConfig reported success without an applied config")
	}
}

func TestUpdateConfigAppliesAllowLan(t *testing.T) {
	withCurrentConfig(t, &config.Config{General: &config.General{}, Controller: &config.Controller{}})
	allowLan := true

	if err := updateConfig(&UpdateParams{AllowLan: &allowLan}); err != nil {
		t.Fatalf("updateConfig error: %v", err)
	}

	if !currentConfig.General.AllowLan {
		t.Error("AllowLan stayed false; the patched value never reached the general config")
	}
}

func TestUpdateConfigPatchesOnlyTheTunFieldsItWasGiven(t *testing.T) {
	withCurrentConfig(t, &config.Config{General: &config.General{}, Controller: &config.Controller{}})
	currentConfig.General.Tun.Device = "keep-me"
	device := "flclash-tun"

	if err := updateConfig(&UpdateParams{Tun: &tunSchema{Enable: true}}); err != nil {
		t.Fatalf("updateConfig error: %v", err)
	}
	if !currentConfig.General.Tun.Enable {
		t.Error("Tun.Enable stayed false")
	}
	if currentConfig.General.Tun.Device != "keep-me" {
		t.Errorf("Tun.Device = %q, want an omitted field left untouched", currentConfig.General.Tun.Device)
	}

	if err := updateConfig(&UpdateParams{Tun: &tunSchema{Enable: true, Device: &device}}); err != nil {
		t.Fatalf("updateConfig error: %v", err)
	}
	if currentConfig.General.Tun.Device != device {
		t.Errorf("Tun.Device = %q, want %q", currentConfig.General.Tun.Device, device)
	}
}

func TestUpdateConfigLeavesTheControllerAloneWhenTheAddressIsUnchanged(t *testing.T) {
	withCurrentConfig(t, &config.Config{
		General:    &config.General{},
		Controller: &config.Controller{ExternalController: "127.0.0.1:9090", Secret: "s3cret"},
	})
	address := "127.0.0.1:9090"

	if err := updateConfig(&UpdateParams{ExternalController: &address}); err != nil {
		t.Fatalf("updateConfig error: %v", err)
	}

	if currentConfig.Controller.Secret != "s3cret" {
		t.Errorf("Secret = %q, want the controller left untouched", currentConfig.Controller.Secret)
	}
}

// geoUpdaterCalls counts the reconciliation the code under test asked for. The
// real calls spawn a goroutine that downloads the GEO databases, which is not
// something a unit test should reach for.
type geoUpdaterCalls struct {
	registered int
	stopped    int
}

func stubGeoUpdater(t *testing.T) *geoUpdaterCalls {
	t.Helper()
	calls := &geoUpdaterCalls{}
	previousRegister, previousStop := registerGeoUpdater, stopGeoUpdater
	previousAuto, previousInterval := updater.GeoAutoUpdate(), updater.GeoUpdateInterval()
	registerGeoUpdater = func() { calls.registered++ }
	stopGeoUpdater = func() { calls.stopped++ }
	t.Cleanup(func() {
		registerGeoUpdater, stopGeoUpdater = previousRegister, previousStop
		updater.SetGeoAutoUpdate(previousAuto)
		updater.SetGeoUpdateInterval(previousInterval)
	})
	return calls
}

func TestSyncGeoUpdaterStopsTheUpdaterWhenDisabled(t *testing.T) {
	calls := stubGeoUpdater(t)

	updater.SetGeoAutoUpdate(true)
	updater.SetGeoUpdateInterval(24)
	disabled := false

	syncGeoUpdater(&disabled, nil)

	if updater.GeoAutoUpdate() {
		t.Error("GeoAutoUpdate stayed on after the setting was turned off")
	}
	if updater.GeoUpdateInterval() != 24 {
		t.Errorf("GeoUpdateInterval = %d, want the configured 24 left untouched by the stop", updater.GeoUpdateInterval())
	}
	if calls.stopped != 1 || calls.registered != 0 {
		t.Errorf(
			"updater calls = %d registered/%d stopped, want the running updater cancelled",
			calls.registered, calls.stopped,
		)
	}
}

func TestSyncGeoUpdaterIgnoresUnchangedParameters(t *testing.T) {
	calls := stubGeoUpdater(t)

	updater.SetGeoAutoUpdate(false)
	updater.SetGeoUpdateInterval(12)
	stillDisabled := false
	sameInterval := 12

	syncGeoUpdater(&stillDisabled, &sameInterval)

	if updater.GeoAutoUpdate() || updater.GeoUpdateInterval() != 12 {
		t.Errorf(
			"geo settings = %v/%d, want them untouched",
			updater.GeoAutoUpdate(), updater.GeoUpdateInterval(),
		)
	}
	if calls.registered != 0 || calls.stopped != 0 {
		t.Errorf(
			"updater calls = %d registered/%d stopped, want the running updater left alone",
			calls.registered, calls.stopped,
		)
	}
}

// A profile apply reloads the setting out of config.yaml, so the core can end
// up with the updater running while the flag reads off. Reconciling only when
// the flag says on left that goroutine downloading GEO databases forever: the
// flag already matched what the app sent next, so syncGeoUpdater saw nothing to
// change and never cancelled it.
func TestReconcileGeoUpdaterStopsAnUpdaterTheProfileTurnedOff(t *testing.T) {
	calls := stubGeoUpdater(t)

	updater.SetGeoAutoUpdate(false)

	reconcileGeoUpdater()

	if calls.stopped != 1 || calls.registered != 0 {
		t.Errorf(
			"updater calls = %d registered/%d stopped, want the updater cancelled",
			calls.registered, calls.stopped,
		)
	}
}

func TestReconcileGeoUpdaterRegistersWhenTheSettingIsOn(t *testing.T) {
	calls := stubGeoUpdater(t)

	updater.SetGeoAutoUpdate(true)

	reconcileGeoUpdater()

	if calls.registered != 1 || calls.stopped != 0 {
		t.Errorf(
			"updater calls = %d registered/%d stopped, want the updater registered",
			calls.registered, calls.stopped,
		)
	}
}

func TestCurrentTestURLFallsBackToTheBuiltInProbe(t *testing.T) {
	previous := testURL.Load()
	t.Cleanup(func() { testURL.Store(previous) })

	testURL.Store(nil)
	if got := currentTestURL(); got != defaultTestURL {
		t.Errorf("currentTestURL = %q, want the built-in probe", got)
	}

	empty := ""
	testURL.Store(&empty)
	if got := currentTestURL(); got != defaultTestURL {
		t.Errorf("currentTestURL = %q, want an empty setting to fall back", got)
	}

	custom := "https://example.test/generate_204"
	setTestURL(custom)
	if got := currentTestURL(); got != custom {
		t.Errorf("currentTestURL = %q, want %q", got, custom)
	}
}

func TestDelayTestSlotsBoundConcurrency(t *testing.T) {
	if cap(delayTestSlots) != delayTestConcurrency {
		t.Fatalf("delayTestSlots capacity = %d, want %d", cap(delayTestSlots), delayTestConcurrency)
	}

	for i := 0; i < delayTestConcurrency; i++ {
		if !acquireDelayTestSlot(context.Background()) {
			t.Fatalf("slot %d was refused while the semaphore still had room", i)
		}
	}

	blocked := make(chan struct{})
	go func() {
		acquireDelayTestSlot(context.Background())
		close(blocked)
	}()

	select {
	case <-blocked:
		t.Fatal("acquireDelayTestSlot handed out more slots than the configured concurrency")
	case <-time.After(20 * time.Millisecond):
	}

	releaseDelayTestSlot()
	select {
	case <-blocked:
	case <-time.After(time.Second):
		t.Fatal("a released slot never reached the waiting caller")
	}

	for i := 0; i < delayTestConcurrency; i++ {
		releaseDelayTestSlot()
	}
}

func TestHandleUpdateGeoDataRejectsAnUnknownResource(t *testing.T) {
	if message := handleUpdateGeoData("NOPE"); message == "" {
		t.Error("an unknown geo resource reported success and silently did nothing")
	}
	if _, exists := geoResourceUpdaters["MMDB"]; !exists {
		t.Error("MMDB is missing from the geo resource table")
	}
}

func TestSetTestURLIgnoresAnEmptyValue(t *testing.T) {
	const configured = "https://example.test/generate_204"
	previousDefault := constant.DefaultTestURL
	previousStored := testURL.Load()
	t.Cleanup(func() {
		constant.DefaultTestURL = previousDefault
		testURL.Store(previousStored)
	})

	setTestURL(configured)
	setTestURL("")

	if constant.DefaultTestURL != configured {
		t.Errorf("DefaultTestURL = %q, an empty setup param cleared mihomo's own default", constant.DefaultTestURL)
	}
	if got := currentTestURL(); got != configured {
		t.Errorf("currentTestURL() = %q, want %q", got, configured)
	}
}

func TestTestDelayRejectsAnUnknownProxyWithoutWaitingForASlot(t *testing.T) {
	for i := 0; i < delayTestConcurrency; i++ {
		delayTestSlots <- struct{}{}
	}
	t.Cleanup(func() {
		for i := 0; i < delayTestConcurrency; i++ {
			<-delayTestSlots
		}
	})

	done := make(chan *Delay, 1)
	go func() {
		done <- handleTestDelay(&TestDelayParams{ProxyName: "missing", Timeout: 1})
	}()

	select {
	case delay := <-done:
		if delay.Value != -1 {
			t.Errorf("value = %d, want -1", delay.Value)
		}
	case <-time.After(time.Second):
		t.Fatal("an unknown proxy queued behind a saturated delay-test semaphore")
	}
}

func settleMessageBatcher() {
	time.Sleep(3 * messageBatchInterval)
}

func withGeoResourceUpdaters(t *testing.T, updaters map[string]func() error) {
	t.Helper()
	previous := geoResourceUpdaters
	geoResourceUpdaters = updaters
	t.Cleanup(func() {
		geoResourceUpdaters = previous
		for name := range updaters {
			releaseGeoUpdate(name)
		}
	})
}

func TestHandleUpdateGeoDataRunsOneUpdatePerResource(t *testing.T) {
	const resource = "TEST"
	started := make(chan struct{}, 2)
	release := make(chan struct{})
	var calls atomic.Int32

	withGeoResourceUpdaters(t, map[string]func() error{
		resource: func() error {
			calls.Add(1)
			started <- struct{}{}
			<-release
			return nil
		},
	})

	if message := handleUpdateGeoData(resource); message != "" {
		t.Fatalf("handleUpdateGeoData = %q, want no error", message)
	}
	select {
	case <-started:
	case <-time.After(time.Second):
		t.Fatal("the first update never started")
	}

	if message := handleUpdateGeoData(resource); message != "" {
		t.Fatalf("the duplicate request reported %q", message)
	}
	select {
	case <-started:
		t.Fatal("a second update started while the first was still running; both close the mmap'd database")
	case <-time.After(100 * time.Millisecond):
	}
	close(release)

	if got := calls.Load(); got != 1 {
		t.Errorf("the updater ran %d times, want 1", got)
	}

	deadline := time.Now().Add(time.Second)
	for !claimGeoUpdate(resource) {
		if time.Now().After(deadline) {
			t.Fatal("the in-flight claim was never released, so the resource can never be updated again")
		}
		time.Sleep(5 * time.Millisecond)
	}
	releaseGeoUpdate(resource)
}

func TestGeoUpdateHookBlocksAManualUpdateOfTheSameResource(t *testing.T) {
	const resource = "MMDB"
	ran := make(chan struct{}, 1)

	withGeoResourceUpdaters(t, map[string]func() error{
		resource: func() error {
			ran <- struct{}{}
			return nil
		},
	})

	updater.GeoUpdateHook(resource, true, false, nil)

	if message := handleUpdateGeoData(resource); message != "" {
		t.Fatalf("handleUpdateGeoData = %q, want no error", message)
	}
	select {
	case <-ran:
		t.Fatal("a manual update ran while the auto updater was already updating the same resource")
	case <-time.After(100 * time.Millisecond):
	}

	updater.GeoUpdateHook(resource, false, false, nil)

	if !claimGeoUpdate(resource) {
		t.Fatal("the hook never cleared the claim, so the resource stays blocked for the rest of the process")
	}
	releaseGeoUpdate(resource)
	settleMessageBatcher()
}

// The hook fires for the automatic updater, which can start and finish inside a
// manual update of the same resource. Releasing the manual claim there lets a
// second manual update run alongside the first.
func TestGeoUpdateHookDoesNotReleaseAManualClaim(t *testing.T) {
	const resource = "GEOIP"
	started := make(chan struct{}, 2)
	release := make(chan struct{})
	var calls atomic.Int32

	withGeoResourceUpdaters(t, map[string]func() error{
		resource: func() error {
			calls.Add(1)
			started <- struct{}{}
			<-release
			return nil
		},
	})

	if message := handleUpdateGeoData(resource); message != "" {
		t.Fatalf("handleUpdateGeoData = %q, want no error", message)
	}
	select {
	case <-started:
	case <-time.After(time.Second):
		t.Fatal("the manual update never started")
	}

	// An automatic pass over the same resource, start to finish, while the
	// manual one is still running.
	updater.GeoUpdateHook(resource, true, false, nil)
	updater.GeoUpdateHook(resource, false, false, nil)

	if message := handleUpdateGeoData(resource); message != "" {
		t.Fatalf("the duplicate request reported %q", message)
	}
	select {
	case <-started:
		t.Fatal("a second manual update started while the first was still running")
	case <-time.After(100 * time.Millisecond):
	}
	close(release)

	deadline := time.Now().Add(time.Second)
	for !claimGeoUpdate(resource) {
		if time.Now().After(deadline) {
			t.Fatal("the manual claim was never released")
		}
		time.Sleep(5 * time.Millisecond)
	}
	releaseGeoUpdate(resource)
	if got := calls.Load(); got != 1 {
		t.Errorf("the updater ran %d times, want 1", got)
	}
	settleMessageBatcher()
}

// An empty config.yaml is how the app expresses "no profile selected". mihomo's
// own reader rejects it.
func TestLoadConfigTreatsAnEmptyProfileAsTheDefaults(t *testing.T) {
	path := filepath.Join(t.TempDir(), "config.yaml")
	if err := os.WriteFile(path, nil, 0o600); err != nil {
		t.Fatalf("write config: %v", err)
	}

	cfg, err := loadConfig(path)

	if err != nil {
		t.Fatalf("loadConfig = %v, want no error for an empty profile", err)
	}
	if cfg == nil {
		t.Fatal("loadConfig returned no config for an empty profile")
	}
}

func TestLoadConfigReportsAMissingFile(t *testing.T) {
	_, err := loadConfig(filepath.Join(t.TempDir(), "absent.yaml"))

	if err == nil {
		t.Fatal("loadConfig accepted a path that does not exist")
	}
	if !strings.Contains(err.Error(), "absent.yaml") {
		t.Errorf("loadConfig = %v, want it to name the missing file", err)
	}
}

func TestLoadConfigReportsMalformedYaml(t *testing.T) {
	path := filepath.Join(t.TempDir(), "config.yaml")
	if err := os.WriteFile(path, []byte("proxies: [unterminated\n"), 0o600); err != nil {
		t.Fatalf("write config: %v", err)
	}

	if _, err := loadConfig(path); err == nil {
		t.Fatal("loadConfig accepted malformed yaml")
	}
}

func withSetupConfig(t *testing.T, apply func(*SetupParams) error) {
	t.Helper()
	previous := setupConfig
	setupConfig = apply
	t.Cleanup(func() { setupConfig = previous })

	isInit.Store(true)
	isRunning.Store(true)
	t.Cleanup(func() {
		isInit.Store(false)
		isRunning.Store(false)
	})
}

// applyConfig rolls back to the default config when the profile fails to parse.
// That rollback is the whole recovery: the error reaches the host and the
// listeners keep serving while the user picks another profile.
func TestHandleSetupConfigKeepsTheListenerWhenTheProfileFails(t *testing.T) {
	withSetupConfig(t, func(*SetupParams) error { return errors.New("bad profile") })

	got := handleSetupConfig(defaultSetupParams())

	if got != "bad profile" {
		t.Fatalf("handleSetupConfig = %q, want the apply error", got)
	}
	if !isRunning.Load() {
		t.Error("a failed apply stopped the listeners")
	}
}

func TestHandleSetupConfigLeavesTheListenerAloneOnSuccess(t *testing.T) {
	withSetupConfig(t, func(*SetupParams) error { return nil })

	got := handleSetupConfig(defaultSetupParams())

	if got != "" {
		t.Fatalf("handleSetupConfig = %q, want no error", got)
	}
	if !isRunning.Load() {
		t.Error("a successful apply stopped the listeners")
	}
}

// The host abandons a delay test after a fixed time.
func TestAcquireDelayTestSlotGivesUpOnTheDeadline(t *testing.T) {
	for i := 0; i < delayTestConcurrency; i++ {
		delayTestSlots <- struct{}{}
	}
	t.Cleanup(func() {
		for i := 0; i < delayTestConcurrency; i++ {
			<-delayTestSlots
		}
	})

	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Millisecond)
	defer cancel()

	refused := make(chan bool, 1)
	go func() { refused <- acquireDelayTestSlot(ctx) }()

	select {
	case granted := <-refused:
		if granted {
			t.Fatal("acquireDelayTestSlot handed out a slot the semaphore did not have")
		}
	case <-time.After(time.Second):
		t.Fatal("acquireDelayTestSlot ignored the deadline and kept queueing")
	}
}

func TestDelayTestTimeoutFallsBackWhenUnset(t *testing.T) {
	if got := delayTestTimeout(250); got != 250*time.Millisecond {
		t.Errorf("delayTestTimeout(250) = %v, want 250ms", got)
	}
	for _, unset := range []int64{0, -1} {
		if got := delayTestTimeout(unset); got != defaultDelayTestTimeout {
			t.Errorf("delayTestTimeout(%d) = %v, want the default %v", unset, got, defaultDelayTestTimeout)
		}
	}
}

func TestTestDelayQueuesWhenTheTimeoutIsUnset(t *testing.T) {
	for i := 0; i < delayTestConcurrency; i++ {
		delayTestSlots <- struct{}{}
	}
	t.Cleanup(func() {
		for i := 0; i < delayTestConcurrency; i++ {
			<-delayTestSlots
		}
	})

	tunnel.UpdateProxies(map[string]constant.Proxy{"queued": namedProxy("queued")}, nil)
	t.Cleanup(func() { tunnel.UpdateProxies(nil, nil) })

	done := make(chan *Delay, 1)
	go func() {
		// A refused port rather than the default URL: the probe this is proving
		// will eventually happen should not leave the machine.
		done <- handleTestDelay(&TestDelayParams{
			ProxyName: "queued",
			TestUrl:   "http://127.0.0.1:1",
		})
	}()

	select {
	case <-done:
		t.Fatal("handleTestDelay gave up immediately on an unset timeout, want it queueing for the default")
	case <-time.After(200 * time.Millisecond):
	}

	// Hand over a slot and join, so nothing is still reading the tunnel when
	// the cleanup below replaces it. tunnel.Proxies and tunnel.Providers are
	// unsynchronised reads of maps UpdateProxies writes, so an unjoined reader
	// is a reported race whatever the timing.
	<-delayTestSlots
	delay := <-done
	delayTestSlots <- struct{}{}

	if delay.Value != -1 {
		t.Errorf("value = %d, want -1 for a probe against a refused port", delay.Value)
	}
}

func TestTestDelayStopsQueueingOnceTheTimeoutIsSpent(t *testing.T) {
	for i := 0; i < delayTestConcurrency; i++ {
		delayTestSlots <- struct{}{}
	}
	t.Cleanup(func() {
		for i := 0; i < delayTestConcurrency; i++ {
			<-delayTestSlots
		}
	})

	// A proxy the lookup actually resolves, so the call reaches the semaphore
	// instead of bailing out on an unknown name.
	tunnel.UpdateProxies(map[string]constant.Proxy{"queued": namedProxy("queued")}, nil)
	t.Cleanup(func() { tunnel.UpdateProxies(nil, nil) })

	done := make(chan *Delay, 1)
	go func() {
		done <- handleTestDelay(&TestDelayParams{ProxyName: "queued", Timeout: 20})
	}()

	select {
	case delay := <-done:
		if delay != nil {
			t.Errorf("delay = %+v, want no result for a test that never got a slot", delay)
		}
	case <-time.After(time.Second):
		t.Fatal("handleTestDelay outlived the timeout it was given, waiting for a slot")
	}
}
