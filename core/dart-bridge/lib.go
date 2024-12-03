//go:build cgo

package dart_bridge

/*
#include <stdlib.h>
#include "stdint.h"
#include "include/dart_api_dl.h"
#include "include/dart_api_dl.c"
#include "include/dart_native_api.h"

bool GoDart_PostCObject(Dart_Port_DL port, Dart_CObject* obj) {
  return Dart_PostCObject_DL(port, obj);
}
*/
import "C"
import (
	"fmt"
	"unsafe"
)

func InitDartApi(api unsafe.Pointer) {
	if C.Dart_InitializeApiDL(api) != 0 {
		panic("failed to create dart bridge")
	} else {
		fmt.Println("Dart Api DL is initialized")
	}
}

func SendToPort(port int64, msg string) bool {
	var obj C.Dart_CObject
	obj._type = C.Dart_CObject_kString
	msgString := C.CString(msg)
	defer C.free(unsafe.Pointer(msgString))
	ptr := unsafe.Pointer(&obj.value[0])
	*(**C.char)(ptr) = msgString
	isSuccess := C.GoDart_PostCObject(C.Dart_Port_DL(port), &obj)
	if !isSuccess {
		return false
	}
	return true
}
