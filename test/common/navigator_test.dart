import 'dart:async';

import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/ui/navigator.dart';
import 'package:fl_clash/ui/surface.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/hand_over.dart';
import '../helpers/test_app.dart';

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
        child: MaterialApp(
          builder: (context, child) => wrapAppScopes(context, child!),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => BaseNavigator.push(
                  context,
                  const Scaffold(body: Text('pushed page')),
                ),
                child: const Text('open'),
              ),
            ),
          ),
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

    testWidgets('slides the mobile route in from a quarter of its width', (
      tester,
    ) async {
      setViewWidth(400);
      await pumpHost(tester);

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final page = find.text('pushed page');
      final progress = ModalRoute.of(tester.element(page))!.animation!.value;
      final width = tester
          .getSize(find.ancestor(of: page, matching: find.byType(Scaffold)))
          .width;
      expect(progress, inExclusiveRange(0, 1));
      expect(
        tester.getTopLeft(page).dx,
        closeTo(
          width / 4 * (1 - Curves.easeInOutCubicEmphasized.transform(progress)),
          0.5,
        ),
      );
    });

    testWidgets('uses the shared-axis route on a mobile view', (tester) async {
      setViewWidth(400);
      await pumpHost(tester);

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('pushed page'), findsOneWidget);
    });

    testWidgets('hands over from the page below without either showing '
        'through the other', (tester) async {
      setViewWidth(400);
      late BuildContext home;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            builder: (context, child) => wrapAppScopes(context, child!),
            theme: ThemeData().withAppSurfaces,
            home: Builder(
              builder: (context) {
                home = context;
                return const Scaffold(body: Center(child: Text('home')));
              },
            ),
          ),
        ),
      );
      final ink = await pixelAt(tester, inkPointOf(tester, 'home'));
      final surface = await pixelAt(
        tester,
        tester.getRect(find.text('home')).centerRight + const Offset(20, 0),
      );

      unawaited(
        BaseNavigator.push(
          home,
          const Scaffold(
            body: Align(alignment: Alignment(0, 0.5), child: Text('next')),
          ),
        ),
      );
      await expectHandOver(
        tester,
        ['home', 'next'],
        ink: ink,
        surface: surface,
        floor: 0.25,
      );
      expect(find.text('home'), findsNothing);

      Navigator.of(tester.element(find.text('next'))).pop();
      await expectHandOver(
        tester,
        ['home', 'next'],
        ink: ink,
        surface: surface,
        floor: 0.25,
      );
      expect(find.text('next'), findsNothing);
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
          child: MaterialApp(
            builder: (context, child) => wrapAppScopes(context, child!),
            home: Builder(
              builder: (context) => Scaffold(
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

    const page = Scaffold(body: Center(child: Text('pushed page')));

    for (final width in [400.0, 1400.0]) {
      testWidgets('pops after a long right drag at width $width', (
        tester,
      ) async {
        await openPage(tester, width, page);

        await tester.timedDrag(
          find.text('pushed page'),
          Offset(tester.getSize(find.byType(Scaffold).last).width * 0.7, 0),
          const Duration(seconds: 1),
        );
        await tester.pumpAndSettle();

        expect(find.text('pushed page'), findsNothing);
        expect(find.text('open'), findsOneWidget);
      });

      testWidgets('stays after a short slow right drag at width $width', (
        tester,
      ) async {
        await openPage(tester, width, page);

        await tester.timedDrag(
          find.text('pushed page'),
          const Offset(80, 0),
          const Duration(seconds: 1),
        );
        await tester.pumpAndSettle();

        expect(find.text('pushed page'), findsOneWidget);
        expect(tester.getTopLeft(find.byType(Scaffold).last), Offset.zero);
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
        Scaffold(
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
      final route = CommonDesktopRoute<void>(builder: (_) => const SizedBox());

      expect(route.barrierColor, isNull);
      expect(route.barrierLabel, isNull);
      expect(route.maintainState, isTrue);
      expect(route.transitionDuration, const Duration(milliseconds: 200));
      expect(
        route.reverseTransitionDuration,
        const Duration(milliseconds: 200),
      );
    });

    test('mobile route uses the longer shared-axis duration', () {
      final route = CommonRoute<void>(builder: (_) => const SizedBox());

      expect(route.barrierColor, isNull);
      expect(route.barrierLabel, isNull);
      expect(route.maintainState, isTrue);
      expect(route.transitionDuration, const Duration(milliseconds: 450));
      expect(
        route.reverseTransitionDuration,
        const Duration(milliseconds: 450),
      );
    });
  });
}
