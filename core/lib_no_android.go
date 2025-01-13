//go:build !android && cgo

package main

func nextHandle(action *Action) {
	return action
}

func nextHandle(action *Action, send func([]byte)) bool {
	return false
}
