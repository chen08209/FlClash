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

Finder _glyph(CaptionGlyph glyph) => find.byWidgetPredicate(
  (widget) => widget is CaptionIcon && widget.glyph == glyph,
);

Finder _captionButton(Finder icon) =>
    find.ancestor(of: icon, matching: find.byType(IconButton));

Finder get _pinIcon => find.byIcon(Icons.push_pin_outlined);

List<Finder> get _captionIcons => [
  _glyph(CaptionGlyph.minimize),
  _glyph(CaptionGlyph.maximize),
  _glyph(CaptionGlyph.close),
];

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
      expect(_windowsHeaderHeight, 32);
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
    late ValueNotifier<WindowCaptionState> caption;
    late List<String> events;

    setUp(() {
      caption = ValueNotifier(const WindowCaptionState());
      events = [];
    });

    tearDown(() {
      caption.dispose();
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
                  state: caption,
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
      for (final icon in [_pinIcon, ..._captionIcons]) {
        final rect = tester.getRect(_captionButton(icon));
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

    testWidgets('the caption buttons match the Windows 11 slot', (
      tester,
    ) async {
      await pumpBar(tester, width: 900);

      final slot = getCaptionButtonSize(_windowsHeaderHeight);
      expect(slot, const Size(46, 32));
      for (final icon in _captionIcons) {
        expect(
          tester.getSize(_captionButton(icon)),
          slot,
          reason: '$icon does not fill a caption slot the height of the bar',
        );
        expect(
          tester.getSize(icon).longestSide,
          lessThanOrEqualTo(_windowsHeaderHeight / 2),
          reason: '$icon is drawn too large for a title bar glyph',
        );
      }
      expect(
        tester.getRect(_captionButton(_glyph(CaptionGlyph.close))).right,
        900,
      );
    });

    testWidgets('the pin keeps the round Material button in a square slot', (
      tester,
    ) async {
      await pumpBar(tester, width: 900);

      final pin = _captionButton(_pinIcon);
      expect(
        tester.getSize(pin),
        Size.square(_windowsHeaderHeight),
        reason: 'the pin must not stretch into a Windows caption slot',
      );
      expect(tester.getSize(_pinIcon), const Size.square(pinIconSize));
      expect(tester.getCenter(_pinIcon), tester.getCenter(pin));
      expect(
        tester.widget<IconButton>(pin).style?.shape?.resolve({}),
        const CircleBorder(),
        reason: 'the pin keeps the round ripple of a regular icon button',
      );
      expect(
        tester.getRect(pin).right,
        tester.getRect(_captionButton(_glyph(CaptionGlyph.minimize))).left,
      );
    });

    testWidgets('the window glyphs are 10x10 and centered in their slot', (
      tester,
    ) async {
      await pumpBar(tester, width: 900);

      for (final icon in _captionIcons) {
        expect(tester.getSize(icon), const Size.square(captionGlyphSize));
        expect(
          tester.getCenter(icon),
          tester.getCenter(_captionButton(icon)),
          reason: '$icon sits off center in its caption button',
        );
      }
    });

    testWidgets('a maximized window offers the restore glyph', (tester) async {
      await pumpBar(tester, width: 900);
      expect(_glyph(CaptionGlyph.maximize), findsOneWidget);
      expect(_glyph(CaptionGlyph.restore), findsNothing);

      caption.value = const WindowCaptionState(isMaximized: true);
      await tester.pump();

      expect(_glyph(CaptionGlyph.maximize), findsNothing);
      expect(_glyph(CaptionGlyph.restore), findsOneWidget);
      expect(
        find.byTooltip(currentAppLocalizations.unmaximize),
        findsOneWidget,
      );
    });

    testWidgets('caption buttons are flat rectangles that keep the ripple', (
      tester,
    ) async {
      await pumpBar(tester, width: 900);

      final size = getCaptionButtonSize(_windowsHeaderHeight);
      expect(size.width, greaterThan(size.height));

      final context = tester.element(_glyph(CaptionGlyph.close));
      final themeStyle = IconButtonTheme.of(context).style!;
      final onSurface = Theme.of(context).colorScheme.onSurface;
      expect(themeStyle.shape?.resolve({}), AppShape.none);
      expect(themeStyle.minimumSize?.resolve({}), size);
      expect(themeStyle.splashFactory, isNull);
      expect(themeStyle.animationDuration, isNull);
      expect(themeStyle.overlayColor, isNull);
      expect(themeStyle.foregroundColor?.resolve({}), onSurface);
      expect(
        themeStyle.foregroundColor?.resolve({WidgetState.pressed}),
        onSurface,
      );
    });

    testWidgets('the close button warns on hover', (tester) async {
      await pumpBar(tester, width: 900);

      final closeIcon = _glyph(CaptionGlyph.close);
      final close = tester.widget<IconButton>(_captionButton(closeIcon));
      final colorScheme = Theme.of(tester.element(closeIcon)).colorScheme;
      final style = close.style!;

      expect(
        style.backgroundColor?.resolve({WidgetState.hovered}),
        colorScheme.error,
      );
      expect(
        style.foregroundColor?.resolve({WidgetState.hovered}),
        colorScheme.onError,
      );
      expect(
        style.backgroundColor?.resolve({WidgetState.pressed}),
        colorScheme.error,
      );
      expect(style.backgroundColor?.resolve({}), isNull);
      expect(style.foregroundColor?.resolve({}), isNull);
      expect(
        style.overlayColor?.resolve({WidgetState.hovered}),
        Colors.transparent,
      );
      expect(
        style.overlayColor?.resolve({WidgetState.pressed}),
        colorScheme.onError.opacity12,
        reason:
            'the ripple on the error colored close button must stay visible',
      );

      for (final icon in [
        _pinIcon,
        _glyph(CaptionGlyph.minimize),
        _glyph(CaptionGlyph.maximize),
      ]) {
        final button = tester.widget<IconButton>(_captionButton(icon));
        expect(
          button.style?.backgroundColor?.resolve({WidgetState.hovered}),
          isNull,
          reason: '$icon must not borrow the close button warning color',
        );
      }
    });

    testWidgets('hovering the close button paints it in the error colors', (
      tester,
    ) async {
      await pumpBar(tester, width: 900);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(_glyph(CaptionGlyph.close)));
      await tester.pumpAndSettle();

      final context = tester.element(_glyph(CaptionGlyph.close));
      final colorScheme = Theme.of(context).colorScheme;
      expect(IconTheme.of(context).color, colorScheme.onError);
      final material = tester.widget<Material>(
        find
            .descendant(
              of: _captionButton(_glyph(CaptionGlyph.close)),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(material.color, colorScheme.error);
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

      await tester.tap(_pinIcon);
      await tester.tap(_glyph(CaptionGlyph.minimize));
      await tester.tap(_glyph(CaptionGlyph.maximize));
      await tester.tap(_glyph(CaptionGlyph.close));
      await tester.pump();

      expect(events, ['pin', 'minimize', 'maximize', 'close']);
    });

    testWidgets('the drag surface never swallows a caption button press', (
      tester,
    ) async {
      await pumpBar(tester, width: 900);

      final close = tester.getCenter(_glyph(CaptionGlyph.close));
      await tester.tapAt(close);
      await tester.pump();

      expect(events, ['close']);
    });
  });

  group('WindowHeaderLayout above the app navigator', () {
    Future<void> pumpLayout(WidgetTester tester) async {
      final caption = ValueNotifier(const WindowCaptionState());
      addTearDown(caption.dispose);
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
                state: caption,
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
      expect(_glyph(CaptionGlyph.close), findsOneWidget);
    });

    testWidgets('a caption button shows its tooltip over the page', (
      tester,
    ) async {
      await pumpLayout(tester);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(_glyph(CaptionGlyph.close)));
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
            return switch (call.method) {
              'isMaximized' || 'isAlwaysOnTop' || 'isFullScreen' => false,
              _ => null,
            };
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
