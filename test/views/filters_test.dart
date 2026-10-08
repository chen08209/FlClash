import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/filters.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _MockCore extends Mock implements CoreHandlerInterface {}

void main() {
  late ProviderContainer container;
  late _MockCore core;

  setUpAll(() {
    registerFallbackValue(<String>[]);
  });

  List<Filter> saved() => container.read(appSettingProvider).filters;

  Finder dialogField(int index) => find
      .descendant(
        of: find.byType(CommonDialog),
        matching: find.byType(TextFormField),
      )
      .at(index);

  Future<void> pumpView(WidgetTester tester, {List<Filter>? filters}) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    core = _MockCore();
    when(() => core.validateFilters(any())).thenAnswer(
      (invocation) async => [
        for (final filter
            in invocation.positionalArguments.single as List<String>)
          filter.contains('(') ? 'missing closing )' : '',
      ],
    );
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(1000, 1600));
    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(filters: filters ?? defaultFilters));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: FiltersView()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> submit(WidgetTester tester, String label, String regex) async {
    await tester.enterText(dialogField(0), label);
    await tester.enterText(dialogField(1), regex);
    await tester.tap(find.text(currentAppLocalizations.confirm));
    await tester.pumpAndSettle();
  }

  testWidgets('lists the presets by their English labels', (tester) async {
    await pumpView(tester);

    for (final filter in defaultFilters) {
      expect(find.text(filter.label), findsOneWidget);
    }
    expect(saved(), defaultFilters);
  });

  testWidgets('adding saves the presets with the new filter after them', (
    tester,
  ) async {
    await pumpView(tester);

    await tester.tap(find.byTooltip(currentAppLocalizations.add));
    await tester.pumpAndSettle();
    await submit(tester, '  Asia  ', 'hk`jp');

    expect(saved(), [
      ...defaultFilters,
      const Filter(label: 'Asia', regex: 'hk`jp'),
    ]);
  });

  testWidgets('adding rejects a taken label and empty fields', (tester) async {
    await pumpView(tester);
    final taken = defaultFilters.first.label;

    await tester.tap(find.byTooltip(currentAppLocalizations.add));
    await tester.pumpAndSettle();
    await submit(tester, taken, 'x');
    expect(
      find.text(
        currentAppLocalizations.existsTip(currentAppLocalizations.label),
      ),
      findsOneWidget,
    );

    await submit(tester, ' ', ' ');
    expect(
      find.text(
        currentAppLocalizations.emptyTip(currentAppLocalizations.label),
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        currentAppLocalizations.emptyTip(currentAppLocalizations.regex),
      ),
      findsOneWidget,
    );
    expect(saved(), defaultFilters);
  });

  testWidgets('adding keeps the dialog open over what the core rejects', (
    tester,
  ) async {
    await pumpView(tester);

    await tester.tap(find.byTooltip(currentAppLocalizations.add));
    await tester.pumpAndSettle();
    await submit(tester, 'Broken', '(hk');

    expect(find.text('missing closing )'), findsOneWidget);
    expect(saved(), defaultFilters);
    verify(() => core.validateFilters(['(hk'])).called(1);

    await tester.enterText(dialogField(1), 'hk');
    await tester.pump();
    expect(find.text('missing closing )'), findsNothing);
    await tester.tap(find.text(currentAppLocalizations.confirm));
    await tester.pumpAndSettle();

    expect(saved().last, const Filter(label: 'Broken', regex: 'hk'));
  });

  testWidgets('editing keeps its own label and its place', (tester) async {
    await pumpView(
      tester,
      filters: const [
        Filter(label: 'A', regex: 'a'),
        Filter(label: 'B', regex: 'b'),
      ],
    );

    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();
    await submit(tester, 'A', 'a|aa');

    expect(saved(), const [
      Filter(label: 'A', regex: 'a|aa'),
      Filter(label: 'B', regex: 'b'),
    ]);
  });

  testWidgets('deleting the last filter saves an empty list', (tester) async {
    await pumpView(
      tester,
      filters: const [Filter(label: 'A', regex: 'a')],
    );

    await tester.tap(find.byType(CommonCheckBox));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(currentAppLocalizations.delete));
    await tester.pumpAndSettle();
    await tester.tap(find.text(currentAppLocalizations.confirm));
    await tester.pumpAndSettle();

    expect(saved(), isEmpty);
    expect(
      find.text(
        currentAppLocalizations.nullTip(currentAppLocalizations.filters),
      ),
      findsOneWidget,
    );
  });
}
