import 'package:fl_clash/core/desktop/model.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:test/test.dart';

class _SilentCore extends CoreHandlerInterface {
  final invoked = <CoreMethod>[];

  @override
  Future<T?> invokeMethod<T>({
    required CoreMethod method,
    Object? arguments,
    Duration? timeout,
  }) async {
    invoked.add(method);
    return null;
  }

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

const _setupParams = SetupParams(selectedMap: {}, testUrl: 'http://x.com');

const _updateParams = UpdateParams(
  tun: Tun(),
  mixedPort: 7890,
  allowLan: true,
  findProcessMode: FindProcessMode.off,
  mode: Mode.rule,
  logLevel: LogLevel.info,
  ipv6: false,
  tcpConcurrent: false,
  externalController: ExternalControllerStatus.close,
  unifiedDelay: false,
);

void main() {
  late _SilentCore core;

  setUp(() => core = _SilentCore());

  final cases = <String, Future<String> Function()>{
    'setupConfig': () => core.setupConfig(_setupParams),
    'updateConfig': () => core.updateConfig(_updateParams),
    'validateConfig': () => core.validateConfig('/tmp/config.yaml'),
    'changeProxy': () => core.changeProxy(
      const ChangeProxyParams(groupName: 'G', proxyName: 'P'),
    ),
    'updateGeoData': () => core.updateGeoData('geoip'),
    'updateExternalProvider': () => core.updateExternalProvider('provider'),
    'sideLoadExternalProvider': () =>
        core.sideLoadExternalProvider(providerName: 'p', data: 'd'),
    'clearEffect': () => core.clearEffect(1),
  };

  group('an unanswered call is not reported as an applied change', () {
    cases.forEach((name, invoke) {
      test('$name surfaces the silence instead of an empty message', () {
        expect(
          invoke(),
          throwsA(
            isA<CoreMethodException>().having(
              (error) => error.code,
              'code',
              'no_response',
            ),
          ),
        );
      });
    });
  });

  test('an answered call still returns the core message verbatim', () async {
    final core = _AnsweringCore('nameserver is empty');
    expect(await core.setupConfig(_setupParams), 'nameserver is empty');
    expect(
      await core.validateConfig('/tmp/config.yaml'),
      'nameserver is empty',
    );
  });

  test('an empty answer still reads as success', () async {
    final core = _AnsweringCore('');
    expect(await core.setupConfig(_setupParams), isEmpty);
  });

  test('calls that legitimately degrade are left alone', () async {
    expect(await core.isInit, isFalse);
    expect(await core.forceGc(), isFalse);
    expect(await core.getMemory(), 0);
    expect(await core.getExternalProviders(), isEmpty);
    expect(await core.getExternalProvider('p'), isNull);
  });
}

class _AnsweringCore extends _SilentCore {
  _AnsweringCore(this.message);

  final String message;

  @override
  Future<T?> invokeMethod<T>({
    required CoreMethod method,
    Object? arguments,
    Duration? timeout,
  }) async {
    return message as T;
  }
}
