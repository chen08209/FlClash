//go:build cgo

package main

import (
	bridge "core/dart-bridge"
)

var (
	Port        int64 = -1
	ServicePort int64 = -1
)

func SendMessage(message Message) {
	s, err := message.Json()
	if err != nil {
		return
	}
	if handler, ok := messageHandlers[message.Type]; ok {
		handler(s)
	} else {
		sendToPort(s)
	}
}

var messageHandlers = map[MessageType]func(string) bool{
	ProtectMessage: sendToServicePort,
	ProcessMessage: sendToServicePort,
	StartedMessage: conditionalSend,
	LoadedMessage:  conditionalSend,
}

func sendToPort(s string) bool {
	return bridge.SendToPort(Port, s)
}

func sendToServicePort(s string) bool {
	return bridge.SendToPort(ServicePort, s)
}

func conditionalSend(s string) bool {
	isSuccess := sendToPort(s)
	if !isSuccess {
		return sendToServicePort(s)
	}
	return isSuccess
}
