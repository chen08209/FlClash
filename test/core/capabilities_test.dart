import 'package:fl_clash/core/api/dto.dart';
import 'package:fl_clash/core/api/errors.dart';
import 'package:fl_clash/core/api/mapping.dart';
import 'package:fl_clash/core/api/model_api.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/core_mocks.dart';

const _concord = CapabilitiesInfo(
  implementation: 'concord',
  version: '0.1.0',
  proxyTypes: ['direct', 'reject', 'ss', 'vmess', 'tuic'],
  transports: ['ws', 'grpc', 'h2', 'http'],
  ruleTypes: ['DOMAIN', 'MATCH'],
  ssPlugins: ['obfs', 'v2ray-plugin', 'shadow-tls'],
  congestionControllers: ['cubic', 'reno'],
  features: Features(),
);

CapabilitiesInfo _with({
  List<String>? ssPlugins,
  List<String>? congestionControllers,
}) => CapabilitiesInfo(
  implementation: _concord.implementation,
  version: _concord.version,
  proxyTypes: _concord.proxyTypes,
  transports: _concord.transports,
  ruleTypes: _concord.ruleTypes,
  ssPlugins: ssPlugins ?? _concord.ssPlugins,
  congestionControllers:
      congestionControllers ?? _concord.congestionControllers,
  features: _concord.features,
);

void main() {
  late CoreMocks mocks;

  setUp(() {
    mocks = coreMocks();
  });

  group('a Core that reports nothing', () {
    const capabilities = CoreCapabilities.everything();

    test('supports everything', () {
      expect(capabilities.restricted, isFalse);
      expect(capabilities.supportsProxyType('tailscale'), isTrue);
      expect(capabilities.supportsNetwork('mkcp'), isTrue);
      expect(capabilities.supportsSsPlugin('kcptun'), isTrue);
      expect(capabilities.supportsTunCongestionController('bbr3'), isTrue);
    });

    test('keeps every choice', () {
      const choices = ['tcp', 'mkcp'];

      expect(capabilities.supportedChoices(ProxyField.network, choices), [
        'tcp',
        'mkcp',
      ]);
    });
  });

  group('capabilities that fail to load', () {
    test(
      'surface the Core error instead of reading it as everything',
      () async {
        when(() => mocks.api.capabilities()).thenThrow(
          const CoreMethodException(code: 'core_unavailable', message: ''),
        );

        await expectLater(
          mocks.api.getCapabilities(),
          throwsA(isA<CoreMethodException>()),
        );
      },
    );

    test('warnings surface the Core error too', () async {
      when(() => mocks.api.lastWarnings()).thenThrow(
        const CoreMethodException(code: 'core_unavailable', message: ''),
      );

      await expectLater(
        mocks.controller.getConfigWarnings(),
        throwsA(isA<CoreMethodException>()),
      );
    });
  });

  group('a Core that lists what it runs', () {
    late CoreCapabilities capabilities;

    setUp(() async {
      when(() => mocks.api.capabilities()).thenAnswer((_) async => _concord);
      capabilities = await mocks.api.getCapabilities();
    });

    test('is read as restricted to the report', () {
      expect(capabilities.restricted, isTrue);
      expect(capabilities.implementation, 'concord');
      expect(capabilities.version, '0.1.0');
      expect(capabilities.ruleTypes, {'DOMAIN', 'MATCH'});
    });

    test('hides the proxy types it does not list', () {
      expect(capabilities.supportsProxyType('vmess'), isTrue);
      expect(capabilities.supportsProxyType('tailscale'), isFalse);
      expect(capabilities.supportsProxyType('easytier'), isFalse);
    });

    test('keeps tcp and drops transports it does not list', () {
      final choices = ['tcp', 'ws', 'http', 'h2', 'grpc', 'mekya', 'mkcp'];

      expect(capabilities.supportedChoices(ProxyField.network, choices), [
        'tcp',
        'ws',
        'http',
        'h2',
        'grpc',
      ]);
    });

    test('drops the ss plugins of the tier it does not run', () {
      final choices = [
        'obfs',
        'v2ray-plugin',
        'gost-plugin',
        'shadow-tls',
        'restls',
        'jls',
        'kcptun',
      ];

      expect(capabilities.supportedChoices(ProxyField.plugin, choices), [
        'obfs',
        'v2ray-plugin',
        'shadow-tls',
      ]);
    });

    test('leaves other fields alone', () {
      const choices = ['a', 'b'];

      expect(capabilities.supportedChoices(ProxyField.obfs, choices), choices);
    });

    test('offers the congestion controls its TUN stack has', () {
      expect(capabilities.supportsTunCongestionController('cubic'), isTrue);
      expect(capabilities.supportsTunCongestionController('reno'), isTrue);
      expect(capabilities.supportsTunCongestionController('bbr'), isFalse);
    });
  });

  group('ss plugins and congestion controllers', () {
    test('follow what the Core reports', () {
      final capabilities = capabilitiesOf(
        _with(
          ssPlugins: ['obfs', 'kcptun'],
          congestionControllers: ['cubic', 'bbr'],
        ),
      );

      expect(capabilities.supportsSsPlugin('kcptun'), isTrue);
      expect(capabilities.supportsSsPlugin('v2ray-plugin'), isFalse);
      expect(capabilities.supportsTunCongestionController('bbr'), isTrue);
      expect(capabilities.supportsTunCongestionController('reno'), isFalse);
    });

    test('an empty report means none, not the fallback', () {
      final capabilities = capabilitiesOf(
        _with(ssPlugins: [], congestionControllers: []),
      );

      expect(capabilities.supportsSsPlugin('obfs'), isFalse);
      expect(capabilities.supportsTunCongestionController('cubic'), isFalse);
    });

    test('fall back to the known tables when the model omits them', () {
      const capabilities = CoreCapabilities(
        implementation: 'concord',
        version: '0.1.0',
        proxyTypes: {'ss'},
        transports: {},
        ruleTypes: {},
      );

      expect(capabilities.supportsSsPlugin('obfs'), isTrue);
      expect(capabilities.supportsSsPlugin('shadow-tls'), isTrue);
      expect(capabilities.supportsSsPlugin('kcptun'), isFalse);
      expect(capabilities.supportsTunCongestionController('cubic'), isTrue);
      expect(capabilities.supportsTunCongestionController('bbr'), isFalse);
    });
  });

  test('warnings map, and only the warning level counts', () async {
    when(() => mocks.api.lastWarnings()).thenAnswer(
      (_) async => const [
        WarningInfo(level: 'warning', path: 'proxies[12]', message: 'removed'),
        WarningInfo(level: 'info', path: 'experimental', message: 'ignored'),
      ],
    );

    final warnings = await mocks.controller.getConfigWarnings();

    expect(warnings, hasLength(2));
    expect(warnings.warnings.map((item) => item.path), ['proxies[12]']);
  });

  test('no warnings is an empty list', () async {
    when(() => mocks.api.lastWarnings()).thenAnswer((_) async => const []);

    expect(await mocks.controller.getConfigWarnings(), isEmpty);
  });
}
