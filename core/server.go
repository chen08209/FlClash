//go:build !cgo

package main

import (
	"encoding/binary"
	"encoding/json"
	"fmt"
	"io"
	"sync"
)

var (
	conn   io.ReadWriteCloser
	connMu sync.Mutex
)

const maxIPCFrameSize = 64 * 1024 * 1024

func (response MethodResponse) send() {
	data, err := response.JSON()
	if err != nil {
		logError("MethodResponse marshal error: id=%s err=%v", response.ID, err)
		return
	}
	send(data)
}

func sendMessageBatch(messages []Message) {
	call := MethodCall{
		Method:    messageMethod,
		Arguments: mustMarshalJSON(messages),
	}
	data, err := json.Marshal(call)
	if err != nil {
		logError("MethodCall marshal error: method=%s err=%v", call.Method, err)
		return
	}
	send(data)
}

func writeFrame(w io.Writer, data []byte) error {
	if len(data) > maxIPCFrameSize {
		return fmt.Errorf("IPC frame exceeds %d bytes", maxIPCFrameSize)
	}
	lenBuf := [4]byte{}
	binary.LittleEndian.PutUint32(lenBuf[:], uint32(len(data)))
	if err := writeAll(w, lenBuf[:]); err != nil {
		return err
	}
	return writeAll(w, data)
}

func writeAll(w io.Writer, data []byte) error {
	for len(data) > 0 {
		n, err := w.Write(data)
		if err != nil {
			return err
		}
		if n == 0 {
			return io.ErrShortWrite
		}
		data = data[n:]
	}
	return nil
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
	if conn == nil {
		logError("send conn nil")
		return
	}
	connMu.Lock()
	defer connMu.Unlock()
	if err := writeFrame(conn, data); err != nil {
		logError("server write error: %v", err)
	}
}

func startServer(arg string) {
	var err error
	conn, err = dial(arg)
	if err != nil {
		panic(err.Error())
	}

	defer func(conn io.Closer) {
		_ = conn.Close()
	}(conn)

	for {
		data, err := readFrame(conn)
		if err != nil {
			if err != io.EOF {
				logError("server read error: %v", err)
			}
			return
		}
		call := &MethodCall{}

		err = json.Unmarshal(data, call)

		if err != nil {
			logError("server unmarshal error: %v (data: %q)", err, data)
			continue
		}

		response := MethodResponse{
			ID: call.ID,
		}

		go handleMethodCall(call, response)
	}
}

func handlePlatformMethodCall(call *MethodCall, response MethodResponse) bool {
	return false
}
