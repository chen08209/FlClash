import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/form/form.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/views/config/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../helpers/app_paths.dart';
import '../helpers/context_menu.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _MockCore extends Mock implements CoreHandlerInterface {}

class _TestClashProviders extends ClashProviders {
  _TestClashProviders(this.initial);

  final List<ClashProvider> initial;

  @override
  Stream<List<ClashProvider>> build() => Stream.value(initial);

  @override
  void order(int oldIndex, int newIndex) {}
}

class _RecordingClashProvidersAction extends ClashProvidersAction {
  final List<Profile> usedBy;
  final Exception? putFailure;
  final put = <ClashProvider>[];
  final refreshed = <ClashProvider>[];
  final deleted = <ClashProvider>[];

  _RecordingClashProvidersAction({this.usedBy = const [], this.putFailure});

  @override
  Future<ClashProvider> putProvider(
    ClashProvider provider, {
    ClashProvider? previous,
    List<int>? content,
    bool refresh = false,
  }) async {
    if (putFailure case final failure?) {
      throw failure;
    }
    put.add(provider);
    if (refresh) {
      refreshed.add(provider);
    }
    return provider;
  }

  @override
  void delProvider(ClashProvider provider) => deleted.add(provider);

  @override
  Future<List<Profile>> profilesUsing(ClashProvider provider) async => usedBy;
}

ProviderContainer _containerFor(
  WidgetTester tester, {
  List<Override> overrides = const [],
  List<Profile> profiles = const [],
}) {
  const size = Size(1400, 1000);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer(
    overrides: [
      profilesProvider.overrideWith(() => TestProfiles(profiles)),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  globalState.container = container;
  container.read(viewSizeProvider.notifier).update((_) => size);
  return container;
}

Finder _rowField(String title) => find.descendant(
  of: find.widgetWithText(FormRow, title),
  matching: find.byType(TextFormField),
);

Finder _formField(String title) => find.descendant(
  of: find.widgetWithText(FormRow, title),
  matching: find.byType(TextFormField),
);

void main() {
  late Directory home;

  setUpAll(() async {
    home = Directory.systemTemp.createTempSync('flclash-rule-sets-view-');
    await useAppPaths(home);
  });

  tearDownAll(() {
    if (home.existsSync()) home.deleteSync(recursive: true);
  });

  testWidgets('a rule set shows its behavior beside its name and when its file '
      'last changed at the end', (tester) async {
    const cached = ClashProvider(
      id: 31,
      label: 'Cached',
      url: 'https://example.com/cached.yaml',
    );
    final modified = DateTime.now().subtract(const Duration(hours: 3));
    await tester.runAsync(() async {
      final file = File(await appPath.getProviderCachePath(cached.fileName));
      await file.create(recursive: true);
      await file.writeAsString('payload: []');
      await file.setLastModified(modified);
    });
    final container = _containerFor(
      tester,
      overrides: [
        clashProvidersProvider.overrideWith(
          () => _TestClashProviders(const [cached]),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ClashProvidersView()),
      ),
    );
    for (var step = 0; step < 5; step++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }

    final updated = modified.getLastUpdateTimeDesc(
      tester.element(find.text('Cached')),
      compact: true,
    );
    expect(find.text(updated), findsOneWidget);
    expect(find.widgetWithText(TonalChip, 'classical'), findsOneWidget);
  });

  const appRules = ClashProvider(
    id: 2,
    label: 'Ad block',
    url: 'https://example.com/ads.yaml',
    behavior: RuleProviderBehavior.domain,
    format: RuleProviderFormat.mrs,
  );

  testWidgets('a url import rejects a name another rule set has', (
    tester,
  ) async {
    final action = _RecordingClashProvidersAction();
    final container = _containerFor(
      tester,
      overrides: [
        clashProvidersProvider.overrideWith(
          () => _TestClashProviders([appRules]),
        ),
        clashProvidersActionProvider.overrideWith(() => action),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ClashProvidersView()),
      ),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Import from URL'));
    await tester.pumpAndSettle();

    await tester.enterText(_formField('Name'), 'Ad block');
    await tester.enterText(_formField('URL'), 'https://example.com/more.yaml');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(action.put, isEmpty);

    await tester.enterText(_formField('Name'), 'Extra rules');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(action.put.single.label, 'Extra rules');
    expect(action.put.single.url, 'https://example.com/more.yaml');
  });

  testWidgets('a url import without a name takes it from the url and asks '
      'nothing more', (tester) async {
    final action = _RecordingClashProvidersAction();
    final container = _containerFor(
      tester,
      overrides: [
        clashProvidersProvider.overrideWith(
          () => _TestClashProviders(const []),
        ),
        clashProvidersActionProvider.overrideWith(() => action),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ClashProvidersView()),
      ),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Import from URL'));
    await tester.pumpAndSettle();

    await tester.enterText(_formField('URL'), 'https://example.com/ads.list');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(find.text('Behavior'), findsNothing);
    expect(action.put.single.label, 'ads');
    expect(action.put.single.url, 'https://example.com/ads.list');
  });

  testWidgets('a batch url import skips known urls and names each set apart', (
    tester,
  ) async {
    final action = _RecordingClashProvidersAction();
    final container = _containerFor(
      tester,
      overrides: [
        clashProvidersProvider.overrideWith(
          () => _TestClashProviders([appRules]),
        ),
        clashProvidersActionProvider.overrideWith(() => action),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ClashProvidersView()),
      ),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Import from URL'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Batch import'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField),
      'https://example.com/ads.yaml\n'
      'https://a.example/cn.list\n'
      'https://b.example/cn.list',
    );
    await tester.pump();
    expect(find.text('2 to add, 1 skipped as existing'), findsOneWidget);
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(action.put.map((provider) => (provider.label, provider.url)), [
      ('cn', 'https://a.example/cn.list'),
      ('cn(1)', 'https://b.example/cn.list'),
    ]);
  });

  testWidgets('a rule set the Core cannot read says why and is not saved', (
    tester,
  ) async {
    final action = _RecordingClashProvidersAction(
      putFailure: const CoreMethodException(
        code: 'rule_set_mixed',
        message: 'rule set mixes domains and IP ranges',
      ),
    );
    final container = _containerFor(
      tester,
      overrides: [
        clashProvidersProvider.overrideWith(
          () => _TestClashProviders(const []),
        ),
        clashProvidersActionProvider.overrideWith(() => action),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ClashProvidersView()),
      ),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Import from URL'));
    await tester.pumpAndSettle();
    await tester.enterText(_formField('URL'), 'https://example.com/mixed.list');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'The rule set mixes domains and IP ranges, so its type cannot be told',
      ),
      findsOneWidget,
    );
    expect(action.put, isEmpty);
  });

  testWidgets('a local provider offers the editor and keeps the url out of '
      'its options', (tester) async {
    const local = ClashProvider(
      id: 3,
      label: 'Local list',
      behavior: RuleProviderBehavior.classical,
      format: RuleProviderFormat.yaml,
    );
    final container = _containerFor(
      tester,
      overrides: [
        clashProvidersProvider.overrideWith(
          () => _TestClashProviders(const [local]),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ClashProvidersView()),
      ),
    );
    await tester.pump();

    expect(find.text('classical'), findsOneWidget);
    expect(find.text('Local'), findsOneWidget);

    await rightClick(tester, find.byType(DecorationListItem));
    await tester.pumpAndSettle();
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Sync'), findsNothing);

    await tester.tap(find.text('Options'));
    await tester.pumpAndSettle();

    expect(_rowField('Name'), findsOneWidget);
    expect(_rowField('URL'), findsNothing);
    expect(find.text('Behavior'), findsNothing);
    expect(find.text('Format'), findsNothing);
  });

  testWidgets('a remote rule set syncs through the action', (tester) async {
    final action = _RecordingClashProvidersAction();
    final container = _containerFor(
      tester,
      overrides: [
        clashProvidersProvider.overrideWith(
          () => _TestClashProviders([appRules]),
        ),
        clashProvidersActionProvider.overrideWith(() => action),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ClashProvidersView()),
      ),
    );
    await tester.pump();

    expect(find.text('domain'), findsOneWidget);
    expect(find.text('Remote'), findsOneWidget);
    expect(find.textContaining(appRules.url), findsNothing);
    await rightClick(tester, find.byType(DecorationListItem));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sync'));
    await tester.pumpAndSettle();

    expect(action.refreshed, [appRules]);
  });

  testWidgets('a remote rule set previews read-only on a tap', (tester) async {
    final core = _MockCore();
    when(() => core.dumpRuleSet(any())).thenAnswer((_) async => 'payload: []');
    final container = _containerFor(
      tester,
      overrides: [
        clashProvidersProvider.overrideWith(
          () => _TestClashProviders([appRules]),
        ),
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ClashProvidersView()),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Ad block'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.widget<EditorPage>(find.byType(EditorPage)).onSave, isNull);
  });

  testWidgets('the options of a remote rule set edit only its name and url', (
    tester,
  ) async {
    final action = _RecordingClashProvidersAction();
    final container = _containerFor(
      tester,
      overrides: [
        clashProvidersProvider.overrideWith(
          () => _TestClashProviders([appRules]),
        ),
        clashProvidersActionProvider.overrideWith(() => action),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ClashProvidersView()),
      ),
    );
    await tester.pump();

    await rightClick(tester, find.byType(DecorationListItem));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Options'));
    await tester.pumpAndSettle();
    expect(find.text('Behavior'), findsNothing);
    expect(find.text('Format'), findsNothing);

    await tester.enterText(_rowField('URL'), 'https://example.com/ads.list');
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();

    expect(
      action.put.single,
      appRules.copyWith(url: 'https://example.com/ads.list'),
    );
  });

  testWidgets('deleting a provider goes through the action after confirming', (
    tester,
  ) async {
    final action = _RecordingClashProvidersAction();
    final container = _containerFor(
      tester,
      overrides: [
        clashProvidersProvider.overrideWith(
          () => _TestClashProviders([appRules]),
        ),
        clashProvidersActionProvider.overrideWith(() => action),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ClashProvidersView()),
      ),
    );
    await tester.pump();

    await rightClick(tester, find.byType(DecorationListItem));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(action.deleted, [appRules]);
  });

  testWidgets(
    'a provider a custom profile still uses is deleted once confirmed',
    (tester) async {
      final action = _RecordingClashProvidersAction(
        usedBy: [Profile.normal(label: 'Work')],
      );
      final container = _containerFor(
        tester,
        overrides: [
          clashProvidersProvider.overrideWith(
            () => _TestClashProviders([appRules]),
          ),
          clashProvidersActionProvider.overrideWith(() => action),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(child: ClashProvidersView()),
        ),
      );
      await tester.pump();

      await rightClick(tester, find.byType(DecorationListItem));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.textContaining('used by Work'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(action.deleted, [appRules]);
    },
  );
}
