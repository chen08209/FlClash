//go:build cgo

package main

/*
#include <stdlib.h>
*/
import "C"
import (
	bridge "core/dart-bridge"
	"encoding/json"
	"unsafe"
)

var messagePort int64 = -1

//export initNativeApiBridge
func initNativeApiBridge(api unsafe.Pointer) {
	bridge.InitDartApi(api)
}

//export attachMessagePort
func attachMessagePort(mPort C.longlong) {
	messagePort = int64(mPort)
}

//export getTraffic
func getTraffic() *C.char {
	return C.CString(handleGetTraffic())
}

//export getTotalTraffic
func getTotalTraffic() *C.char {
	return C.CString(handleGetTotalTraffic())
}

//export freeCString
func freeCString(s *C.char) {
	C.free(unsafe.Pointer(s))
}

func (result ActionResult) send() {
	data, err := result.Json()
	if err != nil {
		return
	}
	bridge.SendToPort(result.Port, string(data))
}

//export invokeAction
func invokeAction(paramsChar *C.char, port C.longlong) {
	params := C.GoString(paramsChar)
	i := int64(port)
	var action = &Action{}
	err := json.Unmarshal([]byte(params), action)
	if err != nil {
		bridge.SendToPort(i, err.Error())
		return
	}
	result := ActionResult{
		Id:     action.Id,
		Method: action.Method,
		Port:   i,
	}
	go handleAction(action, result)
}

func sendMessage(message Message) {
	if messagePort == -1 {
		return
	}
	result := ActionResult{
		Method: messageMethod,
		Port:   messagePort,
		Data:   message,
	}
	result.send()
}

//export getConfig
func getConfig(s *C.char) *C.char {
	path := C.GoString(s)
	config, err := handleGetConfig(path)
	if err != nil {
		return C.CString("")
	}
	marshal, err := json.Marshal(config)
	if err != nil {
		return C.CString("")
	}
	return C.CString(string(marshal))
}

//export startListener
func startListener() {
	handleStartListener()
}

//export stopListener
func stopListener() {
	handleStopListener()
}
