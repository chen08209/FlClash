package core

import (
	"sync"
	"time"

	C "github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"
	"github.com/metacubex/mihomo/tunnel/statistic"
)

type ruleKey struct {
	kind    string
	payload string
	adapter string
}

// A tracker names its rule only by type and payload, so it is matched to the first rule with those and its policy.
type ruleTable struct {
	mu     sync.Mutex
	rules  []C.Rule
	since  time.Time
	seen   time.Time
	byRule map[C.Rule]int
	byKey  map[ruleKey]int
}

var currentRuleTable ruleTable

// A config apply observes the list it swaps in. One swapped in elsewhere, as by the external
// controller, is found only when next asked for, and counts from when the last was still seen.
func (t *ruleTable) refresh() bool {
	rules := tunnel.Rules()
	last := t.seen
	t.seen = time.Now()
	if t.byRule != nil && len(rules) == len(t.rules) && (len(rules) == 0 || &rules[0] == &t.rules[0]) {
		return false
	}
	t.rules = rules
	t.since = last
	t.byRule = make(map[C.Rule]int, len(rules))
	t.byKey = make(map[ruleKey]int, len(rules))
	for index, rule := range rules {
		if _, ok := t.byRule[rule]; !ok {
			t.byRule[rule] = index
		}
		key := ruleKey{rule.RuleType().String(), rule.Payload(), rule.Adapter()}
		if _, ok := t.byKey[key]; !ok {
			t.byKey[key] = index
		}
	}
	return true
}

func (t *ruleTable) observe() {
	t.mu.Lock()
	defer t.mu.Unlock()
	if t.refresh() {
		t.since = t.seen
	}
}

func (t *ruleTable) indexOfRule(rule C.Rule, metadata *C.Metadata) *int {
	if rule == nil || metadata.SpecialRules != "" {
		return nil
	}
	t.mu.Lock()
	defer t.mu.Unlock()
	t.refresh()
	index, ok := t.byRule[rule]
	return found(index, ok)
}

// A listed connection opened before the current list was routed by one since replaced.
func (t *ruleTable) indexOf(info *statistic.TrackerInfo, listed bool) *int {
	if info.Rule == "" || info.Metadata == nil || info.Metadata.SpecialRules != "" || len(info.Chain) == 0 {
		return nil
	}
	t.mu.Lock()
	defer t.mu.Unlock()
	t.refresh()
	if listed && info.Start.Before(t.since) {
		return nil
	}
	// Chain.Last names the leaf; the rule's policy ends the chain.
	index, ok := t.byKey[ruleKey{info.Rule, info.RulePayload, info.Chain[len(info.Chain)-1]}]
	return found(index, ok)
}

func found(index int, ok bool) *int {
	if !ok {
		return nil
	}
	return &index
}

type requestInfo struct {
	*statistic.TrackerInfo
	RuleIndex  *int     `json:"ruleIndex,omitempty"`
	DnsQueries []uint64 `json:"dnsQueries,omitempty"`
}

type connectionSnapshot struct {
	DownloadTotal int64         `json:"downloadTotal"`
	UploadTotal   int64         `json:"uploadTotal"`
	Connections   []requestInfo `json:"connections"`
	Memory        uint64        `json:"memory"`
}

func newRequestInfo(tracker statistic.Tracker) requestInfo {
	info := tracker.Info()
	return requestInfo{
		TrackerInfo: info,
		RuleIndex:   currentRuleTable.indexOf(info, false),
		DnsQueries:  currentDnsTrail.linkedQueries(info.Metadata, info.Start, dialedAddr(info)),
	}
}

func newConnectionSnapshot(snapshot *statistic.Snapshot) *connectionSnapshot {
	result := &connectionSnapshot{
		DownloadTotal: snapshot.DownloadTotal,
		UploadTotal:   snapshot.UploadTotal,
		Memory:        snapshot.Memory,
	}
	for _, info := range snapshot.Connections {
		result.Connections = append(result.Connections, requestInfo{
			TrackerInfo: info,
			RuleIndex:   currentRuleTable.indexOf(info, true),
		})
	}
	return result
}

type ruleEntry struct {
	Type    string `json:"type"`
	Payload string `json:"payload"`
	Target  string `json:"target"`
}

type ruleList struct {
	Rules []ruleEntry `json:"rules"`
}

// handleGetRules lists the table ruleIndex points into, written as a tracker names its rule.
func handleGetRules() ruleList {
	t := &currentRuleTable
	t.mu.Lock()
	defer t.mu.Unlock()
	t.refresh()
	list := ruleList{Rules: make([]ruleEntry, 0, len(t.rules))}
	for _, rule := range t.rules {
		list.Rules = append(list.Rules, ruleEntry{rule.RuleType().String(), rule.Payload(), rule.Adapter()})
	}
	return list
}
