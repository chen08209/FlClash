import 'dart:io';

import 'package:fl_clash/common/tray.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Tray.getTryIcon', () {
    final tray = Tray();
    final suffix = tray.trayIconSuffix;

    test('returns idle icon when core is not started', () {
      expect(
        tray.getTryIcon(isStart: false, tunEnable: false),
        'assets/images/icon/status_1.$suffix',
      );
    });

    test('returns normal mode icon when core is started without TUN', () {
      expect(
        tray.getTryIcon(isStart: true, tunEnable: false),
        Platform.isMacOS
            ? 'assets/images/icon/status_1.$suffix'
            : 'assets/images/icon/status_2.$suffix',
      );
    });

    test('returns enhanced mode icon when core is started with TUN', () {
      expect(
        tray.getTryIcon(isStart: true, tunEnable: true),
        Platform.isMacOS
            ? 'assets/images/icon/status_1.$suffix'
            : 'assets/images/icon/status_3.$suffix',
      );
    });
  });

  group('Tray.updateTrayTitle deduplication', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    late Tray tray;
    late List<MethodCall> calls;

    setUp(() {
      tray = Tray();
      calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('tray_manager'), (
            call,
          ) async {
            calls.add(call);
            return null;
          });
    });

    tearDown(() async {
      await tray.destroy();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('tray_manager'), null);
    });

    test(
      'skips repeated setTitle when the title is unchanged',
      () async {
        await tray.updateTrayTitle(
          showTrayTitle: false,
          traffic: const Traffic(),
        );
        await tray.updateTrayTitle(
          showTrayTitle: false,
          traffic: const Traffic(),
        );
        await tray.updateTrayTitle(
          showTrayTitle: false,
          traffic: const Traffic(),
        );

        final setTitleCalls = calls
            .where((call) => call.method == 'setTitle')
            .toList();
        expect(setTitleCalls, hasLength(1));
        expect(setTitleCalls.single.arguments, {'title': ''});
      },
      skip: !Platform.isMacOS
          ? 'updateTrayTitle is macOS-only'
          : false,
    );

    test(
      'calls setTitle again after destroy resets the title cache',
      () async {
        await tray.updateTrayTitle(
          showTrayTitle: false,
          traffic: const Traffic(),
        );
        expect(
          calls.where((call) => call.method == 'setTitle'),
          hasLength(1),
        );

        await tray.destroy();
        calls.clear();

        await tray.updateTrayTitle(
          showTrayTitle: false,
          traffic: const Traffic(),
        );
        expect(
          calls.where((call) => call.method == 'setTitle'),
          hasLength(1),
        );
      },
      skip: !Platform.isMacOS
          ? 'updateTrayTitle is macOS-only'
          : false,
    );

    test(
      'does not cache the title when setTitle fails',
      () async {
        var shouldFail = true;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(const MethodChannel('tray_manager'), (
              call,
            ) async {
              calls.add(call);
              if (call.method == 'setTitle' && shouldFail) {
                throw PlatformException(code: 'setTitle_failed');
              }
              return null;
            });

        await expectLater(
          tray.updateTrayTitle(
            showTrayTitle: false,
            traffic: const Traffic(),
          ),
          throwsA(isA<PlatformException>()),
        );

        shouldFail = false;
        await tray.updateTrayTitle(
          showTrayTitle: false,
          traffic: const Traffic(),
        );

        expect(
          calls.where((call) => call.method == 'setTitle'),
          hasLength(2),
        );
      },
      skip: !Platform.isMacOS
          ? 'updateTrayTitle is macOS-only'
          : false,
    );
  });
}
