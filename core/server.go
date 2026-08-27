//go:build !(android && cgo)

package main

import (
	"encoding/binary"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"os"
	"sync"
	"sync/atomic"
	"time"
)

type ipcConn interface {
	io.ReadWriteCloser
	SetWriteDeadline(t time.Time) error
}

var (
	conn    ipcConn
	connMu  sync.Mutex
	writeMu sync.Mutex
)

const (
	maxIPCFrameSize        = 64 * 1024 * 1024
	ipcWriteTimeout        = 10 * time.Second
	ipcPartialFrameRetries = 6
)

var deliveryFailureReported atomic.Bool

// logDeliveryError must not reach the mihomo logger: a log event is published
// to the log subscriber, batched, and handed back to send, so reporting a send
// failure through it feeds the failure straight back into itself.
func logDeliveryError(format string, args ...any) {
	if deliveryFailureReported.Swap(true) {
		return
	}
	fmt.Fprintf(os.Stderr, "[ERROR] "+format+"\n", args...)
}

func (response MethodResponse) send() {
	data, err := response.JSON()
	if err != nil {
		logError("MethodResponse marshal error: id=%s err=%v", response.ID, err)
		return
	}
	send(data)
}

func deliverEvent(data []byte) {
	send(data)
}

func writeFrame(w io.Writer, data []byte) (int, error) {
	if len(data) > maxIPCFrameSize {
		return 0, fmt.Errorf("IPC frame exceeds %d bytes", maxIPCFrameSize)
	}
	lenBuf := [4]byte{}
	binary.LittleEndian.PutUint32(lenBuf[:], uint32(len(data)))
	written, err := writeAll(w, lenBuf[:])
	if err != nil {
		return written, err
	}
	n, err := writeAll(w, data)
	return written + n, err
}

type resumingWriter struct {
	conn    ipcConn
	written int
	stalls  int
}

func (writer *resumingWriter) Write(data []byte) (int, error) {
	accepted := 0
	for {
		n, err := writer.conn.Write(data[accepted:])
		accepted += n
		writer.written += n
		if err == nil {
			return accepted, nil
		}
		if accepted >= len(data) || !writer.resume(err) {
			return accepted, err
		}
	}
}

func (writer *resumingWriter) resume(err error) bool {
	if writer.written == 0 || writer.stalls >= ipcPartialFrameRetries {
		return false
	}
	if !errors.Is(err, os.ErrDeadlineExceeded) {
		return false
	}
	writer.stalls++
	return writer.conn.SetWriteDeadline(time.Now().Add(ipcWriteTimeout)) == nil
}

func writeAll(w io.Writer, data []byte) (int, error) {
	written := 0
	for len(data) > 0 {
		n, err := w.Write(data)
		written += n
		if err != nil {
			return written, err
		}
		if n == 0 {
			return written, io.ErrShortWrite
		}
		data = data[n:]
	}
	return written, nil
}

func readFrame(r io.Reader) ([]byte, error) {
	lenBuf := make([]byte, 4)
	if _, err := io.ReadFull(r, lenBuf); err != nil {
		return nil, err
	}
	length := binary.LittleEndian.Uint32(lenBuf)
	if length > maxIPCFrameSize {
		return nil, fmt.Errorf("IPC frame exceeds %d bytes", maxIPCFrameSize)
	}
	data := make([]byte, int(length))
	if _, err := io.ReadFull(r, data); err != nil {
		return nil, err
	}
	return data, nil
}

func send(data []byte) {
	writeMu.Lock()
	defer writeMu.Unlock()

	connMu.Lock()
	c := conn
	connMu.Unlock()

	if c == nil {
		logDeliveryError("send conn nil")
		return
	}
	if err := c.SetWriteDeadline(time.Now().Add(ipcWriteTimeout)); err != nil {
		logDeliveryError("server write deadline error: %v", err)
	}
	written, err := writeFrame(&resumingWriter{conn: c}, data)
	if err == nil {
		deliveryFailureReported.Store(false)
		return
	}
	if written == 0 {
		logDeliveryError("server write error, dropped one frame: %v", err)
		return
	}
	logDeliveryError("server write error after %d bytes: %v", written, err)
	connMu.Lock()
	if conn == c {
		conn = nil
	}
	connMu.Unlock()
	_ = c.Close()
}

func startServer(arg string) {
	dialed, err := dial(arg)
	if err != nil {
		panic(err.Error())
	}
	defer func() {
		connMu.Lock()
		c := conn
		conn = nil
		connMu.Unlock()
		if c != nil {
			_ = c.Close()
		}
	}()

	connMu.Lock()
	conn = dialed
	deliveryFailureReported.Store(false)
	connMu.Unlock()

	for {
		data, err := readFrame(dialed)
		if err != nil {
			if err != io.EOF {
				logError("server read error: %v", err)
			}
			return
		}

		call := &MethodCall{}
		if err := json.Unmarshal(data, call); err != nil {
			logError("server unmarshal error: %v (data: %q)", err, data)
			continue
		}

		go handleMethodCall(call, newMethodResponse(call.ID, nil))
	}
}
