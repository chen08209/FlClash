import 'dart:async';
import 'dart:math' as math;

import 'package:fl_clash/providers/app.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/host_scaffold.dart';
import 'package:prism_ui/prism_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() => container = ProviderContainer());

  tearDown(() => container.dispose());

  void setViewWidth(double width) {
    container.read(viewSizeProvider.notifier).value = Size(width, 900);
  }

  Future<void> pumpHost(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: HostApp(
          builder: (context, child) => wrapAppScopes(context, child!),
          onGenerateRoute: (settings) =>
              HomeRoute<void>(settings: settings, builder: _opener),
        ),
      ),
    );
    await tester.pump();
  }

  group('BaseNavigator.push', () {
    testWidgets('uses the fading desktop route on a wide view', (tester) async {
      setViewWidth(1400);
      await pumpHost(tester);

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(FadeTransition), findsWidgets);
      await tester.pumpAndSettle();
      expect(find.text('pushed page'), findsOneWidget);
    });

    testWidgets('slides the mobile route in from its trailing edge on '
        "iOS's spring", (tester) async {
      setViewWidth(400);
      await pumpHost(tester);

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final page = find.ancestor(
        of: find.text('pushed page'),
        matching: find.byType(HostScaffold),
      );
      final progress = ModalRoute.of(tester.element(page))!.animation!.value;
      // A critically damped 0.3 s spring setting off at nine times its
      // distance a second, 0.1 s past its first frame, which it shows a frame
      // in.
      const omega = 2 * math.pi / 0.3;
      const time = 0.1 + 1 / 60;
      final spring = 1 - (1 + (omega - 9) * time) * math.exp(-omega * time);
      expect(progress, closeTo(spring, 0.01));
      expect(
        tester.getTopLeft(page).dx,
        closeTo(tester.getSize(page).width * (1 - progress), 0.5),
      );
    });

    for (final glass in [false, true]) {
      testWidgets(
        glass
            ? 'draws pages leaving view from snapshots under glass'
            : 'draws pages leaving view from snapshots and the rest live',
        (tester) async {
          setViewWidth(400);
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: HostApp(
                builder: (context, child) => LiquidGlassScope(
                  enabled: glass,
                  child: wrapAppScopes(context, child!),
                ),
                onGenerateRoute: (settings) =>
                    HomeRoute<void>(settings: settings, builder: _opener),
              ),
            ),
          );
          bool snapshots(String text) => tester
              .widget<SnapshotWidget>(
                find
                    .ancestor(
                      of: find.text(text, skipOffstage: false),
                      matching: find.byType(
                        SnapshotWidget,
                        skipOffstage: false,
                      ),
                    )
                    .first,
              )
              .controller
              .allowSnapshotting;

          await tester.tap(find.text('open'));
          await tester.pump();
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 60));
          expect(snapshots('pushed page'), isFalse);
          expect(snapshots('open'), isTrue);

          await tester.pumpAndSettle();
          expect(snapshots('pushed page'), isFalse);
          expect(snapshots('open'), isFalse);

          Navigator.of(tester.element(find.text('pushed page'))).pop();
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 60));
          expect(snapshots('pushed page'), isTrue);
          expect(snapshots('open'), isFalse);
        },
      );
    }

    testWidgets('uses the card route on a mobile view', (tester) async {
      setViewWidth(400);
      await pumpHost(tester);

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('pushed page'), findsOneWidget);
    });

    testWidgets('every frame of a push and a pop shows a page, drawn from its '
        'snapshot or live', (tester) async {
      const below = Color(0xFFFF0000);
      const pushed = Color(0xFF0000FF);
      setViewWidth(400);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: HostApp(
            builder: (context, child) => wrapAppScopes(context, child!),
            onGenerateRoute: (settings) => HomeRoute<void>(
              settings: settings,
              builder: (context) => GestureDetector(
                key: const Key('below'),
                onTap: () => BaseNavigator.push(
                  context,
                  const ColoredBox(color: pushed, child: SizedBox.expand()),
                ),
                child: const ColoredBox(color: below, child: SizedBox.expand()),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      Future<Color?> lastFrameShown() async {
        Color? shown;
        for (var frame = 0; frame < 90; frame++) {
          await tester.pump(const Duration(milliseconds: 16));
          final ratio = tester.view.devicePixelRatio;
          final size = tester.view.physicalSize;
          final layer =
              tester.binding.renderViews.first.debugLayer! as OffsetLayer;
          final bytes = await tester.runAsync(() async {
            final image = await layer.toImage(Offset.zero & size);
            return image.toByteData();
          });
          final x = (20 * ratio).floor();
          final y = (size.height / 2).floor();
          final offset = (y * size.width.toInt() + x) * 4;
          final [r, _, b, _] = bytes!.buffer.asUint8List(offset, 4);
          if (r > 128 && b < 32) {
            shown = below;
          } else if (b > 128 && r < 32) {
            shown = pushed;
          } else {
            fail('frame $frame shows neither page: r $r, b $b');
          }
        }
        return shown;
      }

      await tester.tap(find.byKey(const Key('below')));
      await tester.pump();
      expect(await lastFrameShown(), pushed);
      Navigator.of(tester.element(find.byType(ColoredBox).last)).pop();
      await tester.pump();
      expect(await lastFrameShown(), below);
    });

    testWidgets('slides the page below back by three tenths and dims it', (
      tester,
    ) async {
      setViewWidth(400);
      await pumpHost(tester);
      final origin = tester.getTopLeft(find.text('open')).dx;

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));

      final route = ModalRoute.of(tester.element(find.text('pushed page')))!;
      final progress = route.animation!.value;
      final width = tester.getSize(find.byType(HostScaffold).first).width;
      expect(progress, inExclusiveRange(0, 1));
      expect(
        tester.getTopLeft(find.text('open')).dx,
        closeTo(origin - 0.3 * width * progress, 0.5),
      );
      expect(
        find.byType(HostApp),
        paints..something((method, arguments) {
          if (method != #drawRect) {
            return false;
          }
          final color = (arguments[1] as Paint).color;
          return color.r == 0 && (color.a - 0.1 * progress).abs() < 1e-3;
        }),
      );
    });

    testWidgets('rounds a moving page with the display corners', (
      tester,
    ) async {
      setViewWidth(400);
      const corners = BorderRadius.all(Radius.circular(40));
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: HostApp(
            builder: (context, child) => MediaQuery(
              data: MediaQueryData(
                size: MediaQuery.sizeOf(context),
                displayCornerRadii: corners,
              ),
              child: wrapAppScopes(context, child!),
            ),
            onGenerateRoute: (settings) =>
                HomeRoute<void>(settings: settings, builder: _opener),
          ),
        ),
      );
      Iterable<ClipRSuperellipseLayer> cardClips() => tester.layers
          .whereType<ClipRSuperellipseLayer>()
          .where((layer) => layer.clipRSuperellipse?.tlRadius.x == 40);

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      expect(cardClips(), hasLength(2));

      await tester.pumpAndSettle();
      expect(cardClips(), isEmpty);
    });

    testWidgets('keeps the first page built while pages slide over it', (
      tester,
    ) async {
      setViewWidth(400);
      var builds = 0;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: HostApp(
            builder: (context, child) => wrapAppScopes(context, child!),
            onGenerateRoute: (settings) => HomeRoute<void>(
              settings: settings,
              builder: (_) => HostScaffold(
                body: Builder(
                  builder: (context) {
                    builds++;
                    Theme.of(context);
                    return TextButton(
                      onPressed: () => BaseNavigator.push(
                        context,
                        const HostScaffold(body: Text('pushed page')),
                      ),
                      child: const Text('open'),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
      final origin = tester.getTopLeft(find.text('open')).dx;
      builds = 0;

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      expect(tester.getTopLeft(find.text('open')).dx, lessThan(origin));
      await tester.pumpAndSettle();
      Navigator.of(tester.element(find.text('pushed page'))).pop();
      await tester.pumpAndSettle();

      expect(builds, 0);
    });

    testWidgets('stays on screen when a pop only drops a local history entry', (
      tester,
    ) async {
      setViewWidth(400);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: HostApp(
            builder: (context, child) => wrapAppScopes(context, child!),
            onGenerateRoute: (settings) => HomeRoute<void>(
              settings: settings,
              builder: (_) => const HostScaffold(body: Text('home')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.text('home'));
      final route = ModalRoute.of(context)!;
      route.addLocalHistoryEntry(LocalHistoryEntry());

      Navigator.of(context).pop();
      await tester.pumpAndSettle();

      expect(route.isActive, isTrue);
      expect(route.animation!.value, 1);
    });

    testWidgets('pops back to the origin', (tester) async {
      setViewWidth(1400);
      await pumpHost(tester);
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final context = tester.element(find.text('pushed page'));
      Navigator.of(context).pop();
      await tester.pumpAndSettle();

      expect(find.text('pushed page'), findsNothing);
      expect(find.text('open'), findsOneWidget);
    });
  });

  group('whenRouteUncovered', () {
    testWidgets('waits for the page above to finish leaving', (tester) async {
      setViewWidth(400);
      await pumpHost(tester);
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      final pageContext = tester.element(find.text('pushed page'));
      unawaited(
        BaseNavigator.push(pageContext, const HostScaffold(body: Text('top'))),
      );
      await tester.pumpAndSettle();

      Navigator.of(tester.element(find.text('top'))).pop();
      var uncovered = false;
      unawaited(whenRouteUncovered(pageContext).then((_) => uncovered = true));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(uncovered, isFalse);

      await tester.pumpAndSettle();

      expect(uncovered, isTrue);
    });
  });

  group('drag back', () {
    Future<void> openPage(
      WidgetTester tester,
      double width,
      Widget page,
    ) async {
      setViewWidth(width);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: HostApp(
            builder: (context, child) => wrapAppScopes(context, child!),
            home: Builder(
              builder: (context) => HostScaffold(
                body: TextButton(
                  onPressed: () => BaseNavigator.push(context, page),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    const page = HostScaffold(body: Center(child: Text('pushed page')));

    Future<void> dragAndRest(WidgetTester tester, double share) async {
      final width = tester.getSize(find.byType(HostScaffold).last).width;
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('pushed page')),
      );
      await gesture.moveBy(const Offset(31, 0));
      for (var i = 0; i < 10; i++) {
        await gesture.moveBy(Offset(width * share / 10, 0));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.up();
      await tester.pumpAndSettle();
    }

    for (final width in [400.0, 1400.0]) {
      testWidgets('pops when let go at rest past 0.4665 of width $width', (
        tester,
      ) async {
        await openPage(tester, width, page);

        await dragAndRest(tester, 0.48);

        expect(find.text('pushed page'), findsNothing);
        expect(find.text('open'), findsOneWidget);
      });

      testWidgets('stays when let go at rest short of it at width $width', (
        tester,
      ) async {
        await openPage(tester, width, page);

        await dragAndRest(tester, 0.45);

        expect(find.text('pushed page'), findsOneWidget);
        expect(tester.getTopLeft(find.byType(HostScaffold).last), Offset.zero);
      });
    }

    testWidgets('pops on a quick right fling', (tester) async {
      await openPage(tester, 400, page);

      await tester.fling(find.text('pushed page'), const Offset(120, 0), 1500);
      await tester.pumpAndSettle();

      expect(find.text('pushed page'), findsNothing);
    });

    testWidgets('is disabled when the page vetoes popping', (tester) async {
      await openPage(tester, 400, const PopScope(canPop: false, child: page));

      await tester.timedDrag(
        find.text('pushed page'),
        const Offset(300, 0),
        const Duration(seconds: 1),
      );
      await tester.pumpAndSettle();

      expect(find.text('pushed page'), findsOneWidget);
    });

    testWidgets('yields to a horizontal scrollable inside the page', (
      tester,
    ) async {
      await openPage(
        tester,
        400,
        HostScaffold(
          body: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (var i = 0; i < 20; i++)
                SizedBox(width: 200, child: Text('item $i')),
            ],
          ),
        ),
      );
      final list = find.byType(Scrollable).last;
      tester.state<ScrollableState>(list).position.jumpTo(600);
      await tester.pump();

      await tester.timedDrag(
        list,
        const Offset(300, 0),
        const Duration(seconds: 1),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
    });
  });

  group('route configuration', () {
    test('desktop route exposes a transparent barrier and keeps state', () {
      final route = FadePageRoute<void>(builder: (_) => const SizedBox());

      expect(route.barrierColor, isNull);
      expect(route.barrierLabel, isNull);
      expect(route.maintainState, isTrue);
      expect(route.transitionDuration, const Duration(milliseconds: 200));
      expect(
        route.reverseTransitionDuration,
        const Duration(milliseconds: 200),
      );
    });

    test('mobile route exposes a transparent barrier and keeps state', () {
      final route = CardPageRoute<void>(builder: (_) => const SizedBox());

      expect(route.barrierColor, isNull);
      expect(route.barrierLabel, isNull);
      expect(route.maintainState, isTrue);
    });
  });
}

Widget _opener(BuildContext context) {
  return HostScaffold(
    body: TextButton(
      onPressed: () => BaseNavigator.push(
        context,
        const HostScaffold(body: Text('pushed page')),
      ),
      child: const Text('open'),
    ),
  );
}
