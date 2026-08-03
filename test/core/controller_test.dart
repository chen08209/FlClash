import 'dart:async';

import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/desktop/model.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

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
    test('start, restart, stop, and close delegate to interface', () async {
      const result = CoreLifecycleResult(
        revision: 1,
        outcome: CoreLifecycleOutcome.applied,
      );
      when(() => mock.start()).thenAnswer((_) async => result);
      when(() => mock.restart()).thenAnswer((_) async => result);
      when(() => mock.stop()).thenAnswer((_) async => result);
      when(() => mock.close()).thenAnswer((_) async => result);

      expect(await controller.start(), same(result));
      expect(await controller.restart(), same(result));
      expect(await controller.stop(), same(result));
      expect(await controller.close(), same(result));

      verify(() => mock.start()).called(1);
      verify(() => mock.restart()).called(1);
      verify(() => mock.stop()).called(1);
      verify(() => mock.close()).called(1);
    });

    test('isInit delegates to interface', () async {
      when(() => mock.isInit).thenAnswer((_) async => true);
      final result = await controller.isInit;
      expect(result, true);
    });

    test('crash delegates to interface', () async {
      when(() => mock.crash()).thenAnswer((_) async => true);

      await controller.crash();

      verify(() => mock.crash()).called(1);
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

    test('setupConfig waits for asynchronous preload', () async {
      const params = SetupParams(selectedMap: {}, testUrl: 'http://x.com');
      final preloadCompleter = Completer<void>();
      final events = <String>[];
      when(() => mock.setupConfig(params)).thenAnswer((_) {
        events.add('setup');
        return Future.value('ok');
      });

      final setupFuture = controller.setupConfig(
        params: params,
        preloadInvoke: () async {
          events.add('preload');
          await preloadCompleter.future;
        },
      );
      var completed = false;
      setupFuture.then((_) => completed = true);
      await Future<void>.delayed(Duration.zero);

      expect(events, ['setup', 'preload']);
      expect(completed, isFalse);

      preloadCompleter.complete();
      expect(await setupFuture, 'ok');
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
    test('getConnections delegates structured connections', () async {
      final connection = TrackerInfo.fromJson({
        'id': '1',
        'metadata': {'network': 'tcp'},
        'upload': 0,
        'download': 0,
        'start': '2024-01-01',
        'chains': ['Proxy'],
        'rule': 'DIRECT',
        'rulePayload': '',
      });
      when(() => mock.getConnections()).thenAnswer((_) async => [connection]);
      final result = await controller.getConnections();
      expect(result.length, 1);
      expect(result.first.id, '1');
    });

    test('getConnections handles empty connections', () async {
      when(() => mock.getConnections()).thenAnswer((_) async => []);
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
    test('getExternalProviders delegates structured providers', () async {
      final provider = ExternalProvider(
        name: 'provider1',
        type: 'Proxy',
        count: 5,
        vehicleType: 'HTTP',
        updateAt: DateTime.now(),
      );
      when(
        () => mock.getExternalProviders(),
      ).thenAnswer((_) async => [provider]);
      final result = await controller.getExternalProviders();
      expect(result.length, 1);
      expect(result.first.name, 'provider1');
    });

    test('getExternalProviders handles empty list', () async {
      when(() => mock.getExternalProviders()).thenAnswer((_) async => []);
      final result = await controller.getExternalProviders();
      expect(result, isEmpty);
    });

    test('getExternalProvider returns null when missing', () async {
      when(() => mock.getExternalProvider(any())).thenAnswer((_) async => null);
      final result = await controller.getExternalProvider('test');
      expect(result, isNull);
    });
  });

  group('traffic methods', () {
    test('getTraffic delegates structured traffic', () async {
      when(
        () => mock.getTraffic(false),
      ).thenAnswer((_) async => const Traffic(up: 1, down: 2));
      final result = await controller.getTraffic(false);
      expect(result.up, 1);
      expect(result.down, 2);
    });

    test('getTotalTraffic delegates structured traffic', () async {
      when(
        () => mock.getTotalTraffic(false),
      ).thenAnswer((_) async => const Traffic(up: 3, down: 4));
      final result = await controller.getTotalTraffic(false);
      expect(result.up, 3);
      expect(result.down, 4);
    });

    test('getTrafficSnapshot parses combined payload', () async {
      when(() => mock.getTrafficSnapshot(false)).thenAnswer(
        (_) async => <String, dynamic>{
          'up': 1,
          'down': 2,
          'totalUp': 10,
          'totalDown': 20,
        },
      );
      final result = await controller.getTrafficSnapshot(false);
      expect(result.now.up, 1);
      expect(result.now.down, 2);
      expect(result.total.up, 10);
      expect(result.total.down, 20);
    });

    test('getMemory delegates numeric memory', () async {
      when(() => mock.getMemory()).thenAnswer((_) async => 2048);
      final result = await controller.getMemory();
      expect(result, 2048);
    });
  });

  group('misc methods', () {
    test('getCountryCode returns null on empty string', () async {
      when(() => mock.getCountryCode(any())).thenAnswer((_) async => '');
      final result = await controller.getCountryCode('8.8.8.8');
      expect(result, isNull);
    });

    test('getDelay delegates structured delay', () async {
      when(() => mock.asyncTestDelay(any(), any())).thenAnswer(
        (_) async => const Delay(name: 'P1', value: 100, url: 'test.com'),
      );
      final result = await controller.getDelay('test.com', 'P1');
      expect(result.name, 'P1');
      expect(result.value, 100);
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
      when(() => mock.updateGeoData('MMDB')).thenAnswer((_) async => 'ok');
      final result = await controller.updateGeoData('MMDB');
      expect(result, 'ok');
    });

    test('requestGc delegates to forceGc', () async {
      when(() => mock.forceGc()).thenAnswer((_) async => true);
      await controller.requestGc();
      verify(() => mock.forceGc()).called(1);
    });

    test('clearEffect delegates', () async {
      when(() => mock.clearEffect(42)).thenAnswer((_) async => 'ok');
      final result = await controller.clearEffect(42);
      expect(result, 'ok');
    });
  });
}
