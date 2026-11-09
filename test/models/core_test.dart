import 'dart:convert';

import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:test/test.dart';

void main() {
  group('SetupParams', () {
    test('fromJson uses snake-case keys', () {
      final json = {
        'selected-map': {'G1': 'P1'},
        'options': {'test-url': 'http://test.com', 'skip-cert-verify': true},
      };
      final params = SetupParams.fromJson(json);
      expect(params.selectedMap, {'G1': 'P1'});
      expect(params.options.testUrl, 'http://test.com');
      expect(params.options.skipCertVerify, isTrue);
    });

    test('toJson uses snake-case keys', () {
      const params = SetupParams(
        selectedMap: {'G1': 'P1'},
        options: CoreOptions(testUrl: 'http://t.com'),
      );
      final json = jsonDecode(jsonEncode(params)) as Map<String, Object?>;
      expect(json['selected-map'], {'G1': 'P1'});
      expect(json['options'], {
        'test-url': 'http://t.com',
        'skip-cert-verify': false,
        'delay-test-timeout': defaultDelayTestTimeout,
        'mitm-capture': false,
      });
    });
  });

  group('UpdateParams', () {
    test('fromJson with all fields', () {
      final json = {
        'tun': {'enable': true},
        'mixed-port': 7890,
        'allow-lan': true,
        'find-process-mode': 'off',
        'mode': 'rule',
        'log-level': 'info',
        'ipv6': false,
        'tcp-concurrent': false,
        'external-controller': '',
        'unified-delay': false,
        'options': {'test-url': 'http://t.com'},
      };
      final params = UpdateParams.fromJson(json);
      expect(params.mixedPort, 7890);
      expect(params.allowLan, true);
      expect(params.mode, Mode.rule);
      expect(params.logLevel, LogLevel.info);
    });
  });

  group('InitParams', () {
    test('fromJson and toJson', () {
      final json = {'home-dir': '/data/clash', 'version': 3};
      final params = InitParams.fromJson(json);
      expect(params.homeDir, '/data/clash');
      expect(params.version, 3);
      final restored = jsonDecode(jsonEncode(params.toJson()));
      expect(restored['home-dir'], '/data/clash');
      expect(restored['version'], 3);
    });
  });

  group('VpnOptions.effective', () {
    const options = VpnOptions(
      enable: true,
      port: 7890,
      ipv6: false,
      dnsHijacking: false,
      accessControlProps: AccessControlProps(
        enable: true,
        mode: AccessControlMode.acceptSelected,
        acceptList: ['a.app'],
        rejectList: ['b.app'],
      ),
      allowBypass: true,
      systemProxy: true,
      bypassDomain: ['localhost'],
      stack: 'mixed',
      routeAddress: ['0.0.0.0/0'],
      mtu: 9000,
    );

    test('tells apart every option the tunnel is built from', () {
      final changes = [
        options.copyWith(port: 7891),
        options.copyWith(ipv6: true),
        options.copyWith(dnsHijacking: true),
        options.copyWith(allowBypass: false),
        options.copyWith(systemProxy: false),
        options.copyWith(bypassDomain: const ['example.com']),
        options.copyWith(stack: 'gvisor'),
        options.copyWith(routeAddress: const ['10.0.0.0/8']),
        options.copyWith(mtu: 1500),
        options.copyWith(congestionController: 'bbr'),
        options.copyWith(
          accessControlProps: options.accessControlProps.copyWith(
            acceptList: const ['c.app'],
          ),
        ),
        options.copyWith(enable: false),
      ];

      for (final changed in changes) {
        expect(changed.effective, isNot(options.effective));
      }
    });

    test('ignores how the app list is shown and the list not applied', () {
      final changed = options.copyWith(
        accessControlProps: options.accessControlProps.copyWith(
          rejectList: const ['c.app'],
          sort: AccessSortType.name,
          isFilterSystemApp: false,
        ),
      );

      expect(changed.effective, options.effective);
    });

    test('ignores the proxy port and bypass list without a system proxy', () {
      final withoutProxy = options.copyWith(systemProxy: false);

      expect(
        withoutProxy.copyWith(port: 7891, bypassDomain: const []).effective,
        withoutProxy.effective,
      );
    });

    test('ignores the access lists while access control is off', () {
      final open = options.copyWith(
        accessControlProps: options.accessControlProps.copyWith(enable: false),
      );

      expect(
        open
            .copyWith(
              accessControlProps: open.accessControlProps.copyWith(
                mode: AccessControlMode.rejectSelected,
                acceptList: const [],
              ),
            )
            .effective,
        open.effective,
      );
    });

    test('a proxy-only run reads none of the tunnel options', () {
      final proxyOnly = options.copyWith(enable: false);

      expect(
        proxyOnly.copyWith(ipv6: true, stack: 'gvisor', mtu: 1500).effective,
        proxyOnly.effective,
      );
    });
  });

  group('ChangeProxyParams', () {
    test('fromJson and toJson use snake-case', () {
      final json = {'group-name': 'Proxy', 'proxy-name': 'auto'};
      final params = ChangeProxyParams.fromJson(json);
      expect(params.groupName, 'Proxy');
      expect(params.proxyName, 'auto');
      final out = params.toJson();
      expect(out['group-name'], 'Proxy');
      expect(out['proxy-name'], 'auto');
    });
  });

  group('Delay', () {
    test('fromJson and toJson', () {
      final json = {'name': 'P1', 'url': 'test.com', 'value': 42};
      final delay = Delay.fromJson(json);
      expect(delay.name, 'P1');
      expect(delay.url, 'test.com');
      expect(delay.value, 42);
      final out = delay.toJson();
      expect(out['value'], 42);
    });

    test('null value', () {
      final delay = Delay.fromJson({'name': 'P1', 'url': 'test.com'});
      expect(delay.value, null);
    });
  });

  group('ProxiesData', () {
    test('fromJson with proxies and all list', () {
      final json = {
        'proxies': {
          'G1': {
            'type': 'Selector',
            'now': 'auto',
            'all': ['auto', 'P1'],
          },
        },
        'all': ['G1'],
      };
      final data = ProxiesData.fromJson(json);
      expect(data.all, ['G1']);
      expect(data.proxies['G1'], isA<Map>());
    });
  });

  group('ExternalProvider', () {
    test('fromJson with subscription info', () {
      final json = {
        'name': 'TestProvider',
        'type': 'Proxy',
        'count': 10,
        'vehicle-type': 'HTTP',
        'update-at': '2024-01-01T00:00:00.000Z',
        'subscription-info': {
          'Upload': 100,
          'Download': 200,
          'Total': 1000,
          'Expire': 1700000000,
        },
      };
      final provider = ExternalProvider.fromJson(json);
      expect(provider.name, 'TestProvider');
      expect(provider.count, 10);
      expect(provider.subscriptionInfo!.upload, 100);
      expect(provider.subscriptionInfo!.download, 200);
      expect(provider.subscriptionInfo!.total, 1000);
      expect(provider.subscriptionInfo!.expire, 1700000000);
    });

    test('updatingKey uses provider_ prefix', () {
      final provider = ExternalProvider(
        name: 'MyProvider',
        type: 'Proxy',
        count: 5,
        vehicleType: 'HTTP',
        updateAt: DateTime.now(),
      );
      expect(provider.updatingKey, 'provider_MyProvider');
    });
  });

  group('CoreEvent', () {
    test('fromJson with type and data', () {
      final event = CoreEvent.fromJson({'type': 'log', 'data': 'test log'});
      expect(event.type, CoreEventType.log);
      expect(event.data, 'test log');
    });
  });

  group('MitmExchange', () {
    test('reads a request still waiting on its response', () {
      final exchange = MitmExchange.fromJson({
        'id': 3,
        'start': '2026-10-28T00:00:00Z',
        'pending': true,
        'duration': 40,
        'method': 'POST',
        'url': 'https://a.test/new',
        'status': 0,
        'request-size': 7,
        'response-size': 0,
        'connection': 'connection-1',
        'original-url': 'https://a.test/old',
        'proto': 'HTTP/2.0',
        'ttfb': 0,
        'request-header': {
          'Host': ['a.test'],
          'Accept': ['a', 'b'],
        },
        'response-header': null,
        'actions': [
          {'kind': 'url-rewrite', 'detail': 'header'},
          {'kind': 'script', 'phase': 'request', 'detail': 'sign'},
        ],
      });

      expect(exchange.originalUrl, 'https://a.test/old');
      expect(exchange.requestHeader['Accept'], ['a', 'b']);
      expect(exchange.responseHeader, isEmpty);
      expect(exchange.actions.last.phase, 'request');
      expect(exchange.error, isEmpty);
    });

    test('a body reads with its flags left out', () {
      expect(
        MitmBody.fromJson(const {'data': 'aGk='}),
        const MitmBody(data: 'aGk='),
      );
      expect(
        MitmBody.fromJson(const {
          'data': '',
          'truncated': true,
          'encoding': 'compress',
        }),
        const MitmBody(truncated: true, encoding: 'compress'),
      );
    });
  });
}
