package main

import "sync"

type hostDelayKey struct {
	url  string
	name string
}

var hostDelayTests = struct {
	sync.Mutex
	pending map[hostDelayKey]int
}{pending: make(map[hostDelayKey]int)}

func beginHostDelayTest(url, name string) func() {
	key := hostDelayKey{url: url, name: name}
	hostDelayTests.Lock()
	hostDelayTests.pending[key]++
	hostDelayTests.Unlock()
	return func() {
		hostDelayTests.Lock()
		defer hostDelayTests.Unlock()
		hostDelayTests.pending[key]--
		if hostDelayTests.pending[key] == 0 {
			delete(hostDelayTests.pending, key)
		}
	}
}

func isHostDelayTest(url, name string) bool {
	hostDelayTests.Lock()
	defer hostDelayTests.Unlock()
	return hostDelayTests.pending[hostDelayKey{url: url, name: name}] > 0
}
