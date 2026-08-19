package main

import (
	"encoding/json"
	"fmt"
	"runtime"
	"unsafe"
)

type MethodCall struct {
	ID        string          `json:"id,omitempty"`
	Method    CoreMethod      `json:"method"`
	Arguments json.RawMessage `json:"arguments"`
}

func (call MethodCall) decodeArguments(target any) error {
	if len(call.Arguments) == 0 || string(call.Arguments) == "null" {
		return fmt.Errorf("missing arguments")
	}
	return json.Unmarshal(call.Arguments, target)
}

func decodeMethodArguments(call *MethodCall, response MethodResponse, target any) bool {
	if err := call.decodeArguments(target); err != nil {
		response.failure(
			"invalid_arguments",
			fmt.Sprintf("invalid arguments for %s: %v", call.Method, err),
			nil,
		)
		return false
	}
	return true
}

type MethodError struct {
	Code    string `json:"code"`
	Message string `json:"message"`
	Details any    `json:"details"`
}

type MethodResponse struct {
	ID       string       `json:"id,omitempty"`
	Result   any          `json:"result"`
	Error    *MethodError `json:"error,omitempty"`
	callback unsafe.Pointer
}

func (response MethodResponse) JSON() ([]byte, error) {
	return json.Marshal(response)
}

func (response MethodResponse) success(result any) {
	response.Result = result
	response.Error = nil
	response.send()
}

func (response MethodResponse) failure(code, message string, details any) {
	response.Result = nil
	response.Error = &MethodError{
		Code:    code,
		Message: message,
		Details: details,
	}
	response.send()
}

func (response MethodResponse) notImplemented(method CoreMethod) {
	response.failure(
		"not_implemented",
		fmt.Sprintf("unknown method: %s", method),
		nil,
	)
}

func handleMethodCall(call *MethodCall, response MethodResponse) {
	// The crash method is a developer-only fatal-path test. It must bypass the
	// recovery below so the core process terminates; on Android this also
	// terminates the in-process application.
	if call.Method == crashMethod {
		handleCrash()
		return
	}
	defer func() {
		if r := recover(); r != nil {
			buf := make([]byte, 4096)
			n := runtime.Stack(buf, false)
			logError("panic in handleMethodCall(%s): %v\n%s", call.Method, r, buf[:n])
			response.failure("internal_error", fmt.Sprintf("internal panic: %v", r), nil)
		}
	}()
	switch call.Method {
	case initClashMethod:
		params := InitParams{}
		if !decodeMethodArguments(call, response, &params) {
			return
		}
		response.success(handleInitClash(&params))
		return
	case getIsInitMethod:
		response.success(handleGetIsInit())
		return
	case forceGcMethod:
		handleForceGC()
		response.success(true)
		return
	case shutdownMethod:
		response.success(handleShutdown())
		return
	case validateConfigMethod:
		path := ""
		if !decodeMethodArguments(call, response, &path) {
			return
		}
		response.success(handleValidateConfig(path))
		return
	case updateConfigMethod:
		params := UpdateParams{}
		if !decodeMethodArguments(call, response, &params) {
			return
		}
		response.success(handleUpdateConfig(&params))
		return
	case setupConfigMethod:
		params := defaultSetupParams()
		if !decodeMethodArguments(call, response, params) {
			return
		}
		response.success(handleSetupConfig(params))
		return
	case getProxiesMethod:
		response.success(handleGetProxies())
		return
	case changeProxyMethod:
		params := ChangeProxyParams{}
		if !decodeMethodArguments(call, response, &params) {
			return
		}
		handleChangeProxy(&params, func(value string) {
			response.success(value)
		})
		return
	case getTrafficMethod:
		onlyStatisticsProxy := false
		if !decodeMethodArguments(call, response, &onlyStatisticsProxy) {
			return
		}
		response.success(handleGetTraffic(onlyStatisticsProxy))
		return
	case getTotalTrafficMethod:
		onlyStatisticsProxy := false
		if !decodeMethodArguments(call, response, &onlyStatisticsProxy) {
			return
		}
		response.success(handleGetTotalTraffic(onlyStatisticsProxy))
		return
	case getTrafficSnapshotMethod:
		onlyStatisticsProxy := false
		if !decodeMethodArguments(call, response, &onlyStatisticsProxy) {
			return
		}
		response.success(handleGetTrafficSnapshot(onlyStatisticsProxy))
		return
	case resetTrafficMethod:
		handleResetTraffic()
		response.success(true)
		return
	case asyncTestDelayMethod:
		params := TestDelayParams{}
		if !decodeMethodArguments(call, response, &params) {
			return
		}
		handleAsyncTestDelay(&params, func(value *Delay) {
			response.success(value)
		})
		return
	case getConnectionsMethod:
		response.success(handleGetConnections())
		return
	case closeConnectionsMethod:
		response.success(handleCloseConnections())
		return
	case resetConnectionsMethod:
		response.success(handleResetConnections())
		return
	case getConfigMethod:
		path := ""
		if !decodeMethodArguments(call, response, &path) {
			return
		}
		config, err := handleGetConfig(path)
		if err != nil {
			response.failure("core_error", err.Error(), nil)
			return
		}
		response.success(config)
		return
	case closeConnectionMethod:
		id := ""
		if !decodeMethodArguments(call, response, &id) {
			return
		}
		response.success(handleCloseConnection(id))
		return
	case getExternalProvidersMethod:
		response.success(handleGetExternalProviders())
		return
	case getExternalProviderMethod:
		externalProviderName := ""
		if !decodeMethodArguments(call, response, &externalProviderName) {
			return
		}
		response.success(handleGetExternalProvider(externalProviderName))
		return
	case updateGeoDataMethod:
		geoType := ""
		if !decodeMethodArguments(call, response, &geoType) {
			return
		}
		handleUpdateGeoData(geoType)
		response.success("")
		return
	case updateExternalProviderMethod:
		providerName := ""
		if !decodeMethodArguments(call, response, &providerName) {
			return
		}
		handleUpdateExternalProvider(providerName, func(value string) {
			response.success(value)
		})
		return
	case sideLoadExternalProviderMethod:
		params := map[string]string{}
		if !decodeMethodArguments(call, response, &params) {
			return
		}
		providerName := params["providerName"]
		data := params["data"]
		handleSideLoadExternalProvider(providerName, []byte(data), func(value string) {
			response.success(value)
		})
		return
	case startLogMethod:
		handleStartLog()
		response.success(true)
		return
	case stopLogMethod:
		handleStopLog()
		response.success(true)
		return
	case startListenerMethod:
		response.success(handleStartListener())
		return
	case stopListenerMethod:
		response.success(handleStopListener())
		return
	case getCountryCodeMethod:
		ip := ""
		if !decodeMethodArguments(call, response, &ip) {
			return
		}
		handleGetCountryCode(ip, func(value string) {
			response.success(value)
		})
		return
	case getMemoryMethod:
		handleGetMemory(func(value uint64) {
			response.success(value)
		})
		return
	case clearEffectMethod:
		var profileId int64
		if !decodeMethodArguments(call, response, &profileId) {
			return
		}
		handleClearEffect(profileId, response)
		return
	default:
		if !handlePlatformMethodCall(call, response) {
			response.notImplemented(call.Method)
		}
	}
}
