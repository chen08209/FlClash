//go:build !(darwin || linux) || android

package main

func initOwnership(homeDir string) {}

func scheduleReclaimOwnership() {}
