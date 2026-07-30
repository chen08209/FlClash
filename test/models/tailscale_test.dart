import 'dart:convert';

import 'package:fl_clash/models/models.dart';
import 'package:test/test.dart';

void main() {
  group('TailscaleProxy.toOutboundJson', () {
    test('emits only name and type when optionals are empty', () {
      const proxy = TailscaleProxy(name: 'ts-node');
      final json = proxy.toOutboundJson();
      expect(json, {'name': 'ts-node', 'type': 'tailscale'});
    });

    test('trims name and type value matches core parser', () {
      const proxy = TailscaleProxy(name: '  ts-node  ');
      final json = proxy.toOutboundJson();
      expect(json['name'], 'ts-node');
      expect(json['type'], tailscaleProxyType);
    });

    test('emits kebab-case keys for populated fields', () {
      const proxy = TailscaleProxy(
        name: 'ts-node',
        authKey: 'tskey-auth-abc',
        hostname: 'my-host',
        controlUrl: 'https://controlplane.example.com',
        stateDir: 'tailscale-state',
        ephemeral: true,
        udp: true,
        acceptRoutes: true,
      );
      final json = proxy.toOutboundJson();
      expect(json['auth-key'], 'tskey-auth-abc');
      expect(json['hostname'], 'my-host');
      expect(json['control-url'], 'https://controlplane.example.com');
      expect(json['state-dir'], 'tailscale-state');
      expect(json['ephemeral'], true);
      expect(json['udp'], true);
      expect(json['accept-routes'], true);
    });

    test('omits false boolean flags', () {
      const proxy = TailscaleProxy(name: 'ts-node');
      final json = proxy.toOutboundJson();
      expect(json.containsKey('ephemeral'), isFalse);
      expect(json.containsKey('udp'), isFalse);
      expect(json.containsKey('accept-routes'), isFalse);
      expect(json.containsKey('exit-node'), isFalse);
      expect(json.containsKey('exit-node-allow-lan-access'), isFalse);
    });

    test('includes exit-node-allow-lan-access only when exit-node is set', () {
      const proxy = TailscaleProxy(
        name: 'ts-node',
        exitNode: '100.64.0.1',
        exitNodeAllowLanAccess: true,
      );
      final json = proxy.toOutboundJson();
      expect(json['exit-node'], '100.64.0.1');
      expect(json['exit-node-allow-lan-access'], true);
    });

    test('exit-node-allow-lan-access defaults to false alongside exit-node', () {
      const proxy = TailscaleProxy(name: 'ts-node', exitNode: '100.64.0.1');
      final json = proxy.toOutboundJson();
      expect(json['exit-node'], '100.64.0.1');
      expect(json['exit-node-allow-lan-access'], false);
    });
  });

  group('TailscaleProxy validation and serialization', () {
    test('isValid requires a non-empty trimmed name', () {
      expect(const TailscaleProxy(name: '').isValid, isFalse);
      expect(const TailscaleProxy(name: '   ').isValid, isFalse);
      expect(const TailscaleProxy(name: 'ts-node').isValid, isTrue);
    });

    test('round-trips through json for persistence', () {
      const proxy = TailscaleProxy(
        name: 'ts-node',
        authKey: 'tskey-auth-abc',
        exitNode: '100.64.0.1',
        ephemeral: true,
      );
      final restored = TailscaleProxy.fromJson(
        jsonDecode(jsonEncode(proxy.toJson())) as Map<String, Object?>,
      );
      expect(restored, proxy);
    });
  });

  group('TailscaleProps', () {
    test('is disabled with no nodes by default', () {
      const props = TailscaleProps();
      expect(props.enable, isFalse);
      expect(props.proxies, isEmpty);
    });

    test('activeProxies is empty when disabled', () {
      const props = TailscaleProps(
        enable: false,
        proxies: [TailscaleProxy(name: 'ts-node')],
      );
      expect(props.activeProxies, isEmpty);
    });

    test('activeProxies returns nodes when enabled', () {
      const props = TailscaleProps(
        enable: true,
        proxies: [TailscaleProxy(name: 'ts-node')],
      );
      expect(props.activeProxies.length, 1);
    });

    test('safeFromJson falls back to default on invalid input', () {
      expect(TailscaleProps.safeFromJson(null), defaultTailscaleProps);
      expect(
        TailscaleProps.safeFromJson({'proxies': 'not-a-list'}),
        defaultTailscaleProps,
      );
    });

    test('round-trips through json', () {
      const props = TailscaleProps(
        enable: true,
        bypassTraffic: true,
        proxies: [
          TailscaleProxy(name: 'ts-node', authKey: 'k', routes: ['home-pc']),
        ],
      );
      final restored = TailscaleProps.fromJson(
        jsonDecode(jsonEncode(props.toJson())) as Map<String, Object?>,
      );
      expect(restored, props);
    });
  });

  group('buildTailscaleRouteRule', () {
    test('uses DOMAIN-SUFFIX for hostnames', () {
      expect(
        buildTailscaleRouteRule('home-pc.tailnet.ts.net', 'ts-node'),
        'DOMAIN-SUFFIX,home-pc.tailnet.ts.net,ts-node',
      );
    });

    test('uses IP-CIDR with /32 for bare IPv4', () {
      expect(
        buildTailscaleRouteRule('100.64.0.5', 'ts-node'),
        'IP-CIDR,100.64.0.5/32,ts-node,no-resolve',
      );
    });

    test('keeps an explicit IPv4 CIDR', () {
      expect(
        buildTailscaleRouteRule('192.168.1.0/24', 'ts-node'),
        'IP-CIDR,192.168.1.0/24,ts-node,no-resolve',
      );
    });

    test('uses IP-CIDR6 with /128 for bare IPv6', () {
      expect(
        buildTailscaleRouteRule('fd7a:115c:a1e0::1', 'ts-node'),
        'IP-CIDR6,fd7a:115c:a1e0::1/128,ts-node,no-resolve',
      );
    });
  });

  group('TailscaleProps.buildInjectedRules', () {
    test('is empty by default', () {
      expect(const TailscaleProps().buildInjectedRules(), isEmpty);
    });

    test('emits bypass rules when bypassTraffic is on', () {
      const props = TailscaleProps(bypassTraffic: true);
      expect(props.buildInjectedRules(), tailscaleBypassRules);
      expect(
        props.buildInjectedRules(),
        containsAll([
          'DOMAIN-SUFFIX,tailscale.com,DIRECT',
          'DOMAIN-SUFFIX,tailscale.io,DIRECT',
          'DOMAIN-SUFFIX,ts.net,DIRECT',
        ]),
      );
    });

    test('emits fake-ip filters only when bypassTraffic is on', () {
      expect(const TailscaleProps().buildFakeIpFilters(), isEmpty);
      expect(
        const TailscaleProps(bypassTraffic: true).buildFakeIpFilters(),
        tailscaleFakeIpFilters,
      );
      expect(
        const TailscaleProps(bypassTraffic: true).buildFakeIpFilters(),
        containsAll(['+.tailscale.com', '+.tailscale.io', '+.ts.net']),
      );
    });

    test('does not emit route rules when disabled', () {
      const props = TailscaleProps(
        enable: false,
        proxies: [
          TailscaleProxy(name: 'ts-node', routes: ['100.64.0.5']),
        ],
      );
      expect(props.buildInjectedRules(), isEmpty);
    });

    test('emits route rules for active nodes when enabled', () {
      const props = TailscaleProps(
        enable: true,
        proxies: [
          TailscaleProxy(
            name: 'ts-node',
            routes: ['100.64.0.5', 'home-pc.ts.net'],
          ),
        ],
      );
      expect(props.buildInjectedRules(), [
        'IP-CIDR,100.64.0.5/32,ts-node,no-resolve',
        'DOMAIN-SUFFIX,home-pc.ts.net,ts-node',
      ]);
    });

    test('route rules come before bypass rules', () {
      const props = TailscaleProps(
        enable: true,
        bypassTraffic: true,
        proxies: [
          TailscaleProxy(name: 'ts-node', routes: ['home-pc.ts.net']),
        ],
      );
      final rules = props.buildInjectedRules();
      expect(rules.first, 'DOMAIN-SUFFIX,home-pc.ts.net,ts-node');
      expect(rules.sublist(1), tailscaleBypassRules);
    });

    test('skips invalid nodes and empty routes', () {
      const props = TailscaleProps(
        enable: true,
        proxies: [
          TailscaleProxy(name: '', routes: ['ignored']),
          TailscaleProxy(name: 'ts-node', routes: ['', '  ']),
        ],
      );
      expect(props.buildInjectedRules(), isEmpty);
    });
  });

  group('TailscaleProxyListExt.mergeInto', () {
    test('adds tailscale proxies to a config without a proxies list', () {
      final config = <String, dynamic>{'mode': 'rule'};
      const proxies = [TailscaleProxy(name: 'ts-node')];
      final result = proxies.mergeInto(config);
      expect(result['proxies'], [
        {'name': 'ts-node', 'type': 'tailscale'},
      ]);
      expect(result['mode'], 'rule');
    });

    test('appends while preserving existing proxies', () {
      final config = <String, dynamic>{
        'proxies': [
          {'name': 'ss-node', 'type': 'ss'},
        ],
      };
      const proxies = [TailscaleProxy(name: 'ts-node')];
      final result = proxies.mergeInto(config);
      final resultProxies = result['proxies'] as List;
      expect(resultProxies.length, 2);
      expect(resultProxies.first, {'name': 'ss-node', 'type': 'ss'});
      expect(resultProxies.last, {'name': 'ts-node', 'type': 'tailscale'});
    });

    test('replaces an existing proxy with the same name', () {
      final config = <String, dynamic>{
        'proxies': [
          {'name': 'ts-node', 'type': 'ss'},
        ],
      };
      const proxies = [TailscaleProxy(name: 'ts-node', authKey: 'new-key')];
      final result = proxies.mergeInto(config);
      final resultProxies = result['proxies'] as List;
      expect(resultProxies.length, 1);
      expect(resultProxies.first, {
        'name': 'ts-node',
        'type': 'tailscale',
        'auth-key': 'new-key',
      });
    });

    test('skips invalid nodes', () {
      final config = <String, dynamic>{};
      const proxies = [
        TailscaleProxy(name: ''),
        TailscaleProxy(name: 'ts-node'),
      ];
      final result = proxies.mergeInto(config);
      expect((result['proxies'] as List).length, 1);
    });

    test('returns config unchanged when there are no valid nodes', () {
      final config = <String, dynamic>{
        'proxies': [
          {'name': 'ss-node', 'type': 'ss'},
        ],
      };
      const proxies = [TailscaleProxy(name: '')];
      final result = proxies.mergeInto(config);
      expect(result['proxies'], [
        {'name': 'ss-node', 'type': 'ss'},
      ]);
    });

    test('does not mutate the input config', () {
      final config = <String, dynamic>{
        'proxies': [
          {'name': 'ss-node', 'type': 'ss'},
        ],
      };
      const proxies = [TailscaleProxy(name: 'ts-node')];
      proxies.mergeInto(config);
      expect((config['proxies'] as List).length, 1);
    });
  });
}
