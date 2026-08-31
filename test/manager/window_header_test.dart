import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/manager/window_manager.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

const _windowChannel = MethodChannel('window_manager');

const _contentKey = Key('window-header-test-content');

final double _windowsHeaderHeight = getWindowHeaderHeight(
  isDesktop: true,
  isMacOS: false,
);

final double _macOSHeaderHeight = getWindowHeaderHeight(
  isDesktop: true,
  isMacOS: true,
);

bool _hostShowsHeader({required int version, required bool isMobileView}) {
  return showsWindowHeader(
    isDesktop: system.isDesktop,
    isMacOS: system.isMacOS,
    version: version,
    isMobileView: isMobileView,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await AppLocalizations.load(const Locale('en'));
  });

  group('showsWindowHeader', () {
    test('Windows always draws its own header, at every width and build', () {
      for (final version in [10, 11]) {
        for (final isMobileView in [true, false]) {
          expect(
            showsWindowHeader(
              isDesktop: true,
              isMacOS: false,
              version: version,
              isMobileView: isMobileView,
            ),
            isTrue,
            reason: 'windows $version mobileView=$isMobileView',
          );
        }
      }
    });

    test('macOS keeps its native title bar unless the view is narrow', () {
      expect(
        showsWindowHeader(
          isDesktop: true,
          isMacOS: true,
          version: 15,
          isMobileView: false,
        ),
        isFalse,
      );
      expect(
        showsWindowHeader(
          isDesktop: true,
          isMacOS: true,
          version: 15,
          isMobileView: true,
        ),
        isTrue,
      );
      expect(
        showsWindowHeader(
          isDesktop: true,
          isMacOS: true,
          version: 10,
          isMobileView: true,
        ),
        isFalse,
      );
    });

    test('a phone never draws a window header', () {
      expect(
        showsWindowHeader(
          isDesktop: false,
          isMacOS: false,
          version: 34,
          isMobileView: true,
        ),
        isFalse,
      );
    });
  });

  group('getWindowHeaderHeight', () {
    test('Windows reserves more than macOS, mobile reserves nothing', () {
      expect(_windowsHeaderHeight, 40);
      expect(_macOSHeaderHeight, 28);
      expect(getWindowHeaderHeight(isDesktop: false, isMacOS: false), 0);
    });

    test('the host constant is the height its own platform asks for', () {
      expect(
        kHeaderHeight,
        getWindowHeaderHeight(
          isDesktop: system.isDesktop,
          isMacOS: system.isMacOS,
        ),
      );
    });
  });

  group('WindowHeaderBar on Windows', () {
    late ValueNotifier<bool> isPin;
    late ValueNotifier<bool> isMaximized;
    late List<String> events;

    setUp(() {
      isPin = ValueNotifier(false);
      isMaximized = ValueNotifier(false);
      events = [];
    });

    tearDown(() {
      isPin.dispose();
      isMaximized.dispose();
    });

    Future<void> pumpBar(WidgetTester tester, {double? width}) async {
      if (width != null) {
        tester.view.physicalSize = Size(width, 600);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
      }
      await tester.pumpWidget(
        TestApp(
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: _windowsHeaderHeight),
                  const Expanded(
                    flex: 1,
                    child: ColoredBox(
                      key: _contentKey,
                      color: Color(0xFF00FF00),
                    ),
                  ),
                ],
              ),
              WindowHeaderBar(
                height: _windowsHeaderHeight,
                onDragStart: () => events.add('drag'),
                onDoubleTap: () => events.add('maximize'),
                actions: WindowHeaderActions(
                  isPinNotifier: isPin,
                  isMaximizedNotifier: isMaximized,
                  onPin: () => events.add('pin'),
                  onMinimize: () => events.add('minimize'),
                  onMaximize: () => events.add('maximize'),
                  onClose: () => events.add('close'),
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pump();
    }

    Rect barRect(WidgetTester tester) =>
        tester.getRect(find.byType(WindowHeaderBar));

    testWidgets('the bar spans the top of the window at its own height', (
      tester,
    ) async {
      await pumpBar(tester, width: 900);

      final rect = barRect(tester);
      expect(rect.topLeft, Offset.zero);
      expect(rect.width, 900);
      expect(rect.height, _windowsHeaderHeight);
    });

    testWidgets('the drag surface covers the whole bar', (tester) async {
      await pumpBar(tester, width: 900);

      expect(
        tester.getRect(find.byType(GestureDetector).first),
        barRect(tester),
      );
    });

    testWidgets('the caption buttons stay inside the bar', (tester) async {
      await pumpBar(tester, width: 900);

      final bar = barRect(tester);
      final actions = tester.getRect(find.byType(WindowHeaderActions));

      expect(
        actions.top,
        greaterThanOrEqualTo(bar.top),
        reason: 'the buttons are drawn above the top edge of the window',
      );
      expect(
        actions.bottom,
        lessThanOrEqualTo(bar.bottom),
        reason: 'the buttons spill over the page below the bar',
      );
      expect(actions.right, bar.right);
    });

    testWidgets('every caption button is drawn inside the bar', (tester) async {
      await pumpBar(tester, width: 900);

      final bar = barRect(tester);
      for (final icon in [
        Icons.push_pin_outlined,
        Icons.remove,
        Icons.crop_square,
        Icons.close,
      ]) {
        final rect = tester.getRect(
          find.ancestor(
            of: find.byIcon(icon),
            matching: find.byType(IconButton),
          ),
        );
        expect(
          rect.top >= bar.top &&
              rect.bottom <= bar.bottom &&
              rect.left >= bar.left &&
              rect.right <= bar.right,
          isTrue,
          reason: '$icon is laid out at $rect, outside the bar $bar',
        );
      }
    });

    testWidgets('the bar keeps its height in a narrow window', (tester) async {
      await pumpBar(tester, width: 380);

      final rect = barRect(tester);
      expect(rect.height, _windowsHeaderHeight);
      expect(rect.width, 380);
      expect(tester.takeException(), isNull);
      expect(
        tester.getRect(find.byType(WindowHeaderActions)).left,
        greaterThanOrEqualTo(0),
      );
    });

    testWidgets('the content starts below the bar', (tester) async {
      await pumpBar(tester, width: 900);

      expect(
        tester.getTopLeft(find.byKey(_contentKey)).dy,
        _windowsHeaderHeight,
      );
    });

    testWidgets('dragging the bar moves the window', (tester) async {
      await pumpBar(tester, width: 900);

      await tester.timedDrag(
        find.byType(WindowHeaderBar),
        const Offset(0, 40),
        const Duration(milliseconds: 100),
      );
      await tester.pump();

      expect(events, contains('drag'));
    });

    testWidgets('a double tap on the bar toggles maximized', (tester) async {
      await pumpBar(tester, width: 900);

      final bar = barRect(tester);
      await tester.tapAt(Offset(bar.width / 2, bar.center.dy));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tapAt(Offset(bar.width / 2, bar.center.dy));
      await tester.pump(const Duration(milliseconds: 400));

      expect(events, contains('maximize'));
    });

    testWidgets('each caption button reports its own press', (tester) async {
      await pumpBar(tester, width: 900);

      await tester.tap(find.byIcon(Icons.push_pin_outlined));
      await tester.tap(find.byIcon(Icons.remove));
      await tester.tap(find.byIcon(Icons.crop_square));
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(events, ['pin', 'minimize', 'maximize', 'close']);
    });

    testWidgets('the drag surface never swallows a caption button press', (
      tester,
    ) async {
      await pumpBar(tester, width: 900);

      final close = tester.getCenter(find.byIcon(Icons.close));
      await tester.tapAt(close);
      await tester.pump();

      expect(events, ['close']);
    });
  });

  group('WindowHeaderLayout above the app navigator', () {
    Future<void> pumpLayout(WidgetTester tester) async {
      final isPin = ValueNotifier(false);
      final isMaximized = ValueNotifier(false);
      addTearDown(isPin.dispose);
      addTearDown(isMaximized.dispose);
      tester.view.physicalSize = const Size(900, 600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocalizations.delegate.supportedLocales,
          builder: (_, child) => WindowHeaderLayout(
            height: _windowsHeaderHeight,
            header: WindowHeaderBar(
              height: _windowsHeaderHeight,
              onDragStart: () {},
              onDoubleTap: () {},
              actions: WindowHeaderActions(
                isPinNotifier: isPin,
                isMaximizedNotifier: isMaximized,
                onPin: () {},
                onMinimize: () {},
                onMaximize: () {},
                onClose: () {},
              ),
            ),
            child: child!,
          ),
          home: const ColoredBox(key: _contentKey, color: Color(0xFF00FF00)),
        ),
      );
      await tester.pump();
    }

    testWidgets('the tooltips on the caption buttons find an overlay', (
      tester,
    ) async {
      await pumpLayout(tester);

      expect(tester.takeException(), isNull);
      expect(find.byType(WindowHeaderActions), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('a caption button shows its tooltip over the page', (
      tester,
    ) async {
      await pumpLayout(tester);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(find.byIcon(Icons.close)));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text(currentAppLocalizations.close), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the page still fills the window below the header', (
      tester,
    ) async {
      await pumpLayout(tester);

      final content = tester.getRect(find.byKey(_contentKey));
      expect(content.top, _windowsHeaderHeight);
      expect(content.width, 900);
      expect(content.bottom, 600);
    });
  });

  group('WindowHeaderBar on macOS', () {
    // The system draws the traffic lights over the top-left of the window, so
    // whatever the header paints there is unreachable.
    const trafficLightsWidth = 80.0;

    late List<String> events;

    setUp(() {
      events = [];
    });

    Future<void> pumpBar(WidgetTester tester, {required double width}) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        TestApp(
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: _macOSHeaderHeight),
                  const Expanded(
                    flex: 1,
                    child: ColoredBox(
                      key: _contentKey,
                      color: Color(0xFF00FF00),
                    ),
                  ),
                ],
              ),
              WindowHeaderBar(
                height: _macOSHeaderHeight,
                onDragStart: () => events.add('drag'),
                onDoubleTap: () => events.add('maximize'),
                title: const Text(appName),
              ),
            ],
          ),
        ),
      );
      await tester.pump();
    }

    Rect barRect(WidgetTester tester) =>
        tester.getRect(find.byType(WindowHeaderBar));

    testWidgets('shows the app name and no caption buttons', (tester) async {
      await pumpBar(tester, width: 900);

      expect(find.text(appName), findsOneWidget);
      expect(find.byType(WindowHeaderActions), findsNothing);
      expect(barRect(tester).height, _macOSHeaderHeight);
      expect(
        tester.getRect(find.text(appName)).center.dy,
        barRect(tester).center.dy,
      );
    });

    testWidgets('the bar spans the top of the window in a mobile view', (
      tester,
    ) async {
      await pumpBar(tester, width: 420);

      final rect = barRect(tester);
      expect(rect.topLeft, Offset.zero);
      expect(
        rect.width,
        420,
        reason: 'the window shows through beside the app name',
      );
      expect(rect.height, _macOSHeaderHeight);
    });

    testWidgets('the drag surface covers the whole bar', (tester) async {
      await pumpBar(tester, width: 420);

      expect(
        tester.getRect(find.byType(GestureDetector).first),
        barRect(tester),
      );
    });

    testWidgets('the app name clears the traffic lights in a mobile view', (
      tester,
    ) async {
      await pumpBar(tester, width: 420);

      expect(
        tester.getRect(find.text(appName)).left,
        greaterThan(trafficLightsWidth),
        reason: 'the app name is drawn under the macOS window buttons',
      );
    });

    testWidgets('dragging the app name moves the window', (tester) async {
      await pumpBar(tester, width: 420);

      await tester.timedDragFrom(
        tester.getCenter(find.text(appName)),
        const Offset(0, 40),
        const Duration(milliseconds: 100),
      );
      await tester.pump();

      expect(events, contains('drag'));
    });

    testWidgets('the content starts below the bar', (tester) async {
      await pumpBar(tester, width: 420);

      expect(tester.getTopLeft(find.byKey(_contentKey)).dy, _macOSHeaderHeight);
    });
  });

  group('WindowHeaderContainer', () {
    late ProviderContainer container;

    Future<void> pumpContainer(
      WidgetTester tester, {
      required int version,
      required Size viewSize,
    }) async {
      container = ProviderContainer(
        overrides: [
          versionProvider.overrideWithBuild((_, _) => version),
          viewSizeProvider.overrideWithBuild((_, _) => viewSize),
        ],
      );
      addTearDown(container.dispose);
      container.listen(overlayTopOffsetProvider, (_, _) {});
      globalState.container = container;
      tester.view.physicalSize = viewSize;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(
            includeNavigatorKey: false,
            child: WindowHeaderContainer(
              child: ColoredBox(key: _contentKey, color: Color(0xFF00FF00)),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    setUpAll(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_windowChannel, (call) async {
            if (call.method == 'isMaximized' ||
                call.method == 'isAlwaysOnTop') {
              return false;
            }
            return null;
          });
    });

    tearDownAll(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_windowChannel, null);
    });

    testWidgets('a narrow desktop window carries the header', (tester) async {
      await pumpContainer(tester, version: 15, viewSize: const Size(420, 800));

      final shows = _hostShowsHeader(version: 15, isMobileView: true);
      expect(find.byType(WindowHeader), shows ? findsOneWidget : findsNothing);
      expect(
        tester.getTopLeft(find.byKey(_contentKey)).dy,
        shows ? kHeaderHeight : 0,
      );
    });

    testWidgets('a wide window follows the same rule as the offset', (
      tester,
    ) async {
      await pumpContainer(tester, version: 15, viewSize: const Size(1200, 800));

      final shows = _hostShowsHeader(version: 15, isMobileView: false);
      expect(find.byType(WindowHeader), shows ? findsOneWidget : findsNothing);
      expect(
        tester.getTopLeft(find.byKey(_contentKey)).dy,
        shows ? kHeaderHeight : 0,
      );
    });

    testWidgets('the overlay offset reserves exactly what the header takes', (
      tester,
    ) async {
      for (final viewSize in [const Size(420, 800), const Size(1200, 800)]) {
        await pumpContainer(tester, version: 15, viewSize: viewSize);

        final shows = _hostShowsHeader(
          version: 15,
          isMobileView: viewSize.width <= maxMobileWidth,
        );
        expect(
          container.read(overlayTopOffsetProvider),
          kToolbarHeight + (shows ? kHeaderHeight : 0),
          reason: 'view size $viewSize',
        );
      }
    });
  });
}
