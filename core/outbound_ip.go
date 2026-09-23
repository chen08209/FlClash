package main

import (
	"context"
	"net/netip"
	"strings"
	"time"

	"github.com/metacubex/http"
)

const (
	// Racing every source at once would take every probe slot.
	outboundIpConcurrency = 3
	outboundIpStagger     = 800 * time.Millisecond

	outboundIpMaxBody = 4096

	// Kept in step with browserUa in lib/common/constant.dart.
	browserUserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
)

type OutboundIpParams struct {
	ProxyName string   `json:"proxy-name"`
	Urls      []string `json:"urls"`
	Timeout   int64    `json:"timeout"`
}

type OutboundIpResult struct {
	Url          string   `json:"url"`
	Body         string   `json:"body"`
	Delay        int64    `json:"delay"`
	Chains       []string `json:"chains"`
	Error        string   `json:"error,omitempty"`
	CoreEpoch    uint64   `json:"core-epoch"`
	PicksVersion uint64   `json:"picks-version"`
}

// handleOutboundIp takes the first usable answer and cancels the losers so they
// stop occupying probe slots. Url is the source that was asked, not where it
// redirected, and Body is raw: Dart owns the sources and their parsers.
func handleOutboundIp(params *OutboundIpParams) *OutboundIpResult {
	epoch, picksVersion := routeStamp()
	failure := func(kind string) *OutboundIpResult {
		return &OutboundIpResult{Error: kind, CoreEpoch: epoch, PicksVersion: picksVersion}
	}
	if len(params.Urls) == 0 {
		return failure(probeErrorFailed)
	}

	timeout := probeTimeout(params.Timeout)
	ctx, cancel := context.WithTimeout(context.Background(), timeout)
	defer cancel()

	answers := make(chan *OutboundIpResult, len(params.Urls))
	next := 0
	inFlight := 0
	start := func() {
		if next >= len(params.Urls) {
			return
		}
		url := params.Urls[next]
		next++
		inFlight++
		go func() {
			answers <- probeOutboundIpSource(ctx, url, params.ProxyName, timeout)
		}()
	}

	for i := 0; i < outboundIpConcurrency; i++ {
		start()
	}

	stagger := time.NewTicker(outboundIpStagger)
	defer stagger.Stop()
	for inFlight > 0 {
		select {
		case answer := <-answers:
			inFlight--
			if answer != nil {
				return answer
			}
			start()
		case <-stagger.C:
			start()
		case <-ctx.Done():
			return failure(probeErrorTimeout)
		}
	}
	return failure(probeErrorFailed)
}

func probeOutboundIpSource(ctx context.Context, url string, proxyName string, timeout time.Duration) *OutboundIpResult {
	result := runProbe(ctx, probeRequest{
		method:    http.MethodGet,
		url:       url,
		proxyName: proxyName,
		headers:   map[string]string{"User-Agent": browserUserAgent},
		timeout:   timeout,
		maxBody:   outboundIpMaxBody,
	})
	if result == nil || result.Error != "" || result.StatusCode != http.StatusOK || !mentionsIp(result.Body) {
		return nil
	}
	return &OutboundIpResult{
		Url:          url,
		Body:         result.Body,
		Delay:        result.Delay,
		Chains:       result.Chains,
		CoreEpoch:    result.CoreEpoch,
		PicksVersion: result.PicksVersion,
	}
}

// A rate-limit or captcha page can still answer 200, and Dart cannot fall back
// once the race is decided, so a body without an address must not win it.
func mentionsIp(body string) bool {
	tokens := strings.FieldsFunc(body, func(r rune) bool {
		return !(r == '.' || r == ':' || '0' <= r && r <= '9' || 'a' <= r && r <= 'f' || 'A' <= r && r <= 'F')
	})
	for _, token := range tokens {
		if _, err := netip.ParseAddr(token); err == nil {
			return true
		}
	}
	return false
}
