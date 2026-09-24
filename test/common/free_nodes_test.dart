import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/free_nodes.dart';
import 'package:fl_clash/common/preferences.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yaml/yaml.dart';

void main() {
  const sampleConfig = '''
proxies:
  - name: node-a
    type: ss
    server: example.com
    port: 443
    cipher: aes-128-gcm
    password: pass
  - name: node-a-copy
    type: ss
    server: example.com
    port: 443
    cipher: aes-128-gcm
    password: pass
  - name: node-b
    type: vmess
    server: vmess.example.com
    port: 8443
    uuid: 00000000-0000-0000-0000-000000000000
    alterId: 0
    cipher: auto
''';

  test(
    'parses Clash YAML proxies and removes duplicates in merged config',
    () async {
      final service = FreeNodesService(
        fetcher: (url) async {
          if (url == 'https://github.com/free-nodes/clashfree') {
            return 'https://raw.githubusercontent.com/free-nodes/clashfree/main/clash20260530.yml';
          }
          return sampleConfig;
        },
      );

      final result = await service.fetchMergedConfig();
      final yamlText = utf8.decode(result.bytes);

      expect(result.proxyCount, 2);
      expect(yamlText, contains('name: "FREE-NODES"'));
      expect(yamlText, contains('type: "url-test"'));
      expect(
        yamlText,
        contains(
          'url: "http://connectivitycheck.platform.hicloud.com/generate_204"',
        ),
      );
      expect(yamlText, contains('hidden: false'));
      expect(yamlText, contains('MATCH,FREE-NODES'));
    },
  );

  test('renames same-name proxies before writing merged config', () async {
    const sameNameConfig = '''
proxies:
  - name: repeated
    type: ss
    server: first.example.com
    port: 443
    cipher: aes-128-gcm
    password: pass-a
  - name: repeated
    type: ss
    server: second.example.com
    port: 443
    cipher: aes-128-gcm
    password: pass-b
''';
    final service = FreeNodesService(
      fetcher: (url) async {
        if (url == 'https://github.com/free-nodes/clashfree') {
          return 'https://raw.githubusercontent.com/free-nodes/clashfree/main/clash20260530.yml';
        }
        return sameNameConfig;
      },
    );

    final result = await service.fetchMergedConfig();
    final yamlText = utf8.decode(result.bytes);

    expect(result.proxyCount, 2);
    expect(
      RegExp(r'name: "repeated"$', multiLine: true).allMatches(yamlText),
      hasLength(1),
    );
    expect(yamlText, contains('name: "repeated 1"'));
  });

  test(
    'normalizes legacy chacha20-poly1305 cipher before writing config',
    () async {
      const legacyCipherConfig = '''
proxies:
  - name: legacy-cipher
    type: ss
    server: legacy.example.com
    port: 8388
    cipher: chacha20-poly1305
    password: pass
''';
      final service = FreeNodesService(
        fetcher: (url) async {
          if (url == 'https://github.com/free-nodes/clashfree') {
            return 'https://raw.githubusercontent.com/free-nodes/clashfree/main/clash20260530.yml';
          }
          return legacyCipherConfig;
        },
      );

      final result = await service.fetchMergedConfig();
      final yamlText = utf8.decode(result.bytes);

      expect(result.proxyCount, 1);
      expect(yamlText, contains('cipher: "chacha20-ietf-poly1305"'));
      expect(yamlText, isNot(contains('cipher: "chacha20-poly1305"')));
    },
  );

  test('Dart fallback parses YAML proxy maps', () async {
    const catalog = '''
{
  "lookbackDays": 0,
  "historyTimeoutHours": 72,
  "sources": [
    {
      "id": "map",
      "seed": "https://example.com/map.yaml",
      "rank": 0,
      "configTemplates": ["https://example.com/map.yaml"]
    }
  ]
}
''';
    const mapConfig = '''
proxies:
  map-ss:
    type: ss
    server: map-ss.example.com
    port: 443
    cipher: aes-128-gcm
    password: pass
  explicit-name:
    name: kept-name
    type: trojan
    server: map-trojan.example.com
    port: 443
    password: secret
''';
    final service = FreeNodesService(
      sourceCatalogJson: catalog,
      fetcher: (_) async => mapConfig,
    );

    final result = await service.fetchMergedConfig();
    final yamlText = utf8.decode(result.bytes);

    expect(result.proxyCount, 2);
    expect(yamlText, contains('name: "map-ss"'));
    expect(yamlText, contains('server: "map-ss.example.com"'));
    expect(yamlText, contains('name: "kept-name"'));
    expect(yamlText, contains('server: "map-trojan.example.com"'));
  });

  test('Dart fallback parses legacy Clash Proxy key', () async {
    const catalog = '''
{
  "lookbackDays": 0,
  "historyTimeoutHours": 72,
  "sources": [
    {
      "id": "legacy-proxy",
      "seed": "https://example.com/legacy.yaml",
      "rank": 0,
      "configTemplates": ["https://example.com/legacy.yaml"]
    }
  ]
}
''';
    const legacyConfig = '''
Proxy:
  - name: legacy-proxy
    type: ss
    server: legacy-proxy.example.com
    port: 443
    cipher: aes-128-gcm
    password: pass
''';
    final service = FreeNodesService(
      sourceCatalogJson: catalog,
      fetcher: (_) async => legacyConfig,
    );

    final result = await service.fetchMergedConfig();
    final yamlText = utf8.decode(result.bytes);

    expect(result.proxyCount, greaterThan(0));
    expect(yamlText, contains('name: "legacy-proxy"'));
    expect(yamlText, contains('server: "legacy-proxy.example.com"'));
  });

  test('fetch parses sing-box json outbounds in fallback merge path', () async {
    const catalog = '''
{
  "lookbackDays": 0,
  "historyTimeoutHours": 72,
  "sources": [
    {
      "id": "sing-box",
      "seed": "https://example.com/sing-box.json",
      "rank": 0,
      "configTemplates": ["https://example.com/sing-box.json"]
    }
  ]
}
''';
    const singBoxConfig = '''
{
  "outbounds": [
    {
      "type": "shadowsocks",
      "tag": "SS Out",
      "server": "ss.example.com",
      "server_port": 8388,
      "method": "aes-128-gcm",
      "password": "ss-pass"
    },
    {
      "type": "trojan",
      "tag": "Trojan Out",
      "server": "trojan.example.com",
      "server_port": 443,
      "password": "trojan-pass",
      "tls": {"enabled": true, "server_name": "sni.example.com"}
    }
  ]
}
''';
    final service = FreeNodesService(
      sourceCatalogJson: catalog,
      fetcher: (_) async => singBoxConfig,
    );

    final result = await service.fetchMergedConfig();
    final yamlText = utf8.decode(result.bytes);

    expect(result.proxyCount, 2);
    expect(yamlText, contains('name: "SS Out"'));
    expect(yamlText, contains('type: "ss"'));
    expect(yamlText, contains('name: "Trojan Out"'));
    expect(yamlText, contains('sni: "sni.example.com"'));
  });

  test('Dart fallback parses sing-box outbound maps', () async {
    const catalog = '''
{
  "lookbackDays": 0,
  "historyTimeoutHours": 72,
  "sources": [
    {
      "id": "outbound-map",
      "seed": "https://example.com/outbound-map.yaml",
      "rank": 0,
      "configTemplates": ["https://example.com/outbound-map.yaml"]
    }
  ]
}
''';
    const singBoxConfig = '''
outbounds:
  ss-map:
    type: shadowsocks
    server: ss-map.example.com
    server_port: 8388
    method: aes-128-gcm
    password: ss-pass
  explicit-tag:
    type: trojan
    tag: kept-tag
    server: trojan-map.example.com
    server_port: 443
    password: trojan-pass
''';
    final service = FreeNodesService(
      sourceCatalogJson: catalog,
      fetcher: (_) async => singBoxConfig,
    );

    final result = await service.fetchMergedConfig();
    final yamlText = utf8.decode(result.bytes);

    expect(result.proxyCount, 2);
    expect(yamlText, contains('name: "ss-map"'));
    expect(yamlText, contains('server: "ss-map.example.com"'));
    expect(yamlText, contains('name: "kept-tag"'));
    expect(yamlText, contains('server: "trojan-map.example.com"'));
  });

  test('Dart fallback parses sing-box hysteria2 server_ports only', () async {
    const catalog = '''
{
  "lookbackDays": 0,
  "historyTimeoutHours": 72,
  "sources": [
    {
      "id": "hy2",
      "seed": "https://example.com/hy2.json",
      "rank": 0,
      "configTemplates": ["https://example.com/hy2.json"]
    }
  ]
}
''';
    const singBoxConfig = '''
{
  "outbounds": [
    {
      "type": "hysteria2",
      "tag": "HY2 Multi",
      "server": "hy2-multi.example.com",
      "server_ports": "443,8443-8445",
      "password": "hy2-pass"
    }
  ]
}
''';
    final service = FreeNodesService(
      sourceCatalogJson: catalog,
      fetcher: (_) async => singBoxConfig,
    );

    final result = await service.fetchMergedConfig();
    final yamlText = utf8.decode(result.bytes);

    expect(result.proxyCount, greaterThan(0));
    expect(yamlText, contains('name: "HY2 Multi"'));
    expect(yamlText, contains('port: 443'));
    expect(yamlText, contains('ports: "443,8443-8445"'));
  });

  test('Dart fallback parses sing-box hysteria2 server_ports arrays', () async {
    const catalog = '''
{
  "lookbackDays": 0,
  "historyTimeoutHours": 72,
  "sources": [
    {
      "id": "hy2-array",
      "seed": "https://example.com/hy2-array.json",
      "rank": 0,
      "configTemplates": ["https://example.com/hy2-array.json"]
    }
  ]
}
''';
    const singBoxConfig = '''
{
  "outbounds": [
    {
      "type": "hysteria2",
      "tag": "HY2 Array",
      "server": "hy2-array.example.com",
      "server_ports": [443, "8443-8445"],
      "password": "hy2-pass"
    }
  ]
}
''';
    final service = FreeNodesService(
      sourceCatalogJson: catalog,
      fetcher: (_) async => singBoxConfig,
    );

    final result = await service.fetchMergedConfig();
    final yamlText = utf8.decode(result.bytes);

    expect(result.proxyCount, 1);
    expect(yamlText, contains('port: 443'));
    expect(yamlText, contains('ports: "443,8443-8445"'));
  });

  test('Dart fallback parses sing-box socks outbounds', () async {
    const catalog = '''
{
  "lookbackDays": 0,
  "historyTimeoutHours": 72,
  "sources": [
    {
      "id": "socks-outbound",
      "seed": "https://example.com/socks.json",
      "rank": 0,
      "configTemplates": ["https://example.com/socks.json"]
    }
  ]
}
''';
    const singBoxConfig = '''
{
  "outbounds": [
    {
      "type": "socks",
      "tag": "SOCKS Out",
      "server": "socks.example.com",
      "server_port": 1080,
      "username": "user",
      "password": "pass",
      "udp": true
    }
  ]
}
''';
    final service = FreeNodesService(
      sourceCatalogJson: catalog,
      fetcher: (_) async => singBoxConfig,
    );

    final result = await service.fetchMergedConfig();
    final yamlText = utf8.decode(result.bytes);

    expect(result.proxyCount, 1);
    expect(yamlText, contains('name: "SOCKS Out"'));
    expect(yamlText, contains('type: "socks5"'));
    expect(yamlText, contains('server: "socks.example.com"'));
    expect(yamlText, contains('port: 1080'));
    expect(yamlText, contains('username: "user"'));
    expect(yamlText, contains('password: "pass"'));
    expect(yamlText, contains('udp: true'));
  });

  test('Dart fallback parses sing-box http outbounds', () async {
    const catalog = '''
{
  "lookbackDays": 0,
  "historyTimeoutHours": 72,
  "sources": [
    {
      "id": "http-outbound",
      "seed": "https://example.com/http.json",
      "rank": 0,
      "configTemplates": ["https://example.com/http.json"]
    }
  ]
}
''';
    const singBoxConfig = '''
{
  "outbounds": [
    {
      "type": "http",
      "tag": "HTTP Out",
      "server": "http-out.example.com",
      "server_port": 8080,
      "username": "user",
      "password": "pass"
    }
  ]
}
''';
    final service = FreeNodesService(
      sourceCatalogJson: catalog,
      fetcher: (_) async => singBoxConfig,
    );

    final result = await service.fetchMergedConfig();
    final yamlText = utf8.decode(result.bytes);

    expect(result.proxyCount, 1);
    expect(yamlText, contains('name: "HTTP Out"'));
    expect(yamlText, contains('type: "http"'));
    expect(yamlText, contains('server: "http-out.example.com"'));
    expect(yamlText, contains('port: 8080'));
    expect(yamlText, contains('username: "user"'));
    expect(yamlText, contains('password: "pass"'));
  });

  test('Dart fallback parses sing-box ssh outbounds', () async {
    const catalog = '''
{
  "lookbackDays": 0,
  "historyTimeoutHours": 72,
  "sources": [
    {
      "id": "ssh-outbound",
      "seed": "https://example.com/ssh.json",
      "rank": 0,
      "configTemplates": ["https://example.com/ssh.json"]
    }
  ]
}
''';
    const singBoxConfig = '''
{
  "outbounds": [
    {
      "type": "ssh",
      "tag": "SSH Out",
      "server": "ssh-out.example.com",
      "server_port": 22,
      "username": "root",
      "password": "pass",
      "private_key": "key-value",
      "private_key_passphrase": "passphrase"
    }
  ]
}
''';
    final service = FreeNodesService(
      sourceCatalogJson: catalog,
      fetcher: (_) async => singBoxConfig,
    );

    final result = await service.fetchMergedConfig();
    final yamlText = utf8.decode(result.bytes);

    expect(result.proxyCount, 1);
    expect(yamlText, contains('name: "SSH Out"'));
    expect(yamlText, contains('type: "ssh"'));
    expect(yamlText, contains('server: "ssh-out.example.com"'));
    expect(yamlText, contains('port: 22'));
    expect(yamlText, contains('username: "root"'));
    expect(yamlText, contains('password: "pass"'));
    expect(yamlText, contains('private-key: "key-value"'));
    expect(yamlText, contains('private-key-passphrase: "passphrase"'));
  });

  test('Dart fallback parses sing-box AnyTLS outbounds', () async {
    const catalog = '''
{
  "lookbackDays": 0,
  "historyTimeoutHours": 72,
  "sources": [
    {
      "id": "anytls-outbound",
      "seed": "https://example.com/anytls.json",
      "rank": 0,
      "configTemplates": ["https://example.com/anytls.json"]
    }
  ]
}
''';
    const singBoxConfig = '''
{
  "outbounds": [
    {
      "type": "anytls",
      "tag": "AnyTLS Out",
      "server": "anytls-out.example.com",
      "server_port": 8443,
      "username": "user",
      "password": "pass",
      "udp": true,
      "tls": {"enabled": true, "server_name": "sni.example.com"}
    }
  ]
}
''';
    final service = FreeNodesService(
      sourceCatalogJson: catalog,
      fetcher: (_) async => singBoxConfig,
    );

    final result = await service.fetchMergedConfig();
    final yamlText = utf8.decode(result.bytes);

    expect(result.proxyCount, 1);
    expect(yamlText, contains('name: "AnyTLS Out"'));
    expect(yamlText, contains('type: "anytls"'));
    expect(yamlText, contains('server: "anytls-out.example.com"'));
    expect(yamlText, contains('port: 8443'));
    expect(yamlText, contains('username: "user"'));
    expect(yamlText, contains('password: "pass"'));
    expect(yamlText, contains('udp: true'));
    expect(yamlText, contains('sni: "sni.example.com"'));
  });

  test('Dart fallback parses sing-box WireGuard outbounds', () async {
    const catalog = '''
{
  "lookbackDays": 0,
  "historyTimeoutHours": 72,
  "sources": [
    {
      "id": "wireguard-outbound",
      "seed": "https://example.com/wireguard.json",
      "rank": 0,
      "configTemplates": ["https://example.com/wireguard.json"]
    }
  ]
}
''';
    const singBoxConfig = '''
{
  "outbounds": [
    {
      "type": "wireguard",
      "tag": "WG Out",
      "server": "wg-out.example.com",
      "server_port": 2480,
      "private_key": "private-key-value",
      "peer_public_key": "public-key-value",
      "pre_shared_key": "psk-value",
      "local_address": ["172.16.0.2/32", "fd01::1/128"],
      "reserved": "U4An",
      "udp": true,
      "mtu": 1280
    }
  ]
}
''';
    final service = FreeNodesService(
      sourceCatalogJson: catalog,
      fetcher: (_) async => singBoxConfig,
    );

    final result = await service.fetchMergedConfig();
    final yamlText = utf8.decode(result.bytes);

    expect(result.proxyCount, 1);
    expect(yamlText, contains('name: "WG Out"'));
    expect(yamlText, contains('type: "wireguard"'));
    expect(yamlText, contains('server: "wg-out.example.com"'));
    expect(yamlText, contains('port: 2480'));
    expect(yamlText, contains('private-key: "private-key-value"'));
    expect(yamlText, contains('public-key: "public-key-value"'));
    expect(yamlText, contains('pre-shared-key: "psk-value"'));
    expect(yamlText, contains('ip: "172.16.0.2/32"'));
    expect(yamlText, contains('ipv6: "fd01::1/128"'));
    expect(yamlText, contains('reserved: "U4An"'));
    expect(yamlText, contains('udp: true'));
    expect(yamlText, contains('mtu: 1280'));
  });

  test('Dart fallback parses sing-box hysteria v1 outbounds', () async {
    const catalog = '''
{
  "lookbackDays": 0,
  "historyTimeoutHours": 72,
  "sources": [
    {
      "id": "hysteria-outbound",
      "seed": "https://example.com/hysteria.json",
      "rank": 0,
      "configTemplates": ["https://example.com/hysteria.json"]
    }
  ]
}
''';
    const singBoxConfig = '''
{
  "outbounds": [
    {
      "type": "hysteria",
      "tag": "HY Out",
      "server": "hy-out.example.com",
      "server_port": 8443,
      "auth_str": "auth-value",
      "protocol": "udp",
      "up_mbps": "100",
      "down_mbps": "200",
      "server_ports": "8443,9443-9555",
      "obfs": "obfs-value",
      "udp": true
    }
  ]
}
''';
    final service = FreeNodesService(
      sourceCatalogJson: catalog,
      fetcher: (_) async => singBoxConfig,
    );

    final result = await service.fetchMergedConfig();
    final yamlText = utf8.decode(result.bytes);

    expect(result.proxyCount, 1);
    expect(yamlText, contains('name: "HY Out"'));
    expect(yamlText, contains('type: "hysteria"'));
    expect(yamlText, contains('server: "hy-out.example.com"'));
    expect(yamlText, contains('port: 8443'));
    expect(yamlText, contains('auth_str: "auth-value"'));
    expect(yamlText, contains('protocol: "udp"'));
    expect(yamlText, contains('up: "100"'));
    expect(yamlText, contains('down: "200"'));
    expect(yamlText, contains('ports: "8443,9443-9555"'));
    expect(yamlText, contains('obfs: "obfs-value"'));
    expect(yamlText, contains('udp: true'));
  });

  test(
    'Dart fallback follows singular proxy-provider before probe URLs',
    () async {
      const catalog = '''
{
  "lookbackDays": 0,
  "historyTimeoutHours": 72,
  "sources": [
    {
      "id": "provider",
      "seed": "https://example.com/config.yaml",
      "rank": 0,
      "configTemplates": ["https://example.com/config.yaml"]
    }
  ]
}
''';
      final fetchedUrls = <String>[];
      final service = FreeNodesService(
        sourceCatalogJson: catalog,
        fetcher: (url) async {
          fetchedUrls.add(url);
          if (url == 'https://example.com/config.yaml') {
            return '''
proxy-groups:
  - name: AUTO
    type: url-test
    url: https://probe.example.com/health.yaml
proxy-provider:
  daily:
    type: http
    url: ./providers/daily.yaml?target=clash
''';
          }
          if (url == 'https://example.com/providers/daily.yaml?target=clash') {
            return '''
proxies:
  - name: provider-node
    type: ss
    server: provider.example.com
    port: 443
    cipher: aes-128-gcm
    password: pass
''';
          }
          throw StateError('unexpected fetch: $url');
        },
      );

      final result = await service.fetchMergedConfig();
      final yamlText = utf8.decode(result.bytes);

      expect(fetchedUrls, [
        'https://example.com/config.yaml',
        'https://example.com/providers/daily.yaml?target=clash',
      ]);
      expect(result.proxyCount, 1);
      expect(yamlText, contains('provider-node'));
      expect(yamlText, isNot(contains('probe.example.com')));
    },
  );

  test('Dart fallback follows base64 YAML proxy-provider URLs', () async {
    const catalog = '''
{
  "lookbackDays": 0,
  "historyTimeoutHours": 72,
  "sources": [
    {
      "id": "base64-provider",
      "seed": "https://example.com/config.txt",
      "rank": 0,
      "configTemplates": ["https://example.com/config.txt"]
    }
  ]
}
''';
    final encodedConfig = base64Encode(
      utf8.encode('''
proxy-provider:
  daily:
    type: http
    url: ./providers/daily.yaml?target=clash
'''),
    );
    final fetchedUrls = <String>[];
    final service = FreeNodesService(
      sourceCatalogJson: catalog,
      fetcher: (url) async {
        fetchedUrls.add(url);
        if (url == 'https://example.com/config.txt') {
          return encodedConfig;
        }
        if (url == 'https://example.com/providers/daily.yaml?target=clash') {
          return '''
proxies:
  - name: decoded-provider-node
    type: ss
    server: decoded-provider.example.com
    port: 443
    cipher: aes-128-gcm
    password: pass
''';
        }
        throw StateError('unexpected fetch: $url');
      },
    );

    final result = await service.fetchMergedConfig();
    final yamlText = utf8.decode(result.bytes);

    expect(fetchedUrls, [
      'https://example.com/config.txt',
      'https://example.com/providers/daily.yaml?target=clash',
    ]);
    expect(result.proxyCount, 1);
    expect(yamlText, contains('decoded-provider-node'));
  });

  test(
    'Dart fallback follows embedded base64 YAML proxy-provider URLs',
    () async {
      const catalog = '''
{
  "lookbackDays": 0,
  "historyTimeoutHours": 72,
  "sources": [
    {
      "id": "embedded-base64-provider",
      "seed": "https://example.com/page/config.txt",
      "rank": 0,
      "configTemplates": ["https://example.com/page/config.txt"]
    }
  ]
}
''';
      final encodedConfig = base64Encode(
        utf8.encode('''
proxy-providers:
  daily:
    type: http
    url: ./providers/daily.yaml?target=clash
'''),
      );
      final fetchedUrls = <String>[];
      final service = FreeNodesService(
        sourceCatalogJson: catalog,
        fetcher: (url) async {
          fetchedUrls.add(url);
          if (url == 'https://example.com/page/config.txt') {
            return "<script>window.sub='$encodedConfig';</script>";
          }
          if (url ==
              'https://example.com/page/providers/daily.yaml?target=clash') {
            return '''
proxies:
  - name: embedded-provider-node
    type: ss
    server: embedded-provider.example.com
    port: 443
    cipher: aes-128-gcm
    password: pass
''';
          }
          throw StateError('unexpected fetch: $url');
        },
      );

      final result = await service.fetchMergedConfig();
      final yamlText = utf8.decode(result.bytes);

      expect(fetchedUrls, [
        'https://example.com/page/config.txt',
        'https://example.com/page/providers/daily.yaml?target=clash',
      ]);
      expect(result.proxyCount, 1);
      expect(yamlText, contains('embedded-provider-node'));
    },
  );

  test('parses base64 URI subscriptions into Clash proxies', () {
    final encoded = base64Encode(
      utf8.encode(
        'ss://YWVzLTEyOC1nY206cGFzc0BleGFtcGxlLmNvbTo0NDM=#SS%20Node\n'
        'vmess://eyJhZGQiOiJ2bWVzcy5leGFtcGxlLmNvbSIsInBvcnQiOiI4NDQzIiwiaWQiOiIwMDAwMDAwMC0wMDAwLTAwMDAtMDAwMC0wMDAwMDAwMDAwMDAiLCJhaWQiOiIwIiwic2N5IjoiYXV0byIsInBzIjoiVk1lc3MgTm9kZSJ9',
      ),
    );
    final service = FreeNodesService(fetcher: (_) async => '');

    final proxies = service.parseProxies(encoded);

    expect(proxies, hasLength(2));
    expect(proxies.map((proxy) => proxy['type']), containsAll(['ss', 'vmess']));
  });

  test('Dart fallback parses embedded base64 URI subscription blocks', () {
    final encoded = base64Encode(
      utf8.encode('ss://aes-128-gcm:pass@example.com:443#Embedded'),
    );
    final service = FreeNodesService(fetcher: (_) async => '');

    final proxies = service.parseProxies(
      "<script>window.__sub = '$encoded';</script>",
    );

    expect(proxies, hasLength(1));
    expect(proxies.single['server'], 'example.com');
  });

  test('Dart fallback parses embedded base64url URI subscription blocks', () {
    const encoded =
        'c3M6Ly9hZXMtMTI4LWdjbTpwYXNzQHVybHNhZmUuZXhhbXBsZS5jb206NDQzI8Owwp_CmMKA';
    final service = FreeNodesService(fetcher: (_) async => '');

    final proxies = service.parseProxies(
      "<script>window.__sub = '$encoded';</script>",
    );

    expect(proxies, hasLength(1));
    expect(proxies.single['server'], 'urlsafe.example.com');
  });

  test('Dart fallback parses whitespace separated base64 subscriptions', () {
    final encoded = base64Encode(
      utf8.encode('ss://aes-128-gcm:pass@spaced.example.com:443#Spaced'),
    );
    final spaced =
        '${encoded.substring(0, 12)} \t${encoded.substring(12, 28)} '
        '${encoded.substring(28)}';
    final service = FreeNodesService(fetcher: (_) async => '');

    final proxies = service.parseProxies(spaced);

    expect(proxies, hasLength(1));
    expect(proxies.single['server'], 'spaced.example.com');
  });

  test('Dart fallback parses SSR URI subscriptions', () {
    final service = FreeNodesService(fetcher: (_) async => '');
    final password = base64Url.encode(utf8.encode('pass'));
    final remarks = base64Url.encode(utf8.encode('SSR Node'));
    final obfsParam = base64Url.encode(utf8.encode('obfs.example.com'));
    final protoParam = base64Url.encode(utf8.encode('proto-token'));
    final decoded =
        'ssr.example.com:8388:origin:aes-256-cfb:plain:$password'
        '/?remarks=$remarks&obfsparam=$obfsParam&protoparam=$protoParam';
    final uri = 'ssr://${base64Url.encode(utf8.encode(decoded))}';

    final proxies = service.parseProxies(uri);

    expect(proxies, hasLength(1));
    final proxy = proxies.single;
    expect(proxy['name'], 'SSR Node');
    expect(proxy['type'], 'ssr');
    expect(proxy['server'], 'ssr.example.com');
    expect(proxy['port'], 8388);
    expect(proxy['cipher'], 'aes-256-cfb');
    expect(proxy['password'], 'pass');
    expect(proxy['protocol'], 'origin');
    expect(proxy['obfs'], 'plain');
    expect(proxy['udp'], isTrue);
    expect(proxy['protocol-param'], 'proto-token');
    expect(proxy['obfs-param'], 'obfs.example.com');
  });

  test('Dart fallback parses Snell URI subscriptions', () {
    final service = FreeNodesService(fetcher: (_) async => '');

    final proxies = service.parseProxies(
      'snell://psk-value@snell.example.com:44046?version=3&obfs=http&obfs-host=www.bing.com#Snell%20Node',
    );

    expect(proxies, hasLength(1));
    final proxy = proxies.single;
    expect(proxy['name'], 'Snell Node');
    expect(proxy['type'], 'snell');
    expect(proxy['server'], 'snell.example.com');
    expect(proxy['port'], 44046);
    expect(proxy['psk'], 'psk-value');
    expect(proxy['version'], 3);
    expect(proxy['obfs-opts'], {'mode': 'http', 'host': 'www.bing.com'});
  });

  test('Dart fallback parses SOCKS URI subscriptions', () {
    final service = FreeNodesService(fetcher: (_) async => '');
    final encoded = base64Encode(utf8.encode('user-b64:pass-b64'));

    final proxies = service.parseProxies(
      'socks5://user:pass@socks.example.com:1080?udp=1#SOCKS%20Node\n'
      'socks://socks.example.net:1080#SOCKS%20Alias\n'
      'socks5h://$encoded@socks-b64.example.com:1080?udp=true#SOCKS%20Base64',
    );

    expect(proxies, hasLength(3));
    final socks5 = proxies[0];
    expect(socks5['name'], 'SOCKS Node');
    expect(socks5['type'], 'socks5');
    expect(socks5['server'], 'socks.example.com');
    expect(socks5['port'], 1080);
    expect(socks5['username'], 'user');
    expect(socks5['password'], 'pass');
    expect(socks5['udp'], isTrue);

    final alias = proxies[1];
    expect(alias['name'], 'SOCKS Alias');
    expect(alias['type'], 'socks5');
    expect(alias['server'], 'socks.example.net');
    expect(alias['port'], 1080);

    final socks5h = proxies[2];
    expect(socks5h['name'], 'SOCKS Base64');
    expect(socks5h['type'], 'socks5');
    expect(socks5h['server'], 'socks-b64.example.com');
    expect(socks5h['port'], 1080);
    expect(socks5h['username'], 'user-b64');
    expect(socks5h['password'], 'pass-b64');
    expect(socks5h['udp'], isTrue);
  });

  test('Dart fallback parses HTTP proxy URI subscriptions', () {
    final service = FreeNodesService(fetcher: (_) async => '');

    final proxies = service.parseProxies(
      'http://user:pass@http-proxy.example.com:8080#HTTP%20Proxy\n'
      'https://secure:secret@https-proxy.example.com:8443#HTTPS%20Proxy\n'
      'https://example.com:8443/free-node/list.html?target=clash',
    );

    expect(proxies, hasLength(2));
    final http = proxies[0];
    expect(http['name'], 'HTTP Proxy');
    expect(http['type'], 'http');
    expect(http['server'], 'http-proxy.example.com');
    expect(http['port'], 8080);
    expect(http['username'], 'user');
    expect(http['password'], 'pass');
    expect(http['skip-cert-verify'], isTrue);
    expect(http.containsKey('tls'), isFalse);

    final https = proxies[1];
    expect(https['name'], 'HTTPS Proxy');
    expect(https['type'], 'http');
    expect(https['server'], 'https-proxy.example.com');
    expect(https['port'], 8443);
    expect(https['username'], 'secure');
    expect(https['password'], 'secret');
    expect(https['tls'], isTrue);
    expect(https['skip-cert-verify'], isTrue);
  });

  test('Dart fallback parses SSH URI subscriptions', () {
    final service = FreeNodesService(fetcher: (_) async => '');

    final proxies = service.parseProxies(
      'ssh://root:password@ssh.example.com:22?private-key=key-value&private-key-passphrase=passphrase&host-key=key-a%2Ckey-b&host-key-algorithms=ssh-ed25519%2Crsa-sha2-256#SSH%20Node',
    );

    expect(proxies, hasLength(1));
    final proxy = proxies.single;
    expect(proxy['name'], 'SSH Node');
    expect(proxy['type'], 'ssh');
    expect(proxy['server'], 'ssh.example.com');
    expect(proxy['port'], 22);
    expect(proxy['username'], 'root');
    expect(proxy['password'], 'password');
    expect(proxy['private-key'], 'key-value');
    expect(proxy['private-key-passphrase'], 'passphrase');
    expect(proxy['host-key'], ['key-a', 'key-b']);
    expect(proxy['host-key-algorithms'], ['ssh-ed25519', 'rsa-sha2-256']);
  });

  test('Dart fallback parses hysteria v1 URI subscriptions', () {
    final service = FreeNodesService(fetcher: (_) async => '');

    final proxies = service.parseProxies(
      'hysteria://hy.example.com:8443?auth=secret&peer=sni.example.com&protocol=udp&upmbps=100&downmbps=200&ports=8443,9443-9555&obfs-protocol=wechat-video&obfs=obfs-pass&alpn=h3,h4&insecure=1#HY%20V1',
    );

    expect(proxies, hasLength(1));
    final proxy = proxies.single;
    expect(proxy['name'], 'HY V1');
    expect(proxy['type'], 'hysteria');
    expect(proxy['server'], 'hy.example.com');
    expect(proxy['port'], 8443);
    expect(proxy['auth_str'], 'secret');
    expect(proxy['sni'], 'sni.example.com');
    expect(proxy['protocol'], 'udp');
    expect(proxy['up'], '100');
    expect(proxy['down'], '200');
    expect(proxy['ports'], '8443,9443-9555');
    expect(proxy['obfs'], 'obfs-pass');
    expect(proxy['obfs-protocol'], 'wechat-video');
    expect(proxy['alpn'], ['h3', 'h4']);
    expect(proxy['skip-cert-verify'], isTrue);
  });

  test('Dart fallback parses TUIC v4 and v5 URI subscriptions', () {
    final service = FreeNodesService(fetcher: (_) async => '');

    final proxies = service.parseProxies(
      'tuic://uuid-123:pass-456@tuic.example.com:443?congestion_control=bbr&udp_relay_mode=native&alpn=h3,h4&sni=sni.example.com#TUIC%20V5\n'
      'tuic://token-123@tuic-v4.example.com:8443?disable_sni=1&udp_relay_mode=quic&allow_insecure=1#TUIC%20V4',
    );

    expect(proxies, hasLength(2));
    final v5 = proxies[0];
    expect(v5['name'], 'TUIC V5');
    expect(v5['type'], 'tuic');
    expect(v5['server'], 'tuic.example.com');
    expect(v5['port'], 443);
    expect(v5['uuid'], 'uuid-123');
    expect(v5['password'], 'pass-456');
    expect(v5['udp'], isTrue);
    expect(v5['congestion-controller'], 'bbr');
    expect(v5['udp-relay-mode'], 'native');
    expect(v5['sni'], 'sni.example.com');
    expect(v5['alpn'], ['h3', 'h4']);

    final v4 = proxies[1];
    expect(v4['name'], 'TUIC V4');
    expect(v4['type'], 'tuic');
    expect(v4['server'], 'tuic-v4.example.com');
    expect(v4['port'], 8443);
    expect(v4['token'], 'token-123');
    expect(v4.containsKey('uuid'), isFalse);
    expect(v4.containsKey('password'), isFalse);
    expect(v4['disable-sni'], isTrue);
    expect(v4['udp-relay-mode'], 'quic');
    expect(v4['skip-cert-verify'], isTrue);
  });

  test('Dart fallback parses AnyTLS URI subscriptions', () {
    final service = FreeNodesService(fetcher: (_) async => '');

    final proxies = service.parseProxies(
      'anytls://user:pass@anytls.example.com:8443?sni=sni.example.com&hpkp=fp-value&insecure=1#AnyTLS%20Node',
    );

    expect(proxies, hasLength(1));
    final proxy = proxies.single;
    expect(proxy['name'], 'AnyTLS Node');
    expect(proxy['type'], 'anytls');
    expect(proxy['server'], 'anytls.example.com');
    expect(proxy['port'], 8443);
    expect(proxy['username'], 'user');
    expect(proxy['password'], 'pass');
    expect(proxy['udp'], isTrue);
    expect(proxy['sni'], 'sni.example.com');
    expect(proxy['fingerprint'], 'fp-value');
    expect(proxy['skip-cert-verify'], isTrue);
  });

  test('Dart fallback parses generic proxy list JSON arrays', () {
    const text = '''
[
  {"protocol": "socks5", "ip": "208.102.51.6", "port": 58208},
  {"proxy": "socks4://72.49.49.11:31034", "protocol": "socks4", "ip": "72.49.49.11", "port": 31034},
  {"protocol": "http", "ip": "83.222.18.131", "port": 8080},
  {"proxy": "http://84.17.47.150:9002", "protocol": "https"}
]
''';

    final proxies = FreeNodesService().parseProxies(text);

    expect(proxies, hasLength(4));
    expect(proxies[0]['name'], 'socks5-208.102.51.6:58208');
    expect(proxies[0]['type'], 'socks5');
    expect(proxies[1]['name'], 'socks5-72.49.49.11:31034');
    expect(proxies[1]['type'], 'socks5');
    expect(proxies[2]['name'], 'http-83.222.18.131:8080');
    expect(proxies[2]['type'], 'http');
    expect(proxies[3]['server'], '84.17.47.150');
    expect(proxies[3]['type'], 'http');
  });

  test('Dart fallback parses WireGuard URI subscriptions', () {
    final service = FreeNodesService(fetcher: (_) async => '');

    final proxies = service.parseProxies(
      'wireguard://private-key-value@wg.example.com:2480?public-key=public-key-value&pre-shared-key=psk-value&ip=172.16.0.2&ipv6=fd01%3A5ca1%3Aab1e%3A80fa%3Aab85%3A6eea%3A213f%3Af4a5&udp=true&reserved=U4An&mtu=1280&persistent-keepalive=25&allowed-ips=0.0.0.0%2F0%2C%3A%3A%2F0&dns=1.1.1.1%2C8.8.8.8&remote-dns-resolve=true#WG%20Node',
    );

    expect(proxies, hasLength(1));
    final proxy = proxies.single;
    expect(proxy['name'], 'WG Node');
    expect(proxy['type'], 'wireguard');
    expect(proxy['server'], 'wg.example.com');
    expect(proxy['port'], 2480);
    expect(proxy['private-key'], 'private-key-value');
    expect(proxy['public-key'], 'public-key-value');
    expect(proxy['pre-shared-key'], 'psk-value');
    expect(proxy['ip'], '172.16.0.2');
    expect(proxy['ipv6'], 'fd01:5ca1:ab1e:80fa:ab85:6eea:213f:f4a5');
    expect(proxy['udp'], isTrue);
    expect(proxy['reserved'], 'U4An');
    expect(proxy['mtu'], 1280);
    expect(proxy['persistent-keepalive'], 25);
    expect(proxy['allowed-ips'], ['0.0.0.0/0', '::/0']);
    expect(proxy['dns'], ['1.1.1.1', '8.8.8.8']);
    expect(proxy['remote-dns-resolve'], isTrue);
  });

  test('Dart fallback parses MASQUE URI subscriptions', () {
    final service = FreeNodesService(fetcher: (_) async => '');

    final proxies = service.parseProxies(
      'masque://masque.example.com:443?private-key=private-key-value&public-key=public-key-value&ip=172.16.0.2&ipv6=2606%3A4700%3A110%3A84c0%3A163a%3A4914%3Aa0ad%3A3342&uri=https%3A%2F%2Fexample.com%2Fmasque&sni=example.com&mtu=1280&udp=true&skip-cert-verify=true&network=tcp&congestion-controller=bbr&cwnd=32&bbr-profile=standard&remote-dns-resolve=true&dns=1.1.1.1%2C8.8.8.8#MASQUE%20Node',
    );

    expect(proxies, hasLength(1));
    final proxy = proxies.single;
    expect(proxy['name'], 'MASQUE Node');
    expect(proxy['type'], 'masque');
    expect(proxy['server'], 'masque.example.com');
    expect(proxy['port'], 443);
    expect(proxy['private-key'], 'private-key-value');
    expect(proxy['public-key'], 'public-key-value');
    expect(proxy['ip'], '172.16.0.2');
    expect(proxy['ipv6'], '2606:4700:110:84c0:163a:4914:a0ad:3342');
    expect(proxy['uri'], 'https://example.com/masque');
    expect(proxy['sni'], 'example.com');
    expect(proxy['mtu'], 1280);
    expect(proxy['udp'], isTrue);
    expect(proxy['skip-cert-verify'], isTrue);
    expect(proxy['network'], 'tcp');
    expect(proxy['congestion-controller'], 'bbr');
    expect(proxy['cwnd'], 32);
    expect(proxy['bbr-profile'], 'standard');
    expect(proxy['remote-dns-resolve'], isTrue);
    expect(proxy['dns'], ['1.1.1.1', '8.8.8.8']);
  });

  test('Dart fallback parses TrustTunnel URI subscriptions', () {
    final service = FreeNodesService(fetcher: (_) async => '');

    final proxies = service.parseProxies(
      'trusttunnel://user:pass@tt.example.com:443?alpn=h2%2Chttp%2F1.1&sni=example.com&client-fingerprint=chrome&skip-cert-verify=true&fingerprint=sha256-value&certificate=cert-value&private-key=key-value&udp=true&health-check=true&quic=true&congestion-controller=bbr&cwnd=64&bbr-profile=aggressive&max-connections=8&min-streams=5&max-streams=16#TrustTunnel%20Node',
    );

    expect(proxies, hasLength(1));
    final proxy = proxies.single;
    expect(proxy['name'], 'TrustTunnel Node');
    expect(proxy['type'], 'trusttunnel');
    expect(proxy['server'], 'tt.example.com');
    expect(proxy['port'], 443);
    expect(proxy['username'], 'user');
    expect(proxy['password'], 'pass');
    expect(proxy['alpn'], ['h2', 'http/1.1']);
    expect(proxy['sni'], 'example.com');
    expect(proxy['client-fingerprint'], 'chrome');
    expect(proxy['skip-cert-verify'], isTrue);
    expect(proxy['fingerprint'], 'sha256-value');
    expect(proxy['certificate'], 'cert-value');
    expect(proxy['private-key'], 'key-value');
    expect(proxy['udp'], isTrue);
    expect(proxy['health-check'], isTrue);
    expect(proxy['quic'], isTrue);
    expect(proxy['congestion-controller'], 'bbr');
    expect(proxy['cwnd'], 64);
    expect(proxy['bbr-profile'], 'aggressive');
    expect(proxy['max-connections'], 8);
    expect(proxy['min-streams'], 5);
    expect(proxy['max-streams'], 16);
  });

  test('Dart fallback parses Mieru URI subscriptions', () {
    final service = FreeNodesService(fetcher: (_) async => '');

    final proxies = service.parseProxies(
      'mierus://user:pass@mieru.example.com?handshake-mode=HANDSHAKE_NO_WAIT&multiplexing=MULTIPLEXING_HIGH&port=6666&port=9998-9999&profile=default&protocol=TCP&protocol=UDP&traffic-pattern=CCoQARoECAEQCiIYCAMQASoIMDAwMTAyMDMqCDA0MDUwNjA3#Mieru\n'
      'mieru://single:secret@single.example.com?port=2999&protocol=TCP#Single',
    );

    expect(proxies, hasLength(3));
    final first = proxies[0];
    expect(first['name'], 'Mieru:6666/TCP');
    expect(first['type'], 'mieru');
    expect(first['server'], 'mieru.example.com');
    expect(first['port'], 6666);
    expect(first['transport'], 'TCP');
    expect(first['udp'], isTrue);
    expect(first['username'], 'user');
    expect(first['password'], 'pass');
    expect(first['multiplexing'], 'MULTIPLEXING_HIGH');
    expect(first['handshake-mode'], 'HANDSHAKE_NO_WAIT');
    expect(
      first['traffic-pattern'],
      'CCoQARoECAEQCiIYCAMQASoIMDAwMTAyMDMqCDA0MDUwNjA3',
    );

    final second = proxies[1];
    expect(second['name'], 'Mieru:9998-9999/UDP');
    expect(second['port-range'], '9998-9999');
    expect(second['transport'], 'UDP');

    final alias = proxies[2];
    expect(alias['name'], 'Single:2999/TCP');
    expect(alias['type'], 'mieru');
    expect(alias['server'], 'single.example.com');
    expect(alias['port'], 2999);
    expect(alias['transport'], 'TCP');
    expect(alias['username'], 'single');
    expect(alias['password'], 'secret');
  });

  test('Dart fallback preserves VLESS WebSocket URI options', () {
    final service = FreeNodesService(fetcher: (_) async => '');

    final proxies = service.parseProxies(
      'vless://00000000-0000-0000-0000-000000000000@ws.example.com:443?security=tls&type=ws&path=%2Fedge&host=cdn.example.com&sni=sni.example.com&packetEncoding=packet#VLESS%20WS',
    );

    expect(proxies, hasLength(1));
    final proxy = proxies.single;
    expect(proxy['name'], 'VLESS WS');
    expect(proxy['type'], 'vless');
    expect(proxy['server'], 'ws.example.com');
    expect(proxy['port'], 443);
    expect(proxy['uuid'], '00000000-0000-0000-0000-000000000000');
    expect(proxy['network'], 'ws');
    expect(proxy['tls'], isTrue);
    expect(proxy['sni'], 'sni.example.com');
    expect(proxy['servername'], 'sni.example.com');
    expect(proxy['client-fingerprint'], 'chrome');
    expect(proxy['udp'], isTrue);
    expect(proxy['packet-addr'], isTrue);
    expect(proxy.containsKey('xudp'), isFalse);
    expect(proxy['ws-opts'], {
      'path': '/edge',
      'headers': {'Host': 'cdn.example.com'},
    });
  });

  test('Dart fallback preserves Trojan gRPC URI options', () {
    final service = FreeNodesService(fetcher: (_) async => '');

    final proxies = service.parseProxies(
      'trojan://password@trojan-grpc.example.com:443?security=tls&type=grpc&serviceName=trojan-service&sni=trojan-sni.example.com&alpn=h2%2Chttp%2F1.1&allowInsecure=1#Trojan%20gRPC',
    );

    expect(proxies, hasLength(1));
    final proxy = proxies.single;
    expect(proxy['name'], 'Trojan gRPC');
    expect(proxy['type'], 'trojan');
    expect(proxy['server'], 'trojan-grpc.example.com');
    expect(proxy['port'], 443);
    expect(proxy['password'], 'password');
    expect(proxy['network'], 'grpc');
    expect(proxy['tls'], isTrue);
    expect(proxy['sni'], 'trojan-sni.example.com');
    expect(proxy['servername'], 'trojan-sni.example.com');
    expect(proxy['client-fingerprint'], 'chrome');
    expect(proxy['skip-cert-verify'], isTrue);
    expect(proxy['alpn'], ['h2', 'http/1.1']);
    expect(proxy['grpc-opts'], {'grpc-service-name': 'trojan-service'});
  });

  test('Dart fallback parses VLESS base64 host URI subscriptions', () {
    final service = FreeNodesService(fetcher: (_) async => '');
    final encodedHost = base64Url.encode(
      utf8.encode('base64-host.example.com:443'),
    );

    final proxies = service.parseProxies(
      'vless://00000000-0000-0000-0000-000000000000@$encodedHost?security=tls&type=ws#VLESS%20Base64%20Host',
    );

    expect(proxies, hasLength(1));
    final proxy = proxies.single;
    expect(proxy['name'], 'VLESS Base64 Host');
    expect(proxy['type'], 'vless');
    expect(proxy['server'], 'base64-host.example.com');
    expect(proxy['port'], 443);
    expect(proxy['uuid'], '00000000-0000-0000-0000-000000000000');
    expect(proxy['network'], 'ws');
    expect(proxy['tls'], isTrue);
  });

  test('fetch preserves old date test groups and writes current day', () async {
    const catalog = '''
{
  "lookbackDays": 1,
  "historyTimeoutHours": 10000,
  "sources": [
    {
      "id": "test",
      "seed": "https://example.com/",
      "rank": 0,
      "configTemplates": ["https://example.com/{yyyymmdd}.yaml"]
    }
  ]
}
''';
    const existingConfig = '''
proxies:
  - name: old-node
    type: ss
    server: old.example.com
    port: 443
    cipher: aes-128-gcm
    password: old-pass
proxy-groups:
  - name: "2026-05-30"
    type: url-test
    proxies:
      - old-node
''';
    final now = DateTime.now();
    final today =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    final service = FreeNodesService(
      sourceCatalogJson: catalog,
      fetcher: (_) async => '''
proxies:
  - name: new-node
    type: ss
    server: new.example.com
    port: 443
    cipher: aes-128-gcm
    password: new-pass
''',
    );

    final result = await service.fetchMergedConfig(
      existingConfigText: existingConfig,
    );
    final yamlText = utf8.decode(result.bytes);

    expect(result.proxyCount, 2);
    expect(yamlText, contains('name: "日期 $today"'));
    expect(yamlText, contains('name: "日期 2026-05-30"'));
    expect(yamlText, isNot(contains('name: "优选节点"')));
    expect(yamlText, isNot(contains('name: "2026-05-30"')));
    expect(yamlText, contains('old-node'));
    expect(yamlText, contains('new-node'));
  });

  test('normalization keeps abnormal ISO old date groups switchable', () async {
    const existingConfig = '''
proxies:
  - name: old-node
    type: ss
    server: old.example.com
    port: 443
    cipher: aes-128-gcm
    password: old-pass
proxy-groups:
  - name: "2026-06-19T00:00:00Z"
    type: url-test
    proxies:
      - old-node
''';
    final service = FreeNodesService(fetcher: (_) async => '');

    final result = await service.normalizeExistingConfigText(existingConfig);
    final yamlText = utf8.decode(result!.bytes);

    expect(yamlText, isNot(contains('2026-06-19T00:00:00Z')));
    expect(yamlText, contains('name: "日期 2026-06-19"'));
    expect(yamlText, isNot(contains('name: "优选节点"')));
  });

  test('normalization removes non free-node test categories', () async {
    const existingConfig = '''
proxies:
  - name: test-node
    type: ss
    server: test.example.com
    port: 443
    cipher: aes-128-gcm
    password: test-pass
proxy-groups:
  - name: "FREE-NODES"
    type: url-test
    proxies:
      - test-node
  - name: "测试分类"
    type: url-test
    proxies:
      - test-node
''';
    final service = FreeNodesService(fetcher: (_) async => '');

    final result = await service.normalizeExistingConfigText(existingConfig);
    final yamlText = utf8.decode(result!.bytes);

    expect(yamlText, contains('name: "FREE-NODES"'));
    expect(yamlText, isNot(contains('测试分类')));
  });

  test(
    'visible free node groups are filtered when only date markers remain',
    () {
      expect(
        shouldFilterVisibleFreeNodesGroups(
          groups: const [
            Group(type: GroupType.Selector, name: '2026-06-19T00:00:00Z'),
            Group(type: GroupType.Selector, name: 'DIRECT'),
          ],
        ),
        isTrue,
      );
    },
  );

  test('exposes free node source auto update interval options', () async {
    SharedPreferences.setMockInitialValues({});
    preferences.sharedPreferencesCompleter = Completer<SharedPreferences?>()
      ..complete(await SharedPreferences.getInstance());
    const catalog = '''
{
  "sources": [
    {
      "id": "interval",
      "label": "Interval Source",
      "seed": "https://interval.example.com/",
      "rank": 0,
      "updateIntervalHours": 6,
      "staleTimeoutHours": 18,
      "configTemplates": ["https://interval.example.com/config.yaml"]
    }
  ]
}
''';
    final service = FreeNodesService(sourceCatalogJson: catalog);

    final options = await service.getSourceOptions();

    expect(options, hasLength(1));
    expect(options.single.updateIntervalHours, 6);
    expect(options.single.updateIntervalLabel, '6 小时');
    expect(options.single.staleTimeoutHours, 18);
    expect(options.single.staleTimeoutLabel, '18 小时');

    final preferenceState = await service.getPreferenceState();
    expect(preferenceState.autoPrefer, false);
    await service.saveAutoPrefer(true);
    expect((await service.getPreferenceState()).autoPrefer, true);
  });

  test('records automatic prefer once per day', () async {
    SharedPreferences.setMockInitialValues({});
    preferences.sharedPreferencesCompleter = Completer<SharedPreferences?>()
      ..complete(await SharedPreferences.getInstance());
    final service = FreeNodesService(fetcher: (_) async => '');
    final firstDay = DateTime(2026, 6, 13, 9);
    final nextDay = DateTime(2026, 6, 14, 1);

    expect(await service.wasAutoPreferredToday(now: firstDay), false);
    await service.markAutoPreferredToday(now: firstDay);
    expect(await service.wasAutoPreferredToday(now: firstDay), true);
    expect(await service.wasAutoPreferredToday(now: nextDay), false);
  });

  test('updates only sources whose individual interval is due', () async {
    final now = DateTime(2026, 6, 19, 12);
    const catalog = '''
{
  "sources": [
    {
      "id": "fast",
      "label": "Fast Source",
      "seed": "https://fast.example.com/",
      "rank": 0,
      "updateIntervalHours": 6,
      "configTemplates": ["https://fast.example.com/config.yaml"]
    },
    {
      "id": "daily",
      "label": "Daily Source",
      "seed": "https://daily.example.com/",
      "rank": 1,
      "updateIntervalHours": 24,
      "configTemplates": ["https://daily.example.com/config.yaml"]
    }
  ]
}
''';
    await preferences.sharedPreferencesCompleter.future;
    SharedPreferences.setMockInitialValues({
      freeNodesFetchConcurrencyKey: 1,
      freeNodesFetchTimesKey: json.encode({
        'fast': now.subtract(const Duration(hours: 7)).toIso8601String(),
        'daily': now.subtract(const Duration(hours: 12)).toIso8601String(),
      }),
    });
    preferences.sharedPreferencesCompleter = Completer<SharedPreferences?>()
      ..complete(await SharedPreferences.getInstance());
    final fetchedUrls = <String>[];
    final service = FreeNodesService(
      sourceCatalogJson: catalog,
      fetcher: (url) async {
        fetchedUrls.add(url);
        if (url.contains('daily')) {
          throw StateError('daily source should not be fetched');
        }
        return '''
proxies:
  - name: fast-node
    type: ss
    server: fast.example.com
    port: 443
    cipher: aes-128-gcm
    password: pass
''';
      },
    );

    final dueSources = await service.getDueSourceIds(now: now);
    final result = await service.fetchMergedConfig(sourceIds: dueSources);
    final yamlText = utf8.decode(result.bytes);

    expect(dueSources, {'fast'});
    expect(fetchedUrls, everyElement(contains('fast.example.com')));
    expect(yamlText, contains('fast-node'));
    expect(yamlText, isNot(contains('daily')));
  });

  test('each source becomes due exactly at its persisted interval', () async {
    const catalog = '''
{
  "sources": [
    {
      "id": "fast-four-hours",
      "label": "Fast Four Hours",
      "seed": "https://fast-four-hours.example.com/",
      "rank": 0,
      "updateIntervalHours": 4,
      "configTemplates": ["https://fast-four-hours.example.com/config.yaml"]
    },
    {
      "id": "daily",
      "label": "Daily",
      "seed": "https://daily.example.com/",
      "rank": 1,
      "updateIntervalHours": 24,
      "configTemplates": ["https://daily.example.com/config.yaml"]
    }
  ]
}
''';
    await preferences.sharedPreferencesCompleter.future;
    SharedPreferences.setMockInitialValues({freeNodesFetchConcurrencyKey: 2});
    preferences.sharedPreferencesCompleter = Completer<SharedPreferences?>()
      ..complete(await SharedPreferences.getInstance());
    final service = FreeNodesService(
      sourceCatalogJson: catalog,
      fetcher: (_) async => '''
proxies:
  - name: fast-node
    type: ss
    server: fast-four-hours.example.com
    port: 443
    cipher: aes-128-gcm
    password: pass
''',
    );

    await service.fetchMergedConfig();
    final persistedService = FreeNodesService(
      sourceCatalogJson: catalog,
      fetcher: (_) async => '',
    );
    final options = await persistedService.getSourceOptions();
    final fastLastFetchTime = options
        .singleWhere((option) => option.id == 'fast-four-hours')
        .lastFetchTime;
    final dailyLastFetchTime = options
        .singleWhere((option) => option.id == 'daily')
        .lastFetchTime;

    expect(fastLastFetchTime, isNotNull);
    expect(dailyLastFetchTime, isNotNull);
    expect(
      await persistedService.getDueSourceIds(
        now: fastLastFetchTime!
            .add(const Duration(hours: 4))
            .subtract(const Duration(milliseconds: 1)),
      ),
      isEmpty,
    );
    expect(
      await persistedService.getDueSourceIds(
        now: fastLastFetchTime.add(const Duration(hours: 4)),
      ),
      {'fast-four-hours'},
    );
    expect(
      await persistedService.getDueSourceIds(
        now: dailyLastFetchTime!.add(const Duration(hours: 24)),
      ),
      contains('daily'),
      reason: '24-hour sources use their own last fetch time, not app entry',
    );
  });

  test('concurrent source attempts persist every source fetch time', () async {
    const catalog = '''
{
  "sources": [
    {
      "id": "fast-a",
      "label": "Fast A",
      "seed": "https://fast-a.example.com/",
      "rank": 0,
      "updateIntervalHours": 4,
      "configTemplates": ["https://fast-a.example.com/config.yaml"]
    },
    {
      "id": "fast-b",
      "label": "Fast B",
      "seed": "https://fast-b.example.com/",
      "rank": 1,
      "updateIntervalHours": 4,
      "configTemplates": ["https://fast-b.example.com/config.yaml"]
    }
  ]
}
''';
    await preferences.sharedPreferencesCompleter.future;
    SharedPreferences.setMockInitialValues({freeNodesFetchConcurrencyKey: 2});
    preferences.sharedPreferencesCompleter = Completer<SharedPreferences?>()
      ..complete(await SharedPreferences.getInstance());
    final service = FreeNodesService(
      sourceCatalogJson: catalog,
      fetcher: (url) async {
        await Future<void>.delayed(
          Duration(milliseconds: url.contains('fast-a') ? 5 : 1),
        );
        final suffix = url.contains('fast-a') ? 'a' : 'b';
        return '''
proxies:
  - name: fast-$suffix
    type: ss
    server: fast-$suffix.example.com
    port: 443
    cipher: aes-128-gcm
    password: pass
''';
      },
    );

    await service.fetchMergedConfig();
    final options = await service.getSourceOptions();

    expect(
      options.where((option) => option.lastFetchTime != null).map((e) => e.id),
      containsAll(<String>['fast-a', 'fast-b']),
    );
  });

  test('fetch drops stale date groups before prefer cleanup', () async {
    const catalog = '''
{
  "lookbackDays": 1,
  "historyTimeoutHours": 0,
  "sources": [
    {
      "id": "fresh",
      "label": "Fresh",
      "seed": "https://fresh.example.com/",
      "rank": 0,
      "configTemplates": ["https://fresh.example.com/config.yaml"]
    }
  ]
}
''';
    const existingConfig = '''
proxies:
  - name: stale-node
    type: ss
    server: stale.example.com
    port: 443
    cipher: aes-128-gcm
    password: stale-pass
proxy-groups:
  - name: "2026-05-30"
    type: url-test
    proxies:
      - stale-node
''';
    final service = FreeNodesService(
      sourceCatalogJson: catalog,
      fetcher: (_) async => '''
proxies:
  - name: today-node
    type: ss
    server: today.example.com
    port: 443
    cipher: aes-128-gcm
    password: today-pass
''',
    );

    final result = await service.fetchMergedConfig(
      existingConfigText: existingConfig,
    );
    final yamlText = utf8.decode(result.bytes);

    expect(result.proxyCount, 1);
    expect(yamlText, contains('today-node'));
    expect(yamlText, isNot(contains('stale-node')));

    final cleaned = await service.preferConfigText(
      yamlText,
      deleteExpiredGroups: true,
    );
    final cleanedYamlText = utf8.decode(cleaned.bytes);

    expect(cleaned.afterCount, 1);
    expect(cleanedYamlText, contains('today-node'));
    expect(cleanedYamlText, isNot(contains('stale-node')));
  });

  test(
    'preserves old date nodes as switchable groups when auto prefer is disabled',
    () async {
      SharedPreferences.setMockInitialValues({freeNodesAutoPreferKey: false});
      preferences.sharedPreferencesCompleter = Completer<SharedPreferences?>()
        ..complete(await SharedPreferences.getInstance());
      const catalog = '''
{
  "lookbackDays": 1,
  "historyTimeoutHours": 10000,
  "sources": [
    {
      "id": "fresh",
      "label": "Fresh",
      "seed": "https://fresh.example.com/",
      "rank": 0,
      "configTemplates": ["https://fresh.example.com/config.yaml"]
    }
  ]
}
''';
      const existingConfig = '''
proxies:
  - name: old-node
    type: ss
    server: old.example.com
    port: 443
    cipher: aes-128-gcm
    password: old-pass
proxy-groups:
  - name: "2026-05-30"
    type: url-test
    proxies:
      - old-node
''';
      final service = FreeNodesService(
        sourceCatalogJson: catalog,
        fetcher: (_) async => '''
proxies:
  - name: today-node
    type: ss
    server: today.example.com
    port: 443
    cipher: aes-128-gcm
    password: today-pass
''',
      );

      final result = await service.fetchMergedConfig(
        existingConfigText: existingConfig,
      );
      final yamlText = utf8.decode(result.bytes);

      expect(result.proxyCount, 2);
      expect(yamlText, contains('name: "日期 2026-05-30"'));
      expect(yamlText, contains('old-node'));
      expect(yamlText, isNot(contains('name: "优选节点"')));
    },
  );

  test('auto prefer is applied after fetch instead of during fetch', () async {
    SharedPreferences.setMockInitialValues({freeNodesAutoPreferKey: true});
    preferences.sharedPreferencesCompleter = Completer<SharedPreferences?>()
      ..complete(await SharedPreferences.getInstance());
    const catalog = '''
{
  "lookbackDays": 1,
  "historyTimeoutHours": 10000,
  "sources": [
    {
      "id": "fresh",
      "label": "Fresh",
      "seed": "https://fresh.example.com/",
      "rank": 0,
      "configTemplates": ["https://fresh.example.com/config.yaml"]
    }
  ]
}
''';
    const existingConfig = '''
proxies:
  - name: old-node
    type: ss
    server: old.example.com
    port: 443
    cipher: aes-128-gcm
    password: old-pass
proxy-groups:
  - name: "2026-05-30"
    type: url-test
    proxies:
      - old-node
''';
    final service = FreeNodesService(
      sourceCatalogJson: catalog,
      fetcher: (_) async => '''
proxies:
  - name: today-node
    type: ss
    server: today.example.com
    port: 443
    cipher: aes-128-gcm
    password: today-pass
''',
    );

    final fetched = await service.fetchMergedConfig(
      existingConfigText: existingConfig,
    );
    final fetchedYamlText = utf8.decode(fetched.bytes);

    expect(fetchedYamlText, isNot(contains('name: "优选节点"')));

    final preferred = await service.preferConfigText(fetchedYamlText);
    final preferredYamlText = utf8.decode(preferred.bytes);

    expect(preferredYamlText, isNot(contains('name: "优选节点"')));
    expect(preferred.afterCount, fetched.proxyCount);
  });

  test('fetch writes source groups for different free node sources', () async {
    const catalog = '''
{
  "lookbackDays": 1,
  "historyTimeoutHours": 10000,
  "sources": [
    {
      "id": "source-a",
      "label": "Source A",
      "seed": "https://source-a.example.com/",
      "rank": 0,
      "rawCandidates": ["https://source-a.example.com/config.yaml"]
    },
    {
      "id": "source-b",
      "label": "Source B",
      "seed": "https://source-b.example.com/",
      "rank": 1,
      "rawCandidates": ["https://source-b.example.com/config.yaml"]
    }
  ]
}
''';
    final service = FreeNodesService(
      sourceCatalogJson: catalog,
      fetcher: (url) async {
        if (url.contains('source-a')) {
          return '''
proxies:
  - name: source-a-node
    type: ss
    server: a.example.com
    port: 443
    cipher: aes-128-gcm
    password: pass-a
''';
        }
        return '''
proxies:
  - name: source-b-node
    type: ss
    server: b.example.com
    port: 443
    cipher: aes-128-gcm
    password: pass-b
''';
      },
    );

    final result = await service.fetchMergedConfig();
    final yamlText = utf8.decode(result.bytes);

    expect(result.proxyCount, 2);
    expect(yamlText, contains('name: "来源 Source A"'));
    expect(yamlText, contains('name: "来源 Source B"'));
    expect(yamlText, contains('source-a-node'));
    expect(yamlText, contains('source-b-node'));
    final value = loadYaml(yamlText) as YamlMap;
    final groups = (value['proxy-groups'] as YamlList).cast<YamlMap>();
    final sourceA = groups.singleWhere(
      (group) => group['name'] == '来源 Source A',
    );
    final sourceB = groups.singleWhere(
      (group) => group['name'] == '来源 Source B',
    );
    expect((sourceA['proxies'] as YamlList).cast<String>(), ['source-a-node']);
    expect((sourceB['proxies'] as YamlList).cast<String>(), ['source-b-node']);
    expect(
      groups.where((group) => group['type'] == 'url-test'),
      everyElement(predicate<YamlMap>((group) => group['lazy'] == true)),
      reason: 'inactive categories must not start a full background delay test',
    );
  });

  test(
    'duplicate source labels still produce one isolated group per source',
    () async {
      const catalog = '''
{
  "lookbackDays": 1,
  "historyTimeoutHours": 10000,
  "sources": [
    {
      "id": "source-a",
      "label": "Shared Label",
      "seed": "https://source-a.example.com/",
      "rank": 0,
      "rawCandidates": ["https://source-a.example.com/config.yaml"]
    },
    {
      "id": "source-b",
      "label": "Shared Label",
      "seed": "https://source-b.example.com/",
      "rank": 1,
      "rawCandidates": ["https://source-b.example.com/config.yaml"]
    }
  ]
}
''';
      final service = FreeNodesService(
        sourceCatalogJson: catalog,
        fetcher: (url) async =>
            '''
proxies:
  - name: ${url.contains('source-a') ? 'source-a-node' : 'source-b-node'}
    type: ss
    server: ${url.contains('source-a') ? 'a.example.com' : 'b.example.com'}
    port: 443
    cipher: aes-128-gcm
    password: pass
''',
      );

      final result = await service.fetchMergedConfig();
      final value = loadYaml(utf8.decode(result.bytes)) as YamlMap;
      final groups = (value['proxy-groups'] as YamlList).cast<YamlMap>();
      final sourceA = groups.singleWhere(
        (group) => group['name'] == '来源 Shared Label · source-a',
      );
      final sourceB = groups.singleWhere(
        (group) => group['name'] == '来源 Shared Label · source-b',
      );

      expect((sourceA['proxies'] as YamlList).cast<String>(), [
        'source-a-node',
      ]);
      expect((sourceB['proxies'] as YamlList).cast<String>(), [
        'source-b-node',
      ]);
      expect(sourceA['lazy'], true);
      expect(sourceB['lazy'], true);

      final refreshed = await service.fetchMergedConfig(
        existingConfigText: utf8.decode(result.bytes),
        sourceIds: const {'source-a'},
      );
      final refreshedValue = loadYaml(utf8.decode(refreshed.bytes)) as YamlMap;
      final refreshedGroups = (refreshedValue['proxy-groups'] as YamlList)
          .cast<YamlMap>();
      expect(
        (refreshedGroups.singleWhere(
                  (group) => group['name'] == '来源 Shared Label · source-a',
                )['proxies']
                as YamlList)
            .cast<String>(),
        ['source-a-node'],
      );
      expect(
        (refreshedGroups.singleWhere(
                  (group) => group['name'] == '来源 Shared Label · source-b',
                )['proxies']
                as YamlList)
            .cast<String>(),
        ['source-b-node'],
        reason: 'partial refresh must preserve the other same-label source',
      );
    },
  );

  test(
    'deduplicates one physical proxy across sources while preserving source groups',
    () async {
      final catalog = json.encode({
        'lookbackDays': 1,
        'historyTimeoutHours': 10000,
        'sources': [
          {
            'id': 'source-a',
            'label': 'Source A',
            'seed': 'https://source-a.example.com/',
            'rank': 0,
            'rawCandidates': ['https://source-a.example.com/config.yaml'],
          },
          {
            'id': 'source-b',
            'label': 'Source   B',
            'seed': 'https://source-b.example.com/',
            'rank': 1,
            'rawCandidates': ['https://source-b.example.com/config.yaml'],
          },
        ],
      });
      const sharedProxy = '''
proxies:
  - name: shared-node
    type: socks5
    server: shared.example.com
    port: 1080
''';
      final service = FreeNodesService(
        sourceCatalogJson: catalog,
        fetcher: (_) async => sharedProxy,
      );

      final result = await service.fetchMergedConfig();
      final value = loadYaml(utf8.decode(result.bytes)) as YamlMap;
      final proxies = (value['proxies'] as YamlList).cast<YamlMap>();
      final groups = (value['proxy-groups'] as YamlList).cast<YamlMap>();
      final sourceA = groups.singleWhere(
        (group) => group['name'] == '来源 Source A',
      );
      final sourceB = groups.singleWhere(
        (group) => group['name'] == '来源 Source B',
      );

      expect(result.proxyCount, 1);
      expect(proxies, hasLength(1));
      expect(proxies.single['name'], 'shared-node');
      expect((sourceA['proxies'] as YamlList).cast<String>(), ['shared-node']);
      expect((sourceB['proxies'] as YamlList).cast<String>(), ['shared-node']);
      expect(
        groups.where((group) => group['name'] == '来源 Source   B'),
        isEmpty,
        reason: 'source membership labels must collapse repeated whitespace',
      );

      final refreshed = await service.fetchMergedConfig(
        existingConfigText: utf8.decode(result.bytes),
        sourceIds: const {'source-a'},
      );
      final refreshedValue = loadYaml(utf8.decode(refreshed.bytes)) as YamlMap;
      final refreshedProxies = (refreshedValue['proxies'] as YamlList)
          .cast<YamlMap>();
      final refreshedGroups = (refreshedValue['proxy-groups'] as YamlList)
          .cast<YamlMap>();

      expect(refreshed.proxyCount, 1);
      expect(refreshedProxies, hasLength(1));
      expect(
        (refreshedGroups.singleWhere(
                  (group) => group['name'] == '来源 Source A',
                )['proxies']
                as YamlList)
            .cast<String>(),
        ['shared-node'],
      );
      expect(
        (refreshedGroups.singleWhere(
                  (group) => group['name'] == '来源 Source B',
                )['proxies']
                as YamlList)
            .cast<String>(),
        ['shared-node'],
      );
    },
  );
  test('all 60 default sources produce 60 isolated source groups', () async {
    final sourceIds = List.generate(60, (index) => 'source-$index');
    final catalog = json.encode({
      'lookbackDays': 1,
      'historyTimeoutHours': 10000,
      'defaultSourceIds': sourceIds,
      'sources': [
        for (var index = 0; index < sourceIds.length; index++)
          {
            'id': sourceIds[index],
            'label': 'Source $index',
            'seed': 'https://source-$index.example.com/',
            'rank': index,
            'rawCandidates': ['https://source-$index.example.com/config.yaml'],
          },
      ],
    });
    final service = FreeNodesService(
      sourceCatalogJson: catalog,
      fetcher: (url) async {
        final host = Uri.parse(url).host;
        final sourceIndex = RegExp(
          r'^source-(\d+)\.',
        ).firstMatch(host)?.group(1);
        if (sourceIndex == null) return '';
        return '''
proxies:
  - name: source-$sourceIndex-node
    type: ss
    server: node-$sourceIndex.example.com
    port: 443
    cipher: aes-128-gcm
    password: pass-$sourceIndex
''';
      },
    );

    final result = await service.fetchMergedConfig();
    final value = loadYaml(utf8.decode(result.bytes)) as YamlMap;
    final groups = (value['proxy-groups'] as YamlList).cast<YamlMap>();
    final sourceGroups = groups
        .where((group) => group['name'].toString().startsWith('来源 Source '))
        .toList(growable: false);

    expect(sourceGroups, hasLength(60));
    expect(sourceGroups.map((group) => group['name']).toSet(), {
      for (var index = 0; index < 60; index++) '来源 Source $index',
    });
    for (var index = 0; index < 60; index++) {
      final group = sourceGroups.singleWhere(
        (item) => item['name'] == '来源 Source $index',
      );
      expect((group['proxies'] as YamlList).cast<String>(), [
        'source-$index-node',
      ]);
    }
  });

  test(
    'fetch auto prefer keeps source categories separate from date switch main group',
    () async {
      SharedPreferences.setMockInitialValues({freeNodesAutoPreferKey: true});
      preferences.sharedPreferencesCompleter = Completer<SharedPreferences?>()
        ..complete(await SharedPreferences.getInstance());
      const catalog = '''
{
  "lookbackDays": 1,
  "historyTimeoutHours": 10000,
  "sources": [
    {
      "id": "source-a",
      "label": "Source A",
      "seed": "https://source-a.example.com/",
      "rank": 0,
      "rawCandidates": ["https://source-a.example.com/config.yaml"]
    },
    {
      "id": "source-b",
      "label": "Source B",
      "seed": "https://source-b.example.com/",
      "rank": 1,
      "rawCandidates": ["https://source-b.example.com/config.yaml"]
    }
  ]
}
''';
      final service = FreeNodesService(
        sourceCatalogJson: catalog,
        fetcher: (url) async {
          if (url.contains('source-a')) {
            return '''
proxies:
  - name: source-a-node
    type: ss
    server: a.example.com
    port: 443
    cipher: aes-128-gcm
    password: pass-a
''';
          }
          return '''
proxies:
  - name: source-b-node
    type: ss
    server: b.example.com
    port: 443
    cipher: aes-128-gcm
    password: pass-b
''';
        },
      );

      final result = await service.fetchMergedConfig();
      final yamlText = utf8.decode(result.bytes);
      final value = loadYaml(yamlText) as YamlMap;
      final groups = (value['proxy-groups'] as YamlList).cast<YamlMap>();
      final mainGroup = groups.singleWhere(
        (group) => group['name'] == freeNodesGroupName,
      );
      final mainProxies = (mainGroup['proxies'] as YamlList)
          .map((item) => item.toString())
          .toList(growable: false);

      expect(mainProxies, isNot(contains('来源 Source A')));
      expect(mainProxies, isNot(contains('来源 Source B')));
      expect(mainProxies.where((name) => name.startsWith('日期 ')), isNotEmpty);
      expect(mainProxies, isNot(contains('source-a-node')));
      expect(mainProxies, isNot(contains('source-b-node')));
    },
  );

  test('date switch groups include dates without source categories', () {
    final groups = [
      const Group(type: GroupType.Selector, name: freeNodesGroupName),
      const Group(type: GroupType.Selector, name: freeNodesTreasureGroupName),
      const Group(type: GroupType.Selector, name: '来源 Source A'),
      const Group(type: GroupType.Selector, name: '2026-06-19T00:00:00Z'),
      const Group(type: GroupType.Selector, name: '香港'),
    ];

    final names = freeNodesDateSwitchGroups(
      groups,
    ).map((group) => group.name).toList(growable: false);

    expect(names, ['日期 2026-06-19', freeNodesTreasureGroupName]);
  });

  test('visible free node categories include preferred and every source', () {
    final groups = [
      const Group(type: GroupType.Selector, name: freeNodesGroupName),
      const Group(type: GroupType.Selector, name: freeNodesTreasureGroupName),
      const Group(type: GroupType.Selector, name: '日期 2026-06-19'),
      const Group(type: GroupType.Selector, name: '来源 Source A'),
      const Group(type: GroupType.Selector, name: '来源 Source B'),
    ];

    final visible = normalizeVisibleFreeNodesGroups(groups);

    expect(visible.map((group) => group.name), [
      '来源 Source A',
      '来源 Source B',
      freeNodesTreasureGroupName,
    ]);
  });

  test(
    'same endpoint from different sources keeps one category per source',
    () async {
      const catalog = '''
{
  "lookbackDays": 0,
  "historyTimeoutHours": 72,
  "sources": [
    {
      "id": "source-a",
      "label": "Source A",
      "seed": "https://source-a.example.com/config.yaml",
      "rank": 0,
      "rawCandidates": ["https://source-a.example.com/config.yaml"]
    },
    {
      "id": "source-b",
      "label": "Source B",
      "seed": "https://source-b.example.com/config.yaml",
      "rank": 1,
      "rawCandidates": ["https://source-b.example.com/config.yaml"]
    }
  ]
}
''';
      const sharedEndpoint = '''
proxies:
  - name: shared
    type: ss
    server: shared.example.com
    port: 443
    cipher: aes-128-gcm
    password: pass
''';
      final service = FreeNodesService(
        sourceCatalogJson: catalog,
        fetcher: (_) async => sharedEndpoint,
      );

      final result = await service.fetchMergedConfig();
      final value = loadYaml(utf8.decode(result.bytes)) as YamlMap;
      final groupNames = (value['proxy-groups'] as YamlList)
          .cast<YamlMap>()
          .map((group) => group['name'].toString())
          .toList(growable: false);

      expect(groupNames, contains('来源 Source A'));
      expect(groupNames, contains('来源 Source B'));
    },
  );

  test(
    'free nodes auto update stays enabled after update metadata changes',
    () {
      final service = FreeNodesService();
      final profile = service.createProfile();

      expect(profile.autoUpdate, isTrue);

      final updated = applyFreeNodesUpdateMetadata(profile, 23);

      expect(updated.autoUpdate, isTrue);
      expect(updated.subscriptionInfo?.total, 23);
    },
  );

  test(
    'selected date or preferred group is exposed only after toolbar switch',
    () {
      final groups = [
        const Group(type: GroupType.Selector, name: freeNodesGroupName),
        const Group(type: GroupType.Selector, name: freeNodesTreasureGroupName),
        const Group(type: GroupType.Selector, name: '日期 2026-06-19'),
        const Group(type: GroupType.Selector, name: '来源 Source A'),
      ];

      final visible = normalizeVisibleFreeNodesGroups(
        groups,
        selectedGroupName: '日期 2026-06-19',
      );

      expect(visible.map((group) => group.name), [
        '来源 Source A',
        freeNodesTreasureGroupName,
        '日期 2026-06-19',
      ]);
    },
  );

  test('manual prefer keeps old date groups visible for switching', () async {
    const existingConfig = '''
proxies:
  - name: old-node
    type: ss
    server: old.example.com
    port: 443
    cipher: aes-128-gcm
    password: old-pass
proxy-groups:
  - name: "2026-05-30"
    type: url-test
    proxies:
      - old-node
''';
    final result = await FreeNodesService(
      fetcher: (_) async => '',
    ).preferConfigText(existingConfig, deleteExpiredGroups: false);
    final yamlText = utf8.decode(result.bytes);

    expect(result.removedCount, 0);
    expect(yamlText, contains('name: "日期 2026-05-30"'));
    expect(yamlText, isNot(contains('name: "优选节点"')));
    expect(yamlText, contains('old-node'));
  });

  test(
    'normalizes ISO timestamp date groups and keeps old categories switchable',
    () async {
      const existingConfig = '''
proxies:
  - name: iso-node
    type: ss
    server: iso.example.com
    port: 443
    cipher: aes-128-gcm
    password: iso-pass
proxy-groups:
  - name: "2026-06-19T00:00:00Z"
    type: url-test
    proxies:
      - iso-node
''';
      final result = await FreeNodesService(
        fetcher: (_) async => '',
      ).preferConfigText(existingConfig, deleteExpiredGroups: false);
      final yamlText = utf8.decode(result.bytes);

      expect(yamlText, contains('name: "日期 2026-06-19"'));
      expect(yamlText, isNot(contains('2026-06-19T00:00:00Z')));
      expect(yamlText, isNot(contains('name: "优选节点"')));
      expect(yamlText, contains('iso-node'));
    },
  );

  test(
    'normalizes existing local ISO groups and keeps old categories switchable',
    () async {
      const existingConfig = '''
proxies:
  - name: iso-node
    type: ss
    server: iso.example.com
    port: 443
    cipher: aes-128-gcm
    password: iso-pass
proxy-groups:
  - name: "2026-06-19T00:00:00Z"
    type: url-test
    proxies:
      - iso-node
''';

      final result = await FreeNodesService(
        fetcher: (_) async => '',
      ).normalizeExistingConfigText(existingConfig);
      final yamlText = result == null
          ? existingConfig
          : utf8.decode(result.bytes);

      expect(result?.proxyCount ?? 1, 1);
      expect(yamlText, contains('name: "日期 2026-06-19"'));
      expect(yamlText, isNot(contains('2026-06-19T00:00:00Z')));
      expect(yamlText, isNot(contains('name: "优选节点"')));
      expect(yamlText, contains('iso-node'));
    },
  );

  test(
    'keeps existing local old date groups when labels are already clean',
    () async {
      const existingConfig = '''
proxies:
  - name: old-node
    type: ss
    server: old.example.com
    port: 443
    cipher: aes-128-gcm
    password: old-pass
proxy-groups:
  - name: "日期 2025-01-01"
    type: url-test
    proxies:
      - old-node
''';

      final result = await FreeNodesService(
        fetcher: (_) async => '',
      ).normalizeExistingConfigText(existingConfig);
      final yamlText = result == null
          ? existingConfig
          : utf8.decode(result.bytes);

      expect(result?.proxyCount ?? 1, 1);
      expect(yamlText, contains('name: "日期 2025-01-01"'));
      expect(yamlText, isNot(contains('name: "优选节点"')));
      expect(yamlText, contains('old-node'));
    },
  );

  test('manual prefer rejects empty result before writing', () async {
    final service = FreeNodesService(fetcher: (_) async => '');

    expect(
      () => service.preferConfigText('proxy-groups: []'),
      throwsA(contains('已保留原配置')),
    );
  });

  test(
    'deleting an old date group moves its nodes to preferred only',
    () async {
      final now = DateTime.now();
      final today =
          '${now.year.toString().padLeft(4, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}';
      final existingConfig =
          '''
proxies:
  - name: old-node
    type: ss
    server: old.example.com
    port: 443
    cipher: aes-128-gcm
    password: old-pass
  - name: today-node
    type: ss
    server: today.example.com
    port: 443
    cipher: aes-128-gcm
    password: today-pass
proxy-groups:
  - name: "宝藏积累"
    type: url-test
    proxies:
      - old-node
  - name: "2026-05-30"
    type: url-test
    proxies:
      - old-node
  - name: "$today"
    type: url-test
    proxies:
      - today-node
''';

      final result = await FreeNodesService().deleteDateGroupConfigText(
        existingConfig,
        '2026-05-30',
      );
      final yamlText = utf8.decode(result.bytes);

      expect(result.affectedCount, 1);
      expect(yamlText, isNot(contains('name: "2026-05-30"')));
      expect(yamlText, contains('name: "优选节点"'));
      expect(yamlText, contains('old-node'));
      expect(yamlText, contains('name: "日期 $today"'));
    },
  );

  test('manual delete supports abnormal ISO date group names', () async {
    const existingConfig = '''
proxies:
  - name: iso-node
    type: ss
    server: iso.example.com
    port: 443
    cipher: aes-128-gcm
    password: iso-pass
proxy-groups:
  - name: "2026-06-19T00:00:00Z"
    type: url-test
    proxies:
      - iso-node
''';

    final result = await FreeNodesService().deleteDateGroupConfigText(
      existingConfig,
      '2026-06-19T00:00:00Z',
    );
    final yamlText = utf8.decode(result.bytes);

    expect(result.affectedCount, 1);
    expect(result.groupName, '日期 2026-06-19');
    expect(yamlText, isNot(contains('2026-06-19T00:00:00Z')));
    expect(yamlText, contains('name: "优选节点"'));
    expect(yamlText, contains('iso-node'));
  });

  test('manual prefer supports the FREE-NODES root group', () async {
    const existingConfig = '''
proxies:
  - name: old-node
    type: ss
    server: old.example.com
    port: 443
    cipher: aes-128-gcm
    password: old-pass
  - name: today-node
    type: ss
    server: today.example.com
    port: 443
    cipher: aes-128-gcm
    password: today-pass
proxy-groups:
  - name: "2026-05-30"
    type: url-test
    proxies:
      - old-node
  - name: "2026-06-19"
    type: url-test
    proxies:
      - today-node
''';

    final result = await FreeNodesService().preferGroupConfigText(
      existingConfig,
      freeNodesGroupName,
    );
    final yamlText = utf8.decode(result.bytes);

    expect(result.affectedCount, 2);
    expect(yamlText, contains('name: "FREE-NODES"'));
    expect(yamlText, contains('old-node'));
    expect(yamlText, contains('today-node'));
  });

  test('manual prefer supports a visible custom free node group', () async {
    const existingConfig = '''
proxies:
  - name: hk-node
    type: ss
    server: hk.example.com
    port: 443
    cipher: aes-128-gcm
    password: hk-pass
  - name: us-node
    type: ss
    server: us.example.com
    port: 443
    cipher: aes-128-gcm
    password: us-pass
proxy-groups:
  - name: "香港"
    type: url-test
    proxies:
      - hk-node
  - name: "美国"
    type: url-test
    proxies:
      - us-node
''';

    final result = await FreeNodesService().preferGroupConfigText(
      existingConfig,
      '香港',
    );

    expect(result.affectedCount, 1);
    expect(result.groupName, '香港');
  });

  test('manual delete supports a visible custom free node group', () async {
    const existingConfig = '''
proxies:
  - name: hk-node
    type: ss
    server: hk.example.com
    port: 443
    cipher: aes-128-gcm
    password: hk-pass
  - name: us-node
    type: ss
    server: us.example.com
    port: 443
    cipher: aes-128-gcm
    password: us-pass
proxy-groups:
  - name: "香港"
    type: url-test
    proxies:
      - hk-node
  - name: "美国"
    type: url-test
    proxies:
      - us-node
''';

    final result = await FreeNodesService().deleteDateGroupConfigText(
      existingConfig,
      '香港',
    );
    final yamlText = utf8.decode(result.bytes);

    expect(result.affectedCount, 1);
    expect(result.groupName, '香港');
    expect(yamlText, contains('name: "优选节点"'));
    expect(yamlText, contains('hk-node'));
  });

  test('manual delete rejects today date group', () async {
    final now = DateTime.now();
    final today =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    final existingConfig =
        '''
proxies:
  - name: today-node
    type: ss
    server: today.example.com
    port: 443
    cipher: aes-128-gcm
    password: today-pass
proxy-groups:
  - name: "$today"
    type: url-test
    proxies:
      - today-node
''';

    expect(
      () => FreeNodesService().deleteDateGroupConfigText(existingConfig, today),
      throwsA(contains('不能删除本日免费节点')),
    );
  });

  test(
    'asset catalog keeps 187 unique sources and enables all by default',
    () async {
      final sourceCatalogJson = await File(
        'assets/data/free_node_sources.json',
      ).readAsString();
      final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
      final sources = (data['sources'] as List).cast<Map<String, dynamic>>();
      final defaultSourceIds = (data['defaultSourceIds'] as List)
          .map((item) => item.toString())
          .toList(growable: false);

      String canonicalSeed(String seed) {
        final uri = Uri.parse(seed);
        final path = uri.path == '/'
            ? ''
            : uri.path.replaceFirst(RegExp(r'/+$'), '');
        return uri
            .replace(
              scheme: uri.scheme.toLowerCase(),
              host: uri.host.toLowerCase(),
              path: path,
              fragment: null,
            )
            .toString();
      }

      final ids = sources.map((source) => source['id'].toString()).toList();
      final labels = sources
          .map((source) => source['label'].toString())
          .toList();
      final seeds = sources.map((source) => source['seed'].toString()).toList();
      final canonicalSeeds = seeds.map(canonicalSeed).toList();

      expect(sources, hasLength(187));
      expect(defaultSourceIds, hasLength(187));
      expect(defaultSourceIds.toSet(), hasLength(187));
      expect(defaultSourceIds, sources.map((source) => source['id']));
      expect(defaultSourceIds.every(ids.toSet().contains), isTrue);
      expect(ids.every((value) => value.trim().isNotEmpty), isTrue);
      expect(labels.every((value) => value.trim().isNotEmpty), isTrue);
      expect(seeds.every((value) => value.trim().isNotEmpty), isTrue);
      expect(ids.toSet(), hasLength(sources.length));
      expect(labels.toSet(), hasLength(sources.length));
      expect(canonicalSeeds.toSet(), hasLength(sources.length));

      await preferences.sharedPreferencesCompleter.future;
      SharedPreferences.setMockInitialValues({});
      preferences.sharedPreferencesCompleter = Completer<SharedPreferences?>()
        ..complete(await SharedPreferences.getInstance());
      final service = FreeNodesService(sourceCatalogJson: sourceCatalogJson);
      expect(await service.getSourceOptions(), hasLength(187));
      expect(await service.getEnabledSourceIds(), ids.toSet());
    },
  );

  test('defaults fetch concurrency to all enabled free node sources', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    await preferences.sharedPreferencesCompleter.future;
    SharedPreferences.setMockInitialValues({});
    preferences.sharedPreferencesCompleter = Completer<SharedPreferences?>()
      ..complete(await SharedPreferences.getInstance());
    final service = FreeNodesService(sourceCatalogJson: sourceCatalogJson);

    final enabledSourceIds = await service.getEnabledSourceIds();
    final preferenceState = await service.getPreferenceState();

    expect(enabledSourceIds, isNotEmpty);
    expect(preferenceState.fetchConcurrency, enabledSourceIds.length);
  });

  test('keeps saved free node fetch concurrency above legacy limit', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    await preferences.sharedPreferencesCompleter.future;
    SharedPreferences.setMockInitialValues({freeNodesFetchConcurrencyKey: 96});
    preferences.sharedPreferencesCompleter = Completer<SharedPreferences?>()
      ..complete(await SharedPreferences.getInstance());
    final service = FreeNodesService(sourceCatalogJson: sourceCatalogJson);

    expect((await service.getPreferenceState()).fetchConcurrency, 96);
  });

  test('clamps saved free node fetch concurrency to catalog size', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    await preferences.sharedPreferencesCompleter.future;
    SharedPreferences.setMockInitialValues({});
    preferences.sharedPreferencesCompleter = Completer<SharedPreferences?>()
      ..complete(await SharedPreferences.getInstance());
    final service = FreeNodesService(sourceCatalogJson: sourceCatalogJson);
    final sourceCount = (await service.getSourceOptions()).length;

    await service.saveFetchConcurrency(999);

    expect((await service.getPreferenceState()).fetchConcurrency, sourceCount);
  });

  test('Dart fallback gives every source candidate its own timeout', () async {
    const catalog = '''
{
  "lookbackDays": 1,
  "sources": [
    {
      "id": "timeout-retry",
      "label": "Timeout Retry",
      "seed": "https://timeout-retry.example.com/",
      "rank": 0,
      "configTemplates": [
        "https://a-timeout.example.com/config.yaml",
        "https://b-success.example.com/config.yaml"
      ]
    }
  ]
}
''';
    await preferences.sharedPreferencesCompleter.future;
    SharedPreferences.setMockInitialValues({freeNodesFetchConcurrencyKey: 1});
    preferences.sharedPreferencesCompleter = Completer<SharedPreferences?>()
      ..complete(await SharedPreferences.getInstance());
    final fetchedUrls = <String>[];
    final service = FreeNodesService(
      sourceCatalogJson: catalog,
      fetchTimeout: const Duration(milliseconds: 20),
      fetcher: (url) async {
        fetchedUrls.add(url);
        if (url.contains('a-timeout')) {
          await Future<void>.delayed(const Duration(milliseconds: 40));
          return sampleConfig;
        }
        if (url.contains('b-success')) {
          return sampleConfig;
        }
        throw StateError('unexpected URL: $url');
      },
    );

    final result = await service.fetchMergedConfig();

    expect(fetchedUrls, contains('https://a-timeout.example.com/config.yaml'));
    expect(fetchedUrls, contains('https://b-success.example.com/config.yaml'));
    expect(result.proxyCount, 2);
  });

  test('failed free node source stays due for retry', () async {
    const catalog = '''
{
  "lookbackDays": 1,
  "sources": [
    {
      "id": "failed-source",
      "label": "Failed Source",
      "seed": "https://failed-source.example.com/",
      "rank": 0,
      "updateIntervalHours": 24,
      "configTemplates": ["https://failed-source.example.com/config.yaml"]
    }
  ]
}
''';
    await preferences.sharedPreferencesCompleter.future;
    SharedPreferences.setMockInitialValues({freeNodesFetchConcurrencyKey: 1});
    preferences.sharedPreferencesCompleter = Completer<SharedPreferences?>()
      ..complete(await SharedPreferences.getInstance());
    final service = FreeNodesService(
      sourceCatalogJson: catalog,
      fetcher: (_) async => throw StateError('fetch failed'),
    );

    await service.fetchMergedConfig();

    expect(await service.getDueSourceIds(), contains('failed-source'));
    expect(
      (await service.getSourceOptions())
          .singleWhere((option) => option.id == 'failed-source')
          .lastFetchTime,
      isNull,
    );
  });
  test('catalog defaults do not limit the all-source app default', () async {
    const catalog = '''
{
  "lookbackDays": 1,
  "defaultSourceIds": ["default"],
  "sources": [
    {
      "id": "default",
      "label": "Default",
      "seed": "https://default.example.com/config.yaml",
      "rank": 0,
      "configTemplates": ["https://default.example.com/config.yaml"]
    },
    {
      "id": "reserve",
      "label": "Reserve",
      "seed": "https://reserve.example.com/config.yaml",
      "rank": 1,
      "configTemplates": ["https://reserve.example.com/config.yaml"]
    }
  ]
}
''';
    await preferences.sharedPreferencesCompleter.future;
    SharedPreferences.setMockInitialValues({});
    preferences.sharedPreferencesCompleter = Completer<SharedPreferences?>()
      ..complete(await SharedPreferences.getInstance());
    final fetchedUrls = <String>[];
    final service = FreeNodesService(
      sourceCatalogJson: catalog,
      fetcher: (url) async {
        fetchedUrls.add(url);
        return sampleConfig;
      },
    );

    expect(await service.getEnabledSourceIds(), {'default', 'reserve'});
    final result = await service.fetchMergedConfig();

    expect(result.proxyCount, 2);
    expect(fetchedUrls, isNotEmpty);
    expect(
      fetchedUrls.any((url) => url.contains('default.example.com')),
      isTrue,
    );
    expect(
      fetchedUrls.any((url) => url.contains('reserve.example.com')),
      isTrue,
    );
  });

  test('saved source selection overrides the all-source app default', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map<String, dynamic>>();
    final selectedId = sources.last['id'].toString();
    await preferences.sharedPreferencesCompleter.future;
    SharedPreferences.setMockInitialValues({
      freeNodesSelectedSourcesKey: [selectedId],
    });
    preferences.sharedPreferencesCompleter = Completer<SharedPreferences?>()
      ..complete(await SharedPreferences.getInstance());
    final service = FreeNodesService(sourceCatalogJson: sourceCatalogJson);

    expect(await service.getEnabledSourceIds(), {selectedId});
  });

  test('uses enabled free node sources only', () async {
    const catalog = '''
{
  "lookbackDays": 1,
  "sources": [
    {
      "id": "enabled",
      "label": "Enabled",
      "seed": "https://enabled.example.com/",
      "rank": 0,
      "configTemplates": ["https://enabled.example.com/config.yaml"]
    },
    {
      "id": "disabled",
      "label": "Disabled",
      "seed": "https://disabled.example.com/",
      "rank": 1,
      "configTemplates": ["https://disabled.example.com/config.yaml"]
    }
  ]
}
''';
    final fetchedUrls = <String>[];
    final service = FreeNodesService(
      sourceCatalogJson: catalog,
      enabledSourceIds: {'enabled'},
      fetcher: (url) async {
        fetchedUrls.add(url);
        return sampleConfig;
      },
    );

    final result = await service.fetchMergedConfig();

    expect(result.proxyCount, 2);
    expect(
      fetchedUrls.every((url) => url.contains('enabled.example.com')),
      isTrue,
    );
  });

  test(
    'Dart fallback expands GitHub raw sources to bounded mirror fallbacks',
    () async {
      const raw =
          'https://raw.githubusercontent.com/PuddinCat/BestClash/refs/heads/main/proxies.yaml';
      const canonical =
          'https://raw.githubusercontent.com/PuddinCat/BestClash/main/proxies.yaml';
      const catalog =
          '''
{
  "lookbackDays": 1,
  "sources": [
    {
      "id": "github",
      "label": "GitHub",
      "seed": "https://github.com/PuddinCat/BestClash",
      "rank": 0,
      "rawCandidates": ["$raw"]
    }
  ]
}
''';
      final fetchedUrls = <String>[];
      final service = FreeNodesService(
        sourceCatalogJson: catalog,
        fetcher: (url) async {
          fetchedUrls.add(url);
          return sampleConfig;
        },
      );

      await service.fetchMergedConfig();

      expect(fetchedUrls, contains('https://ghfile.geekertao.top/$canonical'));
      expect(fetchedUrls, contains('https://ghfast.top/$canonical'));
      expect(fetchedUrls, contains('https://ghproxy.net/$canonical'));
      expect(fetchedUrls, contains('https://gh-proxy.com/$canonical'));
      expect(fetchedUrls, contains('https://gh.llkk.cc/$canonical'));
      expect(fetchedUrls, contains('https://gh.ddlc.top/$canonical'));
      expect(
        fetchedUrls,
        contains(
          'https://cdn.jsdelivr.net/gh/PuddinCat/BestClash@main/proxies.yaml',
        ),
      );
      expect(
        fetchedUrls,
        contains(
          'https://fastly.jsdelivr.net/gh/PuddinCat/BestClash@main/proxies.yaml',
        ),
      );
      expect(
        fetchedUrls,
        contains(
          'https://gcore.jsdelivr.net/gh/PuddinCat/BestClash@main/proxies.yaml',
        ),
      );
      expect(
        fetchedUrls,
        contains(
          'https://rawgithubusercontent.deno.dev/PuddinCat/BestClash/main/proxies.yaml',
        ),
      );
      expect(fetchedUrls, contains(canonical));
    },
  );

  test('Dart fallback candidate limit scales with GitHub mirror count', () {
    final source = File('lib/common/free_nodes.dart').readAsStringSync();

    expect(freeNodesConfigCandidateLimitForTesting, 1800);
    expect(
      source,
      isNot(contains('const _freeNodesConfigCandidateLimit = 1100;')),
    );
    expect(source, contains('final _freeNodesConfigCandidateLimit ='));
    expect(source, contains('_githubRawMirrorPrefixes.length'));
  });

  test('Dart fallback tries expanded raw GitHub mirror set', () {
    const raw =
        'https://raw.githubusercontent.com/PuddinCat/BestClash/main/proxies.yaml';
    final mirrors = githubMirrorUrlsForTesting(raw);

    expect(mirrors.length, 17);
    expect(mirrors.first, 'https://ghfile.geekertao.top/$raw');
    expect(mirrors.elementAt(1), 'https://ghfast.top/$raw');
    expect(mirrors.elementAt(2), 'https://ghproxy.net/$raw');
    expect(mirrors.elementAt(3), 'https://gh-proxy.com/$raw');
    expect(mirrors, contains('https://ghproxy.imciel.com/$raw'));
    expect(mirrors, contains('https://gh.monlor.com/$raw'));
    expect(mirrors, contains('https://ghproxy.cc/$raw'));
    expect(mirrors, contains('https://gh.con.sh/$raw'));
    expect(mirrors, contains('https://hub.gitmirror.com/$raw'));
    expect(mirrors, contains('https://ghproxy.vip/$raw'));
    expect(mirrors, contains('https://github.akams.cn/$raw'));
    expect(
      mirrors,
      contains(
        'https://rawgithubusercontent.deno.dev/PuddinCat/BestClash/main/proxies.yaml',
      ),
    );
  });

  test('Dart fallback expands GitHub blob URLs through canonical raw mirrors', () {
    const blob =
        'https://github.com/PuddinCat/BestClash/blob/main/proxies.yaml';
    const raw =
        'https://raw.githubusercontent.com/PuddinCat/BestClash/main/proxies.yaml';
    final mirrors = githubMirrorUrlsForTesting(blob);

    expect(mirrors.length, 17);
    expect(mirrors.first, 'https://ghfile.geekertao.top/$raw');
    expect(mirrors, contains('https://gh-proxy.com/$raw'));
    expect(
      mirrors,
      contains(
        'https://cdn.jsdelivr.net/gh/PuddinCat/BestClash@main/proxies.yaml',
      ),
    );
    expect(
      mirrors,
      contains(
        'https://rawgithubusercontent.deno.dev/PuddinCat/BestClash/main/proxies.yaml',
      ),
    );
    expect(mirrors.any((url) => url.contains('/blob/main/')), isFalse);
  });

  test('Dart fallback canonicalizes jsDelivr GitHub mirrors', () {
    const raw =
        'https://raw.githubusercontent.com/PuddinCat/BestClash/main/proxies.yaml';
    expect(
      canonicalFreeNodeConfigUrlForTesting(
        'https://cdn.jsdelivr.net/gh/PuddinCat/BestClash@main/proxies.yaml',
      ),
      raw,
    );
    expect(
      canonicalFreeNodeConfigUrlForTesting(
        'https://fastly.jsdelivr.net/gh/PuddinCat/BestClash@main/proxies.yaml',
      ),
      raw,
    );
    expect(
      canonicalFreeNodeConfigUrlForTesting(
        'https://gcore.jsdelivr.net/gh/PuddinCat/BestClash@main/proxies.yaml',
      ),
      raw,
    );
    expect(
      canonicalFreeNodeConfigUrlForTesting(
        'https://rawgithubusercontent.deno.dev/PuddinCat/BestClash/main/proxies.yaml',
      ),
      raw,
    );
  });

  test('Dart fallback expands raw refs heads mirrors with the branch name', () {
    const raw =
        'https://raw.githubusercontent.com/PuddinCat/BestClash/refs/heads/main/proxies.yaml';
    const canonical =
        'https://raw.githubusercontent.com/PuddinCat/BestClash/main/proxies.yaml';

    final mirrors = githubMirrorUrlsForTesting(raw);

    expect(mirrors.first, 'https://ghfile.geekertao.top/$canonical');
    expect(
      mirrors,
      contains(
        'https://cdn.jsdelivr.net/gh/PuddinCat/BestClash@main/proxies.yaml',
      ),
    );
    expect(
      mirrors,
      contains(
        'https://fastly.jsdelivr.net/gh/PuddinCat/BestClash@main/proxies.yaml',
      ),
    );
    expect(
      mirrors,
      contains(
        'https://gcore.jsdelivr.net/gh/PuddinCat/BestClash@main/proxies.yaml',
      ),
    );
    expect(
      mirrors,
      contains(
        'https://rawgithubusercontent.deno.dev/PuddinCat/BestClash/main/proxies.yaml',
      ),
    );
    expect(
      mirrors.any(
        (url) =>
            url.contains('BestClash@refs/') ||
            url.contains('BestClash/refs/heads/'),
      ),
      isFalse,
    );
  });

  test(
    'Dart fallback canonicalizes PuddinCat mirrored blob and raw refs candidates',
    () async {
      const canonical =
          'https://raw.githubusercontent.com/PuddinCat/BestClash/main/proxies.yaml';
      const catalog = '''
{
  "lookbackDays": 1,
  "sources": [
    {
      "id": "puddincat",
      "label": "PuddinCat",
      "seed": "https://github.com/PuddinCat/BestClash",
      "rank": 0,
      "rawCandidates": [
        "https://ghfile.geekertao.top/https://github.com/PuddinCat/BestClash/blob/main/proxies.yaml",
        "https://ghfile.geekertao.top/https://raw.githubusercontent.com/PuddinCat/BestClash/refs/heads/main/proxies.yaml",
        "https://gh-proxy.com/https://raw.githubusercontent.com/PuddinCat/BestClash/refs/heads/main/proxies.yaml",
        "https://raw.githubusercontent.com/PuddinCat/BestClash/refs/heads/main/proxies.yaml"
      ]
    }
  ]
}
''';
      final fetchedUrls = <String>[];
      final service = FreeNodesService(
        sourceCatalogJson: catalog,
        fetcher: (url) async {
          fetchedUrls.add(url);
          return sampleConfig;
        },
      );

      await service.fetchMergedConfig();

      final expected = [
        'https://ghfile.geekertao.top/$canonical',
        'https://gh-proxy.com/$canonical',
        'https://ghproxy.imciel.com/$canonical',
        'https://gh.monlor.com/$canonical',
        'https://ghproxy.net/$canonical',
        'https://ghfast.top/$canonical',
        'https://gh.ddlc.top/$canonical',
        'https://gh.llkk.cc/$canonical',
        'https://ghproxy.cc/$canonical',
        'https://gh.con.sh/$canonical',
        'https://hub.gitmirror.com/$canonical',
        'https://ghproxy.vip/$canonical',
        'https://github.akams.cn/$canonical',
        'https://gcore.jsdelivr.net/gh/PuddinCat/BestClash@main/proxies.yaml',
        'https://fastly.jsdelivr.net/gh/PuddinCat/BestClash@main/proxies.yaml',
        'https://cdn.jsdelivr.net/gh/PuddinCat/BestClash@main/proxies.yaml',
        'https://rawgithubusercontent.deno.dev/PuddinCat/BestClash/main/proxies.yaml',
        canonical,
      ];
      expect(fetchedUrls.toSet(), expected.toSet());
      expect(
        fetchedUrls.any(
          (url) =>
              url.contains('/blob/main/proxies.yaml') ||
              url.contains('/refs/heads/main/proxies.yaml'),
        ),
        isFalse,
      );
    },
  );

  test('Dart fallback discovers GitHub repo from mirrored blob seed', () async {
    const seed =
        'https://ghfile.geekertao.top/https://github.com/PuddinCat/BestClash/blob/dev/proxies.yaml';
    const catalog =
        '''
{
  "lookbackDays": 1,
  "sources": [
    {
      "id": "puddincat",
      "label": "PuddinCat",
      "seed": "$seed",
      "rank": 0,
      "githubDiscovery": true
    }
  ]
}
''';
    final fetchedUrls = <String>[];
    final service = FreeNodesService(
      sourceCatalogJson: catalog,
      fetcher: (url) async {
        fetchedUrls.add(url);
        final requestUrl = _stripKnownGithubMirrorPrefixForTest(url);
        if (requestUrl == 'https://api.github.com/repos/PuddinCat/BestClash') {
          return '{"default_branch":"main"}';
        }
        if (requestUrl.startsWith(
          'https://api.github.com/repos/PuddinCat/BestClash/',
        )) {
          return '[]';
        }
        return 'proxies: []';
      },
    );

    await service.fetchMergedConfig();
    final canonicalFetchedUrls = fetchedUrls
        .map(_stripKnownGithubMirrorPrefixForTest)
        .toList(growable: false);

    expect(
      canonicalFetchedUrls,
      contains('https://api.github.com/repos/PuddinCat/BestClash'),
    );
    expect(
      canonicalFetchedUrls,
      contains(
        'https://api.github.com/repos/PuddinCat/BestClash/contents?ref=dev',
      ),
    );
    expect(
      canonicalFetchedUrls,
      contains(
        'https://api.github.com/repos/PuddinCat/BestClash/git/trees/dev?recursive=1',
      ),
    );
    expect(
      canonicalFetchedUrls.indexOf(
        'https://api.github.com/repos/PuddinCat/BestClash/contents?ref=dev',
      ),
      lessThan(
        canonicalFetchedUrls.indexOf(
          'https://api.github.com/repos/PuddinCat/BestClash/git/trees/main?recursive=1',
        ),
      ),
    );
    expect(
      fetchedUrls,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/PuddinCat/BestClash/dev/sub/clash.yaml',
      ),
    );
    expect(
      fetchedUrls.indexOf(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/PuddinCat/BestClash/dev/clash.yaml',
      ),
      lessThan(
        fetchedUrls.indexOf(
          'https://ghfile.geekertao.top/https://raw.githubusercontent.com/PuddinCat/BestClash/main/clash.yaml',
        ),
      ),
    );
  });

  test('Dart fallback discovers GitHub default branch before main master guesses', () async {
    const catalog = '''
{
  "lookbackDays": 1,
  "sources": [
    {
      "id": "github",
      "label": "GitHub",
      "seed": "https://github.com/PuddinCat/BestClash",
      "rank": 0,
      "githubDiscovery": true
    }
  ]
}
''';
    final fetchedUrls = <String>[];
    final service = FreeNodesService(
      sourceCatalogJson: catalog,
      fetcher: (url) async {
        fetchedUrls.add(url);
        final requestUrl = _stripKnownGithubMirrorPrefixForTest(url);
        if (requestUrl == 'https://api.github.com/repos/PuddinCat/BestClash') {
          return '{"default_branch":"dev"}';
        }
        if (requestUrl ==
            'https://api.github.com/repos/PuddinCat/BestClash/contents?ref=dev') {
          return '[{"path":"custom.yaml","type":"file"}]';
        }
        if (requestUrl.contains('/git/trees/')) {
          return '{"tree":[]}';
        }
        if (url ==
                'https://ghfile.geekertao.top/https://raw.githubusercontent.com/PuddinCat/BestClash/dev/proxies.yaml' ||
            url ==
                'https://ghfile.geekertao.top/https://raw.githubusercontent.com/PuddinCat/BestClash/dev/custom.yaml' ||
            url ==
                'https://ghfile.geekertao.top/https://raw.githubusercontent.com/PuddinCat/BestClash/dev/mihomo.yaml') {
          return sampleConfig;
        }
        if (url.startsWith(
          'https://ghfile.geekertao.top/https://raw.githubusercontent.com/PuddinCat/BestClash/dev/',
        )) {
          return 'proxies: []';
        }
        throw StateError('unexpected url $url');
      },
    );

    final result = await service.fetchMergedConfig();

    expect(result.proxyCount, 2);
    expect(
      _stripKnownGithubMirrorPrefixForTest(fetchedUrls.first),
      'https://api.github.com/repos/PuddinCat/BestClash',
    );
    expect(
      fetchedUrls,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/PuddinCat/BestClash/dev/proxies.yaml',
      ),
    );
    expect(
      fetchedUrls,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/PuddinCat/BestClash/dev/custom.yaml',
      ),
    );
    expect(
      fetchedUrls,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/PuddinCat/BestClash/dev/mihomo.yaml',
      ),
    );
    for (final path in [
      'config.yaml',
      'config.yml',
      'merged.yaml',
      'merged.yml',
      'all.yml',
      'nodes.yml',
      'proxy.yaml',
      'proxy.yml',
      'sing-box.json',
      'sing-box.yaml',
      'singbox.json',
      'outbounds.json',
      'outbounds.yaml',
    ]) {
      expect(
        fetchedUrls,
        contains(
          'https://ghfile.geekertao.top/https://raw.githubusercontent.com/PuddinCat/BestClash/dev/$path',
        ),
        reason: 'missing mirrored GitHub root seed path $path',
      );
    }
    expect(
      fetchedUrls,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/PuddinCat/BestClash/dev/all.yaml',
      ),
    );
    expect(
      fetchedUrls,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/PuddinCat/BestClash/dev/base64.txt',
      ),
    );
    expect(
      fetchedUrls,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/PuddinCat/BestClash/dev/v2ray.txt',
      ),
    );
    for (final path in [
      'sub',
      'sub.yml',
      'sub_en',
      'sub_zh',
      'sub_ar',
      'v2ray',
      'base64',
      'list',
      'subscribe',
      'subscribe.yaml',
      'subscribe.yml',
      'subscription',
      'subscription.yaml',
      'subscription.yml',
      'subscriptions',
      'subscriptions.yaml',
      'subscriptions.yml',
      'subscribe.txt',
      'subscription.txt',
      'subscriptions.txt',
      'nodes.txt',
      'nodes',
      'node',
      'node.txt',
      'node.yaml',
      'node.yml',
      'proxy.txt',
      'proxy',
      'proxies.txt',
      'proxies',
      'list.txt',
      'links.txt',
      'urls.txt',
      'profile',
      'profile.txt',
      'profile.yaml',
      'profile.yml',
      'profiles',
      'profiles.txt',
      'profiles.yaml',
      'profiles.yml',
      'node/clash.yaml',
      'node/clash.yml',
      'node/proxies.yaml',
      'node/proxies.yml',
      'node/mihomo.yaml',
      'node/base64.txt',
      'node/sub.txt',
      'node/v2ray.txt',
      'proxy/clash.yaml',
      'proxy/clash.yml',
      'proxy/proxies.yaml',
      'proxy/proxies.yml',
      'proxy/mihomo.yaml',
      'proxy/base64.txt',
      'proxy/sub.txt',
      'proxy/v2ray.txt',
      'proxies/clash.yaml',
      'proxies/clash.yml',
      'proxies/proxies.yaml',
      'proxies/proxies.yml',
      'proxies/mihomo.yaml',
      'proxies/base64.txt',
      'proxies/sub.txt',
      'proxies/v2ray.txt',
    ]) {
      expect(
        fetchedUrls,
        contains(
          'https://ghfile.geekertao.top/https://raw.githubusercontent.com/PuddinCat/BestClash/dev/$path',
        ),
        reason: 'missing mirrored GitHub extensionless root seed path $path',
      );
    }
    expect(
      fetchedUrls,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/PuddinCat/BestClash/dev/source/clash-meta.yaml',
      ),
    );
    expect(
      fetchedUrls,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/PuddinCat/BestClash/dev/sub/clash.yaml',
      ),
    );
    expect(
      fetchedUrls,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/PuddinCat/BestClash/dev/sub/base64.txt',
      ),
    );
    expect(
      fetchedUrls,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/PuddinCat/BestClash/dev/sub/merged.yaml',
      ),
    );
    expect(
      fetchedUrls,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/PuddinCat/BestClash/dev/subscribe/v2ray.txt',
      ),
    );
    expect(
      fetchedUrls,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/PuddinCat/BestClash/dev/subscription/clash.yaml',
      ),
    );
    expect(
      fetchedUrls,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/PuddinCat/BestClash/dev/subscriptions/base64.txt',
      ),
    );
    expect(
      fetchedUrls,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/PuddinCat/BestClash/dev/clash/proxies.yaml',
      ),
    );
    expect(
      fetchedUrls,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/PuddinCat/BestClash/dev/mihomo/all.yaml',
      ),
    );
    expect(
      fetchedUrls,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/PuddinCat/BestClash/dev/yaml/clash.yaml',
      ),
    );
    expect(
      fetchedUrls,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/PuddinCat/BestClash/dev/v2ray/sub.txt',
      ),
    );
    expect(
      fetchedUrls,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/PuddinCat/BestClash/dev/static/sub_zh',
      ),
    );
    expect(
      fetchedUrls,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/PuddinCat/BestClash/dev/nodes/clashmeta.yaml',
      ),
    );
    expect(
      fetchedUrls,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/PuddinCat/BestClash/dev/subs/merged/tested_within.yaml',
      ),
    );
    expect(
      fetchedUrls,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/PuddinCat/BestClash/dev/subs/merged/tested_within_sudoku.yaml',
      ),
    );
  });

  test('Dart fallback deduplicates GitHub contents default ref pages', () async {
    const catalog = '''
{
  "lookbackDays": 1,
  "sources": [
    {
      "id": "github",
      "label": "GitHub",
      "seed": "https://github.com/PuddinCat/BestClash",
      "rank": 0,
      "githubDiscovery": true
    }
  ]
}
''';
    final fetchedUrls = <String>[];
    final service = FreeNodesService(
      sourceCatalogJson: catalog,
      fetcher: (url) async {
        fetchedUrls.add(url);
        final requestUrl = _stripKnownGithubMirrorPrefixForTest(url);
        if (requestUrl == 'https://api.github.com/repos/PuddinCat/BestClash') {
          return '{"default_branch":"main"}';
        }
        if (requestUrl ==
            'https://api.github.com/repos/PuddinCat/BestClash/contents') {
          return '[]';
        }
        if (requestUrl.contains('/git/trees/')) {
          return '{"tree":[]}';
        }
        if (url ==
            'https://ghfile.geekertao.top/https://raw.githubusercontent.com/PuddinCat/BestClash/main/proxies.yaml') {
          return sampleConfig;
        }
        return 'proxies: []';
      },
    );

    final result = await service.fetchMergedConfig();

    expect(result.proxyCount, 2);
    final canonicalFetchedUrls = fetchedUrls
        .map(_stripKnownGithubMirrorPrefixForTest)
        .toList(growable: false);
    expect(
      canonicalFetchedUrls,
      isNot(
        contains(
          'https://api.github.com/repos/PuddinCat/BestClash/contents?ref=main',
        ),
      ),
    );
  });

  test('Dart fallback deduplicates GitHub contents subdir default ref pages', () async {
    const catalog = '''
{
  "lookbackDays": 1,
  "sources": [
    {
      "id": "github",
      "label": "GitHub",
      "seed": "https://github.com/PuddinCat/BestClash",
      "rank": 0,
      "githubDiscovery": true
    }
  ]
}
''';
    final fetchedUrls = <String>[];
    final service = FreeNodesService(
      sourceCatalogJson: catalog,
      fetcher: (url) async {
        fetchedUrls.add(url);
        final requestUrl = _stripKnownGithubMirrorPrefixForTest(url);
        if (requestUrl == 'https://api.github.com/repos/PuddinCat/BestClash') {
          return '{"default_branch":"main"}';
        }
        if (requestUrl ==
            'https://api.github.com/repos/PuddinCat/BestClash/contents') {
          return '''
[
  {
    "path": "configs",
    "type": "dir",
    "url": "https://api.github.com/repos/PuddinCat/BestClash/contents/configs?ref=main"
  }
]
''';
        }
        if (requestUrl ==
            'https://api.github.com/repos/PuddinCat/BestClash/contents/configs') {
          return '[{"path":"configs/proxies.yaml","type":"file","download_url":null}]';
        }
        if (requestUrl.contains('/git/trees/')) {
          return '{"tree":[]}';
        }
        if (url ==
                'https://ghfile.geekertao.top/https://raw.githubusercontent.com/PuddinCat/BestClash/main/proxies.yaml' ||
            url ==
                'https://ghfile.geekertao.top/https://raw.githubusercontent.com/PuddinCat/BestClash/main/configs/proxies.yaml') {
          return sampleConfig;
        }
        return 'proxies: []';
      },
    );

    final result = await service.fetchMergedConfig();

    expect(result.proxyCount, 2);
    final canonicalFetchedUrls = fetchedUrls
        .map(_stripKnownGithubMirrorPrefixForTest)
        .toList(growable: false);
    expect(
      canonicalFetchedUrls,
      contains(
        'https://api.github.com/repos/PuddinCat/BestClash/contents/configs',
      ),
    );
    expect(
      canonicalFetchedUrls,
      isNot(
        contains(
          'https://api.github.com/repos/PuddinCat/BestClash/contents/configs?ref=main',
        ),
      ),
    );
  });

  test('Dart fallback tries GitHub mirrors for discovery API pages', () async {
    const catalog = '''
{
  "lookbackDays": 1,
  "sources": [
    {
      "id": "github",
      "label": "GitHub",
      "seed": "https://github.com/owner/repo",
      "rank": 0,
      "githubDiscovery": true
    }
  ]
}
''';
    final fetchedUrls = <String>[];
    final service = FreeNodesService(
      sourceCatalogJson: catalog,
      fetcher: (url) async {
        fetchedUrls.add(url);
        if (url == 'https://api.github.com/repos/owner/repo') {
          return '{"default_branch":"dev"}';
        }
        if (url == 'https://api.github.com/repos/owner/repo/contents') {
          throw StateError('direct GitHub API blocked');
        }
        if (url ==
            'https://ghfile.geekertao.top/https://api.github.com/repos/owner/repo/contents') {
          return '''
[
  {"path":"configs/special-clash.yaml","type":"file","download_url":null},
  {"path":"configs/subscribe","type":"file","download_url":null},
  {"path":"profiles/v2ray","type":"file","download_url":null},
  {"path":"profiles/profiles","type":"file","download_url":null}
]
''';
        }
        if (url.contains('/git/trees/')) {
          return '{"tree":[]}';
        }
        if (url ==
            'https://ghfile.geekertao.top/https://raw.githubusercontent.com/owner/repo/main/configs/special-clash.yaml') {
          return sampleConfig;
        }
        if (url ==
            'https://ghfile.geekertao.top/https://raw.githubusercontent.com/owner/repo/main/configs/subscribe') {
          return sampleConfig;
        }
        if (url ==
            'https://ghfile.geekertao.top/https://raw.githubusercontent.com/owner/repo/main/profiles/v2ray') {
          return sampleConfig;
        }
        if (url ==
            'https://ghfile.geekertao.top/https://raw.githubusercontent.com/owner/repo/main/profiles/profiles') {
          return sampleConfig;
        }
        return 'proxies: []';
      },
    );

    final result = await service.fetchMergedConfig();

    expect(result.proxyCount, 2);
    expect(
      fetchedUrls,
      contains(
        'https://ghfile.geekertao.top/https://api.github.com/repos/owner/repo/contents',
      ),
    );
    expect(
      fetchedUrls,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/owner/repo/main/configs/special-clash.yaml',
      ),
    );
    expect(
      fetchedUrls,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/owner/repo/main/configs/subscribe',
      ),
    );
    expect(
      fetchedUrls,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/owner/repo/main/profiles/v2ray',
      ),
    );
    expect(
      fetchedUrls,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/owner/repo/main/profiles/profiles',
      ),
    );
  });

  test('Dart GitHub discovery estimate covers expanded seed candidates', () {
    expect(
      freeNodesGithubDiscoveryInitialCandidateEstimateForTesting,
      greaterThanOrEqualTo(freeNodesGithubRawSeedPathCountForTesting * 3 + 8),
    );
  });

  test('Dart GitHub raw seed paths cover Rust high value source families', () {
    expect(
      freeNodesGithubRawSeedPathsForTesting,
      containsAll([
        'c.yaml',
        'v.txt',
        'Client.txt',
        'ClashPremiumFree.yaml',
        'README.md',
        'all.json',
        'all.csv',
        'all-proxies.txt',
        'http.txt',
        'https.txt',
        'socks5.txt',
        'proxylist.json',
        'proxylist.csv',
        'proxylist.xml',
        'proxylist.phps',
        'provider.yaml',
        'providers.json',
        'proxy-providers.yaml',
        'proxy_providers.json',
        'proxies/protocols/http/data.json',
        'proxies/protocols/https/data.csv',
        'proxies/protocols/socks5/data.txt',
        'online-proxies/yaml/proxies-basic.yaml',
        'online-proxies/json/proxies-basic.json',
        'online-proxies/xml/proxies-basic.xml',
        'sub/protocols/vless.txt',
        'sub/protocols/trojan.yaml',
        'output_configs/Vless.txt',
        'output_configs/Vmess.txt',
        'output_configs/Trojan.txt',
        'output_configs/ShadowSocks.txt',
        'output_configs/Hysteria2.txt',
        'output_configs/Tuic.txt',
        'Splitted-By-Protocol/vless.txt',
        'Splitted-By-Protocol/vmess.txt',
        'Splitted-By-Protocol/trojan.txt',
        'Splitted-By-Protocol/ss.txt',
        'Splitted-By-Protocol/hysteria2.txt',
        'Splitted-By-Protocol/tuic.txt',
        'sub/continents/Europe.yaml',
        'sub/continents/Asia.txt',
        'sub/countries/IR.txt',
        'sub/countries/US.yaml',
        'sub1.txt',
        'sub2.txt',
        'sub3.txt',
        'subscriptions/v2ray/super-sub.txt',
        'subscriptions/v2ray/subs/sub1.txt',
        'subscriptions/v2ray/subs/sub10.txt',
        'nodes/yudou66.txt',
        'nodes/ndnode.txt',
        'nodes/v2rayshare.txt',
        'nodes/wenode.txt',
        'config/clash.yaml',
        'configs/sub.yaml',
        'data/proxies.yaml',
        'share/sub.yaml',
      ]),
    );
  });

  test(
    'still discovers page sources when many config candidates exist',
    () async {
      final rawCandidates = List.generate(
        40,
        (index) => '"https://bulk.example.com/$index.yaml"',
      ).join(',\n');
      final catalog =
          '''
{
  "lookbackDays": 1,
  "sources": [
    {
      "id": "bulk",
      "label": "Bulk",
      "seed": "https://bulk.example.com/",
      "rank": 0,
      "rawCandidates": [$rawCandidates]
    },
    {
      "id": "page",
      "label": "Page",
      "seed": "https://page.example.com/",
      "rank": 1,
      "pageDiscovery": true
    }
  ]
}
''';
      final fetchedUrls = <String>[];
      final service = FreeNodesService(
        sourceCatalogJson: catalog,
        fetcher: (url) async {
          fetchedUrls.add(url);
          if (url == 'https://page.example.com/') {
            return '<a href="https://page.example.com/config.yaml">config</a>';
          }
          return sampleConfig;
        },
      );

      final result = await service.fetchMergedConfig();

      expect(result.proxyCount, greaterThan(0));
      expect(fetchedUrls, contains('https://page.example.com/'));
      expect(fetchedUrls, contains('https://page.example.com/config.yaml'));
    },
  );

  test('Dart fallback discovers meta refresh subscription URLs', () async {
    const catalog = '''
{
  "lookbackDays": 1,
  "sources": [
    {
      "id": "meta-refresh",
      "label": "Meta Refresh",
      "seed": "https://meta.example.com/free/index.html",
      "rank": 0,
      "pageDiscovery": true
    }
  ]
}
''';
    final fetchedUrls = <String>[];
    final service = FreeNodesService(
      sourceCatalogJson: catalog,
      fetcher: (url) async {
        fetchedUrls.add(url);
        if (url == 'https://meta.example.com/free/index.html') {
          return '''
<html>
  <head>
    <meta http-equiv="refresh" content="0; url=/api/subscribe?token=a&amp;target=clash">
    <meta content="0; url='./profiles/free.txt?format=clash'" http-equiv="refresh">
  </head>
</html>
''';
        }
        if (url ==
                'https://meta.example.com/api/subscribe?token=a&target=clash' ||
            url ==
                'https://meta.example.com/free/profiles/free.txt?format=clash') {
          return sampleConfig;
        }
        return 'proxies: []';
      },
    );

    final result = await service.fetchMergedConfig();

    expect(result.proxyCount, 2);
    expect(
      fetchedUrls,
      contains('https://meta.example.com/api/subscribe?token=a&target=clash'),
    );
    expect(
      fetchedUrls,
      contains('https://meta.example.com/free/profiles/free.txt?format=clash'),
    );
  });

  test('Dart fallback discovers base64 encoded subscription URLs', () async {
    final encoded = base64Encode(
      utf8.encode('https://encoded.example.com/daily.yaml?target=clash'),
    );
    const catalog = '''
{
  "lookbackDays": 1,
  "sources": [
    {
      "id": "encoded-page",
      "label": "Encoded Page",
      "seed": "https://encoded.example.com/",
      "rank": 0,
      "pageDiscovery": true
    }
  ]
}
''';
    final fetchedUrls = <String>[];
    final service = FreeNodesService(
      sourceCatalogJson: catalog,
      fetcher: (url) async {
        fetchedUrls.add(url);
        if (url == 'https://encoded.example.com/') {
          return '<script>window.encodedSub="$encoded";</script>';
        }
        if (url == 'https://encoded.example.com/daily.yaml?target=clash') {
          return sampleConfig;
        }
        return 'proxies: []';
      },
    );

    final result = await service.fetchMergedConfig();

    expect(result.proxyCount, greaterThan(0));
    expect(
      fetchedUrls,
      contains('https://encoded.example.com/daily.yaml?target=clash'),
    );
  });

  test('Dart fallback discovers base64 encoded relative JSON URLs', () async {
    final encoded = base64Encode(
      utf8.encode('''
{
  "clash": "/api/free?target=clash",
  "daily": "daily/free.yaml",
  "logo": "assets/logo.png"
}
'''),
    );
    const catalog = '''
{
  "lookbackDays": 1,
  "sources": [
    {
      "id": "encoded-json-page",
      "label": "Encoded JSON Page",
      "seed": "https://jsonencoded.example.com/free-node/index.html",
      "rank": 0,
      "pageDiscovery": true
    }
  ]
}
''';
    final fetchedUrls = <String>[];
    final service = FreeNodesService(
      sourceCatalogJson: catalog,
      fetcher: (url) async {
        fetchedUrls.add(url);
        if (url == 'https://jsonencoded.example.com/free-node/index.html') {
          return '<script>window.encodedSub="$encoded";</script>';
        }
        if (url == 'https://jsonencoded.example.com/api/free?target=clash' ||
            url ==
                'https://jsonencoded.example.com/free-node/daily/free.yaml') {
          return sampleConfig;
        }
        return 'proxies: []';
      },
    );

    final result = await service.fetchMergedConfig();

    expect(result.proxyCount, greaterThan(0));
    expect(
      fetchedUrls,
      contains('https://jsonencoded.example.com/api/free?target=clash'),
    );
    expect(
      fetchedUrls,
      contains('https://jsonencoded.example.com/free-node/daily/free.yaml'),
    );
    expect(
      fetchedUrls,
      isNot(
        contains('https://jsonencoded.example.com/free-node/assets/logo.png'),
      ),
    );
  });

  test('reports free node update progress', () async {
    const catalog = '''
{
  "lookbackDays": 1,
  "sources": [
    {
      "id": "progress",
      "label": "Progress",
      "seed": "https://progress.example.com/",
      "rank": 0,
      "configTemplates": ["https://progress.example.com/config.yaml"]
    }
  ]
}
''';
    final progressEvents = <FreeNodesProgress>[];
    final service = FreeNodesService(
      sourceCatalogJson: catalog,
      fetcher: (_) async => sampleConfig,
    );

    final result = await service.fetchMergedConfig(
      onProgress: progressEvents.add,
    );

    expect(result.proxyCount, 2);
    expect(progressEvents, isNotEmpty);
    expect(progressEvents.last.done, isTrue);
    expect(progressEvents.last.proxyCount, 2);
    expect(progressEvents.last.total, 1);
    expect(progressEvents.last.successfulSources, 1);
    expect(progressEvents.last.failedSources, 0);
  });

  test('reports partial merged config before later sources finish', () async {
    const catalog = '''
{
  "lookbackDays": 1,
  "sources": [
    {
      "id": "fast",
      "label": "Fast",
      "seed": "https://fast.example.com/",
      "rank": 0,
      "configTemplates": ["https://fast.example.com/config.yaml"]
    },
    {
      "id": "slow",
      "label": "Slow",
      "seed": "https://slow.example.com/",
      "rank": 1,
      "configTemplates": ["https://slow.example.com/config.yaml"]
    }
  ]
}
''';
    final partialCounts = <int>[];
    final service = FreeNodesService(
      sourceCatalogJson: catalog,
      fetchTimeout: const Duration(milliseconds: 30),
      fetcher: (url) async {
        if (url.contains('slow.example.com')) {
          await Future<void>.delayed(const Duration(seconds: 1));
          return '';
        }
        return sampleConfig;
      },
    );

    final result = await service.fetchMergedConfig(
      onPartialResult: (partial) {
        partialCounts.add(partial.proxyCount);
      },
    );

    expect(partialCounts, isNotEmpty);
    expect(partialCounts.first, 2);
    expect(result.proxyCount, 2);
  });

  test('keeps existing nodes when new sources time out', () async {
    const catalog = '''
{
  "lookbackDays": 1,
  "historyTimeoutHours": 10000,
  "sources": [
    {
      "id": "timeout",
      "label": "Timeout",
      "seed": "https://timeout.example.com/",
      "rank": 0,
      "configTemplates": ["https://timeout.example.com/config.yaml"]
    }
  ]
}
''';
    const existingConfig = '''
proxies:
  - name: cached-node
    type: ss
    server: cached.example.com
    port: 443
    cipher: aes-128-gcm
    password: cached-pass
proxy-groups:
  - name: "2026-05-30"
    type: url-test
    proxies:
      - cached-node
''';
    final service = FreeNodesService(
      sourceCatalogJson: catalog,
      fetchTimeout: const Duration(milliseconds: 30),
      fetcher: (_) async {
        await Future<void>.delayed(const Duration(seconds: 1));
        return '';
      },
    );

    final result = await service.fetchMergedConfig(
      existingConfigText: existingConfig,
    );
    final yamlText = utf8.decode(result.bytes);

    expect(result.proxyCount, 1);
    expect(yamlText, contains('cached-node'));
  });

  test('asset catalog includes PuddinCat BestClash with ghfile mirror first', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map>();
    final source = sources.singleWhere(
      (item) => item['id'] == 'puddincat-bestclash',
    );
    final rawCandidates = (source['rawCandidates'] as List).cast<String>();

    expect(source['githubDiscovery'], true);
    expect(rawCandidates.first, startsWith('https://ghfile.geekertao.top/'));
    expect(rawCandidates.take(8), [
      'https://ghfile.geekertao.top/https://github.com/PuddinCat/BestClash/blob/main/proxies.yaml',
      'https://ghfile.geekertao.top/https://raw.githubusercontent.com/PuddinCat/BestClash/refs/heads/main/proxies.yaml',
      'https://ghfast.top/https://raw.githubusercontent.com/PuddinCat/BestClash/refs/heads/main/proxies.yaml',
      'https://ghproxy.net/https://raw.githubusercontent.com/PuddinCat/BestClash/refs/heads/main/proxies.yaml',
      'https://gh-proxy.com/https://raw.githubusercontent.com/PuddinCat/BestClash/refs/heads/main/proxies.yaml',
      'https://ghproxy.imciel.com/https://raw.githubusercontent.com/PuddinCat/BestClash/refs/heads/main/proxies.yaml',
      'https://gh.monlor.com/https://raw.githubusercontent.com/PuddinCat/BestClash/refs/heads/main/proxies.yaml',
      'https://gh.ddlc.top/https://raw.githubusercontent.com/PuddinCat/BestClash/refs/heads/main/proxies.yaml',
    ]);
    expect(
      rawCandidates,
      isNot(
        contains(
          'https://gh.con.sh/https://raw.githubusercontent.com/PuddinCat/BestClash/refs/heads/main/proxies.yaml',
        ),
      ),
    );
    expect(
      rawCandidates,
      contains(
        'https://raw.githubusercontent.com/PuddinCat/BestClash/refs/heads/main/proxies.yaml',
      ),
    );
  });

  test('asset catalog includes LeilaoMi verified public node outputs', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map>();
    final source = sources.singleWhere(
      (item) => item['id'] == 'leilaomi-automerge-public-nodes-optimized',
    );
    final rawCandidates = (source['rawCandidates'] as List).cast<String>();

    expect(source['githubDiscovery'], true);
    expect(source['updateIntervalHours'], 6);
    expect(rawCandidates.first, startsWith('https://ghfile.geekertao.top/'));
    expect(
      rawCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/LeilaoMi/AutoMergePublicNodes-Optimized/main/output/verified.yaml',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/LeilaoMi/AutoMergePublicNodes-Optimized/main/output/global.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/LeilaoMi/AutoMergePublicNodes-Optimized/main/output/all.yaml',
        'https://gh.con.sh/https://raw.githubusercontent.com/LeilaoMi/AutoMergePublicNodes-Optimized/main/output/verified.yaml',
        'https://gh.con.sh/https://raw.githubusercontent.com/LeilaoMi/AutoMergePublicNodes-Optimized/main/output/verified.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/LeilaoMi/AutoMergePublicNodes-Optimized/main/output/verified.json',
        'https://gh.con.sh/https://raw.githubusercontent.com/LeilaoMi/AutoMergePublicNodes-Optimized/main/output/global.yaml',
        'https://gh.con.sh/https://raw.githubusercontent.com/LeilaoMi/AutoMergePublicNodes-Optimized/main/output/global.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/LeilaoMi/AutoMergePublicNodes-Optimized/main/output/global.json',
        'https://gh.con.sh/https://raw.githubusercontent.com/LeilaoMi/AutoMergePublicNodes-Optimized/main/output/all.yaml',
        'https://gh.con.sh/https://raw.githubusercontent.com/LeilaoMi/AutoMergePublicNodes-Optimized/main/output/all.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/LeilaoMi/AutoMergePublicNodes-Optimized/main/output/all.json',
        'https://fastly.jsdelivr.net/gh/LeilaoMi/AutoMergePublicNodes-Optimized@main/output/verified.yaml',
        'https://cdn.jsdelivr.net/gh/LeilaoMi/AutoMergePublicNodes-Optimized@main/output/all.yaml',
        'https://raw.githubusercontent.com/LeilaoMi/AutoMergePublicNodes-Optimized/main/output/verified.json',
        'https://raw.githubusercontent.com/LeilaoMi/AutoMergePublicNodes-Optimized/main/output/global.json',
        'https://raw.githubusercontent.com/LeilaoMi/AutoMergePublicNodes-Optimized/main/output/all.json',
      ]),
    );
  });

  test('asset catalog includes cmliu SubsCheck URL index source', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map>();
    final source = sources.singleWhere(
      (item) => item['id'] == 'cmliu-subscheck-urls',
    );
    final rawCandidates = (source['rawCandidates'] as List).cast<String>();

    expect(source['pageDiscovery'], true);
    expect(source['updateIntervalHours'], 6);
    expect(
      source['seed'],
      'https://raw.githubusercontent.com/cmliu/cmliu/main/SubsCheck-URLs',
    );
    expect(
      rawCandidates.first,
      'https://gh.con.sh/https://raw.githubusercontent.com/cmliu/cmliu/main/SubsCheck-URLs',
    );
    expect(
      rawCandidates,
      containsAll([
        'https://cdn.jsdelivr.net/gh/cmliu/cmliu@main/SubsCheck-URLs',
        'https://fastly.jsdelivr.net/gh/cmliu/cmliu@main/SubsCheck-URLs',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/cmliu/cmliu/main/SubsCheck-URLs',
        'https://raw.githubusercontent.com/cmliu/cmliu/main/SubsCheck-URLs',
      ]),
    );
  });

  test('asset catalog splits live cmliu upstreams into source categories', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map>();
    Map findSource(String id) =>
        sources.singleWhere((item) => item['id'] == id);

    final q3Candidates =
        (findSource('q3dlaxpoaq-v2rayn-clash-node-getter')['rawCandidates']
                as List)
            .cast<String>();
    expect(q3Candidates.first, startsWith('https://ghfile.geekertao.top/'));
    expect(
      q3Candidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/Q3dlaXpoaQ/V2rayN_Clash_Node_Getter/main/APIs/sc0.yaml',
        'https://gh.con.sh/https://raw.githubusercontent.com/Q3dlaXpoaQ/V2rayN_Clash_Node_Getter/main/APIs/sc1.yaml',
        'https://fastly.jsdelivr.net/gh/Q3dlaXpoaQ/V2rayN_Clash_Node_Getter@main/APIs/sc2.yaml',
        'https://raw.githubusercontent.com/Q3dlaXpoaQ/V2rayN_Clash_Node_Getter/main/APIs/sc3.yaml',
      ]),
    );
    expect(q3Candidates.where((url) => url.contains('sc4.yaml')), isEmpty);

    final chengaopanCandidates =
        (findSource('chengaopan-automerge-public-nodes')['rawCandidates']
                as List)
            .cast<String>();
    expect(
      chengaopanCandidates.first,
      'https://gh.con.sh/https://raw.githubusercontent.com/chengaopan/AutoMergePublicNodes/master/list.yml',
    );
    expect(
      chengaopanCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/chengaopan/AutoMergePublicNodes/master/list.yml',
        'https://gh.con.sh/https://raw.githubusercontent.com/chengaopan/AutoMergePublicNodes/master/list.yml',
        'https://fastly.jsdelivr.net/gh/chengaopan/AutoMergePublicNodes@master/list.yml',
        'https://raw.githubusercontent.com/chengaopan/AutoMergePublicNodes/master/list.yml',
      ]),
    );

    final lagzianCandidates =
        (findSource('lagzian-ss-collector')['rawCandidates'] as List)
            .cast<String>();
    expect(lagzianCandidates.first, startsWith('https://ghfile.'));
    expect(
      lagzianCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/lagzian/SS-Collector/main/SS/TrinityBase',
        'https://cdn.jsdelivr.net/gh/lagzian/SS-Collector@main/SS/VM_TrinityBase',
        'https://raw.githubusercontent.com/lagzian/SS-Collector/main/SS/trinity_clash.yaml',
      ]),
    );

    final mfbpnCandidates =
        (findSource('mfbpn-tg-sub')['rawCandidates'] as List).cast<String>();
    expect(mfbpnCandidates.first, startsWith('https://ghfile.'));
    expect(
      mfbpnCandidates,
      containsAll([
        'https://gh.con.sh/https://raw.githubusercontent.com/mfbpn/tg_mfbpn_sub/main/trial.yaml',
        'https://raw.githubusercontent.com/mfbpn/tg_mfbpn_sub/main/trial.yaml',
      ]),
    );

    final zhangkaiCandidates =
        (findSource('zhangkaiitugithub-passcro')['rawCandidates'] as List)
            .cast<String>();
    expect(
      zhangkaiCandidates.first,
      'https://gh.con.sh/https://raw.githubusercontent.com/zhangkaiitugithub/passcro/main/speednodes.yaml',
    );
    expect(
      zhangkaiCandidates,
      containsAll([
        'https://cdn.jsdelivr.net/gh/zhangkaiitugithub/passcro@main/speednodes.yaml',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/zhangkaiitugithub/passcro/main/speednodes.yaml',
        'https://raw.githubusercontent.com/zhangkaiitugithub/passcro/main/speednodes.yaml',
      ]),
    );

    final rukCandidates =
        (findSource('ruk1ng001-freesub')['rawCandidates'] as List)
            .cast<String>();
    expect(
      rukCandidates.first,
      'https://gh.con.sh/https://raw.githubusercontent.com/Ruk1ng001/freeSub/main/clash.yaml',
    );
    expect(
      rukCandidates,
      containsAll([
        'https://cdn.jsdelivr.net/gh/Ruk1ng001/freeSub@main/clash.yaml',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/Ruk1ng001/freeSub/main/clash.yaml',
        'https://raw.githubusercontent.com/Ruk1ng001/freeSub/main/clash.yaml',
      ]),
    );

    final peacefishCandidates =
        (findSource('peacefish-nodefree')['rawCandidates'] as List)
            .cast<String>();
    expect(
      peacefishCandidates.first,
      'https://gh.con.sh/https://raw.githubusercontent.com/peacefish/nodefree/main/sub/proxy_cf.yaml',
    );
    expect(
      peacefishCandidates,
      containsAll([
        'https://cdn.jsdelivr.net/gh/peacefish/nodefree@main/sub/proxy_cf.yaml',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/peacefish/nodefree/main/sub/proxy_cf.yaml',
        'https://raw.githubusercontent.com/peacefish/nodefree/main/sub/proxy_cf.yaml',
      ]),
    );

    final niceVpnCandidates =
        (findSource('nicevpn123-nicevpn')['rawCandidates'] as List)
            .cast<String>();
    expect(
      niceVpnCandidates.first,
      'https://gh.con.sh/https://raw.githubusercontent.com/NiceVPN123/NiceVPN/main/Clash.yaml',
    );
    expect(
      niceVpnCandidates,
      containsAll([
        'https://gh.con.sh/https://raw.githubusercontent.com/NiceVPN123/NiceVPN/main/utils/pool/output.yaml',
        'https://cdn.jsdelivr.net/gh/NiceVPN123/NiceVPN@main/Clash.yaml',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/NiceVPN123/NiceVPN/main/utils/pool/output.yaml',
        'https://raw.githubusercontent.com/NiceVPN123/NiceVPN/main/utils/pool/output.yaml',
      ]),
    );

    final shahidCandidates =
        (findSource('shahidbhutta-clash-router')['rawCandidates'] as List)
            .cast<String>();
    expect(
      shahidCandidates.first,
      'https://gh.con.sh/https://raw.githubusercontent.com/shahidbhutta/Clash/main/Router',
    );
    expect(
      shahidCandidates,
      containsAll([
        'https://cdn.jsdelivr.net/gh/shahidbhutta/Clash@main/Router',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/shahidbhutta/Clash/main/Router',
        'https://raw.githubusercontent.com/shahidbhutta/Clash/main/Router',
      ]),
    );
  });

  test('asset catalog gives every GitHub raw source a ghfile mirror', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map>();
    final missing = <String>[];

    for (final source in sources) {
      final rawCandidates = (source['rawCandidates'] as List? ?? const [])
          .map((item) => item.toString())
          .toList(growable: false);
      if (rawCandidates.isEmpty) continue;
      final hasGithubCandidate = rawCandidates.any((url) {
        return url.contains('raw.githubusercontent.com') ||
            RegExp(r'github\.com/.+/(blob|raw)/').hasMatch(url) ||
            url.contains('api.github.com/repos/') ||
            url.contains('cdn.jsdelivr.net/gh/') ||
            url.contains('fastly.jsdelivr.net/gh/') ||
            url.contains('gcore.jsdelivr.net/gh/');
      });
      if (!hasGithubCandidate) continue;
      final hasGhfile = rawCandidates.any(
        (url) =>
            url.startsWith('https://ghfile.geekertao.top/') ||
            githubMirrorUrlsForTesting(url).any(
              (mirror) => mirror.startsWith('https://ghfile.geekertao.top/'),
            ),
      );
      if (!hasGhfile) {
        missing.add(source['id']?.toString() ?? '<unknown>');
      }
    }

    expect(missing, isEmpty);
  });

  test('asset catalog includes Au1rxx hourly verified subscriptions', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map>();
    final source = sources.singleWhere(
      (item) => item['id'] == 'au1rxx-free-vpn-subscriptions',
    );
    final rawCandidates = (source['rawCandidates'] as List).cast<String>();

    expect(source['githubDiscovery'], true);
    expect(source['updateIntervalHours'], 1);
    expect(rawCandidates.first, startsWith('https://ghfile.geekertao.top/'));
    expect(
      rawCandidates,
      contains(
        'https://fastly.jsdelivr.net/gh/Au1rxx/free-vpn-subscriptions@main/output/clash.yaml',
      ),
    );
    expect(
      rawCandidates,
      containsAll([
        'https://gh.con.sh/https://raw.githubusercontent.com/Au1rxx/free-vpn-subscriptions/main/output/clash.yaml',
        'https://gh.con.sh/https://raw.githubusercontent.com/Au1rxx/free-vpn-subscriptions/main/output/singbox.json',
        'https://gh.con.sh/https://raw.githubusercontent.com/Au1rxx/free-vpn-subscriptions/main/output/v2ray-base64.txt',
        'https://raw.githubusercontent.com/Au1rxx/free-vpn-subscriptions/main/output/clash.yaml',
        'https://raw.githubusercontent.com/Au1rxx/free-vpn-subscriptions/main/output/singbox.json',
        'https://raw.githubusercontent.com/Au1rxx/free-vpn-subscriptions/main/output/v2ray-base64.txt',
      ]),
    );
  });

  test('asset catalog includes additional verified GitHub Clash feeds', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map>();

    Map findSource(String id) {
      return sources.singleWhere((item) => item['id'] == id);
    }

    final itxveCandidates =
        (findSource('itxve-fetch-clash-node')['rawCandidates'] as List)
            .cast<String>();
    final caijhCandidates =
        (findSource('caijh-free-proxies-scraper')['rawCandidates'] as List)
            .cast<String>();

    expect(findSource('itxve-fetch-clash-node')['githubDiscovery'], true);
    expect(itxveCandidates.first, startsWith('https://ghfile.geekertao.top/'));
    expect(
      itxveCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/itxve/fetch-clash-node/main/node/merge.yaml',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/itxve/fetch-clash-node/main/node/NodeShare.yaml',
        'https://gh.con.sh/https://raw.githubusercontent.com/itxve/fetch-clash-node/main/node/merge.yaml',
        'https://gh.con.sh/https://raw.githubusercontent.com/itxve/fetch-clash-node/main/node/NodeShare.yaml',
        'https://cdn.jsdelivr.net/gh/itxve/fetch-clash-node/node/merge.yaml',
        'https://cdn.jsdelivr.net/gh/itxve/fetch-clash-node/node/NodeFree.yaml',
        'https://raw.githubusercontent.com/itxve/fetch-clash-node/main/node/merge.yaml',
      ]),
    );
    expect(
      itxveCandidates,
      isNot(
        contains(
          'https://gh.llkk.cc/https://raw.githubusercontent.com/itxve/fetch-clash-node/main/node/merge.yaml',
        ),
      ),
    );
    expect(findSource('caijh-free-proxies-scraper')['githubDiscovery'], true);
    expect(caijhCandidates.first, startsWith('https://ghfile.geekertao.top/'));
    expect(
      caijhCandidates,
      contains(
        'https://raw.githubusercontent.com/caijh/FreeProxiesScraper/main/Eternity.yaml',
      ),
    );
    expect(
      caijhCandidates,
      contains(
        'https://gh.con.sh/https://raw.githubusercontent.com/caijh/FreeProxiesScraper/main/Eternity.yaml',
      ),
    );
    expect(
      caijhCandidates,
      isNot(
        contains(
          'https://raw.githubusercontent.com/caijh/FreeProxiesScraper/main/Eterniy',
        ),
      ),
    );
  });

  test('asset catalog includes high volume verified raw node feeds', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map>();

    Map findSource(String id) {
      return sources.singleWhere((item) => item['id'] == id);
    }

    final fastNodesCandidates =
        (findSource('rtwo2-fastnodes')['rawCandidates'] as List).cast<String>();
    final gfpcomCandidates =
        (findSource('gfpcom-free-proxy-list-wiki')['rawCandidates'] as List)
            .cast<String>();

    expect(findSource('rtwo2-fastnodes')['githubDiscovery'], false);
    expect(
      fastNodesCandidates,
      equals([
        'https://raw.githubusercontent.com/rtwo2/FastNodes/main/sub/protocols/vless.txt',
        'https://raw.githubusercontent.com/rtwo2/FastNodes/main/sub/protocols/trojan.txt',
        'https://raw.githubusercontent.com/rtwo2/FastNodes/main/sub/protocols/vmess.txt',
        'https://raw.githubusercontent.com/rtwo2/FastNodes/main/sub/protocols/ss.txt',
        'https://raw.githubusercontent.com/rtwo2/FastNodes/main/sub/protocols/hysteria2.txt',
      ]),
    );
    expect(
      fastNodesCandidates.every((url) => url.contains('/protocols/')),
      isTrue,
    );

    expect(findSource('gfpcom-free-proxy-list-wiki')['githubDiscovery'], true);
    expect(gfpcomCandidates.first, startsWith('https://ghfile.geekertao.top/'));
    expect(
      gfpcomCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/wiki/gfpcom/free-proxy-list/lists/vless.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/wiki/gfpcom/free-proxy-list/lists/vmess.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/wiki/gfpcom/free-proxy-list/lists/vless.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/wiki/gfpcom/free-proxy-list/lists/tuic.txt',
        'https://raw.githubusercontent.com/wiki/gfpcom/free-proxy-list/lists/trojan.txt',
        'https://raw.githubusercontent.com/wiki/gfpcom/free-proxy-list/lists/tuic.txt',
      ]),
    );
    expect(
      gfpcomCandidates,
      isNot(
        contains(
          'https://raw.githubusercontent.com/wiki/gfpcom/free-proxy-list/lists/hysteria2.txt',
        ),
      ),
    );
    expect(
      gfpcomCandidates,
      isNot(
        contains(
          'https://cdn.jsdelivr.net/gh/gfpcom/free-proxy-list.wiki@master/lists/vless.txt',
        ),
      ),
    );
  });

  test('asset catalog includes additional multi format GitHub feeds', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map>();

    Map findSource(String id) {
      return sources.singleWhere((item) => item['id'] == id);
    }

    final radikalCandidates =
        (findSource('radikal-free-v2ray-configs')['rawCandidates'] as List)
            .cast<String>();
    final deltaCandidates =
        (findSource('delta-kronecker-v2ray-config')['rawCandidates'] as List)
            .cast<String>();
    final mahdiblandCandidates =
        (findSource('mahdibland-shadowsocks-aggregator')['rawCandidates']
                as List)
            .cast<String>();
    final ssAggregatorCandidates =
        (findSource('mahdibland-ssaggregator')['rawCandidates'] as List)
            .cast<String>();

    expect(findSource('radikal-free-v2ray-configs')['githubDiscovery'], true);
    expect(
      radikalCandidates.first,
      startsWith('https://ghfile.geekertao.top/'),
    );
    expect(
      radikalCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/0xRadikal/Free-v2ray-Configs/main/all/configs.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/0xRadikal/Free-v2ray-Configs/main/all/clash.yaml',
        'https://gh.con.sh/https://raw.githubusercontent.com/0xRadikal/Free-v2ray-Configs/main/all/configs.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/0xRadikal/Free-v2ray-Configs/main/all/singbox.json',
        'https://cdn.jsdelivr.net/gh/0xRadikal/Free-v2ray-Configs@main/all/configs.txt',
        'https://cdn.jsdelivr.net/gh/0xRadikal/Free-v2ray-Configs@main/all/clash.yaml',
        'https://raw.githubusercontent.com/0xRadikal/Free-v2ray-Configs/main/all/configs.txt',
      ]),
    );
    expect(findSource('delta-kronecker-v2ray-config')['githubDiscovery'], true);
    expect(deltaCandidates.first, startsWith('https://ghfile.geekertao.top/'));
    expect(
      deltaCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/Delta-Kronecker/V2ray-Config/main/config/all_configs.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/Delta-Kronecker/V2ray-Config/main/config/all_configs.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/Delta-Kronecker/V2ray-Config/main/config/protocols/vless.txt',
        'https://cdn.jsdelivr.net/gh/Delta-Kronecker/V2ray-Config@main/config/all_configs.txt',
        'https://raw.githubusercontent.com/Delta-Kronecker/V2ray-Config/main/config/all_configs.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/Delta-Kronecker/V2ray-Config/main/config/clash.yaml',
        'https://raw.githubusercontent.com/Delta-Kronecker/V2ray-Config/main/config/clash.yaml',
        'https://cdn.jsdelivr.net/gh/Delta-Kronecker/V2ray-Config@main/config/clash.yaml',
        'https://cdn.jsdelivr.net/gh/Delta-Kronecker/V2ray-Config@main/config/protocols/vless_clash.yaml',
      ]),
    );

    expect(
      findSource('mahdibland-shadowsocks-aggregator')['githubDiscovery'],
      true,
    );
    expect(
      mahdiblandCandidates.first,
      'https://cdn.jsdelivr.net/gh/mahdibland/ShadowsocksAggregator@master/sub/sub_merge.txt',
    );
    expect(
      mahdiblandCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/mahdibland/ShadowsocksAggregator/master/sub/sub_merge.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/mahdibland/ShadowsocksAggregator/master/sub/sub_merge.txt',
        'https://cdn.jsdelivr.net/gh/mahdibland/ShadowsocksAggregator@master/Eternity.yml',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/mahdibland/ShadowsocksAggregator/master/Eternity.yml',
        'https://gh.con.sh/https://raw.githubusercontent.com/mahdibland/ShadowsocksAggregator/master/EternityAir',
        'https://raw.githubusercontent.com/mahdibland/ShadowsocksAggregator/master/Eternity.yml',
        'https://raw.githubusercontent.com/mahdibland/ShadowsocksAggregator/master/Eternity',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/mahdibland/ShadowsocksAggregator/master/EternityAir',
      ]),
    );
    expect(
      mahdiblandCandidates,
      isNot(
        contains(
          'https://cdn.jsdelivr.net/gh/mahdibland/ShadowsocksAggregator@master/Eternity',
        ),
      ),
    );

    expect(findSource('mahdibland-ssaggregator')['githubDiscovery'], true);
    expect(
      ssAggregatorCandidates.first,
      'https://gh.con.sh/https://raw.githubusercontent.com/mahdibland/SSAggregator/master/sub/sub_merge_yaml.yml',
    );
    expect(
      ssAggregatorCandidates,
      containsAll([
        'https://cdn.jsdelivr.net/gh/mahdibland/SSAggregator@master/sub/sub_merge_yaml.yml',
        'https://raw.githubusercontent.com/mahdibland/SSAggregator/master/sub/sub_merge_yaml.yml',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/mahdibland/SSAggregator/master/sub/sub_merge_yaml.yml',
      ]),
    );
  });

  test('asset catalog includes more verified GitHub subscription feeds', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map>();

    Map findSource(String id) {
      return sources.singleWhere((item) => item['id'] == id);
    }

    final barryCandidates =
        (findSource('barry-far-v2ray-config')['rawCandidates'] as List)
            .cast<String>();
    final epodoniosCandidates =
        (findSource('epodonios-v2ray-configs')['rawCandidates'] as List)
            .cast<String>();
    final rayanCandidates =
        (findSource('rayan-config-c-sub')['rawCandidates'] as List)
            .cast<String>();
    final shatakCandidates =
        (findSource('shatakvpn-configforge')['rawCandidates'] as List)
            .cast<String>();
    final limilcoCandidates =
        (findSource('limilco-v2r')['rawCandidates'] as List).cast<String>();

    expect(findSource('barry-far-v2ray-config')['githubDiscovery'], true);
    expect(barryCandidates.first, startsWith('https://cdn.jsdelivr.net/'));
    expect(
      barryCandidates,
      containsAll([
        'https://cdn.jsdelivr.net/gh/barry-far/V2ray-config@main/All_Configs_Sub.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/barry-far/V2ray-config/main/All_Configs_Sub.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/barry-far/V2ray-config/main/All_Configs_Sub.txt',
        'https://raw.githubusercontent.com/barry-far/V2ray-config/main/All_Configs_Sub.txt',
      ]),
    );

    expect(findSource('epodonios-v2ray-configs')['githubDiscovery'], true);
    expect(epodoniosCandidates.first, startsWith('https://cdn.jsdelivr.net/'));
    expect(
      epodoniosCandidates,
      containsAll([
        'https://cdn.jsdelivr.net/gh/Epodonios/v2ray-configs@main/All_Configs_Sub.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/Epodonios/v2ray-configs/main/All_Configs_Sub.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/Epodonios/v2ray-configs/main/All_Configs_Sub.txt',
        'https://raw.githubusercontent.com/Epodonios/v2ray-configs/main/All_Configs_Sub.txt',
      ]),
    );

    expect(findSource('rayan-config-c-sub')['githubDiscovery'], true);
    expect(rayanCandidates.first, startsWith('https://cdn.jsdelivr.net/'));
    expect(
      rayanCandidates,
      containsAll([
        'https://cdn.jsdelivr.net/gh/Rayan-Config/C-Sub@main/configs/proxy.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/Rayan-Config/C-Sub/main/configs/proxy.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/Rayan-Config/C-Sub/main/configs/proxy.txt',
        'https://raw.githubusercontent.com/Rayan-Config/C-Sub/main/configs/proxy.txt',
      ]),
    );

    expect(findSource('shatakvpn-configforge')['githubDiscovery'], true);
    expect(
      shatakCandidates,
      containsAll([
        'https://cdn.jsdelivr.net/gh/ShatakVPN/ConfigForge@main/configs/all.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/ShatakVPN/ConfigForge/main/configs/all.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/ShatakVPN/ConfigForge/main/configs/all.txt',
        'https://raw.githubusercontent.com/ShatakVPN/ConfigForge/main/configs/all.txt',
      ]),
    );

    expect(findSource('limilco-v2r')['githubDiscovery'], true);
    expect(
      limilcoCandidates,
      containsAll([
        'https://cdn.jsdelivr.net/gh/liMilCo/v2r@main/pro/vless.txt',
        'https://cdn.jsdelivr.net/gh/liMilCo/v2r@main/pro/vmess.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/liMilCo/v2r/main/pro/vless.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/liMilCo/v2r/main/pro/vless.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/liMilCo/v2r/main/pro/ss.txt',
        'https://raw.githubusercontent.com/liMilCo/v2r/main/pro/ss.txt',
      ]),
    );
  });

  test('asset catalog includes verified crawler and parser feeds', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map>();

    Map findSource(String id) {
      return sources.singleWhere((item) => item['id'] == id);
    }

    final shatakCandidates =
        (findSource('shatakvpn-configforge-v2ray')['rawCandidates'] as List)
            .cast<String>();
    final tgparseCandidates =
        (findSource('surfboardv2ray-tgparse')['rawCandidates'] as List)
            .cast<String>();
    final subcrawlerCandidates =
        (findSource('leon406-subcrawler')['rawCandidates'] as List)
            .cast<String>();
    final nomorewallsCandidates =
        (findSource('peasoft-nomorewalls')['rawCandidates'] as List)
            .cast<String>();

    expect(findSource('shatakvpn-configforge-v2ray')['githubDiscovery'], true);
    expect(shatakCandidates.first, startsWith('https://cdn.jsdelivr.net/'));
    expect(
      shatakCandidates,
      containsAll([
        'https://cdn.jsdelivr.net/gh/ShatakVPN/ConfigForge-V2Ray@main/configs/all.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/ShatakVPN/ConfigForge-V2Ray/main/configs/all.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/ShatakVPN/ConfigForge-V2Ray/main/configs/all.txt',
        'https://raw.githubusercontent.com/ShatakVPN/ConfigForge-V2Ray/main/configs/all.txt',
      ]),
    );

    expect(findSource('surfboardv2ray-tgparse')['githubDiscovery'], true);
    expect(
      tgparseCandidates.first,
      startsWith('https://ghfile.geekertao.top/'),
    );
    expect(
      tgparseCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/Surfboardv2ray/TGParse/main/configtg.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/Surfboardv2ray/TGParse/main/configtg.txt',
        'https://cdn.jsdelivr.net/gh/Surfboardv2ray/TGParse@main/configtg.txt',
        'https://raw.githubusercontent.com/Surfboardv2ray/TGParse/main/configtg.txt',
      ]),
    );

    expect(findSource('leon406-subcrawler')['githubDiscovery'], true);
    expect(
      subcrawlerCandidates.first,
      startsWith('https://ghfile.geekertao.top/'),
    );
    expect(
      subcrawlerCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/Leon406/SubCrawler/main/sub/share/vless',
        'https://gh.con.sh/https://raw.githubusercontent.com/Leon406/SubCrawler/main/sub/share/vless',
        'https://gh.con.sh/https://raw.githubusercontent.com/Leon406/SubCrawler/main/sub/share/a11',
        'https://cdn.jsdelivr.net/gh/Leon406/SubCrawler@main/sub/share/vless',
        'https://raw.githubusercontent.com/Leon406/SubCrawler/main/sub/share/hysteria2',
      ]),
    );
    expect(
      subcrawlerCandidates,
      isNot(
        contains(
          'https://raw.githubusercontent.com/Leon406/SubCrawler/main/sub/share/all.txt',
        ),
      ),
    );

    expect(findSource('peasoft-nomorewalls')['githubDiscovery'], true);
    expect(
      nomorewallsCandidates.first,
      startsWith('https://ghfile.geekertao.top/'),
    );
    expect(
      nomorewallsCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/peasoft/NoMoreWalls/master/list_raw.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/peasoft/NoMoreWalls/master/list_raw.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/peasoft/NoMoreWalls/master/list.yml',
        'https://cdn.jsdelivr.net/gh/peasoft/NoMoreWalls@master/list_raw.txt',
        'https://raw.githubusercontent.com/peasoft/NoMoreWalls/master/list.yml',
      ]),
    );
  });

  test('asset catalog includes additional verified collector feeds', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map>();

    Map findSource(String id) {
      return sources.singleWhere((item) => item['id'] == id);
    }

    final matinCandidates =
        (findSource('matin-ghanbari-v2ray-configs')['rawCandidates'] as List)
            .cast<String>();
    final arghCandidates =
        (findSource('argh94-proxy-list')['rawCandidates'] as List)
            .cast<String>();
    final hamedCandidates =
        (findSource('hamedcode-port-based-v2ray-configs')['rawCandidates']
                as List)
            .cast<String>();
    final mheidariCandidates =
        (findSource('mheidari98-proxy')['rawCandidates'] as List)
            .cast<String>();
    final mahdiCandidates =
        (findSource('mahdi0024-proxycollector')['rawCandidates'] as List)
            .cast<String>();
    final roosterCandidates =
        (findSource('roosterkid-openproxylist')['rawCandidates'] as List)
            .cast<String>();
    final stinsonCandidates =
        (findSource('stinsonysm-go-v2raycollector')['rawCandidates'] as List)
            .cast<String>();

    expect(findSource('matin-ghanbari-v2ray-configs')['githubDiscovery'], true);
    expect(
      matinCandidates.first,
      startsWith('https://raw.githubusercontent.com/'),
    );
    expect(
      matinCandidates,
      containsAll([
        'https://raw.githubusercontent.com/MatinGhanbari/v2ray-configs/main/subscriptions/v2ray/all_sub.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/MatinGhanbari/v2ray-configs/main/subscriptions/v2ray/all_sub.txt',
        'https://cdn.jsdelivr.net/gh/MatinGhanbari/v2ray-configs@main/subscriptions/v2ray/all_sub.txt',
        'https://cdn.jsdelivr.net/gh/MatinGhanbari/v2ray-configs@main/subscriptions/v2ray/super-sub.txt',
        'https://cdn.jsdelivr.net/gh/MatinGhanbari/v2ray-configs@main/subscriptions/v2ray/subs/sub1.txt',
        'https://cdn.jsdelivr.net/gh/MatinGhanbari/v2ray-configs@main/subscriptions/v2ray/subs/sub10.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/MatinGhanbari/v2ray-configs/main/subscriptions/v2ray/super-sub.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/MatinGhanbari/v2ray-configs/main/subscriptions/v2ray/subs/sub1.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/MatinGhanbari/v2ray-configs/main/subscriptions/v2ray/subs/sub10.txt',
        'https://raw.githubusercontent.com/MatinGhanbari/v2ray-configs/main/subscriptions/v2ray/super-sub.txt',
        'https://raw.githubusercontent.com/MatinGhanbari/v2ray-configs/main/subscriptions/v2ray/subs/sub10.txt',
        'https://cdn.jsdelivr.net/gh/MatinGhanbari/v2ray-configs@main/subscriptions/filtered/subs/vmess.txt',
        'https://raw.githubusercontent.com/MatinGhanbari/v2ray-configs/main/subscriptions/filtered/subs/hysteria2.txt',
      ]),
    );
    expect(
      matinCandidates,
      isNot(
        contains(
          'https://raw.githubusercontent.com/MatinGhanbari/v2ray-configs/main/subscriptions/v2ray/subs/sub1.txt',
        ),
      ),
    );
    expect(
      matinCandidates,
      isNot(
        contains(
          'https://raw.githubusercontent.com/MatinGhanbari/v2ray-configs/main/subscriptions/filtered/subs/shadowsocks.txt',
        ),
      ),
    );

    expect(findSource('argh94-proxy-list')['githubDiscovery'], true);
    expect(
      arghCandidates,
      containsAll([
        'https://cdn.jsdelivr.net/gh/Argh94/Proxy-List@main/All_Config.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/Argh94/Proxy-List/main/All_Config.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/Argh94/Proxy-List/main/All_Config.txt',
        'https://raw.githubusercontent.com/Argh94/Proxy-List/main/All_Config.txt',
      ]),
    );

    expect(
      findSource('hamedcode-port-based-v2ray-configs')['githubDiscovery'],
      true,
    );
    expect(
      hamedCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/hamedcode/port-based-v2ray-configs/main/sub/vless.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/hamedcode/port-based-v2ray-configs/main/sub/vless.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/hamedcode/port-based-v2ray-configs/main/sub/other.txt',
        'https://cdn.jsdelivr.net/gh/hamedcode/port-based-v2ray-configs@main/sub/trojan.txt',
        'https://raw.githubusercontent.com/hamedcode/port-based-v2ray-configs/main/sub/other.txt',
      ]),
    );
    expect(
      hamedCandidates,
      isNot(
        contains(
          'https://raw.githubusercontent.com/hamedcode/port-based-v2ray-configs/main/subscriptions/normal/mix',
        ),
      ),
    );

    expect(findSource('mheidari98-proxy')['githubDiscovery'], true);
    expect(
      mheidariCandidates.first,
      startsWith('https://ghfile.geekertao.top/'),
    );
    expect(
      mheidariCandidates,
      contains('https://raw.githubusercontent.com/mheidari98/.proxy/main/all'),
    );
    expect(
      mheidariCandidates,
      isNot(contains('https://cdn.jsdelivr.net/gh/mheidari98/.proxy@main/all')),
    );

    expect(findSource('mahdi0024-proxycollector')['githubDiscovery'], true);
    expect(mahdiCandidates.first, startsWith('https://ghfile.geekertao.top/'));
    expect(findSource('roosterkid-openproxylist')['githubDiscovery'], true);
    expect(roosterCandidates.first, startsWith('https://cdn.jsdelivr.net/'));
    expect(
      roosterCandidates,
      contains(
        'https://gh.con.sh/https://raw.githubusercontent.com/roosterkid/openproxylist/main/V2RAY_BASE64.txt',
      ),
    );
    expect(findSource('stinsonysm-go-v2raycollector')['githubDiscovery'], true);
    expect(
      stinsonCandidates,
      containsAll([
        'https://cdn.jsdelivr.net/gh/Stinsonysm/GO_V2rayCollector@main/mixed_iran.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/Stinsonysm/GO_V2rayCollector/main/mixed_iran.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/Stinsonysm/GO_V2rayCollector/main/mixed_iran.txt',
      ]),
    );
  });

  test('asset catalog includes high volume verified v2ray collectors', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map>();

    Map findSource(String id) {
      return sources.singleWhere((item) => item['id'] == id);
    }

    const sourceIds = {
      'danialsamadi-v2go',
      'm450ud-v2ray-configs',
      'coldwater-v2ray-config-lite',
      'v2rayroot-v2rayconfig',
      'mohamadfg-telegram-v2ray-configs',
      'miladtahanian-v2ray-scrape-by-country',
      'mfuu-v2ray',
    };
    for (final sourceId in sourceIds) {
      expect(findSource(sourceId)['githubDiscovery'], true, reason: sourceId);
    }

    final v2goCandidates =
        (findSource('danialsamadi-v2go')['rawCandidates'] as List)
            .cast<String>();
    final m450udCandidates =
        (findSource('m450ud-v2ray-configs')['rawCandidates'] as List)
            .cast<String>();
    final coldwaterCandidates =
        (findSource('coldwater-v2ray-config-lite')['rawCandidates'] as List)
            .cast<String>();
    final v2rayRootCandidates =
        (findSource('v2rayroot-v2rayconfig')['rawCandidates'] as List)
            .cast<String>();
    final mohamadfgCandidates =
        (findSource('mohamadfg-telegram-v2ray-configs')['rawCandidates']
                as List)
            .cast<String>();
    final miladtahanianCandidates =
        (findSource('miladtahanian-v2ray-scrape-by-country')['rawCandidates']
                as List)
            .cast<String>();
    final mfuuCandidates = (findSource('mfuu-v2ray')['rawCandidates'] as List)
        .cast<String>();

    expect(v2goCandidates.first, startsWith('https://ghfile.geekertao.top/'));
    expect(
      v2goCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/Danialsamadi/v2go/main/AllConfigsSub.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/Danialsamadi/v2go/main/AllConfigsSub.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/Danialsamadi/v2go/main/Splitted-By-Protocol/hy2.txt',
        'https://cdn.jsdelivr.net/gh/Danialsamadi/v2go@main/Splitted-By-Protocol/vless.txt',
        'https://raw.githubusercontent.com/Danialsamadi/v2go/main/Splitted-By-Protocol/hy2.txt',
      ]),
    );
    expect(
      v2goCandidates,
      isNot(
        contains(
          'https://raw.githubusercontent.com/Danialsamadi/v2go/main/Splitted-By-Protocol/tuic.txt',
        ),
      ),
    );

    expect(m450udCandidates.first, startsWith('https://ghfile.geekertao.top/'));
    expect(
      m450udCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/M450ud/V2ray-Configs/refs/heads/main/All_Configs_Sub.txt',
        'https://cdn.jsdelivr.net/gh/M450ud/V2ray-Configs@main/All_Configs_Sub.txt',
        'https://raw.githubusercontent.com/M450ud/V2ray-Configs/refs/heads/main/All_Configs_Sub.txt',
      ]),
    );

    expect(
      coldwaterCandidates.first,
      startsWith('https://ghfile.geekertao.top/'),
    );
    expect(
      coldwaterCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/coldwater-10/V2ray-Config-Lite/main/All_Configs_Sub.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/coldwater-10/V2ray-Config-Lite/main/All_Configs_Sub.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/coldwater-10/V2ray-Config-Lite/main/Splitted-By-Protocol/tuic.txt',
        'https://cdn.jsdelivr.net/gh/coldwater-10/V2ray-Config-Lite@main/All_Configs_Sub.txt',
        'https://raw.githubusercontent.com/coldwater-10/V2ray-Config-Lite/main/Splitted-By-Protocol/trojan.txt',
      ]),
    );

    expect(
      v2rayRootCandidates.first,
      startsWith('https://ghfile.geekertao.top/'),
    );
    expect(
      v2rayRootCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/V2RayRoot/V2RayConfig/main/Config/vless.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/V2RayRoot/V2RayConfig/main/Config/vless.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/V2RayRoot/V2RayConfig/main/Config/shadowsocks.txt',
        'https://cdn.jsdelivr.net/gh/V2RayRoot/V2RayConfig@main/Config/vmess.txt',
        'https://raw.githubusercontent.com/V2RayRoot/V2RayConfig/main/Config/shadowsocks.txt',
      ]),
    );

    expect(
      mohamadfgCandidates.first,
      startsWith('https://ghfile.geekertao.top/'),
    );
    expect(
      mohamadfgCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/mohamadfg-dev/telegram-v2ray-configs-collector/refs/heads/main/category/vless.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/mohamadfg-dev/telegram-v2ray-configs-collector/refs/heads/main/category/vless.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/mohamadfg-dev/telegram-v2ray-configs-collector/refs/heads/main/category/wireguard.txt',
        'https://cdn.jsdelivr.net/gh/mohamadfg-dev/telegram-v2ray-configs-collector@main/category/trojan.txt',
        'https://raw.githubusercontent.com/mohamadfg-dev/telegram-v2ray-configs-collector/refs/heads/main/category/vmess.txt',
      ]),
    );

    expect(
      miladtahanianCandidates.first,
      startsWith('https://ghfile.geekertao.top/'),
    );
    expect(
      miladtahanianCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/miladtahanian/V2RayScrapeByCountry/refs/heads/main/output_configs/Vless.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/miladtahanian/V2RayScrapeByCountry/refs/heads/main/output_configs/Vless.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/miladtahanian/V2RayScrapeByCountry/refs/heads/main/output_configs/Trojan.txt',
        'https://cdn.jsdelivr.net/gh/miladtahanian/V2RayScrapeByCountry@main/output_configs/Trojan.txt',
        'https://raw.githubusercontent.com/miladtahanian/V2RayScrapeByCountry/refs/heads/main/output_configs/ShadowSocks.txt',
      ]),
    );
    expect(
      miladtahanianCandidates,
      isNot(
        contains(
          'https://raw.githubusercontent.com/miladtahanian/V2RayScrapeByCountry/refs/heads/main/output_configs/WireGuard.txt',
        ),
      ),
    );

    expect(mfuuCandidates.first, startsWith('https://cdn.jsdelivr.net/'));
    expect(
      mfuuCandidates,
      containsAll([
        'https://cdn.jsdelivr.net/gh/mfuu/v2ray@master/v2ray',
        'https://cdn.jsdelivr.net/gh/mfuu/v2ray@master/clash.yaml',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/mfuu/v2ray/master/v2ray',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/mfuu/v2ray/master/clash.yaml',
        'https://raw.githubusercontent.com/mfuu/v2ray/master/v2ray',
        'https://raw.githubusercontent.com/mfuu/v2ray/master/clash.yaml',
      ]),
    );
    expect(
      mfuuCandidates,
      isNot(
        contains(
          'https://raw.githubusercontent.com/mfuu/v2ray/master/merge/merge.txt',
        ),
      ),
    );
  });

  test('asset catalog includes balanced high volume v2ray collectors', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map>();

    Map findSource(String id) {
      return sources.singleWhere((item) => item['id'] == id);
    }

    const sourceIds = {
      'm-mashreghi-free-v2ray-collector',
      'ebrasha-free-v2ray-public-list',
      'alirewa-v2ray-configs',
      'freefolkson-abc-configs',
      'sevcator-5ubscrpt10n',
      'mhditaheri-v2raycollector',
      'lalatinahub-mineral',
      'aliilapro-v2rayng-config',
      'mostafasadeghifar-v2ray-config',
      'youfoundamin-v2raycollector',
      'mosifree-free2config',
      'mahsanet-config-topic',
    };
    for (final sourceId in sourceIds) {
      expect(findSource(sourceId)['githubDiscovery'], true, reason: sourceId);
    }

    final mashreghiCandidates =
        (findSource('m-mashreghi-free-v2ray-collector')['rawCandidates']
                as List)
            .cast<String>();
    final ebrashaCandidates =
        (findSource('ebrasha-free-v2ray-public-list')['rawCandidates'] as List)
            .cast<String>();
    final alirewaCandidates =
        (findSource('alirewa-v2ray-configs')['rawCandidates'] as List)
            .cast<String>();
    final abcConfigsCandidates =
        (findSource('freefolkson-abc-configs')['rawCandidates'] as List)
            .cast<String>();
    final sevcatorCandidates =
        (findSource('sevcator-5ubscrpt10n')['rawCandidates'] as List)
            .cast<String>();
    final taheriCandidates =
        (findSource('mhditaheri-v2raycollector')['rawCandidates'] as List)
            .cast<String>();
    final lalatinaCandidates =
        (findSource('lalatinahub-mineral')['rawCandidates'] as List)
            .cast<String>();
    final aliilaproCandidates =
        (findSource('aliilapro-v2rayng-config')['rawCandidates'] as List)
            .cast<String>();
    final mostafaCandidates =
        (findSource('mostafasadeghifar-v2ray-config')['rawCandidates'] as List)
            .cast<String>();
    final youfoundaminCandidates =
        (findSource('youfoundamin-v2raycollector')['rawCandidates'] as List)
            .cast<String>();
    final mosifreeCandidates =
        (findSource('mosifree-free2config')['rawCandidates'] as List)
            .cast<String>();
    final mahsanetCandidates =
        (findSource('mahsanet-config-topic')['rawCandidates'] as List)
            .cast<String>();

    expect(mashreghiCandidates.first, startsWith('https://cdn.jsdelivr.net/'));
    expect(
      mashreghiCandidates,
      containsAll([
        'https://cdn.jsdelivr.net/gh/M-Mashreghi/Free-V2ray-Collector@main/All_Configs_Sub.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/M-Mashreghi/Free-V2ray-Collector/refs/heads/main/All_Configs_Sub.txt',
        'https://raw.githubusercontent.com/M-Mashreghi/Free-V2ray-Collector/refs/heads/main/All_Configs_Sub.txt',
      ]),
    );

    expect(
      ebrashaCandidates,
      contains(
        predicate<String>(
          (url) => url.startsWith('https://ghfile.geekertao.top/'),
        ),
      ),
    );
    expect(
      ebrashaCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/ebrasha/free-v2ray-public-list/refs/heads/main/trojan_configs.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/ebrasha/free-v2ray-public-list/main/vless_configs.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/ebrasha/free-v2ray-public-list/refs/heads/main/vless_configs.txt',
        'https://cdn.jsdelivr.net/gh/ebrasha/free-v2ray-public-list@main/ss_configs.txt',
        'https://raw.githubusercontent.com/ebrasha/free-v2ray-public-list/refs/heads/main/vmess_configs.txt',
        'https://raw.githubusercontent.com/ebrasha/free-v2ray-public-list/refs/heads/main/vless_configs.txt',
      ]),
    );
    expect(
      ebrashaCandidates,
      isNot(
        contains(
          'https://raw.githubusercontent.com/ebrasha/free-v2ray-public-list/refs/heads/main/all_extracted_configs.txt',
        ),
      ),
    );
    expect(alirewaCandidates.first, startsWith('https://cdn.jsdelivr.net/'));
    expect(
      alirewaCandidates,
      containsAll([
        'https://cdn.jsdelivr.net/gh/Alirewa/V2ray-Configs@main/config.txt',
        'https://cdn.jsdelivr.net/gh/Alirewa/V2ray-Configs@main/sub1.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/Alirewa/V2ray-Configs/main/config.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/Alirewa/V2ray-Configs/main/config.txt',
        'https://raw.githubusercontent.com/Alirewa/V2ray-Configs/main/sub3.txt',
      ]),
    );

    expect(abcConfigsCandidates.first, startsWith('https://cdn.jsdelivr.net/'));
    expect(findSource('freefolkson-abc-configs')['pageDiscovery'], true);
    expect(
      abcConfigsCandidates,
      containsAll([
        'https://cdn.jsdelivr.net/gh/FreeFolksOn/abc-configs-free-vpn-proxy-list@main/README.md',
        'https://gh.con.sh/https://raw.githubusercontent.com/FreeFolksOn/abc-configs-free-vpn-proxy-list/main/README.md',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/FreeFolksOn/abc-configs-free-vpn-proxy-list/main/README.md',
        'https://raw.githubusercontent.com/FreeFolksOn/abc-configs-free-vpn-proxy-list/main/README.md',
      ]),
    );

    expect(
      sevcatorCandidates.first,
      startsWith('https://ghfile.geekertao.top/'),
    );
    expect(
      sevcatorCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/sevcator/5ubscrpt10n/main/protocols/vl.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/sevcator/5ubscrpt10n/main/protocols/tr.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/sevcator/5ubscrpt10n/main/protocols/vl.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/sevcator/5ubscrpt10n/main/protocols/ss.txt',
        'https://cdn.jsdelivr.net/gh/sevcator/5ubscrpt10n@main/protocols/ss.txt',
        'https://raw.githubusercontent.com/sevcator/5ubscrpt10n/main/protocols/vl.txt',
        'https://raw.githubusercontent.com/sevcator/5ubscrpt10n/main/protocols/ss.txt',
      ]),
    );
    expect(
      sevcatorCandidates,
      isNot(
        contains(
          'https://raw.githubusercontent.com/sevcator/5ubscrpt10n/main/full/5ubscrpt10n.txt',
        ),
      ),
    );
    expect(taheriCandidates.first, startsWith('https://ghfile.geekertao.top/'));
    expect(
      taheriCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/MhdiTaheri/V2rayCollector/main/sub/mix',
        'https://gh.con.sh/https://raw.githubusercontent.com/MhdiTaheri/V2rayCollector/main/sub/mix',
        'https://gh.con.sh/https://raw.githubusercontent.com/MhdiTaheri/V2rayCollector/main/sub/hysteriabase64',
        'https://cdn.jsdelivr.net/gh/MhdiTaheri/V2rayCollector@main/sub/hysteriabase64',
        'https://raw.githubusercontent.com/MhdiTaheri/V2rayCollector/main/sub/mix',
      ]),
    );

    expect(
      lalatinaCandidates.first,
      startsWith('https://ghfile.geekertao.top/'),
    );
    expect(
      lalatinaCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/LalatinaHub/Mineral/refs/heads/master/result/nodes',
        'https://gh.con.sh/https://raw.githubusercontent.com/LalatinaHub/Mineral/refs/heads/master/result/nodes',
        'https://cdn.jsdelivr.net/gh/LalatinaHub/Mineral@master/result/nodes',
        'https://raw.githubusercontent.com/LalatinaHub/Mineral/refs/heads/master/result/nodes',
      ]),
    );

    expect(
      aliilaproCandidates.first,
      startsWith('https://ghfile.geekertao.top/'),
    );
    expect(
      aliilaproCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/ALIILAPRO/v2rayNG-Config/main/sub.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/ALIILAPRO/v2rayNG-Config/main/sub.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/ALIILAPRO/v2rayNG-Config/main/server.txt',
        'https://cdn.jsdelivr.net/gh/ALIILAPRO/v2rayNG-Config@main/server.txt',
        'https://raw.githubusercontent.com/ALIILAPRO/v2rayNG-Config/main/server.txt',
      ]),
    );

    expect(
      mostafaCandidates.first,
      startsWith('https://ghfile.geekertao.top/'),
    );
    expect(
      mostafaCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/mostafasadeghifar/v2ray-config/main/config_file.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/mostafasadeghifar/v2ray-config/main/config_file.txt',
        'https://cdn.jsdelivr.net/gh/mostafasadeghifar/v2ray-config@main/config_file.txt',
        'https://raw.githubusercontent.com/mostafasadeghifar/v2ray-config/main/config_file.txt',
      ]),
    );

    expect(
      youfoundaminCandidates.first,
      startsWith('https://ghfile.geekertao.top/'),
    );
    expect(
      youfoundaminCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/youfoundamin/V2rayCollector/main/mixed_iran.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/youfoundamin/V2rayCollector/main/mixed_iran.txt',
        'https://cdn.jsdelivr.net/gh/youfoundamin/V2rayCollector@main/mixed_iran.txt',
        'https://raw.githubusercontent.com/youfoundamin/V2rayCollector/main/mixed_iran.txt',
      ]),
    );

    expect(
      mosifreeCandidates.first,
      startsWith('https://ghfile.geekertao.top/'),
    );
    expect(
      mosifreeCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/Mosifree/-FREE2CONFIG/refs/heads/main/Reality',
        'https://gh.con.sh/https://raw.githubusercontent.com/Mosifree/-FREE2CONFIG/refs/heads/main/Reality',
        'https://gh.con.sh/https://raw.githubusercontent.com/Mosifree/-FREE2CONFIG/refs/heads/main/SS',
        'https://cdn.jsdelivr.net/gh/Mosifree/-FREE2CONFIG@main/SS',
        'https://raw.githubusercontent.com/Mosifree/-FREE2CONFIG/refs/heads/main/SS',
      ]),
    );
    expect(
      mosifreeCandidates,
      isNot(
        contains(
          'https://raw.githubusercontent.com/Mosifree/-FREE2CONFIG/refs/heads/main/Vless',
        ),
      ),
    );

    expect(
      mahsanetCandidates.first,
      startsWith('https://ghfile.geekertao.top/'),
    );
    expect(
      mahsanetCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/MahsaNetConfigTopic/config/refs/heads/main/xray_final.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/MahsaNetConfigTopic/config/refs/heads/main/xray_final.txt',
        'https://cdn.jsdelivr.net/gh/MahsaNetConfigTopic/config@main/xray_final.txt',
        'https://raw.githubusercontent.com/MahsaNetConfigTopic/config/refs/heads/main/xray_final.txt',
      ]),
    );
  });

  test('asset catalog includes additional mirrored v2ray collector feeds', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map>();

    Map findSource(String id) {
      return sources.singleWhere((item) => item['id'] == id);
    }

    const sourceIds = {
      'argh94-v2ray-auto-config',
      'cnoc-configs-collector-v2ray',
      'kolandone-v2raycollector',
      'solispirit-v2ray-configs',
      'shabane-kamaji',
      'igareck-vpn-configs-for-russia',
      'yasserdivar-pr0xy',
      'kwinshadow-telegram-v2raycollector',
      'codingbox-free-node-merge',
    };
    for (final sourceId in sourceIds) {
      expect(findSource(sourceId)['githubDiscovery'], true, reason: sourceId);
    }

    final arghCandidates =
        (findSource('argh94-v2ray-auto-config')['rawCandidates'] as List)
            .cast<String>();
    final cnocCandidates =
        (findSource('cnoc-configs-collector-v2ray')['rawCandidates'] as List)
            .cast<String>();
    final kolandoneCandidates =
        (findSource('kolandone-v2raycollector')['rawCandidates'] as List)
            .cast<String>();
    final solispiritCandidates =
        (findSource('solispirit-v2ray-configs')['rawCandidates'] as List)
            .cast<String>();
    final shabaneCandidates =
        (findSource('shabane-kamaji')['rawCandidates'] as List).cast<String>();
    final igareckCandidates =
        (findSource('igareck-vpn-configs-for-russia')['rawCandidates'] as List)
            .cast<String>();
    final yasserCandidates =
        (findSource('yasserdivar-pr0xy')['rawCandidates'] as List)
            .cast<String>();
    final kwinshadowCandidates =
        (findSource('kwinshadow-telegram-v2raycollector')['rawCandidates']
                as List)
            .cast<String>();
    final codingboxCandidates =
        (findSource('codingbox-free-node-merge')['rawCandidates'] as List)
            .cast<String>();

    expect(arghCandidates.first, startsWith('https://cdn.jsdelivr.net/'));
    expect(
      arghCandidates,
      containsAll([
        'https://cdn.jsdelivr.net/gh/Argh94/V2RayAutoConfig@main/configs/Trojan.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/Argh94/V2RayAutoConfig/refs/heads/main/configs/Vmess.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/Argh94/V2RayAutoConfig/refs/heads/main/configs/Trojan.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/Argh94/V2RayAutoConfig/refs/heads/main/configs/Hysteria2.txt',
        'https://raw.githubusercontent.com/Argh94/V2RayAutoConfig/refs/heads/main/configs/Hysteria2.txt',
      ]),
    );
    expect(
      arghCandidates,
      isNot(
        contains(
          'https://raw.githubusercontent.com/Argh94/V2RayAutoConfig/refs/heads/main/configs/Vless.txt',
        ),
      ),
    );
    expect(
      arghCandidates,
      isNot(
        contains(
          'https://raw.githubusercontent.com/Argh94/V2RayAutoConfig/refs/heads/main/configs/ShadowSocks.txt',
        ),
      ),
    );

    expect(cnocCandidates.first, startsWith('https://ghfile.geekertao.top/'));
    expect(
      cnocCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/217CnoC/configs-collector-v2ray/refs/heads/main/sub/all_configs.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/217CnoC/configs-collector-v2ray/refs/heads/main/sub/all_configs.txt',
        'https://cdn.jsdelivr.net/gh/217CnoC/configs-collector-v2ray@main/sub/all_configs.txt',
        'https://raw.githubusercontent.com/217CnoC/configs-collector-v2ray/refs/heads/main/sub/all_configs.txt',
      ]),
    );

    expect(
      kolandoneCandidates.first,
      startsWith('https://ghfile.geekertao.top/'),
    );
    expect(
      kolandoneCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/Kolandone/v2raycollector/refs/heads/main/config.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/Kolandone/v2raycollector/refs/heads/main/config.txt',
        'https://cdn.jsdelivr.net/gh/Kolandone/v2raycollector@main/config.txt',
        'https://raw.githubusercontent.com/Kolandone/v2raycollector/refs/heads/main/config.txt',
      ]),
    );

    expect(solispiritCandidates.first, startsWith('https://cdn.jsdelivr.net/'));
    expect(
      solispiritCandidates,
      containsAll([
        'https://cdn.jsdelivr.net/gh/SoliSpirit/v2ray-configs@main/all_configs.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/SoliSpirit/v2ray-configs/main/all_configs.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/SoliSpirit/v2ray-configs/refs/heads/main/all_configs.txt',
        'https://raw.githubusercontent.com/SoliSpirit/v2ray-configs/refs/heads/main/all_configs.txt',
      ]),
    );

    expect(shabaneCandidates.first, startsWith('https://cdn.jsdelivr.net/'));
    expect(
      shabaneCandidates,
      containsAll([
        'https://cdn.jsdelivr.net/gh/shabane/kamaji@master/hub/merged.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/shabane/kamaji/master/hub/merged.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/shabane/kamaji/refs/heads/master/hub/merged.txt',
        'https://raw.githubusercontent.com/shabane/kamaji/refs/heads/master/hub/merged.txt',
      ]),
    );

    expect(igareckCandidates.first, startsWith('https://cdn.jsdelivr.net/'));
    expect(
      igareckCandidates,
      containsAll([
        'https://cdn.jsdelivr.net/gh/igareck/vpn-configs-for-russia@main/BLACK_VLESS_RUS.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/igareck/vpn-configs-for-russia/refs/heads/main/BLACK_VLESS_RUS.txt',
        'https://raw.githubusercontent.com/igareck/vpn-configs-for-russia/refs/heads/main/BLACK_VLESS_RUS.txt',
      ]),
    );

    expect(yasserCandidates.first, startsWith('https://cdn.jsdelivr.net/'));
    expect(
      yasserCandidates,
      containsAll([
        'https://cdn.jsdelivr.net/gh/YasserDivaR/pr0xy@main/ShadowSocks2021.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/YasserDivaR/pr0xy/refs/heads/main/ShadowSocks2021.txt',
        'https://raw.githubusercontent.com/YasserDivaR/pr0xy/refs/heads/main/ShadowSocks2021.txt',
      ]),
    );

    expect(
      kwinshadowCandidates.first,
      startsWith('https://ghfile.geekertao.top/'),
    );
    expect(
      kwinshadowCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/Kwinshadow/TelegramV2rayCollector/refs/heads/main/sublinks/mix.txt',
        'https://cdn.jsdelivr.net/gh/Kwinshadow/TelegramV2rayCollector@main/sublinks/mix.txt',
        'https://raw.githubusercontent.com/Kwinshadow/TelegramV2rayCollector/refs/heads/main/sublinks/mix.txt',
      ]),
    );

    expect(
      codingboxCandidates.first,
      startsWith('https://ghfile.geekertao.top/'),
    );
    expect(
      codingboxCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/codingbox/Free-Node-Merge/main/node.txt',
        'https://cdn.jsdelivr.net/gh/codingbox/Free-Node-Merge@main/node.txt',
        'https://raw.githubusercontent.com/codingbox/Free-Node-Merge/main/node.txt',
      ]),
    );
  });

  test('asset catalog includes latest verified mirrored subscription feeds', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map>();

    expect(sources.length, 187);

    Map findSource(String id) {
      return sources.singleWhere((item) => item['id'] == id);
    }

    const sourceIds = {
      'hans-thomas-v2ray-subscription',
      'mahdibland-v2ray-aggregator',
      'go4sharing-sub',
      'firefoxmmx2-v2rayshare-subcription',
    };
    for (final sourceId in sourceIds) {
      expect(findSource(sourceId)['githubDiscovery'], true, reason: sourceId);
    }

    final hansCandidates =
        (findSource('hans-thomas-v2ray-subscription')['rawCandidates'] as List)
            .cast<String>();
    final mahdiblandCandidates =
        (findSource('mahdibland-v2ray-aggregator')['rawCandidates'] as List)
            .cast<String>();
    final go4sharingCandidates =
        (findSource('go4sharing-sub')['rawCandidates'] as List).cast<String>();
    final firefoxCandidates =
        (findSource('firefoxmmx2-v2rayshare-subcription')['rawCandidates']
                as List)
            .cast<String>();

    expect(hansCandidates.first, startsWith('https://cdn.jsdelivr.net/'));
    expect(
      hansCandidates,
      containsAll([
        'https://cdn.jsdelivr.net/gh/hans-thomas/v2ray-subscription@master/servers.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/hans-thomas/v2ray-subscription/refs/heads/master/servers.txt',
        'https://raw.githubusercontent.com/hans-thomas/v2ray-subscription/refs/heads/master/servers.txt',
      ]),
    );

    expect(
      mahdiblandCandidates.first,
      startsWith('https://ghfile.geekertao.top/'),
    );
    expect(
      mahdiblandCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/mahdibland/V2RayAggregator/master/sub/sub_merge.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/mahdibland/V2RayAggregator/master/sub/sub_merge.txt',
        'https://cdn.jsdelivr.net/gh/mahdibland/V2RayAggregator@master/sub/sub_merge.txt',
        'https://raw.githubusercontent.com/mahdibland/V2RayAggregator/master/sub/sub_merge.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/mahdibland/V2RayAggregator/master/Eternity.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/mahdibland/V2RayAggregator/master/Eternity.txt',
        'https://cdn.jsdelivr.net/gh/mahdibland/V2RayAggregator@master/Eternity.txt',
        'https://raw.githubusercontent.com/mahdibland/V2RayAggregator/master/Eternity.txt',
      ]),
    );

    expect(go4sharingCandidates.first, startsWith('https://cdn.jsdelivr.net/'));
    expect(
      go4sharingCandidates,
      containsAll([
        'https://cdn.jsdelivr.net/gh/go4sharing/sub@main/sub.yaml',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/go4sharing/sub/main/sub.yaml',
        'https://raw.githubusercontent.com/go4sharing/sub/main/sub.yaml',
      ]),
    );

    expect(firefoxCandidates.first, startsWith('https://cdn.jsdelivr.net/'));
    expect(
      firefoxCandidates,
      containsAll([
        'https://cdn.jsdelivr.net/gh/firefoxmmx2/v2rayshare_subcription@main/subscription/clash_sub.yaml',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/firefoxmmx2/v2rayshare_subcription/main/subscription/clash_sub.yaml',
        'https://raw.githubusercontent.com/firefoxmmx2/v2rayshare_subcription/main/subscription/clash_sub.yaml',
      ]),
    );
  });

  test('asset catalog includes additional base64 and Clash GitHub feeds', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map>();

    expect(sources.length, 187);

    Map findSource(String id) {
      return sources.singleWhere((item) => item['id'] == id);
    }

    const sourceIds = {
      'azadnetch-clash',
      'xiaoji235-airport-free',
      'awesome-vpn-awesome-vpn',
      'gtang8-subcrawler',
      'vxiaov-free-proxies',
      'ripaojiedian-freenode',
      'nasheep-freenode-playlab',
    };
    for (final sourceId in sourceIds) {
      expect(findSource(sourceId)['githubDiscovery'], true, reason: sourceId);
    }

    final azadCandidates =
        (findSource('azadnetch-clash')['rawCandidates'] as List).cast<String>();
    final xiaojiCandidates =
        (findSource('xiaoji235-airport-free')['rawCandidates'] as List)
            .cast<String>();
    final awesomeCandidates =
        (findSource('awesome-vpn-awesome-vpn')['rawCandidates'] as List)
            .cast<String>();
    final gtangCandidates =
        (findSource('gtang8-subcrawler')['rawCandidates'] as List)
            .cast<String>();
    final vxiaovCandidates =
        (findSource('vxiaov-free-proxies')['rawCandidates'] as List)
            .cast<String>();
    final ripaoCandidates =
        (findSource('ripaojiedian-freenode')['rawCandidates'] as List)
            .cast<String>();
    final nasheepCandidates =
        (findSource('nasheep-freenode-playlab')['rawCandidates'] as List)
            .cast<String>();

    expect(azadCandidates.first, startsWith('https://ghfile.geekertao.top/'));
    expect(
      azadCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/AzadNetCH/Clash/main/AzadNet_hy.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/AzadNetCH/Clash/main/AzadNet.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/AzadNetCH/Clash/main/AzadNet.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/AzadNetCH/Clash/main/AzadNet_hy.txt',
        'https://cdn.jsdelivr.net/gh/AzadNetCH/Clash@main/AzadNet_hy.txt',
        'https://cdn.jsdelivr.net/gh/AzadNetCH/Clash@main/AzadNet.txt',
        'https://raw.githubusercontent.com/AzadNetCH/Clash/main/AzadNet_hy.txt',
        'https://raw.githubusercontent.com/AzadNetCH/Clash/main/AzadNet.txt',
      ]),
    );

    expect(
      xiaojiCandidates.first,
      startsWith('https://raw.githubusercontent.com/'),
    );
    expect(
      xiaojiCandidates,
      containsAll([
        'https://raw.githubusercontent.com/xiaoji235/airport-free/refs/heads/main/v2ray.txt',
        'https://raw.githubusercontent.com/xiaoji235/airport-free/main/clash/naidounode.txt',
        'https://raw.githubusercontent.com/xiaoji235/airport-free/main/v2ray/v2rayshare.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/xiaoji235/airport-free/refs/heads/main/v2ray.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/xiaoji235/airport-free/main/clash/naidounode.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/xiaoji235/airport-free/main/v2ray/v2rayshare.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/xiaoji235/airport-free/refs/heads/main/v2ray.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/xiaoji235/airport-free/main/v2ray/v2rayshare.txt',
        'https://cdn.jsdelivr.net/gh/xiaoji235/airport-free@main/v2ray.txt',
        'https://cdn.jsdelivr.net/gh/xiaoji235/airport-free@main/clash/naidounode.txt',
        'https://cdn.jsdelivr.net/gh/xiaoji235/airport-free@main/v2ray/v2rayshare.txt',
      ]),
    );

    expect(
      awesomeCandidates.first,
      startsWith('https://raw.githubusercontent.com/'),
    );
    expect(
      awesomeCandidates,
      containsAll([
        'https://raw.githubusercontent.com/awesome-vpn/awesome-vpn/master/all',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/awesome-vpn/awesome-vpn/master/all',
        'https://cdn.jsdelivr.net/gh/awesome-vpn/awesome-vpn@master/all',
      ]),
    );

    expect(
      gtangCandidates.first,
      startsWith('https://raw.githubusercontent.com/'),
    );
    expect(
      gtangCandidates,
      containsAll([
        'https://raw.githubusercontent.com/gtang8/SubCrawler/main/sub/share/all',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/gtang8/SubCrawler/main/sub/share/all',
        'https://cdn.jsdelivr.net/gh/gtang8/SubCrawler@main/sub/share/all',
      ]),
    );

    expect(vxiaovCandidates.first, startsWith('https://cdn.jsdelivr.net/'));
    expect(
      vxiaovCandidates,
      containsAll([
        'https://cdn.jsdelivr.net/gh/vxiaov/free_proxies@main/links.txt',
        'https://cdn.jsdelivr.net/gh/vxiaov/free_proxies@main/clash/clash.provider.yaml',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/vxiaov/free_proxies/main/links.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/vxiaov/free_proxies/main/clash/clash.provider.yaml',
        'https://gh.con.sh/https://raw.githubusercontent.com/vxiaov/free_proxies/main/links.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/vxiaov/free_proxies/main/clash/clash.provider.yaml',
        'https://raw.githubusercontent.com/vxiaov/free_proxies/main/links.txt',
        'https://raw.githubusercontent.com/vxiaov/free_proxies/main/clash/clash.provider.yaml',
      ]),
    );

    expect(
      ripaoCandidates.first,
      startsWith('https://raw.githubusercontent.com/'),
    );
    expect(
      ripaoCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/ripaojiedian/freenode/main/sub',
        'https://cdn.jsdelivr.net/gh/ripaojiedian/freenode@main/sub',
        'https://raw.githubusercontent.com/ripaojiedian/freenode/main/sub',
      ]),
    );

    expect(
      nasheepCandidates.first,
      startsWith('https://raw.githubusercontent.com/'),
    );
    expect(
      nasheepCandidates,
      containsAll([
        'https://raw.githubusercontent.com/nasheep/FreeNode/main/clash/PlayLab',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/nasheep/FreeNode/main/clash/PlayLab',
        'https://cdn.jsdelivr.net/gh/nasheep/FreeNode@main/clash/PlayLab',
      ]),
    );
  });

  test('asset catalog includes additional live raw mirror feeds', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map>();

    expect(sources.length, 187);

    Map findSource(String id) {
      return sources.singleWhere((item) => item['id'] == id);
    }

    const sourceIds = {
      'vpei-free-node-1',
      'jikelonglie-meskell',
      'ermaozi01-free-clash-vpn',
      'learnhard-cn-free-proxy-ss',
      'voken100g-autossr',
      'tjyu010-jiedian',
    };
    for (final sourceId in sourceIds) {
      expect(findSource(sourceId)['githubDiscovery'], true, reason: sourceId);
    }

    final vpeiCandidates =
        (findSource('vpei-free-node-1')['rawCandidates'] as List)
            .cast<String>();
    final meskellCandidates =
        (findSource('jikelonglie-meskell')['rawCandidates'] as List)
            .cast<String>();
    final ermaoziCandidates =
        (findSource('ermaozi01-free-clash-vpn')['rawCandidates'] as List)
            .cast<String>();
    final learnhardCandidates =
        (findSource('learnhard-cn-free-proxy-ss')['rawCandidates'] as List)
            .cast<String>();
    final vokenCandidates =
        (findSource('voken100g-autossr')['rawCandidates'] as List)
            .cast<String>();
    final tjyuCandidates =
        (findSource('tjyu010-jiedian')['rawCandidates'] as List).cast<String>();

    expect(
      vpeiCandidates.first,
      startsWith('https://raw.githubusercontent.com/'),
    );
    expect(
      vpeiCandidates,
      containsAll([
        'https://raw.githubusercontent.com/vpei/free-node-1/main/o/proxies.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/vpei/free-node-1/main/o/proxies.txt',
        'https://cdn.jsdelivr.net/gh/vpei/free-node-1@main/o/proxies.txt',
      ]),
    );

    expect(
      meskellCandidates.first,
      startsWith('https://raw.githubusercontent.com/'),
    );
    expect(
      meskellCandidates,
      containsAll([
        'https://raw.githubusercontent.com/jikelonglie/meskell/main/meskell',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/jikelonglie/meskell/main/meskell',
        'https://cdn.jsdelivr.net/gh/jikelonglie/meskell@main/meskell',
      ]),
    );

    expect(ermaoziCandidates.first, startsWith('https://cdn.jsdelivr.net/'));
    expect(
      ermaoziCandidates,
      containsAll([
        'https://cdn.jsdelivr.net/gh/ermaozi01/free_clash_vpn@main/subscribe/v2ray.txt',
        'https://raw.githubusercontent.com/ermaozi01/free_clash_vpn/main/subscribe/v2ray.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/ermaozi01/free_clash_vpn/main/subscribe/v2ray.txt',
      ]),
    );

    expect(
      learnhardCandidates.first,
      startsWith('https://raw.githubusercontent.com/'),
    );
    expect(
      learnhardCandidates,
      containsAll([
        'https://raw.githubusercontent.com/learnhard-cn/free_proxy_ss/main/free',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/learnhard-cn/free_proxy_ss/main/free',
        'https://cdn.jsdelivr.net/gh/learnhard-cn/free_proxy_ss@main/free',
      ]),
    );

    expect(
      vokenCandidates.first,
      startsWith('https://raw.githubusercontent.com/'),
    );
    expect(
      vokenCandidates,
      containsAll([
        'https://raw.githubusercontent.com/voken100g/AutoSSR/master/online',
        'https://cdn.jsdelivr.net/gh/voken100g/AutoSSR@master/online',
        'https://raw.githubusercontent.com/voken100g/AutoSSR/master/recent',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/voken100g/AutoSSR/master/recent',
      ]),
    );

    expect(
      tjyuCandidates.first,
      startsWith('https://raw.githubusercontent.com/'),
    );
    expect(
      tjyuCandidates,
      containsAll([
        'https://raw.githubusercontent.com/tjyu010/jiedian/main/21',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/tjyu010/jiedian/main/21',
        'https://cdn.jsdelivr.net/gh/tjyu010/jiedian@main/21',
      ]),
    );
  });

  test('asset catalog includes additional OpenRay-derived live feeds', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map>();

    expect(sources.length, 187);

    Map findSource(String id) {
      return sources.singleWhere((item) => item['id'] == id);
    }

    const sourceIds = {
      'lonup-nodelist',
      'mhditaheri-v2raycollector-py',
      'mrvcoder-v2raycollector',
      'nyeinkokoaung404-v2ray-configs',
      'shjpr9-subs',
      'thegreatpeter-v2raynodes',
      'avencores-goida-vpn-configs',
      'nirevil-vless',
    };
    for (final sourceId in sourceIds) {
      expect(findSource(sourceId)['githubDiscovery'], true, reason: sourceId);
    }

    final lonupCandidates =
        (findSource('lonup-nodelist')['rawCandidates'] as List).cast<String>();
    final mhdiPyCandidates =
        (findSource('mhditaheri-v2raycollector-py')['rawCandidates'] as List)
            .cast<String>();
    final mrvcoderCandidates =
        (findSource('mrvcoder-v2raycollector')['rawCandidates'] as List)
            .cast<String>();
    final nyeinCandidates =
        (findSource('nyeinkokoaung404-v2ray-configs')['rawCandidates'] as List)
            .cast<String>();
    final shjpr9Candidates =
        (findSource('shjpr9-subs')['rawCandidates'] as List).cast<String>();
    final greatPeterCandidates =
        (findSource('thegreatpeter-v2raynodes')['rawCandidates'] as List)
            .cast<String>();
    final avenCoresCandidates =
        (findSource('avencores-goida-vpn-configs')['rawCandidates'] as List)
            .cast<String>();
    final nirevilCandidates =
        (findSource('nirevil-vless')['rawCandidates'] as List).cast<String>();

    expect(lonupCandidates.first, startsWith('https://ghfile.geekertao.top/'));
    expect(
      lonupCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/LonUp/NodeList/main/V2RAY/Latest_base64.txt',
        'https://raw.githubusercontent.com/LonUp/NodeList/main/V2RAY/Latest_base64.txt',
        'https://cdn.jsdelivr.net/gh/LonUp/NodeList@main/V2RAY/Latest_base64.txt',
      ]),
    );

    expect(
      mhdiPyCandidates.first,
      startsWith('https://raw.githubusercontent.com/'),
    );
    expect(
      mhdiPyCandidates,
      containsAll([
        'https://raw.githubusercontent.com/MhdiTaheri/V2rayCollector_Py/refs/heads/main/sub/Mix/mix.txt',
        'https://cdn.jsdelivr.net/gh/MhdiTaheri/V2rayCollector_Py@main/sub/Mix/mix.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/MhdiTaheri/V2rayCollector_Py/refs/heads/main/sub/Mix/mix.txt',
      ]),
    );

    expect(
      mrvcoderCandidates.first,
      startsWith('https://raw.githubusercontent.com/'),
    );
    expect(
      mrvcoderCandidates,
      containsAll([
        'https://raw.githubusercontent.com/mrvcoder/V2rayCollector/refs/heads/main/vless_iran.txt',
        'https://raw.githubusercontent.com/mrvcoder/V2rayCollector/refs/heads/main/vmess_iran.txt',
        'https://raw.githubusercontent.com/mrvcoder/V2rayCollector/refs/heads/main/trojan_iran.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/mrvcoder/V2rayCollector/refs/heads/main/vless_iran.txt',
        'https://gh.con.sh/https://raw.githubusercontent.com/mrvcoder/V2rayCollector/refs/heads/main/ss_iran.txt',
        'https://cdn.jsdelivr.net/gh/mrvcoder/V2rayCollector@main/vless_iran.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/mrvcoder/V2rayCollector/refs/heads/main/vless_iran.txt',
      ]),
    );

    expect(
      nyeinCandidates.first,
      startsWith('https://raw.githubusercontent.com/'),
    );
    expect(
      nyeinCandidates,
      containsAll([
        'https://raw.githubusercontent.com/nyeinkokoaung404/V2ray-Configs/refs/heads/main/All_Configs_Sub.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/nyeinkokoaung404/V2ray-Configs/refs/heads/main/All_Configs_Sub.txt',
        'https://cdn.jsdelivr.net/gh/nyeinkokoaung404/V2ray-Configs@main/All_Configs_Sub.txt',
      ]),
    );

    expect(
      shjpr9Candidates.first,
      startsWith('https://raw.githubusercontent.com/'),
    );
    expect(
      shjpr9Candidates,
      containsAll([
        'https://raw.githubusercontent.com/Shjpr9/Subs/refs/heads/main/sub.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/Shjpr9/Subs/refs/heads/main/sub.txt',
        'https://cdn.jsdelivr.net/gh/Shjpr9/Subs@main/sub.txt',
      ]),
    );

    expect(
      greatPeterCandidates.first,
      startsWith('https://raw.githubusercontent.com/'),
    );
    expect(
      greatPeterCandidates,
      containsAll([
        'https://raw.githubusercontent.com/theGreatPeter/v2rayNodes/main/nodes.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/theGreatPeter/v2rayNodes/main/nodes.txt',
        'https://cdn.jsdelivr.net/gh/theGreatPeter/v2rayNodes@main/nodes.txt',
      ]),
    );

    expect(
      avenCoresCandidates.first,
      startsWith('https://raw.githubusercontent.com/'),
    );
    expect(
      avenCoresCandidates,
      contains(
        predicate<String>((url) => url.startsWith('https://cdn.jsdelivr.net/')),
      ),
    );
    expect(
      avenCoresCandidates,
      containsAll([
        'https://raw.githubusercontent.com/AvenCores/goida-vpn-configs/refs/heads/main/githubmirror/26.txt',
        'https://cdn.jsdelivr.net/gh/AvenCores/goida-vpn-configs@main/githubmirror/26.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/AvenCores/goida-vpn-configs/refs/heads/main/githubmirror/26.txt',
      ]),
    );

    expect(
      nirevilCandidates.first,
      startsWith('https://raw.githubusercontent.com/'),
    );
    expect(
      nirevilCandidates,
      containsAll([
        'https://raw.githubusercontent.com/NiREvil/vless/refs/heads/main/sub/clash-meta-wg.yml',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/NiREvil/vless/refs/heads/main/sub/clash-meta-wg.yml',
        'https://cdn.jsdelivr.net/gh/NiREvil/vless@main/sub/clash-meta-wg.yml',
      ]),
    );
  });

  test('asset catalog includes additional high volume live feeds', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map>();

    expect(sources.length, 187);

    Map findSource(String id) {
      return sources.singleWhere((item) => item['id'] == id);
    }

    const sourceIds = {
      'sakha1370-openray',
      'acymz-autovpn',
      'cidvpn-cid-vpn-config',
      'farid-karimi-config-collector',
      'hakurouken-free-node',
      'pachangcheng-mianfeijiedian',
      'iboxz-free-v2ray-collector',
      'wuqb-xray-config-toolkit',
    };
    for (final sourceId in sourceIds) {
      expect(findSource(sourceId)['githubDiscovery'], true, reason: sourceId);
    }

    final openRayCandidates =
        (findSource('sakha1370-openray')['rawCandidates'] as List)
            .cast<String>();
    final acymzCandidates =
        (findSource('acymz-autovpn')['rawCandidates'] as List).cast<String>();
    final cidVpnCandidates =
        (findSource('cidvpn-cid-vpn-config')['rawCandidates'] as List)
            .cast<String>();
    final faridCandidates =
        (findSource('farid-karimi-config-collector')['rawCandidates'] as List)
            .cast<String>();
    final hakurouKenCandidates =
        (findSource('hakurouken-free-node')['rawCandidates'] as List)
            .cast<String>();
    final pachangchengCandidates =
        (findSource('pachangcheng-mianfeijiedian')['rawCandidates'] as List)
            .cast<String>();
    final iboxzCandidates =
        (findSource('iboxz-free-v2ray-collector')['rawCandidates'] as List)
            .cast<String>();
    final wuqbCandidates =
        (findSource('wuqb-xray-config-toolkit')['rawCandidates'] as List)
            .cast<String>();

    expect(
      openRayCandidates,
      contains(
        predicate<String>((url) => url.startsWith('https://cdn.jsdelivr.net/')),
      ),
    );
    expect(
      openRayCandidates,
      containsAll([
        'https://cdn.jsdelivr.net/gh/sakha1370/OpenRay@main/output/all_valid_proxies.txt',
        'https://raw.githubusercontent.com/sakha1370/OpenRay/refs/heads/main/output/all_valid_proxies.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/sakha1370/OpenRay/refs/heads/main/output/all_valid_proxies.txt',
      ]),
    );

    expect(acymzCandidates.first, startsWith('https://cdn.jsdelivr.net/'));
    expect(
      acymzCandidates,
      containsAll([
        'https://cdn.jsdelivr.net/gh/acymz/AutoVPN@main/data/V2.txt',
        'https://raw.githubusercontent.com/acymz/AutoVPN/refs/heads/main/data/V2.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/acymz/AutoVPN/refs/heads/main/data/V2.txt',
      ]),
    );

    expect(
      cidVpnCandidates.first,
      startsWith('https://raw.githubusercontent.com/'),
    );
    expect(
      cidVpnCandidates,
      containsAll([
        'https://raw.githubusercontent.com/CidVpn/cid-vpn-config/refs/heads/main/general.txt',
        'https://cdn.jsdelivr.net/gh/CidVpn/cid-vpn-config@main/general.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/CidVpn/cid-vpn-config/refs/heads/main/general.txt',
      ]),
    );

    expect(
      faridCandidates.first,
      startsWith('https://raw.githubusercontent.com/'),
    );
    expect(
      faridCandidates,
      containsAll([
        'https://raw.githubusercontent.com/Farid-Karimi/Config-Collector/refs/heads/main/mixed_iran.txt',
        'https://cdn.jsdelivr.net/gh/Farid-Karimi/Config-Collector@main/mixed_iran.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/Farid-Karimi/Config-Collector/refs/heads/main/mixed_iran.txt',
      ]),
    );

    expect(
      hakurouKenCandidates.first,
      startsWith('https://ghfile.geekertao.top/'),
    );
    expect(
      hakurouKenCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/HakurouKen/free-node/main/public',
        'https://raw.githubusercontent.com/HakurouKen/free-node/main/public',
      ]),
    );
    expect(
      hakurouKenCandidates.any((url) => url.contains('cdn.jsdelivr.net')),
      isFalse,
    );

    expect(
      pachangchengCandidates.first,
      startsWith('https://cdn.jsdelivr.net/'),
    );
    expect(
      pachangchengCandidates,
      containsAll([
        'https://cdn.jsdelivr.net/gh/pachangcheng/mianfeijiedian@main/should.txt',
        'https://raw.githubusercontent.com/pachangcheng/mianfeijiedian/refs/heads/main/should.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/pachangcheng/mianfeijiedian/refs/heads/main/should.txt',
      ]),
    );

    expect(
      iboxzCandidates.first,
      startsWith('https://raw.githubusercontent.com/'),
    );
    expect(
      iboxzCandidates,
      containsAll([
        'https://raw.githubusercontent.com/iboxz/free-v2ray-collector/main/main/vless',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/iboxz/free-v2ray-collector/main/main/vless',
      ]),
    );
    expect(
      iboxzCandidates.any((url) => url.contains('cdn.jsdelivr.net')),
      isFalse,
    );

    expect(
      wuqbCandidates.first,
      startsWith('https://raw.githubusercontent.com/'),
    );
    expect(
      wuqbCandidates,
      containsAll([
        'https://raw.githubusercontent.com/wuqb2i4f/xray-config-toolkit/refs/heads/main/output/base64/mix-uri',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/wuqb2i4f/xray-config-toolkit/refs/heads/main/output/base64/mix-uri',
      ]),
    );
    expect(
      wuqbCandidates.any((url) => url.contains('cdn.jsdelivr.net')),
      isFalse,
    );
  });

  test('asset catalog includes additional mermeroo-indexed live feeds', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map>();

    expect(sources.length, 187);

    Map findSource(String id) {
      return sources.singleWhere((item) => item['id'] == id);
    }

    const sourceIds = {
      'anaer-sub',
      'mermeroo-loon',
      'mermeroo-qx',
      'mermeroo-quantumultx',
      'misersun-config003',
      'ronghuaxueleng-get-v2',
    };
    for (final sourceId in sourceIds) {
      expect(findSource(sourceId)['githubDiscovery'], true, reason: sourceId);
    }

    final anaerCandidates = (findSource('anaer-sub')['rawCandidates'] as List)
        .cast<String>();
    final loonCandidates =
        (findSource('mermeroo-loon')['rawCandidates'] as List).cast<String>();
    final qxCandidates = (findSource('mermeroo-qx')['rawCandidates'] as List)
        .cast<String>();
    final quantumultXCandidates =
        (findSource('mermeroo-quantumultx')['rawCandidates'] as List)
            .cast<String>();
    final misersunCandidates =
        (findSource('misersun-config003')['rawCandidates'] as List)
            .cast<String>();
    final ronghuaCandidates =
        (findSource('ronghuaxueleng-get-v2')['rawCandidates'] as List)
            .cast<String>();

    expect(
      anaerCandidates.first,
      startsWith('https://raw.githubusercontent.com/'),
    );
    expect(
      anaerCandidates,
      containsAll([
        'https://raw.githubusercontent.com/anaer/Sub/main/clash.yaml',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/anaer/Sub/main/clash.yaml',
        'https://cdn.jsdelivr.net/gh/anaer/Sub@main/clash.yaml',
      ]),
    );

    expect(
      loonCandidates.first,
      startsWith('https://raw.githubusercontent.com/'),
    );
    expect(
      loonCandidates,
      containsAll([
        'https://raw.githubusercontent.com/mermeroo/Loon/refs/heads/main/all.nodes.txt',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/mermeroo/Loon/refs/heads/main/all.nodes.txt',
        'https://cdn.jsdelivr.net/gh/mermeroo/Loon@main/all.nodes.txt',
      ]),
    );

    expect(
      qxCandidates.first,
      startsWith('https://raw.githubusercontent.com/'),
    );
    expect(
      qxCandidates,
      containsAll([
        'https://raw.githubusercontent.com/mermeroo/QX/refs/heads/main/Nodes',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/mermeroo/QX/refs/heads/main/Nodes',
      ]),
    );
    expect(
      qxCandidates.any((url) => url.contains('cdn.jsdelivr.net')),
      isFalse,
    );

    expect(
      quantumultXCandidates.first,
      startsWith('https://raw.githubusercontent.com/'),
    );
    expect(
      quantumultXCandidates,
      containsAll([
        'https://raw.githubusercontent.com/mermeroo/QuantumultX/refs/heads/main/Trojan.nodes',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/mermeroo/QuantumultX/refs/heads/main/Trojan.nodes',
      ]),
    );
    expect(
      quantumultXCandidates.any((url) => url.contains('cdn.jsdelivr.net')),
      isFalse,
    );

    expect(
      misersunCandidates.first,
      startsWith('https://raw.githubusercontent.com/'),
    );
    expect(
      misersunCandidates,
      containsAll([
        'https://raw.githubusercontent.com/misersun/config003/main/config_all.yaml',
        'https://cdn.jsdelivr.net/gh/misersun/config003@main/config_all.yaml',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/misersun/config003/main/config_all.yaml',
      ]),
    );

    expect(
      ronghuaCandidates.first,
      startsWith('https://raw.githubusercontent.com/'),
    );
    expect(
      ronghuaCandidates,
      containsAll([
        'https://raw.githubusercontent.com/ronghuaxueleng/get_v2/main/pub/combine.yaml',
        'https://cdn.jsdelivr.net/gh/ronghuaxueleng/get_v2@main/pub/combine.yaml',
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/ronghuaxueleng/get_v2/main/pub/combine.yaml',
      ]),
    );
  });

  test('asset catalog includes additional index-discovered direct feeds', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map>();

    expect(sources.length, 187);

    Map findSource(String id) {
      return sources.singleWhere((item) => item['id'] == id);
    }

    const sourceIds = {'yitong2333-proxy-minging', 'w1770946466-auto-proxy'};
    for (final sourceId in sourceIds) {
      expect(findSource(sourceId)['githubDiscovery'], true, reason: sourceId);
    }

    final yitongCandidates =
        (findSource('yitong2333-proxy-minging')['rawCandidates'] as List)
            .cast<String>();
    final w177Candidates =
        (findSource('w1770946466-auto-proxy')['rawCandidates'] as List)
            .cast<String>();

    expect(yitongCandidates.first, startsWith('https://ghfile.geekertao.top/'));
    expect(
      yitongCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/yitong2333/proxy-minging/refs/heads/main/v2ray.txt',
        'https://cdn.jsdelivr.net/gh/yitong2333/proxy-minging@main/v2ray.txt',
        'https://raw.githubusercontent.com/yitong2333/proxy-minging/refs/heads/main/v2ray.txt',
      ]),
    );

    expect(w177Candidates.first, startsWith('https://ghfile.geekertao.top/'));
    expect(
      w177Candidates,
      containsAll([
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/w1770946466/Auto_proxy/main/Long_term_subscription_num',
        'https://cdn.jsdelivr.net/gh/w1770946466/Auto_proxy@main/Long_term_subscription_num',
        'https://raw.githubusercontent.com/w1770946466/Auto_proxy/main/Long_term_subscription_num',
      ]),
    );
  });

  test(
    'asset catalog includes additional subscription index discovery pages',
    () async {
      final sourceCatalogJson = await File(
        'assets/data/free_node_sources.json',
      ).readAsString();
      final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
      final sources = (data['sources'] as List).cast<Map>();

      expect(sources.length, 187);

      Map findSource(String id) {
        return sources.singleWhere((item) => item['id'] == id);
      }

      final mermerooIndex = findSource('mermeroo-subscription-links-index');
      final mehdirzfxIndex = findSource('mehdirzfx-v2ray-sub-index');

      expect(mermerooIndex['pageDiscovery'], true);
      expect(mermerooIndex['githubDiscovery'], false);
      expect(
        mermerooIndex['seed'],
        'https://github.com/mermeroo/V2RAY-CLASH-BASE64-Subscription.Links/blob/main/SUB%20LINKS',
      );

      expect(mehdirzfxIndex['pageDiscovery'], true);
      expect(mehdirzfxIndex['githubDiscovery'], false);
      expect(
        mehdirzfxIndex['seed'],
        'https://raw.githubusercontent.com/mehdirzfx/v2ray-sub/main/README.md',
      );
    },
  );

  test('asset catalog adds ghfile mirrors for high priority GitHub subscriptions', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map>();

    Map findSource(String id) {
      return sources.singleWhere((item) => item['id'] == id);
    }

    final clashfreeTemplates =
        (findSource('github-free-nodes-clashfree')['configTemplates'] as List)
            .cast<String>();
    final pawdroidCandidates =
        (findSource('pawdroid-free-servers')['rawCandidates'] as List)
            .cast<String>();
    final free18Candidates =
        (findSource('free18-v2ray')['rawCandidates'] as List).cast<String>();
    final freenodesCandidates =
        (findSource('freenodes-github-io')['rawCandidates'] as List)
            .cast<String>();
    final ermaoziCandidates =
        (findSource('ermaozi-get-subscribe')['rawCandidates'] as List)
            .cast<String>();
    final shaoyouvipCandidates =
        (findSource('shaoyouvip-free')['rawCandidates'] as List).cast<String>();

    expect(
      clashfreeTemplates.first,
      'https://ghfile.geekertao.top/https://raw.githubusercontent.com/free-nodes/clashfree/main/clash{yyyymmdd}.yml',
    );
    expect(
      clashfreeTemplates,
      contains(
        'https://gh.con.sh/https://raw.githubusercontent.com/free-nodes/clashfree/main/clash{yyyymmdd}.yml',
      ),
    );
    expect(
      pawdroidCandidates,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/Pawdroid/Free-servers/main/static/sub_en',
      ),
    );
    expect(
      pawdroidCandidates,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/Pawdroid/Free-servers/main/static/sub_ar',
      ),
    );
    expect(
      pawdroidCandidates,
      contains(
        'https://gh.con.sh/https://raw.githubusercontent.com/Pawdroid/Free-servers/main/static/sub_zh',
      ),
    );
    expect(
      pawdroidCandidates,
      contains(
        'https://raw.githubusercontent.com/Pawdroid/Free-servers/main/static/sub_ar',
      ),
    );
    expect(
      free18Candidates,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/free18/v2ray/main/c.yaml',
      ),
    );
    expect(
      free18Candidates,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/free18/v2ray/main/v.txt',
      ),
    );
    expect(
      free18Candidates,
      contains(
        'https://gh.con.sh/https://raw.githubusercontent.com/free18/v2ray/main/c.yaml',
      ),
    );
    expect(
      freenodesCandidates,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/freenodes/freenodes/main/ClashPremiumFree.yaml',
      ),
    );
    expect(
      freenodesCandidates,
      contains(
        'https://gh.con.sh/https://raw.githubusercontent.com/freenodes/freenodes/main/ClashPremiumFree.yaml',
      ),
    );
    expect(
      ermaoziCandidates.first,
      'https://ghfile.geekertao.top/https://raw.githubusercontent.com/ermaozi/get_subscribe/main/subscribe/clash.yml',
    );
    expect(
      shaoyouvipCandidates,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/shaoyouvip/free/main/all.yaml',
      ),
    );
    expect(
      shaoyouvipCandidates,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/shaoyouvip/free/main/base64.txt',
      ),
    );
    expect(
      shaoyouvipCandidates,
      contains(
        'https://gh.con.sh/https://raw.githubusercontent.com/shaoyouvip/free/main/all.yaml',
      ),
    );
    expect(
      shaoyouvipCandidates,
      contains(
        'https://gh.con.sh/https://raw.githubusercontent.com/shaoyouvip/free/main/base64.txt',
      ),
    );
    expect(
      shaoyouvipCandidates,
      contains(
        'https://raw.githubusercontent.com/shaoyouvip/free/main/base64.txt',
      ),
    );
  });

  test('asset catalog adds ghfile mirrors for remaining GitHub raw sources', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map>();

    Map findSource(String id) {
      return sources.singleWhere((item) => item['id'] == id);
    }

    final v2rayfreeCandidates =
        (findSource('github-free-nodes-v2rayfree')['rawCandidates'] as List)
            .cast<String>();
    final freefqCandidates =
        (findSource('freefq-free')['rawCandidates'] as List).cast<String>();
    final snakem982Candidates =
        (findSource('snakem982-proxypool')['rawCandidates'] as List)
            .cast<String>();
    final barabamaCandidates =
        (findSource('barabama-freenodes')['rawCandidates'] as List)
            .cast<String>();
    final dongchengjieCandidates =
        (findSource('dongchengjie-airport')['rawCandidates'] as List)
            .cast<String>();

    expect(
      v2rayfreeCandidates,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/free-nodes/v2rayfree/main/v2ray.txt',
      ),
    );
    expect(
      v2rayfreeCandidates,
      contains(
        'https://raw.githubusercontent.com/free-nodes/v2rayfree/main/v2ray',
      ),
    );
    expect(
      freefqCandidates,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/freefq/free/master/v2',
      ),
    );
    expect(
      freefqCandidates,
      contains(
        'https://raw.githubusercontent.com/freefq/free/master/README.md',
      ),
    );
    expect(
      snakem982Candidates,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/snakem982/proxypool/main/source/clash-meta-2.yaml',
      ),
    );
    expect(
      snakem982Candidates,
      contains(
        'https://raw.githubusercontent.com/snakem982/proxypool/main/source/clash-meta-2.yaml',
      ),
    );
    expect(
      barabamaCandidates,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/Barabama/FreeNodes/main/nodes/yudou66.yaml',
      ),
    );
    expect(
      barabamaCandidates,
      contains(
        'https://raw.githubusercontent.com/Barabama/FreeNodes/main/nodes/v2rayshare.yaml',
      ),
    );
    expect(
      barabamaCandidates,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/Barabama/FreeNodes/main/nodes/nodefree.txt',
      ),
    );
    expect(
      barabamaCandidates,
      contains(
        'https://cdn.jsdelivr.net/gh/Barabama/FreeNodes@main/nodes/nodev2ray.txt',
      ),
    );
    expect(
      barabamaCandidates,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/Barabama/FreeNodes/main/nodes/yudou66.txt',
      ),
    );
    expect(
      barabamaCandidates,
      contains(
        'https://cdn.jsdelivr.net/gh/Barabama/FreeNodes@main/nodes/ndnode.txt',
      ),
    );
    expect(
      barabamaCandidates,
      contains(
        'https://raw.githubusercontent.com/Barabama/FreeNodes/main/nodes/wenode.txt',
      ),
    );
    expect(
      dongchengjieCandidates,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/dongchengjie/airport/refs/heads/main/subs/merged/tested_within_sudoku.yaml',
      ),
    );
    expect(
      dongchengjieCandidates,
      contains(
        'https://gh.con.sh/https://raw.githubusercontent.com/dongchengjie/airport/refs/heads/main/subs/merged/tested_within.yaml',
      ),
    );
    expect(
      dongchengjieCandidates,
      contains(
        'https://gh.con.sh/https://raw.githubusercontent.com/dongchengjie/airport/refs/heads/main/subs/merged/tested_within_sudoku.yaml',
      ),
    );
    expect(
      dongchengjieCandidates,
      contains(
        'https://raw.githubusercontent.com/dongchengjie/airport/refs/heads/main/subs/merged/tested_within_sudoku.yaml',
      ),
    );
  });

  test('asset catalog adds ghcon mirrors for high frequency GitHub raw sources', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map>();

    Map findSource(String id) {
      return sources.singleWhere((item) => item['id'] == id);
    }

    const expectedGhConCandidates = {
      'mheidari98-proxy':
          'https://gh.con.sh/https://raw.githubusercontent.com/mheidari98/.proxy/main/all',
      'mahdi0024-proxycollector':
          'https://gh.con.sh/https://raw.githubusercontent.com/Mahdi0024/ProxyCollector/master/sub/proxies.txt',
      'm450ud-v2ray-configs':
          'https://gh.con.sh/https://raw.githubusercontent.com/M450ud/V2ray-Configs/refs/heads/main/All_Configs_Sub.txt',
      'mfuu-v2ray':
          'https://gh.con.sh/https://raw.githubusercontent.com/mfuu/v2ray/master/v2ray',
      'm-mashreghi-free-v2ray-collector':
          'https://gh.con.sh/https://raw.githubusercontent.com/M-Mashreghi/Free-V2ray-Collector/refs/heads/main/All_Configs_Sub.txt',
      'yitong2333-proxy-minging':
          'https://gh.con.sh/https://raw.githubusercontent.com/yitong2333/proxy-minging/refs/heads/main/v2ray.txt',
      'w1770946466-auto-proxy':
          'https://gh.con.sh/https://raw.githubusercontent.com/w1770946466/Auto_proxy/main/Long_term_subscription_num',
      'igareck-vpn-configs-for-russia':
          'https://gh.con.sh/https://raw.githubusercontent.com/igareck/vpn-configs-for-russia/refs/heads/main/BLACK_VLESS_RUS.txt',
      'yasserdivar-pr0xy':
          'https://gh.con.sh/https://raw.githubusercontent.com/YasserDivaR/pr0xy/refs/heads/main/ShadowSocks2021.txt',
      'kwinshadow-telegram-v2raycollector':
          'https://gh.con.sh/https://raw.githubusercontent.com/Kwinshadow/TelegramV2rayCollector/refs/heads/main/sublinks/mix.txt',
      'codingbox-free-node-merge':
          'https://gh.con.sh/https://raw.githubusercontent.com/codingbox/Free-Node-Merge/main/node.txt',
      'hans-thomas-v2ray-subscription':
          'https://gh.con.sh/https://raw.githubusercontent.com/hans-thomas/v2ray-subscription/refs/heads/master/servers.txt',
      'go4sharing-sub':
          'https://gh.con.sh/https://raw.githubusercontent.com/go4sharing/sub/main/sub.yaml',
      'firefoxmmx2-v2rayshare-subcription':
          'https://gh.con.sh/https://raw.githubusercontent.com/firefoxmmx2/v2rayshare_subcription/main/subscription/clash_sub.yaml',
      'awesome-vpn-awesome-vpn':
          'https://gh.con.sh/https://raw.githubusercontent.com/awesome-vpn/awesome-vpn/master/all',
      'gtang8-subcrawler':
          'https://gh.con.sh/https://raw.githubusercontent.com/gtang8/SubCrawler/main/sub/share/all',
      'ripaojiedian-freenode':
          'https://gh.con.sh/https://raw.githubusercontent.com/ripaojiedian/freenode/main/sub',
      'nasheep-freenode-playlab':
          'https://gh.con.sh/https://raw.githubusercontent.com/nasheep/FreeNode/main/clash/PlayLab',
      'vpei-free-node-1':
          'https://gh.con.sh/https://raw.githubusercontent.com/vpei/free-node-1/main/o/proxies.txt',
      'jikelonglie-meskell':
          'https://gh.con.sh/https://raw.githubusercontent.com/jikelonglie/meskell/main/meskell',
      'ermaozi01-free-clash-vpn':
          'https://gh.con.sh/https://raw.githubusercontent.com/ermaozi01/free_clash_vpn/main/subscribe/v2ray.txt',
      'learnhard-cn-free-proxy-ss':
          'https://gh.con.sh/https://raw.githubusercontent.com/learnhard-cn/free_proxy_ss/main/free',
      'voken100g-autossr':
          'https://gh.con.sh/https://raw.githubusercontent.com/voken100g/AutoSSR/master/online',
      'tjyu010-jiedian':
          'https://gh.con.sh/https://raw.githubusercontent.com/tjyu010/jiedian/main/21',
      'lonup-nodelist':
          'https://gh.con.sh/https://raw.githubusercontent.com/LonUp/NodeList/main/V2RAY/Latest_base64.txt',
      'mhditaheri-v2raycollector-py':
          'https://gh.con.sh/https://raw.githubusercontent.com/MhdiTaheri/V2rayCollector_Py/refs/heads/main/sub/Mix/mix.txt',
      'nyeinkokoaung404-v2ray-configs':
          'https://gh.con.sh/https://raw.githubusercontent.com/nyeinkokoaung404/V2ray-Configs/refs/heads/main/All_Configs_Sub.txt',
      'shjpr9-subs':
          'https://gh.con.sh/https://raw.githubusercontent.com/Shjpr9/Subs/refs/heads/main/sub.txt',
      'thegreatpeter-v2raynodes':
          'https://gh.con.sh/https://raw.githubusercontent.com/theGreatPeter/v2rayNodes/main/nodes.txt',
      'avencores-goida-vpn-configs':
          'https://gh.con.sh/https://raw.githubusercontent.com/AvenCores/goida-vpn-configs/refs/heads/main/githubmirror/26.txt',
      'nirevil-vless':
          'https://gh.con.sh/https://raw.githubusercontent.com/NiREvil/vless/refs/heads/main/sub/clash-meta-wg.yml',
      'sakha1370-openray':
          'https://gh.con.sh/https://raw.githubusercontent.com/sakha1370/OpenRay/refs/heads/main/output/all_valid_proxies.txt',
      'acymz-autovpn':
          'https://gh.con.sh/https://raw.githubusercontent.com/acymz/AutoVPN/refs/heads/main/data/V2.txt',
      'cidvpn-cid-vpn-config':
          'https://gh.con.sh/https://raw.githubusercontent.com/CidVpn/cid-vpn-config/refs/heads/main/general.txt',
      'farid-karimi-config-collector':
          'https://gh.con.sh/https://raw.githubusercontent.com/Farid-Karimi/Config-Collector/refs/heads/main/mixed_iran.txt',
      'hakurouken-free-node':
          'https://gh.con.sh/https://raw.githubusercontent.com/HakurouKen/free-node/main/public',
      'pachangcheng-mianfeijiedian':
          'https://gh.con.sh/https://raw.githubusercontent.com/pachangcheng/mianfeijiedian/refs/heads/main/should.txt',
      'iboxz-free-v2ray-collector':
          'https://gh.con.sh/https://raw.githubusercontent.com/iboxz/free-v2ray-collector/main/main/vless',
      'wuqb-xray-config-toolkit':
          'https://gh.con.sh/https://raw.githubusercontent.com/wuqb2i4f/xray-config-toolkit/refs/heads/main/output/base64/mix-uri',
      'anaer-sub':
          'https://gh.con.sh/https://raw.githubusercontent.com/anaer/Sub/main/clash.yaml',
      'mermeroo-loon':
          'https://gh.con.sh/https://raw.githubusercontent.com/mermeroo/Loon/refs/heads/main/all.nodes.txt',
      'mermeroo-qx':
          'https://gh.con.sh/https://raw.githubusercontent.com/mermeroo/QX/refs/heads/main/Nodes',
      'mermeroo-quantumultx':
          'https://gh.con.sh/https://raw.githubusercontent.com/mermeroo/QuantumultX/refs/heads/main/Trojan.nodes',
      'misersun-config003':
          'https://gh.con.sh/https://raw.githubusercontent.com/misersun/config003/main/config_all.yaml',
      'ronghuaxueleng-get-v2':
          'https://gh.con.sh/https://raw.githubusercontent.com/ronghuaxueleng/get_v2/main/pub/combine.yaml',
      'ermaozi-get-subscribe':
          'https://gh.con.sh/https://raw.githubusercontent.com/ermaozi/get_subscribe/main/subscribe/clash.yml',
      'github-free-nodes-v2rayfree':
          'https://gh.con.sh/https://raw.githubusercontent.com/free-nodes/v2rayfree/main/v2ray.txt',
      'freefq-free':
          'https://gh.con.sh/https://raw.githubusercontent.com/freefq/free/master/v2',
      'snakem982-proxypool':
          'https://gh.con.sh/https://raw.githubusercontent.com/snakem982/proxypool/main/source/clash-meta.yaml',
      'matin-ghanbari-v2ray-configs all_sub':
          'https://gh.con.sh/https://raw.githubusercontent.com/MatinGhanbari/v2ray-configs/main/subscriptions/v2ray/all_sub.txt',
      'matin-ghanbari-v2ray-configs filtered vless':
          'https://gh.con.sh/https://raw.githubusercontent.com/MatinGhanbari/v2ray-configs/main/subscriptions/filtered/subs/vless.txt',
      'matin-ghanbari-v2ray-configs filtered vmess':
          'https://gh.con.sh/https://raw.githubusercontent.com/MatinGhanbari/v2ray-configs/main/subscriptions/filtered/subs/vmess.txt',
      'matin-ghanbari-v2ray-configs filtered trojan':
          'https://gh.con.sh/https://raw.githubusercontent.com/MatinGhanbari/v2ray-configs/main/subscriptions/filtered/subs/trojan.txt',
      'matin-ghanbari-v2ray-configs filtered ss':
          'https://gh.con.sh/https://raw.githubusercontent.com/MatinGhanbari/v2ray-configs/main/subscriptions/filtered/subs/ss.txt',
      'matin-ghanbari-v2ray-configs filtered hysteria2':
          'https://gh.con.sh/https://raw.githubusercontent.com/MatinGhanbari/v2ray-configs/main/subscriptions/filtered/subs/hysteria2.txt',
      'mfuu-v2ray clash':
          'https://gh.con.sh/https://raw.githubusercontent.com/mfuu/v2ray/master/clash.yaml',
      'ebrasha-free-v2ray-public-list trojan refs':
          'https://gh.con.sh/https://raw.githubusercontent.com/ebrasha/free-v2ray-public-list/refs/heads/main/trojan_configs.txt',
      'ebrasha-free-v2ray-public-list ss refs':
          'https://gh.con.sh/https://raw.githubusercontent.com/ebrasha/free-v2ray-public-list/refs/heads/main/ss_configs.txt',
      'ebrasha-free-v2ray-public-list vmess refs':
          'https://gh.con.sh/https://raw.githubusercontent.com/ebrasha/free-v2ray-public-list/refs/heads/main/vmess_configs.txt',
      'ebrasha-free-v2ray-public-list vless refs':
          'https://gh.con.sh/https://raw.githubusercontent.com/ebrasha/free-v2ray-public-list/refs/heads/main/vless_configs.txt',
      'solispirit-v2ray-configs refs':
          'https://gh.con.sh/https://raw.githubusercontent.com/SoliSpirit/v2ray-configs/refs/heads/main/all_configs.txt',
      'shabane-kamaji refs':
          'https://gh.con.sh/https://raw.githubusercontent.com/shabane/kamaji/refs/heads/master/hub/merged.txt',
      'voken100g-autossr recent':
          'https://gh.con.sh/https://raw.githubusercontent.com/voken100g/AutoSSR/master/recent',
      'github-free-nodes-v2rayfree v2ray':
          'https://gh.con.sh/https://raw.githubusercontent.com/free-nodes/v2rayfree/main/v2ray',
      'freefq-free readme':
          'https://gh.con.sh/https://raw.githubusercontent.com/freefq/free/master/README.md',
      'snakem982-proxypool clash-meta-2':
          'https://gh.con.sh/https://raw.githubusercontent.com/snakem982/proxypool/main/source/clash-meta-2.yaml',
      'barabama-freenodes clashmeta yaml':
          'https://gh.con.sh/https://raw.githubusercontent.com/Barabama/FreeNodes/main/nodes/clashmeta.yaml',
      'barabama-freenodes v2rayshare yaml':
          'https://gh.con.sh/https://raw.githubusercontent.com/Barabama/FreeNodes/main/nodes/v2rayshare.yaml',
      'barabama-freenodes yudou66 yaml':
          'https://gh.con.sh/https://raw.githubusercontent.com/Barabama/FreeNodes/main/nodes/yudou66.yaml',
    };

    for (final entry in expectedGhConCandidates.entries) {
      final sourceId = entry.key.split(' ').first;
      final candidates = (findSource(sourceId)['rawCandidates'] as List)
          .cast<String>();
      expect(candidates, contains(entry.value), reason: entry.key);
    }
  });

  test(
    'asset catalog enables GitHub discovery for mirrored repository sources',
    () async {
      final sourceCatalogJson = await File(
        'assets/data/free_node_sources.json',
      ).readAsString();
      final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
      final sources = (data['sources'] as List).cast<Map>();

      Map findSource(String id) {
        return sources.singleWhere((item) => item['id'] == id);
      }

      const repositorySourceIds = {
        'github-free-nodes-clashfree',
        'pawdroid-free-servers',
        'free18-v2ray',
        'au1rxx-free-vpn-subscriptions',
        'proxifly-free-proxy-list',
        'proxyscrape-free-proxy-list',
        'shaoyouvip-free',
        'freefq-free',
        'snakem982-proxypool',
        'dongchengjie-airport',
      };

      for (final sourceId in repositorySourceIds) {
        expect(findSource(sourceId)['githubDiscovery'], true, reason: sourceId);
      }
    },
  );

  test('asset catalog uses supported protocol shards for JSON proxy list sources', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map>();
    final proxifly = sources.singleWhere(
      (item) => item['id'] == 'proxifly-free-proxy-list',
    );
    final proxyscrape = sources.singleWhere(
      (item) => item['id'] == 'proxyscrape-free-proxy-list',
    );
    final proxiflyCandidates = (proxifly['rawCandidates'] as List)
        .cast<String>();
    final proxyscrapeCandidates = (proxyscrape['rawCandidates'] as List)
        .cast<String>();

    expect(
      proxiflyCandidates,
      contains(
        'https://cdn.jsdelivr.net/gh/proxifly/free-proxy-list@main/proxies/protocols/socks5/data.json',
      ),
    );
    expect(proxiflyCandidates.any((url) => url.contains('socks4')), isFalse);
    expect(proxiflyCandidates.any((url) => url.contains('/all/')), isFalse);
    expect(
      proxiflyCandidates,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/proxifly/free-proxy-list/main/proxies/protocols/socks5/data.json',
      ),
    );
    expect(
      proxiflyCandidates,
      contains(
        'https://gh.con.sh/https://raw.githubusercontent.com/proxifly/free-proxy-list/main/proxies/protocols/socks5/data.json',
      ),
    );
    expect(
      proxiflyCandidates,
      contains(
        'https://raw.githubusercontent.com/proxifly/free-proxy-list/main/proxies/protocols/http/data.json',
      ),
    );
    expect(
      proxyscrapeCandidates,
      contains(
        'https://cdn.jsdelivr.net/gh/proxyscrape/free-proxy-list@main/proxies/protocols/https/data.json',
      ),
    );
    expect(proxyscrapeCandidates.any((url) => url.contains('socks4')), isFalse);
    expect(proxyscrapeCandidates.any((url) => url.contains('/all/')), isFalse);
    expect(
      proxyscrapeCandidates,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/proxyscrape/free-proxy-list/main/proxies/protocols/socks5/data.json',
      ),
    );
    expect(
      proxyscrapeCandidates,
      contains(
        'https://gh.con.sh/https://raw.githubusercontent.com/proxyscrape/free-proxy-list/main/proxies/protocols/http/data.json',
      ),
    );
    expect(
      proxyscrapeCandidates,
      contains(
        'https://raw.githubusercontent.com/proxyscrape/free-proxy-list/main/proxies/protocols/http/data.json',
      ),
    );
  });

  test('asset catalog mirrors jetkai online proxy formats', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map>();
    final source = sources.singleWhere(
      (item) => item['id'] == 'jetkai-proxy-list',
    );
    final candidates = (source['rawCandidates'] as List).cast<String>();

    expect(
      candidates,
      contains(
        'https://cdn.jsdelivr.net/gh/jetkai/proxy-list@main/online-proxies/yaml/proxies-basic.yaml',
      ),
    );
    expect(
      candidates,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/jetkai/proxy-list/main/online-proxies/csv/proxies.csv',
      ),
    );
    expect(
      candidates,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/jetkai/proxy-list/main/online-proxies/json/proxies-basic.json',
      ),
    );
    expect(
      candidates,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/jetkai/proxy-list/main/online-proxies/xml/proxies-basic.xml',
      ),
    );
    expect(
      candidates,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/jetkai/proxy-list/main/online-proxies/yaml/proxies-basic.yaml',
      ),
    );
    expect(
      candidates,
      contains(
        'https://gh.con.sh/https://raw.githubusercontent.com/jetkai/proxy-list/main/online-proxies/yaml/proxies.yaml',
      ),
    );
    expect(
      candidates,
      contains(
        'https://gh.con.sh/https://raw.githubusercontent.com/jetkai/proxy-list/main/online-proxies/yaml/proxies-basic.yaml',
      ),
    );
    expect(
      candidates,
      contains(
        'https://raw.githubusercontent.com/jetkai/proxy-list/main/online-proxies/yaml/proxies-basic.yaml',
      ),
    );
  });

  test('asset catalog mirrors supported root text proxy protocol shards', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map>();
    final theSpeedX = sources.singleWhere(
      (item) => item['id'] == 'thespeedx-socks-list',
    );
    final ipLocate = sources.singleWhere(
      (item) => item['id'] == 'iplocate-free-proxy-list',
    );
    final clarketm = sources.singleWhere(
      (item) => item['id'] == 'clarketm-proxy-list',
    );
    final theSpeedXCandidates = (theSpeedX['rawCandidates'] as List)
        .cast<String>();
    final ipLocateCandidates = (ipLocate['rawCandidates'] as List)
        .cast<String>();
    final clarketmCandidates = (clarketm['rawCandidates'] as List)
        .cast<String>();

    expect(
      theSpeedXCandidates,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/TheSpeedX/SOCKS-List/master/http.txt',
      ),
    );
    expect(
      theSpeedXCandidates,
      contains(
        'https://gh.con.sh/https://raw.githubusercontent.com/TheSpeedX/SOCKS-List/master/socks5.txt',
      ),
    );
    expect(
      theSpeedXCandidates,
      contains(
        'https://raw.githubusercontent.com/TheSpeedX/SOCKS-List/master/http.txt',
      ),
    );
    expect(theSpeedXCandidates.any((url) => url.contains('socks4')), isFalse);

    expect(
      ipLocateCandidates,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/iplocate/free-proxy-list/main/protocols/socks5.txt',
      ),
    );
    expect(
      ipLocateCandidates,
      contains(
        'https://gh.con.sh/https://raw.githubusercontent.com/iplocate/free-proxy-list/main/all-proxies.txt',
      ),
    );
    expect(
      ipLocateCandidates,
      contains(
        'https://raw.githubusercontent.com/iplocate/free-proxy-list/main/protocols/https.txt',
      ),
    );
    expect(ipLocateCandidates.any((url) => url.contains('socks4')), isFalse);

    expect(
      clarketmCandidates,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/clarketm/proxy-list/master/proxy-list-raw.txt',
      ),
    );
    expect(
      clarketmCandidates,
      contains(
        'https://gh.con.sh/https://raw.githubusercontent.com/clarketm/proxy-list/master/proxy-list-raw.txt',
      ),
    );
    expect(
      clarketmCandidates,
      contains(
        'https://raw.githubusercontent.com/clarketm/proxy-list/master/proxy-list-raw.txt',
      ),
    );
    expect(clarketmCandidates.any((url) => url.contains('socks4')), isFalse);
  });

  test('asset catalog keeps vakhov GitHub Pages proxy formats', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map>();
    final source = sources.singleWhere(
      (item) => item['id'] == 'vakhov-fresh-proxy-list',
    );
    final candidates = (source['rawCandidates'] as List).cast<String>();

    expect(
      candidates,
      contains('https://vakhov.github.io/fresh-proxy-list/http.txt'),
    );
    expect(
      candidates,
      contains('https://vakhov.github.io/fresh-proxy-list/https.txt'),
    );
    expect(
      candidates,
      contains('https://vakhov.github.io/fresh-proxy-list/socks5.txt'),
    );
    expect(
      candidates,
      contains('https://vakhov.github.io/fresh-proxy-list/proxylist.txt'),
    );
    expect(
      candidates,
      contains('https://vakhov.github.io/fresh-proxy-list/proxylist.json'),
    );
    expect(candidates.any((url) => url.contains('socks4')), isFalse);
  });

  test('asset catalog mirrors vakhov raw proxy formats', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map>();
    final source = sources.singleWhere(
      (item) => item['id'] == 'vakhov-fresh-proxy-list',
    );
    final candidates = (source['rawCandidates'] as List).cast<String>();

    expect(
      candidates,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/vakhov/fresh-proxy-list/master/http.txt',
      ),
    );
    expect(
      candidates,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/vakhov/fresh-proxy-list/master/https.txt',
      ),
    );
    expect(
      candidates,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/vakhov/fresh-proxy-list/master/socks5.txt',
      ),
    );
    expect(
      candidates,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/vakhov/fresh-proxy-list/master/proxylist.json',
      ),
    );
    expect(
      candidates,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/vakhov/fresh-proxy-list/master/proxylist.csv',
      ),
    );
    expect(
      candidates,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/vakhov/fresh-proxy-list/master/proxylist.xml',
      ),
    );
    expect(
      candidates,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/vakhov/fresh-proxy-list/master/proxylist.phps',
      ),
    );
    expect(
      candidates,
      contains(
        'https://gh.con.sh/https://raw.githubusercontent.com/vakhov/fresh-proxy-list/master/http.txt',
      ),
    );
    expect(
      candidates,
      contains(
        'https://gh.con.sh/https://raw.githubusercontent.com/vakhov/fresh-proxy-list/master/proxylist.json',
      ),
    );
    expect(
      candidates,
      contains(
        'https://raw.githubusercontent.com/vakhov/fresh-proxy-list/master/http.txt',
      ),
    );
    expect(
      candidates,
      contains(
        'https://raw.githubusercontent.com/vakhov/fresh-proxy-list/master/proxylist.json',
      ),
    );
    expect(candidates.any((url) => url.contains('socks4')), isFalse);
  });

  test('asset catalog adds verified mirrored high frequency public sources', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map>();

    Map findSource(String id) {
      return sources.singleWhere((item) => item['id'] == id);
    }

    final r3zarahimi = findSource('r3zarahimi-tg-v2ray-configs-every2h');
    final r3Candidates = (r3zarahimi['rawCandidates'] as List).cast<String>();

    expect(r3zarahimi['githubDiscovery'], true);
    expect(r3zarahimi['updateIntervalHours'], 2);
    expect(
      r3Candidates.first,
      'https://ghfile.geekertao.top/https://raw.githubusercontent.com/r3zarahimi/tg-v2ray-configs-every2h/main/Config_jo.txt',
    );
    expect(
      r3Candidates,
      contains(
        'https://ghfast.top/https://raw.githubusercontent.com/r3zarahimi/tg-v2ray-configs-every2h/main/regions/conf-US.txt',
      ),
    );
    expect(
      r3Candidates,
      contains(
        'https://ghproxy.net/https://raw.githubusercontent.com/r3zarahimi/tg-v2ray-configs-every2h/main/regions/conf-FR.txt',
      ),
    );
    expect(
      r3Candidates,
      isNot(
        contains(
          'https://ghfast.top/https://raw.githubusercontent.com/r3zarahimi/tg-v2ray-configs-every2h/main/regions/conf-FR.txt',
        ),
      ),
    );
    expect(
      r3Candidates,
      contains(
        'https://raw.githubusercontent.com/r3zarahimi/tg-v2ray-configs-every2h/main/Config-jo.yaml',
      ),
    );

    final asgharkapk = findSource('asgharkapk-free-clash-meta');
    final asgharCandidates = (asgharkapk['rawCandidates'] as List)
        .cast<String>();

    expect(asgharkapk['githubDiscovery'], true);
    expect(
      asgharCandidates.first,
      'https://ghfile.geekertao.top/https://raw.githubusercontent.com/asgharkapk/Free-Clash-Meta/main/Sublist/Complex/10ium/HighSpeed.yaml',
    );
    expect(
      asgharCandidates,
      contains(
        'https://ghfast.top/https://raw.githubusercontent.com/asgharkapk/Free-Clash-Meta/main/Sublist/Simple/linzjian666/chromego_extractor/outputs/clash_meta.yaml',
      ),
    );
    expect(
      asgharCandidates,
      contains(
        'https://ghproxy.net/https://raw.githubusercontent.com/asgharkapk/Free-Clash-Meta/main/Sublist/Simple/vpnclashfa-backup/MirrorMan/shatakvpn.yml',
      ),
    );
    expect(
      asgharCandidates,
      contains(
        'https://raw.githubusercontent.com/asgharkapk/Free-Clash-Meta/main/Sublist/Simple/vpny.online/VPNy.json',
      ),
    );
    expect(
      asgharCandidates.any((url) => url.startsWith('https://gh.con.sh/')),
      isFalse,
    );
  });

  test('asset catalog adds second live verified GitHub source batch', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map>();

    Map findSource(String id) {
      return sources.singleWhere((item) => item['id'] == id);
    }

    const expectedFirstCandidates = {
      'moneyfly1-sublist':
          'https://ghfile.geekertao.top/https://raw.githubusercontent.com/moneyfly1/sublist/main/clash.yml',
      'shbioc-clash':
          'https://ghfast.top/https://raw.githubusercontent.com/shbioc/clash/main/aaa01.yaml',
      'chongdong1230-dxz':
          'https://ghfile.geekertao.top/https://raw.githubusercontent.com/chongdong1230/dxz/main/clash',
      'freebaipiao-freebaipiao':
          'https://ghfile.geekertao.top/https://raw.githubusercontent.com/freebaipiao/freebaipiao/main/jiassweetoy3.yaml',
      'gooooooooooooogle-clash-config':
          'https://ghfast.top/https://raw.githubusercontent.com/gooooooooooooogle/Clash-Config/main/Clash.yaml',
      'itsyebekhe-psg':
          'https://ghfile.geekertao.top/https://raw.githubusercontent.com/itsyebekhe/PSG/main/subscriptions/clash/mix',
      '10ium-free-config':
          'https://ghfile.geekertao.top/https://raw.githubusercontent.com/10ium/free-config/refs/heads/main/free-mihomo-sub/HighSpeed.yaml',
      'liketolivefree-kobabi':
          'https://ghfile.geekertao.top/https://raw.githubusercontent.com/liketolivefree/kobabi/main/clash_mt_ir_prov_f.yaml',
      'diditen-scrape-and-categorize':
          'https://ghfile.geekertao.top/https://raw.githubusercontent.com/DiDiten/ScrapeAndCategorize/main/Clash/output/scrape-iran.yaml',
      'rango-cfs-newcollector':
          'https://ghfile.geekertao.top/https://raw.githubusercontent.com/rango-cfs/NewCollector/refs/heads/main/v2ray_links.txt',
    };

    for (final entry in expectedFirstCandidates.entries) {
      final source = findSource(entry.key);
      final candidates = (source['rawCandidates'] as List).cast<String>();

      expect(source['githubDiscovery'], true, reason: entry.key);
      expect(candidates.first, entry.value, reason: entry.key);
      expect(
        candidates.any(
          (url) => url.startsWith('https://raw.githubusercontent.com/'),
        ),
        true,
        reason: entry.key,
      );
    }

    final shbiocCandidates =
        (findSource('shbioc-clash')['rawCandidates'] as List).cast<String>();
    expect(
      shbiocCandidates.any(
        (url) => url.startsWith('https://ghfile.geekertao.top/'),
      ),
      isFalse,
    );
    expect(
      shbiocCandidates.any((url) => url.startsWith('https://ghproxy.net/')),
      isFalse,
    );

    final googleCandidates =
        (findSource('gooooooooooooogle-clash-config')['rawCandidates'] as List)
            .cast<String>();
    expect(
      googleCandidates.any(
        (url) => url.startsWith('https://ghfile.geekertao.top/'),
      ),
      isFalse,
    );

    final kobabiCandidates =
        (findSource('liketolivefree-kobabi')['rawCandidates'] as List)
            .cast<String>();
    expect(
      kobabiCandidates,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/liketolivefree/kobabi/main/clash_mt_ir_prov_f2.yaml',
      ),
    );
  });

  test('asset catalog adds third live verified GitHub source batch', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map>();

    Map findSource(String id) {
      return sources.singleWhere((item) => item['id'] == id);
    }

    const expectedFirstCandidates = {
      'proxydaemitelegram-proxydaemi44':
          'https://ghfile.geekertao.top/https://raw.githubusercontent.com/Proxydaemitelegram/Proxydaemi44/refs/heads/main/Proxydaemi44',
      '4n0nymou3-multi-proxy-config-fetcher':
          'https://ghfile.geekertao.top/https://raw.githubusercontent.com/4n0nymou3/multi-proxy-config-fetcher/refs/heads/main/configs/proxy_configs.txt',
      'monday9907-v2ray':
          'https://ghfile.geekertao.top/https://raw.githubusercontent.com/MOnday9907/v2ray/main/v2ray.txt',
      'adminaliang-v2ray':
          'https://ghfile.geekertao.top/https://raw.githubusercontent.com/adminaliang/v2ray/main/v2ray',
      'baip01-clash':
          'https://ghfile.geekertao.top/https://raw.githubusercontent.com/baip01/clash/main/clash',
      'baipiao0-baipiao02':
          'https://ghfile.geekertao.top/https://raw.githubusercontent.com/baipiao0/baipiao02/main/v2ray',
      'nodesfree-v2raynode':
          'https://ghfile.geekertao.top/https://raw.githubusercontent.com/nodesfree/v2raynode/refs/heads/main/subscribe/v2ray.txt',
      'resasanian-mirza':
          'https://ghfile.geekertao.top/https://raw.githubusercontent.com/resasanian/Mirza/main/sub',
      'yanstar-free-proxy':
          'https://ghfile.geekertao.top/https://raw.githubusercontent.com/YanStar/free-proxy/refs/heads/main/v2ray.txt',
    };

    for (final entry in expectedFirstCandidates.entries) {
      final source = findSource(entry.key);
      final candidates = (source['rawCandidates'] as List).cast<String>();

      expect(source['githubDiscovery'], true, reason: entry.key);
      expect(candidates.first, entry.value, reason: entry.key);
      expect(
        candidates.any(
          (url) => url.startsWith('https://raw.githubusercontent.com/'),
        ),
        true,
        reason: entry.key,
      );
      expect(
        candidates.any((url) => url.startsWith('https://ghproxy.net/')),
        true,
        reason: entry.key,
      );
      expect(
        candidates.any((url) => url.startsWith('https://gh-proxy.com/')),
        true,
        reason: entry.key,
      );
    }

    final yanStarCandidates =
        (findSource('yanstar-free-proxy')['rawCandidates'] as List)
            .cast<String>();
    expect(
      yanStarCandidates,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/YanStar/free-proxy/refs/heads/main/v2ray_subscribe.txt',
      ),
    );
    expect(
      yanStarCandidates,
      contains(
        'https://raw.githubusercontent.com/YanStar/free-proxy/refs/heads/main/v2ray_subscribe.txt',
      ),
    );
  });

  test('asset catalog adds fourth live verified GitHub source batch', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map>();

    Map findSource(String id) {
      return sources.singleWhere((item) => item['id'] == id);
    }

    const expectedFirstCandidates = {
      'arshiacomplus-v2rayextractor':
          'https://ghfile.geekertao.top/https://raw.githubusercontent.com/arshiacomplus/v2rayExtractor/refs/heads/main/mix/sub.html',
      'hosseinkoofi-go-v2raycollector':
          'https://ghfile.geekertao.top/https://raw.githubusercontent.com/HosseinKoofi/GO_V2rayCollector/main/ss_iran.txt',
      '10ium-v2hub3':
          'https://ghfile.geekertao.top/https://raw.githubusercontent.com/10ium/V2Hub3/main/merged_base64',
      'ndsphonemy-proxy-sub':
          'https://ghfile.geekertao.top/https://raw.githubusercontent.com/ndsphonemy/proxy-sub/refs/heads/main/speed.txt',
      'created-by-telegram-eag1e-yt':
          'https://ghfile.geekertao.top/https://raw.githubusercontent.com/Created-By/Telegram-Eag1e_YT/refs/heads/main/%40Eag1e_YT',
    };

    for (final entry in expectedFirstCandidates.entries) {
      final source = findSource(entry.key);
      final candidates = (source['rawCandidates'] as List).cast<String>();

      expect(source['githubDiscovery'], true, reason: entry.key);
      expect(candidates.first, entry.value, reason: entry.key);
      expect(
        candidates.any((url) => url.startsWith('https://ghfast.top/')),
        true,
        reason: entry.key,
      );
      expect(
        candidates.any((url) => url.startsWith('https://ghproxy.net/')),
        true,
        reason: entry.key,
      );
      expect(
        candidates.any((url) => url.startsWith('https://gh-proxy.com/')),
        true,
        reason: entry.key,
      );
      expect(
        candidates.any(
          (url) => url.startsWith('https://raw.githubusercontent.com/'),
        ),
        true,
        reason: entry.key,
      );
    }

    final v2hub3Candidates =
        (findSource('10ium-v2hub3')['rawCandidates'] as List).cast<String>();
    expect(
      v2hub3Candidates,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/10ium/V2Hub3/refs/heads/main/Split/Normal/shadowsocks',
      ),
    );
    expect(
      v2hub3Candidates,
      contains(
        'https://raw.githubusercontent.com/10ium/V2Hub3/refs/heads/main/Split/Normal/shadowsocks',
      ),
    );

    final ndsphonemyCandidates =
        (findSource('ndsphonemy-proxy-sub')['rawCandidates'] as List)
            .cast<String>();
    expect(
      ndsphonemyCandidates,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/ndsphonemy/proxy-sub/refs/heads/main/hys-tuic.txt',
      ),
    );
    expect(
      ndsphonemyCandidates,
      contains(
        'https://raw.githubusercontent.com/ndsphonemy/proxy-sub/refs/heads/main/hys-tuic.txt',
      ),
    );
  });

  test('asset catalog adds fifth live verified GitHub source batch', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map>();

    Map findSource(String id) {
      return sources.singleWhere((item) => item['id'] == id);
    }

    const expectedFirstCandidates = {
      'aqayerez-matnofficial-vpn':
          'https://ghfile.geekertao.top/https://raw.githubusercontent.com/aqayerez/MatnOfficial-VPN/refs/heads/main/MatnOfficial',
      '10ium-scrapeandcategorize':
          'https://ghfile.geekertao.top/https://raw.githubusercontent.com/10ium/ScrapeAndCategorize/refs/heads/main/output_configs/Vless.txt',
      'darknessshade-sub':
          'https://ghfile.geekertao.top/https://raw.githubusercontent.com/DarknessShade/Sub/main/V2mix',
      'nscl5-4':
          'https://ghfile.geekertao.top/https://raw.githubusercontent.com/nscl5/4/refs/heads/main/Splitted-By-Protocol/ss.txt',
      'nscl5-5':
          'https://ghfile.geekertao.top/https://raw.githubusercontent.com/nscl5/5/refs/heads/main/configs/all.txt',
      'lagzian-iranconfigcollector':
          'https://ghfile.geekertao.top/https://raw.githubusercontent.com/lagzian/IranConfigCollector/main/Base64.txt',
    };

    for (final entry in expectedFirstCandidates.entries) {
      final source = findSource(entry.key);
      final candidates = (source['rawCandidates'] as List).cast<String>();

      expect(source['githubDiscovery'], true, reason: entry.key);
      expect(candidates.first, entry.value, reason: entry.key);
      expect(
        candidates.any((url) => url.startsWith('https://ghfast.top/')),
        true,
        reason: entry.key,
      );
      expect(
        candidates.any((url) => url.startsWith('https://ghproxy.net/')),
        true,
        reason: entry.key,
      );
      expect(
        candidates.any((url) => url.startsWith('https://gh-proxy.com/')),
        true,
        reason: entry.key,
      );
      expect(
        candidates.any(
          (url) => url.startsWith('https://raw.githubusercontent.com/'),
        ),
        true,
        reason: entry.key,
      );
    }

    final darknessShadeCandidates =
        (findSource('darknessshade-sub')['rawCandidates'] as List)
            .cast<String>();
    expect(
      darknessShadeCandidates,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/DarknessShade/Sub/main/Ss',
      ),
    );
    expect(
      darknessShadeCandidates,
      contains('https://raw.githubusercontent.com/DarknessShade/Sub/main/Ss'),
    );

    final nscl5Candidates = (findSource('nscl5-5')['rawCandidates'] as List)
        .cast<String>();
    expect(
      nscl5Candidates,
      contains(
        'https://ghfile.geekertao.top/https://raw.githubusercontent.com/nscl5/5/refs/heads/main/configs/vmess.txt',
      ),
    );
    expect(
      nscl5Candidates,
      contains(
        'https://raw.githubusercontent.com/nscl5/5/refs/heads/main/configs/vmess.txt',
      ),
    );
  });

  test('asset catalog backfills high rank GitHub source mirrors', () async {
    final sourceCatalogJson = await File(
      'assets/data/free_node_sources.json',
    ).readAsString();
    final data = json.decode(sourceCatalogJson) as Map<String, dynamic>;
    final sources = (data['sources'] as List).cast<Map>();

    Map findSource(String id) {
      return sources.singleWhere((item) => item['id'] == id);
    }

    final puddinCatCandidates =
        (findSource('puddincat-bestclash')['rawCandidates'] as List)
            .cast<String>();
    expect(
      puddinCatCandidates,
      containsAll([
        'https://ghfile.geekertao.top/https://github.com/PuddinCat/BestClash/blob/main/proxies.yaml',
        'https://ghfast.top/https://raw.githubusercontent.com/PuddinCat/BestClash/refs/heads/main/proxies.yaml',
        'https://ghproxy.net/https://raw.githubusercontent.com/PuddinCat/BestClash/refs/heads/main/proxies.yaml',
        'https://gh-proxy.com/https://raw.githubusercontent.com/PuddinCat/BestClash/refs/heads/main/proxies.yaml',
        'https://ghproxy.imciel.com/https://raw.githubusercontent.com/PuddinCat/BestClash/refs/heads/main/proxies.yaml',
        'https://gh.monlor.com/https://raw.githubusercontent.com/PuddinCat/BestClash/refs/heads/main/proxies.yaml',
        'https://gh.ddlc.top/https://raw.githubusercontent.com/PuddinCat/BestClash/refs/heads/main/proxies.yaml',
        'https://raw.githubusercontent.com/PuddinCat/BestClash/refs/heads/main/proxies.yaml',
      ]),
    );

    final free18Candidates =
        (findSource('free18-v2ray')['rawCandidates'] as List).cast<String>();
    expect(
      free18Candidates,
      containsAll([
        'https://ghfast.top/https://raw.githubusercontent.com/free18/v2ray/main/c.yaml',
        'https://ghproxy.net/https://raw.githubusercontent.com/free18/v2ray/main/v.txt',
        'https://gh-proxy.com/https://raw.githubusercontent.com/free18/v2ray/main/c.yaml',
      ]),
    );

    final au1rxxCandidates =
        (findSource('au1rxx-free-vpn-subscriptions')['rawCandidates'] as List)
            .cast<String>();
    expect(
      au1rxxCandidates,
      containsAll([
        'https://ghfast.top/https://raw.githubusercontent.com/Au1rxx/free-vpn-subscriptions/main/output/clash.yaml',
        'https://ghproxy.net/https://raw.githubusercontent.com/Au1rxx/free-vpn-subscriptions/main/output/singbox.json',
        'https://gh-proxy.com/https://raw.githubusercontent.com/Au1rxx/free-vpn-subscriptions/main/output/v2ray-base64.txt',
      ]),
    );
  });

  test(
    'live free node sources expose at least one usable Clash YAML source',
    () async {
      if (const bool.fromEnvironment('FLCLASH_LIVE_FREE_NODES') != true) {
        return;
      }

      final sourceCatalogJson = await File(
        'assets/data/free_node_sources.json',
      ).readAsString();
      final result = await FreeNodesService(
        sourceCatalogJson: sourceCatalogJson,
        fetcher: _fetchLiveText,
        enabledSourceIds: const {
          'ermao-net',
          'dongchengjie-airport',
          'shaoyouvip-free',
          'snakem982-proxypool',
        },
      ).fetchMergedConfig();
      final successfulSourceList = result.sources
          .where((source) {
            return source.success && source.proxyCount > 0;
          })
          .toList(growable: false);
      final familyCounts = <String, int>{};
      for (final source in successfulSourceList) {
        familyCounts.update(
          source.sourceId ?? _sourceFamily(source.url),
          (value) => value + source.proxyCount,
          ifAbsent: () => source.proxyCount,
        );
      }
      // Kept for release verification evidence when the live test is requested.
      // ignore: avoid_print
      print(
        'live_free_nodes proxyCount=${result.proxyCount} successfulSources=${successfulSourceList.length}',
      );
      for (final entry in familyCounts.entries) {
        // ignore: avoid_print
        print('live_family ${entry.key} ${entry.value}');
      }
      for (final source in successfulSourceList.take(40)) {
        // ignore: avoid_print
        print('live_success ${source.proxyCount} ${source.url}');
      }

      expect(result.proxyCount, greaterThan(0));
      expect(successfulSourceList.length, greaterThan(0));
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );

  test(
    'live searched free node sources expose a usable Clash YAML source',
    () async {
      if (const bool.fromEnvironment('FLCLASH_LIVE_FREE_NODES') != true) {
        return;
      }

      final sourceCatalogJson = await File(
        'assets/data/free_node_sources.json',
      ).readAsString();
      final result = await FreeNodesService(
        sourceCatalogJson: sourceCatalogJson,
        fetcher: _fetchLiveText,
        enabledSourceIds: const {
          'pawdroid-free-servers',
          'free18-v2ray',
          'freenodes-github-io',
          'ermao-net',
          'shaoyouvip-free',
          'snakem982-proxypool',
          'dongchengjie-airport',
          'barabama-freenodes',
        },
      ).fetchMergedConfig();
      final familyCounts = <String, int>{};
      for (final source in result.sources) {
        if (!source.success || source.proxyCount <= 0) continue;
        familyCounts.update(
          source.sourceId ?? _sourceFamily(source.url),
          (value) => value + source.proxyCount,
          ifAbsent: () => source.proxyCount,
        );
      }
      // ignore: avoid_print
      print(
        'live_searched_free_nodes proxyCount=${result.proxyCount} '
        'families=${familyCounts.length}',
      );
      for (final entry in familyCounts.entries) {
        // ignore: avoid_print
        print('live_searched_family ${entry.key} ${entry.value}');
      }

      expect(result.proxyCount, greaterThan(0));
      expect(familyCounts.length, greaterThan(0));
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}

String _sourceFamily(String url) {
  final lower = url.toLowerCase();
  if (lower.contains('free-nodes/clashfree')) return 'github-free-nodes';
  if (lower.contains('freeclashnode.com') ||
      lower.contains('node.freeclashnode.com')) {
    return 'freeclashnode';
  }
  if (lower.contains('oneclash.cc') || lower.contains('oss.oneclash.cc')) {
    return 'oneclash';
  }
  if (lower.contains('v2rayshare.net') ||
      lower.contains('static.v2rayshare.net')) {
    return 'v2rayshare';
  }
  if (lower.contains('clashgithub.com')) return 'clashgithub';
  if (lower.contains('clashnode.cc') || lower.contains('node.clashnode.cc')) {
    return 'clashnode';
  }
  if (lower.contains('datiya.com')) return 'datiya';
  if (lower.contains('puddincat/bestclash')) return 'puddincat';
  if (lower.contains('clashmeta.cc') || lower.contains('node.clashmeta.cc')) {
    return 'clashmeta';
  }
  if (lower.contains('crossxx') || lower.contains('freeclash.top')) {
    return 'crossxx';
  }
  if (lower.contains('freenode.biz')) return 'freenodebiz';
  if (lower.contains('ripaojiedian/freenode') ||
      lower.contains('down.nigx.cn/raw.githubusercontent.com/ripaojiedian')) {
    return 'ripaojiedian';
  }
  if (lower.contains('freenodes/freenodes')) return 'freenodes';
  if (lower.contains('a2470982985/getnode') ||
      lower.contains('flikify/getnode')) {
    return 'flikify';
  }
  if (lower.contains('barabama/freenodes')) return 'barabama';
  if (lower.contains('free-clash-v2ray.github.io')) {
    return 'free-clash-v2ray';
  }
  return Uri.tryParse(url)?.host ?? url;
}

String _stripKnownGithubMirrorPrefixForTest(String url) {
  for (final prefix in const [
    'https://ghfile.geekertao.top/',
    'https://gh-proxy.com/',
    'https://ghproxy.net/',
    'https://ghfast.top/',
    'https://gh.llkk.cc/',
    'https://gh.ddlc.top/',
  ]) {
    if (!url.toLowerCase().startsWith(prefix)) continue;
    final rest = url.substring(prefix.length);
    if (rest.startsWith('http://') || rest.startsWith('https://')) {
      return rest;
    }
  }
  return url;
}

Future<String> _fetchLiveText(String url) async {
  final httpText = await _fetchLiveTextWithHttpClient(url);
  if (httpText.trim().isNotEmpty) return httpText;
  return _fetchLiveTextWithCurl(url);
}

Future<String> _fetchLiveTextWithHttpClient(String url) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  try {
    final request = await client
        .getUrl(Uri.parse(url))
        .timeout(const Duration(seconds: 10));
    request.headers.set(
      HttpHeaders.userAgentHeader,
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
      'AppleWebKit/537.36 (KHTML, like Gecko) FlClashPlusPlus/1.0',
    );
    final response = await request.close().timeout(const Duration(seconds: 10));
    return utf8.decoder.bind(response).join();
  } catch (_) {
    return '';
  } finally {
    client.close();
  }
}

Future<String> _fetchLiveTextWithCurl(String url) async {
  try {
    final result = await Process.run(
      'curl.exe',
      [
        '-L',
        '--max-time',
        '15',
        '-A',
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) FlClashPlusPlus/1.0',
        url,
      ],
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
    if (result.exitCode == 0) return result.stdout.toString();
  } catch (_) {}
  return '';
}
