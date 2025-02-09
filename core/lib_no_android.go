//go:build !android && cgo

package main

func nextHandle(action *Action, result func(data interface{})) bool {
	return false
}
