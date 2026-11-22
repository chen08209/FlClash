package core

import (
	"context"
	"errors"
	"io"
	"net"
	"net/netip"
	"os"
	"time"

	"github.com/metacubex/mihomo/common/utils"
	"github.com/metacubex/mihomo/component/resolver"
	C "github.com/metacubex/mihomo/constant"
)

type FailureKind string

const (
	FailureTimeout     FailureKind = "timeout"
	FailureRefused     FailureKind = "refused"
	FailureUnreachable FailureKind = "unreachable"
	FailureDns         FailureKind = "dns"
	FailureHandshake   FailureKind = "handshake"
	FailureOther       FailureKind = "other"
)

type RequestFailure struct {
	Kind    FailureKind `json:"kind"`
	Message string      `json:"message"`
}

type FailedRequest struct {
	Id          string         `json:"id"`
	Metadata    *C.Metadata    `json:"metadata"`
	Start       time.Time      `json:"start"`
	Chains      []string       `json:"chains"`
	Rule        string         `json:"rule"`
	RulePayload string         `json:"rulePayload"`
	RuleIndex   *int           `json:"ruleIndex,omitempty"`
	DnsQueries  []uint64       `json:"dnsQueries,omitempty"`
	ClosedAt    time.Time      `json:"closedAt"`
	Failure     RequestFailure `json:"failure"`
}

func newFailedRequest(metadata *C.Metadata, rule C.Rule, proxy C.Proxy, err error, at time.Time) *FailedRequest {
	request := &FailedRequest{
		Id:       utils.NewUUIDV4().String(),
		Metadata: metadata,
		Start:    at,
		Chains:   chainsOf(proxy, metadata),
		ClosedAt: at,
		Failure:  RequestFailure{Kind: failureKindOf(err), Message: err.Error()},
		// A failed dial names no address it dialed, so a DIRECT lookup is not linked.
		DnsQueries: currentDnsTrail.linkedQueries(metadata, at, netip.Addr{}),
	}
	if rule != nil {
		request.Rule = rule.RuleType().String()
		request.RulePayload = rule.Payload()
		request.RuleIndex = currentRuleTable.indexOfRule(rule, metadata)
	}
	return request
}

// A group that nests itself has no leaf; the names stop here.
const maxChainLength = 16

// chainsOf names the outbounds a dial through proxy passes, leaf first as in a
// tracker's chain. A group answers with its pick now, which may not be the one
// that failed when the pick moved since.
func chainsOf(proxy C.Proxy, metadata *C.Metadata) []string {
	chains := []string{proxy.Name()}
	for next := proxy.Unwrap(metadata, false); next != nil && len(chains) < maxChainLength; next = next.Unwrap(metadata, false) {
		chains = append([]string{next.Name()}, chains...)
	}
	return chains
}

func failureKindOf(err error) FailureKind {
	var dnsErr *net.DNSError
	var netErr net.Error
	switch {
	case errors.Is(err, resolver.ErrIPNotFound),
		errors.Is(err, resolver.ErrIPVersion),
		errors.As(err, &dnsErr) && dnsErr.IsNotFound:
		return FailureDns
	case errors.Is(err, resolver.ErrIPv6Disabled):
		return FailureUnreachable
	case errors.Is(err, context.DeadlineExceeded),
		errors.Is(err, os.ErrDeadlineExceeded),
		errors.As(err, &netErr) && netErr.Timeout(),
		isErrno(err, timeoutErrnos):
		return FailureTimeout
	case isErrno(err, refusedErrnos):
		return FailureRefused
	case isErrno(err, unreachableErrnos):
		return FailureUnreachable
	case errors.Is(err, io.EOF),
		errors.Is(err, io.ErrUnexpectedEOF),
		errors.Is(err, net.ErrClosed),
		isErrno(err, handshakeErrnos):
		return FailureHandshake
	default:
		return FailureOther
	}
}

func isErrno[E error](err error, errnos []E) bool {
	for _, errno := range errnos {
		if errors.Is(err, errno) {
			return true
		}
	}
	return false
}
