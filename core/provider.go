package core

import (
	"cmp"
	"context"
	"crypto/tls"
	"crypto/x509"
	"errors"
	"io"
	"net"
	"net/url"
	"os"
	"path/filepath"
	"slices"
	"strconv"
	"strings"
	"sync"
	"syscall"

	"github.com/metacubex/mihomo/adapter/provider"
	"github.com/metacubex/mihomo/component/resolver"
	"github.com/metacubex/mihomo/constant"
	cp "github.com/metacubex/mihomo/constant/provider"
	rp "github.com/metacubex/mihomo/rules/provider"
	"github.com/metacubex/mihomo/tunnel"
)

var errNotExternalProvider = errors.New("not external provider")

func externalProviders() map[string]cp.Provider {
	eps := make(map[string]cp.Provider)
	for n, p := range tunnel.ProvidersSnapshot() {
		if p.VehicleType() != cp.Compatible {
			eps[n] = p
		}
	}
	for n, p := range tunnel.RuleProvidersSnapshot() {
		if p.VehicleType() != cp.Compatible {
			eps[n] = p
		}
	}
	return eps
}

func lookupExternalProvider(name string) (cp.Provider, bool) {
	if p, exist := tunnel.RuleProvidersSnapshot()[name]; exist && p.VehicleType() != cp.Compatible {
		return p, true
	}
	if p, exist := tunnel.ProvidersSnapshot()[name]; exist && p.VehicleType() != cp.Compatible {
		return p, true
	}
	return nil, false
}

func toExternalProvider(p cp.Provider) (*ExternalProvider, error) {
	switch typed := p.(type) {
	case *provider.ProxySetProvider:
		return &ExternalProvider{
			Name:             typed.Name(),
			Type:             typed.Type().String(),
			VehicleType:      typed.VehicleType().String(),
			Count:            typed.Count(),
			UpdateAt:         typed.UpdatedAt(),
			Path:             typed.Vehicle().Path(),
			SubscriptionInfo: typed.GetSubscriptionInfo(),
		}, nil
	case *rp.RuleSetProvider:
		return &ExternalProvider{
			Name:        typed.Name(),
			Type:        typed.Type().String(),
			VehicleType: typed.VehicleType().String(),
			Count:       typed.Count(),
			UpdateAt:    typed.UpdatedAt(),
			Path:        typed.Vehicle().Path(),
		}, nil
	default:
		return nil, errNotExternalProvider
	}
}

func sideUpdateExternalProvider(p cp.Provider, data []byte) error {
	switch typed := p.(type) {
	case *provider.ProxySetProvider:
		_, _, err := typed.SideUpdate(data)
		return err
	case *rp.RuleSetProvider:
		_, _, err := typed.SideUpdate(data)
		return err
	default:
		return errNotExternalProvider
	}
}

func handleGetExternalProviders() []ExternalProvider {
	providers := externalProviders()
	eps := make([]ExternalProvider, 0, len(providers))
	for _, p := range providers {
		if externalProvider, err := toExternalProvider(p); err == nil {
			eps = append(eps, *externalProvider)
		}
	}
	slices.SortFunc(eps, func(a, b ExternalProvider) int {
		return cmp.Compare(a.Name, b.Name)
	})
	return eps
}

func handleGetExternalProvider(name string) *ExternalProvider {
	p, exist := lookupExternalProvider(name)
	if !exist {
		return nil
	}
	externalProvider, err := toExternalProvider(p)
	if err != nil {
		return nil
	}
	return externalProvider
}

const (
	geoUpdateScope      = "geo:"
	providerUpdateScope = "provider:"
)

// One update per resource at a time. The value marks a claim taken for
// mihomo's own updater through GeoUpdateHook, the only kind that hook gives
// back: its run can start and finish inside a manual update of the resource.
var updateClaims = struct {
	sync.Mutex
	fromHook map[string]bool
}{fromHook: map[string]bool{}}

func claimUpdateAs(key string, fromHook bool) bool {
	updateClaims.Lock()
	defer updateClaims.Unlock()
	if _, held := updateClaims.fromHook[key]; held {
		return false
	}
	updateClaims.fromHook[key] = fromHook
	return true
}

func claimUpdate(key string) bool {
	return claimUpdateAs(key, false)
}

func releaseUpdate(key string) {
	updateClaims.Lock()
	defer updateClaims.Unlock()
	delete(updateClaims.fromHook, key)
}

func releaseHookUpdate(key string) {
	updateClaims.Lock()
	defer updateClaims.Unlock()
	if updateClaims.fromHook[key] {
		delete(updateClaims.fromHook, key)
	}
}

type providerRequestFailure struct {
	code       string
	reason     string
	statusCode int
}

// The reason values are matched by lib/common/network_error.dart.
func classifyProviderRequestError(err error) (providerRequestFailure, bool) {
	// mihomo reports a non-2xx fetch as errors.New(resp.Status).
	message := err.Error()
	if len(message) >= 4 && message[3] == ' ' {
		status, parseErr := strconv.Atoi(message[:3])
		if parseErr == nil && status >= 100 && status <= 599 {
			return providerRequestFailure{
				code:       "request_bad_response",
				statusCode: status,
			}, true
		}
	}
	var urlError *url.Error
	var networkError net.Error
	if reason := providerRequestFailureReason(err); reason != "" ||
		errors.As(err, &urlError) ||
		errors.As(err, &networkError) {
		return providerRequestFailure{code: "request_error", reason: reason}, true
	}
	return providerRequestFailure{}, false
}

func providerRequestFailureReason(err error) string {
	var unknownAuthority x509.UnknownAuthorityError
	var hostname x509.HostnameError
	var invalidCertificate x509.CertificateInvalidError
	var certificateVerification *tls.CertificateVerificationError
	var recordHeader tls.RecordHeaderError
	var alert tls.AlertError
	var dnsError *net.DNSError
	var networkError net.Error
	var opError *net.OpError
	switch {
	case errors.As(err, &unknownAuthority),
		errors.As(err, &hostname),
		errors.As(err, &invalidCertificate),
		errors.As(err, &certificateVerification),
		errors.As(err, &recordHeader),
		errors.As(err, &alert):
		return "tls"
	case errors.As(err, &dnsError), errors.Is(err, resolver.ErrIPNotFound):
		return "dns"
	case errors.Is(err, context.DeadlineExceeded),
		errors.Is(err, os.ErrDeadlineExceeded),
		errors.As(err, &networkError) && networkError.Timeout():
		return "timeout"
	case errors.As(err, &opError),
		errors.Is(err, syscall.ECONNREFUSED),
		errors.Is(err, syscall.ECONNRESET),
		errors.Is(err, io.EOF),
		errors.Is(err, io.ErrUnexpectedEOF):
		return "connection"
	}
	return ""
}

func providerError(code, providerName string, err error) *MethodError {
	return &MethodError{
		Code:    code,
		Message: err.Error(),
		Details: map[string]any{"providerName": providerName},
	}
}

func providerUpdateError(providerName string, err error) *MethodError {
	if methodErr := requestMethodError(err, map[string]any{"providerName": providerName}); methodErr != nil {
		return methodErr
	}
	return providerError("provider_update_error", providerName, err)
}

func requestMethodError(err error, details map[string]any) *MethodError {
	failure, isRequest := classifyProviderRequestError(err)
	if !isRequest {
		return nil
	}
	if failure.reason != "" {
		details["reason"] = failure.reason
	}
	if failure.statusCode != 0 {
		details["statusCode"] = failure.statusCode
	}
	return &MethodError{Code: failure.code, Message: err.Error(), Details: details}
}

func updateExternalProvider(name string, update func(cp.Provider) *MethodError) error {
	p, exist := lookupExternalProvider(name)
	if !exist {
		return providerError("provider_not_found", name, errors.New("external provider does not exist"))
	}
	key := providerUpdateScope + name
	if !claimUpdate(key) {
		return providerError("provider_updating", name, errors.New("external provider is updating"))
	}
	defer releaseUpdate(key)
	if methodErr := update(p); methodErr != nil {
		return methodErr
	}
	refreshRoute()
	return nil
}

func handleUpdateExternalProvider(name string) error {
	return updateExternalProvider(name, func(p cp.Provider) *MethodError {
		if err := p.Update(); err != nil {
			return providerUpdateError(name, err)
		}
		return nil
	})
}

func handleSideLoadExternalProvider(params *SideLoadParams) error {
	name := params.ProviderName
	return updateExternalProvider(name, func(p cp.Provider) *MethodError {
		if err := sideUpdateExternalProvider(p, []byte(params.Data)); err != nil {
			return providerError("provider_update_error", name, err)
		}
		return nil
	})
}

func handleDumpRuleSet(path string) (string, error) {
	buf, err := os.ReadFile(path)
	if err != nil {
		return "", err
	}
	var errs []error
	for _, behavior := range []cp.RuleBehavior{cp.Domain, cp.IPCIDR} {
		var text strings.Builder
		err := rp.ConvertToMrs(buf, behavior, cp.MrsRule, &text)
		if err == nil {
			return text.String(), nil
		}
		errs = append(errs, err)
	}
	return "", errors.Join(errs...)
}

// The profile ID is an int64 rendered through strconv, so the last element can
// never carry a separator or a `..` — that is what keeps handleClearEffect from
// becoming a general-purpose privileged file deletion API.
func providerPaths(homeDir string, profileId int64) (root string, target string) {
	root = filepath.Join(homeDir, "profiles", "providers")
	return root, filepath.Join(root, strconv.FormatInt(profileId, 10))
}

func handleClearEffect(profileId int64) error {
	if !isInit.Load() {
		return errNotInitialized
	}
	if profileId <= 0 {
		return errors.New("invalid profile id")
	}
	providersRoot, providersPath := providerPaths(constant.Path.HomeDir(), profileId)
	if err := os.RemoveAll(providersPath); err != nil {
		return err
	}
	_ = os.Remove(providersRoot)
	return nil
}
