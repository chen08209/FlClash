package main

import (
	"encoding/json"
	"github.com/metacubex/mihomo/adapter/provider"
	"github.com/metacubex/mihomo/config"
	"time"
)

type ConfigExtendedParams struct {
	IsPatch             bool              `json:"is-patch"`
	IsCompatible        bool              `json:"is-compatible"`
	SelectedMap         map[string]string `json:"selected-map"`
	TestURL             *string           `json:"test-url"`
	OverrideDns         bool              `json:"override-dns"`
	OnlyStatisticsProxy bool              `json:"only-statistics-proxy"`
}

type GenerateConfigParams struct {
	ProfileId string               `json:"profile-id"`
	Config    config.RawConfig     `json:"config" `
	Params    ConfigExtendedParams `json:"params"`
}

type ChangeProxyParams struct {
	GroupName *string `json:"group-name"`
	ProxyName *string `json:"proxy-name"`
}

type TestDelayParams struct {
	ProxyName string `json:"proxy-name"`
	TestUrl   string `json:"test-url"`
	Timeout   int64  `json:"timeout"`
}

type ExternalProvider struct {
	Name             string                     `json:"name"`
	Type             string                     `json:"type"`
	VehicleType      string                     `json:"vehicle-type"`
	Count            int                        `json:"count"`
	Path             string                     `json:"path"`
	UpdateAt         time.Time                  `json:"update-at"`
	SubscriptionInfo *provider.SubscriptionInfo `json:"subscription-info"`
}

const (
	messageMethod                  Method = "message"
	initClashMethod                Method = "initClash"
	getIsInitMethod                Method = "getIsInit"
	forceGcMethod                  Method = "forceGc"
	shutdownMethod                 Method = "shutdown"
	validateConfigMethod           Method = "validateConfig"
	updateConfigMethod             Method = "updateConfig"
	getProxiesMethod               Method = "getProxies"
	changeProxyMethod              Method = "changeProxy"
	getTrafficMethod               Method = "getTraffic"
	getTotalTrafficMethod          Method = "getTotalTraffic"
	resetTrafficMethod             Method = "resetTraffic"
	asyncTestDelayMethod           Method = "asyncTestDelay"
	getConnectionsMethod           Method = "getConnections"
	closeConnectionsMethod         Method = "closeConnections"
	closeConnectionMethod          Method = "closeConnection"
	getExternalProvidersMethod     Method = "getExternalProviders"
	getExternalProviderMethod      Method = "getExternalProvider"
	getCountryCodeMethod           Method = "getCountryCode"
	getMemoryMethod                Method = "getMemory"
	updateGeoDataMethod            Method = "updateGeoData"
	updateExternalProviderMethod   Method = "updateExternalProvider"
	sideLoadExternalProviderMethod Method = "sideLoadExternalProvider"
	startLogMethod                 Method = "startLog"
	stopLogMethod                  Method = "stopLog"
	startListenerMethod            Method = "startListener"
	stopListenerMethod             Method = "stopListener"
	startTunMethod                 Method = "startTun"
	stopTunMethod                  Method = "stopTun"
	updateDnsMethod                Method = "updateDns"
	setProcessMapMethod            Method = "setProcessMap"
	setFdMapMethod                 Method = "setFdMap"
	setStateMethod                 Method = "setState"
	getAndroidVpnOptionsMethod     Method = "getAndroidVpnOptions"
	getRunTimeMethod               Method = "getRunTime"
	getCurrentProfileNameMethod    Method = "getCurrentProfileName"
)

type Method string

type MessageType string

type Delay struct {
	Url   string `json:"url"`
	Name  string `json:"name"`
	Value int32  `json:"value"`
}

type Message struct {
	Type MessageType `json:"type"`
	Data interface{} `json:"data"`
}

const (
	LogMessage     MessageType = "log"
	DelayMessage   MessageType = "delay"
	RequestMessage MessageType = "request"
	LoadedMessage  MessageType = "loaded"
)

func (message *Message) Json() (string, error) {
	data, err := json.Marshal(message)
	return string(data), err
}

type InvokeMessage struct {
	Type InvokeType  `json:"type"`
	Data interface{} `json:"data"`
}

type InvokeType string

const (
	ProtectInvoke InvokeType = "protect"
	ProcessInvoke InvokeType = "process"
)

func (message *InvokeMessage) Json() string {
	data, _ := json.Marshal(message)
	return string(data)
}
