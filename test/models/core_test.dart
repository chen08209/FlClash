import 'dart:convert';

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:test/test.dart';

void main() {
  group('SetupParams', () {
    test('fromJson uses snake-case keys', () {
      final json = {
        'selected-map': {'G1': 'P1'},
        'test-url': 'http://test.com',
      };
      final params = SetupParams.fromJson(json);
      expect(params.selectedMap, {'G1': 'P1'});
      expect(params.testUrl, 'http://test.com');
    });

    test('toJson uses snake-case keys', () {
      const params = SetupParams(
        selectedMap: {'G1': 'P1'},
        testUrl: 'http://t.com',
      );
      final json = params.toJson();
      expect(json['selected-map'], {'G1': 'P1'});
      expect(json['test-url'], 'http://t.com');
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

  group('UpdateGeoDataParams', () {
    test('fromJson with snake-case keys', () {
      final json = {'geo-type': 'mmdb', 'geo-name': 'Country'};
      final params = UpdateGeoDataParams.fromJson(json);
      expect(params.geoType, 'mmdb');
      expect(params.geoName, 'Country');
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

  group('Now', () {
    test('fromJson and toJson', () {
      final now = Now.fromJson({'name': 'test', 'value': '123'});
      expect(now.name, 'test');
      expect(now.value, '123');
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

  group('InvokeMessage', () {
    test('fromJson', () {
      final msg = InvokeMessage.fromJson({
        'type': 'protect',
        'data': {'method': 'test'},
      });
      expect(msg.type, InvokeMessageType.protect);
    });
  });
}
