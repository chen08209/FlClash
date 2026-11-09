import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

const _phone = Size(402, 874);
const _safeTop = 62.0;
const _window = Size(1000, 700);

Future<BannerHostState> _pumpHost(
  WidgetTester tester, {
  Size size = _phone,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1
    ..viewPadding = const FakeViewPadding(top: _safeTop)
    ..padding = const FakeViewPadding(top: _safeTop);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    TestApp(
      child: BannerHost(
        stacked: size.width > _phone.width,
        topInset: 0,
        child: const SizedBox(),
      ),
    ),
  );
  return tester.state<BannerHostState>(find.byType(BannerHost).last);
}

Finder _bannerOf(String text) {
  return find
      .ancestor(
        of: find.text(text),
        matching: find.byWidgetPredicate(
          (widget) => widget is Surface || widget is LiquidGlass,
        ),
      )
      .first;
}

Rect _rectOf(WidgetTester tester, String text) =>
    tester.getRect(_bannerOf(text));

Future<void> _drag(WidgetTester tester, String text, Offset offset) async {
  final gesture = await tester.startGesture(tester.getCenter(_bannerOf(text)));
  for (var step = 1; step <= 10; step++) {
    await gesture.moveBy(offset / 10);
    await tester.pump(const Duration(milliseconds: 16));
  }
  await gesture.up();
}

void main() {
  testWidgets('shows a message until its duration expires', (tester) async {
    final host = await _pumpHost(tester);
    host.show('hello');
    await tester.pump();

    expect(find.text('hello'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('hello'), findsNothing);
  });

  testWidgets('rests across the phone 8 dp in from each edge', (tester) async {
    final host = await _pumpHost(tester);
    host.show('hello');
    await tester.pumpAndSettle();

    final rect = _rectOf(tester, 'hello');
    expect(rect.left, 8);
    expect(rect.right, _phone.width - 8);
    expect(rect.top, _safeTop);
    expect(rect.height, 52);
  });

  testWidgets('keeps the top inset it is given clear', (tester) async {
    tester.view
      ..physicalSize = _phone
      ..devicePixelRatio = 1
      ..viewPadding = const FakeViewPadding(top: _safeTop)
      ..padding = const FakeViewPadding(top: _safeTop);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const TestApp(
        child: BannerHost(stacked: false, topInset: 30, child: SizedBox()),
      ),
    );
    tester.state<BannerHostState>(find.byType(BannerHost).last).show('hello');
    await tester.pumpAndSettle();

    expect(_rectOf(tester, 'hello').top, _safeTop + 30);
  });

  testWidgets('keeps a wide window banner at a centred 556 dp', (tester) async {
    const window = _window;
    final host = await _pumpHost(tester, size: window);
    host.show('hello');
    await tester.pumpAndSettle();

    final rect = _rectOf(tester, 'hello');
    expect(rect.width, 556);
    expect(rect.center.dx, window.width / 2);
  });

  testWidgets('drops straight in from above the screen', (tester) async {
    final host = await _pumpHost(tester);
    host.show('hello');
    await tester.pump();

    final start = _rectOf(tester, 'hello');
    expect(start.bottom, lessThanOrEqualTo(0));
    expect(start.left, 8);
    expect(start.width, _phone.width - 16);

    var previous = start.top;
    for (var frame = 0; frame < 20; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      final rect = _rectOf(tester, 'hello');
      expect(rect.left, 8);
      expect(rect.top, greaterThanOrEqualTo(previous));
      expect(rect.top, lessThanOrEqualTo(_safeTop + 1));
      previous = rect.top;
    }
    expect(previous, closeTo(_safeTop, 1));
  });

  testWidgets('rises straight off the screen before it is removed', (
    tester,
  ) async {
    final host = await _pumpHost(tester);
    host.show('hello');
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 3));
    final leaving = _rectOf(tester, 'hello');
    await tester.pump(const Duration(milliseconds: 100));
    final rising = _rectOf(tester, 'hello');
    expect(rising.top, lessThan(leaving.top));
    expect(rising.width, leaving.width);

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    expect(find.text('hello'), findsNothing);
  });

  testWidgets('shows one banner at a time, in turn', (tester) async {
    final host = await _pumpHost(tester);
    host.show('first');
    host.show('second');
    await tester.pump();

    expect(find.text('first'), findsOneWidget);
    expect(find.text('second'), findsNothing);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('first'), findsNothing);
    expect(find.text('second'), findsOneWidget);
  });

  testWidgets('a waiting message cuts the shown banner short', (tester) async {
    final host = await _pumpHost(tester);
    host.show('careful', level: BannerLevel.warning);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    host.show('next');
    await tester.pump();
    expect(find.text('careful'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('careful'), findsNothing);
    expect(find.text('next'), findsOneWidget);
  });

  testWidgets('a message arriving after the hold sends the shown one off', (
    tester,
  ) async {
    final host = await _pumpHost(tester);
    host.show('careful', level: BannerLevel.warning);
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    expect(find.text('careful'), findsOneWidget);

    host.show('next');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('careful'), findsNothing);
    expect(find.text('next'), findsOneWidget);
  });

  testWidgets('a banner that acts on a tap is not cut short', (tester) async {
    final host = await _pumpHost(tester);
    host.show('restart needed', onTap: () {});
    await tester.pump();
    host.show('next');
    await tester.pump(const Duration(seconds: 5));
    expect(find.text('restart needed'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('restart needed'), findsNothing);
    expect(find.text('next'), findsOneWidget);
  });

  testWidgets('an error jumps ahead of the messages waiting in the queue', (
    tester,
  ) async {
    final host = await _pumpHost(tester);
    host.show('first');
    host.show('second');
    host.show('boom', level: BannerLevel.error);
    await tester.pump();

    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('boom'), findsOneWidget);
    expect(find.text('second'), findsNothing);
  });

  testWidgets('merges a repeat instead of queueing it again', (tester) async {
    final host = await _pumpHost(tester);
    host.show('same');
    host.show('same');
    await tester.pump();
    expect(find.text('same'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('same'), findsNothing);
  });

  testWidgets('a merged repeat restarts the visible duration', (tester) async {
    final host = await _pumpHost(tester);
    host.show('same');
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    host.show('same');
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('same'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('same'), findsNothing);
  });

  testWidgets('tells levels apart by their fill alone', (tester) async {
    final host = await _pumpHost(tester);
    host.show('plain');
    await tester.pump();
    final context = tester.element(find.text('plain'));
    final colorScheme = Theme.of(context).colorScheme;

    expect(find.byType(GlyphIcon), findsNothing);
    expect(find.byType(Image), findsNothing);
    expect(
      tester.widget<Surface>(_bannerOf('plain')).color,
      SurfaceLevel.floatingOf(colorScheme).colorOf(colorScheme),
    );

    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 300));
    host.show('boom', level: BannerLevel.error);
    await tester.pump();

    expect(find.byType(GlyphIcon), findsNothing);
    expect(
      tester.widget<Surface>(_bannerOf('boom')).color,
      colorScheme.errorContainer,
    );
    expect(
      tester.widget<Text>(find.text('boom')).style?.color,
      colorScheme.onErrorContainer,
    );
  });

  testWidgets('keeps an error longer than an info message', (tester) async {
    final host = await _pumpHost(tester);
    host.show('boom', level: BannerLevel.error);
    await tester.pump();

    await tester.pump(const Duration(seconds: 5));
    expect(find.text('boom'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('boom'), findsNothing);
  });

  testWidgets('a tap runs the banner\'s action and dismisses it', (
    tester,
  ) async {
    var ran = false;
    final host = await _pumpHost(tester);
    host.show('restart needed', onTap: () => ran = true);
    await tester.pumpAndSettle();
    await tester.tap(find.text('restart needed'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(ran, isTrue);
    expect(find.text('restart needed'), findsNothing);
  });

  testWidgets('a tap leaves a banner without an action in place', (
    tester,
  ) async {
    final host = await _pumpHost(tester);
    host.show('plain');
    await tester.pumpAndSettle();

    await tester.tap(find.text('plain'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('plain'), findsOneWidget);
  });

  testWidgets('a swipe up dismisses the banner', (tester) async {
    final host = await _pumpHost(tester);
    host.show('swipe me');
    await tester.pumpAndSettle();

    await _drag(tester, 'swipe me', const Offset(0, -80));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('swipe me'), findsNothing);
  });

  testWidgets('a short drag springs back and keeps the banner', (tester) async {
    final host = await _pumpHost(tester);
    host.show('drag me');
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(
      tester.getCenter(_bannerOf('drag me')),
    );
    for (var step = 0; step < 4; step++) {
      await gesture.moveBy(const Offset(0, -5));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(_rectOf(tester, 'drag me').top, lessThan(_safeTop));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(_rectOf(tester, 'drag me').top, _safeTop);
  });

  testWidgets('a pull down stretches less than the finger moves', (
    tester,
  ) async {
    final host = await _pumpHost(tester);
    host.show('pull me');
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(
      tester.getCenter(_bannerOf('pull me')),
    );
    await gesture.moveBy(const Offset(0, 20));
    await gesture.moveBy(const Offset(0, 100));
    await tester.pump();
    final pulled = _rectOf(tester, 'pull me').top - _safeTop;
    expect(pulled, greaterThan(0));
    expect(pulled, lessThan(40));

    await gesture.up();
    await tester.pumpAndSettle();
    expect(_rectOf(tester, 'pull me').top, _safeTop);
  });

  testWidgets('a drag holds the auto dismiss until it is released', (
    tester,
  ) async {
    final host = await _pumpHost(tester);
    host.show('held');
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(
      tester.getCenter(_bannerOf('held')),
    );
    for (var step = 0; step < 4; step++) {
      await gesture.moveBy(const Offset(0, 10));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(seconds: 4));
    expect(find.text('held'), findsOneWidget);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('held'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('held'), findsNothing);
  });

  testWidgets('a message that arrives during a drag waits for the release', (
    tester,
  ) async {
    final host = await _pumpHost(tester);
    host.show('held');
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(
      tester.getCenter(_bannerOf('held')),
    );
    for (var step = 0; step < 4; step++) {
      await gesture.moveBy(const Offset(0, 10));
      await tester.pump(const Duration(milliseconds: 50));
    }
    host.show('arrived mid drag');
    await tester.pump(const Duration(seconds: 4));
    expect(find.text('held'), findsOneWidget);
    expect(find.text('arrived mid drag'), findsNothing);

    await gesture.up();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('held'), findsNothing);
    expect(find.text('arrived mid drag'), findsOneWidget);
  });

  testWidgets('a wide window stacks up to three, the newest on top', (
    tester,
  ) async {
    final host = await _pumpHost(tester, size: _window);
    for (final text in ['first', 'second', 'third', 'fourth']) {
      host.show(text);
    }
    await tester.pumpAndSettle(const Duration(milliseconds: 16));

    expect(find.text('fourth'), findsNothing);
    final first = _rectOf(tester, 'first');
    final second = _rectOf(tester, 'second');
    final third = _rectOf(tester, 'third');
    expect(third.top, _safeTop);
    expect(second.top, third.bottom + 8);
    expect(first.top, second.bottom + 8);
    expect(first.left, third.left);
    expect(first.width, 556);
  });

  testWidgets('a full stack lets the oldest go once it has held', (
    tester,
  ) async {
    final host = await _pumpHost(tester, size: _window);
    host.show('oldest', level: BannerLevel.warning);
    host.show('middle', level: BannerLevel.warning);
    host.show('newest', level: BannerLevel.warning);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    host.show('waiting');
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('waiting'), findsNothing);

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('oldest'), findsNothing);
    expect(find.text('middle'), findsOneWidget);
    expect(find.text('waiting'), findsOneWidget);
  });

  testWidgets('a stacked banner fades as its slot closes', (tester) async {
    final host = await _pumpHost(tester, size: _window);
    host.show('older', level: BannerLevel.warning);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    host.show('newer');
    await tester.pumpAndSettle(const Duration(milliseconds: 16));
    final newerTop = _rectOf(tester, 'newer').top;
    final olderTop = _rectOf(tester, 'older').top;

    await tester.pump(const Duration(milliseconds: 2500));
    final fade = tester.widget<LiquidGlassFade>(
      find.ancestor(
        of: find.text('newer'),
        matching: find.byType(LiquidGlassFade),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(fade.opacity.value, inExclusiveRange(0, 1));
    expect(_rectOf(tester, 'newer').top, newerTop);
    expect(_rectOf(tester, 'older').top, lessThan(olderTop));

    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('newer'), findsNothing);
    expect(_rectOf(tester, 'older').top, closeTo(_safeTop, 0.5));
  });

  testWidgets('a banner takes presses and swipes anywhere on it', (
    tester,
  ) async {
    for (final stacked in [false, true]) {
      for (final glass in [false, true]) {
        var pageTaps = 0;
        tester.view
          ..physicalSize = stacked ? _window : _phone
          ..devicePixelRatio = 1
          ..viewPadding = const FakeViewPadding(top: _safeTop)
          ..padding = const FakeViewPadding(top: _safeTop);
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          TestApp(
            child: LiquidGlassScope(
              enabled: glass,
              child: LiquidGlassHost(
                enabled: glass,
                child: BannerHost(
                  stacked: stacked,
                  topInset: 0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => pageTaps++,
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
          ),
        );
        tester
            .state<BannerHostState>(find.byType(BannerHost).last)
            .show('hello');
        await tester.pumpAndSettle();

        final rect = _rectOf(tester, 'hello');
        await tester.tapAt(rect.centerRight - const Offset(24, 0));
        await tester.tapAt(rect.topCenter + const Offset(0, 4));
        await tester.pump(const Duration(milliseconds: 300));

        expect(pageTaps, 0, reason: 'stacked $stacked, glass $glass');

        final gesture = await tester.startGesture(
          rect.centerRight - const Offset(24, 0),
        );
        for (var step = 0; step < 10; step++) {
          await gesture.moveBy(const Offset(0, -10));
          await tester.pump(const Duration(milliseconds: 16));
        }
        await gesture.up();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(
          find.text('hello'),
          findsNothing,
          reason: 'stacked $stacked, glass $glass',
        );
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 10));
      }
    }
  });
}
