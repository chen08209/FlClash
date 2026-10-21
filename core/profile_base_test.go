package core

import (
	"bytes"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"reflect"
	"strings"
	"testing"

	"github.com/metacubex/mihomo/adapter/provider"
	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/constant"
	cp "github.com/metacubex/mihomo/constant/provider"
	"go.yaml.in/yaml/v3"
)

const baseProfile = `x-defaults: &socks {type: socks5, server: 127.0.0.1, port: 1080}
mixed-port: 7000
dns:
  enable: true
  nameserver: [223.5.5.5]
proxies:
  - {<<: *socks, name: a}
  - name: b
    type: vless
    server: 127.0.0.1
    port: 443
    uuid: 2a70e3a9-b4ce-4f20-908d-e99950a0a611
    network: tcp
    tls: true
    reality-opts: {public-key: SbVKOEMjK0sIlbwg4akyBg5mL5KZwwB-ed4eEE7YnRc, short-id: 0123}
proxy-groups:
  - {name: g, type: select, proxies: [a, b]}
sub-rules:
  sub: ["MATCH,g"]
rules:
  - DOMAIN-SUFFIX,example.com,g
  - match,DIRECT
  - MATCH,g
`

func writeBaseProfile(t *testing.T, profile string) string {
	t.Helper()
	path := filepath.Join(t.TempDir(), "profile.yaml")
	if err := os.WriteFile(path, []byte(profile), 0o600); err != nil {
		t.Fatalf("write profile: %v", err)
	}
	return path
}

// The overlay is the host's patch of what getProfileBase returned.
func overlayOf(t *testing.T, base *ProfileBase, rules []string, patch map[string]any) string {
	t.Helper()
	data, err := json.Marshal(base.Config)
	if err != nil {
		t.Fatalf("marshal base: %v", err)
	}
	var overlay map[string]any
	if err := json.Unmarshal(data, &overlay); err != nil {
		t.Fatalf("unmarshal base: %v", err)
	}
	delete(overlay, "rule")
	overlay["rules"] = rules
	for key, value := range patch {
		overlay[key] = value
	}
	data, err = json.Marshal(overlay)
	if err != nil {
		t.Fatalf("marshal overlay: %v", err)
	}
	return string(data)
}

func ruleStrings(cfg *config.Config) []string {
	rules := make([]string, 0, len(cfg.Rules))
	for _, rule := range cfg.Rules {
		rules = append(rules, rule.RuleType().String()+","+rule.Payload()+","+rule.Adapter())
	}
	return rules
}

func TestHandleGetProfileBaseLeavesTheBulkSectionsInTheCore(t *testing.T) {
	path := writeBaseProfile(t, baseProfile)

	base, err := handleGetProfileBase(path)

	if err != nil {
		t.Fatalf("handleGetProfileBase = %v", err)
	}
	raw := base.Config
	if raw.Proxy != nil || raw.ProxyGroup != nil || raw.Rule != nil || raw.SubRules != nil {
		t.Errorf("config kept a bulk section: %+v", raw)
	}
	if raw.MixedPort != 7000 || !raw.DNS.Enable {
		t.Errorf("config dropped a section the host patches: mixed-port %d, dns %t", raw.MixedPort, raw.DNS.Enable)
	}
	if base.Proxies != 2 || base.ProxyGroups != 1 || base.Rules != 3 {
		t.Errorf("counts = %d/%d/%d, want 2/1/3", base.Proxies, base.ProxyGroups, base.Rules)
	}
	if want := []string{"match,DIRECT", "MATCH,g"}; !reflect.DeepEqual(base.MatchRules, want) {
		t.Errorf("match rules = %v, want %v", base.MatchRules, want)
	}
	digest := sha256.Sum256([]byte(baseProfile))
	if base.Digest != hex.EncodeToString(digest[:]) {
		t.Errorf("digest = %s, want the sha256 of the file", base.Digest)
	}
}

func TestHandleGetProfileOutboundsListsOnlyNamesAndTypes(t *testing.T) {
	path := writeBaseProfile(t, baseProfile)

	outbounds, err := handleGetProfileOutbounds(path)

	if err != nil {
		t.Fatalf("handleGetProfileOutbounds = %v", err)
	}
	want := &ProfileOutbounds{
		Proxies:     []ProfileOutbound{{Name: "a", Type: "socks5"}, {Name: "b", Type: "vless"}},
		ProxyGroups: []ProfileOutbound{{Name: "g", Type: "select"}},
	}
	if !reflect.DeepEqual(outbounds, want) {
		t.Errorf("outbounds = %+v, want %+v", outbounds, want)
	}
}

func TestHandleBuildProfileWritesTheMergedConfigWhereTheHostReadsSpills(t *testing.T) {
	withSpillHome(t, responseSpillThreshold)
	path := writeBaseProfile(t, baseProfile)
	base, err := handleGetProfileBase(path)
	if err != nil {
		t.Fatalf("handleGetProfileBase = %v", err)
	}
	overlay := overlayOf(t, base, []string{"DOMAIN,added.test,DIRECT"}, nil)

	built, err := handleBuildProfile(&SetupBase{Path: path, Overlay: overlay})

	if err != nil {
		t.Fatalf("handleBuildProfile = %v", err)
	}
	if filepath.Dir(built) != spilledResponseDir() {
		t.Errorf("built %s, want it in %s", built, spilledResponseDir())
	}
	cfg, err := loadConfig(built)
	if err != nil {
		t.Fatalf("loadConfig(built) = %v", err)
	}
	if got := ruleStrings(cfg); len(got) != 4 || got[0] != "Domain,added.test,DIRECT" {
		t.Errorf("rules = %v, want the added rule before the profile's three", got)
	}
}

func TestLoadConfigWithBasePutsTheAddedRulesFirstAndTheOverlayOverTheRest(t *testing.T) {
	path := writeBaseProfile(t, baseProfile)
	base, err := handleGetProfileBase(path)
	if err != nil {
		t.Fatalf("handleGetProfileBase = %v", err)
	}
	overlay := overlayOf(t, base, []string{"DOMAIN,added.test,DIRECT"}, map[string]any{
		"mixed-port": 7890,
		"dns":        map[string]any{"enable": true, "nameserver": []string{"1.1.1.1"}},
	})
	configPath := filepath.Join(t.TempDir(), "config.yaml")

	cfg, err := loadConfigWithBase(&SetupBase{Path: path, Overlay: overlay}, configPath)

	if err != nil {
		t.Fatalf("loadConfigWithBase = %v", err)
	}
	want := []string{
		"Domain,added.test,DIRECT",
		"DomainSuffix,example.com,g",
		"Match,,DIRECT",
		"Match,,g",
	}
	if got := ruleStrings(cfg); !reflect.DeepEqual(got, want) {
		t.Errorf("rules = %v, want %v", got, want)
	}
	if cfg.General.MixedPort != 7890 {
		t.Errorf("mixed-port = %d, want the overlay's", cfg.General.MixedPort)
	}
	if len(cfg.DNS.NameServer) != 1 || !strings.Contains(cfg.DNS.NameServer[0].Addr, "1.1.1.1") {
		t.Errorf("nameservers = %+v, want only the overlay's", cfg.DNS.NameServer)
	}
	for _, name := range []string{"a", "b", "g"} {
		if cfg.Proxies[name] == nil {
			t.Errorf("proxy %s is missing", name)
		}
	}
	if len(cfg.SubRules["sub"]) != 1 {
		t.Errorf("sub-rules = %v, want the profile's", cfg.SubRules)
	}
}

// The Android service and mihomo's controller reload config.yaml without the
// profile, and the anchor it was written with sits in a section the overlay drops.
func TestLoadConfigWithBaseWritesAConfigThatLoadsAlone(t *testing.T) {
	path := writeBaseProfile(t, baseProfile)
	base, err := handleGetProfileBase(path)
	if err != nil {
		t.Fatalf("handleGetProfileBase = %v", err)
	}
	configPath := filepath.Join(t.TempDir(), "config.yaml")
	cfg, err := loadConfigWithBase(
		&SetupBase{Path: path, Overlay: overlayOf(t, base, []string{"DOMAIN,added.test,DIRECT"}, nil)},
		configPath,
	)
	if err != nil {
		t.Fatalf("loadConfigWithBase = %v", err)
	}

	reloaded, err := loadConfig(configPath)

	if err != nil {
		t.Fatalf("loadConfig(config.yaml) = %v", err)
	}
	if got, want := ruleStrings(reloaded), ruleStrings(cfg); !reflect.DeepEqual(got, want) {
		t.Errorf("reloaded rules = %v, want %v", got, want)
	}
	if len(reloaded.Proxies) != len(cfg.Proxies) {
		t.Errorf("reloaded %d proxies, want %d", len(reloaded.Proxies), len(cfg.Proxies))
	}
	raw, err := handleGetConfig(configPath)
	if err != nil {
		t.Fatalf("handleGetConfig(config.yaml) = %v", err)
	}
	for _, proxy := range raw.Proxy {
		if proxy["name"] != "b" {
			continue
		}
		if got := proxy["reality-opts"].(map[string]any)["short-id"]; got != "0123" {
			t.Errorf("short-id = %#v, want the literal 0123", got)
		}
	}
}

func TestLoadConfigWithBaseKeepsAnEmptyProfileOnTheDefaults(t *testing.T) {
	path := writeBaseProfile(t, "")

	cfg, err := loadConfigWithBase(
		&SetupBase{Path: path, Overlay: `{"rules": ["MATCH,DIRECT"]}`},
		filepath.Join(t.TempDir(), "config.yaml"),
	)

	if err != nil {
		t.Fatalf("loadConfigWithBase = %v", err)
	}
	if got := ruleStrings(cfg); !reflect.DeepEqual(got, []string{"Match,,DIRECT"}) {
		t.Errorf("rules = %v, want the added rule alone", got)
	}
}

func TestLoadConfigWithBaseRejectsAProfileThatIsNotAMapping(t *testing.T) {
	path := writeBaseProfile(t, "- a\n- b\n")
	configPath := filepath.Join(t.TempDir(), "config.yaml")

	if _, err := loadConfigWithBase(&SetupBase{Path: path, Overlay: "{}"}, configPath); err == nil {
		t.Fatal("loadConfigWithBase accepted a list as a config")
	}
	if _, err := os.Stat(configPath); !os.IsNotExist(err) {
		t.Errorf("stat config.yaml = %v, want the failed apply to leave it alone", err)
	}
}

func TestLoadSetupConfigReadsConfigYamlWithoutABase(t *testing.T) {
	home := t.TempDir()
	previous := constant.Path.HomeDir()
	constant.SetHomeDir(home)
	t.Cleanup(func() { constant.SetHomeDir(previous) })
	profile := "rules:\n  - MATCH,REJECT\n"
	if err := os.WriteFile(filepath.Join(home, "config.yaml"), []byte(profile), 0o600); err != nil {
		t.Fatalf("write config: %v", err)
	}

	cfg, err := loadSetupConfig(defaultSetupParams())

	if err != nil {
		t.Fatalf("loadSetupConfig = %v", err)
	}
	if got := ruleStrings(cfg); !reflect.DeepEqual(got, []string{"Match,,REJECT"}) {
		t.Errorf("rules = %v, want config.yaml's", got)
	}
}

func TestHandleGetProxyDefinitionReadsTheRunningConfig(t *testing.T) {
	home := t.TempDir()
	previous := constant.Path.HomeDir()
	constant.SetHomeDir(home)
	t.Cleanup(func() { constant.SetHomeDir(previous) })
	if err := os.WriteFile(filepath.Join(home, "config.yaml"), []byte(baseProfile), 0o600); err != nil {
		t.Fatalf("write config: %v", err)
	}

	merged, err := handleGetProxyDefinition("a")
	if err != nil {
		t.Fatalf("handleGetProxyDefinition(a) = %v", err)
	}
	reality, err := handleGetProxyDefinition("b")
	if err != nil {
		t.Fatalf("handleGetProxyDefinition(b) = %v", err)
	}
	group, err := handleGetProxyDefinition("g")
	if err != nil {
		t.Fatalf("handleGetProxyDefinition(g) = %v", err)
	}

	want := map[string]any{"name": "a", "type": "socks5", "server": "127.0.0.1", "port": 1080}
	if !reflect.DeepEqual(merged, want) {
		t.Errorf("definition of a = %v, want %v", merged, want)
	}
	if opts, _ := reality["reality-opts"].(map[string]any); opts["short-id"] != "0123" {
		t.Errorf("reality-opts of b = %v, want short-id kept as the string 0123", reality["reality-opts"])
	}
	if group != nil {
		t.Errorf("definition of group g = %v, want none", group)
	}
}

func TestHandleGetProxyDefinitionReadsAProviderProxyAsItsProviderBuildsIt(t *testing.T) {
	home := t.TempDir()
	previous := constant.Path.HomeDir()
	constant.SetHomeDir(home)
	t.Cleanup(func() { constant.SetHomeDir(previous) })
	const subscription = `proxies:
  - {name: a, type: socks5, server: 127.0.0.1, port: 1080}
  - {name: b, type: socks5, server: 127.0.0.2, port: 1080}
`
	const running = `proxy-providers:
  sub:
    type: file
    path: ./sub.yaml
    exclude-filter: ^a$
    override: {additional-prefix: "S-", udp: false}
  inline:
    type: inline
    payload:
      - {name: c, type: socks5, server: 127.0.0.3, port: 1080}
`
	for path, content := range map[string]string{"sub.yaml": subscription, "config.yaml": running} {
		if err := os.WriteFile(filepath.Join(home, path), []byte(content), 0o600); err != nil {
			t.Fatalf("write %s: %v", path, err)
		}
	}
	raw, err := handleGetConfig(runningConfigPath())
	if err != nil {
		t.Fatalf("read running config: %v", err)
	}
	providers := map[string]cp.ProxyProvider{}
	for name, mapping := range raw.ProxyProvider {
		pd, err := provider.ParseProxyProvider(name, mapping, nil)
		if err != nil {
			t.Fatalf("parse provider %s: %v", name, err)
		}
		if err := pd.Initial(); err != nil {
			t.Fatalf("load provider %s: %v", name, err)
		}
		t.Cleanup(func() { _ = pd.(interface{ Close() error }).Close() })
		providers[name] = pd
	}
	withTunnelProviders(t, providers, nil)

	for name, want := range map[string]map[string]any{
		"S-b": {"name": "S-b", "type": "socks5", "server": "127.0.0.2", "port": 1080, "udp": false},
		"c":   {"name": "c", "type": "socks5", "server": "127.0.0.3", "port": 1080},
		"a":   nil,
	} {
		got, err := handleGetProxyDefinition(name)
		if err != nil {
			t.Fatalf("handleGetProxyDefinition(%s) = %v", name, err)
		}
		if want == nil && got != nil || want != nil && !reflect.DeepEqual(got, want) {
			t.Errorf("definition of %s = %v, want %v", name, got, want)
		}
	}
}

func TestEncodeConfigMappingKeepsEveryKeyAfterAnOpenEndedScalar(t *testing.T) {
	rules := make([]string, encodeSliceLength*2+1)
	for i := range rules {
		rules[i] = fmt.Sprintf("DOMAIN,%d.test,DIRECT", i)
	}
	var mapping yaml.Node
	if err := mapping.Encode(map[string]any{"rules": rules}); err != nil {
		t.Fatalf("encode rules: %v", err)
	}
	note := []*yaml.Node{
		{Kind: yaml.ScalarNode, Tag: "!!str", Value: "a-note"},
		{Kind: yaml.ScalarNode, Tag: "!!str", Value: "kept\n\n", Style: yaml.LiteralStyle},
	}
	mapping.Content = append(note, mapping.Content...)
	var out bytes.Buffer

	if err := encodeConfigMapping(&out, &mapping); err != nil {
		t.Fatalf("encodeConfigMapping = %v", err)
	}

	var decoded struct {
		Note  string   `yaml:"a-note"`
		Rules []string `yaml:"rules"`
	}
	if err := yaml.Unmarshal(out.Bytes(), &decoded); err != nil {
		t.Fatalf("decode = %v", err)
	}
	if decoded.Note != "kept\n\n" {
		t.Errorf("note = %q, want its trailing lines kept", decoded.Note)
	}
	if !reflect.DeepEqual(decoded.Rules, rules) {
		t.Errorf("decoded %d rules, want all %d in order", len(decoded.Rules), len(rules))
	}
}
