import 'package:fl_clash/core/desktop/model.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/core/spill.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:test/test.dart';

class _Core extends CoreHandlerInterface {
  _Core(this.answer);

  final Object? Function(CoreMethod method) answer;

  @override
  Future<Object?> invokeMethod({
    required CoreMethod method,
    Object? arguments,
    Duration? timeout,
    CoreResultModel? model,
  }) async => answer(method);

  @override
  Future<CoreLifecycleResult> start() async => _unused;

  @override
  Future<CoreLifecycleResult> restart() async => _unused;

  @override
  Future<CoreLifecycleResult> stop() async => _unused;

  @override
  Future<CoreLifecycleResult> close() async => _unused;
}

const _unused = CoreLifecycleResult(
  revision: 0,
  outcome: CoreLifecycleOutcome.applied,
);

Never _notImplemented(CoreMethod method) => throw CoreMethodException(
  code: 'not_implemented',
  message: 'unknown method: ${method.wireName}',
);

const _concord = {
  'impl': 'concord',
  'version': '0.1.0',
  'proxy-types': ['direct', 'reject', 'ss', 'vmess', 'tuic'],
  'transports': ['ws', 'grpc', 'h2', 'http'],
  'rule-types': ['DOMAIN', 'MATCH'],
  'ss-plugins': ['obfs', 'v2ray-plugin', 'shadow-tls'],
  'congestion-controllers': ['cubic', 'reno'],
  'features': {'mitm': false, 'ech': false, 'system-stack': false},
};

void main() {
  group('a Core without the methods', () {
    final core = _Core(_notImplemented);

    test('supports everything', () async {
      final capabilities = await core.getCapabilities();

      expect(capabilities.restricted, isFalse);
      expect(capabilities.supportsProxyType('tailscale'), isTrue);
      expect(capabilities.supportsNetwork('mkcp'), isTrue);
      expect(capabilities.supportsSsPlugin('kcptun'), isTrue);
      expect(capabilities.supportsTunCongestionController('bbr3'), isTrue);
    });

    test('has no warnings', () async {
      expect(await core.getConfigWarnings(), isEmpty);
    });
  });

  test('another failure is not read as missing methods', () async {
    final core = _Core(
      (_) => throw const CoreMethodException(code: 'no_response', message: ''),
    );

    await expectLater(
      core.getCapabilities(),
      throwsA(isA<CoreMethodException>()),
    );
    await expectLater(
      core.getConfigWarnings(),
      throwsA(isA<CoreMethodException>()),
    );
  });

  group('a Core that lists what it runs', () {
    late CoreCapabilities capabilities;

    setUp(() async {
      capabilities = await _Core(
        (method) => switch (method) {
          CoreMethod.coreCapabilities => _concord,
          _ => _notImplemented(method),
        },
      ).getCapabilities();
    });

    test('hides the proxy types it does not list', () {
      expect(capabilities.implementation, 'concord');
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
    Future<CoreCapabilities> load(Map<String, Object?> body) => _Core(
      (method) => switch (method) {
        CoreMethod.coreCapabilities => body,
        _ => _notImplemented(method),
      },
    ).getCapabilities();

    test('follow what the Core reports', () async {
      final capabilities = await load({
        ..._concord,
        'ss-plugins': ['obfs', 'kcptun'],
        'congestion-controllers': ['cubic', 'bbr'],
      });

      expect(capabilities.supportsSsPlugin('kcptun'), isTrue);
      expect(capabilities.supportsSsPlugin('v2ray-plugin'), isFalse);
      expect(capabilities.supportsTunCongestionController('bbr'), isTrue);
      expect(capabilities.supportsTunCongestionController('reno'), isFalse);
    });

    test('fall back to the known tables when the Core omits them', () async {
      final capabilities = await load({
        for (final entry in _concord.entries)
          if (entry.key != 'ss-plugins' &&
              entry.key != 'congestion-controllers')
            entry.key: entry.value,
      });

      expect(capabilities.restricted, isTrue);
      expect(capabilities.supportsSsPlugin('obfs'), isTrue);
      expect(capabilities.supportsSsPlugin('shadow-tls'), isTrue);
      expect(capabilities.supportsSsPlugin('kcptun'), isFalse);
      expect(capabilities.supportsTunCongestionController('cubic'), isTrue);
      expect(capabilities.supportsTunCongestionController('bbr'), isFalse);
    });

    test('an empty report means none, not the fallback', () async {
      final capabilities = await load({
        ..._concord,
        'ss-plugins': <String>[],
        'congestion-controllers': <String>[],
      });

      expect(capabilities.supportsSsPlugin('obfs'), isFalse);
      expect(capabilities.supportsTunCongestionController('cubic'), isFalse);
    });
  });

  test('warnings decode, and only the warning level counts', () async {
    final core = _Core(
      (method) => switch (method) {
        CoreMethod.configWarnings => [
          {'level': 'warning', 'path': 'proxies[12]', 'message': 'removed'},
          {'level': 'info', 'path': 'experimental', 'message': 'ignored'},
        ],
        _ => _notImplemented(method),
      },
    );

    final warnings = await core.getConfigWarnings();

    expect(warnings, hasLength(2));
    expect(warnings.warnings.map((item) => item.path), ['proxies[12]']);
  });
}
