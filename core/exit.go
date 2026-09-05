//go:build !(android && cgo)

package main

import (
	"fmt"
	"os"
	"os/signal"
	"syscall"
	"time"
)

const exitCleanupTimeout = 3 * time.Second // sing-tun's Linux policy routes outlive the process; only a shutdown removes them

func releaseOnExit() {
	if !isInit.Load() {
		return
	}
	done := make(chan struct{})
	go func() {
		defer close(done)
		handleShutdown()
	}()
	select {
	case <-done:
	case <-time.After(exitCleanupTimeout):
		fmt.Fprintln(os.Stderr, "[ERROR] core cleanup did not finish before exit")
	}
}

func exitOnTermination() {
	signals := make(chan os.Signal, 1)
	signal.Notify(signals, os.Interrupt, syscall.SIGTERM)
	<-signals
	releaseOnExit()
	os.Exit(0)
}
