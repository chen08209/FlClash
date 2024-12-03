//go:build !cgo

package main

func SendMessage(message Message) {
	s, err := message.Json()
	if err != nil {
		return
	}
	Action{
		Method: messageMethod,
	}.callback(s)
}
