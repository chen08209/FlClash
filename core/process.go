//go:build android

package main

import "C"
import (
	bridge "core/dart-bridge"
	"encoding/json"
	"errors"
	"github.com/metacubex/mihomo/component/process"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/log"
	"sync/atomic"
	"time"
)

var (
	counter int64
)

var processMap = make(map[int64]*string)

func init() {
	process.DefaultPackageNameResolver = func(metadata *constant.Metadata) (string, error) {
		if metadata == nil {
			return "", process.ErrInvalidNetwork
		}
		id := atomic.AddInt64(&counter, 1)

		timeout := time.After(200 * time.Millisecond)

		message := &bridge.Message{
			Type: bridge.Process,
			Data: Process{
				Id:       id,
				Metadata: *metadata,
			},
		}

		bridge.SendMessage(*message)

		for {
			select {
			case <-timeout:
				return "", errors.New("package resolver timeout")
			default:
				value, exists := processMap[counter]
				if exists {
					if value != nil {
						log.Infoln("[PKG] %s --> %s by [%s]", metadata.SourceAddress(), metadata.RemoteAddress(), *value)
						return *value, nil
					} else {
						return "", process.ErrInvalidNetwork
					}
				}
				time.Sleep(10 * time.Millisecond)
			}
		}
	}
}

//export setProcessMap
func setProcessMap(s *C.char) {
	go func() {
		paramsString := C.GoString(s)
		var processMapItem = &ProcessMapItem{}
		err := json.Unmarshal([]byte(paramsString), processMapItem)
		if err == nil {
			processMap[processMapItem.Id] = processMapItem.Value
		}
	}()
}
