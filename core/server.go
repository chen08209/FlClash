//go:build !cgo

package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"net"
	"strconv"
)

var conn net.Conn = nil

func startServer(arg string) {
	_, err := strconv.Atoi(arg)
	if err != nil {
		conn, err = net.Dial("unix", arg)
	} else {
		conn, err = net.Dial("tcp", fmt.Sprintf("127.0.0.1:%s", arg))
	}
	if err != nil {
		panic(err.Error())
	}

	defer func(conn net.Conn) {
		_ = conn.Close()
	}(conn)

	reader := bufio.NewReader(conn)

	for {
		data, err := reader.ReadString('\n')
		if err != nil {
			return
		}
		var action = &Action{}

		err = json.Unmarshal([]byte(data), action)

		if err != nil {
			return
		}

		go handleAction(action)
	}
}

func handleAction(action *Action) {
	switch action.Method {
	case initClashMethod:
		data := action.Data.(string)
		action.callback(handleInitClash(data))
		return
	case getIsInitMethod:
		action.callback(handleGetIsInit())
		return
	case forceGcMethod:
		handleForceGc()
		return
	case shutdownMethod:
		action.callback(handleShutdown())
		return
	case validateConfigMethod:
		data := []byte(action.Data.(string))
		action.callback(handleValidateConfig(data))
		return
	case updateConfigMethod:
		data := []byte(action.Data.(string))
		action.callback(handleUpdateConfig(data))
		return
	case getProxiesMethod:
		action.callback(handleGetProxies())
		return
	case changeProxyMethod:
		data := action.Data.(string)
		handleChangeProxy(data, func(value string) {
			action.callback(value)
		})
		return
	case getTrafficMethod:
		data := action.Data.(bool)
		action.callback(handleGetTraffic(data))
		return
	case getTotalTrafficMethod:
		data := action.Data.(bool)
		action.callback(handleGetTotalTraffic(data))
		return
	case resetTrafficMethod:
		handleResetTraffic()
		return
	case asyncTestDelayMethod:
		data := action.Data.(string)
		handleAsyncTestDelay(data, func(value string) {
			action.callback(value)
		})
		return
	case getConnectionsMethod:
		action.callback(handleGetConnections())
		return
	case closeConnectionsMethod:
		action.callback(handleCloseConnections())
		return
	case closeConnectionMethod:
		id := action.Data.(string)
		action.callback(handleCloseConnection(id))
		return
	case getExternalProvidersMethod:
		action.callback(handleGetExternalProviders())
		return
	case getExternalProviderMethod:
		externalProviderName := action.Data.(string)
		action.callback(handleGetExternalProvider(externalProviderName))
	case updateGeoDataMethod:
		paramsString := action.Data.(string)
		var params = map[string]string{}
		err := json.Unmarshal([]byte(paramsString), &params)
		if err != nil {
			action.callback(err.Error())
			return
		}
		geoType := params["geoType"]
		geoName := params["geoName"]
		handleUpdateGeoData(geoType, geoName, func(value string) {
			action.callback(value)
		})
		return
	case updateExternalProviderMethod:
		providerName := action.Data.(string)
		handleUpdateExternalProvider(providerName, func(value string) {
			action.callback(value)
		})
		return
	case sideLoadExternalProviderMethod:
		paramsString := action.Data.(string)
		var params = map[string]string{}
		err := json.Unmarshal([]byte(paramsString), &params)
		if err != nil {
			action.callback(err.Error())
			return
		}
		providerName := params["providerName"]
		data := params["data"]
		handleSideLoadExternalProvider(providerName, []byte(data), func(value string) {
			action.callback(value)
		})
		return
	case startLogMethod:
		handleStartLog()
		return
	case stopLogMethod:
		handleStopLog()
		return
	case startListenerMethod:
		action.callback(handleStartListener())
		return
	case stopListenerMethod:
		action.callback(handleStopListener())
		return
	case getCountryCodeMethod:
		ip := action.Data.(string)
		handleGetCountryCode(ip, func(value string) {
			action.callback(value)
		})
		return
	case getMemoryMethod:
		handleGetMemory(func(value string) {
			action.callback(value)
		})
		return
	}

}
