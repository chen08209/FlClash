package main

import (
	"encoding/json"
)

type Action struct {
	Id           string      `json:"id"`
	Method       Method      `json:"method"`
	Data         interface{} `json:"data"`
	DefaultValue interface{} `json:"default-value"`
}

type ActionResult struct {
	Id     string      `json:"id"`
	Method Method      `json:"method"`
	Data   interface{} `json:"data"`
}

func (result ActionResult) Json() ([]byte, error) {
	data, err := json.Marshal(result)
	return data, err
}

func (action Action) getResult(data interface{}) []byte {
	resultAction := ActionResult{
		Id:     action.Id,
		Method: action.Method,
		Data:   data,
	}
	res, _ := resultAction.Json()
	return res
}

func handleAction(action *Action, result func(data interface{})) {
	switch action.Method {
	case initClashMethod:
		data := action.Data.(string)
		result(handleInitClash(data))
		return
	case getIsInitMethod:
		result(handleGetIsInit())
		return
	case forceGcMethod:
		handleForceGc()
		result(true)
		return
	case shutdownMethod:
		result(handleShutdown())
		return
	case validateConfigMethod:
		data := []byte(action.Data.(string))
		result(handleValidateConfig(data))
		return
	case updateConfigMethod:
		data := []byte(action.Data.(string))
		result(handleUpdateConfig(data))
		return
	case getProxiesMethod:
		result(handleGetProxies())
		return
	case changeProxyMethod:
		data := action.Data.(string)
		handleChangeProxy(data, func(value string) {
			result(value)
		})
		return
	case getTrafficMethod:
		result(handleGetTraffic())
		return
	case getTotalTrafficMethod:
		result(handleGetTotalTraffic())
		return
	case resetTrafficMethod:
		handleResetTraffic()
		result(true)
		return
	case asyncTestDelayMethod:
		data := action.Data.(string)
		handleAsyncTestDelay(data, func(value string) {
			result(value)
		})
		return
	case getConnectionsMethod:
		result(handleGetConnections())
		return
	case closeConnectionsMethod:
		result(handleCloseConnections())
		return
	case closeConnectionMethod:
		id := action.Data.(string)
		result(handleCloseConnection(id))
		return
	case getExternalProvidersMethod:
		result(handleGetExternalProviders())
		return
	case getExternalProviderMethod:
		externalProviderName := action.Data.(string)
		result(handleGetExternalProvider(externalProviderName))
	case updateGeoDataMethod:
		paramsString := action.Data.(string)
		var params = map[string]string{}
		err := json.Unmarshal([]byte(paramsString), &params)
		if err != nil {
			result(err.Error())
			return
		}
		geoType := params["geo-type"]
		geoName := params["geo-name"]
		handleUpdateGeoData(geoType, geoName, func(value string) {
			result(value)
		})
		return
	case updateExternalProviderMethod:
		providerName := action.Data.(string)
		handleUpdateExternalProvider(providerName, func(value string) {
			result(value)
		})
		return
	case sideLoadExternalProviderMethod:
		paramsString := action.Data.(string)
		var params = map[string]string{}
		err := json.Unmarshal([]byte(paramsString), &params)
		if err != nil {
			result(err.Error())
			return
		}
		providerName := params["providerName"]
		data := params["data"]
		handleSideLoadExternalProvider(providerName, []byte(data), func(value string) {
			result(value)
		})
		return
	case startLogMethod:
		handleStartLog()
		result(true)
		return
	case stopLogMethod:
		handleStopLog()
		result(true)
		return
	case startListenerMethod:
		result(handleStartListener())
		return
	case stopListenerMethod:
		result(handleStopListener())
		return
	case getCountryCodeMethod:
		ip := action.Data.(string)
		handleGetCountryCode(ip, func(value string) {
			result(value)
		})
		return
	case getMemoryMethod:
		handleGetMemory(func(value string) {
			result(value)
		})
		return
	case getProfileMethod:
		profileId := action.Data.(string)
		handleGetMemory(func(value string) {
			result(handleGetProfile(profileId))
		})
		return
	case setStateMethod:
		data := action.Data.(string)
		handleSetState(data)
		result(true)
	default:
		handle := nextHandle(action, result)
		if handle {
			return
		} else {
			result(action.DefaultValue)
		}
	}
}
