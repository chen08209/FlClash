import 'dart:async';
import 'dart:convert';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

class FakeCompleter extends Fake implements Completer<dynamic> {
  @override
  bool get isCompleted => true;
}

class CaptureCoreHandlerInterface extends CoreHandlerInterface {
  final _completer = Completer<void>()..complete();
  ActionMethod? capturedMethod;
  dynamic capturedData;
  Duration? capturedTimeout;

  @override
  Completer get completer => _completer;

  @override
  FutureOr<bool> destroy() => true;

  @override
  Future<String> preload() async => '';

  @override
  Future<bool> shutdown(bool isUser) async => true;

  @override
  Future<T?> invoke<T>({
    required ActionMethod method,
    dynamic data,
    Duration? timeout,
  }) async {
    capturedMethod = method;
    capturedData = data;
    capturedTimeout = timeout;
    return json.encode({
          'name': 'P1',
          'url': 'https://probe.example.com',
          'value': 123,
        })
        as T;
  }
}

void main() {
  late MockCoreHandlerInterface mock;
  late CoreController controller;

  setUpAll(() {
    registerFallbackValue(
      const SetupParams(selectedMap: {}, testUrl: 'http://x.com'),
    );
    registerFallbackValue(const InitParams(homeDir: '.', version: 1));
    registerFallbackValue(
      const UpdateParams(
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
      ),
    );
    registerFallbackValue(
      const ChangeProxyParams(groupName: 'G', proxyName: 'P'),
    );
    registerFallbackValue(
      const SetupState(
        profileId: null,
        profileLastUpdateDate: null,
        overwriteType: OverwriteType.standard,
        rules: [],
        proxyGroups: [],
        addedRules: [],
        script: null,
        overrideDns: false,
        dns: Dns(),
      ),
    );
    registerFallbackValue(
      const UpdateGeoDataParams(geoType: 't', geoName: 'n'),
    );
  });

  setUp(() {
    mock = MockCoreHandlerInterface();
    CoreController.resetInstance();
    controller = CoreController.test(mock);
  });

  tearDown(() {
    CoreController.resetInstance();
  });

  group('CoreController singleton', () {
    test('test constructor injects mock interface', () {
      expect(controller, isA<CoreController>());
    });

    test('resetInstance allows fresh construction', () {
      CoreController.resetInstance();
      final instance = CoreController.test(mock);
      expect(instance, isA<CoreController>());
    });
  });

  group('lifecycle methods', () {
    test('preload delegates to interface', () async {
      when(() => mock.preload()).thenAnswer((_) async => 'ready');
      final result = await controller.preload();
      expect(result, 'ready');
      verify(() => mock.preload()).called(1);
    });

    test('shutdown delegates to interface', () async {
      when(() => mock.shutdown(true)).thenAnswer((_) async => true);
      await controller.shutdown(true);
      verify(() => mock.shutdown(true)).called(1);
    });

    test('isInit delegates to interface', () async {
      when(() => mock.isInit).thenAnswer((_) async => true);
      final result = await controller.isInit;
      expect(result, true);
    });
  });

  group('config methods', () {
    test('validateConfig delegates to interface', () async {
      when(() => mock.validateConfig('/path')).thenAnswer((_) async => 'ok');
      final result = await controller.validateConfig('/path');
      expect(result, 'ok');
      verify(() => mock.validateConfig('/path')).called(1);
    });

    test('updateConfig delegates to interface', () async {
      const params = UpdateParams(
        tun: Tun(enable: false),
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
      when(() => mock.updateConfig(params)).thenAnswer((_) async => 'ok');
      final result = await controller.updateConfig(params);
      expect(result, 'ok');
    });

    test('setupConfig waits for core before preload callback', () async {
      const params = SetupParams(selectedMap: {}, testUrl: 'http://x.com');
      const setupState = SetupState(
        profileId: null,
        profileLastUpdateDate: null,
        overwriteType: OverwriteType.standard,
        rules: [],
        proxyGroups: [],
        addedRules: [],
        script: null,
        overrideDns: false,
        dns: Dns(),
      );
      final setupCompleter = Completer<String>();
      var preloadCalled = false;
      when(
        () => mock.setupConfig(params),
      ).thenAnswer((_) => setupCompleter.future);

      final resultFuture = controller.setupConfig(
        params: params,
        setupState: setupState,
        preloadInvoke: () {
          preloadCalled = true;
        },
      );
      await Future<void>.delayed(Duration.zero);

      expect(preloadCalled, false);

      setupCompleter.complete('ok');
      final result = await resultFuture;

      expect(result, 'ok');
      expect(preloadCalled, true);
    });
  });

  group('proxy methods', () {
    test('changeProxy delegates to interface', () async {
      const params = ChangeProxyParams(groupName: 'G1', proxyName: 'P1');
      when(() => mock.changeProxy(params)).thenAnswer((_) async => 'ok');
      final result = await controller.changeProxy(params);
      expect(result, 'ok');
    });
  });

  group('connection methods', () {
    test('getConnections parses JSON response', () async {
      when(() => mock.getConnections()).thenAnswer(
        (_) async => json.encode({
          'connections': [
            {
              'id': '1',
              'metadata': {'network': 'tcp'},
              'upload': 0,
              'download': 0,
              'start': '2024-01-01',
              'chains': ['Proxy'],
              'rule': 'DIRECT',
              'rulePayload': '',
            },
          ],
        }),
      );
      final result = await controller.getConnections();
      expect(result.length, 1);
      expect(result.first.id, '1');
    });

    test('getConnections handles empty connections', () async {
      when(
        () => mock.getConnections(),
      ).thenAnswer((_) async => json.encode({'connections': []}));
      final result = await controller.getConnections();
      expect(result, isEmpty);
    });

    test('closeConnection delegates', () async {
      when(() => mock.closeConnection('id1')).thenAnswer((_) async => true);
      await controller.closeConnection('id1');
      verify(() => mock.closeConnection('id1')).called(1);
    });
  });

  group('external providers', () {
    test('getExternalProviders parses JSON', () async {
      when(() => mock.getExternalProviders()).thenAnswer(
        (_) async => json.encode([
          {
            'name': 'provider1',
            'type': 'Proxy',
            'count': 5,
            'vehicle-type': 'HTTP',
            'update-at': DateTime.now().toIso8601String(),
          },
        ]),
      );
      final result = await controller.getExternalProviders();
      expect(result.length, 1);
      expect(result.first.name, 'provider1');
    });

    test('getExternalProviders handles empty string', () async {
      when(() => mock.getExternalProviders()).thenAnswer((_) async => '');
      final result = await controller.getExternalProviders();
      expect(result, isEmpty);
    });

    test('getExternalProvider returns null on empty', () async {
      when(() => mock.getExternalProvider(any())).thenAnswer((_) async => '');
      final result = await controller.getExternalProvider('test');
      expect(result, isNull);
    });
  });

  group('traffic methods', () {
    test('getTraffic handles empty string', () async {
      when(() => mock.getTraffic(false)).thenAnswer((_) async => '');
      final result = await controller.getTraffic(false);
      expect(result.up, 0);
      expect(result.down, 0);
    });

    test('getTotalTraffic handles empty string', () async {
      when(() => mock.getTotalTraffic(false)).thenAnswer((_) async => '');
      final result = await controller.getTotalTraffic(false);
      expect(result.up, 0);
      expect(result.down, 0);
    });

    test('getMemory handles empty string', () async {
      when(() => mock.getMemory()).thenAnswer((_) async => '');
      final result = await controller.getMemory();
      expect(result, 0);
    });
  });

  group('misc methods', () {
    test('getCountryCode returns null on empty string', () async {
      when(() => mock.getCountryCode(any())).thenAnswer((_) async => '');
      final result = await controller.getCountryCode('8.8.8.8');
      expect(result, isNull);
    });

    test('getDelay parses JSON response', () async {
      when(() => mock.asyncTestDelay(any(), any())).thenAnswer(
        (_) async =>
            json.encode({'name': 'P1', 'value': 100, 'url': 'test.com'}),
      );
      final result = await controller.getDelay('test.com', 'P1');
      expect(result.name, 'P1');
      expect(result.value, 100);
    });

    test('asyncTestDelay keeps the original core timeout contract', () async {
      final handler = CaptureCoreHandlerInterface();

      final result = await handler.asyncTestDelay(
        'https://probe.example.com',
        'P1',
      );
      final payload = json.decode(handler.capturedData as String) as Map;

      expect(handler.capturedMethod, ActionMethod.asyncTestDelay);
      expect(payload['timeout'], httpTimeoutDuration.inMilliseconds);
      expect(handler.capturedTimeout, const Duration(seconds: 6));
      expect(result, contains('"value":123'));
    });

    test('startListener delegates', () async {
      when(() => mock.startListener()).thenAnswer((_) async => true);
      final result = await controller.startListener();
      expect(result, true);
    });

    test('stopListener delegates', () async {
      when(() => mock.stopListener()).thenAnswer((_) async => false);
      final result = await controller.stopListener();
      expect(result, false);
    });

    test('updateGeoData delegates', () async {
      const params = UpdateGeoDataParams(geoType: 'mmdb', geoName: 'Country');
      when(() => mock.updateGeoData(params)).thenAnswer((_) async => 'ok');
      final result = await controller.updateGeoData(params);
      expect(result, 'ok');
    });

    test('requestGc delegates to forceGc', () async {
      when(() => mock.forceGc()).thenAnswer((_) async => true);
      await controller.requestGc();
      verify(() => mock.forceGc()).called(1);
    });

    test('deleteFile delegates', () async {
      when(() => mock.deleteFile('/tmp/x')).thenAnswer((_) async => 'ok');
      final result = await controller.deleteFile('/tmp/x');
      expect(result, 'ok');
    });
  });
}
