import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/widgets/start_button.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

void main() {
  testWidgets('RunTimeText styles every hour digit alike', (tester) async {
    const colorScheme = ColorScheme.light(
      primary: Color(0xFF6750A4),
      onPrimaryContainer: Color(0xFF21005D),
    );
    for (final (hours, expected) in [(99, '99:00:00'), (100, '100:00:00')]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(colorScheme: colorScheme),
          home: RunTimeText(timeStamp: hours * 60 * 60 * 1000),
        ),
      );

      final text = tester.widget<Text>(
        find.descendant(
          of: find.byType(RunTimeText),
          matching: find.byType(Text),
        ),
      );

      expect(text.data, expected);
      expect(text.textSpan, isNull);
      expect(text.style?.color, colorScheme.onPrimaryContainer);
      expect(
        text.style?.fontFeatures,
        contains(const FontFeature.tabularFigures()),
      );
    }
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
  group('docked', () {
    Future<ProviderContainer> pumpDocked(
      WidgetTester tester, {
      bool suspend = false,
    }) async {
      final container = ProviderContainer(
        overrides: [
          profilesProvider.overrideWithValue([
            const Profile(id: 1, autoUpdateDuration: Duration.zero),
          ]),
          suspendProvider.overrideWithValue(suspend),
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
            homeBuilder: (child) => Scaffold(
              body: Align(alignment: .bottomCenter, child: child),
            ),
            child: NavigationDock(
              destinations: const [
                NavigationDockDestination(
                  glyph: AppGlyphs.dashboard,
                  label: 'a',
                ),
                NavigationDockDestination(glyph: AppGlyphs.tools, label: 'b'),
              ],
              selectedIndex: 0,
              onSelected: (_) {},
              trailing: const StartButton(),
            ),
          ),
        ),
      );
      await tester.pump();
      return container;
    }

    testWidgets('swaps in the Wi-Fi off glyph and a tooltip when suspended', (
      tester,
    ) async {
      await pumpDocked(tester, suspend: true);
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(StartButton));
      expect(
        tester
            .widget<FloatingActionButton>(find.byType(FloatingActionButton))
            .tooltip,
        context.appLocalizations.suspended,
      );
      expect(find.byGlyph(AppGlyphs.wifiOff), findsOneWidget);
    });

    testWidgets('keeps the pause glyph while running normally', (tester) async {
      await pumpDocked(tester);

      expect(
        tester
            .widget<FloatingActionButton>(find.byType(FloatingActionButton))
            .tooltip,
        isNull,
      );
      expect(find.byGlyph(AppGlyphs.wifiOff), findsNothing);
    });
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
