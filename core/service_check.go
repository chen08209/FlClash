package main

import (
	"context"
	"strings"
	"time"

	"github.com/metacubex/http"
)

const (
	// A sweep runs a few checks at a time so it cannot take every probe slot.
	// It therefore runs in waves, and a rule like Disney+ spends several
	// requests in sequence, so the run gets a multiple of the request budget.
	serviceCheckConcurrency  = 4
	serviceSweepBudgetFactor = 6

	// Region markers sit deep inside these pages; endpoints that answer with a
	// few lines get the small cap.
	serviceHtmlMaxBody  = 512 * 1024
	serviceSmallMaxBody = 16 * 1024
)

// Statuses a check reports. Dart maps each to a localized label, so these
// strings are part of the contract and cannot be reworded on one side alone.
const (
	serviceAvailable         = "available"
	serviceUnavailable       = "unavailable"
	serviceRestricted        = "restricted"
	serviceDisallowedIsp     = "disallowed-isp"
	serviceBlocked           = "blocked"
	serviceUnsupportedRegion = "unsupported-region"
	serviceOriginalsOnly     = "originals-only"
	serviceComingSoon        = "coming-soon"
	serviceTimeout           = "timeout"
	serviceFailed            = "failed"
)

// An empty Names runs every check.
type ServiceCheckParams struct {
	ProxyName string   `json:"proxy-name"`
	Names     []string `json:"names"`
	Timeout   int64    `json:"timeout"`
}

// runServiceCheck stamps Name; a blank Status means a rule has yet to judge it.
type ServiceCheckItem struct {
	Name         string   `json:"name"`
	Status       string   `json:"status"`
	Region       string   `json:"region,omitempty"`
	Delay        int64    `json:"delay,omitempty"`
	Chains       []string `json:"chains,omitempty"`
	CheckedAt    int64    `json:"checked-at"`
	CoreEpoch    uint64   `json:"core-epoch"`
	PicksVersion uint64   `json:"picks-version"`
}

type serviceEnv struct {
	ctx       context.Context
	proxyName string
	timeout   time.Duration
}

func (e serviceEnv) get(url string, maxBody int64) *ProbeResult {
	return e.send(probeRequest{method: http.MethodGet, url: url, maxBody: maxBody})
}

func (e serviceEnv) send(req probeRequest) *ProbeResult {
	req.proxyName = e.proxyName
	req.timeout = e.timeout
	headers := map[string]string{"User-Agent": browserUserAgent}
	for name, value := range req.headers {
		headers[name] = value
	}
	req.headers = headers
	return runProbe(e.ctx, req)
}

type serviceChecker struct {
	name  string
	check func(serviceEnv) ServiceCheckItem
}

var serviceCheckers = []serviceChecker{
	{name: "google", check: checkReachable("https://www.google.com/generate_204")},
	{name: "github", check: checkReachable("https://github.com/")},
	{name: "youtube", check: checkYouTubePremium},
	{name: "chatgpt", check: checkChatGpt},
	{name: "claude", check: checkClaude},
	{name: "gemini", check: checkGemini},
	{name: "netflix", check: checkNetflix},
	{name: "disney-plus", check: checkDisneyPlus},
	{name: "prime-video", check: checkPrimeVideo},
	{name: "spotify", check: checkSpotify},
	{name: "tiktok", check: checkTikTok},
	{name: "bilibili", check: checkBilibili},
}

func handleServiceCheck(params *ServiceCheckParams) []ServiceCheckItem {
	wanted := selectedCheckers(params.Names)
	items := make([]ServiceCheckItem, len(wanted))
	if len(wanted) == 0 {
		return items
	}

	timeout := probeTimeout(params.Timeout)
	ctx, cancel := context.WithTimeout(context.Background(), timeout*serviceSweepBudgetFactor)
	defer cancel()

	type slot struct {
		index   int
		checker serviceChecker
	}
	queue := make(chan slot)
	done := make(chan struct{})

	workers := min(serviceCheckConcurrency, len(wanted))
	for worker := 0; worker < workers; worker++ {
		go func() {
			defer func() { done <- struct{}{} }()
			for job := range queue {
				items[job.index] = runServiceCheck(ctx, job.checker, params.ProxyName, timeout)
			}
		}()
	}
	for index, checker := range wanted {
		queue <- slot{index: index, checker: checker}
	}
	close(queue)
	for worker := 0; worker < workers; worker++ {
		<-done
	}
	return items
}

// A misbehaving rule must not take the sweep down with it.
func runServiceCheck(ctx context.Context, checker serviceChecker, proxyName string, timeout time.Duration) (item ServiceCheckItem) {
	epoch, picksVersion := routeStamp()
	item = ServiceCheckItem{Status: serviceFailed}
	defer func() {
		if recovered := recover(); recovered != nil {
			item = ServiceCheckItem{Status: serviceFailed}
		}
		item.Name = checker.name
		item.CheckedAt = time.Now().UnixMilli()
		item.CoreEpoch = epoch
		item.PicksVersion = picksVersion
	}()
	return checker.check(serviceEnv{ctx: ctx, proxyName: proxyName, timeout: timeout})
}

func selectedCheckers(names []string) []serviceChecker {
	if len(names) == 0 {
		return serviceCheckers
	}
	wanted := make([]serviceChecker, 0, len(names))
	for _, name := range names {
		for _, checker := range serviceCheckers {
			if checker.name == name {
				wanted = append(wanted, checker)
				break
			}
		}
	}
	return wanted
}

// checkReachable is the rule for a target with no unlock semantics of its own.
func checkReachable(url string) func(serviceEnv) ServiceCheckItem {
	return func(env serviceEnv) ServiceCheckItem {
		result := env.get(url, 0)
		item := itemFrom(result)
		if item.Status != "" {
			return item
		}
		item.Status = statusFromCode(result.StatusCode)
		return item
	}
}

func itemFrom(result *ProbeResult) ServiceCheckItem {
	if result == nil {
		return ServiceCheckItem{Status: serviceFailed}
	}
	item := ServiceCheckItem{Delay: result.Delay, Chains: result.Chains}
	switch result.Error {
	case "":
	case probeErrorTimeout:
		item.Status = serviceTimeout
		item.Delay = 0
	default:
		item.Status = serviceFailed
		item.Delay = 0
	}
	return item
}

func statusFromCode(code int) string {
	switch {
	case code >= 200 && code < 300:
		return serviceAvailable
	case code == http.StatusUnauthorized,
		code == http.StatusForbidden,
		code == http.StatusTooManyRequests,
		code == http.StatusUnavailableForLegalReasons:
		return serviceRestricted
	default:
		return serviceUnavailable
	}
}

func answered(item ServiceCheckItem, result *ProbeResult) bool {
	return item.Status == "" && result != nil
}

func bodyContains(result *ProbeResult, needles ...string) bool {
	body := strings.ToLower(result.Body)
	for _, needle := range needles {
		if strings.Contains(body, needle) {
			return true
		}
	}
	return false
}

func traceValue(body string, key string) string {
	for _, line := range strings.Split(body, "\n") {
		if rest, found := strings.CutPrefix(line, key+"="); found {
			return strings.TrimSpace(rest)
		}
	}
	return ""
}
