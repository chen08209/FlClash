import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/widgets/outbound_mode.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(1200, 1000);
  });

  tearDown(() => container.dispose());

  Widget neighbor(String label) {
    return SizedBox(
      height: 80,
      child: CommonCard(onPressed: () {}, child: Text(label)),
    );
  }

  Future<void> pumpDashboard(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(
            body: FocusTraversalGroup(
              policy: PageTraversalPolicy(),
              child: PageFocusScope(
                child: Column(
                  children: [
                    neighbor('above'),
                    Row(
                      children: [
                        Expanded(child: neighbor('left')),
                        const Expanded(child: OutboundMode()),
                        Expanded(child: neighbor('right')),
                      ],
                    ),
                    neighbor('below'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  String? focusedLabel() {
    final context = FocusManager.instance.primaryFocus?.context;
    if (context == null) {
      return null;
    }
    final texts = find
        .descendant(
          of: find.byWidget(context.widget),
          matching: find.byType(Text),
        )
        .evaluate()
        .map((element) => (element.widget as Text).data)
        .whereType<String>()
        .toList();
    if (texts.isEmpty) {
      return '<unlabelled ${context.widget.runtimeType}>';
    }
    return texts.length == 1 ? texts.single : texts.join('+');
  }

  Future<void> focusNeighbor(WidgetTester tester, String label) async {
    for (var i = 0; i < 12 && focusedLabel() != label; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    }
    expect(focusedLabel(), label, reason: 'seed focus on the $label card');
  }

  Future<List<String?>> walk(
    WidgetTester tester,
    LogicalKeyboardKey key, {
    int steps = 6,
  }) async {
    final trail = <String?>[];
    for (var i = 0; i < steps; i++) {
      await tester.sendKeyEvent(key);
      await tester.pump();
      trail.add(focusedLabel());
    }
    return trail;
  }

  testWidgets('arrow down walks every mode and leaves the card', (
    tester,
  ) async {
    await pumpDashboard(tester);
    await focusNeighbor(tester, 'above');

    final trail = await walk(tester, LogicalKeyboardKey.arrowDown);

    expect(
      trail.take(4),
      <String>['Rule', 'Global', 'Direct', 'below'],
      reason:
          'arrow down should step through the modes without the card itself '
          'taking a turn, got $trail',
    );
  });

  testWidgets('arrow right enters a mode row and leaves through it', (
    tester,
  ) async {
    await pumpDashboard(tester);
    await focusNeighbor(tester, 'left');

    final trail = await walk(tester, LogicalKeyboardKey.arrowRight, steps: 3);

    expect(
      trail.first,
      anyOf('Rule', 'Global', 'Direct'),
      reason: 'arrow right should land on a mode row, got $trail',
    );
    expect(
      trail,
      contains('right'),
      reason: 'arrow right must keep going past the card, got $trail',
    );
  });

  testWidgets('navigating the card does not change the mode', (tester) async {
    await pumpDashboard(tester);
    await focusNeighbor(tester, 'left');

    final modes = <Mode>[];
    for (final key in <LogicalKeyboardKey>[
      LogicalKeyboardKey.arrowRight,
      LogicalKeyboardKey.arrowDown,
      LogicalKeyboardKey.arrowDown,
      LogicalKeyboardKey.arrowUp,
      LogicalKeyboardKey.arrowLeft,
      LogicalKeyboardKey.arrowRight,
    ]) {
      await tester.sendKeyEvent(key);
      await tester.pump();
      modes.add(container.read(patchClashConfigProvider).mode);
    }

    expect(
      modes,
      everyElement(Mode.rule),
      reason: 'arrow keys must move focus, never the selection',
    );
  });

  testWidgets('activating a mode row selects it', (tester) async {
    await pumpDashboard(tester);
    await focusNeighbor(tester, 'above');

    for (var i = 0; i < 6 && focusedLabel() != 'Global'; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
    }
    expect(focusedLabel(), 'Global');

    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();

    expect(container.read(patchClashConfigProvider).mode, Mode.global);
  });
}
