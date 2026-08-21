import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/overwrite/overwrite.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

const _group = ProxyGroup(id: 1, name: 'g', type: GroupType.Selector);

class _ProbeForm extends ConsumerWidget {
  const _ProbeForm();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBottomSheet =
        SheetProvider.of(context)?.type == SheetType.bottomSheet;
    final name = ref.watch(proxyGroupProvider.select((state) => state.name));
    final height = isBottomSheet
        ? ref.read(viewSizeProvider).height * 0.6
        : double.maxFinite;
    return AdaptiveSheetScaffold(
      sheetTransparentToolBar: true,
      body: Container(
        constraints: BoxConstraints(maxHeight: height),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            for (var index = 0; index < 8; index++)
              ListTile(title: Text('row $index')),
            Text(name),
            FilledButton(
              onPressed: () {
                ref.read(proxyGroupProvider.notifier).update((state) {
                  return state.copyWith(name: 'changed');
                });
              },
              child: const Text('mutate'),
            ),
          ],
        ),
      ),
      title: 'Form',
    );
  }
}

class _NestedSheetHarness {
  int saveCalls = 0;
  late final ProviderContainer container;

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    container = ProviderContainer(
      overrides: [
        viewSizeProvider.overrideWithBuild((_, _) => const Size(1400, 1000)),
        proxyGroupProvider.overrideWithBuild((_, _) => _group),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Builder(
            builder: (context) {
              return FilledButton(
                onPressed: () {
                  showSheet(
                    context: context,
                    props: const SheetProps(
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      maxWidth: double.maxFinite,
                    ),
                    builder: (_) => OverwriteNestedSheet<ProxyGroup>(
                      currentOf: (ref) => ref.read(proxyGroupProvider),
                      save: (context, ref) {
                        saveCalls++;
                        return true;
                      },
                      formBuilder: (_) => const _ProbeForm(),
                    ),
                  );
                },
                child: const Text('open'),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> closeBySystemBack(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets('closing without changes pops without saving', (tester) async {
    final harness = _NestedSheetHarness();
    await harness.pump(tester);

    expect(find.byType(OverwriteNestedSheet<ProxyGroup>), findsOneWidget);

    await harness.closeBySystemBack(tester);

    expect(harness.saveCalls, 0);
    expect(find.byType(OverwriteNestedSheet<ProxyGroup>), findsNothing);
  });

  testWidgets('closing with changes saves after confirmation', (tester) async {
    final harness = _NestedSheetHarness();
    await harness.pump(tester);

    await tester.ensureVisible(find.text('mutate'));
    await tester.tap(find.text('mutate'));
    await tester.pump();
    await harness.closeBySystemBack(tester);

    expect(find.text(AppLocalizations.current.dataChangedSave), findsOneWidget);
    await tester.tap(find.text(AppLocalizations.current.confirm));
    await tester.pumpAndSettle();

    expect(harness.saveCalls, 1);
    expect(find.byType(OverwriteNestedSheet<ProxyGroup>), findsNothing);
  });

  testWidgets('closing with changes discards when the user cancels', (
    tester,
  ) async {
    final harness = _NestedSheetHarness();
    await harness.pump(tester);

    await tester.ensureVisible(find.text('mutate'));
    await tester.tap(find.text('mutate'));
    await tester.pump();
    await harness.closeBySystemBack(tester);

    expect(find.text(AppLocalizations.current.dataChangedSave), findsOneWidget);
    await tester.tap(find.text(AppLocalizations.current.cancel));
    await tester.pumpAndSettle();

    expect(harness.saveCalls, 0);
    expect(find.byType(OverwriteNestedSheet<ProxyGroup>), findsNothing);
  });
}
