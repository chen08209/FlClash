package core

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"net"
	"net/url"
	"strings"

	"github.com/metacubex/mihomo/common/convert"
)

// Each link is written for convert.ConvertsV2Ray to read back, so the two
// stay in step; a type with no link form, or a mapping whose server, plugin or
// transport the converter cannot read back from a link, encodes to "".
func handleEncodeShareLinks(mappings []map[string]any) []string {
	links := make([]string, len(mappings))
	for i, mapping := range mappings {
		links[i] = encodeShareLink(proxyFields(mapping))
	}
	return links
}

func handleDecodeShareLinks(lines []string) [][]map[string]any {
	results := make([][]map[string]any, len(lines))
	for i, line := range lines {
		proxies, err := convert.ConvertsV2Ray([]byte(line))
		if err != nil {
			proxies = []map[string]any{}
		}
		results[i] = proxies
	}
	return results
}

type proxyFields map[string]any

func (f proxyFields) str(key string) string {
	switch value := f[key].(type) {
	case nil:
		return ""
	case string:
		return value
	default:
		return fmt.Sprint(value)
	}
}

func (f proxyFields) flag(key string) bool {
	switch value := f[key].(type) {
	case bool:
		return value
	case string:
		return value == "true"
	}
	return false
}

func (f proxyFields) sub(key string) proxyFields {
	value, _ := f[key].(map[string]any)
	return value
}

func (f proxyFields) list(key string) []string {
	switch value := f[key].(type) {
	case []string:
		return value
	case []any:
		items := make([]string, 0, len(value))
		for _, item := range value {
			items = append(items, fmt.Sprint(item))
		}
		return items
	case string:
		if value != "" {
			return []string{value}
		}
	}
	return nil
}

func (f proxyFields) first(key string) string {
	if items := f.list(key); len(items) > 0 {
		return items[0]
	}
	return ""
}

func setIf(query url.Values, key, value string) {
	if value != "" {
		query.Set(key, value)
	}
}

func shareURL(scheme string, user *url.Userinfo, host string, query url.Values, name string) string {
	link := url.URL{Scheme: scheme, User: user, Host: host, RawQuery: query.Encode(), Fragment: name}
	return link.String()
}

func encodeShareLink(f proxyFields) string {
	if f.str("server") == "" {
		return ""
	}
	switch f.str("type") {
	case "ss":
		return encodeShadowsocks(f)
	case "ssr":
		return encodeShadowsocksR(f)
	case "vmess":
		return encodeVmess(f)
	case "vless":
		return encodeVless(f)
	case "trojan":
		return encodeTrojan(f)
	case "hysteria":
		return encodeHysteria(f)
	case "hysteria2":
		return encodeHysteria2(f)
	case "tuic":
		return encodeTuic(f)
	case "socks5":
		return encodeSocks(f, "socks5")
	case "http":
		if f.flag("tls") {
			return encodeSocks(f, "https")
		}
		return encodeSocks(f, "http")
	case "anytls":
		return encodeAnyTLS(f)
	case "mieru":
		return encodeMieru(f)
	}
	return ""
}

func hostPort(f proxyFields) string {
	return net.JoinHostPort(f.str("server"), f.str("port"))
}

func encodeShadowsocks(f proxyFields) string {
	// SIP002 asks for base64 outside the 2022 ciphers; the converter reads
	// either, and the plain form is the one a person can edit.
	user := url.UserPassword(f.str("cipher"), f.str("password"))
	query := url.Values{}
	if f.flag("udp-over-tcp") {
		query.Set("uot", "1")
	}
	opts := f.sub("plugin-opts")
	switch f.str("plugin") {
	case "":
	case "obfs":
		query.Set("plugin", "obfs-local;obfs="+opts.str("mode")+";obfs-host="+opts.str("host"))
	case "v2ray-plugin":
		plugin := "v2ray-plugin;mode=" + opts.str("mode") + ";host=" + opts.str("host") + ";path=" + opts.str("path")
		if opts.flag("tls") {
			plugin += ";tls"
		}
		query.Set("plugin", plugin)
	default:
		return ""
	}
	return shareURL("ss", user, hostPort(f), query, f.str("name"))
}

// The decoded body is split on ":", so an IPv6 server has no SSR link.
func encodeShadowsocksR(f proxyFields) string {
	if strings.Contains(f.str("server"), ":") {
		return ""
	}
	encode := func(value string) string {
		return base64.RawURLEncoding.EncodeToString([]byte(value))
	}
	body := strings.Join([]string{
		f.str("server"),
		f.str("port"),
		f.str("protocol"),
		f.str("cipher"),
		f.str("obfs"),
		encode(f.str("password")),
	}, ":") + "/?obfsparam=" + encode(f.str("obfs-param")) +
		"&protoparam=" + encode(f.str("protocol-param")) +
		"&remarks=" + encode(f.str("name"))
	return "ssr://" + encode(body)
}

func wsEarlyDataPath(path string, opts proxyFields) string {
	earlyData := opts.str("max-early-data")
	if earlyData == "" || earlyData == "0" {
		return path
	}
	link, err := url.Parse(path)
	if err != nil {
		return path
	}
	query := link.Query()
	query.Set("ed", earlyData)
	link.RawQuery = query.Encode()
	return link.String()
}

// The plain Xray form fixes alterId at 0, so only a legacy alterId falls back
// to the base64 JSON of v2rayN.
func encodeVmess(f proxyFields) string {
	if alterID := f.str("alterId"); alterID == "" || alterID == "0" {
		query := vShareQuery(f)
		if cipher := f.str("cipher"); cipher != "" && cipher != "auto" {
			query.Set("encryption", cipher)
		}
		return shareURL("vmess", url.User(f.str("uuid")), hostPort(f), query, f.str("name"))
	}
	values := map[string]any{
		"v":    "2",
		"ps":   f.str("name"),
		"add":  f.str("server"),
		"port": f.str("port"),
		"id":   f.str("uuid"),
		"aid":  f.str("alterId"),
		"scy":  f.str("cipher"),
		"net":  "tcp",
		"type": "none",
		"host": "",
		"path": "",
		"tls":  "",
	}
	if values["aid"] == "" {
		values["aid"] = "0"
	}
	switch network := f.str("network"); network {
	case "ws", "httpupgrade":
		opts := f.sub("ws-opts")
		values["net"] = network
		values["host"] = opts.sub("headers").str("Host")
		values["path"] = opts.str("path")
		if network == "ws" {
			values["path"] = wsEarlyDataPath(opts.str("path"), opts)
		}
	case "http":
		opts := f.sub("http-opts")
		values["type"] = "http"
		values["host"] = opts.sub("headers").first("Host")
		values["path"] = opts.first("path")
	case "h2":
		opts := f.sub("h2-opts")
		values["net"] = "h2"
		values["host"] = opts.first("host")
		values["path"] = opts.str("path")
	case "grpc":
		values["net"] = "grpc"
		values["path"] = f.sub("grpc-opts").str("grpc-service-name")
	}
	if f.flag("tls") {
		values["tls"] = "tls"
		values["sni"] = f.str("servername")
		values["alpn"] = strings.Join(f.list("alpn"), ",")
		values["fp"] = f.str("client-fingerprint")
	}
	data, _ := json.Marshal(values)
	return "vmess://" + base64.StdEncoding.EncodeToString(data)
}

func encodeVless(f proxyFields) string {
	query := vShareQuery(f)
	setIf(query, "flow", f.str("flow"))
	setIf(query, "encryption", f.str("encryption"))
	return shareURL("vless", url.User(f.str("uuid")), hostPort(f), query, f.str("name"))
}

// The Xray share link standard that handleVShareLink in mihomo reads.
func vShareQuery(f proxyFields) url.Values {
	query := url.Values{}
	if f.flag("tls") {
		reality := f.sub("reality-opts")
		if publicKey := reality.str("public-key"); publicKey != "" {
			query.Set("security", "reality")
			query.Set("pbk", publicKey)
			setIf(query, "sid", reality.str("short-id"))
			setIf(query, "support-x25519mlkem768", reality.str("support-x25519mlkem768"))
		} else {
			query.Set("security", "tls")
		}
		setIf(query, "fp", f.str("client-fingerprint"))
		setIf(query, "alpn", strings.Join(f.list("alpn"), ","))
		setIf(query, "pcs", f.str("fingerprint"))
	}
	setIf(query, "sni", f.str("servername"))
	switch {
	case f.flag("packet-addr"):
		query.Set("packetEncoding", "packet")
	case !f.flag("xudp"):
		query.Set("packetEncoding", "none")
	}
	switch network := f.str("network"); network {
	case "", "tcp":
	case "http":
		opts := f.sub("http-opts")
		query.Set("type", "tcp")
		query.Set("headerType", "http")
		setIf(query, "path", opts.first("path"))
		setIf(query, "host", opts.sub("headers").first("Host"))
		setIf(query, "method", opts.str("method"))
	case "h2":
		opts := f.sub("h2-opts")
		query.Set("type", "http")
		setIf(query, "path", opts.str("path"))
		setIf(query, "host", opts.first("host"))
	case "ws", "httpupgrade":
		opts := f.sub("ws-opts")
		query.Set("type", network)
		setIf(query, "path", opts.str("path"))
		setIf(query, "host", opts.sub("headers").str("Host"))
		if network == "ws" {
			if earlyData := opts.str("max-early-data"); earlyData != "" && earlyData != "0" {
				query.Set("ed", earlyData)
			}
			if header := opts.str("early-data-header-name"); header != "" && header != "Sec-WebSocket-Protocol" {
				query.Set("eh", header)
			}
		} else if opts.flag("v2ray-http-upgrade-fast-open") {
			query.Set("ed", "0")
		}
	case "grpc":
		query.Set("type", "grpc")
		setIf(query, "serviceName", f.sub("grpc-opts").str("grpc-service-name"))
	case "xhttp":
		opts := f.sub("xhttp-opts")
		query.Set("type", "xhttp")
		setIf(query, "path", opts.str("path"))
		setIf(query, "host", opts.str("host"))
		setIf(query, "mode", opts.str("mode"))
	default:
		query.Set("type", network)
	}
	return query
}

func encodeTrojan(f proxyFields) string {
	query := url.Values{}
	if f.flag("skip-cert-verify") {
		query.Set("allowInsecure", "1")
	}
	setIf(query, "sni", f.str("sni"))
	setIf(query, "alpn", strings.Join(f.list("alpn"), ","))
	switch f.str("network") {
	case "ws":
		opts := f.sub("ws-opts")
		if opts.sub("headers").str("Host") != "" {
			return ""
		}
		query.Set("type", "ws")
		setIf(query, "path", opts.str("path"))
	case "grpc":
		query.Set("type", "grpc")
		setIf(query, "serviceName", f.sub("grpc-opts").str("grpc-service-name"))
	}
	setIf(query, "fp", f.str("client-fingerprint"))
	setIf(query, "pcs", f.str("fingerprint"))
	return shareURL("trojan", url.User(f.str("password")), hostPort(f), query, f.str("name"))
}

func encodeHysteria(f proxyFields) string {
	query := url.Values{}
	setIf(query, "peer", f.str("sni"))
	setIf(query, "obfs", f.str("obfs"))
	setIf(query, "alpn", strings.Join(f.list("alpn"), ","))
	auth := f.str("auth-str")
	if auth == "" {
		auth = f.str("auth_str")
	}
	setIf(query, "auth", auth)
	setIf(query, "protocol", f.str("protocol"))
	setIf(query, "up", f.str("up"))
	setIf(query, "down", f.str("down"))
	if f.flag("skip-cert-verify") {
		query.Set("insecure", "1")
	}
	return shareURL("hysteria", nil, hostPort(f), query, f.str("name"))
}

// A realm hop needs the realm server's address where the link holds the
// proxy's own, so such a proxy has no link.
func encodeHysteria2(f proxyFields) string {
	if f.sub("realm-opts").flag("enable") {
		return ""
	}
	host := hostPort(f)
	if ports := f.str("ports"); ports != "" && !strings.Contains(f.str("server"), ":") {
		host = f.str("server") + ":" + ports
	}
	var user *url.Userinfo
	if password := f.str("password"); password != "" {
		user = url.User(password)
	}
	query := url.Values{}
	setIf(query, "sni", f.str("sni"))
	setIf(query, "obfs", f.str("obfs"))
	setIf(query, "obfs-password", f.str("obfs-password"))
	if f.flag("skip-cert-verify") {
		query.Set("insecure", "1")
	}
	setIf(query, "alpn", strings.Join(f.list("alpn"), ","))
	setIf(query, "pinSHA256", f.str("fingerprint"))
	setIf(query, "up", f.str("up"))
	setIf(query, "down", f.str("down"))
	return shareURL("hysteria2", user, host, query, f.str("name"))
}

func encodeTuic(f proxyFields) string {
	user := url.UserPassword(f.str("uuid"), f.str("password"))
	if f.str("uuid") == "" {
		user = url.User(f.str("token"))
	}
	query := url.Values{}
	setIf(query, "congestion_control", f.str("congestion-controller"))
	setIf(query, "alpn", strings.Join(f.list("alpn"), ","))
	setIf(query, "sni", f.str("sni"))
	if f.flag("disable-sni") {
		query.Set("disable_sni", "1")
	}
	setIf(query, "udp_relay_mode", f.str("udp-relay-mode"))
	return shareURL("tuic", user, hostPort(f), query, f.str("name"))
}

// The converter reads the user info as base64 before falling back to plain
// text, so it always carries the ":" that no base64 alphabet has.
func encodeSocks(f proxyFields, scheme string) string {
	var user *url.Userinfo
	if username, password := f.str("username"), f.str("password"); username != "" || password != "" {
		user = url.UserPassword(username, password)
	}
	return shareURL(scheme, user, hostPort(f), url.Values{}, f.str("name"))
}

func encodeAnyTLS(f proxyFields) string {
	query := url.Values{}
	setIf(query, "sni", f.str("sni"))
	if f.flag("skip-cert-verify") {
		query.Set("insecure", "1")
	}
	setIf(query, "hpkp", f.str("fingerprint"))
	return shareURL("anytls", url.User(f.str("password")), hostPort(f), query, f.str("name"))
}

func encodeMieru(f proxyFields) string {
	port := f.str("port-range")
	if port == "" {
		port = f.str("port")
	}
	protocol := f.str("transport")
	if protocol == "" {
		protocol = "TCP"
	}
	query := url.Values{}
	query.Set("port", port)
	query.Set("protocol", protocol)
	setIf(query, "multiplexing", f.str("multiplexing"))
	setIf(query, "handshake-mode", f.str("handshake-mode"))
	setIf(query, "traffic-pattern", f.str("traffic-pattern"))
	host := f.str("server")
	if strings.Contains(host, ":") {
		host = "[" + host + "]"
	}
	user := url.UserPassword(f.str("username"), f.str("password"))
	return shareURL("mierus", user, host, query, f.str("name"))
}
