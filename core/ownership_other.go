//go:build !(darwin || linux) || android

package core

func initOwnership(homeDir string) {}

func scheduleReclaimOwnership() {}
