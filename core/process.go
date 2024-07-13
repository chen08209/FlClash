//go:build android

package main

import "C"
import (
	"encoding/json"
	"errors"
	"github.com/metacubex/mihomo/component/process"
	"github.com/metacubex/mihomo/constant"
	"sync"
	"sync/atomic"
	"time"
)

type ProcessMap struct {
	m sync.Map
}

func (cm *ProcessMap) Store(key int64, value string) {
	cm.m.Store(key, value)
}

func (cm *ProcessMap) Load(key int64) (string, bool) {
	value, ok := cm.m.Load(key)
	if !ok || value == nil {
		return "", false
	}
	return value.(string), true
}

var counter int64 = 0

var processMap ProcessMap

func init() {
	process.DefaultPackageNameResolver = func(metadata *constant.Metadata) (string, error) {
		if metadata == nil {
			return "", process.ErrInvalidNetwork
		}
		id := atomic.AddInt64(&counter, 1)

		timeout := time.After(200 * time.Millisecond)

		SendMessage(Message{
			Type: ProcessMessage,
			Data: Process{
				Id:       id,
				Metadata: metadata,
			},
		})

		for {
			select {
			case <-timeout:
				return "", errors.New("package resolver timeout")
			default:
				value, exists := processMap.Load(id)
				if exists {
					return value, nil
				}
				time.Sleep(20 * time.Millisecond)
			}
		}
	}
}

//export setProcessMap
func setProcessMap(s *C.char) {
	if s == nil {
		return
	}
	paramsString := C.GoString(s)
	go func() {
		var processMapItem = &ProcessMapItem{}
		err := json.Unmarshal([]byte(paramsString), processMapItem)
		if err == nil {
			processMap.Store(processMapItem.Id, processMapItem.Value)
		}
	}()
}
