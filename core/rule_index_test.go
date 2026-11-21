package core

import (
	"encoding/json"
	"io"
	"net"
	"reflect"
	"testing"
	"time"

	"github.com/metacubex/mihomo/adapter/outbound"
	C "github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/rules"
	"github.com/metacubex/mihomo/tunnel"
	"github.com/metacubex/mihomo/tunnel/statistic"
)

func useRules(t *testing.T, lines ...[3]string) []C.Rule {
	t.Helper()
	var parsed []C.Rule
	for _, line := range lines {
		rule, err := rules.ParseRule(line[0], line[1], line[2], nil, nil)
		if err != nil {
			t.Fatalf("ParseRule %v: %v", line, err)
		}
		parsed = append(parsed, rule)
	}
	tunnel.UpdateRules(parsed, nil, nil)
	currentRuleTable.observe()
	t.Cleanup(func() {
		tunnel.UpdateRules(nil, nil, nil)
		currentRuleTable.observe()
	})
	return parsed
}

func indexValue(index *int) int {
	if index == nil {
		return -1
	}
	return *index
}

func TestRuleIndexNamesTheFirstRuleWithTheConnectionsTypePayloadAndPolicy(t *testing.T) {
	parsed := useRules(t,
		[3]string{"DOMAIN", "a.test", "Proxy"},
		[3]string{"DOMAIN", "b.test", "DIRECT"},
		[3]string{"DOMAIN", "b.test", "Proxy"},
		[3]string{"DOMAIN", "b.test", "Proxy"},
		[3]string{"MATCH", "", "DIRECT"},
	)
	opened := func(rule, payload string, chain ...string) *statistic.TrackerInfo {
		return &statistic.TrackerInfo{
			Metadata:    &C.Metadata{},
			Start:       time.Now(),
			Chain:       chain,
			Rule:        rule,
			RulePayload: payload,
		}
	}
	subRules := opened("Domain", "b.test", "DIRECT")
	subRules.Metadata.SpecialRules = "sub"
	for _, test := range []struct {
		info *statistic.TrackerInfo
		want int
	}{
		{opened("Domain", "b.test", "HK-01", "Proxy"), 2},
		{opened("Domain", "b.test", "DIRECT"), 1},
		{opened("Match", "", "DIRECT"), 4},
		{opened("Domain", "c.test", "DIRECT"), -1},
		{opened("", "", "DIRECT"), -1},
		{subRules, -1},
	} {
		if got := indexValue(currentRuleTable.indexOf(test.info, false)); got != test.want {
			t.Errorf("%s %s via %v: index %d, want %d", test.info.Rule, test.info.RulePayload, test.info.Chain, got, test.want)
		}
	}

	metadata := &C.Metadata{}
	if got := indexValue(currentRuleTable.indexOfRule(parsed[3], metadata)); got != 3 {
		t.Errorf("a failed dial's own rule: index %d, want 3", got)
	}
	stray, _ := rules.ParseRule("DOMAIN", "a.test", "Proxy", nil, nil)
	if got := indexValue(currentRuleTable.indexOfRule(stray, metadata)); got != -1 {
		t.Errorf("a rule not in the list: index %d", got)
	}
	metadata.SpecialRules = "sub"
	if got := indexValue(currentRuleTable.indexOfRule(parsed[3], metadata)); got != -1 {
		t.Errorf("a rule matched from a sub-rule list: index %d", got)
	}
}

func TestAListedConnectionOpenedBeforeTheRulesChangedHasNoIndex(t *testing.T) {
	useRules(t, [3]string{"MATCH", "", "DIRECT"})
	info := &statistic.TrackerInfo{
		Metadata: &C.Metadata{},
		Start:    time.Now(),
		Chain:    C.Chain{"DIRECT"},
		Rule:     "Match",
	}
	if got := indexValue(currentRuleTable.indexOf(info, true)); got != 0 {
		t.Fatalf("opened under the current rules: index %d, want 0", got)
	}
	time.Sleep(time.Millisecond)
	useRules(t, [3]string{"MATCH", "", "DIRECT"})
	if got := indexValue(currentRuleTable.indexOf(info, true)); got != -1 {
		t.Errorf("listed after the rules changed: index %d", got)
	}
	if got := indexValue(currentRuleTable.indexOf(info, false)); got != 0 {
		t.Errorf("announced as it opens: index %d, want 0", got)
	}
}

func TestARequestEventIsTheTrackerWithItsRuleIndex(t *testing.T) {
	parsed := useRules(t, [3]string{"DOMAIN", "x.test", "DIRECT"}, [3]string{"MATCH", "", "DIRECT"})
	local, remote := net.Pipe()
	go func() { _, _ = io.Copy(io.Discard, remote) }()
	t.Cleanup(func() { _ = remote.Close() })
	tracker := statistic.NewTCPTracker(
		outbound.NewConn(local, outbound.NewDirect()),
		statistic.DefaultManager,
		&C.Metadata{NetWork: C.TCP, Host: "y.test", DstPort: 443},
		parsed[1],
		0,
		0,
		false,
	)
	t.Cleanup(func() { _ = tracker.Close() })

	var plain, event map[string]any
	for target, value := range map[*map[string]any]any{&plain: tracker, &event: newRequestInfo(tracker)} {
		data, err := json.Marshal(value)
		if err != nil {
			t.Fatal(err)
		}
		if err := json.Unmarshal(data, target); err != nil {
			t.Fatal(err)
		}
	}
	if event["ruleIndex"] != float64(1) {
		t.Errorf("ruleIndex = %v, want 1", event["ruleIndex"])
	}
	delete(event, "ruleIndex")
	if !reflect.DeepEqual(plain, event) {
		t.Errorf("event %v\nwant the tracker's own fields %v", event, plain)
	}

	snapshot := handleGetConnections()
	for _, listed := range snapshot.Connections {
		if listed.UUID == tracker.Info().UUID && indexValue(listed.RuleIndex) != 1 {
			t.Errorf("listed with index %v, want 1", listed.RuleIndex)
		}
	}
}

func TestRuleListNamesEachRuleAsATrackerDoesInIndexOrder(t *testing.T) {
	useRules(t, [3]string{"DOMAIN-SUFFIX", "x.test", "Proxy"}, [3]string{"MATCH", "", "DIRECT"})
	data, err := json.Marshal(handleGetRules())
	if err != nil {
		t.Fatal(err)
	}
	want := `{"rules":[{"type":"DomainSuffix","payload":"x.test","target":"Proxy"},{"type":"Match","payload":"","target":"DIRECT"}]}`
	if string(data) != want {
		t.Errorf("rule.list = %s\nwant %s", data, want)
	}
	info := &statistic.TrackerInfo{Metadata: &C.Metadata{}, Start: time.Now(), Chain: C.Chain{"HK-01", "Proxy"}, Rule: "DomainSuffix", RulePayload: "x.test"}
	if got := indexValue(currentRuleTable.indexOf(info, true)); got != 0 {
		t.Errorf("the tracker's index %d, want the first listed", got)
	}

	tunnel.UpdateRules(nil, nil, nil)
	if data, _ := json.Marshal(handleGetRules()); string(data) != `{"rules":[]}` {
		t.Errorf("no rules: %s", data)
	}
}

func TestAListedConnectionOpenedAfterTheRulesWereSwappedElsewhereKeepsItsIndex(t *testing.T) {
	useRules(t, [3]string{"MATCH", "", "DIRECT"})
	info := func() *statistic.TrackerInfo {
		return &statistic.TrackerInfo{Metadata: &C.Metadata{}, Start: time.Now(), Chain: C.Chain{"DIRECT"}, Rule: "Match"}
	}
	currentRuleTable.indexOf(info(), false)
	time.Sleep(time.Millisecond)
	rule, err := rules.ParseRule("MATCH", "", "DIRECT", nil, nil)
	if err != nil {
		t.Fatal(err)
	}
	tunnel.UpdateRules([]C.Rule{rule}, nil, nil)
	opened := info()
	time.Sleep(time.Millisecond)

	if got := indexValue(currentRuleTable.indexOf(opened, true)); got != 0 {
		t.Errorf("listed after an external controller's reload: index %d, want 0", got)
	}
}
