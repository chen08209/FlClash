import 'dart:async';

import 'package:fl_clash/common/app_localizations.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/pages/scan.dart';
import 'package:fl_clash/widgets/activate_box.dart';
import 'package:fl_clash/widgets/null_status.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

class _FakeScannerPlatform extends MobileScannerPlatform {
  final StreamController<BarcodeCapture?> _barcodes =
      StreamController<BarcodeCapture?>.broadcast();
  final StreamController<TorchState> _torch =
      StreamController<TorchState>.broadcast();
  final StreamController<double> _zoom = StreamController<double>.broadcast();

  int startCalls = 0;
  int stopCalls = 0;
  int disposeCalls = 0;
  int toggleTorchCalls = 0;
  TorchState initialTorchState = TorchState.off;
  MobileScannerException? startError;
  Completer<void>? startGate;

  void emit(BarcodeCapture capture) => _barcodes.add(capture);

  void emitError(Object error) => _barcodes.addError(error);

  void emitTorch(TorchState state) => _torch.add(state);

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
    await startGate?.future;
    final error = startError;
    if (error != null) {
      throw error;
    }
    return MobileScannerViewAttributes(
      cameraDirection: CameraFacing.back,
      currentTorchMode: initialTorchState,
      size: const Size(100, 100),
    );
  }

  @override
  Future<void> toggleTorch() async {
    toggleTorchCalls++;
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

BarcodeCapture _textCapture(List<String> rawValues) {
  return BarcodeCapture(
    barcodes: [
      for (final rawValue in rawValues)
        Barcode(type: BarcodeType.text, rawValue: rawValue),
    ],
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

  /// The scan effect repeats for as long as the page is mounted, so
  /// `pumpAndSettle` only returns once the page has been popped or unmounted.
  Future<void> pumpFrames(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

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
    await pumpFrames(tester);
  }

  Future<void> sendLifecycle(WidgetTester tester, AppLifecycleState state) {
    final messenger = tester.binding.defaultBinaryMessenger;
    return messenger.handlePlatformMessage(
      'flutter/lifecycle',
      const StringCodec().encodeMessage(state.toString()),
      (_) {},
    );
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

    testWidgets('an install-config link pops the url it carries', (
      tester,
    ) async {
      String? result;
      await pumpScanPage(tester, onPopped: (value) => result = value);

      platform.emit(
        _textCapture([
          'clash://install-config?url=https%3A%2F%2Fsub.example%2Fy',
        ]),
      );
      await tester.pumpAndSettle();

      expect(result, 'https://sub.example/y');
    });

    testWidgets('the first profile link in a capture wins', (tester) async {
      String? result;
      await pumpScanPage(tester, onPopped: (value) => result = value);

      platform.emit(
        _textCapture(['WIFI:S:home;;', ' https://sub.example/z\n']),
      );
      await tester.pumpAndSettle();

      expect(result, 'https://sub.example/z');
    });

    testWidgets('a code without a profile link keeps scanning with a hint', (
      tester,
    ) async {
      var popped = false;
      await pumpScanPage(tester, onPopped: (_) => popped = true);

      platform.emit(_textCapture(['plain text']));
      await pumpFrames(tester);

      expect(popped, isFalse);
      expect(
        find.text(currentAppLocalizations.invalidProfileQrcode),
        findsOneWidget,
      );

      await tester.pump(const Duration(seconds: 2));

      expect(find.text(currentAppLocalizations.qrcodeDesc), findsOneWidget);

      platform.emit(
        _capture(type: BarcodeType.url, rawValue: 'https://sub.example/x'),
      );
      await tester.pumpAndSettle();

      expect(popped, isTrue);
    });

    testWidgets('captures racing the exit transition pop only once', (
      tester,
    ) async {
      var popCount = 0;
      await pumpScanPage(tester, onPopped: (_) => popCount++);

      platform.emit(_textCapture(['https://a.example']));
      platform.emit(_textCapture(['https://b.example']));
      await tester.pump();
      platform.emit(_textCapture(['https://c.example']));
      await tester.pumpAndSettle();

      expect(popCount, 1);
      expect(find.byType(ScanPage), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a detection error is not surfaced as an uncaught error', (
      tester,
    ) async {
      await pumpScanPage(tester, onPopped: (_) {});

      platform.emitError(const MobileScannerBarcodeException('boom'));
      await pumpFrames(tester);

      expect(find.byType(ScanPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('ScanPage app lifecycle', () {
    testWidgets('a resume during a pending start does not start again', (
      tester,
    ) async {
      final gate = Completer<void>();
      platform.startGate = gate;
      await pumpScanPage(tester, onPopped: (_) {});
      expect(platform.startCalls, 1);

      await sendLifecycle(tester, AppLifecycleState.inactive);
      await sendLifecycle(tester, AppLifecycleState.resumed);
      await pumpFrames(tester);
      gate.complete();
      await pumpFrames(tester);

      expect(platform.startCalls, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('going inactive stops the camera', (tester) async {
      await pumpScanPage(tester, onPopped: (_) {});
      expect(platform.startCalls, 1);

      await sendLifecycle(tester, AppLifecycleState.inactive);
      await pumpFrames(tester);

      expect(platform.stopCalls, 1);
    });

    testWidgets('resuming restarts the camera and pops a barcode once', (
      tester,
    ) async {
      var popCount = 0;
      await pumpScanPage(tester, onPopped: (_) => popCount++);

      await sendLifecycle(tester, AppLifecycleState.inactive);
      await pumpFrames(tester);
      await sendLifecycle(tester, AppLifecycleState.resumed);
      await pumpFrames(tester);

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
      await pumpFrames(tester);
      await sendLifecycle(tester, AppLifecycleState.resumed);
      await pumpFrames(tester);

      platform.emit(
        _capture(type: BarcodeType.url, rawValue: 'https://c.example'),
      );
      await tester.pumpAndSettle();

      expect(popCount, 1);
    });
  });

  group('ScanPage camera errors', () {
    testWidgets('a denied permission offers settings and stops the effect', (
      tester,
    ) async {
      platform.startError = const MobileScannerException(
        errorCode: MobileScannerErrorCode.permissionDenied,
      );
      await pumpScanPage(tester, onPopped: (_) {});
      await tester.pumpAndSettle();

      expect(
        find.text(currentAppLocalizations.cameraPermissionRequired),
        findsOneWidget,
      );
      expect(find.text(currentAppLocalizations.settings), findsOneWidget);
      expect(find.text(currentAppLocalizations.qrcodeDesc), findsNothing);
      expect(find.byTooltip(currentAppLocalizations.pickFromAlbum), findsOne);
    });

    testWidgets('a denied permission is not retried on a plain resume', (
      tester,
    ) async {
      platform.startError = const MobileScannerException(
        errorCode: MobileScannerErrorCode.permissionDenied,
      );
      await pumpScanPage(tester, onPopped: (_) {});

      await sendLifecycle(tester, AppLifecycleState.inactive);
      await sendLifecycle(tester, AppLifecycleState.resumed);
      await pumpFrames(tester);

      expect(platform.startCalls, 1);
    });

    testWidgets('returning from the settings action retries the camera', (
      tester,
    ) async {
      platform.startError = const MobileScannerException(
        errorCode: MobileScannerErrorCode.permissionDenied,
      );
      await pumpScanPage(tester, onPopped: (_) {});

      platform.startError = null;
      await tester.tap(find.text(currentAppLocalizations.settings));
      await sendLifecycle(tester, AppLifecycleState.inactive);
      await sendLifecycle(tester, AppLifecycleState.resumed);
      await pumpFrames(tester);

      expect(platform.startCalls, 2);
      expect(find.text(currentAppLocalizations.qrcodeDesc), findsOneWidget);
    });

    testWidgets('a failed start can be retried', (tester) async {
      platform.startError = const MobileScannerException(
        errorCode: MobileScannerErrorCode.genericError,
      );
      await pumpScanPage(tester, onPopped: (_) {});

      expect(
        find.text(currentAppLocalizations.cameraUnavailable),
        findsOneWidget,
      );

      platform.startError = null;
      await tester.tap(find.text(currentAppLocalizations.retry));
      await pumpFrames(tester);

      expect(platform.startCalls, 2);
      expect(find.text(currentAppLocalizations.qrcodeDesc), findsOneWidget);
    });

    testWidgets('a device without a camera offers no retry', (tester) async {
      platform.startError = const MobileScannerException(
        errorCode: MobileScannerErrorCode.unsupported,
      );
      await pumpScanPage(tester, onPopped: (_) {});

      expect(
        find.text(currentAppLocalizations.cameraUnavailable),
        findsOneWidget,
      );
      expect(find.text(currentAppLocalizations.retry), findsNothing);
    });
  });

  group('ScanPage layout', () {
    const viewports = [
      (
        name: 'a portrait phone',
        size: Size(390, 844),
        padding: FakeViewPadding(top: 47, bottom: 34),
        textScale: 1.0,
      ),
      (
        name: 'a landscape phone',
        size: Size(844, 390),
        padding: FakeViewPadding(left: 47, right: 47, bottom: 21),
        textScale: 1.0,
      ),
      (
        name: 'a short split-screen pane with large text',
        size: Size(390, 420),
        padding: FakeViewPadding(top: 24),
        textScale: 2.0,
      ),
      (
        name: 'a landscape tablet',
        size: Size(1280, 800),
        padding: FakeViewPadding(top: 24, bottom: 48),
        textScale: 1.0,
      ),
    ];

    for (final viewport in viewports) {
      testWidgets('${viewport.name} keeps every control clear of the window', (
        tester,
      ) async {
        tester.view
          ..physicalSize = viewport.size
          ..devicePixelRatio = 1
          ..padding = viewport.padding;
        tester.platformDispatcher.textScaleFactorTestValue = viewport.textScale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        await pumpScanPage(tester, onPopped: (_) {});
        platform.emit(_textCapture(['plain text']));
        await pumpFrames(tester);

        final overlay = tester
            .widgetList<CustomPaint>(find.byType(CustomPaint))
            .map((paint) => paint.painter)
            .whereType<ScannerOverlay>()
            .single;
        final rects = {
          'scan window': overlay.scanWindow,
          'hint': tester.getRect(
            find.text(currentAppLocalizations.invalidProfileQrcode),
          ),
          'torch': tester.getRect(
            find.byTooltip(currentAppLocalizations.torch),
          ),
          'close': tester.getRect(
            find.byTooltip(currentAppLocalizations.close),
          ),
          'album': tester.getRect(
            find.byTooltip(currentAppLocalizations.pickFromAlbum),
          ),
        };
        final screen = Offset.zero & viewport.size;

        expect(overlay.scanWindow.width, greaterThan(100));
        expect(tester.takeException(), isNull);
        for (final MapEntry(key: name, value: rect) in rects.entries) {
          expect(screen.expandToInclude(rect), screen, reason: name);
          for (final MapEntry(key: other, value: otherRect) in rects.entries) {
            if (name.compareTo(other) < 0) {
              expect(
                rect.overlaps(otherRect),
                isFalse,
                reason: '$name overlaps $other',
              );
            }
          }
        }
      });
    }

    testWidgets('a landscape phone keeps the permission prompt in one column', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(844, 390)
        ..devicePixelRatio = 1
        ..padding = const FakeViewPadding(left: 47, right: 47, bottom: 21);
      addTearDown(tester.view.reset);
      platform.startError = const MobileScannerException(
        errorCode: MobileScannerErrorCode.permissionDenied,
      );
      await pumpScanPage(tester, onPopped: (_) {});

      final status = tester.getRect(find.byType(NullStatus));
      final label = tester.getRect(
        find.text(currentAppLocalizations.cameraPermissionRequired),
      );
      final description = tester.getRect(
        find.text(currentAppLocalizations.cameraPermissionDesc),
      );
      final settings = tester.getRect(
        find.ancestor(
          of: find.text(currentAppLocalizations.settings),
          matching: find.bySubtype<FilledButton>(),
        ),
      );
      final close = tester.getRect(
        find.byTooltip(currentAppLocalizations.close),
      );

      expect(tester.takeException(), isNull);
      expect(status.top, greaterThanOrEqualTo(close.bottom));
      expect(description.top, greaterThanOrEqualTo(label.bottom));
      expect(settings.top, greaterThanOrEqualTo(description.bottom));
      expect(settings.center.dx, moreOrLessEquals(label.center.dx, epsilon: 1));
    });
  });

  group('ScanPage torch', () {
    Finder torchAncestor<T extends Widget>() => find.ancestor(
      of: find.byTooltip(currentAppLocalizations.torch),
      matching: find.byType(T),
    );

    testWidgets('the torch button toggles the torch and follows its state', (
      tester,
    ) async {
      await pumpScanPage(tester, onPopped: (_) {});

      await tester.tap(find.byTooltip(currentAppLocalizations.torch));
      await pumpFrames(tester);
      expect(platform.toggleTorchCalls, 1);
      expect(find.byGlyph(AppGlyphs.torchOff), findsOneWidget);

      platform.emitTorch(TorchState.on);
      await pumpFrames(tester);
      expect(find.byGlyph(AppGlyphs.torch), findsOneWidget);
    });

    testWidgets('the torch button is hidden while the torch is unavailable', (
      tester,
    ) async {
      platform.initialTorchState = TorchState.unavailable;
      await pumpScanPage(tester, onPopped: (_) {});

      expect(
        tester.widget<ActivateBox>(torchAncestor<ActivateBox>()).active,
        isFalse,
      );
      expect(
        tester
            .widget<AnimatedOpacity>(torchAncestor<AnimatedOpacity>())
            .opacity,
        0,
      );
    });
  });
}
