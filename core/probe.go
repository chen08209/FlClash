package main

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"github.com/metacubex/http"
	"io"
	"net"
	"sync"
	"time"

	N "github.com/metacubex/mihomo/common/net"
	"github.com/metacubex/mihomo/component/ca"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"
	"github.com/metacubex/mihomo/tunnel/statistic"
)

const (
	probeConcurrency    = 8
	defaultProbeTimeout = 10 * time.Second
	probeErrorTimeout   = "timeout"
	probeErrorFailed    = "failed"

	// A routed dial learns its outbound from the tracker the tunnel registers
	// once the remote side is up. The request is held back until then, so the
	// answer does not depend on the server keeping the connection open, but
	// never longer than this: a sniffer waiting for client bytes gives up
	// after one second, and past that the request goes out and the lookup is
	// retried when the response arrives.
	probeRouteWait     = 2 * time.Second
	probeRouteInterval = 5 * time.Millisecond
)

var probeSlots = make(chan struct{}, probeConcurrency)

type probeRoute struct {
	chains      []string
	rule        string
	rulePayload string
}

// probeDialer opens one connection per dial, either pinned to a proxy or
// routed through the tunnel like any inbound connection, and keeps the route
// of the most recent one, which after redirects is the one that produced the
// final response.
type probeDialer struct {
	proxy constant.Proxy

	mu   sync.Mutex
	last *routedConn
}

func (d *probeDialer) dial(ctx context.Context, _ string, address string) (net.Conn, error) {
	metadata := &constant.Metadata{
		NetWork: constant.TCP,
		Type:    constant.INNER,
		DNSMode: constant.DNSNormal,
		Process: constant.MihomoName,
	}
	if err := metadata.SetRemoteAddress(address); err != nil {
		return nil, err
	}
	if d.proxy != nil {
		conn, err := d.proxy.DialContext(ctx, metadata)
		if err != nil {
			return nil, err
		}
		d.remember(&routedConn{route: &probeRoute{chains: conn.Chains()}})
		return conn, nil
	}
	local, remote := N.Pipe()
	routed := &routedConn{Conn: local, metadata: metadata, ctx: ctx, closed: make(chan struct{})}
	go tunnel.Tunnel.HandleTCPConn(&closeNotifier{Conn: remote, closed: routed.closed}, metadata)
	d.remember(routed)
	return routed, nil
}

func (d *probeDialer) remember(conn *routedConn) {
	d.mu.Lock()
	defer d.mu.Unlock()
	d.last = conn
}

func (d *probeDialer) route() *probeRoute {
	d.mu.Lock()
	last := d.last
	d.mu.Unlock()
	if last == nil {
		return nil
	}
	return last.resolve()
}

type routedConn struct {
	net.Conn
	metadata *constant.Metadata
	ctx      context.Context
	closed   chan struct{}

	first sync.Once
	mu    sync.Mutex
	route *probeRoute
}

func (c *routedConn) Write(b []byte) (int, error) {
	c.first.Do(c.awaitRoute)
	return c.Conn.Write(b)
}

func (c *routedConn) awaitRoute() {
	if c.metadata == nil {
		return
	}
	deadline := time.NewTimer(probeRouteWait)
	defer deadline.Stop()
	ticker := time.NewTicker(probeRouteInterval)
	defer ticker.Stop()
	for c.resolve() == nil {
		select {
		case <-ticker.C:
		case <-deadline.C:
			return
		case <-c.closed:
			return
		case <-c.ctx.Done():
			return
		}
	}
}

func (c *routedConn) resolve() *probeRoute {
	c.mu.Lock()
	defer c.mu.Unlock()
	if c.route == nil && c.metadata != nil {
		c.route = trackedRoute(c.metadata)
	}
	return c.route
}

func trackedRoute(metadata *constant.Metadata) *probeRoute {
	var route *probeRoute
	statistic.DefaultManager.Range(func(tracker statistic.Tracker) bool {
		info := tracker.Info()
		if info.Metadata != metadata {
			return true
		}
		route = &probeRoute{
			chains:      append([]string(nil), info.Chain...),
			rule:        info.Rule,
			rulePayload: info.RulePayload,
		}
		return false
	})
	return route
}

type closeNotifier struct {
	net.Conn
	once   sync.Once
	closed chan struct{}
}

func (c *closeNotifier) Close() error {
	c.once.Do(func() { close(c.closed) })
	return c.Conn.Close()
}

func probeTimeout(millis int64) time.Duration {
	if millis <= 0 {
		return defaultProbeTimeout
	}
	return time.Duration(millis) * time.Millisecond
}

func probeErrorKind(err error) string {
	var netErr net.Error
	if errors.Is(err, context.DeadlineExceeded) || (errors.As(err, &netErr) && netErr.Timeout()) {
		return probeErrorTimeout
	}
	return probeErrorFailed
}

type probeRequest struct {
	method    string
	url       string
	proxyName string
	headers   map[string]string
	body      []byte
	timeout   time.Duration
	maxBody   int64

	// A followed redirect loses the Location that Netflix names its region in.
	noRedirect bool
}

func handleProbe(params *ProbeParams) *ProbeResult {
	return runProbe(context.Background(), probeRequest{
		method:    http.MethodGet,
		url:       params.Url,
		proxyName: params.ProxyName,
		headers:   params.Headers,
		timeout:   probeTimeout(params.Timeout),
		maxBody:   params.MaxBody,
	})
}

// runProbe returns nil when the request never got a slot before its deadline.
func runProbe(parent context.Context, req probeRequest) *ProbeResult {
	result := &ProbeResult{Url: req.url, Chains: []string{}}
	result.CoreEpoch, result.PicksVersion = routeStamp()
	fail := func(err error) *ProbeResult {
		result.Error = probeErrorKind(err)
		result.Message = err.Error()
		return result
	}

	dialer := &probeDialer{}
	if req.proxyName != "" {
		dialer.proxy = lookupProxy(req.proxyName)
		if dialer.proxy == nil {
			return fail(fmt.Errorf("proxy %q is not part of the applied config", req.proxyName))
		}
	}
	tlsConfig, err := ca.GetTLSConfig(ca.Option{})
	if err != nil {
		return fail(err)
	}

	timeout := req.timeout
	if timeout <= 0 {
		timeout = defaultProbeTimeout
	}
	queueCtx, cancelQueue := context.WithTimeout(parent, timeout)
	granted := acquireProbeSlot(queueCtx)
	cancelQueue()
	if !granted {
		return nil
	}
	defer releaseProbeSlot()

	ctx, cancel := context.WithTimeout(parent, timeout)
	defer cancel()

	var body io.Reader
	if len(req.body) > 0 {
		body = bytes.NewReader(req.body)
	}
	method := req.method
	if method == "" {
		method = http.MethodGet
	}
	request, err := http.NewRequestWithContext(ctx, method, req.url, body)
	if err != nil {
		return fail(err)
	}
	for name, value := range req.headers {
		request.Header.Set(name, value)
	}
	transport := &http.Transport{
		DialContext:         dialer.dial,
		TLSClientConfig:     tlsConfig,
		TLSHandshakeTimeout: timeout,
		MaxIdleConns:        1,
		IdleConnTimeout:     timeout,
	}
	defer transport.CloseIdleConnections()
	client := &http.Client{Transport: transport}
	if req.noRedirect {
		client.CheckRedirect = func(*http.Request, []*http.Request) error {
			return http.ErrUseLastResponse
		}
	}

	start := time.Now()
	response, err := client.Do(request)
	if err != nil {
		return fail(err)
	}
	defer func() {
		_ = response.Body.Close()
	}()
	result.Delay = time.Since(start).Milliseconds()
	result.StatusCode = response.StatusCode
	result.header = response.Header
	result.Url = response.Request.URL.String()
	if route := dialer.route(); route != nil {
		result.Chains = route.chains
		result.Rule = route.rule
		result.RulePayload = route.rulePayload
	}
	if req.maxBody > 0 {
		payload, _ := io.ReadAll(io.LimitReader(response.Body, req.maxBody))
		result.Body = string(payload)
	}
	return result
}

func acquireProbeSlot(ctx context.Context) bool {
	select {
	case probeSlots <- struct{}{}:
		return true
	case <-ctx.Done():
		return false
	}
}

func releaseProbeSlot() {
	<-probeSlots
}
