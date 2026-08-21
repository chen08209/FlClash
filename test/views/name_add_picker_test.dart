import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/overwrite/custom/name_add_picker.dart';
import 'package:fl_clash/widgets/inherited.dart';
import 'package:fl_clash/widgets/sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

ProxyGroup _group({List<String>? proxies}) {
  return ProxyGroup(
    id: 100,
    profileId: 1,
    name: 'Group',
    type: GroupType.Selector,
    proxies: proxies,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUpAll(() async {
    await AppLocalizations.load(const Locale('en'));
  });

  ProviderContainer buildContainer(ProxyGroup group) {
    final built = ProviderContainer(
      overrides: [proxyGroupProvider.overrideWithBuild((_, _) => group)],
    );
    addTearDown(built.dispose);
    // `proxyGroupProvider` is auto-dispose and nothing in the picker watches it,
    // so without a listener each `read` below would rebuild it from the override
    // and drop what the staging flow wrote.
    built.listen(proxyGroupProvider, (_, _) {});
    globalState.container = built;
    built.read(viewSizeProvider.notifier).update((_) => const Size(1400, 1000));
    return built;
  }

  Future<void> pumpPicker(
    WidgetTester tester, {
    required List<NameAddSection> sections,
    List<String?> scenes = const [null],
  }) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: SheetProvider(
            type: SheetType.page,
            child: NameAddPicker(
              title: 'Add',
              stageTagPrefix: 'NameAddPickerTest',
              scenes: scenes,
              apply: (state, staged) =>
                  state.copyWith(proxies: [...state.proxies ?? [], ...staged]),
              sectionsBuilder: (_, _) => sections,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  /// The picker keys its staging sets off a `UniqueKeyStateMixin` key that only
  /// exists once the state is built. Both `itemsProvider` and `proxyGroupProvider`
  /// are auto-dispose, so the container has to hold them or a `read` after the
  /// flow runs would rebuild them and lose the write.
  String holdStageKey(
    WidgetTester tester, {
    List<String?> scenes = const [null],
  }) {
    final key =
        (tester.state(find.byType(NameAddPicker)) as dynamic).key as String;
    for (final scene in scenes) {
      container.listen(
        itemsProvider(scene == null ? key : '${key}_$scene'),
        (_, _) {},
      );
    }
    return key;
  }

  /// Clearing the stage re-triggers the listener, which arms one more debounce.
  /// It has to be drained or the binding reports a pending timer.
  Future<void> drainStaging(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpWidget(const SizedBox.shrink());
  }

  testWidgets('renders each section label with its entries', (tester) async {
    container = buildContainer(_group());

    await pumpPicker(
      tester,
      scenes: const ['a', 'b'],
      sections: const [
        NameAddSection(
          label: 'Section A',
          scene: 'a',
          entries: [NameAddEntry(title: 'alpha', subtitle: 'first')],
        ),
        NameAddSection(
          label: 'Section B',
          scene: 'b',
          entries: [NameAddEntry(title: 'beta')],
        ),
      ],
    );

    expect(find.text('Section A'), findsOneWidget);
    expect(find.text('Section B'), findsOneWidget);
    expect(find.text('alpha'), findsOneWidget);
    expect(find.text('first'), findsOneWidget);
    expect(find.text('beta'), findsOneWidget);
  });

  testWidgets('drops sections that have no entries', (tester) async {
    container = buildContainer(_group());

    await pumpPicker(
      tester,
      scenes: const ['a', 'b'],
      sections: const [
        NameAddSection(label: 'Empty', scene: 'a', entries: []),
        NameAddSection(
          label: 'Filled',
          scene: 'b',
          entries: [NameAddEntry(title: 'beta')],
        ),
      ],
    );

    expect(find.text('Empty'), findsNothing);
    expect(find.text('Filled'), findsOneWidget);
  });

  testWidgets('shows the no-data label only when every section is empty', (
    tester,
  ) async {
    container = buildContainer(_group());

    await pumpPicker(
      tester,
      scenes: const ['a'],
      sections: const [NameAddSection(label: 'Empty', scene: 'a', entries: [])],
    );

    expect(find.text(currentAppLocalizations.noData), findsOneWidget);
  });

  testWidgets(
    'a section still holding entries keeps the list even when its siblings '
    'are empty',
    (tester) async {
      container = buildContainer(_group());

      await pumpPicker(
        tester,
        scenes: const ['targets', 'proxies'],
        sections: const [
          NameAddSection(
            label: 'Targets',
            scene: 'targets',
            entries: [NameAddEntry(title: 'DIRECT')],
          ),
          NameAddSection(label: 'Proxies', scene: 'proxies', entries: []),
        ],
      );

      expect(find.text(currentAppLocalizations.noData), findsNothing);
      expect(find.text('DIRECT'), findsOneWidget);
    },
  );

  testWidgets('adding an entry stages it onto the proxy group', (tester) async {
    container = buildContainer(_group(proxies: ['existing']));

    await pumpPicker(
      tester,
      sections: const [
        NameAddSection(
          label: 'Section',
          entries: [NameAddEntry(title: 'alpha')],
        ),
      ],
    );

    holdStageKey(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    // The staging flow debounces before it writes through.
    await tester.pump(const Duration(milliseconds: 400));

    expect(container.read(proxyGroupProvider).proxies, ['existing', 'alpha']);

    await drainStaging(tester);
  });

  testWidgets('each scene stages independently', (tester) async {
    container = buildContainer(_group());

    await pumpPicker(
      tester,
      scenes: const ['a', 'b'],
      sections: const [
        NameAddSection(
          label: 'A',
          scene: 'a',
          entries: [NameAddEntry(title: 'alpha')],
        ),
        NameAddSection(
          label: 'B',
          scene: 'b',
          entries: [NameAddEntry(title: 'beta')],
        ),
      ],
    );

    holdStageKey(tester, scenes: const ['a', 'b']);

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(container.read(proxyGroupProvider).proxies, ['alpha']);

    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(container.read(proxyGroupProvider).proxies, ['alpha', 'beta']);

    await drainStaging(tester);
  });
}
