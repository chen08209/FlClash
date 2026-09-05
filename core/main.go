//go:build !(android && cgo)

package main

import (
	"fmt"
	"os"
)

func main() {
	args := os.Args
	if len(args) <= 1 {
		fmt.Fprintln(os.Stderr, "Arguments error")
		os.Exit(1)
	}
	go exitOnTermination()
	startServer(args[1])
}
