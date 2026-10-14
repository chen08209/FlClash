//go:build !cgo && !android

package core

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
	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/log"
)

type fakeConn struct {
	mu            sync.Mutex
	written       bytes.Buffer
	readable      *bytes.Reader
	writeErr      error
	writeErrAfter int
	writeErrTimes int
	closed        bool
	deadlines     int
	deadlineErr   error
	deadlineOK    int
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
	if fake.writeErr == nil {
		return fake.written.Write(p)
	}
	writeErr := fake.writeErr
	if fake.writeErrTimes > 0 {
		fake.writeErrTimes--
		if fake.writeErrTimes == 0 {
			fake.writeErr = nil
		}
	}
	accepted := min(fake.writeErrAfter, len(p))
	if accepted <= 0 {
		return 0, writeErr
	}
	fake.writeErrAfter -= accepted
	written, err := fake.written.Write(p[:accepted])
	if err != nil {
		return written, err
	}
	return written, writeErr
}

func (fake *fakeConn) deadlineCount() int {
	fake.mu.Lock()
	defer fake.mu.Unlock()
	return fake.deadlines
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
	if fake.deadlineErr != nil && fake.deadlines > fake.deadlineOK {
		return fake.deadlineErr
	}
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
	frame := encodeResponse(MethodResponse{ID: "42", Result: map[string]any{"ok": true}})

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
	frame := encodeResponse(MethodResponse{ID: "7", Error: &MethodError{
		Code:    "core_error",
		Message: "boom",
		Details: []string{"detail"},
	}})

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

			_, err := decodeArguments[InitParams](call)

			if err == nil {
				t.Fatal("decodeArguments accepted an invalid payload")
			}
			if code := asMethodError(err).Code; code != "invalid_arguments" {
				t.Errorf("code = %q, want invalid_arguments", code)
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

	target, err := decodeArguments[*InitParams](call)

	if err != nil {
		t.Fatalf("decodeArguments rejected a valid payload: %v", err)
	}
	if target.HomeDir != "/tmp/flclash" || target.Version != 3 {
		t.Errorf("decoded params = %+v, want {/tmp/flclash 3}", target)
	}
}

func TestHandleMethodCallReportsUnknownMethod(t *testing.T) {
	frame := handleMethodCall(&MethodCall{ID: "9", Method: CoreMethod("nopeMethod")})

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

func withMethodHandler(t *testing.T, method CoreMethod, handler methodHandler) {
	t.Helper()
	methodHandlers[method] = handler
	t.Cleanup(func() { delete(methodHandlers, method) })
}

// dispatchReplies collects every reply to one call; a second one would
// double-release the platform callback.
func dispatchReplies(t *testing.T, call *MethodCall) [][]byte {
	t.Helper()
	replies := make(chan []byte, 2)
	dispatchMethodCall(call, func(data []byte) { replies <- data })

	var frames [][]byte
	select {
	case frame := <-replies:
		frames = append(frames, frame)
	case <-time.After(time.Second):
		t.Fatal("the call was never answered")
	}
	select {
	case frame := <-replies:
		frames = append(frames, frame)
	case <-time.After(50 * time.Millisecond):
	}
	return frames
}

func TestDispatchMethodCallAnswersExactlyOnce(t *testing.T) {
	const method CoreMethod = "testEcho"
	withMethodHandler(t, method, withArguments(func(value string) string { return value }))

	frames := dispatchReplies(t, &MethodCall{ID: "11", Method: method, Arguments: json.RawMessage(`"first"`)})

	if len(frames) != 1 {
		t.Fatalf("got %d replies, want 1", len(frames))
	}
	var envelope struct {
		ID     string `json:"id"`
		Result string `json:"result"`
	}
	if err := json.Unmarshal(frames[0], &envelope); err != nil {
		t.Fatalf("response is not valid JSON: %v", err)
	}
	if envelope.ID != "11" || envelope.Result != "first" {
		t.Errorf("envelope = %+v, want the handler's result under the call's id", envelope)
	}
}

func TestMethodHandlerErrorsBecomeFailureEnvelopes(t *testing.T) {
	const method CoreMethod = "testFail"
	structured := &MethodError{Code: "provider_updating", Message: "busy"}
	tests := []struct {
		name    string
		handler methodHandler
		code    string
		result  string
	}{
		{"plain error", withFallible(func(string) (string, error) { return "", errors.New("boom") }), "core_error", ""},
		{"structured error", withFallible(func(string) (string, error) { return "", structured }), "provider_updating", ""},
		{"message", withMessage(func(string) error { return errors.New("boom") }), "", "boom"},
		{"structured message", withMessage(func(string) error { return structured }), "provider_updating", ""},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			withMethodHandler(t, method, test.handler)

			frame := handleMethodCall(&MethodCall{Method: method, Arguments: json.RawMessage(`"x"`)})

			var envelope struct {
				Result string       `json:"result"`
				Error  *MethodError `json:"error"`
			}
			if err := json.Unmarshal(frame, &envelope); err != nil {
				t.Fatalf("response is not valid JSON: %v", err)
			}
			code := ""
			if envelope.Error != nil {
				code = envelope.Error.Code
			}
			if code != test.code || envelope.Result != test.result {
				t.Errorf("code = %q result = %q, want %q and %q", code, envelope.Result, test.code, test.result)
			}
		})
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
	frame := handleMethodCall(&MethodCall{ID: "3", Method: getTrafficMethod})

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

func TestSendResumesAFrameThatStalledOnTheWriteDeadline(t *testing.T) {
	fake := &fakeConn{writeErr: os.ErrDeadlineExceeded, writeErrAfter: 2, writeErrTimes: 1}
	previous := swapConn(fake)
	defer swapConn(previous)

	send([]byte("{}"))

	if fake.isClosed() {
		t.Fatal("a host that stopped reading for one deadline window killed the connection, and with it the tunnel")
	}
	frames := fake.frames(t)
	if len(frames) != 1 || string(frames[0]) != "{}" {
		t.Errorf("frames = %q, want the stalled frame finished so the stream stays in sync", frames)
	}
	if fake.deadlineCount() < 2 {
		t.Error("resuming a stalled frame must arm a fresh write deadline")
	}
}

func TestSendWaitsOutAHostSuspendedForManyDeadlineWindows(t *testing.T) {
	const windows = 360
	fake := &fakeConn{writeErr: os.ErrDeadlineExceeded, writeErrAfter: 2, writeErrTimes: windows}
	previous := swapConn(fake)
	defer swapConn(previous)

	send([]byte("{}"))

	if fake.isClosed() {
		t.Fatal("a host asleep for an hour of deadline windows had its connection closed, and with it the Core")
	}
	frames := fake.frames(t)
	if len(frames) != 1 || string(frames[0]) != "{}" {
		t.Errorf("frames = %q, want the stalled frame finished once the host woke", frames)
	}
	if fake.deadlineCount() != 1+windows {
		t.Errorf("deadlines armed = %d, want one per stalled window plus the first", fake.deadlineCount())
	}
}

type pipeTimeoutError struct{}

func (*pipeTimeoutError) Error() string { return "i/o timeout" }
func (*pipeTimeoutError) Timeout() bool { return true }

func TestSendResumesAFrameThatStalledOnANamedPipeTimeout(t *testing.T) {
	fake := &fakeConn{writeErr: &pipeTimeoutError{}, writeErrAfter: 2, writeErrTimes: 1}
	previous := swapConn(fake)
	defer swapConn(previous)

	send([]byte("{}"))

	if fake.isClosed() {
		t.Fatal("a Windows pipe timeout on a half-written frame closed the connection instead of resuming it")
	}
	frames := fake.frames(t)
	if len(frames) != 1 || string(frames[0]) != "{}" {
		t.Errorf("frames = %q, want the stalled frame finished so the stream stays in sync", frames)
	}
}

type pipeNonTimeoutError struct{}

func (*pipeNonTimeoutError) Error() string { return "pipe closed" }
func (*pipeNonTimeoutError) Timeout() bool { return false }

func TestSendDropsTheConnectionWhenTimeoutReportsFalse(t *testing.T) {
	fake := &fakeConn{writeErr: &pipeNonTimeoutError{}, writeErrAfter: 2}
	previous := swapConn(fake)
	defer swapConn(previous)

	send([]byte("{}"))

	if !fake.isClosed() {
		t.Error("an error that implements Timeout() but reports false was treated as a stall instead of a dead host")
	}
}

func TestSendDropsTheConnectionWhenAStalledFrameCannotRearmItsDeadline(t *testing.T) {
	fake := &fakeConn{
		writeErr:      os.ErrDeadlineExceeded,
		writeErrAfter: 2,
		writeErrTimes: 1,
		deadlineErr:   errors.New("pipe closed"),
		deadlineOK:    1,
	}
	previous := swapConn(fake)
	defer swapConn(previous)

	send([]byte("{}"))

	if !fake.isClosed() {
		t.Error("a half-written frame whose deadline could not be re-armed left the connection open; the stream is desynchronized")
	}
	if conn != nil {
		t.Error("conn still points at the dead connection")
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

func TestDispatchMethodCallAnswersWhenTheHandlerPanics(t *testing.T) {
	const method CoreMethod = "testPanic"
	withMethodHandler(t, method, withoutArguments(func() bool { panic("handler exploded") }))

	frames := dispatchReplies(t, &MethodCall{ID: "5", Method: method})

	if len(frames) != 1 {
		t.Fatalf("got %d replies, want the panic answered exactly once", len(frames))
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

func TestSafeGoSurvivesAPanic(t *testing.T) {
	done := make(chan struct{})

	safeGo("test", func() {
		defer close(done)
		panic("background exploded")
	})

	select {
	case <-done:
	case <-time.After(time.Second):
		t.Fatal("safeGo never ran the task")
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
	first := currentLogPump()
	if first == nil {
		t.Fatal("handleStartLog did not start a log pump")
	}

	handleStartLog()
	second := currentLogPump()
	if second == first || !first.stopped.Load() {
		t.Error("a second handleStartLog left the first pump subscribed")
	}

	handleStopLog()
	if currentLogPump() != nil || !second.stopped.Load() {
		t.Fatal("handleStopLog did not stop the log pump")
	}
	if _, open := <-second.subscription; open {
		t.Error("handleStopLog left the subscription open, so mihomo keeps emitting into it")
	}
}

// mihomo emits to a subscriber under a lock and blocks once its buffer is full,
// so a pump that stopped reading before the unsubscribe would wedge the stop.
func TestHandleStopLogReturnsWhileTheLogIsFlooded(t *testing.T) {
	previous := log.Level()
	log.SetLevel(log.SILENT)
	t.Cleanup(func() { log.SetLevel(previous) })

	handleStartLog()
	flooding := make(chan struct{})
	flooded := make(chan struct{})
	go func() {
		defer close(flooded)
		for {
			select {
			case <-flooding:
				return
			default:
				log.Infoln("flood")
			}
		}
	}()

	stopped := make(chan struct{})
	go func() {
		defer close(stopped)
		handleStopLog()
	}()

	select {
	case <-stopped:
	case <-time.After(5 * time.Second):
		t.Fatal("handleStopLog never returned under a log flood")
	}
	close(flooding)
	<-flooded
}

func TestServeReleasesTheCoreWhenTheHostDisconnects(t *testing.T) {
	withCurrentConfig(t, &config.Config{General: &config.General{}, Controller: &config.Controller{}})
	isInit.Store(true)

	serve(&fakeConn{})

	if isInit.Load() {
		t.Error("the host went away without a shutdown call and the core kept its state, so a TUN it owned would leave its routes behind")
	}
	if currentConfig != nil {
		t.Error("currentConfig survived the host disconnect")
	}
	connMu.Lock()
	remaining := conn
	connMu.Unlock()
	if remaining != nil {
		t.Error("serve returned with the closed connection still installed")
	}
}

func TestReleaseOnExitIsANoOpBeforeInit(t *testing.T) {
	isInit.Store(false)
	handleStartLog()
	t.Cleanup(handleStopLog)
	pump := currentLogPump()

	releaseOnExit()

	if currentLogPump() != pump || pump.stopped.Load() {
		t.Error("release before init stopped a log pump it does not own")
	}
}
