package dart_bridge

import "encoding/json"

var Port *int64

type MessageType string

const (
	Log     MessageType = "log"
	Tun     MessageType = "tun"
	Delay   MessageType = "delay"
	Now     MessageType = "now"
	Process MessageType = "process"
	Request MessageType = "request"
)

type Message struct {
	Type MessageType `json:"type"`
	Data interface{} `json:"data"`
}

func (message *Message) Json() string {
	data, _ := json.Marshal(message)
	return string(data)
}

func SendMessage(message Message) {
	SendToPort(*Port, message.Json())
}
