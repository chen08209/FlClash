package core

import (
	"os"
	"regexp"
	"strings"
	"testing"

	"github.com/dlclark/regexp2"
)

func TestValidateFiltersReadsEachBacktickPart(t *testing.T) {
	results := handleValidateFilters([]string{
		"",
		"(?i)港|(?<![a-z])hk(?![a-z])",
		"hk`jp",
		"[a-z-[aeiou]]",
		"(abc",
		"hk`(",
	})
	for i, valid := range []bool{true, true, true, true, false, false} {
		if (results[i] == "") != valid {
			t.Errorf("filter %d: got %q, want valid=%v", i, results[i], valid)
		}
	}
}

var presetEntry = regexp.MustCompile(`Filter\(\s*label:\s*'([^']*)',\s*regex:\s*((?:r'[^']*'\s*)+),?\s*\)`)
var rawString = regexp.MustCompile(`r'([^']*)'`)

func filterPresets(t *testing.T) map[string]string {
	t.Helper()
	source, err := os.ReadFile("../lib/models/config.dart")
	if err != nil {
		t.Fatal(err)
	}
	_, body, _ := strings.Cut(string(source), "const defaultFilters = [")
	body, _, _ = strings.Cut(body, "\n];")
	presets := map[string]string{}
	for _, entry := range presetEntry.FindAllStringSubmatch(body, -1) {
		var pattern strings.Builder
		for _, part := range rawString.FindAllStringSubmatch(entry[2], -1) {
			pattern.WriteString(part[1])
		}
		presets[entry[1]] = pattern.String()
	}
	if len(presets) == 0 {
		t.Fatal("found no presets; the parser lost track of defaultFilters")
	}
	return presets
}

func TestFilterPresetsMatchTheirNamesOnly(t *testing.T) {
	matches := map[string][]string{
		"Hong Kong":         {"🇭🇰 HK 01", "香港 IPLC", "Hong Kong-02"},
		"Taiwan":            {"🇹🇼 TW", "台湾 家宽", "Taiwan 03"},
		"Japan":             {"JP01", "日本 东京", "Tokyo 2"},
		"Singapore":         {"SG-1", "新加坡", "Singapore"},
		"United States":     {"US 01", "USA", "美国 洛杉矶", "美西"},
		"South Korea":       {"KR 1", "韩国", "South Korea"},
		"United Kingdom":    {"UK-London", "英国", "GB 2"},
		"Remaining Traffic": {"剩余流量：10 GB", "剩餘流量: 1.2 TB", "已用流量 20%", "流量：10G / 100G", "Traffic: 10 GB", "Remaining 1 TB"},
		"Expiry Date":       {"套餐到期：2026-12-31", "过期时间：2026-01-01", "Expire: 2026-12-31", "Expiration 2026-12-31"},
		"Traffic Reset":     {"距离下次重置剩余：12 天", "Next Reset: 12 days"},
		"Website & Notices": {"官网：example.com", "最新网址 example.com", "公告：请更新订阅", "当前套餐：Pro", "Telegram 群组", "TG 频道", "Website: example.com"},
	}
	misses := map[string][]string{
		"Hong Kong":         {"CHKS 1", "Japan 01"},
		"United States":     {"Russia 01", "Australia", "Plus"},
		"United Kingdom":    {"Ukraine 01"},
		"Remaining Traffic": {"香港 01", "US 大带宽", "HK 大流量"},
		"Expiry Date":       {"香港 01", "Japan 01"},
		"Traffic Reset":     {"香港 01", "US Reserved"},
		"Website & Notices": {"香港 01", "US Montgomery", "Taiwan 01"},
	}
	presets := filterPresets(t)
	for name := range matches {
		if _, ok := presets[name]; !ok {
			t.Errorf("preset %s is gone from defaultFilters", name)
		}
	}
	for name, pattern := range presets {
		if _, ok := matches[name]; !ok {
			t.Errorf("preset %s has no sample names here", name)
			continue
		}
		reg, err := regexp2.Compile(pattern, regexp2.None)
		if err != nil {
			t.Errorf("preset %s: %v", name, err)
			continue
		}
		for _, sample := range matches[name] {
			if ok, _ := reg.MatchString(sample); !ok {
				t.Errorf("preset %s misses %q", name, sample)
			}
		}
		for _, sample := range misses[name] {
			if ok, _ := reg.MatchString(sample); ok {
				t.Errorf("preset %s matches %q", name, sample)
			}
		}
	}
}
