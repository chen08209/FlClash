//go:build android

package main

import "C"
import (
	"encoding/json"
	"fmt"
)

type AccessControl struct {
	Mode              string   `json:"mode"`
	AcceptList        []string `json:"acceptList"`
	RejectList        []string `json:"rejectList"`
	IsFilterSystemApp bool     `json:"isFilterSystemApp"`
}

type AndroidProps struct {
	AccessControl *AccessControl `json:"accessControl"`
	AllowBypass   bool           `json:"allowBypass"`
	SystemProxy   bool           `json:"systemProxy"`
}

var androidProps AndroidProps

//export getAndroidProps
func getAndroidProps() *C.char {
	data, err := json.Marshal(androidProps)
	if err != nil {
		fmt.Println("Error:", err)
		return C.CString("")
	}
	return C.CString(string(data))
}

//export setAndroidProps
func setAndroidProps(s *C.char) {
	paramsString := C.GoString(s)
	err := json.Unmarshal([]byte(paramsString), &androidProps)
	if err != nil {
		return
	}
}
