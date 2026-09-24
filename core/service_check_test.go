package main

import (
	"net/http"
	"sync"
	"sync/atomic"
	"testing"
	"time"
)

func withServiceCheckers(t *testing.T, checkers ...serviceChecker) {
	t.Helper()
	previous := serviceCheckers
	serviceCheckers = checkers
	t.Cleanup(func() { serviceCheckers = previous })
}

func stubChecker(name string, item ServiceCheckItem) serviceChecker {
	return serviceChecker{name: name, check: func(serviceEnv) ServiceCheckItem { return item }}
}

func TestHandleServiceCheckRunsEveryCheckerByDefault(t *testing.T) {
	withServiceCheckers(t,
		stubChecker("alpha", ServiceCheckItem{Status: serviceAvailable, Region: "US"}),
		stubChecker("beta", ServiceCheckItem{Status: serviceUnsupportedRegion}),
	)

	items := handleServiceCheck(&ServiceCheckParams{Timeout: 1000})

	if len(items) != 2 {
		t.Fatalf("items = %d, want 2", len(items))
	}
	if items[0].Name != "alpha" || items[0].Status != serviceAvailable || items[0].Region != "US" {
		t.Errorf("items[0] = %+v", items[0])
	}
	if items[1].Name != "beta" || items[1].Status != serviceUnsupportedRegion {
		t.Errorf("items[1] = %+v", items[1])
	}
	for _, item := range items {
		if item.CheckedAt == 0 {
			t.Errorf("%s has no check time", item.Name)
		}
	}
}

func TestHandleServiceCheckStampsTheRegisteredName(t *testing.T) {
	withServiceCheckers(t,
		stubChecker("alpha", ServiceCheckItem{Name: "stale", Status: serviceAvailable}),
	)

	items := handleServiceCheck(&ServiceCheckParams{Timeout: 1000})

	if items[0].Name != "alpha" {
		t.Errorf("name = %q, want the registry's rather than the rule's", items[0].Name)
	}
}

func TestHandleServiceCheckKeepsTheRequestedOrder(t *testing.T) {
	withServiceCheckers(t,
		stubChecker("alpha", ServiceCheckItem{Status: serviceAvailable}),
		stubChecker("beta", ServiceCheckItem{Status: serviceAvailable}),
		stubChecker("gamma", ServiceCheckItem{Status: serviceAvailable}),
	)

	items := handleServiceCheck(&ServiceCheckParams{Names: []string{"gamma", "alpha"}, Timeout: 1000})

	if len(items) != 2 {
		t.Fatalf("items = %d, want 2", len(items))
	}
	if items[0].Name != "gamma" || items[1].Name != "alpha" {
		t.Errorf("names = %q, %q, want gamma, alpha", items[0].Name, items[1].Name)
	}
}

func TestHandleServiceCheckIgnoresAnUnknownName(t *testing.T) {
	withServiceCheckers(t, stubChecker("alpha", ServiceCheckItem{Status: serviceAvailable}))

	items := handleServiceCheck(&ServiceCheckParams{Names: []string{"nope"}, Timeout: 1000})

	if len(items) != 0 {
		t.Fatalf("items = %d, want none", len(items))
	}
}

func TestHandleServiceCheckSurvivesAPanickingRule(t *testing.T) {
	withServiceCheckers(t,
		serviceChecker{name: "boom", check: func(serviceEnv) ServiceCheckItem { panic("rule blew up") }},
		stubChecker("alpha", ServiceCheckItem{Status: serviceAvailable}),
	)

	items := handleServiceCheck(&ServiceCheckParams{Timeout: 1000})

	if len(items) != 2 {
		t.Fatalf("items = %d, want 2", len(items))
	}
	if items[0].Status != serviceFailed {
		t.Errorf("panicking rule reported %q, want %q", items[0].Status, serviceFailed)
	}
	if items[1].Status != serviceAvailable {
		t.Errorf("the sibling rule reported %q, want it unaffected", items[1].Status)
	}
}

func TestHandleServiceCheckBoundsConcurrency(t *testing.T) {
	var mu sync.Mutex
	var running, peak int
	var total atomic.Int32
	blocking := func(name string) serviceChecker {
		return serviceChecker{name: name, check: func(serviceEnv) ServiceCheckItem {
			mu.Lock()
			running++
			if running > peak {
				peak = running
			}
			mu.Unlock()
			time.Sleep(20 * time.Millisecond)
			mu.Lock()
			running--
			mu.Unlock()
			total.Add(1)
			return ServiceCheckItem{Status: serviceAvailable}
		}}
	}
	checkers := make([]serviceChecker, 0, 12)
	for index := 0; index < 12; index++ {
		checkers = append(checkers, blocking("x"))
	}
	withServiceCheckers(t, checkers...)

	handleServiceCheck(&ServiceCheckParams{Timeout: 5000})

	if got := total.Load(); got != 12 {
		t.Errorf("ran %d checks, want 12", got)
	}
	mu.Lock()
	defer mu.Unlock()
	if peak > serviceCheckConcurrency {
		t.Errorf("peak concurrency = %d, want at most %d", peak, serviceCheckConcurrency)
	}
}

func TestHandleServiceCheckRetriesATimeoutOnce(t *testing.T) {
	var calls atomic.Int32
	withServiceCheckers(t, serviceChecker{name: "flaky", check: func(serviceEnv) ServiceCheckItem {
		if calls.Add(1) == 1 {
			return ServiceCheckItem{Status: serviceTimeout}
		}
		return ServiceCheckItem{Status: serviceAvailable}
	}})

	items := handleServiceCheck(&ServiceCheckParams{Timeout: 1000})

	if items[0].Status != serviceAvailable {
		t.Errorf("status = %q, want the retry's answer", items[0].Status)
	}
	if got := calls.Load(); got != 2 {
		t.Errorf("ran %d times, want 2", got)
	}
}

func TestHandleServiceCheckReportsARepeatedTimeout(t *testing.T) {
	var calls atomic.Int32
	withServiceCheckers(t, serviceChecker{name: "down", check: func(serviceEnv) ServiceCheckItem {
		calls.Add(1)
		return ServiceCheckItem{Status: serviceTimeout}
	}})

	items := handleServiceCheck(&ServiceCheckParams{Timeout: 1000})

	if items[0].Status != serviceTimeout {
		t.Errorf("status = %q, want %q", items[0].Status, serviceTimeout)
	}
	if got := calls.Load(); got != 2 {
		t.Errorf("ran %d times, want a single retry", got)
	}
}

func TestHandleServiceCheckCancelsTheOlderCheckOfTheSameService(t *testing.T) {
	started := make(chan struct{}, 2)
	var calls atomic.Int32
	withServiceCheckers(t,
		serviceChecker{name: "alpha", check: func(env serviceEnv) ServiceCheckItem {
			if calls.Add(1) > 1 {
				return ServiceCheckItem{Status: serviceAvailable}
			}
			started <- struct{}{}
			<-env.ctx.Done()
			return ServiceCheckItem{Status: serviceFailed}
		}},
		serviceChecker{name: "beta", check: func(env serviceEnv) ServiceCheckItem {
			started <- struct{}{}
			select {
			case <-env.ctx.Done():
				return ServiceCheckItem{Status: serviceFailed}
			case <-time.After(200 * time.Millisecond):
				return ServiceCheckItem{Status: serviceAvailable}
			}
		}},
	)

	older := make(chan []ServiceCheckItem)
	go func() { older <- handleServiceCheck(&ServiceCheckParams{Timeout: 5000}) }()
	<-started
	<-started

	newer := handleServiceCheck(&ServiceCheckParams{Names: []string{"alpha"}, Timeout: 5000})

	if newer[0].Status != serviceAvailable {
		t.Errorf("newer alpha = %q, want %q", newer[0].Status, serviceAvailable)
	}
	select {
	case items := <-older:
		if items[0].Status != serviceFailed {
			t.Errorf("older alpha = %q, want it cancelled", items[0].Status)
		}
		if items[1].Status != serviceAvailable {
			t.Errorf("older beta = %q, want it left running", items[1].Status)
		}
	case <-time.After(2 * time.Second):
		t.Fatal("the older sweep kept running after its service was asked again")
	}
}

func TestStatusFromCode(t *testing.T) {
	cases := map[int]string{
		http.StatusOK:                         serviceAvailable,
		http.StatusNoContent:                  serviceAvailable,
		http.StatusUnauthorized:               serviceRestricted,
		http.StatusForbidden:                  serviceRestricted,
		http.StatusTooManyRequests:            serviceRestricted,
		http.StatusUnavailableForLegalReasons: serviceRestricted,
		http.StatusNotFound:                   serviceUnavailable,
		http.StatusInternalServerError:        serviceUnavailable,
	}
	for code, want := range cases {
		if got := statusFromCode(code); got != want {
			t.Errorf("statusFromCode(%d) = %q, want %q", code, got, want)
		}
	}
}

func TestItemFromMapsTransportErrors(t *testing.T) {
	timedOut := itemFrom(&ProbeResult{Error: probeErrorTimeout, Delay: 900})
	if timedOut.Status != serviceTimeout {
		t.Errorf("status = %q, want %q", timedOut.Status, serviceTimeout)
	}
	if timedOut.Delay != 0 {
		t.Errorf("delay = %d, want it dropped for a timeout", timedOut.Delay)
	}
	if missing := itemFrom(nil); missing.Status != serviceFailed {
		t.Errorf("status = %q, want %q when the probe got no slot", missing.Status, serviceFailed)
	}
	answered := itemFrom(&ProbeResult{StatusCode: http.StatusOK, Delay: 120})
	if answered.Status != "" {
		t.Errorf("status = %q, want it left for the rule to judge", answered.Status)
	}
	if answered.Delay != 120 {
		t.Errorf("delay = %d, want 120", answered.Delay)
	}
}

func TestTraceValue(t *testing.T) {
	body := "fl=abc\nip=203.0.113.7\nloc=JP\nwarp=off\n"
	if got := traceValue(body, "loc"); got != "JP" {
		t.Errorf("loc = %q, want JP", got)
	}
	if got := traceValue(body, "colo"); got != "" {
		t.Errorf("colo = %q, want empty", got)
	}
}
