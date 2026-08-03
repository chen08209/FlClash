package main

import (
	"cmp"
	"context"
	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/outboundgroup"
	"github.com/metacubex/mihomo/common/observable"
	"github.com/metacubex/mihomo/common/utils"
	"github.com/metacubex/mihomo/component/mmdb"
	"github.com/metacubex/mihomo/component/resolver"
	"github.com/metacubex/mihomo/component/updater"
	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/constant/features"
	cp "github.com/metacubex/mihomo/constant/provider"
	"github.com/metacubex/mihomo/hub/executor"
	"github.com/metacubex/mihomo/listener"
	"github.com/metacubex/mihomo/log"
	"github.com/metacubex/mihomo/tunnel"
	"github.com/metacubex/mihomo/tunnel/statistic"
	"golang.org/x/exp/slices"
	"net"
	"os"
	"path/filepath"
	"runtime"
	"runtime/debug"
	"strconv"
	"sync"
	"sync/atomic"
	"time"
)

var (
	isInit            atomic.Bool
	externalProviders = map[string]cp.Provider{}
	logSubscriber     observable.Subscription[log.Event]
	trafficStopCh     chan struct{}
	trafficPushMu     sync.Mutex
)

func handleInitClash(params *InitParams) bool {
	runLock.Lock()
	defer runLock.Unlock()
	version = params.Version
	constant.SetHomeDir(params.HomeDir)
	isInit.Store(true)
	return true
}

func handleStartListener() bool {
	runLock.Lock()
	defer runLock.Unlock()
	isRunning = true
	updateListeners()
	resolver.ResetConnection()
	startTrafficPush()
	return true
}

func handleStopListener() bool {
	runLock.Lock()
	defer runLock.Unlock()
	isRunning = false
	stopTrafficPush()
	listener.StopListener()
	resolver.ResetConnection()
	return true
}

func handleGetIsInit() bool {
	return isInit.Load()
}

func handleForceGC() {
	log.Infoln("[APP] request force GC")
	runtime.GC()
	if features.Android {
		debug.FreeOSMemory()
	}
}

func handleShutdown() bool {
	stopTrafficPush()
	stopListeners()
	executor.Shutdown()
	handleForceGC()
	isInit.Store(false)
	return true
}

func handleValidateConfig(path string) string {
	buf, err := readFile(path)
	_, err = config.UnmarshalRawConfig(buf)
	if err != nil {
		return err.Error()
	}
	return ""
}

func handleGetProxies() ProxiesData {
	runLock.Lock()
	defer runLock.Unlock()

	nameList := config.GetProxyNameList()

	proxies := tunnel.AllProxies()

	hasGlobal := false

	allNames := make([]string, 0, len(nameList)+1)

	for _, name := range nameList {
		if name == "GLOBAL" {
			hasGlobal = true
		}

		p, ok := proxies[name]
		if !ok || p == nil {
			continue
		}
		switch p.Type() {
		case constant.Selector, constant.URLTest, constant.Fallback, constant.Relay, constant.LoadBalance:
			allNames = append(allNames, name)
		default:
		}
	}

	if !hasGlobal {
		if p, ok := proxies["GLOBAL"]; ok && p != nil {
			allNames = append([]string{"GLOBAL"}, allNames...)
		}
	}

	return ProxiesData{
		All:     allNames,
		Proxies: proxies,
	}
}

func handleChangeProxy(params *ChangeProxyParams, fn func(string string)) {
	runLock.Lock()
	go func() {
		defer runLock.Unlock()
		groupName := params.GroupName
		proxyName := params.ProxyName
		proxies := tunnel.AllProxies()
		group, ok := proxies[groupName]
		if !ok {
			fn("Not found group")
			return
		}
		adapterProxy, ok := group.(*adapter.Proxy)
		if !ok {
			fn("Group has invalid proxy type")
			return
		}
		selector, ok := adapterProxy.ProxyAdapter.(outboundgroup.SelectAble)
		if !ok {
			fn("Group is not selectable")
			return
		}
		if proxyName == "" {
			selector.ForceSet(proxyName)
		} else {
			err := selector.Set(proxyName)
			if err != nil {
				fn(err.Error())
				return
			}
		}

		fn("")
		return
	}()
}

func handleGetTraffic(onlyStatisticsProxy bool) Traffic {
	up, down := statistic.DefaultManager.NowTraffic(onlyStatisticsProxy)
	return Traffic{
		Up:   up,
		Down: down,
	}
}

func handleGetTotalTraffic(onlyStatisticsProxy bool) Traffic {
	up, down := statistic.DefaultManager.TotalTraffic(onlyStatisticsProxy)
	return Traffic{
		Up:   up,
		Down: down,
	}
}

func handleResetTraffic() {
	statistic.DefaultManager.ResetStatistic()
}

func handleGetTrafficSnapshot(onlyStatisticsProxy bool) map[string]int64 {
	up, down := statistic.DefaultManager.NowTraffic(onlyStatisticsProxy)
	totalUp, totalDown := statistic.DefaultManager.TotalTraffic(onlyStatisticsProxy)
	return map[string]int64{
		"up":        up,
		"down":      down,
		"totalUp":   totalUp,
		"totalDown": totalDown,
	}
}

func trafficSnapshotPayload() map[string]int64 {
	up, down := statistic.DefaultManager.NowTraffic(false)
	totalUp, totalDown := statistic.DefaultManager.TotalTraffic(false)
	proxyUp, proxyDown := statistic.DefaultManager.NowTraffic(true)
	proxyTotalUp, proxyTotalDown := statistic.DefaultManager.TotalTraffic(true)
	return map[string]int64{
		"up":             up,
		"down":           down,
		"totalUp":        totalUp,
		"totalDown":      totalDown,
		"proxyUp":        proxyUp,
		"proxyDown":      proxyDown,
		"proxyTotalUp":   proxyTotalUp,
		"proxyTotalDown": proxyTotalDown,
	}
}

func sendTrafficSnapshotMessage() {
	sendMessage(Message{
		Type: TrafficMessage,
		Data: trafficSnapshotPayload(),
	})
}

func sendConnectionsSnapshotMessage() {
	runLock.Lock()
	snapshot := statistic.DefaultManager.Snapshot()
	runLock.Unlock()
	sendMessage(Message{
		Type: ConnectionsMessage,
		Data: snapshot,
	})
}

func startTrafficPush() {
	trafficPushMu.Lock()
	defer trafficPushMu.Unlock()
	stopTrafficPushLocked()
	stopCh := make(chan struct{})
	trafficStopCh = stopCh
	go func() {
		ticker := time.NewTicker(time.Second)
		defer ticker.Stop()
		sendTrafficSnapshotMessage()
		sendConnectionsSnapshotMessage()
		ticks := 0
		for {
			select {
			case <-ticker.C:
				sendTrafficSnapshotMessage()
				ticks++
				if ticks%2 == 0 {
					sendConnectionsSnapshotMessage()
				}
			case <-stopCh:
				return
			}
		}
	}()
}

func stopTrafficPush() {
	trafficPushMu.Lock()
	defer trafficPushMu.Unlock()
	stopTrafficPushLocked()
}

func stopTrafficPushLocked() {
	if trafficStopCh != nil {
		close(trafficStopCh)
		trafficStopCh = nil
	}
}


func handleAsyncTestDelay(params *TestDelayParams, fn func(*Delay)) {
	batchKey := params.ProxyName + "\x00" + params.TestUrl
	mBatch.Go(batchKey, func() (bool, error) {
		testUrl := params.TestUrl
		if testUrl == "" {
			testUrl = constant.DefaultTestURL
		}
		delayData := &Delay{
			Name:  params.ProxyName,
			Url:   testUrl,
			Value: -1,
		}

		expectedStatus, err := utils.NewUnsignedRanges[uint16]("")
		if err != nil {
			fn(delayData)
			return false, nil
		}

		ctx, cancel := context.WithTimeout(context.Background(), time.Millisecond*time.Duration(params.Timeout))
		defer cancel()

		proxies := tunnel.AllProxies()
		proxy := proxies[params.ProxyName]

		if proxy == nil {
			fn(delayData)
			return false, nil
		}
		delay, err := proxy.URLTest(ctx, testUrl, expectedStatus)
		if err != nil || delay == 0 {
			fn(delayData)
			return false, nil
		}

		delayData.Value = int32(delay)
		fn(delayData)
		return false, nil
	})
}

func handleGetConnections() *statistic.Snapshot {
	runLock.Lock()
	defer runLock.Unlock()
	return statistic.DefaultManager.Snapshot()
}

func handleCloseConnections() bool {
	runLock.Lock()
	defer runLock.Unlock()
	closeConnections()
	return true
}

func closeConnections() {
	statistic.DefaultManager.Range(func(c statistic.Tracker) bool {
		err := c.Close()
		if err != nil {
			return false
		}
		return true
	})
}

func handleResetConnections() bool {
	runLock.Lock()
	defer runLock.Unlock()
	resolver.ResetConnection()
	return true
}

func handleCloseConnection(connectionId string) bool {
	runLock.Lock()
	defer runLock.Unlock()
	c := statistic.DefaultManager.Get(connectionId)
	if c == nil {
		return false
	}
	_ = c.Close()
	return true
}

func handleGetExternalProviders() []ExternalProvider {
	runLock.Lock()
	defer runLock.Unlock()
	externalProviders = getExternalProvidersRaw()
	eps := make([]ExternalProvider, 0)
	for _, p := range externalProviders {
		externalProvider, err := toExternalProvider(p)
		if err != nil {
			continue
		}
		eps = append(eps, *externalProvider)
	}
	slices.SortFunc(eps, func(a, b ExternalProvider) int {
		return cmp.Compare(a.Name, b.Name)
	})
	return eps
}

func handleGetExternalProvider(externalProviderName string) *ExternalProvider {
	runLock.Lock()
	defer runLock.Unlock()
	externalProvider, exist := externalProviders[externalProviderName]
	if !exist {
		return nil
	}
	e, err := toExternalProvider(externalProvider)
	if err != nil {
		return nil
	}
	return e
}

func handleUpdateGeoData(geoType string) {
	go func() {
		switch geoType {
		case "MMDB":
			updater.UpdateMMDB()
			return
		case "ASN":
			updater.UpdateASN()
			return
		case "GEOIP":
			updater.UpdateGeoIp()
			return
		case "GEOSITE":
			updater.UpdateGeoSite()
			return
		}
	}()
}

func handleUpdateExternalProvider(providerName string, fn func(value string)) {
	go func() {
		runLock.Lock()
		externalProvider, exist := externalProviders[providerName]
		runLock.Unlock()
		if !exist {
			fn("external provider is not exist")
			return
		}
		err := externalProvider.Update()
		if err != nil {
			fn(err.Error())
			return
		}
		fn("")
	}()
}

func handleSideLoadExternalProvider(providerName string, data []byte, fn func(value string)) {
	go func() {
		runLock.Lock()
		defer runLock.Unlock()
		externalProvider, exist := externalProviders[providerName]
		if !exist {
			fn("external provider is not exist")
			return
		}
		err := sideUpdateExternalProvider(externalProvider, data)
		if err != nil {
			fn(err.Error())
			return
		}
		fn("")
	}()
}

func handleSuspend(suspended bool) bool {
	if suspended {
		tunnel.OnSuspend()
	} else {
		tunnel.OnRunning()
	}
	return true
}

func handleStartLog() {
	runLock.Lock()
	if logSubscriber != nil {
		log.UnSubscribe(logSubscriber)
	}
	subscriber := log.Subscribe()
	logSubscriber = subscriber
	runLock.Unlock()
	go func() {
		for logData := range subscriber {
			if logData.LogLevel < log.Level() {
				continue
			}
			message := &Message{
				Type: LogMessage,
				Data: logData,
			}
			sendMessage(*message)
		}
	}()
}

func handleStopLog() {
	runLock.Lock()
	defer runLock.Unlock()
	if logSubscriber != nil {
		log.UnSubscribe(logSubscriber)
		logSubscriber = nil
	}
}

func handleGetCountryCode(ip string, fn func(value string)) {
	go func() {
		runLock.Lock()
		defer runLock.Unlock()
		codes := mmdb.IPInstance().LookupCode(net.ParseIP(ip))
		if len(codes) == 0 {
			fn("")
			return
		}
		fn(codes[0])
	}()
}

func handleGetMemory(fn func(value uint64)) {
	go func() {
		fn(statistic.DefaultManager.Memory())
	}()
}

func handleGetConfig(path string) (*config.RawConfig, error) {
	bytes, err := readFile(path)
	if err != nil {
		return nil, err
	}
	prof, err := config.UnmarshalRawConfig(bytes)
	if err != nil {
		return nil, err
	}
	return prof, nil
}

func handleCrash() {
	panic("handle invoke crash")
}

func handleUpdateConfig(params *UpdateParams) string {
	updateConfig(params)
	return ""
}

// handleClearEffect derives the provider directory from a profile ID so the
// method cannot be used as a general-purpose privileged file deletion API.
func handleClearEffect(profileId int64, response MethodResponse) {
	go func() {
		if !isInit.Load() {
			response.success("not initialized")
			return
		}
		if profileId <= 0 {
			response.success("invalid profile id")
			return
		}
		providersRoot := filepath.Join(
			constant.Path.HomeDir(),
			"profiles",
			"providers",
		)
		providersPath := filepath.Join(
			providersRoot,
			strconv.FormatInt(profileId, 10),
		)
		if err := os.RemoveAll(providersPath); err != nil {
			response.success(err.Error())
			return
		}
		_ = os.Remove(providersRoot)
		response.success("")
	}()
}

func handleSetupConfig(params *SetupParams) string {
	if !isInit.Load() {
		return "not initialized"
	}
	err := applyConfig(params)
	if err != nil {
		return err.Error()
	}
	return ""
}

func init() {
	adapter.UrlTestHook = func(url string, name string, delay uint16) {
		delayData := &Delay{
			Url:  url,
			Name: name,
		}
		if delay == 0 {
			delayData.Value = -1
		} else {
			delayData.Value = int32(delay)
		}
		sendMessage(Message{
			Type: DelayMessage,
			Data: delayData,
		})
	}
	statistic.DefaultRequestNotify = func(c statistic.Tracker) {
		sendMessage(Message{
			Type: RequestMessage,
			Data: c,
		})
	}
	executor.DefaultProviderLoadedHook = func(providerName string) {
		sendMessage(Message{
			Type: LoadedMessage,
			Data: providerName,
		})
	}
	updater.GeoUpdateHook = func(geoType string, updating bool, skipped bool, updateErr error) {
		status := GeoUpdateStatus{
			Type:     geoType,
			Updating: updating,
			Skipped:  skipped,
		}
		if updateErr != nil {
			status.Error = updateErr.Error()
		}
		sendMessage(Message{
			Type: GeoUpdateMessage,
			Data: status,
		})
	}
}
