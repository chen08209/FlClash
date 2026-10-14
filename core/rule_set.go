package core

import (
	"bytes"
	"context"
	"io"
	"net/netip"
	"os"
	"path/filepath"
	"slices"
	"strings"

	"github.com/metacubex/mihomo/common/utils"
	"github.com/metacubex/mihomo/common/yaml"
	"github.com/metacubex/mihomo/component/resource"
	"github.com/metacubex/mihomo/constant"
	cp "github.com/metacubex/mihomo/constant/provider"
	rp "github.com/metacubex/mihomo/rules/provider"
)

var (
	errRuleSetEmpty   = &MethodError{Code: "rule_set_empty", Message: "rule set has no usable entries"}
	errRuleSetMixed   = &MethodError{Code: "rule_set_mixed", Message: "rule set mixes domains and IP ranges"}
	errRuleSetInvalid = &MethodError{Code: "rule_set_invalid", Message: "rule set is not a readable mrs file"}
)

var zstdMagic = []byte{0x28, 0xB5, 0x2F, 0xFD}

// A name, never a path: the Core may run as root. The directory and the .mrs
// beside the source match ClashProviderExt in lib/models/common.dart.
func ruleSetCachePath(name string) (string, bool) {
	if name == "" || name[0] == '.' {
		return "", false
	}
	for _, r := range name {
		if !(r >= 'a' && r <= 'z' || r >= 'A' && r <= 'Z' || r >= '0' && r <= '9' || r == '.' || r == '-' || r == '_') {
			return "", false
		}
	}
	return filepath.Join(constant.Path.HomeDir(), "providers", "rules", name), true
}

func handleCompileRuleSet(params CompileRuleSetParams) (*RuleSetInfo, error) {
	if !isInit.Load() {
		return nil, errNotInitialized
	}
	source, ok := ruleSetCachePath(params.Name)
	if !ok {
		return nil, &MethodError{Code: "invalid_arguments", Message: "invalid rule set name"}
	}
	var buf []byte
	var err error
	if params.URL != "" {
		buf, err = downloadRuleSet(params.URL, source)
	} else {
		buf, err = os.ReadFile(source)
	}
	if err != nil {
		return nil, err
	}
	info, mrs, err := compileRuleSet(buf, params.URL == "")
	if err != nil {
		return nil, err
	}
	if params.URL != "" {
		if err := writeRuleSetFile(source, buf); err != nil {
			return nil, err
		}
	}
	if mrs != nil {
		if err := writeRuleSetFile(source+".mrs", mrs); err != nil {
			return nil, err
		}
	}
	return info, nil
}

func downloadRuleSet(url string, path string) ([]byte, error) {
	buf, _, err := resource.NewHTTPVehicle(url, path, "", nil, resource.DefaultHttpTimeout, 0).
		Read(context.Background(), utils.HashType{})
	if err != nil {
		if methodErr := requestMethodError(err, map[string]any{}); methodErr != nil {
			return nil, methodErr
		}
		return nil, err
	}
	return buf, nil
}

func writeRuleSetFile(path string, buf []byte) error {
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return err
	}
	// The directory belongs to the user while the Core may run as root, so the
	// temp file is created afresh rather than opened through whatever is there.
	temp := path + ".tmp"
	_ = os.Remove(temp)
	file, err := os.OpenFile(temp, os.O_WRONLY|os.O_CREATE|os.O_EXCL, 0o644)
	if err != nil {
		return err
	}
	_, err = file.Write(buf)
	if closeErr := file.Close(); err == nil {
		err = closeErr
	}
	if err != nil {
		_ = os.Remove(temp)
		return err
	}
	if err := os.Rename(temp, path); err != nil {
		_ = os.Remove(temp)
		return err
	}
	return nil
}

func compileRuleSet(buf []byte, allowEmpty bool) (*RuleSetInfo, []byte, error) {
	if bytes.HasPrefix(buf, zstdMagic) {
		for _, behavior := range []cp.RuleBehavior{cp.Domain, cp.IPCIDR} {
			if rp.ConvertToMrs(buf, behavior, cp.MrsRule, io.Discard) == nil {
				return ruleSetInfo(cp.MrsRule, behavior), nil, nil
			}
		}
		return nil, nil, errRuleSetInvalid
	}
	format, entries := ruleSetEntries(buf)
	if len(entries) == 0 && allowEmpty {
		return ruleSetInfo(format, cp.Classical), nil, nil
	}
	behavior, keys, err := classifyRuleSet(entries)
	if err != nil {
		return nil, nil, err
	}
	info := ruleSetInfo(format, behavior)
	if behavior == cp.Classical {
		return info, nil, nil
	}
	var mrs bytes.Buffer
	// With an in-memory writer the only failure left is that no key parsed.
	if err := rp.ConvertToMrs([]byte(strings.Join(keys, "\n")), behavior, cp.TextRule, &mrs); err != nil {
		return nil, nil, errRuleSetEmpty
	}
	return info, mrs.Bytes(), nil
}

func ruleSetInfo(format cp.RuleFormat, behavior cp.RuleBehavior) *RuleSetInfo {
	formats := map[cp.RuleFormat]string{cp.YamlRule: "yaml", cp.TextRule: "text", cp.MrsRule: "mrs"}
	return &RuleSetInfo{Behavior: strings.ToLower(behavior.String()), Format: formats[format]}
}

func ruleSetEntries(buf []byte) (cp.RuleFormat, []string) {
	var schema struct {
		Payload *[]string `yaml:"payload"`
		Rules   *[]string `yaml:"rules"`
	}
	if yaml.Unmarshal(buf, &schema) == nil && (schema.Payload != nil || schema.Rules != nil) {
		var entries []string
		for _, list := range []*[]string{schema.Payload, schema.Rules} {
			if list == nil {
				continue
			}
			for _, entry := range *list {
				if entry = strings.TrimSpace(entry); entry != "" {
					entries = append(entries, entry)
				}
			}
		}
		return cp.YamlRule, entries
	}
	var entries []string
	for _, line := range strings.Split(string(buf), "\n") {
		line = strings.TrimSpace(line)
		if line == "" || line[0] == '#' || strings.HasPrefix(line, "//") {
			continue
		}
		entries = append(entries, line)
	}
	return cp.TextRule, entries
}

func classifyRuleSet(entries []string) (cp.RuleBehavior, []string, error) {
	if len(entries) == 0 {
		return cp.Classical, nil, errRuleSetEmpty
	}
	if slices.ContainsFunc(entries, func(entry string) bool { return strings.Contains(entry, ",") }) {
		behavior, keys := classifyClassical(entries)
		return behavior, keys, nil
	}
	cidrs := make([]string, 0, len(entries))
	for _, entry := range entries {
		if cidr, ok := parseCIDR(entry); ok {
			cidrs = append(cidrs, cidr)
		}
	}
	switch len(cidrs) {
	case 0:
		return cp.Domain, entries, nil
	case len(entries):
		return cp.IPCIDR, cidrs, nil
	}
	return cp.Classical, nil, errRuleSetMixed
}

func classifyClassical(entries []string) (cp.RuleBehavior, []string) {
	domains := make([]string, 0, len(entries))
	cidrs := make([]string, 0, len(entries))
	for _, entry := range entries {
		ruleType, value, ok := strings.Cut(entry, ",")
		if !ok || strings.Contains(value, ",") {
			return cp.Classical, nil
		}
		value = strings.TrimSpace(value)
		switch strings.ToUpper(strings.TrimSpace(ruleType)) {
		case "DOMAIN":
			if !plainDomain(value) {
				return cp.Classical, nil
			}
			domains = append(domains, value)
		case "DOMAIN-SUFFIX":
			if !plainDomain(value) {
				return cp.Classical, nil
			}
			domains = append(domains, "+."+value)
		case "IP-CIDR", "IP-CIDR6":
			if _, err := netip.ParsePrefix(value); err != nil {
				return cp.Classical, nil
			}
			cidrs = append(cidrs, value)
		default:
			return cp.Classical, nil
		}
	}
	switch {
	case len(cidrs) == 0:
		return cp.Domain, domains
	case len(domains) == 0:
		return cp.IPCIDR, cidrs
	}
	return cp.Classical, nil
}

// A domain set reads a leading dot, "+" and "*" as wildcards.
func plainDomain(value string) bool {
	return value != "" && value[0] != '.' && !strings.ContainsAny(value, "+*/")
}

func parseCIDR(entry string) (string, bool) {
	if _, err := netip.ParsePrefix(entry); err == nil {
		return entry, true
	}
	if addr, err := netip.ParseAddr(entry); err == nil {
		addr = addr.WithZone("")
		return netip.PrefixFrom(addr, addr.BitLen()).String(), true
	}
	return "", false
}
