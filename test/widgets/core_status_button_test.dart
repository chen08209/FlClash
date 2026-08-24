import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/widgets/core_status_button.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets(
    'holds connecting for the minimum duration after a fast restart',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      globalState.container = container;
      container.read(coreStatusProvider.notifier).value = CoreStatus.connected;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(
            includeNavigatorKey: false,
            setTheme: false,
            homeBuilder: (child) => Scaffold(body: Center(child: child)),
            child: const CoreStatusButton(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byType(CommonCircleLoading), findsNothing);

      container.read(coreStatusProvider.notifier).value = CoreStatus.connecting;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(CommonCircleLoading), findsOneWidget);
      expect(find.byIcon(Icons.check), findsNothing);

      container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
      await tester.pump();
      expect(find.byType(CommonCircleLoading), findsOneWidget);
      expect(find.byIcon(Icons.check), findsNothing);

      await tester.pump(const Duration(milliseconds: 199));
      expect(find.byType(CommonCircleLoading), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byType(CommonCircleLoading), findsNothing);

      await tester.pump(const Duration(seconds: 1));
      expect(find.byIcon(Icons.check), findsOneWidget);
    },
  );

  testWidgets(
    'shows disconnected immediately when restart fails during the hold',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      globalState.container = container;
      container.read(coreStatusProvider.notifier).value = CoreStatus.connected;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(
            includeNavigatorKey: false,
            setTheme: false,
            homeBuilder: (child) => Scaffold(body: Center(child: child)),
            child: const CoreStatusButton(),
          ),
        ),
      );
      await tester.pump();

      container.read(coreStatusProvider.notifier).value = CoreStatus.connecting;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(CommonCircleLoading), findsOneWidget);

      container.read(coreStatusProvider.notifier).value =
          CoreStatus.disconnected;
      await tester.pump();
      expect(find.byIcon(Icons.restart_alt_sharp), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byIcon(Icons.restart_alt_sharp), findsOneWidget);
      expect(find.byType(CommonCircleLoading), findsNothing);

      await tester.pump(const Duration(seconds: 1));
      expect(find.byIcon(Icons.restart_alt_sharp), findsOneWidget);
      expect(find.byType(CommonCircleLoading), findsNothing);
    },
  );

  testWidgets('does not clip a connecting state longer than the hold', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          includeNavigatorKey: false,
          setTheme: false,
          homeBuilder: (child) => Scaffold(body: Center(child: child)),
          child: const CoreStatusButton(),
        ),
      ),
    );
    await tester.pump();

    container.read(coreStatusProvider.notifier).value = CoreStatus.connecting;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.byType(CommonCircleLoading), findsOneWidget);

    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.byType(CommonCircleLoading), findsNothing);

    await tester.pump(const Duration(seconds: 1));
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('holds connecting when restarting from disconnected', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          includeNavigatorKey: false,
          setTheme: false,
          homeBuilder: (child) => Scaffold(body: Center(child: child)),
          child: const CoreStatusButton(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.restart_alt_sharp), findsOneWidget);

    container.read(coreStatusProvider.notifier).value = CoreStatus.connecting;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(CommonCircleLoading), findsOneWidget);
    expect(find.byIcon(Icons.restart_alt_sharp), findsNothing);

    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
    await tester.pump();
    expect(find.byType(CommonCircleLoading), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 199));
    expect(find.byType(CommonCircleLoading), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.byType(CommonCircleLoading), findsNothing);

    await tester.pump(const Duration(seconds: 1));
    expect(find.byIcon(Icons.check), findsOneWidget);
  });
}
