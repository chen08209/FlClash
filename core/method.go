package core

import (
	"encoding/json"
	"errors"
	"fmt"
	"runtime"
	"sync/atomic"
)

type MethodCall struct {
	ID        string          `json:"id,omitempty"`
	Method    CoreMethod      `json:"method"`
	Arguments json.RawMessage `json:"arguments"`
	seq       uint64
}

type MethodError struct {
	Code    string `json:"code"`
	Message string `json:"message"`
	Details any    `json:"details"`
}

func (e *MethodError) Error() string {
	return e.Message
}

type MethodResponse struct {
	ID     string       `json:"id,omitempty"`
	Result any          `json:"result"`
	Error  *MethodError `json:"error,omitempty"`
	File   string       `json:"file,omitempty"`
}

var methodCallSeq atomic.Uint64

// Each call runs on its own goroutine, so a handler that must honour the
// host's latest intent compares seq, stamped here in arrival order; every
// transport has to deliver calls in the order the host sent them.
func dispatchMethodCall(call *MethodCall, reply func(data []byte)) {
	call.seq = methodCallSeq.Add(1)
	// A developer-only fatal-path test. It runs outside every recovery so the
	// core process terminates; on Android that is the whole application.
	if call.Method == coreCrashMethod {
		go handleCrash()
		return
	}
	safeGo(string(call.Method), func() {
		reply(handleMethodCall(call))
	})
}

func handleCrash() {
	panic("handle invoke crash")
}

func handleMethodCall(call *MethodCall) (data []byte) {
	defer func() {
		if r := recover(); r != nil {
			logError("panic in %s: %v\n%s", call.Method, r, stackTrace())
			data = encodeResponse(MethodResponse{ID: call.ID, Error: &MethodError{
				Code:    "internal_error",
				Message: fmt.Sprintf("internal panic: %v", r),
			}})
		}
	}()

	handler, exists := methodHandlers[call.Method]
	if !exists {
		return encodeResponse(MethodResponse{ID: call.ID, Error: &MethodError{
			Code:    "not_implemented",
			Message: fmt.Sprintf("unknown method: %s", call.Method),
		}})
	}
	result, err := handler(call)
	if err != nil {
		return encodeResponse(MethodResponse{ID: call.ID, Error: asMethodError(err)})
	}
	return spillResponse(call.ID, encodeResponse(MethodResponse{ID: call.ID, Result: result}))
}

func encodeResponse(response MethodResponse) []byte {
	data, err := json.Marshal(response)
	if err == nil {
		return data
	}
	logError("MethodResponse marshal error: id=%s err=%v", response.ID, err)
	data, _ = json.Marshal(MethodResponse{ID: response.ID, Error: &MethodError{
		Code:    "internal_error",
		Message: "encode response: " + err.Error(),
	}})
	return data
}

func asMethodError(err error) *MethodError {
	var methodErr *MethodError
	if errors.As(err, &methodErr) {
		return methodErr
	}
	return &MethodError{Code: "core_error", Message: err.Error()}
}

func stackTrace() []byte {
	buf := make([]byte, 4096)
	return buf[:runtime.Stack(buf, false)]
}

func safeGo(name string, run func()) {
	go func() {
		defer func() {
			if r := recover(); r != nil {
				logError("panic in %s: %v\n%s", name, r, stackTrace())
			}
		}()
		run()
	}()
}

func (call MethodCall) decodeArguments(target any) error {
	if len(call.Arguments) == 0 || string(call.Arguments) == "null" {
		return errors.New("missing arguments")
	}
	return json.Unmarshal(call.Arguments, target)
}

func decodeArguments[P any](call *MethodCall) (params P, err error) {
	if decodeErr := call.decodeArguments(&params); decodeErr != nil {
		return params, &MethodError{
			Code:    "invalid_arguments",
			Message: fmt.Sprintf("invalid arguments for %s: %v", call.Method, decodeErr),
		}
	}
	return params, nil
}

type methodHandler func(call *MethodCall) (any, error)

func withArguments[P, R any](run func(P) R) methodHandler {
	return withFallible(func(params P) (R, error) {
		return run(params), nil
	})
}

func withFallible[P, R any](run func(P) (R, error)) methodHandler {
	return func(call *MethodCall) (any, error) {
		params, err := decodeArguments[P](call)
		if err != nil {
			return nil, err
		}
		return run(params)
	}
}

func withoutArguments[R any](run func() R) methodHandler {
	return func(*MethodCall) (any, error) {
		return run(), nil
	}
}

func fallibleWithoutArguments[R any](run func() (R, error)) methodHandler {
	return func(*MethodCall) (any, error) {
		return run()
	}
}

// command answers null, or the error run returns.
func command[P any](run func(P) error) methodHandler {
	return func(call *MethodCall) (any, error) {
		params, err := decodeArguments[P](call)
		if err != nil {
			return nil, err
		}
		return nil, run(params)
	}
}

func action(run func()) methodHandler {
	return func(*MethodCall) (any, error) {
		run()
		return nil, nil
	}
}

var methodHandlers = map[CoreMethod]methodHandler{
	coreInitMethod:        command(handleInit),
	coreInitializedMethod: withoutArguments(handleInitialized),
	coreGCMethod:          action(handleForceGC),
	coreMemoryMethod:      withoutArguments(handleGetMemoryStats),

	configSetupMethod:    command(handleSetupConfig),
	configUpdateMethod:   command(updateConfig),
	configValidateMethod: withArguments(handleValidateConfig),
	configDecryptMethod:  withFallible(handleDecryptConfig),
	configReadMethod:     withFallible(handleReadConfig),

	profileBaseMethod:        withFallible(handleGetProfileBase),
	profileOutboundsMethod:   withFallible(handleGetProfileOutbounds),
	profileBuildMethod:       withFallible(handleBuildProfile),
	profileClearEffectMethod: command(handleClearEffect),

	proxyListMethod:       withoutArguments(handleGetProxies),
	proxySelectMethod:     withArguments(handleChangeProxy),
	proxyDefinitionMethod: withFallible(handleGetProxyDefinition),
	proxyTestDelayMethod:  withArguments(handleTestDelay),
	proxyValidateMethod:   withArguments(handleValidateProxies),
	proxyConvertMethod:    withFallible(handleConvertProxies),
	shareLinkEncodeMethod: withArguments(handleEncodeShareLinks),
	shareLinkDecodeMethod: withArguments(handleDecodeShareLinks),
	filterValidateMethod:  withArguments(handleValidateFilters),

	providerListMethod:     withoutArguments(handleGetExternalProviders),
	providerGetMethod:      withArguments(handleGetExternalProvider),
	providerUpdateMethod:   command(handleUpdateExternalProvider),
	providerSideLoadMethod: command(handleSideLoadExternalProvider),
	ruleSetDumpMethod:      withFallible(handleDumpRuleSet),
	ruleSetCompileMethod:   withFallible(handleCompileRuleSet),
	geoUpdateMethod:        command(handleUpdateGeoData),

	trafficCurrentMethod:     withArguments(handleGetTraffic),
	trafficTotalMethod:       withArguments(handleGetTotalTraffic),
	trafficResetMethod:       action(handleResetTraffic),
	connectionListMethod:     withoutArguments(handleGetConnections),
	connectionCountMethod:    withoutArguments(handleGetConnectionCount),
	connectionCloseMethod:    command(handleCloseConnection),
	connectionCloseAllMethod: action(handleCloseConnections),
	connectionResetMethod:    action(handleResetConnections),
	dnsClearCacheMethod:      action(handleClearDnsCache),
	networkChangedMethod:     action(handleNetworkChanged),

	logStartMethod:      action(handleStartLog),
	logStopMethod:       action(handleStopLog),
	listenerStartMethod: action(handleStartListener),
	listenerStopMethod:  action(handleStopListener),
	routeWatchMethod:    watchRouteHandler,
	routeCheckMethod:    withArguments(handleCheckRoutes),

	probeOutboundIPMethod: withArguments(handleOutboundIp),
	probeServicesMethod:   withArguments(handleServiceCheck),
}

func watchRouteHandler(call *MethodCall) (any, error) {
	params, err := decodeArguments[WatchParams](call)
	if err != nil {
		return nil, err
	}
	return handleWatchRoute(params.Watch, call.seq), nil
}
