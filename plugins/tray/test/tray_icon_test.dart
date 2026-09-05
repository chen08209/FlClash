import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tray/tray.dart';

const MethodChannel _channel = MethodChannel('tray');
const _asset = 'assets/images/tray/unix/status_1.png';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<MethodCall> calls;

  Map<String, Object?> lastIcon() {
    final arguments = calls.last.arguments as Map<Object?, Object?>;
    return (arguments['icon'] as Map<Object?, Object?>).cast<String, Object?>();
  }

  setUp(() {
    calls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
          calls.add(call);
          return true;
        });
    Tray.instance.resetForTesting();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
    Tray.fileExists = (filePath) => false;
    Tray.instance.resetForTesting();
    debugDefaultTargetPlatformOverride = null;
  });

  test('variant assets follow the Flutter resolution layout', () {
    expect(Tray.variantAsset(_asset, 1.0), _asset);
    expect(
      Tray.variantAsset(_asset, 2.0),
      'assets/images/tray/unix/2.0x/status_1.png',
    );
    expect(Tray.variantAsset('status_1.png', 3.0), '3.0x/status_1.png');
  });

  test('linux hands the indicator the largest bundled variant', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    Tray.fileExists = (filePath) => filePath.contains('/3.0x/');

    await Tray.instance.show(const TraySpec(icon: TrayIcon.asset(_asset)));

    expect(
      lastIcon()['path'],
      endsWith('flutter_assets/assets/images/tray/unix/3.0x/status_1.png'),
    );
  });

  test(
    'linux falls back to the base asset when no variant is bundled',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;

      await Tray.instance.show(const TraySpec(icon: TrayIcon.asset(_asset)));

      expect(
        lastIcon()['path'],
        endsWith('flutter_assets/assets/images/tray/unix/status_1.png'),
      );
    },
  );

  test('macOS sends every bundled scale as a representation', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    final bundled = {
      _asset: [1],
      'assets/images/tray/unix/2.0x/status_1.png': [2, 2],
    };
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
          final key = utf8.decode(message!.buffer.asUint8List());
          final bytes = bundled[key];
          if (bytes == null) {
            return null;
          }
          return ByteData.sublistView(Uint8List.fromList(bytes));
        });

    await Tray.instance.show(
      const TraySpec(icon: TrayIcon.asset(_asset, isTemplate: true)),
    );

    final reps = (lastIcon()['reps'] as List<Object?>)
        .cast<Map<Object?, Object?>>();
    expect(reps.map((rep) => rep['scale']), [1.0, 2.0]);
    expect(base64Decode(reps.last['bytes'] as String), [2, 2]);
    expect(lastIcon()['isTemplate'], isTrue);
    expect(lastIcon().containsKey('path'), isFalse);
  });
}
