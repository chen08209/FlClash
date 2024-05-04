package dart_bridge

import "encoding/json"

var Port *int64

type MessageType string

const (
	Log     MessageType = "log"
	Tun     MessageType = "tun"
	Delay   MessageType = "delay"
	Process MessageType = "process"
)

type Message struct {
	Type MessageType `json:"type"`
	Data interface{} `json:"data"`
}

func (message *Message) toJson() string {
	data, _ := json.Marshal(message)
	return string(data)
}

func SendMessage(message Message) {
	SendToPort(*Port, message.toJson())
}
