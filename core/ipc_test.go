//go:build !cgo

package main

import (
	"bytes"
	"encoding/binary"
	"encoding/json"
	"errors"
	"io"
	"os"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/metacubex/mihomo/common/observable"
	"github.com/metacubex/mihomo/log"
)

type fakeConn struct {
	mu            sync.Mutex
	written       bytes.Buffer
	readable      *bytes.Reader
	writeErr      error
	writeErrAfter int
	closed        bool
	deadlines     int
}

func (fake *fakeConn) Read(p []byte) (int, error) {
	if fake.readable == nil {
		return 0, io.EOF
	}
	return fake.readable.Read(p)
}

func (fake *fakeConn) Write(p []byte) (int, error) {
	fake.mu.Lock()
	defer fake.mu.Unlock()
	if fake.writeErr != nil {
		if fake.writeErrAfter <= 0 {
			return 0, fake.writeErr
		}
		accepted := min(fake.writeErrAfter, len(p))
		fake.writeErrAfter -= accepted
		written, err := fake.written.Write(p[:accepted])
		if err != nil {
			return written, err
		}
		return written, fake.writeErr
	}
	return fake.written.Write(p)
}

func (fake *fakeConn) setWriteErr(err error) {
	fake.mu.Lock()
	defer fake.mu.Unlock()
	fake.writeErr = err
	fake.written.Reset()
}

func (fake *fakeConn) Close() error {
	fake.mu.Lock()
	defer fake.mu.Unlock()
	fake.closed = true
	return nil
}

func (fake *fakeConn) SetWriteDeadline(time.Time) error {
	fake.mu.Lock()
	defer fake.mu.Unlock()
	fake.deadlines++
	return nil
}

func (fake *fakeConn) isClosed() bool {
	fake.mu.Lock()
	defer fake.mu.Unlock()
	return fake.closed
}

func (fake *fakeConn) frames(t *testing.T) [][]byte {
	t.Helper()
	fake.mu.Lock()
	defer fake.mu.Unlock()
	reader := bytes.NewReader(fake.written.Bytes())
	var frames [][]byte
	for {
		frame, err := readFrame(reader)
		if err == io.EOF {
			return frames
		}
		if err != nil {
			t.Fatalf("readFrame error: %v", err)
		}
		frames = append(frames, frame)
	}
}

// swapConn installs a connection the way send reads one. The message batcher
// runs for the whole test binary and reads conn under connMu, so a bare
// assignment here is a data race against every event it happens to deliver.
func swapConn(next ipcConn) ipcConn {
	connMu.Lock()
	defer connMu.Unlock()
	previous := conn
	conn = next
	return previous
}

func captureFrames(t *testing.T, run func()) [][]byte {
	t.Helper()
	fake := &fakeConn{}
	previous := swapConn(fake)
	defer swapConn(previous)
	run()
	return fake.frames(t)
}

func captureSingleFrame(t *testing.T, run func()) []byte {
	t.Helper()
	frames := captureFrames(t, run)
	if len(frames) != 1 {
		t.Fatalf("captured %d frames, want 1", len(frames))
	}
	return frames[0]
}

func TestWriteFrameReadFrameRoundTrip(t *testing.T) {
	payloads := [][]byte{
		[]byte(""),
		[]byte("{}"),
		bytes.Repeat([]byte("x"), 70000),
	}

	buffer := &bytes.Buffer{}
	for _, payload := range payloads {
		if _, err := writeFrame(buffer, payload); err != nil {
			t.Fatalf("writeFrame error: %v", err)
		}
	}

	for i, payload := range payloads {
		got, err := readFrame(buffer)
		if err != nil {
			t.Fatalf("readFrame %d error: %v", i, err)
		}
		if !bytes.Equal(got, payload) {
			t.Errorf("frame %d length = %d, want %d", i, len(got), len(payload))
		}
	}
}

func TestWriteFrameRejectsOversizedPayload(t *testing.T) {
	written, err := writeFrame(&bytes.Buffer{}, make([]byte, maxIPCFrameSize+1))

	if written != 0 {
		t.Errorf("writeFrame wrote %d bytes for a rejected payload, want 0", written)
	}
	if err == nil {
		t.Fatal("writeFrame accepted a payload above the frame limit")
	}
	if !strings.Contains(err.Error(), "IPC frame exceeds") {
		t.Errorf("writeFrame error = %v, want an IPC frame limit error", err)
	}
}

func TestReadFrameRejectsOversizedHeader(t *testing.T) {
	header := make([]byte, 4)
	binary.LittleEndian.PutUint32(header, maxIPCFrameSize+1)

	_, err := readFrame(bytes.NewReader(header))

	if err == nil {
		t.Fatal("readFrame accepted a header above the frame limit")
	}
	if !strings.Contains(err.Error(), "IPC frame exceeds") {
		t.Errorf("readFrame error = %v, want an IPC frame limit error", err)
	}
}

func TestReadFrameRejectsTruncatedPayload(t *testing.T) {
	header := make([]byte, 4)
	binary.LittleEndian.PutUint32(header, 8)
	truncated := append(header, []byte("abc")...)

	if _, err := readFrame(bytes.NewReader(truncated)); err == nil {
		t.Fatal("readFrame accepted a truncated payload")
	}
}

func TestMethodResponseSuccessEnvelope(t *testing.T) {
	frame := captureSingleFrame(t, func() {
		MethodResponse{ID: "42"}.success(map[string]any{"ok": true})
	})

	var envelope map[string]any
	if err := json.Unmarshal(frame, &envelope); err != nil {
		t.Fatalf("response is not valid JSON: %v", err)
	}
	if envelope["id"] != "42" {
		t.Errorf("id = %v, want 42", envelope["id"])
	}
	if _, hasError := envelope["error"]; hasError {
		t.Error("a successful response must omit the error field")
	}
	result, ok := envelope["result"].(map[string]any)
	if !ok || result["ok"] != true {
		t.Errorf("result = %v, want {ok: true}", envelope["result"])
	}
}

func TestMethodResponseFailureEnvelope(t *testing.T) {
	frame := captureSingleFrame(t, func() {
		MethodResponse{ID: "7"}.failure("core_error", "boom", []string{"detail"})
	})

	var envelope struct {
		ID     string       `json:"id"`
		Result any          `json:"result"`
		Error  *MethodError `json:"error"`
	}
	if err := json.Unmarshal(frame, &envelope); err != nil {
		t.Fatalf("response is not valid JSON: %v", err)
	}
	if envelope.ID != "7" {
		t.Errorf("id = %s, want 7", envelope.ID)
	}
	if envelope.Result != nil {
		t.Errorf("result = %v, want null on failure", envelope.Result)
	}
	if envelope.Error == nil {
		t.Fatal("failure response must carry an error")
	}
	if envelope.Error.Code != "core_error" || envelope.Error.Message != "boom" {
		t.Errorf("error = %+v, want code core_error message boom", envelope.Error)
	}
}

func TestDecodeMethodArgumentsRejectsInvalidPayloads(t *testing.T) {
	tests := []struct {
		name      string
		arguments string
	}{
		{name: "missing", arguments: ""},
		{name: "null", arguments: "null"},
		{name: "wrong type", arguments: `"not-an-object"`},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			call := &MethodCall{
				ID:        "1",
				Method:    initClashMethod,
				Arguments: json.RawMessage(test.arguments),
			}
			target := InitParams{}
			accepted := true

			frame := captureSingleFrame(t, func() {
				accepted = decodeMethodArguments(call, MethodResponse{ID: call.ID}, &target)
			})

			if accepted {
				t.Fatal("decodeMethodArguments accepted an invalid payload")
			}
			var envelope struct {
				Error *MethodError `json:"error"`
			}
			if err := json.Unmarshal(frame, &envelope); err != nil {
				t.Fatalf("response is not valid JSON: %v", err)
			}
			if envelope.Error == nil || envelope.Error.Code != "invalid_arguments" {
				t.Errorf("error = %+v, want code invalid_arguments", envelope.Error)
			}
		})
	}
}

func TestDecodeMethodArgumentsAcceptsValidPayload(t *testing.T) {
	call := &MethodCall{
		ID:        "1",
		Method:    initClashMethod,
		Arguments: json.RawMessage(`{"home-dir":"/tmp/flclash","version":3}`),
	}
	target := InitParams{}

	frames := captureFrames(t, func() {
		if !decodeMethodArguments(call, MethodResponse{ID: call.ID}, &target) {
			t.Fatal("decodeMethodArguments rejected a valid payload")
		}
	})

	if len(frames) != 0 {
		t.Errorf("a successful decode must not send a response, got %d frames", len(frames))
	}
	if target.HomeDir != "/tmp/flclash" || target.Version != 3 {
		t.Errorf("decoded params = %+v, want {/tmp/flclash 3}", target)
	}
}

func TestHandleMethodCallReportsUnknownMethod(t *testing.T) {
	frame := captureSingleFrame(t, func() {
		handleMethodCall(
			&MethodCall{ID: "9", Method: CoreMethod("nopeMethod")},
			MethodResponse{ID: "9"},
		)
	})

	var envelope struct {
		Error *MethodError `json:"error"`
	}
	if err := json.Unmarshal(frame, &envelope); err != nil {
		t.Fatalf("response is not valid JSON: %v", err)
	}
	if envelope.Error == nil || envelope.Error.Code != "not_implemented" {
		t.Fatalf("error = %+v, want code not_implemented", envelope.Error)
	}
	if !strings.Contains(envelope.Error.Message, "nopeMethod") {
		t.Errorf("error message = %s, want it to name the method", envelope.Error.Message)
	}
}

func TestSendMessageBatchWrapsMessagesInMethodCall(t *testing.T) {
	batch := []Message{
		{Type: DelayMessage, Data: Delay{Url: "https://example.test", Name: "a", Value: 12}},
		{Type: LogMessage, Data: "hello"},
	}

	frame := captureSingleFrame(t, func() {
		sendMessageBatch(batch)
	})

	call := MethodCall{}
	if err := json.Unmarshal(frame, &call); err != nil {
		t.Fatalf("batch frame is not a MethodCall: %v", err)
	}
	if call.Method != messageMethod {
		t.Errorf("method = %s, want %s", call.Method, messageMethod)
	}
	if call.ID != "" {
		t.Errorf("id = %s, want an empty id for event calls", call.ID)
	}

	var decoded []Message
	if err := json.Unmarshal(call.Arguments, &decoded); err != nil {
		t.Fatalf("arguments are not a message list: %v", err)
	}
	if len(decoded) != 2 {
		t.Fatalf("decoded %d messages, want 2", len(decoded))
	}
	if decoded[0].Type != DelayMessage || decoded[1].Type != LogMessage {
		t.Errorf("decoded types = %s,%s, want delay,log", decoded[0].Type, decoded[1].Type)
	}
}

func TestSendWithoutConnectionDoesNotPanic(t *testing.T) {
	previous := swapConn(nil)
	defer swapConn(previous)

	send([]byte("{}"))
}

func TestMethodResponseAnswersExactlyOnce(t *testing.T) {
	response := newMethodResponse("11", nil)

	frames := captureFrames(t, func() {
		response.success("first")
		response.success("second")
		response.failure("core_error", "late", nil)
	})

	if len(frames) != 1 {
		t.Fatalf("captured %d frames, want 1; a second answer double-releases the platform callback", len(frames))
	}
	var envelope struct {
		Result string `json:"result"`
	}
	if err := json.Unmarshal(frames[0], &envelope); err != nil {
		t.Fatalf("response is not valid JSON: %v", err)
	}
	if envelope.Result != "first" {
		t.Errorf("result = %q, want the first answer to win", envelope.Result)
	}
}

func TestSendMessageBatchDoesNotDoubleEncodeArguments(t *testing.T) {
	frame := captureSingleFrame(t, func() {
		sendMessageBatch([]Message{{Type: LoadedMessage, Data: "provider"}})
	})

	var envelope struct {
		Arguments json.RawMessage `json:"arguments"`
	}
	if err := json.Unmarshal(frame, &envelope); err != nil {
		t.Fatalf("batch frame is not valid JSON: %v", err)
	}
	if len(envelope.Arguments) == 0 || envelope.Arguments[0] != '[' {
		t.Fatalf("arguments = %s, want a JSON array rather than an encoded string", envelope.Arguments)
	}
}

func TestHandleMethodCallReportsMissingArguments(t *testing.T) {
	frame := captureSingleFrame(t, func() {
		handleMethodCall(
			&MethodCall{ID: "3", Method: getTrafficMethod},
			newMethodResponse("3", nil),
		)
	})

	var envelope struct {
		Error *MethodError `json:"error"`
	}
	if err := json.Unmarshal(frame, &envelope); err != nil {
		t.Fatalf("response is not valid JSON: %v", err)
	}
	if envelope.Error == nil || envelope.Error.Code != "invalid_arguments" {
		t.Errorf("error = %+v, want code invalid_arguments", envelope.Error)
	}
}

func TestSendArmsAWriteDeadlineOnEveryFrame(t *testing.T) {
	fake := &fakeConn{}
	previous := swapConn(fake)
	defer swapConn(previous)

	send([]byte("{}"))
	send([]byte("{}"))

	fake.mu.Lock()
	defer fake.mu.Unlock()
	if fake.deadlines != 2 {
		t.Errorf("deadlines armed = %d, want one per frame", fake.deadlines)
	}
}

func TestSendDropsTheConnectionAfterAPartialWriteFailure(t *testing.T) {
	fake := &fakeConn{writeErr: errors.New("host stopped reading"), writeErrAfter: 2}
	previous := swapConn(fake)
	defer swapConn(previous)

	send([]byte("{}"))

	if !fake.isClosed() {
		t.Error("a half-written frame left the connection open; the stream is desynchronized")
	}
	if conn != nil {
		t.Error("conn still points at the dead connection")
	}

	send([]byte("{}"))
}

func TestSendKeepsTheConnectionWhenNoBytesReachedTheWire(t *testing.T) {
	fake := &fakeConn{writeErr: os.ErrDeadlineExceeded}
	previous := swapConn(fake)
	defer swapConn(previous)

	send([]byte("{}"))

	if fake.isClosed() {
		t.Error("write backpressure closed the only control channel; the Core would have to be restarted")
	}
	connMu.Lock()
	still := conn == ipcConn(fake)
	connMu.Unlock()
	if !still {
		t.Error("conn was cleared even though the frame never reached the wire")
	}

	fake.setWriteErr(nil)
	send([]byte("{}"))
	if frames := fake.frames(t); len(frames) != 1 {
		t.Errorf("delivered %d frames after the stall, want the retried one", len(frames))
	}
}

func TestSendRearmsTheFailureReportAfterAFrameGetsThrough(t *testing.T) {
	fake := &fakeConn{writeErr: os.ErrDeadlineExceeded}
	previous := swapConn(fake)
	deliveryFailureReported.Store(false)
	defer func() {
		swapConn(previous)
		deliveryFailureReported.Store(false)
	}()

	send([]byte("{}"))
	if !deliveryFailureReported.Load() {
		t.Fatal("the first delivery failure was not reported")
	}

	fake.setWriteErr(nil)
	send([]byte("{}"))

	if deliveryFailureReported.Load() {
		t.Error("a successful frame left the report latched; every later failure stays silent")
	}
}

func TestSafeGoAnswersWhenTheHandlerPanics(t *testing.T) {
	response := newMethodResponse("5", nil)
	done := make(chan struct{})

	frames := captureFrames(t, func() {
		safeGo(response, func() {
			defer close(done)
			panic("handler exploded")
		})
		<-done
		time.Sleep(50 * time.Millisecond)
	})

	if len(frames) != 1 {
		t.Fatalf("captured %d frames, want the panic answered exactly once", len(frames))
	}
	var envelope struct {
		Error *MethodError `json:"error"`
	}
	if err := json.Unmarshal(frames[0], &envelope); err != nil {
		t.Fatalf("response is not valid JSON: %v", err)
	}
	if envelope.Error == nil || envelope.Error.Code != "internal_error" {
		t.Errorf("error = %+v, want code internal_error", envelope.Error)
	}
	if !strings.Contains(envelope.Error.Message, "handler exploded") {
		t.Errorf("error message = %q, want it to carry the panic value", envelope.Error.Message)
	}
}

func TestSafeGoDetachedSurvivesAPanic(t *testing.T) {
	done := make(chan struct{})

	safeGoDetached("test", func() {
		defer close(done)
		panic("background exploded")
	})

	select {
	case <-done:
	case <-time.After(time.Second):
		t.Fatal("safeGoDetached never ran the task")
	}
	time.Sleep(50 * time.Millisecond)
}

func drainLogStream(t *testing.T, subscriber observable.Subscription[log.Event], window time.Duration, match func(string) bool) bool {
	t.Helper()
	deadline := time.After(window)
	for {
		select {
		case event, ok := <-subscriber:
			if !ok {
				return false
			}
			if match(event.Payload) {
				return true
			}
		case <-deadline:
			return false
		}
	}
}

func TestSendFailureIsNotReportedThroughTheLogStream(t *testing.T) {
	subscriber := log.Subscribe()
	defer log.UnSubscribe(subscriber)

	previous := swapConn(nil)
	deliveryFailureReported.Store(false)
	defer func() {
		swapConn(previous)
		deliveryFailureReported.Store(false)
	}()

	for i := 0; i < 8; i++ {
		send([]byte("{}"))
	}

	echoed := drainLogStream(t, subscriber, 100*time.Millisecond, func(payload string) bool {
		return strings.Contains(payload, "conn nil") || strings.Contains(payload, "server write")
	})
	if echoed {
		t.Error("a failed send published a log event, which is batched and handed back to send")
	}
}

func TestLogErrorStillReachesTheLogStream(t *testing.T) {
	subscriber := log.Subscribe()
	defer log.UnSubscribe(subscriber)

	logError("delivery probe %d", 7)

	reached := drainLogStream(t, subscriber, time.Second, func(payload string) bool {
		return strings.Contains(payload, "delivery probe 7")
	})
	if !reached {
		t.Fatal("logError never reached the log stream, so the send-path assertion above proves nothing")
	}
}

func TestDeliveryFailureIsReportedOncePerConnection(t *testing.T) {
	deliveryFailureReported.Store(false)
	defer deliveryFailureReported.Store(false)

	logDeliveryError("first")
	if !deliveryFailureReported.Load() {
		t.Fatal("the first delivery failure did not latch")
	}
	logDeliveryError("second")

	deliveryFailureReported.Store(false)
	logDeliveryError("after a fresh connection")
	if !deliveryFailureReported.Load() {
		t.Error("the latch did not re-arm for a new connection")
	}
}

func TestHandleStartLogAndStopLogLifecycle(t *testing.T) {
	handleStartLog()
	logMu.Lock()
	if logSubscriber == nil || logCancel == nil {
		logMu.Unlock()
		t.Fatal("handleStartLog did not initialize subscriber or cancel func")
	}
	logMu.Unlock()

	handleStartLog()

	handleStopLog()
	logMu.Lock()
	if logSubscriber != nil || logCancel != nil {
		logMu.Unlock()
		t.Fatal("handleStopLog did not clear subscriber or cancel func")
	}
	logMu.Unlock()
}
