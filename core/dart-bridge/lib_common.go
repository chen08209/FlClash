//go:build !cgo

package dart_bridge

func SendToPort(port int64, msg string) bool {
	return false
}
