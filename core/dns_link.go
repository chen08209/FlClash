package core

import (
	"net/netip"
	"slices"
	"strings"
	"sync"
	"time"

	"github.com/metacubex/mihomo/common/lru"
	"github.com/metacubex/mihomo/component/resolver"
	C "github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/dns"
	"github.com/metacubex/mihomo/tunnel/statistic"
	D "github.com/miekg/dns"
)

// The rule stage resolves under DefaultDNSTimeout (tunnel/tunnel.go:340), then the dial under
// DefaultTCPTimeout or DefaultUDPTimeout (tunnel/tunnel.go:576, 468), before the connection opens.
func dnsLinkWindow() time.Duration {
	return resolver.DefaultDNSTimeout + max(C.DefaultTCPTimeout, C.DefaultUDPTimeout)
}

type trailedQuery struct {
	id      uint64
	start   time.Time
	qtype   uint16
	answers []netip.Addr
}

// Each oldest first by start.
type hostLookups struct {
	rule, direct []trailedQuery
}

func (l *hostLookups) of(initiator string) *[]trailedQuery {
	if initiator == resolver.InitiatorRule {
		return &l.rule
	}
	return &l.direct
}

// Lookups end out of order, but mostly in order, so one arriving late moves back only a little.
func addLookup(queries []trailedQuery, query trailedQuery) []trailedQuery {
	cutoff := query.start.Add(-dnsLinkWindow())
	expired := 0
	for expired < len(queries) && queries[expired].start.Before(cutoff) {
		expired++
	}
	queries = queries[expired:]
	if cap(queries) > 64 && len(queries) < cap(queries)/4 {
		queries = slices.Clone(queries)
	}
	queries = append(queries, query)
	for at := len(queries) - 1; at > 0 && queries[at-1].start.After(query.start); at-- {
		queries[at-1], queries[at] = queries[at], queries[at-1]
	}
	return queries
}

type appQuery struct {
	id    uint64
	host  string
	start time.Time
}

type dnsTrail struct {
	mu     sync.Mutex
	nextID uint64
	byHost *lru.LruCache[string, *hostLookups]
	byIP   *lru.LruCache[netip.Addr, appQuery]
}

const (
	dnsTrailHosts = 1024
	dnsTrailIPs   = 4096
)

var currentDnsTrail = newDnsTrail()

func newDnsTrail() *dnsTrail {
	return &dnsTrail{
		byHost: lru.New[string, *hostLookups](lru.WithSize[string, *hostLookups](dnsTrailHosts)),
		byIP:   lru.New[netip.Addr, appQuery](lru.WithSize[netip.Addr, appQuery](dnsTrailIPs)),
	}
}

func (t *dnsTrail) note(record dns.QueryRecord) uint64 {
	var answers []netip.Addr
	if record.Msg != nil {
		for _, rr := range record.Msg.Answer {
			switch answer := rr.(type) {
			case *D.A:
				answers = appendAddr(answers, answer.A)
			case *D.AAAA:
				answers = appendAddr(answers, answer.AAAA)
			}
		}
	}
	host := dnsName(record.Question.Name)
	t.mu.Lock()
	defer t.mu.Unlock()
	t.nextID++
	id := t.nextID
	switch record.Initiator {
	case resolver.InitiatorApp:
		for _, ip := range answers {
			t.byIP.Set(ip, appQuery{id: id, host: host, start: record.Start})
		}
	case resolver.InitiatorRule, resolver.InitiatorDirect:
		lookups, ok := t.byHost.Get(host)
		if !ok {
			lookups = &hostLookups{}
			t.byHost.Set(host, lookups)
		}
		queries := lookups.of(record.Initiator)
		*queries = addLookup(*queries, trailedQuery{
			id:      id,
			start:   record.Start,
			qtype:   record.Question.Qtype,
			answers: answers,
		})
	}
	return id
}

func dnsName(name string) string {
	return strings.ToLower(strings.TrimSuffix(name, "."))
}

func appendAddr(answers []netip.Addr, ip []byte) []netip.Addr {
	if addr, ok := netip.AddrFromSlice(ip); ok {
		return append(answers, addr.Unmap())
	}
	return answers
}

// The fork ties no lookup to its connection, so a host's lookups are linked only when one answered
// with the address used and no type was looked up twice in the window, as side-by-side connections do.
func (t *dnsTrail) linkedQueries(metadata *C.Metadata, opened time.Time, dialed netip.Addr) []uint64 {
	if metadata == nil {
		return nil
	}
	t.mu.Lock()
	defer t.mu.Unlock()
	switch metadata.DNSMode {
	case C.DNSFakeIP:
		return nil
	case C.DNSMapping:
		// The fork names the connection after the host last answered with its address, which a
		// lookup of another host can replace while it dials.
		if query, ok := t.byIP.Get(metadata.DstIP.Unmap()); ok && query.host == dnsName(metadata.Host) && !query.start.After(opened) {
			return []uint64{query.id}
		}
		return nil
	}
	if metadata.Host == "" {
		return nil
	}
	lookups, ok := t.byHost.Get(dnsName(metadata.Host))
	if !ok {
		return nil
	}
	var linked []uint64
	for _, lookup := range []struct {
		initiator string
		address   netip.Addr
	}{
		{resolver.InitiatorRule, metadata.DstIP.Unmap()},
		{resolver.InitiatorDirect, dialed},
	} {
		if lookup.address.IsValid() {
			linked = appendUnambiguous(linked, *lookups.of(lookup.initiator), opened, lookup.address)
		}
	}
	return linked
}

func appendUnambiguous(linked []uint64, queries []trailedQuery, opened time.Time, address netip.Addr) []uint64 {
	end, _ := slices.BinarySearchFunc(queries, opened, func(query trailedQuery, opened time.Time) int {
		if query.start.After(opened) {
			return 1
		}
		return -1
	})
	types := make([]uint16, 0, 4)
	answered := false
	for at := end - 1; at >= 0 && opened.Sub(queries[at].start) <= dnsLinkWindow(); at-- {
		query := queries[at]
		if slices.Contains(types, query.qtype) {
			return linked
		}
		types = append(types, query.qtype)
		answered = answered || slices.Contains(query.answers, address)
	}
	if !answered {
		return linked
	}
	for at := end - len(types); at < end; at++ {
		linked = append(linked, queries[at].id)
	}
	return linked
}

func dialedAddr(info *statistic.TrackerInfo) netip.Addr {
	if info.Metadata == nil {
		return netip.Addr{}
	}
	addrPort, err := netip.ParseAddrPort(info.Metadata.RemoteDst)
	if err != nil {
		addr, err := netip.ParseAddr(info.Metadata.RemoteDst)
		if err != nil {
			return netip.Addr{}
		}
		return addr.Unmap()
	}
	return addrPort.Addr().Unmap()
}
