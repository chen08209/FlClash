//go:build cgo

package main

/*
#include <stdlib.h>
*/
import "C"
import (
	bridge "core/dart-bridge"
	"unsafe"
)

//export initNativeApiBridge
func initNativeApiBridge(api unsafe.Pointer) {
	bridge.InitDartApi(api)
}

//export initMessage
func initMessage(port C.longlong) {
	i := int64(port)
	Port = i
}

//export freeCString
func freeCString(s *C.char) {
	C.free(unsafe.Pointer(s))
}

//export initClash
func initClash(homeDirStr *C.char) bool {
	return handleInitClash(C.GoString(homeDirStr))
}

//export startListener
func startListener() {
	handleStartListener()
}

//export stopListener
func stopListener() {
	handleStopListener()
}

//export getIsInit
func getIsInit() bool {
	return handleGetIsInit()
}

//export shutdownClash
func shutdownClash() bool {
	return handleShutdown()
}

//export forceGc
func forceGc() {
	handleForceGc()
}

//export validateConfig
func validateConfig(s *C.char, port C.longlong) {
	i := int64(port)
	bytes := []byte(C.GoString(s))
	go func() {
		bridge.SendToPort(i, handleValidateConfig(bytes))
	}()
}

//export updateConfig
func updateConfig(s *C.char, port C.longlong) {
	i := int64(port)
	bytes := []byte(C.GoString(s))
	go func() {
		bridge.SendToPort(i, handleUpdateConfig(bytes))
	}()
}

//export getProxies
func getProxies() *C.char {
	return C.CString(handleGetProxies())
}

//export changeProxy
func changeProxy(s *C.char, port C.longlong) {
	i := int64(port)
	paramsString := C.GoString(s)
	handleChangeProxy(paramsString, func(value string) {
		bridge.SendToPort(i, value)
	})
}

//export getTraffic
func getTraffic(port C.int) *C.char {
	onlyProxy := int(port) == 1
	return C.CString(handleGetTraffic(onlyProxy))
}

//export getTotalTraffic
func getTotalTraffic(port C.int) *C.char {
	onlyProxy := int(port) == 1
	return C.CString(handleGetTotalTraffic(onlyProxy))
}

//export resetTraffic
func resetTraffic() {
	handleResetTraffic()
}

//export asyncTestDelay
func asyncTestDelay(s *C.char, port C.longlong) {
	i := int64(port)
	paramsString := C.GoString(s)
	handleAsyncTestDelay(paramsString, func(value string) {
		bridge.SendToPort(i, value)
	})
}

//export getConnections
func getConnections() *C.char {
	return C.CString(handleGetConnections())
}

//export getMemory
func getMemory(port C.longlong) {
	i := int64(port)
	handleGetMemory(func(value string) {
		bridge.SendToPort(i, value)
	})
}

//export closeConnections
func closeConnections() {
	handleCloseConnections()
}

//export closeConnection
func closeConnection(id *C.char) {
	connectionId := C.GoString(id)
	handleCloseConnection(connectionId)
}

//export getExternalProviders
func getExternalProviders() *C.char {
	return C.CString(handleGetExternalProviders())
}

//export getExternalProvider
func getExternalProvider(externalProviderNameChar *C.char) *C.char {
	externalProviderName := C.GoString(externalProviderNameChar)
	return C.CString(handleGetExternalProvider(externalProviderName))
}

//export updateGeoData
func updateGeoData(geoTypeChar *C.char, geoNameChar *C.char, port C.longlong) {
	i := int64(port)
	geoType := C.GoString(geoTypeChar)
	geoName := C.GoString(geoNameChar)
	handleUpdateGeoData(geoType, geoName, func(value string) {
		bridge.SendToPort(i, value)
	})
}

//export updateExternalProvider
func updateExternalProvider(providerNameChar *C.char, port C.longlong) {
	i := int64(port)
	providerName := C.GoString(providerNameChar)
	handleUpdateExternalProvider(providerName, func(value string) {
		bridge.SendToPort(i, value)
	})
}

//export getCountryCode
func getCountryCode(ipChar *C.char, port C.longlong) {
	ip := C.GoString(ipChar)
	i := int64(port)
	handleGetCountryCode(ip, func(value string) {
		bridge.SendToPort(i, value)
	})
}

//export sideLoadExternalProvider
func sideLoadExternalProvider(providerNameChar *C.char, dataChar *C.char, port C.longlong) {
	i := int64(port)
	providerName := C.GoString(providerNameChar)
	data := []byte(C.GoString(dataChar))
	handleSideLoadExternalProvider(providerName, data, func(value string) {
		bridge.SendToPort(i, value)
	})
}

//export startLog
func startLog() {
	handleStartLog()
}

//export stopLog
func stopLog() {
	handleStopLog()
}
