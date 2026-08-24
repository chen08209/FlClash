import 'dart:async';

import 'package:fl_clash/pages/scan.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../helpers/test_app.dart';

/// A platform that never touches a camera: barcodes are pushed by the test.
class _FakeScannerPlatform extends MobileScannerPlatform {
  final StreamController<BarcodeCapture?> _barcodes =
      StreamController<BarcodeCapture?>.broadcast();
  final StreamController<TorchState> _torch =
      StreamController<TorchState>.broadcast();
  final StreamController<double> _zoom = StreamController<double>.broadcast();

  int startCalls = 0;
  int stopCalls = 0;
  int disposeCalls = 0;

  void emit(BarcodeCapture capture) => _barcodes.add(capture);

  @override
  Stream<BarcodeCapture?> get barcodesStream => _barcodes.stream;

  @override
  Stream<TorchState> get torchStateStream => _torch.stream;

  @override
  Stream<double> get zoomScaleStateStream => _zoom.stream;

  @override
  Widget buildCameraView() => const SizedBox.shrink();

  @override
  Future<MobileScannerViewAttributes> start(StartOptions startOptions) async {
    startCalls++;
    return const MobileScannerViewAttributes(
      cameraDirection: CameraFacing.back,
      currentTorchMode: TorchState.off,
      size: Size(100, 100),
    );
  }

  @override
  Future<void> stop() async {
    stopCalls++;
  }

  @override
  Future<void> updateScanWindow(Rect? window) async {}

  // Deliberately keeps the streams open: a real camera plugin can still deliver
  // a frame that was already in flight when teardown began, and the test needs
  // to be able to model that.
  @override
  Future<void> dispose() async {
    disposeCalls++;
  }

  Future<void> close() async {
    await _barcodes.close();
    await _torch.close();
    await _zoom.close();
  }
}

BarcodeCapture _capture({required BarcodeType type, String? rawValue}) {
  return BarcodeCapture(
    barcodes: [Barcode(type: type, rawValue: rawValue)],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeScannerPlatform platform;

  setUp(() {
    platform = _FakeScannerPlatform();
    MobileScannerPlatform.instance = platform;
    addTearDown(platform.close);
  });

  /// Pushes the page onto a route so `Navigator.pop` from `_handleBarcode` has
  /// something to pop, and reports what the page popped with.
  Future<void> pumpScanPage(
    WidgetTester tester, {
    required void Function(String? result) onPopped,
  }) async {
    late BuildContext hostContext;
    await tester.pumpWidget(
      ProviderScope(
        child: TestApp(
          child: Builder(
            builder: (context) {
              hostContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    unawaited(
      Navigator.of(hostContext)
          .push<String>(
            MaterialPageRoute<String>(builder: (_) => const ScanPage()),
          )
          .then(onPopped),
    );
    await tester.pumpAndSettle();
  }

  group('ScanPage lifecycle', () {
    testWidgets('disposing the page does not break the dispose contract', (
      tester,
    ) async {
      await pumpScanPage(tester, onPopped: (_) {});

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      // `StatefulElement.unmount` asserts `super.dispose()` already ran. An
      // `await` before it defers the call past the assert and this fails with
      // "_ScanPageState.dispose failed to call super.dispose."
      expect(tester.takeException(), isNull);
    });

    testWidgets('the controller is torn down when the page is disposed', (
      tester,
    ) async {
      await pumpScanPage(tester, onPopped: (_) {});
      expect(platform.disposeCalls, 0);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      expect(platform.disposeCalls, 1);
    });

    testWidgets('a barcode delivered after teardown never pops a dead route', (
      tester,
    ) async {
      var popped = false;
      await pumpScanPage(tester, onPopped: (_) => popped = true);

      await tester.pumpWidget(const SizedBox.shrink());
      platform.emit(
        _capture(type: BarcodeType.url, rawValue: 'https://a.example'),
      );
      await tester.pumpAndSettle();

      // Two things stop this: the subscription is cancelled in dispose, and
      // `_handleBarcode` re-checks `mounted` for anything already dispatched.
      expect(popped, isFalse);
      expect(tester.takeException(), isNull);
    });
  });

  group('ScanPage barcode handling', () {
    testWidgets('a url barcode pops its raw value', (tester) async {
      String? result;
      var popped = false;
      await pumpScanPage(
        tester,
        onPopped: (value) {
          result = value;
          popped = true;
        },
      );

      platform.emit(
        _capture(type: BarcodeType.url, rawValue: 'https://sub.example/x'),
      );
      await tester.pumpAndSettle();

      expect(popped, isTrue);
      expect(result, 'https://sub.example/x');
    });

    testWidgets('a non-url barcode pops without a value', (tester) async {
      String? result = 'unset';
      var popped = false;
      await pumpScanPage(
        tester,
        onPopped: (value) {
          result = value;
          popped = true;
        },
      );

      platform.emit(_capture(type: BarcodeType.text, rawValue: 'plain text'));
      await tester.pumpAndSettle();

      expect(popped, isTrue);
      expect(result, isNull);
    });
  });

  group('ScanPage app lifecycle', () {
    Future<void> sendLifecycle(WidgetTester tester, AppLifecycleState state) {
      final messenger = tester.binding.defaultBinaryMessenger;
      return messenger.handlePlatformMessage(
        'flutter/lifecycle',
        const StringCodec().encodeMessage(state.toString()),
        (_) {},
      );
    }

    testWidgets('going inactive stops the camera', (tester) async {
      await pumpScanPage(tester, onPopped: (_) {});
      expect(platform.startCalls, 1);

      await sendLifecycle(tester, AppLifecycleState.inactive);
      await tester.pumpAndSettle();

      expect(platform.stopCalls, 1);
    });

    testWidgets('resuming restarts the camera and pops a barcode once', (
      tester,
    ) async {
      var popCount = 0;
      await pumpScanPage(tester, onPopped: (_) => popCount++);

      await sendLifecycle(tester, AppLifecycleState.inactive);
      await tester.pumpAndSettle();
      await sendLifecycle(tester, AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(platform.startCalls, 2);

      platform.emit(
        _capture(type: BarcodeType.url, rawValue: 'https://b.example'),
      );
      await tester.pumpAndSettle();

      expect(popCount, 1);
    });

    testWidgets('repeated resumes do not stack barcode subscriptions', (
      tester,
    ) async {
      var popCount = 0;
      await pumpScanPage(tester, onPopped: (_) => popCount++);

      // Without cancelling first, each resume adds another listener and the
      // single capture below would be handled once per subscription.
      await sendLifecycle(tester, AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      await sendLifecycle(tester, AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      platform.emit(
        _capture(type: BarcodeType.url, rawValue: 'https://c.example'),
      );
      await tester.pumpAndSettle();

      expect(popCount, 1);
    });
  });
}
