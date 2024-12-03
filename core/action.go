//go:build !cgo

package main

import (
	"encoding/json"
)

func (action Action) Json() ([]byte, error) {
	data, err := json.Marshal(action)
	return data, err
}

func (action Action) callback(data interface{}) bool {
	if conn == nil {
		return false
	}
	sendAction := Action{
		Id:     action.Id,
		Method: action.Method,
		Data:   data,
	}
	res, err := sendAction.Json()
	if err != nil {
		return false
	}
	_, err = conn.Write(append(res, []byte("\n")...))
	if err != nil {
		return false
	}
	return true
}
