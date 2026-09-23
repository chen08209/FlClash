import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/overwrite/overwrite.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

const _group = ProxyGroup(id: 1, name: 'g', type: GroupType.Selector);

int _applyCalls = 0;

class _StageFlowProbe extends ConsumerStatefulWidget {
  const _StageFlowProbe();

  @override
  ConsumerState<_StageFlowProbe> createState() => _StageFlowProbeState();
}

class _StageFlowProbeState extends ConsumerState<_StageFlowProbe>
    with OverwriteStageFlowMixin<_StageFlowProbe> {
  @override
  String get key => 'stage_probe';

  @override
  void initState() {
    super.initState();
    listenForStageChanges(
      tag: 'apply',
      apply: (state, staged) {
        _applyCalls++;
        return state.copyWith(proxies: [...state.proxies ?? [], ...staged]);
      },
    );
    listenForStageChanges(
      tag: 'apply_scene',
      scene: 'scene',
      apply: (state, staged) {
        return state.copyWith(proxies: [...state.proxies ?? [], ...staged]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FilledButton(
          onPressed: () => handleStage('A'),
          child: const Text('stage'),
        ),
        FilledButton(
          onPressed: () => handleStage('B', 'scene'),
          child: const Text('stage scene'),
        ),
        FilledButton(
          onPressed: () {
            handleStage('C');
            handleRealStage(
              tag: 'apply',
              apply: (state, staged) {
                return state.copyWith(
                  proxies: [...state.proxies ?? [], ...staged],
                );
              },
            );
          },
          child: const Text('real'),
        ),
      ],
    );
  }
}

void main() {
  Future<ProviderContainer> pumpProbe(WidgetTester tester) async {
    _applyCalls = 0;
    final container = ProviderContainer(
      overrides: [proxyGroupProvider.overrideWithBuild((_, _) => _group)],
    );
    addTearDown(container.dispose);
    container.listen(proxyGroupProvider, (_, _) {});
    container.listen(itemsProvider('stage_probe_scene'), (_, _) {});
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: _StageFlowProbe()),
      ),
    );
    await tester.pump();
    return container;
  }

  testWidgets(
    'handleStage applies the staged items after the debounce and clears the stage',
    (tester) async {
      final container = await pumpProbe(tester);

      await tester.tap(find.text('stage'));
      await tester.pump();
      expect(container.read(itemsProvider('stage_probe')), {'A'});
      expect(container.read(proxyGroupProvider).proxies, isNull);

      await tester.pump(const Duration(milliseconds: 500));
      expect(container.read(proxyGroupProvider).proxies, ['A']);
      expect(container.read(itemsProvider('stage_probe')), isEmpty);

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('scene-scoped staging uses a separate stage key', (tester) async {
    final container = await pumpProbe(tester);

    await tester.tap(find.text('stage scene'));
    await tester.pump();
    expect(container.read(itemsProvider('stage_probe_scene')), {'B'});
    expect(container.read(itemsProvider('stage_probe')), isEmpty);

    await tester.pump(const Duration(milliseconds: 500));
    expect(container.read(proxyGroupProvider).proxies, ['B']);
    expect(container.read(itemsProvider('stage_probe_scene')), isEmpty);

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('handleRealStage applies the staged items and clears the stage', (
    tester,
  ) async {
    final container = await pumpProbe(tester);

    await tester.tap(find.text('real'));
    await tester.pump();
    expect(container.read(itemsProvider('stage_probe')), {'C'});

    await tester.pump(const Duration(milliseconds: 500));
    expect(container.read(proxyGroupProvider).proxies, ['C']);
    expect(container.read(itemsProvider('stage_probe')), isEmpty);

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('clearing the stage does not schedule a second apply', (
    tester,
  ) async {
    await pumpProbe(tester);

    await tester.tap(find.text('stage'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(_applyCalls, 1);

    await tester.pump(const Duration(milliseconds: 500));
    expect(_applyCalls, 1);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('staged items are settled when the widget leaves the tree', (
    tester,
  ) async {
    final container = await pumpProbe(tester);

    await tester.tap(find.text('stage'));
    await tester.pump();
    expect(container.read(proxyGroupProvider).proxies, isNull);

    await tester.pumpWidget(const SizedBox.shrink());

    expect(container.read(proxyGroupProvider).proxies, ['A']);

    await tester.pump(const Duration(milliseconds: 500));
    expect(_applyCalls, 1);
  });
}
