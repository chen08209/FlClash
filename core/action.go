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

func (action Action) wrapMessage(data interface{}) []byte {
	sendAction := ActionResult{
		Id:     action.Id,
		Method: action.Method,
		Data:   data,
	}
	res, _ := sendAction.Json()
	return res
}

func handleAction(action *Action, send func([]byte)) {
	switch action.Method {
	case initClashMethod:
		data := action.Data.(string)
		send(action.wrapMessage(handleInitClash(data)))
		return
	case getIsInitMethod:
		send(action.wrapMessage(handleGetIsInit()))
		return
	case forceGcMethod:
		handleForceGc()
		send(action.wrapMessage(true))
		return
	case shutdownMethod:
		send(action.wrapMessage(handleShutdown()))
		return
	case validateConfigMethod:
		data := []byte(action.Data.(string))
		send(action.wrapMessage(handleValidateConfig(data)))
		return
	case updateConfigMethod:
		data := []byte(action.Data.(string))
		send(action.wrapMessage(handleUpdateConfig(data)))
		return
	case getProxiesMethod:
		send(action.wrapMessage(handleGetProxies()))
		return
	case changeProxyMethod:
		data := action.Data.(string)
		handleChangeProxy(data, func(value string) {
			send(action.wrapMessage(value))
		})
		return
	case getTrafficMethod:
		send(action.wrapMessage(handleGetTraffic()))
		return
	case getTotalTrafficMethod:
		send(action.wrapMessage(handleGetTotalTraffic()))
		return
	case resetTrafficMethod:
		handleResetTraffic()
		send(action.wrapMessage(true))
		return
	case asyncTestDelayMethod:
		data := action.Data.(string)
		handleAsyncTestDelay(data, func(value string) {
			send(action.wrapMessage(value))
		})
		return
	case getConnectionsMethod:
		send(action.wrapMessage(handleGetConnections()))
		return
	case closeConnectionsMethod:
		send(action.wrapMessage(handleCloseConnections()))
		return
	case closeConnectionMethod:
		id := action.Data.(string)
		send(action.wrapMessage(handleCloseConnection(id)))
		return
	case getExternalProvidersMethod:
		send(action.wrapMessage(handleGetExternalProviders()))
		return
	case getExternalProviderMethod:
		externalProviderName := action.Data.(string)
		send(action.wrapMessage(handleGetExternalProvider(externalProviderName)))
	case updateGeoDataMethod:
		paramsString := action.Data.(string)
		var params = map[string]string{}
		err := json.Unmarshal([]byte(paramsString), &params)
		if err != nil {
			send(action.wrapMessage(err.Error()))
			return
		}
		geoType := params["geo-type"]
		geoName := params["geo-name"]
		handleUpdateGeoData(geoType, geoName, func(value string) {
			send(action.wrapMessage(value))
		})
		return
	case updateExternalProviderMethod:
		providerName := action.Data.(string)
		handleUpdateExternalProvider(providerName, func(value string) {
			send(action.wrapMessage(value))
		})
		return
	case sideLoadExternalProviderMethod:
		paramsString := action.Data.(string)
		var params = map[string]string{}
		err := json.Unmarshal([]byte(paramsString), &params)
		if err != nil {
			send(action.wrapMessage(err.Error()))
			return
		}
		providerName := params["providerName"]
		data := params["data"]
		handleSideLoadExternalProvider(providerName, []byte(data), func(value string) {
			send(action.wrapMessage(value))
		})
		return
	case startLogMethod:
		handleStartLog()
		send(action.wrapMessage(true))
		return
	case stopLogMethod:
		handleStopLog()
		send(action.wrapMessage(true))
		return
	case startListenerMethod:
		send(action.wrapMessage(handleStartListener()))
		return
	case stopListenerMethod:
		send(action.wrapMessage(handleStopListener()))
		return
	case getCountryCodeMethod:
		ip := action.Data.(string)
		handleGetCountryCode(ip, func(value string) {
			send(action.wrapMessage(value))
		})
		return
	case getMemoryMethod:
		handleGetMemory(func(value string) {
			send(action.wrapMessage(value))
		})
		return
	default:
		handle := nextHandle(action, send)
		if handle {
			return
		} else {
			send(action.wrapMessage(action.DefaultValue))
		}
	}
}
