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
	Run     MessageType = "run"
	Loaded  MessageType = "loaded"
)

type Message struct {
	Type MessageType `json:"type"`
	Data interface{} `json:"data"`
}

func (message *Message) Json() (string, error) {
	data, err := json.Marshal(message)
	return string(data), err
}

func SendMessage(message Message) {
	if Port == nil {
		return
	}
	s, err := message.Json()
	if err != nil {
		return
	}
	SendToPort(*Port, s)
}
