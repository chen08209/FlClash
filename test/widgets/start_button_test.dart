import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/widgets/start_button.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('RunTimeText emphasizes the hundreds hour digit', (tester) async {
    const colorScheme = ColorScheme.light(
      primary: Color(0xFF6750A4),
      onPrimaryContainer: Color(0xFF21005D),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorScheme: colorScheme),
        home: const RunTimeText(timeStamp: 100 * 60 * 60 * 1000),
      ),
    );

    final text = tester.widget<Text>(
      find.descendant(
        of: find.byType(RunTimeText),
        matching: find.byType(Text),
      ),
    );
    final span = text.textSpan! as TextSpan;

    expect(span.toPlainText(), '100:00:00');
    expect(span.text, '1');
    expect(span.style?.color, colorScheme.primary);
    expect(span.style?.fontWeight, FontWeight.w600);
    expect(span.children, hasLength(1));
    expect(
      (span.children!.single as TextSpan).style?.color,
      colorScheme.onPrimaryContainer,
    );
  });

  testWidgets('RunTimeText uses one color below 100 hours', (tester) async {
    const colorScheme = ColorScheme.light(
      primary: Color(0xFF6750A4),
      onPrimaryContainer: Color(0xFF21005D),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorScheme: colorScheme),
        home: const RunTimeText(timeStamp: 99 * 60 * 60 * 1000),
      ),
    );

    final text = tester.widget<Text>(
      find.descendant(
        of: find.byType(RunTimeText),
        matching: find.byType(Text),
      ),
    );

    expect(text.data, '99:00:00');
    expect(text.style?.color, colorScheme.onPrimaryContainer);
  });

  testWidgets('StartButton animates its width when hours reach three digits', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWithValue([
          const Profile(id: 1, autoUpdateDuration: Duration.zero),
        ]),
        suspendProvider.overrideWithValue(false),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(runTimeProvider.notifier).value = 99 * 60 * 60 * 1000;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          includeNavigatorKey: false,
          setTheme: false,
          homeBuilder: (child) => Scaffold(floatingActionButton: child),
          child: const StartButton(),
        ),
      ),
    );
    await tester.pump();

    final button = find.byType(FloatingActionButton);
    expect(tester.getSize(button).height, 56);
    final twoDigitWidth = tester.getSize(button).width;

    container.read(runTimeProvider.notifier).value = 100 * 60 * 60 * 1000;
    await tester.pump();
    expect(tester.getSize(button).width, twoDigitWidth);

    await tester.pump(const Duration(milliseconds: 100));
    final animatedWidth = tester.getSize(button).width;
    expect(animatedWidth, greaterThan(twoDigitWidth));

    await tester.pumpAndSettle();
    expect(tester.getSize(button).width, greaterThan(animatedWidth));
  });

  testWidgets('StartButton resets its text after the close animation', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWithValue([
          const Profile(id: 1, autoUpdateDuration: Duration.zero),
        ]),
        suspendProvider.overrideWithValue(false),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(runTimeProvider.notifier).value = const Duration(
      hours: 100,
      minutes: 2,
      seconds: 3,
    ).inMilliseconds;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          includeNavigatorKey: false,
          setTheme: false,
          homeBuilder: (child) => Scaffold(floatingActionButton: child),
          child: const StartButton(),
        ),
      ),
    );
    await tester.pump();

    final button = find.byType(FloatingActionButton);
    String runTimeText() {
      final text = tester.widget<Text>(
        find.descendant(
          of: find.byType(RunTimeText),
          matching: find.byType(Text),
        ),
      );
      return text.data ?? text.textSpan!.toPlainText();
    }

    final expandedTextWidth = tester
        .widget<AnimatedContainer>(find.byType(AnimatedContainer))
        .constraints
        ?.maxWidth;
    final expandedButtonWidth = tester.getSize(button).width;
    expect(runTimeText(), '100:02:03');

    container.read(runTimeProvider.notifier).value = null;
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.getSize(button).width, greaterThan(expandedButtonWidth));
    expect(
      tester
          .widget<AnimatedContainer>(find.byType(AnimatedContainer))
          .constraints
          ?.maxWidth,
      expandedTextWidth,
    );
    expect(runTimeText(), '100:02:03');

    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.getSize(button).width, 56);
    expect(runTimeText(), '100:02:03');

    await tester.pumpAndSettle();

    expect(tester.getSize(button).width, 56);
    expect(runTimeText(), '00:00:00');
  });

  testWidgets('dispatches each toggle through the shared running state', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        initProvider.overrideWithBuild((_, _) => true),
        profilesProvider.overrideWithValue([
          const Profile(id: 1, autoUpdateDuration: Duration.zero),
        ]),
        setupActionProvider.overrideWith(_RecordingSetupAction.new),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(runTimeProvider.notifier).value = 1;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          includeNavigatorKey: false,
          setTheme: false,
          homeBuilder: (child) => Scaffold(floatingActionButton: child),
          child: const StartButton(),
        ),
      ),
    );

    final action =
        container.read(setupActionProvider.notifier) as _RecordingSetupAction;
    final button = find.byType(FloatingActionButton);

    await tester.tap(button);
    expect(action.requests, [false]);
    expect(container.read(isStartProvider), isFalse);

    await tester.tap(button);
    expect(action.requests, [false, true]);
    expect(container.read(isStartProvider), isTrue);
  });
}

class _RecordingSetupAction extends SetupAction {
  final requests = <bool>[];

  @override
  Future<void> setRunning(bool running, {bool initialize = false}) {
    requests.add(running);
    ref.read(runTimeProvider.notifier).value = running ? 1 : null;
    return Future.value();
  }
}
