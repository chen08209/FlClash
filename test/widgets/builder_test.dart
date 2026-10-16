import 'package:fl_clash/ui/builder.dart';
import 'package:fl_clash/ui/inherited.dart';
import 'package:fl_clash/widgets/active_polling.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('TickBuilder rebuilds on the configured interval', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TickBuilder(
          duration: const Duration(seconds: 1),
          builder: (_, tick) => Text('tick: $tick'),
        ),
      ),
    );

    expect(find.text('tick: 0'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('tick: 1'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('tick: 2'), findsOneWidget);
  });

  testWidgets('TickBuilder ticks only while the page is active', (
    tester,
  ) async {
    Widget buildApp({required bool isPageActive}) {
      return MaterialApp(
        home: PageActivityScope(
          isActive: isPageActive,
          child: TickBuilder(
            duration: const Duration(seconds: 1),
            builder: (_, tick) => Text('tick: $tick'),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildApp(isPageActive: false));
    await tester.pump(const Duration(seconds: 3));

    expect(find.text('tick: 0'), findsOneWidget);

    await tester.pumpWidget(buildApp(isPageActive: true));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('tick: 1'), findsOneWidget);

    await tester.pumpWidget(buildApp(isPageActive: false));
    await tester.pump(const Duration(seconds: 3));

    expect(find.text('tick: 1'), findsOneWidget);
  });

  testWidgets('TickBuilder stops ticking while the app is paused', (
    tester,
  ) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(
      MaterialApp(
        home: TickBuilder(
          duration: const Duration(seconds: 1),
          builder: (_, tick) => Text('tick: $tick'),
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('tick: 1'), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 3));

    expect(find.text('tick: 1'), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(find.text('tick: 2'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('tick: 3'), findsOneWidget);
  });

  testWidgets('TickBuilder catches up when focus returns', (tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(
      MaterialApp(
        home: TickBuilder(
          duration: const Duration(minutes: 1),
          builder: (_, tick) => Text('tick: $tick'),
        ),
      ),
    );

    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(seconds: 40));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump(const Duration(seconds: 10));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
    }

    expect(find.text('tick: 4'), findsOneWidget);
  });

  testWidgets('WidthBuilder builds again only when its width changes', (
    tester,
  ) async {
    var builds = 0;
    final size = ValueNotifier(const Size(300, 400));
    addTearDown(size.dispose);
    final builder = WidthBuilder(
      builder: (_, width) {
        builds++;
        return Text('width: $width');
      },
    );
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: ValueListenableBuilder(
            valueListenable: size,
            builder: (_, size, child) =>
                SizedBox.fromSize(size: size, child: child),
            child: builder,
          ),
        ),
      ),
    );
    expect(builds, 1);

    for (final height in [420.0, 520.0, 600.0]) {
      size.value = Size(300, height);
      await tester.pump();
    }
    expect(builds, 1);

    size.value = const Size(320, 600);
    await tester.pump();
    expect(builds, 2);
    expect(find.text('width: 320.0'), findsOneWidget);
  });

  testWidgets('WidthBuilder follows what its builder depends on', (
    tester,
  ) async {
    final builder = WidthBuilder(
      builder: (context, _) =>
          Text('scale: ${MediaQuery.textScalerOf(context).scale(1)}'),
    );
    Widget app(double scale) => MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(scale)),
      child: Directionality(textDirection: TextDirection.ltr, child: builder),
    );

    await tester.pumpWidget(app(1));
    expect(find.text('scale: 1.0'), findsOneWidget);

    await tester.pumpWidget(app(1.5));
    expect(find.text('scale: 1.5'), findsOneWidget);
  });
}
