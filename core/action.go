package main

import (
	"encoding/json"
)

type Action struct {
	Id     string      `json:"id"`
	Method Method      `json:"method"`
	Data   interface{} `json:"data"`
}

type ActionResult struct {
	Id     string      `json:"id"`
	Method Method      `json:"method"`
	Data   interface{} `json:"data"`
	Code   int         `json:"code"`
	Port   int64
}

func (result ActionResult) Json() ([]byte, error) {
	data, err := json.Marshal(result)
	return data, err
}

func (result ActionResult) success(data interface{}) {
	result.Code = 0
	result.Data = data
	result.send()
}

func (result ActionResult) error(data interface{}) {
	result.Code = -1
	result.Data = data
	result.send()
}

func handleAction(action *Action, result ActionResult) {
	switch action.Method {
	case initClashMethod:
		paramsString := action.Data.(string)
		result.success(handleInitClash(paramsString))
		return
	case getIsInitMethod:
		result.success(handleGetIsInit())
		return
	case forceGcMethod:
		handleForceGc()
		result.success(true)
		return
	case shutdownMethod:
		result.success(handleShutdown())
		return
	case validateConfigMethod:
		data := []byte(action.Data.(string))
		result.success(handleValidateConfig(data))
		return
	case updateConfigMethod:
		data := []byte(action.Data.(string))
		result.success(handleUpdateConfig(data))
		return
	case setupConfigMethod:
		data := []byte(action.Data.(string))
		result.success(handleSetupConfig(data))
		return
	case getProxiesMethod:
		result.success(handleGetProxies())
		return
	case changeProxyMethod:
		data := action.Data.(string)
		handleChangeProxy(data, func(value string) {
			result.success(value)
		})
		return
	case getTrafficMethod:
		result.success(handleGetTraffic())
		return
	case getTotalTrafficMethod:
		result.success(handleGetTotalTraffic())
		return
	case resetTrafficMethod:
		handleResetTraffic()
		result.success(true)
		return
	case asyncTestDelayMethod:
		data := action.Data.(string)
		handleAsyncTestDelay(data, func(value string) {
			result.success(value)
		})
		return
	case getConnectionsMethod:
		result.success(handleGetConnections())
		return
	case closeConnectionsMethod:
		result.success(handleCloseConnections())
		return
	case resetConnectionsMethod:
		result.success(handleResetConnections())
		return
	case getConfigMethod:
		path := action.Data.(string)
		config, err := handleGetConfig(path)
		if err != nil {
			result.error(err)
			return
		}
		result.success(config)
		return
	case closeConnectionMethod:
		id := action.Data.(string)
		result.success(handleCloseConnection(id))
		return
	case getExternalProvidersMethod:
		result.success(handleGetExternalProviders())
		return
	case getExternalProviderMethod:
		externalProviderName := action.Data.(string)
		result.success(handleGetExternalProvider(externalProviderName))
	case updateGeoDataMethod:
		paramsString := action.Data.(string)
		var params = map[string]string{}
		err := json.Unmarshal([]byte(paramsString), &params)
		if err != nil {
			result.success(err.Error())
			return
		}
		geoType := params["geo-type"]
		geoName := params["geo-name"]
		handleUpdateGeoData(geoType, geoName, func(value string) {
			result.success(value)
		})
		return
	case updateExternalProviderMethod:
		providerName := action.Data.(string)
		handleUpdateExternalProvider(providerName, func(value string) {
			result.success(value)
		})
		return
	case sideLoadExternalProviderMethod:
		paramsString := action.Data.(string)
		var params = map[string]string{}
		err := json.Unmarshal([]byte(paramsString), &params)
		if err != nil {
			result.success(err.Error())
			return
		}
		providerName := params["providerName"]
		data := params["data"]
		handleSideLoadExternalProvider(providerName, []byte(data), func(value string) {
			result.success(value)
		})
		return
	case startLogMethod:
		handleStartLog()
		result.success(true)
		return
	case stopLogMethod:
		handleStopLog()
		result.success(true)
		return
	case startListenerMethod:
		result.success(handleStartListener())
		return
	case stopListenerMethod:
		result.success(handleStopListener())
		return
	case getCountryCodeMethod:
		ip := action.Data.(string)
		handleGetCountryCode(ip, func(value string) {
			result.success(value)
		})
		return
	case getMemoryMethod:
		handleGetMemory(func(value string) {
			result.success(value)
		})
		return
	case setStateMethod:
		data := action.Data.(string)
		handleSetState(data)
		result.success(true)
	case crashMethod:
		result.success(true)
		handleCrash()
	default:
		nextHandle(action, result)
	}
}
