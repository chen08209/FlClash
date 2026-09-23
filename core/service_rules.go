package main

import (
	"encoding/json"
	"net/url"
	"regexp"
	"slices"
	"strings"

	"github.com/metacubex/http"
)

// disneyAuthHeader is the public browser client token Disney+ hands to any web
// visitor; the device and token calls below are rejected without it.
const disneyAuthHeader = "Bearer ZGlzbmV5JmJyb3dzZXImMS4wLjA.Cu56AgSfBTDag5NiRA81oLHkDZfu5L3CKadnefEAY84"

var (
	youTubeRegionPatterns = []*regexp.Regexp{
		regexp.MustCompile(`(?i)id=["']country-code["'][^>]*>\s*([A-Za-z]{2,3})\s*<`),
		regexp.MustCompile(`"GL"\s*:\s*"([A-Za-z]{2})"`),
		regexp.MustCompile(`"countryCode"\s*:\s*"([A-Za-z]{2})"`),
		regexp.MustCompile(`"country_code"\s*:\s*"([A-Za-z]{2})"`),
	}
	tikTokRegionPattern    = regexp.MustCompile(`"region"\s*:\s*"([a-zA-Z-]+)"`)
	primeRegionPattern     = regexp.MustCompile(`"currentTerritory":"([^"]+)"`)
	disneyAssertionPattern = regexp.MustCompile(`"assertion"\s*:\s*"([^"]+)"`)
	disneyRefreshPattern   = regexp.MustCompile(`"refresh_token"\s*:\s*"([^"]+)"`)
	disneyCountryPattern   = regexp.MustCompile(`"countryCode"\s*:\s*"([^"]+)"`)
	disneySupportedPattern = regexp.MustCompile(`"inSupportedLocation"\s*:\s*(false|true)`)
	spotifyCountryPattern  = regexp.MustCompile(`"countryCode"\s*:\s*"([^"]+)"`)
	geminiRegionMarker     = `,2,1,200,"`
	claudeBlockedRegions   = []string{"AF", "BY", "CN", "CU", "HK", "IR", "KP", "MO", "RU", "SY"}
	geminiBlockedRegions   = []string{"CHN", "RUS", "BLR", "CUB", "IRN", "PRK", "SYR", "HKG", "MAC"}
)

func firstSubmatch(pattern *regexp.Regexp, body string) string {
	match := pattern.FindStringSubmatch(body)
	if len(match) < 2 {
		return ""
	}
	return match[1]
}

func checkClaude(env serviceEnv) ServiceCheckItem {
	result := env.get("https://claude.ai/cdn-cgi/trace", serviceSmallMaxBody)
	item := itemFrom(result)
	if !answered(item, result) {
		return item
	}
	region := normalizeRegion(traceValue(result.Body, "loc"))
	if region == "" {
		item.Status = serviceFailed
		return item
	}
	item.Region = region
	item.Status = serviceAvailable
	if slices.Contains(claudeBlockedRegions, region) {
		item.Status = serviceUnsupportedRegion
	}
	return item
}

func checkGemini(env serviceEnv) ServiceCheckItem {
	result := env.get("https://gemini.google.com", serviceHtmlMaxBody)
	item := itemFrom(result)
	if !answered(item, result) {
		return item
	}
	index := strings.Index(result.Body, geminiRegionMarker)
	if index < 0 || index+len(geminiRegionMarker)+3 > len(result.Body) {
		item.Status = serviceFailed
		return item
	}
	start := index + len(geminiRegionMarker)
	code := result.Body[start : start+3]
	if !isAsciiUpper(code) {
		item.Status = serviceFailed
		return item
	}
	item.Region = normalizeRegion(code)
	item.Status = serviceAvailable
	if slices.Contains(geminiBlockedRegions, code) {
		item.Status = serviceUnsupportedRegion
	}
	return item
}

// checkChatGpt folds Verge's separate iOS and Web results into one entry: the
// card shows a single row per service, and a split would put two identical
// OpenAI icons next to each other.
func checkChatGpt(env serviceEnv) ServiceCheckItem {
	ios := env.get("https://ios.chat.openai.com/", serviceSmallMaxBody)
	item := itemFrom(ios)
	if answered(item, ios) {
		item.Status = chatGptIosStatus(ios)
	}

	trace := env.get("https://chat.openai.com/cdn-cgi/trace", serviceSmallMaxBody)
	if traceItem := itemFrom(trace); answered(traceItem, trace) {
		item.Region = normalizeRegion(traceValue(trace.Body, "loc"))
	}

	web := env.get("https://api.openai.com/compliance/cookie_requirements", serviceSmallMaxBody)
	if webItem := itemFrom(web); answered(webItem, web) &&
		bodyContains(web, "unsupported_country") {
		item.Status = serviceUnsupportedRegion
	}
	return item
}

func chatGptIosStatus(result *ProbeResult) string {
	switch {
	case bodyContains(result, "you may be connected to a disallowed isp"):
		return serviceDisallowedIsp
	case bodyContains(result, "sorry, you have been blocked"):
		return serviceBlocked
	case bodyContains(result, "request is not allowed. please try again later."):
		// Being turned away as an API client is what a reachable region looks
		// like here; anything else means the request never got that far.
		return serviceAvailable
	default:
		return serviceFailed
	}
}

func checkYouTubePremium(env serviceEnv) ServiceCheckItem {
	result := env.get("https://www.youtube.com/premium?hl=en", serviceHtmlMaxBody)
	item := itemFrom(result)
	if !answered(item, result) {
		return item
	}
	for _, pattern := range youTubeRegionPatterns {
		if code := firstSubmatch(pattern, result.Body); code != "" {
			item.Region = normalizeRegion(code)
			break
		}
	}
	switch {
	case bodyContains(result,
		"youtube premium is not available in your country",
		"premium is not available in your country",
		"premium is not available in your region"):
		item.Status = serviceUnsupportedRegion
	case result.StatusCode >= 200 && result.StatusCode < 300 &&
		bodyContains(result, "youtube premium", "ad-free", `"browseid":"spunlimited"`):
		item.Status = serviceAvailable
	default:
		item.Status = statusFromCode(result.StatusCode)
	}
	return item
}

func checkSpotify(env serviceEnv) ServiceCheckItem {
	result := env.get(
		"https://www.spotify.com/api/content/v1/country-selector?platform=web&format=json",
		serviceSmallMaxBody,
	)
	item := itemFrom(result)
	if !answered(item, result) {
		return item
	}
	item.Region = normalizeRegion(spotifyRegion(result))
	switch {
	case result.StatusCode == http.StatusForbidden ||
		result.StatusCode == http.StatusUnavailableForLegalReasons:
		item.Status = serviceUnsupportedRegion
	case result.StatusCode < 200 || result.StatusCode >= 300:
		item.Status = statusFromCode(result.StatusCode)
	case bodyContains(result, "not available in your country"):
		item.Status = serviceUnsupportedRegion
	default:
		item.Status = serviceAvailable
	}
	return item
}

// spotifyRegion prefers the country Spotify redirected the request into, and
// falls back to the one named in the payload.
func spotifyRegion(result *ProbeResult) string {
	if final, err := url.Parse(result.Url); err == nil {
		segments := strings.Split(strings.Trim(final.Path, "/"), "/")
		if first := segments[0]; first != "" && first != "api" {
			return strings.Split(first, "-")[0]
		}
	}
	return firstSubmatch(spotifyCountryPattern, result.Body)
}

func checkTikTok(env serviceEnv) ServiceCheckItem {
	result := env.get("https://www.tiktok.com/cdn-cgi/trace", serviceSmallMaxBody)
	item := itemFrom(result)
	if answered(item, result) {
		item.Status = tikTokStatus(result)
		item.Region = normalizeRegion(tikTokRegion(result.Body))
	}
	if item.Region != "" && item.Status != serviceFailed {
		return item
	}

	fallback := env.get("https://www.tiktok.com/", serviceHtmlMaxBody)
	fallbackItem := itemFrom(fallback)
	if !answered(fallbackItem, fallback) {
		if item.Status == "" {
			item.Status = fallbackItem.Status
		}
		return item
	}
	if item.Status != serviceUnsupportedRegion {
		item.Status = tikTokStatus(fallback)
	}
	if item.Region == "" {
		item.Region = normalizeRegion(tikTokRegion(fallback.Body))
	}
	if item.Delay == 0 {
		item.Delay = fallbackItem.Delay
	}
	if len(item.Chains) == 0 {
		item.Chains = fallbackItem.Chains
	}
	return item
}

func tikTokStatus(result *ProbeResult) string {
	switch {
	case result.StatusCode == http.StatusForbidden ||
		result.StatusCode == http.StatusUnavailableForLegalReasons:
		return serviceUnsupportedRegion
	case result.StatusCode < 200 || result.StatusCode >= 300:
		return serviceFailed
	case bodyContains(result, "access denied", "not available in your region", "tiktok is not available"):
		return serviceUnsupportedRegion
	default:
		return serviceAvailable
	}
}

func tikTokRegion(body string) string {
	raw := firstSubmatch(tikTokRegionPattern, body)
	if raw == "" {
		return ""
	}
	return strings.Split(raw, "-")[0]
}

func checkBilibili(env serviceEnv) ServiceCheckItem {
	const url = "https://api.bilibili.com/pgc/player/web/playurl?avid=18281381&cid=29892777&qn=0&type=&otype=json&ep_id=183799&fourk=1&fnver=0&fnval=16&module=bangumi"
	result := env.get(url, serviceSmallMaxBody)
	item := itemFrom(result)
	if !answered(item, result) {
		return item
	}
	var payload struct {
		Code int `json:"code"`
	}
	if err := json.Unmarshal([]byte(result.Body), &payload); err != nil {
		item.Status = serviceFailed
		return item
	}
	switch payload.Code {
	case 0:
		item.Status = serviceAvailable
	case -10403:
		item.Status = serviceUnsupportedRegion
	default:
		item.Status = serviceFailed
	}
	return item
}

func checkPrimeVideo(env serviceEnv) ServiceCheckItem {
	result := env.get("https://www.primevideo.com", serviceHtmlMaxBody)
	item := itemFrom(result)
	if !answered(item, result) {
		return item
	}
	if strings.Contains(result.Body, "isServiceRestricted") {
		item.Status = serviceUnsupportedRegion
		return item
	}
	region := firstSubmatch(primeRegionPattern, result.Body)
	if region == "" {
		item.Status = serviceFailed
		return item
	}
	item.Region = normalizeRegion(region)
	item.Status = serviceAvailable
	return item
}

func checkNetflix(env serviceEnv) ServiceCheckItem {
	if item := netflixFromCdn(env); item.Status == serviceAvailable || item.Status == serviceBlocked {
		return item
	}

	first := env.get("https://www.netflix.com/title/81280792", 0)
	firstItem := itemFrom(first)
	if !answered(firstItem, first) {
		return firstItem
	}
	second := env.get("https://www.netflix.com/title/70143836", 0)
	secondItem := itemFrom(second)
	if !answered(secondItem, second) {
		return secondItem
	}

	item := firstItem
	switch {
	case first.StatusCode == http.StatusNotFound && second.StatusCode == http.StatusNotFound:
		item.Status = serviceOriginalsOnly
	case first.StatusCode == http.StatusForbidden || second.StatusCode == http.StatusForbidden:
		item.Status = serviceUnsupportedRegion
	case netflixServed(first.StatusCode) || netflixServed(second.StatusCode):
		item.Status = serviceAvailable
		item.Region = netflixRegion(env)
	default:
		item.Status = statusFromCode(first.StatusCode)
	}
	return item
}

func netflixServed(code int) bool {
	return code == http.StatusOK || code == http.StatusMovedPermanently
}

// netflixRegion reads the country out of the redirect Netflix would send a
// visitor to, so the redirect must not be followed.
func netflixRegion(env serviceEnv) string {
	result := env.send(probeRequest{
		method:     http.MethodGet,
		url:        "https://www.netflix.com/title/80018499",
		noRedirect: true,
	})
	if result == nil || result.Error != "" || result.header == nil {
		return ""
	}
	segments := strings.Split(result.header.Get("Location"), "/")
	if len(segments) < 4 {
		return ""
	}
	return normalizeRegion(strings.Split(segments[3], "-")[0])
}

func netflixFromCdn(env serviceEnv) ServiceCheckItem {
	const url = "https://api.fast.com/netflix/speedtest/v2?https=true&token=YXNkZmFzZGxmbnNkYWZoYXNkZmhrYWxm&urlCount=5"
	result := env.get(url, serviceSmallMaxBody)
	item := itemFrom(result)
	if !answered(item, result) {
		return item
	}
	if result.StatusCode == http.StatusForbidden {
		item.Status = serviceBlocked
		return item
	}
	var payload struct {
		Targets []struct {
			Location struct {
				Country string `json:"country"`
			} `json:"location"`
		} `json:"targets"`
	}
	if err := json.Unmarshal([]byte(result.Body), &payload); err != nil || len(payload.Targets) == 0 {
		item.Status = serviceFailed
		return item
	}
	item.Region = normalizeRegion(payload.Targets[0].Location.Country)
	item.Status = serviceAvailable
	return item
}

// checkDisneyPlus walks the browser hand-shake: register a device, exchange the
// assertion for a refresh token, then ask the session which region it landed
// in. Any step can answer on its own that the address is not welcome.
func checkDisneyPlus(env serviceEnv) ServiceCheckItem {
	device := env.send(probeRequest{
		method: http.MethodPost,
		url:    "https://disney.api.edge.bamgrid.com/devices",
		headers: map[string]string{
			"authorization": disneyAuthHeader,
			"content-type":  "application/json; charset=UTF-8",
		},
		body:    []byte(`{"deviceFamily":"browser","applicationRuntime":"chrome","deviceProfile":"windows","attributes":{}}`),
		maxBody: serviceSmallMaxBody,
	})
	item := itemFrom(device)
	if !answered(item, device) {
		return item
	}
	if device.StatusCode == http.StatusForbidden {
		item.Status = serviceBlocked
		return item
	}
	assertion := firstSubmatch(disneyAssertionPattern, device.Body)
	if assertion == "" {
		item.Status = serviceFailed
		return item
	}

	form := strings.NewReplacer("{assertion}", assertion).Replace(
		"grant_type=urn:ietf:params:oauth:grant-type:token-exchange" +
			"&latitude=0&longitude=0&platform=browser" +
			"&subject_token={assertion}" +
			"&subject_token_type=urn:bamtech:params:oauth:token-type:device",
	)
	token := env.send(probeRequest{
		method: http.MethodPost,
		url:    "https://disney.api.edge.bamgrid.com/token",
		headers: map[string]string{
			"authorization": disneyAuthHeader,
			"content-type":  "application/x-www-form-urlencoded",
		},
		body:    []byte(form),
		maxBody: serviceSmallMaxBody,
	})
	if tokenItem := itemFrom(token); !answered(tokenItem, token) {
		return tokenItem
	}
	if strings.Contains(token.Body, "forbidden-location") || strings.Contains(token.Body, "403 ERROR") {
		item.Status = serviceBlocked
		return item
	}
	refresh := firstSubmatch(disneyRefreshPattern, token.Body)
	if refresh == "" {
		item.Status = serviceFailed
		return item
	}

	query := `{"query":"mutation refreshToken($input: RefreshTokenInput!) { refreshToken(refreshToken: $input) { activeSession { sessionId } } }","variables":{"input":{"refreshToken":"` +
		refresh + `"}}}`
	session := env.send(probeRequest{
		method: http.MethodPost,
		url:    "https://disney.api.edge.bamgrid.com/graph/v1/device/graphql",
		headers: map[string]string{
			"authorization": disneyAuthHeader,
			"content-type":  "application/json",
		},
		body:    []byte(query),
		maxBody: serviceSmallMaxBody,
	})
	sessionItem := itemFrom(session)
	if !answered(sessionItem, session) || session.Body == "" || session.StatusCode >= 400 {
		item.Status = serviceFailed
		return item
	}
	region := normalizeRegion(firstSubmatch(disneyCountryPattern, session.Body))
	if region == "" {
		item.Status = serviceUnavailable
		return item
	}
	item.Region = region
	switch firstSubmatch(disneySupportedPattern, session.Body) {
	case "true":
		item.Status = serviceAvailable
	case "false":
		item.Status = serviceComingSoon
	default:
		item.Status = serviceFailed
	}
	return item
}
