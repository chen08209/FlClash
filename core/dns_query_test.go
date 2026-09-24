package main

import (
	"encoding/json"
	"errors"
	"net"
	"reflect"
	"testing"
	"time"

	"github.com/metacubex/mihomo/component/resolver"
	"github.com/metacubex/mihomo/dns"
	D "github.com/miekg/dns"
)

func dnsQuestion(name string, qtype uint16) D.Question {
	return D.Question{Name: D.Fqdn(name), Qtype: qtype, Qclass: D.ClassINET}
}

func TestNewDnsQueryFlattensAnswers(t *testing.T) {
	request := new(D.Msg)
	request.SetQuestion("www.example.com.", D.TypeA)
	resp := new(D.Msg)
	resp.SetReply(request)
	header := func(rrtype uint16) D.RR_Header {
		return D.RR_Header{Name: "www.example.com.", Rrtype: rrtype, Class: D.ClassINET, Ttl: 60}
	}
	resp.Answer = []D.RR{
		&D.CNAME{Hdr: header(D.TypeCNAME), Target: "edge.example.net."},
		&D.A{Hdr: header(D.TypeA), A: net.ParseIP("93.184.216.34").To4()},
		&D.AAAA{Hdr: header(D.TypeAAAA), AAAA: net.ParseIP("2606:2800:220:1::248")},
		&D.TXT{Hdr: header(D.TypeTXT), Txt: []string{"v=spf1 -all"}},
	}
	start := time.Now()

	query := newDnsQuery(dns.QueryRecord{
		Question:  request.Question[0],
		Msg:       resp,
		Initiator: resolver.InitiatorApp,
		Upstream:  "tls://1.1.1.1:853",
		Cached:    true,
		Start:     start,
	})

	if query.Domain != "www.example.com" || query.Type != "A" {
		t.Fatalf("query = %+v", query)
	}
	if query.Initiator != "app" || query.Upstream != "tls://1.1.1.1:853" || !query.Cached {
		t.Fatalf("initiator = %q, upstream = %q, cached = %v", query.Initiator, query.Upstream, query.Cached)
	}
	if query.Rcode != "NOERROR" || query.Error != "" {
		t.Fatalf("rcode = %q, error = %q", query.Rcode, query.Error)
	}
	want := []string{"edge.example.net", "93.184.216.34", "2606:2800:220:1::248", `"v=spf1 -all"`}
	if !reflect.DeepEqual(query.Answers, want) {
		t.Fatalf("answers = %q, want %q", query.Answers, want)
	}
	if !query.Time.Equal(start) {
		t.Fatalf("time = %v, want %v", query.Time, start)
	}
}

func TestNewDnsQueryKeepsTheFailure(t *testing.T) {
	query := newDnsQuery(dns.QueryRecord{
		Question:  dnsQuestion("missing.test", D.TypeAAAA),
		Initiator: resolver.InitiatorDirect,
		Start:     time.Now(),
		Err:       errors.New("i/o timeout"),
	})

	if query.Error != "i/o timeout" || query.Rcode != "" {
		t.Fatalf("error = %q, rcode = %q", query.Error, query.Rcode)
	}
	data, err := json.Marshal(query)
	if err != nil {
		t.Fatal(err)
	}
	var decoded map[string]any
	if err := json.Unmarshal(data, &decoded); err != nil {
		t.Fatal(err)
	}
	if answers, ok := decoded["answers"].([]any); !ok || len(answers) != 0 {
		t.Fatalf("answers = %v, want an empty list", decoded["answers"])
	}
	for _, key := range []string{"upstream", "cached"} {
		if _, ok := decoded[key]; ok {
			t.Fatalf("%s = %v, want it omitted", key, decoded[key])
		}
	}
	if decoded["initiator"] != "direct" {
		t.Fatalf("initiator = %v, want direct", decoded["initiator"])
	}
}

func TestNewDnsQueryNamesUnknownTypes(t *testing.T) {
	resp := new(D.Msg)
	resp.Rcode = D.RcodeNameError

	query := newDnsQuery(dns.QueryRecord{
		Question: dnsQuestion("example.com", 65280),
		Msg:      resp,
		Start:    time.Now(),
	})

	if query.Type != "TYPE65280" || query.Rcode != "NXDOMAIN" {
		t.Fatalf("type = %q, rcode = %q", query.Type, query.Rcode)
	}
}
