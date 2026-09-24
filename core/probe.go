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
	probeRouteWait = 2 * time.Second

	probeTunnelPoll = 50 * time.Millisecond

	probeScanChunk   = 32 * 1024
	probeScanOverlap = 256
)

var (
	probeSlots = make(chan struct{}, probeConcurrency)

	pendingProbeRoutes sync.Map
)

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
	if err := awaitTunnel(ctx); err != nil {
		return nil, err
	}
	local, remote := N.Pipe()
	routed := &routedConn{
		Conn:     local,
		metadata: metadata,
		ctx:      ctx,
		closed:   make(chan struct{}),
		ready:    make(chan struct{}),
	}
	pendingProbeRoutes.Store(metadata, routed)
	go tunnel.Tunnel.HandleTCPConn(&closeNotifier{Conn: remote, closed: routed.closed}, metadata)
	d.remember(routed)
	return routed, nil
}

// Applying a config suspends the tunnel before the route epoch moves, so a
// connection refused in that window would come back as a failure the host
// still takes for the current route.
func awaitTunnel(ctx context.Context) error {
	for tunnel.Status() == tunnel.Suspend {
		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-time.After(probeTunnelPoll):
		}
	}
	return nil
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
	ready    chan struct{}

	first sync.Once
	mu    sync.Mutex
	route *probeRoute
}

func (c *routedConn) Close() error {
	pendingProbeRoutes.CompareAndDelete(c.metadata, c)
	return c.Conn.Close()
}

func (c *routedConn) Write(b []byte) (int, error) {
	c.first.Do(c.awaitRoute)
	return c.Conn.Write(b)
}

func (c *routedConn) awaitRoute() {
	if c.ready == nil {
		return
	}
	deadline := time.NewTimer(probeRouteWait)
	defer deadline.Stop()
	select {
	case <-c.ready:
	case <-deadline.C:
	case <-c.closed:
	case <-c.ctx.Done():
	}
}

func (c *routedConn) resolve() *probeRoute {
	c.mu.Lock()
	defer c.mu.Unlock()
	return c.route
}

func (c *routedConn) settle(route *probeRoute) {
	c.mu.Lock()
	c.route = route
	c.mu.Unlock()
	close(c.ready)
}

func notifyProbeRoute(tracker statistic.Tracker) {
	info := tracker.Info()
	pending, ok := pendingProbeRoutes.LoadAndDelete(info.Metadata)
	if !ok {
		return
	}
	pending.(*routedConn).settle(&probeRoute{
		chains:      append([]string(nil), info.Chain...),
		rule:        info.Rule,
		rulePayload: info.RulePayload,
	})
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

	// until sees the latest chunk and probeScanOverlap bytes before it.
	until func(tail string) bool
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
		result.Body = readProbeBody(response.Body, req.maxBody, req.until)
	}
	return result
}

func readProbeBody(body io.Reader, maxBody int64, until func(string) bool) string {
	limited := io.LimitReader(body, maxBody)
	if until == nil {
		payload, _ := io.ReadAll(limited)
		return string(payload)
	}
	var buffer bytes.Buffer
	chunk := make([]byte, probeScanChunk)
	for {
		n, err := limited.Read(chunk)
		if n > 0 {
			start := max(0, buffer.Len()-probeScanOverlap)
			buffer.Write(chunk[:n])
			if until(string(buffer.Bytes()[start:])) {
				break
			}
		}
		if err != nil {
			break
		}
	}
	return buffer.String()
}

func acquireProbeSlot(ctx context.Context) bool {
	if ctx.Err() != nil {
		return false
	}
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
