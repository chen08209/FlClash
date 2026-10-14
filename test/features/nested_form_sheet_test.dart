import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/form/form.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

const _group = ProxyGroup(id: 1, name: 'g', type: GroupType.Selector);

class _ProbeForm extends ConsumerStatefulWidget {
  final void Function(BuildContext context) onSave;

  const _ProbeForm({required this.onSave});

  @override
  ConsumerState<_ProbeForm> createState() => _ProbeFormState();
}

class _ProbeFormState extends ConsumerState<_ProbeForm> {
  @override
  void initState() {
    super.initState();
    NestedFormSheet.bindSave(context, () => widget.onSave(context));
  }

  @override
  Widget build(BuildContext context) {
    final isBottomSheet =
        SheetProvider.of(context)?.type == SheetType.bottomSheet;
    final name = ref.watch(proxyGroupProvider.select((state) => state.name));
    final height = isBottomSheet
        ? ref.read(viewSizeProvider).height * 0.6
        : double.maxFinite;
    return CommonScaffold(
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
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  PagedSheetRoute(
                    builder: (_) => const Center(child: Text('nested page')),
                  ),
                );
              },
              child: const Text('open nested'),
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
  bool saves = true;
  late final ProviderContainer container;

  Future<void> pump(
    WidgetTester tester, {
    Size size = const Size(1400, 1000),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    container = ProviderContainer(
      overrides: [
        viewSizeProvider.overrideWithBuild((_, _) => size),
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
                    props: nestedPagedSheetProps,
                    builder: (_) => NestedFormSheet<ProxyGroup>(
                      currentOf: (ref) => ref.read(proxyGroupProvider),
                      formBuilder: (_) => _ProbeForm(
                        onSave: (context) {
                          saveCalls++;
                          if (saves) {
                            context.safeNestedPop();
                          }
                        },
                      ),
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

  Future<void> mutate(WidgetTester tester) async {
    await tester.ensureVisible(find.text('mutate'));
    await tester.tap(find.text('mutate'));
    await tester.pump();
  }
}

void main() {
  testWidgets('closing without changes pops without saving', (tester) async {
    final harness = _NestedSheetHarness();
    await harness.pump(tester);

    expect(find.byType(NestedFormSheet<ProxyGroup>), findsOneWidget);

    await harness.closeBySystemBack(tester);

    expect(harness.saveCalls, 0);
    expect(find.byType(NestedFormSheet<ProxyGroup>), findsNothing);
  });

  testWidgets('system back pops a nested page before closing the sheet', (
    tester,
  ) async {
    final harness = _NestedSheetHarness();
    await harness.pump(tester);

    await tester.ensureVisible(find.text('open nested'));
    await tester.tap(find.text('open nested'));
    await tester.pumpAndSettle();

    expect(find.text('nested page'), findsOneWidget);

    await harness.closeBySystemBack(tester);

    expect(find.text('nested page'), findsNothing);
    expect(find.byType(NestedFormSheet<ProxyGroup>), findsOneWidget);
    expect(harness.saveCalls, 0);
  });

  testWidgets('closing with changes asks before saving them', (tester) async {
    final harness = _NestedSheetHarness();
    await harness.pump(tester);
    final l = AppLocalizations.current;

    await harness.mutate(tester);
    await harness.closeBySystemBack(tester);

    expect(find.text(l.saveChanges), findsOneWidget);
    expect(harness.saveCalls, 0);

    await tester.tap(find.text(l.confirm));
    await tester.pumpAndSettle();

    expect(harness.saveCalls, 1);
    expect(find.byType(NestedFormSheet<ProxyGroup>), findsNothing);
  });

  testWidgets('declining the save closes without saving', (tester) async {
    final harness = _NestedSheetHarness();
    await harness.pump(tester);
    final l = AppLocalizations.current;

    await harness.mutate(tester);
    await tester.tap(find.byTooltip(l.close));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.cancel));
    await tester.pumpAndSettle();

    expect(harness.saveCalls, 0);
    expect(find.byType(NestedFormSheet<ProxyGroup>), findsNothing);
  });

  testWidgets('dismissing the save prompt keeps the form open', (tester) async {
    final harness = _NestedSheetHarness();
    await harness.pump(tester);
    final l = AppLocalizations.current;

    await harness.mutate(tester);
    await harness.closeBySystemBack(tester);
    expect(find.text(l.saveChanges), findsOneWidget);

    await harness.closeBySystemBack(tester);

    expect(find.byType(CommonDialog), findsNothing);
    expect(harness.saveCalls, 0);
    expect(find.byType(NestedFormSheet<ProxyGroup>), findsOneWidget);
  });

  testWidgets('a tap outside a nested page with changes asks only to save', (
    tester,
  ) async {
    final harness = _NestedSheetHarness();
    await harness.pump(tester, size: const Size(400, 800));
    final l = AppLocalizations.current;

    harness.container
        .read(proxyGroupProvider.notifier)
        .update((state) => state.copyWith(name: 'changed'));
    unawaited(
      Navigator.of(
        tester.element(find.text('row 0')),
      ).push(PagedSheetRoute(builder: (_) => const Text('nested page'))),
    );
    await tester.pumpAndSettle();
    expect(find.text('nested page'), findsOneWidget);
    await tester.tapAt(const Offset(200, 40));
    await tester.pumpAndSettle();

    expect(find.text(l.confirmExitWindow), findsNothing);
    expect(find.text(l.saveChanges), findsOneWidget);
  });

  testWidgets('a save that fails keeps the form open without more prompts', (
    tester,
  ) async {
    final harness = _NestedSheetHarness()..saves = false;
    await harness.pump(tester);
    final l = AppLocalizations.current;

    await harness.mutate(tester);
    await harness.closeBySystemBack(tester);
    await tester.tap(find.text(l.confirm));
    await tester.pumpAndSettle();

    expect(harness.saveCalls, 1);
    expect(find.byType(CommonDialog), findsNothing);
    expect(find.byType(NestedFormSheet<ProxyGroup>), findsOneWidget);
  });
}
