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
}

var methodCallSeq atomic.Uint64

// Each call runs on its own goroutine, so a handler that must honour the
// host's latest intent compares seq, stamped here in arrival order; every
// transport has to deliver calls in the order the host sent them.
func dispatchMethodCall(call *MethodCall, reply func(data []byte)) {
	call.seq = methodCallSeq.Add(1)
	// A developer-only fatal-path test. It runs outside every recovery so the
	// core process terminates; on Android that is the whole application.
	if call.Method == crashMethod {
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
	return encodeResponse(MethodResponse{ID: call.ID, Result: result})
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

// The host reads the result of these methods as a message that is empty on
// success. A *MethodError is the structured form and still fails the call.
func withMessage[P any](run func(P) error) methodHandler {
	return withFallible(func(params P) (string, error) {
		err := run(params)
		var methodErr *MethodError
		if err == nil || errors.As(err, &methodErr) {
			return "", err
		}
		return err.Error(), nil
	})
}

func withoutArguments[R any](run func() R) methodHandler {
	return func(*MethodCall) (any, error) {
		return run(), nil
	}
}

func acknowledged(run func()) methodHandler {
	return func(*MethodCall) (any, error) {
		run()
		return true, nil
	}
}

var methodHandlers = map[CoreMethod]methodHandler{
	initClashMethod:                withArguments(handleInitClash),
	getIsInitMethod:                withoutArguments(handleGetIsInit),
	forceGcMethod:                  acknowledged(handleForceGC),
	shutdownMethod:                 withoutArguments(handleShutdown),
	startListenerMethod:            withoutArguments(handleStartListener),
	stopListenerMethod:             withoutArguments(handleStopListener),
	getMemoryStatsMethod:           withoutArguments(handleGetMemoryStats),
	startLogMethod:                 acknowledged(handleStartLog),
	stopLogMethod:                  acknowledged(handleStopLog),
	validateConfigMethod:           withMessage(handleValidateConfig),
	decryptConfigMethod:            withFallible(handleDecryptConfig),
	getConfigMethod:                withFallible(handleGetConfig),
	setupConfigMethod:              withMessage(handleSetupConfig),
	updateConfigMethod:             withMessage(updateConfig),
	validateProxiesMethod:          withArguments(handleValidateProxies),
	validateFiltersMethod:          withArguments(handleValidateFilters),
	convertProxiesMethod:           withFallible(handleConvertProxies),
	encodeShareLinksMethod:         withArguments(handleEncodeShareLinks),
	decodeShareLinksMethod:         withArguments(handleDecodeShareLinks),
	getProxiesMethod:               withoutArguments(handleGetProxies),
	changeProxyMethod:              withArguments(handleChangeProxy),
	asyncTestDelayMethod:           withArguments(handleTestDelay),
	watchRouteMethod:               watchRouteHandler,
	probeMethod:                    withArguments(handleProbe),
	outboundIpMethod:               withArguments(handleOutboundIp),
	serviceCheckMethod:             withArguments(handleServiceCheck),
	getTrafficMethod:               withArguments(handleGetTraffic),
	getTotalTrafficMethod:          withArguments(handleGetTotalTraffic),
	resetTrafficMethod:             acknowledged(handleResetTraffic),
	getConnectionsMethod:           withoutArguments(handleGetConnections),
	getConnectionCountMethod:       withoutArguments(handleGetConnectionCount),
	closeConnectionsMethod:         withoutArguments(handleCloseConnections),
	resetConnectionsMethod:         withoutArguments(handleResetConnections),
	closeConnectionMethod:          withArguments(handleCloseConnection),
	getExternalProvidersMethod:     withoutArguments(handleGetExternalProviders),
	getExternalProviderMethod:      withArguments(handleGetExternalProvider),
	updateExternalProviderMethod:   withMessage(handleUpdateExternalProvider),
	sideLoadExternalProviderMethod: withMessage(handleSideLoadExternalProvider),
	updateGeoDataMethod:            withMessage(handleUpdateGeoData),
	dumpRuleSetMethod:              withFallible(handleDumpRuleSet),
	compileRuleSetMethod:           withFallible(handleCompileRuleSet),
	clearEffectMethod:              withMessage(handleClearEffect),
}

func watchRouteHandler(call *MethodCall) (any, error) {
	watch, err := decodeArguments[bool](call)
	if err != nil {
		return nil, err
	}
	return handleWatchRoute(watch, call.seq), nil
}

func registerMethod(method CoreMethod, handler methodHandler) {
	if _, exists := methodHandlers[method]; exists {
		panic(fmt.Sprintf("duplicate handler for method %s", method))
	}
	methodHandlers[method] = handler
}
