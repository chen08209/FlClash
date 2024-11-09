package main

import "C"
import (
	"core/state"
	"encoding/json"
	"fmt"
)

//export getCurrentProfileName
func getCurrentProfileName() *C.char {
	if state.CurrentState == nil {
		return C.CString("")
	}
	return C.CString(state.CurrentState.CurrentProfileName)
}

//export getAndroidVpnOptions
func getAndroidVpnOptions() *C.char {
	options := state.AndroidVpnOptions{
		Enable:           state.CurrentState.Enable,
		Port:             state.CurrentRawConfig.MixedPort,
		Ipv4Address:      state.DefaultIpv4Address,
		Ipv6Address:      state.GetIpv6Address(),
		AccessControl:    state.CurrentState.AccessControl,
		SystemProxy:      state.CurrentState.SystemProxy,
		AllowBypass:      state.CurrentState.AllowBypass,
		RouteAddress:     state.CurrentState.RouteAddress,
		BypassDomain:     state.CurrentState.BypassDomain,
		DnsServerAddress: state.GetDnsServerAddress(),
	}
	data, err := json.Marshal(options)
	if err != nil {
		fmt.Println("Error:", err)
		return C.CString("")
	}
	return C.CString(string(data))
}

//export setState
func setState(s *C.char) {
	paramsString := C.GoString(s)
	err := json.Unmarshal([]byte(paramsString), state.CurrentState)
	if err != nil {
		return
	}
}
