package main

import "C"
import (
	bridge "core/dart-bridge"
	"github.com/metacubex/mihomo/common/observable"
	"github.com/metacubex/mihomo/log"
)

var logSubscriber observable.Subscription[log.Event]

//export startLog
func startLog() {
	if logSubscriber != nil {
		log.UnSubscribe(logSubscriber)
		logSubscriber = nil
	}
	logSubscriber = log.Subscribe()
	go func() {
		for logData := range logSubscriber {
			if logData.LogLevel < log.Level() {
				continue
			}
			message := &bridge.Message{
				Type: bridge.Log,
				Data: logData,
			}
			bridge.SendMessage(*message)
		}
	}()
}

//export stopLog
func stopLog() {
	if logSubscriber != nil {
		log.UnSubscribe(logSubscriber)
		logSubscriber = nil
	}
}
