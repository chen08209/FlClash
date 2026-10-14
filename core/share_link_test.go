package core

import (
	"fmt"
	"strings"
	"testing"

	"github.com/metacubex/mihomo/common/convert"
)

func lookupField(proxy map[string]any, path string) any {
	var value any = proxy
	for _, key := range strings.Split(path, ".") {
		mapping, ok := value.(map[string]any)
		if !ok {
			return nil
		}
		value = mapping[key]
	}
	return value
}

func TestShareLinksReadBackThroughTheConverter(t *testing.T) {
	cases := []struct {
		proxy  map[string]any
		prefix string
		want   map[string]string
	}{
		{
			proxy: map[string]any{
				"name": "ss node", "type": "ss", "server": "a.example", "port": 8388,
				"cipher": "aes-256-gcm", "password": "p@ss:word", "udp-over-tcp": true,
				"plugin": "obfs", "plugin-opts": map[string]any{"mode": "tls", "host": "cdn.example"},
			},
			prefix: "ss://aes-256-gcm:p%40ss%3Aword@a.example:8388",
			want: map[string]string{
				"name": "ss node", "server": "a.example", "port": "8388",
				"cipher": "aes-256-gcm", "password": "p@ss:word", "udp-over-tcp": "true",
				"plugin": "obfs", "plugin-opts.mode": "tls", "plugin-opts.host": "cdn.example",
			},
		},
		{
			proxy: map[string]any{
				"name": "ss 2022", "type": "ss", "server": "2001:db8::1", "port": 443,
				"cipher": "2022-blake3-aes-128-gcm", "password": "AAAAAAAAAAAAAAAAAAAAAA==",
			},
			want: map[string]string{
				"server": "2001:db8::1", "cipher": "2022-blake3-aes-128-gcm",
				"password": "AAAAAAAAAAAAAAAAAAAAAA==",
			},
		},
		{
			proxy: map[string]any{
				"name": "ssr", "type": "ssr", "server": "b.example", "port": 443,
				"cipher": "chacha20-ietf", "password": "secret", "obfs": "tls1.2_ticket_auth",
				"protocol": "auth_aes128_md5", "obfs-param": "obfs.example", "protocol-param": "1:p",
			},
			want: map[string]string{
				"name": "ssr", "server": "b.example", "port": "443", "cipher": "chacha20-ietf",
				"password": "secret", "obfs": "tls1.2_ticket_auth", "protocol": "auth_aes128_md5",
				"obfs-param": "obfs.example", "protocol-param": "1:p",
			},
		},
		{
			proxy: map[string]any{
				"name": "vmess ws", "type": "vmess", "server": "c.example", "port": 443,
				"uuid": "b831381d-6324-4d53-ad4f-8cda48b30811", "alterId": 64, "cipher": "auto",
				"tls": true, "servername": "sni.example", "network": "ws",
				"ws-opts": map[string]any{
					"path": "/ray", "headers": map[string]any{"Host": "host.example"},
					"max-early-data": 2048,
				},
			},
			prefix: "vmess://eyJ",
			want: map[string]string{
				"name": "vmess ws", "server": "c.example", "port": "443",
				"uuid": "b831381d-6324-4d53-ad4f-8cda48b30811", "alterId": "64", "cipher": "auto",
				"tls": "true", "servername": "sni.example", "network": "ws",
				"ws-opts.path": "/ray", "ws-opts.headers.Host": "host.example",
				"ws-opts.max-early-data": "2048",
			},
		},
		{
			proxy: map[string]any{
				"name": "vmess grpc", "type": "vmess", "server": "c.example", "port": "443",
				"uuid": "u", "cipher": "aes-128-gcm", "network": "grpc",
				"grpc-opts": map[string]any{"grpc-service-name": "svc"},
			},
			prefix: "vmess://u@c.example:443?",
			want: map[string]string{
				"network": "grpc", "grpc-opts.grpc-service-name": "svc", "tls": "<nil>",
				"alterId": "0", "cipher": "aes-128-gcm",
			},
		},
		{
			proxy: map[string]any{
				"name": "vmess aead ws", "type": "vmess", "server": "c.example", "port": 443,
				"uuid": "u", "alterId": 0, "cipher": "auto", "tls": true,
				"servername": "sni.example", "client-fingerprint": "chrome", "network": "ws",
				"ws-opts": map[string]any{
					"path": "/ray", "headers": map[string]any{"Host": "host.example"},
				},
			},
			prefix: "vmess://u@c.example:443?",
			want: map[string]string{
				"name": "vmess aead ws", "cipher": "auto", "tls": "true",
				"servername": "sni.example", "client-fingerprint": "chrome", "network": "ws",
				"ws-opts.path": "/ray", "ws-opts.headers.Host": "host.example",
			},
		},
		{
			proxy: map[string]any{
				"name": "vless reality", "type": "vless", "server": "d.example", "port": 443,
				"uuid": "u-1", "flow": "xtls-rprx-vision", "tls": true, "servername": "www.example",
				"client-fingerprint": "firefox", "network": "tcp",
				"reality-opts": map[string]any{"public-key": "pk", "short-id": "ab"},
			},
			want: map[string]string{
				"name": "vless reality", "uuid": "u-1", "flow": "xtls-rprx-vision", "tls": "true",
				"servername": "www.example", "client-fingerprint": "firefox", "network": "tcp",
				"reality-opts.public-key": "pk", "reality-opts.short-id": "ab", "xudp": "<nil>",
			},
		},
		{
			proxy: map[string]any{
				"name": "vless h2", "type": "vless", "server": "d.example", "port": 443,
				"uuid": "u-2", "xudp": true, "network": "h2",
				"h2-opts": map[string]any{"path": "/h2", "host": []any{"h2.example"}},
			},
			want: map[string]string{
				"network": "h2", "h2-opts.path": "/h2", "h2-opts.host": "[h2.example]", "xudp": "true",
			},
		},
		{
			proxy: map[string]any{
				"name": "trojan", "type": "trojan", "server": "e.example", "port": 443,
				"password": "pass word", "sni": "sni.example", "skip-cert-verify": true,
				"alpn": []any{"h2", "http/1.1"}, "network": "grpc",
				"grpc-opts": map[string]any{"grpc-service-name": "g"},
			},
			want: map[string]string{
				"name": "trojan", "password": "pass word", "sni": "sni.example",
				"skip-cert-verify": "true", "alpn": "[h2 http/1.1]", "network": "grpc",
				"grpc-opts.grpc-service-name": "g",
			},
		},
		{
			proxy: map[string]any{
				"name": "trojan ws", "type": "trojan", "server": "e.example", "port": 443,
				"password": "p", "network": "ws", "ws-opts": map[string]any{"path": "/ws"},
			},
			want: map[string]string{"network": "ws", "ws-opts.path": "/ws"},
		},
		{
			proxy: map[string]any{
				"name": "hy", "type": "hysteria", "server": "f.example", "port": 443,
				"auth-str": "token", "up": "30 Mbps", "down": "200 Mbps", "sni": "hy.example",
				"protocol": "udp", "obfs": "o",
			},
			want: map[string]string{
				"auth_str": "token", "up": "30 Mbps", "down": "200 Mbps", "sni": "hy.example",
				"protocol": "udp", "obfs": "o",
			},
		},
		{
			proxy: map[string]any{
				"name": "hy2", "type": "hysteria2", "server": "g.example", "port": 443,
				"ports": "443,20000-30000", "password": "pw", "obfs": "salamander",
				"obfs-password": "op", "sni": "hy2.example", "skip-cert-verify": true,
			},
			want: map[string]string{
				"name": "hy2", "port": "443", "ports": "443,20000-30000", "password": "pw",
				"obfs": "salamander", "obfs-password": "op", "sni": "hy2.example",
				"skip-cert-verify": "true",
			},
		},
		{
			proxy: map[string]any{
				"name": "tuic", "type": "tuic", "server": "h.example", "port": 443,
				"uuid": "u-3", "password": "pw", "congestion-controller": "bbr",
				"udp-relay-mode": "quic", "alpn": []string{"h3"},
			},
			want: map[string]string{
				"uuid": "u-3", "password": "pw", "congestion-controller": "bbr",
				"udp-relay-mode": "quic", "alpn": "[h3]",
			},
		},
		{
			proxy: map[string]any{
				"name": "socks", "type": "socks5", "server": "i.example", "port": 1080,
				"username": "me", "password": "secret",
			},
			want: map[string]string{
				"name": "socks", "type": "socks5", "username": "me", "password": "secret",
			},
		},
		{
			proxy: map[string]any{
				"name": "https", "type": "http", "server": "j.example", "port": 443,
				"username": "test", "tls": true,
			},
			want: map[string]string{
				"type": "http", "username": "test", "password": "", "tls": "true",
			},
		},
		{
			proxy: map[string]any{
				"name": "anytls", "type": "anytls", "server": "k.example", "port": 443,
				"password": "pw", "sni": "a.example", "skip-cert-verify": true,
			},
			want: map[string]string{
				"name": "anytls", "password": "pw", "sni": "a.example", "skip-cert-verify": "true",
			},
		},
		{
			proxy: map[string]any{
				"name": "mieru", "type": "mieru", "server": "l.example", "port": 2999,
				"transport": "TCP", "username": "u", "password": "p", "multiplexing": "MULTIPLEXING_LOW",
			},
			want: map[string]string{
				"name": "mieru:2999/TCP", "port": "2999", "transport": "TCP", "username": "u",
				"password": "p", "multiplexing": "MULTIPLEXING_LOW",
			},
		},
	}

	for _, tc := range cases {
		name, _ := tc.proxy["name"].(string)
		t.Run(name, func(t *testing.T) {
			links := handleEncodeShareLinks([]map[string]any{tc.proxy})
			if !strings.HasPrefix(links[0], tc.prefix) {
				t.Errorf("link %q does not start with %q", links[0], tc.prefix)
			}
			proxies, err := convert.ConvertsV2Ray([]byte(links[0]))
			if err != nil || len(proxies) != 1 {
				t.Fatalf("link %q read back as %v, %v", links[0], proxies, err)
			}
			for path, want := range tc.want {
				if got := fmt.Sprint(lookupField(proxies[0], path)); got != want {
					t.Errorf("%s from %q = %q, want %q", path, links[0], got, want)
				}
			}
		})
	}
}

func TestShareLinksLeaveOutWhatNoLinkCarries(t *testing.T) {
	links := handleEncodeShareLinks([]map[string]any{
		{"name": "wg", "type": "wireguard", "server": "a.example", "port": 51820},
		{"name": "no server", "type": "ss", "cipher": "aes-128-gcm", "password": "p"},
		{"name": "ssr v6", "type": "ssr", "server": "2001:db8::1", "port": 443},
		{
			"name": "realm", "type": "hysteria2", "server": "a.example", "port": 443,
			"realm-opts": map[string]any{"enable": true},
		},
		{
			"name": "shadow-tls", "type": "ss", "server": "a.example", "port": 443,
			"cipher": "aes-128-gcm", "password": "p", "plugin": "shadow-tls",
			"plugin-opts": map[string]any{"host": "cdn.example", "password": "x"},
		},
		{
			"name": "trojan ws host", "type": "trojan", "server": "a.example", "port": 443,
			"password": "p", "network": "ws",
			"ws-opts": map[string]any{"path": "/ws", "headers": map[string]any{"Host": "cdn.example"}},
		},
	})
	for i, link := range links {
		if link != "" {
			t.Errorf("mapping %d encoded to %q", i, link)
		}
	}
}

func TestDecodeShareLinksAnswersEveryLine(t *testing.T) {
	results := handleDecodeShareLinks([]string{
		"trojan://pw@a.example:443#one",
		"not a link",
		"socks5://b.example:1080#two",
	})
	if len(results) != 3 || len(results[0]) != 1 || len(results[1]) != 0 || len(results[2]) != 1 {
		t.Fatalf("results = %v", results)
	}
	if results[0][0]["name"] != "one" || results[2][0]["name"] != "two" {
		t.Errorf("names = %v, %v", results[0][0]["name"], results[2][0]["name"])
	}
}
