package core

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net"
	"os"
	"reflect"
	"testing"
	"time"

	"github.com/metacubex/mihomo/component/resolver"
	C "github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/rules/common"
)

type unwrappingProxy struct {
	C.Proxy
	name string
	next C.Proxy
}

func (p *unwrappingProxy) Name() string { return p.name }

func (p *unwrappingProxy) Unwrap(*C.Metadata, bool) C.Proxy { return p.next }

func dialError(err error) error {
	return &net.OpError{Op: "dial", Net: "tcp", Err: os.NewSyscallError("connect", err)}
}

func TestFailureKindOfDialErrors(t *testing.T) {
	cases := []struct {
		err  error
		want FailureKind
	}{
		{context.DeadlineExceeded, FailureTimeout},
		{&net.OpError{Op: "dial", Err: os.ErrDeadlineExceeded}, FailureTimeout},
		{dialError(timeoutErrnos[0]), FailureTimeout},
		{dialError(refusedErrnos[0]), FailureRefused},
		{dialError(unreachableErrnos[0]), FailureUnreachable},
		{resolver.ErrIPv6Disabled, FailureUnreachable},
		{fmt.Errorf("%w: example.com", resolver.ErrIPNotFound), FailureDns},
		{&net.DNSError{Err: "no such host", Name: "example.com", IsNotFound: true}, FailureDns},
		{fmt.Errorf("read handshake: %w", io.EOF), FailureHandshake},
		{dialError(handshakeErrnos[0]), FailureHandshake},
		{errors.New("vmess: invalid auth"), FailureOther},
	}
	for _, c := range cases {
		if got := failureKindOf(c.err); got != c.want {
			t.Errorf("failureKindOf(%v) = %s, want %s", c.err, got, c.want)
		}
	}
}

func TestFailedRequestOpensAndClosesInOneEvent(t *testing.T) {
	leaf := &unwrappingProxy{name: "HK-01"}
	group := &unwrappingProxy{name: "Proxy", next: leaf}
	rule := common.NewDomain("example.com", "Proxy")
	metadata := &C.Metadata{NetWork: C.TCP, Host: "example.com", DstPort: 443}
	at := time.Date(2026, 11, 21, 8, 0, 0, 0, time.UTC)

	data, err := json.Marshal(newFailedRequest(metadata, rule, group, dialError(refusedErrnos[0]), at))
	if err != nil {
		t.Fatal(err)
	}
	var event map[string]any
	if err := json.Unmarshal(data, &event); err != nil {
		t.Fatal(err)
	}

	if event["id"] == "" || event["start"] != "2026-11-21T08:00:00Z" || event["closedAt"] != "2026-11-21T08:00:00Z" {
		t.Fatalf("event = %s", data)
	}
	if !reflect.DeepEqual(event["chains"], []any{"HK-01", "Proxy"}) {
		t.Errorf("chains = %v, want leaf first", event["chains"])
	}
	if event["rule"] != "Domain" || event["rulePayload"] != "example.com" {
		t.Errorf("rule = %v %v", event["rule"], event["rulePayload"])
	}
	failure := event["failure"].(map[string]any)
	if failure["kind"] != "refused" || failure["message"] == "" {
		t.Errorf("failure = %v", failure)
	}
	if _, ok := event["metadata"].(map[string]any); !ok {
		t.Errorf("metadata = %v", event["metadata"])
	}
}

func TestChainsOfAGroupThatNestsItselfStop(t *testing.T) {
	group := &unwrappingProxy{name: "Loop"}
	group.next = group

	if got := len(chainsOf(group, &C.Metadata{})); got != maxChainLength {
		t.Errorf("len(chains) = %d, want %d", got, maxChainLength)
	}
}
