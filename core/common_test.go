package main

import (
	"encoding/json"
	"go/ast"
	"go/parser"
	"go/token"
	"strconv"
	"testing"

	"github.com/metacubex/mihomo/common/utils"
	"github.com/metacubex/mihomo/constant"
	cp "github.com/metacubex/mihomo/constant/provider"
	"github.com/metacubex/mihomo/tunnel"
)

func TestDefaultSetupParams(t *testing.T) {
	params := defaultSetupParams()

	if params.TestURL != "https://www.gstatic.com/generate_204" {
		t.Errorf("TestURL = %s, want the gstatic generate_204 probe", params.TestURL)
	}
	if params.SelectedMap == nil {
		t.Error("SelectedMap must be a usable map so decoding can merge into it")
	}
}

func TestDefaultSetupParamsSurvivesPartialDecode(t *testing.T) {
	params := defaultSetupParams()

	if err := json.Unmarshal([]byte(`{"selected-map":{"GLOBAL":"auto"}}`), params); err != nil {
		t.Fatalf("decode error: %v", err)
	}

	if params.TestURL != "https://www.gstatic.com/generate_204" {
		t.Errorf("TestURL = %s, want the default to survive a partial payload", params.TestURL)
	}
	if params.SelectedMap["GLOBAL"] != "auto" {
		t.Errorf("SelectedMap = %v, want GLOBAL mapped to auto", params.SelectedMap)
	}
}

func TestUnmarshalJsonPreservesLargeIntegers(t *testing.T) {
	target := map[string]any{}

	if err := UnmarshalJson([]byte(`{"id":9007199254740993}`), &target); err != nil {
		t.Fatalf("UnmarshalJson error: %v", err)
	}

	number, ok := target["id"].(json.Number)
	if !ok {
		t.Fatalf("id decoded as %T, want json.Number so int64 precision survives", target["id"])
	}
	value, err := number.Int64()
	if err != nil {
		t.Fatalf("Int64() error: %v", err)
	}
	if value != 9007199254740993 {
		t.Errorf("id = %d, want 9007199254740993", value)
	}
}

func TestUnmarshalJsonReportsInvalidPayload(t *testing.T) {
	target := map[string]any{}

	if err := UnmarshalJson([]byte(`{`), &target); err == nil {
		t.Fatal("UnmarshalJson accepted malformed JSON")
	}
}

func TestToExternalProviderRejectsUnsupportedProvider(t *testing.T) {
	provider, err := toExternalProvider(nil)

	if err == nil {
		t.Fatal("toExternalProvider accepted a provider it cannot describe")
	}
	if provider != nil {
		t.Errorf("provider = %+v, want nil alongside the error", provider)
	}
}

func TestMethodCallDecodeArgumentsRejectsEmptyPayload(t *testing.T) {
	tests := map[string]json.RawMessage{
		"empty": nil,
		"null":  json.RawMessage("null"),
	}

	for name, arguments := range tests {
		t.Run(name, func(t *testing.T) {
			call := MethodCall{Method: validateConfigMethod, Arguments: arguments}
			target := ""

			err := call.decodeArguments(&target)

			if err == nil {
				t.Fatal("decodeArguments accepted a missing payload")
			}
			if err.Error() != "missing arguments" {
				t.Errorf("error = %v, want \"missing arguments\"", err)
			}
		})
	}
}

func TestMethodCallDecodeArgumentsAcceptsScalar(t *testing.T) {
	call := MethodCall{
		Method:    validateConfigMethod,
		Arguments: json.RawMessage(`"/tmp/config.yaml"`),
	}
	target := ""

	if err := call.decodeArguments(&target); err != nil {
		t.Fatalf("decodeArguments error: %v", err)
	}
	if target != "/tmp/config.yaml" {
		t.Errorf("target = %s, want /tmp/config.yaml", target)
	}
}

func TestSideLoadParamsMatchesTheWirePayload(t *testing.T) {
	params := SideLoadParams{}

	if err := json.Unmarshal([]byte(`{"providerName":"rules","data":"payload"}`), &params); err != nil {
		t.Fatalf("decode error: %v", err)
	}

	if params.ProviderName != "rules" || params.Data != "payload" {
		t.Errorf("params = %+v, want {rules payload}", params)
	}
}

func TestSideUpdateExternalProviderRejectsUnsupportedProvider(t *testing.T) {
	if err := sideUpdateExternalProvider(nil, []byte("payload")); err == nil {
		t.Fatal("sideUpdateExternalProvider accepted a provider it cannot side-load")
	}
}

func coreMethodConstants(t *testing.T) []CoreMethod {
	t.Helper()
	fileSet := token.NewFileSet()
	file, err := parser.ParseFile(fileSet, "constant.go", nil, 0)
	if err != nil {
		t.Fatalf("parse constant.go: %v", err)
	}

	var methods []CoreMethod
	ast.Inspect(file, func(node ast.Node) bool {
		spec, ok := node.(*ast.ValueSpec)
		if !ok {
			return true
		}
		typeName, ok := spec.Type.(*ast.Ident)
		if !ok || typeName.Name != "CoreMethod" {
			return true
		}
		for _, value := range spec.Values {
			literal, ok := value.(*ast.BasicLit)
			if !ok || literal.Kind != token.STRING {
				continue
			}
			unquoted, err := strconv.Unquote(literal.Value)
			if err != nil {
				t.Fatalf("unquote %s: %v", literal.Value, err)
			}
			methods = append(methods, CoreMethod(unquoted))
		}
		return true
	})

	if len(methods) == 0 {
		t.Fatal("found no CoreMethod constants; the parser lost track of constant.go")
	}
	return methods
}

func TestEveryCoreMethodConstantIsDispatchable(t *testing.T) {
	notDispatched := map[CoreMethod]string{
		messageMethod:   "core-to-host event envelope, never received",
		crashMethod:     "handled ahead of the table so it bypasses panic recovery",
		updateDnsMethod: "registered by the cgo build only",
	}

	for _, method := range coreMethodConstants(t) {
		if reason, expected := notDispatched[method]; expected {
			if _, exists := methodHandlers[method]; exists {
				t.Errorf("method %s has a handler but is documented as %s", method, reason)
			}
			continue
		}
		if _, exists := methodHandlers[method]; !exists {
			t.Errorf("method %s has no handler and would answer not_implemented", method)
		}
	}
}

func TestRegisterMethodRejectsADuplicate(t *testing.T) {
	defer func() {
		if recover() == nil {
			t.Error("registerMethod accepted a second handler for an already routed method")
		}
	}()

	registerMethod(getProxiesMethod, withoutArguments(func(response MethodResponse) {}))
}

// fakeProxyProvider and fakeRuleProvider stand in for the mihomo providers the
// tunnel holds. Only the name and the vehicle type matter to the lookup; the
// rest of each interface is here because the tunnel maps are typed.
type fakeProxyProvider struct {
	name    string
	vehicle cp.VehicleType
}

func (f *fakeProxyProvider) Name() string                { return f.name }
func (f *fakeProxyProvider) VehicleType() cp.VehicleType { return f.vehicle }
func (f *fakeProxyProvider) Type() cp.ProviderType       { return cp.Proxy }
func (f *fakeProxyProvider) Initial() error              { return nil }
func (f *fakeProxyProvider) Update() error               { return nil }
func (f *fakeProxyProvider) Proxies() []constant.Proxy   { return nil }
func (f *fakeProxyProvider) Count() int                  { return 0 }
func (f *fakeProxyProvider) Touch()                      {}
func (f *fakeProxyProvider) HealthCheck()                {}
func (f *fakeProxyProvider) Version() uint32             { return 0 }
func (f *fakeProxyProvider) RegisterHealthCheckTask(string, utils.IntRanges[uint16], string, uint) {
}
func (f *fakeProxyProvider) HealthCheckURL() string { return "" }

type fakeRuleProvider struct {
	name    string
	vehicle cp.VehicleType
}

func (f *fakeRuleProvider) Name() string                { return f.name }
func (f *fakeRuleProvider) VehicleType() cp.VehicleType { return f.vehicle }
func (f *fakeRuleProvider) Type() cp.ProviderType       { return cp.Rule }
func (f *fakeRuleProvider) Initial() error              { return nil }
func (f *fakeRuleProvider) Update() error               { return nil }
func (f *fakeRuleProvider) Behavior() cp.RuleBehavior   { return cp.Domain }
func (f *fakeRuleProvider) Count() int                  { return 0 }
func (f *fakeRuleProvider) Match(*constant.Metadata, constant.RuleMatchHelper) bool {
	return false
}
func (f *fakeRuleProvider) Strategy() any { return nil }

// withTunnelProviders installs a provider set for the duration of a test. The
// unit tests never apply a config, so the tunnel starts empty and restoring it
// to empty is restoring what was there.
func withTunnelProviders(
	t *testing.T,
	proxyProviders map[string]cp.ProxyProvider,
	ruleProviders map[string]cp.RuleProvider,
) {
	t.Helper()
	tunnel.UpdateProxies(nil, proxyProviders)
	tunnel.UpdateRules(nil, nil, ruleProviders)
	t.Cleanup(func() {
		tunnel.UpdateProxies(nil, nil)
		tunnel.UpdateRules(nil, nil, nil)
	})
}

func TestExternalProvidersSkipsInlineProviders(t *testing.T) {
	withTunnelProviders(t,
		map[string]cp.ProxyProvider{
			"subscription": &fakeProxyProvider{name: "subscription", vehicle: cp.HTTP},
			"inline":       &fakeProxyProvider{name: "inline", vehicle: cp.Compatible},
		},
		map[string]cp.RuleProvider{
			"ruleset": &fakeRuleProvider{name: "ruleset", vehicle: cp.HTTP},
		},
	)

	providers := externalProviders()

	if _, exist := providers["inline"]; exist {
		t.Error("a compatible provider was reported as externally updatable")
	}
	if len(providers) != 2 {
		t.Errorf("externalProviders() = %d entries, want subscription and ruleset", len(providers))
	}
}

func TestLookupExternalProviderFollowsAConfigReplacement(t *testing.T) {
	tunnel.UpdateProxies(nil, map[string]cp.ProxyProvider{
		"first": &fakeProxyProvider{name: "first", vehicle: cp.HTTP},
	})
	t.Cleanup(func() { tunnel.UpdateProxies(nil, nil) })

	if _, exist := lookupExternalProvider("first"); !exist {
		t.Fatal("the installed provider was not found")
	}

	tunnel.UpdateProxies(nil, map[string]cp.ProxyProvider{
		"second": &fakeProxyProvider{name: "second", vehicle: cp.HTTP},
	})

	if _, exist := lookupExternalProvider("first"); exist {
		t.Error("a provider the tunnel no longer holds is still reachable, so updating it writes to disk for nothing")
	}
	if _, exist := lookupExternalProvider("second"); !exist {
		t.Error("the replacement provider is not reachable")
	}
}

func TestLookupExternalProviderRejectsInlineAndUnknownNames(t *testing.T) {
	withTunnelProviders(t,
		map[string]cp.ProxyProvider{
			"inline": &fakeProxyProvider{name: "inline", vehicle: cp.Compatible},
		},
		nil,
	)

	if _, exist := lookupExternalProvider("inline"); exist {
		t.Error("an inline provider is not externally updatable but was handed out")
	}
	if _, exist := lookupExternalProvider("missing"); exist {
		t.Error("an unknown name resolved to a provider")
	}
}

// externalProviders writes rule providers last, so one shadows a proxy provider
// sharing its name. The lookup has to agree with the list the host was given.
func TestLookupExternalProviderMatchesTheListedPrecedence(t *testing.T) {
	const shared = "same-name"
	ruleProvider := &fakeRuleProvider{name: shared, vehicle: cp.HTTP}
	withTunnelProviders(t,
		map[string]cp.ProxyProvider{shared: &fakeProxyProvider{name: shared, vehicle: cp.HTTP}},
		map[string]cp.RuleProvider{shared: ruleProvider},
	)

	found, exist := lookupExternalProvider(shared)
	if !exist {
		t.Fatal("the shared name resolved to nothing")
	}
	if found != externalProviders()[shared] {
		t.Error("lookupExternalProvider disagrees with the list externalProviders builds")
	}
	if found != cp.Provider(ruleProvider) {
		t.Error("the proxy provider shadowed the rule provider, reversing the listed precedence")
	}
}
