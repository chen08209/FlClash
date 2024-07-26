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

type State struct {
	AndroidProps
	MixedPort int  `json:"mixedPort"`
	OnlyProxy bool `json:"onlyProxy"`
}

var state State

//export getState
func getState() *C.char {
	data, err := json.Marshal(state)
	if err != nil {
		fmt.Println("Error:", err)
		return C.CString("")
	}
	return C.CString(string(data))
}

//export setState
func setState(s *C.char) {
	paramsString := C.GoString(s)
	err := json.Unmarshal([]byte(paramsString), &state)
	if err != nil {
		return
	}
}
