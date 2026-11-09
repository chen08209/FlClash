import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_ui/loading.dart';
import '../helpers/test_app.dart';

void main() {
  Size loadingSize(WidgetTester tester) => tester.getSize(
    find.descendant(
      of: find.byType(ActivityIndicator),
      matching: find.byType(CustomPaint),
    ),
  );

  testWidgets('ActivityIndicator takes the ambient icon size', (tester) async {
    await tester.pumpWidget(
      const HostApp(
        home: Center(
          child: IconTheme(
            data: IconThemeData(size: 20),
            child: ActivityIndicator(),
          ),
        ),
      ),
    );

    expect(loadingSize(tester), const Size.square(20));
  });

  testWidgets('ActivityIndicator takes an explicit or page size', (
    tester,
  ) async {
    await tester.pumpWidget(
      const HostApp(
        home: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [ActivityIndicator(size: 16), ActivityIndicator.page()],
          ),
        ),
      ),
    );

    final sizes = tester
        .widgetList<ActivityIndicator>(find.byType(ActivityIndicator))
        .map((loading) => tester.getSize(find.byWidget(loading)));
    expect(sizes, [const Size.square(16), const Size.square(128)]);
  });

  testWidgets('ActivityIndicator.page stays under the illustration', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const HostApp(home: Center(child: ActivityIndicator.page())),
    );

    expect(loadingSize(tester), const Size.square(96));
  });

  testWidgets('ActivityIndicator fills a tight slot', (tester) async {
    await tester.pumpWidget(
      const HostApp(
        home: Center(
          child: SizedBox.square(
            dimension: 32,
            child: ActivityIndicator(size: 24),
          ),
        ),
      ),
    );

    expect(loadingSize(tester), const Size.square(32));
  });

  testWidgets('ActivityIndicator keeps turning until disposed', (tester) async {
    await tester.pumpWidget(
      const HostApp(home: Center(child: ActivityIndicator())),
    );
    await tester.pump(const Duration(milliseconds: 2500));

    expect(SchedulerBinding.instance.transientCallbackCount, 1);

    await tester.pumpWidget(const SizedBox.shrink());

    expect(SchedulerBinding.instance.transientCallbackCount, 0);
  });

  for (final disableAnimations in [false, true]) {
    testWidgets('ActivityIndicator paints a whole loop, '
        'disableAnimations: $disableAnimations', (tester) async {
      await tester.pumpWidget(
        HostApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: disableAnimations),
            child: const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ActivityIndicator(size: 12),
                  ActivityIndicator.page(),
                ],
              ),
            ),
          ),
        ),
      );
      for (var i = 0; i < 110; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('ActivityIndicator.page draws back in with its switcher', (
    tester,
  ) async {
    final presence = AnimationController(vsync: tester, value: 1);
    addTearDown(presence.dispose);
    await tester.pumpWidget(
      HostApp(
        home: Center(
          child: ActivityPresence(
            animation: presence,
            child: const ActivityIndicator.page(),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    presence.value = 0;
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(loadingSize(tester), const Size.square(128));
  });

  testWidgets('LoadingBar comes and goes without leaving a ticker', (
    tester,
  ) async {
    Widget bar(bool active) => HostApp(home: LoadingBar(active: active));
    Finder light() => find.descendant(
      of: find.byType(LoadingBar),
      matching: find.byType(CustomPaint),
    );

    await tester.pumpWidget(bar(false));
    expect(light(), findsNothing);
    expect(SchedulerBinding.instance.transientCallbackCount, 0);

    await tester.pumpWidget(bar(true));
    await tester.pump(const Duration(milliseconds: 500));
    expect(light(), findsOneWidget);

    await tester.pumpWidget(bar(false));
    await tester.pump(const Duration(milliseconds: 100));
    expect(light(), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 150));
    expect(light(), findsNothing);
    expect(SchedulerBinding.instance.transientCallbackCount, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ActivityIndicator exposes an optional label', (tester) async {
    await tester.pumpWidget(
      const HostApp(home: ActivityIndicator(semanticLabel: 'Loading profiles')),
    );

    expect(find.bySemanticsLabel('Loading profiles'), findsOneWidget);
  });
}
