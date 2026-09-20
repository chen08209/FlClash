package main

import (
	"sync"
	"testing"
)

func TestHostDelayTrackingIsScopedAndReferenceCounted(t *testing.T) {
	url, name := "https://tracking.test/", "tracking-node"
	first := beginHostDelayTest(url, name)
	second := beginHostDelayTest(url, name)
	if !isHostDelayTest(url, name) {
		t.Fatal("active probes were not tracked")
	}
	if isHostDelayTest(url+"other", name) || isHostDelayTest(url, name+"-other") {
		t.Fatal("unrelated probes were suppressed")
	}
	first()
	if !isHostDelayTest(url, name) {
		t.Fatal("first completion released the second probe")
	}
	second()
	if isHostDelayTest(url, name) {
		t.Fatal("completed probes remained tracked")
	}
	hostDelayTests.Lock()
	_, retained := hostDelayTests.pending[hostDelayKey{url: url, name: name}]
	hostDelayTests.Unlock()
	if retained {
		t.Fatal("completed key was retained")
	}
}

func TestHostDelayTrackingSupportsConcurrentCompletions(t *testing.T) {
	const count = 32
	url, name := "https://tracking.test/concurrent", "tracking-node"
	var started, completed sync.WaitGroup
	started.Add(count)
	completed.Add(count)
	release := make(chan struct{})
	for i := 0; i < count; i++ {
		go func() {
			defer completed.Done()
			finish := beginHostDelayTest(url, name)
			started.Done()
			<-release
			finish()
		}()
	}
	started.Wait()
	if !isHostDelayTest(url, name) {
		t.Error("concurrent probes were not tracked")
	}
	close(release)
	completed.Wait()
	if isHostDelayTest(url, name) {
		t.Error("concurrent completions leaked tracking")
	}
}
