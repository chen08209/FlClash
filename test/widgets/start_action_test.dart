import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/widgets/start_action.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  Future<ProviderContainer> pumpButton(
    WidgetTester tester, {
    bool hasProfile = true,
    bool running = false,
    bool suspended = false,
    bool floating = false,
  }) async {
    final container = ProviderContainer(
      overrides: [
        initProvider.overrideWithBuild((_, _) => true),
        profilesProvider.overrideWithValue([
          if (hasProfile)
            const Profile(id: 1, autoUpdateDuration: Duration.zero),
        ]),
        suspendProvider.overrideWithValue(suspended),
        setupActionProvider.overrideWith(_RecordingSetupAction.new),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(runTimeProvider.notifier).value = running ? 1 : null;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          includeNavigatorKey: false,
          setTheme: false,
          child: CommonScaffold(
            title: 'Dashboard',
            actionInBar: false,
            actions: [if (!floating) const StartAction()],
            floatingActionButton: floating
                ? const StartAction(floating: true)
                : null,
            body: const SizedBox.expand(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets(
    'start and pause stay in the title bar without a floating button',
    (tester) async {
      final container = await pumpButton(tester);
      final context = tester.element(find.byType(StartAction));
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.byTooltip(context.appLocalizations.start), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byType(StartAction),
        ),
        findsOneWidget,
      );
      final button = find.descendant(
        of: find.byType(StartAction),
        matching: find.byType(IconButton),
      );
      expect(tester.getSize(button).width, TonalButtonSize.bar.button);
      final action =
          container.read(setupActionProvider.notifier) as _RecordingSetupAction;
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(action.requests, [true]);
      expect(find.byTooltip(context.appLocalizations.stop), findsOneWidget);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(action.requests, [true, false]);
      expect(find.byTooltip(context.appLocalizations.start), findsOneWidget);
    },
  );

  testWidgets('floating start action retains start and pause callbacks', (
    tester,
  ) async {
    final container = await pumpButton(tester, floating: true);
    final action =
        container.read(setupActionProvider.notifier) as _RecordingSetupAction;
    final button = find.byType(FloatingActionButton);
    expect(button, findsOneWidget);
    await tester.tap(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(action.requests, [true, false]);
  });

  testWidgets('no imported profiles hides the start action', (tester) async {
    await pumpButton(tester, hasProfile: false);
    expect(find.byType(IconButton), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('suspended service still exposes pause in the title bar', (
    tester,
  ) async {
    await pumpButton(tester, running: true, suspended: true);
    final context = tester.element(find.byType(StartAction));
    expect(find.byTooltip(context.appLocalizations.stop), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
  });
}

class _RecordingSetupAction extends SetupAction {
  final requests = <bool>[];

  @override
  Future<bool> setRunning(bool running, {bool initialize = false}) {
    requests.add(running);
    ref.read(runTimeProvider.notifier).value = running ? 1 : null;
    return Future.value(true);
  }
}
