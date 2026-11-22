package core

import (
	"encoding/json"
	"net"
	"net/netip"
	"reflect"
	"slices"
	"testing"
	"time"

	"github.com/metacubex/mihomo/component/resolver"
	C "github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/dns"
	"github.com/metacubex/mihomo/tunnel/statistic"
	D "github.com/miekg/dns"
)

func answeredQuery(host string, qtype uint16, initiator string, start time.Time, ips ...string) dns.QueryRecord {
	request := new(D.Msg)
	request.SetQuestion(D.Fqdn(host), qtype)
	reply := new(D.Msg)
	reply.SetReply(request)
	for _, ip := range ips {
		header := D.RR_Header{Name: D.Fqdn(host), Rrtype: qtype, Class: D.ClassINET, Ttl: 60}
		if qtype == D.TypeA {
			reply.Answer = append(reply.Answer, &D.A{Hdr: header, A: net.ParseIP(ip).To4()})
		} else {
			reply.Answer = append(reply.Answer, &D.AAAA{Hdr: header, AAAA: net.ParseIP(ip)})
		}
	}
	return dns.QueryRecord{Question: request.Question[0], Msg: reply, Initiator: initiator, Start: start}
}

func sorted(ids []uint64) []uint64 {
	slices.Sort(ids)
	return ids
}

func TestAConnectionIsLinkedToTheLookupsOnlyItCouldHaveMade(t *testing.T) {
	opened := time.Now()
	before := opened.Add(-time.Second)
	trail := newDnsTrail()
	ruleA := trail.note(answeredQuery("rules.test", D.TypeA, resolver.InitiatorRule, before, "192.0.2.1"))
	ruleAAAA := trail.note(answeredQuery("rules.test", D.TypeAAAA, resolver.InitiatorRule, before, "2001:db8::1"))
	directA := trail.note(answeredQuery("dial.test", D.TypeA, resolver.InitiatorDirect, before, "192.0.2.2"))
	trail.note(answeredQuery("node.test", D.TypeA, resolver.InitiatorProxy, before, "192.0.2.3"))
	trail.note(answeredQuery("old.test", D.TypeA, resolver.InitiatorRule, opened.Add(-dnsLinkWindow()-time.Second), "192.0.2.4"))
	trail.note(answeredQuery("busy.test", D.TypeA, resolver.InitiatorRule, before, "192.0.2.5"))
	trail.note(answeredQuery("busy.test", D.TypeA, resolver.InitiatorRule, before, "192.0.2.5"))
	trail.note(answeredQuery("busy.test", D.TypeAAAA, resolver.InitiatorRule, before, "2001:db8::5"))
	trail.note(answeredQuery("later.test", D.TypeA, resolver.InitiatorRule, opened.Add(time.Second), "192.0.2.6"))
	mapped := trail.note(answeredQuery("mapped.test", D.TypeA, resolver.InitiatorApp, before, "198.51.100.7"))

	addr := netip.MustParseAddr
	for _, test := range []struct {
		name     string
		metadata C.Metadata
		dialed   netip.Addr
		want     []uint64
	}{
		{"both types the rule stage looked up", C.Metadata{Host: "rules.test", DstIP: addr("192.0.2.1")}, netip.Addr{}, []uint64{ruleA, ruleAAAA}},
		{"a DIRECT dial's own lookup", C.Metadata{Host: "dial.test"}, addr("192.0.2.2"), []uint64{directA}},
		{"a DIRECT lookup that answered another address", C.Metadata{Host: "dial.test"}, addr("192.0.2.9"), nil},
		{"a node's lookup of its server", C.Metadata{Host: "node.test"}, addr("192.0.2.3"), nil},
		{"a lookup before the window", C.Metadata{Host: "old.test", DstIP: addr("192.0.2.4")}, netip.Addr{}, nil},
		{"a type looked up twice", C.Metadata{Host: "busy.test", DstIP: addr("192.0.2.5")}, netip.Addr{}, nil},
		{"a lookup after it opened", C.Metadata{Host: "later.test", DstIP: addr("192.0.2.6")}, netip.Addr{}, nil},
		{"a redir-host address", C.Metadata{DNSMode: C.DNSMapping, Host: "mapped.test", DstIP: addr("198.51.100.7")}, netip.Addr{}, []uint64{mapped}},
		{"a fake-ip address", C.Metadata{DNSMode: C.DNSFakeIP, Host: "rules.test", DstIP: addr("192.0.2.1")}, netip.Addr{}, nil},
		{"an address with no host", C.Metadata{DstIP: addr("192.0.2.1")}, netip.Addr{}, nil},
	} {
		metadata := test.metadata
		if got := sorted(trail.linkedQueries(&metadata, opened, test.dialed)); !reflect.DeepEqual(got, test.want) {
			t.Errorf("%s: linked %v, want %v", test.name, got, test.want)
		}
	}
}

func TestADnsEventAndARequestEventCarryTheLink(t *testing.T) {
	start := time.Now().Add(-time.Second)
	record := answeredQuery("event-link.test", D.TypeA, resolver.InitiatorDirect, start, "192.0.2.10")
	query := newDnsQuery(record)
	query.Id = currentDnsTrail.note(record)

	data, _ := json.Marshal(query)
	var dnsEvent map[string]any
	_ = json.Unmarshal(data, &dnsEvent)
	if dnsEvent["id"] != float64(query.Id) || query.Id == 0 {
		t.Fatalf("dns event %s", data)
	}

	info := &statistic.TrackerInfo{
		Metadata: &C.Metadata{Host: "event-link.test", RemoteDst: "192.0.2.10"},
		Start:    time.Now(),
		Chain:    C.Chain{"DIRECT"},
	}
	data, _ = json.Marshal(requestInfo{TrackerInfo: info, DnsQueries: currentDnsTrail.linkedQueries(info.Metadata, info.Start, dialedAddr(info))})
	var requestEvent map[string]any
	_ = json.Unmarshal(data, &requestEvent)
	if !reflect.DeepEqual(requestEvent["dnsQueries"], []any{float64(query.Id)}) {
		t.Errorf("request event %s", data)
	}
}

func TestARedirHostAddressIsLinkedOnlyToALookupOfItsOwnHostBeforeItOpened(t *testing.T) {
	opened := time.Now()
	before := opened.Add(-time.Second)
	trail := newDnsTrail()
	trail.note(answeredQuery("first.test", D.TypeA, resolver.InitiatorApp, before.Add(-time.Second), "198.51.100.1"))
	second := trail.note(answeredQuery("second.test", D.TypeA, resolver.InitiatorApp, before, "198.51.100.1"))
	trail.note(answeredQuery("late.test", D.TypeA, resolver.InitiatorApp, opened.Add(time.Second), "198.51.100.2"))

	addr := netip.MustParseAddr
	for _, test := range []struct {
		name string
		host string
		ip   string
		want []uint64
	}{
		{"the host the address was last answered for", "second.test", "198.51.100.1", []uint64{second}},
		{"a host the address was answered for before another", "first.test", "198.51.100.1", nil},
		{"a lookup after it opened", "late.test", "198.51.100.2", nil},
	} {
		metadata := C.Metadata{DNSMode: C.DNSMapping, Host: test.host, DstIP: addr(test.ip)}
		if got := trail.linkedQueries(&metadata, opened, netip.Addr{}); !reflect.DeepEqual(got, test.want) {
			t.Errorf("%s: linked %v, want %v", test.name, got, test.want)
		}
	}
}

func TestABurstOfLookupsOfOneHostCostsEachLookupAndConnectionLittle(t *testing.T) {
	opened := time.Now()
	trail := newDnsTrail()
	for i := range 5000 {
		trail.note(answeredQuery("burst.test", D.TypeA, resolver.InitiatorRule, opened.Add(-time.Duration(5000-i)*time.Millisecond), "192.0.2.1"))
	}
	lookup := answeredQuery("burst.test", D.TypeA, resolver.InitiatorRule, opened, "192.0.2.1")
	metadata := C.Metadata{Host: "burst.test", DstIP: netip.MustParseAddr("192.0.2.1")}

	noting := testing.AllocsPerRun(100, func() { trail.note(lookup) })
	linking := testing.AllocsPerRun(100, func() { trail.linkedQueries(&metadata, opened, netip.Addr{}) })

	if noting > 4 || linking > 1 {
		t.Errorf("allocated %v a lookup and %v a connection, want at most 4 and 1", noting, linking)
	}
	if got := trail.linkedQueries(&metadata, opened, netip.Addr{}); got != nil {
		t.Errorf("linked %v, want none of a type looked up many times", got)
	}
}

func TestLookupsThatEndOutOfOrderAreLinkedAsThoughTheyHadNot(t *testing.T) {
	opened := time.Now()
	trail := newDnsTrail()
	trail.note(answeredQuery("order.test", D.TypeA, resolver.InitiatorRule, opened.Add(time.Second), "192.0.2.1"))
	aaaa := trail.note(answeredQuery("order.test", D.TypeAAAA, resolver.InitiatorRule, opened.Add(-time.Second), "2001:db8::1"))
	a := trail.note(answeredQuery("order.test", D.TypeA, resolver.InitiatorRule, opened.Add(-2*time.Second), "192.0.2.1"))
	trail.note(answeredQuery("order.test", D.TypeA, resolver.InitiatorRule, opened.Add(-dnsLinkWindow()-time.Second), "192.0.2.1"))

	metadata := C.Metadata{Host: "order.test", DstIP: netip.MustParseAddr("192.0.2.1")}
	if got, want := sorted(trail.linkedQueries(&metadata, opened, netip.Addr{})), sorted([]uint64{a, aaaa}); !reflect.DeepEqual(got, want) {
		t.Errorf("linked %v, want %v", got, want)
	}
}

func TestAHostIsLinkedToItsLookupsWhateverItsCaseAndFinalDot(t *testing.T) {
	opened := time.Now()
	before := opened.Add(-time.Second)
	trail := newDnsTrail()
	rule := trail.note(answeredQuery("Mixed.TEST", D.TypeA, resolver.InitiatorRule, before, "192.0.2.1"))
	app := trail.note(answeredQuery("App.TEST", D.TypeA, resolver.InitiatorApp, before, "198.51.100.1"))

	addr := netip.MustParseAddr
	for _, test := range []struct {
		name     string
		metadata C.Metadata
		want     []uint64
	}{
		{"another case", C.Metadata{Host: "mixed.test", DstIP: addr("192.0.2.1")}, []uint64{rule}},
		{"a final dot", C.Metadata{Host: "mixed.TEST.", DstIP: addr("192.0.2.1")}, []uint64{rule}},
		{"a redir-host address", C.Metadata{DNSMode: C.DNSMapping, Host: "app.test", DstIP: addr("198.51.100.1")}, []uint64{app}},
	} {
		metadata := test.metadata
		if got := trail.linkedQueries(&metadata, opened, netip.Addr{}); !reflect.DeepEqual(got, test.want) {
			t.Errorf("%s: linked %v, want %v", test.name, got, test.want)
		}
	}
}
