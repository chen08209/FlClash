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
	go handleAction(action, func(data interface{}) {
		bridge.SendToPort(i, string(action.getResult(data)))
	})
}

func sendMessage(message Message) {
	if messagePort == -1 {
		return
	}
	res, err := message.Json()
	if err != nil {
		return
	}
	bridge.SendToPort(messagePort, string(Action{
		Method: messageMethod,
	}.getResult(res)))
}

//export startListener
func startListener() {
	handleStartListener()
}

//export stopListener
func stopListener() {
	handleStopListener()
}
