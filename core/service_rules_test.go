package main

import (
	"net/http"
	"testing"
)

func TestNormalizeRegion(t *testing.T) {
	cases := map[string]string{
		"US":    "US",
		"jp":    "JP",
		"CHN":   "CN",
		"usa":   "US",
		"HKG":   "HK",
		"ZZZ":   "",
		"C":     "",
		"CNAAA": "",
		"":      "",
		"1A":    "",
	}
	for input, want := range cases {
		if got := normalizeRegion(input); got != want {
			t.Errorf("normalizeRegion(%q) = %q, want %q", input, got, want)
		}
	}
}

func TestNormalizeRegionCoversTheBlockLists(t *testing.T) {
	for _, code := range geminiBlockedRegions {
		if normalizeRegion(code) == "" {
			t.Errorf("gemini block list entry %q does not fold to an alpha-2 code", code)
		}
	}
	for _, code := range claudeBlockedRegions {
		if normalizeRegion(code) != code {
			t.Errorf("claude block list entry %q is not already alpha-2", code)
		}
	}
}

// The iOS endpoint turns API clients away even where ChatGPT works, so that
// refusal is the success signal and anything else is not.
func TestChatGptIosStatus(t *testing.T) {
	cases := map[string]string{
		"Request is not allowed. Please try again later.": serviceAvailable,
		"You may be connected to a disallowed ISP":        serviceDisallowedIsp,
		"Sorry, you have been blocked":                    serviceBlocked,
		"<html>something else entirely</html>":            serviceFailed,
		"":                                                serviceFailed,
	}
	for body, want := range cases {
		if got := chatGptIosStatus(&ProbeResult{Body: body}); got != want {
			t.Errorf("chatGptIosStatus(%q) = %q, want %q", body, got, want)
		}
	}
}

func TestTikTokStatus(t *testing.T) {
	cases := []struct {
		code int
		body string
		want string
	}{
		{http.StatusOK, `{"region":"JP"}`, serviceAvailable},
		{http.StatusForbidden, "", serviceUnsupportedRegion},
		{http.StatusUnavailableForLegalReasons, "", serviceUnsupportedRegion},
		{http.StatusOK, "Access Denied", serviceUnsupportedRegion},
		{http.StatusOK, "TikTok is not available in your region", serviceUnsupportedRegion},
		{http.StatusInternalServerError, "", serviceFailed},
	}
	for _, testCase := range cases {
		got := tikTokStatus(&ProbeResult{StatusCode: testCase.code, Body: testCase.body})
		if got != testCase.want {
			t.Errorf("tikTokStatus(%d, %q) = %q, want %q", testCase.code, testCase.body, got, testCase.want)
		}
	}
}

func TestTikTokRegionTakesTheCountryHalf(t *testing.T) {
	if got := tikTokRegion(`{"region":"zh-Hant-TW"}`); got != "zh" {
		t.Errorf("region = %q, want the leading segment", got)
	}
	if got := tikTokRegion(`{"region":"JP"}`); got != "JP" {
		t.Errorf("region = %q, want JP", got)
	}
	if got := tikTokRegion("{}"); got != "" {
		t.Errorf("region = %q, want empty", got)
	}
}

func TestSpotifyRegionPrefersTheRedirectedPath(t *testing.T) {
	redirected := &ProbeResult{Url: "https://www.spotify.com/de-de/", Body: `{"countryCode":"US"}`}
	if got := spotifyRegion(redirected); got != "de" {
		t.Errorf("region = %q, want the path's country", got)
	}
	unredirected := &ProbeResult{
		Url:  "https://www.spotify.com/api/content/v1/country-selector",
		Body: `{"countryCode":"SE"}`,
	}
	if got := spotifyRegion(unredirected); got != "SE" {
		t.Errorf("region = %q, want the payload's country", got)
	}
}

func TestYouTubeRegionPatterns(t *testing.T) {
	bodies := map[string]string{
		`<span id="country-code"> GB </span>`: "GB",
		`{"GL":"JP","other":1}`:               "JP",
		`{"countryCode":"KR"}`:                "KR",
		`{"country_code":"BR"}`:               "BR",
	}
	for body, want := range bodies {
		var got string
		for _, pattern := range youTubeRegionPatterns {
			if code := firstSubmatch(pattern, body); code != "" {
				got = normalizeRegion(code)
				break
			}
		}
		if got != want {
			t.Errorf("region from %q = %q, want %q", body, got, want)
		}
	}
}

func TestDisneyAndPrimePatterns(t *testing.T) {
	if got := firstSubmatch(disneyAssertionPattern, `{"assertion":"abc.def"}`); got != "abc.def" {
		t.Errorf("assertion = %q", got)
	}
	if got := firstSubmatch(disneyRefreshPattern, `{"refresh_token":"tok123"}`); got != "tok123" {
		t.Errorf("refresh token = %q", got)
	}
	if got := firstSubmatch(disneySupportedPattern, `{"inSupportedLocation":false}`); got != "false" {
		t.Errorf("supported = %q", got)
	}
	if got := firstSubmatch(primeRegionPattern, `{"currentTerritory":"NL"}`); got != "NL" {
		t.Errorf("territory = %q", got)
	}
}
