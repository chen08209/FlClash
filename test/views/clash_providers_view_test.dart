import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/providers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _TestClashProviders extends ClashProviders {
  _TestClashProviders(this.initial);

  final List<ClashProvider> initial;

  @override
  Stream<List<ClashProvider>> build(ProviderKind kind) =>
      Stream.value(initial.where((item) => item.kind == kind).toList());

  @override
  void order(int oldIndex, int newIndex) {}
}

class _RecordingClashProvidersAction extends ClashProvidersAction {
  final put = <ClashProvider>[];
  final deleted = <ClashProvider>[];

  @override
  void putProvider(ClashProvider provider, {ClashProvider? previous}) {
    put.add(provider);
  }

  @override
  void delProvider(ClashProvider provider) {
    deleted.add(provider);
  }
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

void main() {
  const appProxies = ClashProvider(
    id: 1,
    kind: ProviderKind.proxy,
    label: 'Shared nodes',
    url: 'https://example.com/nodes.yaml',
  );
  const appRules = ClashProvider(
    id: 2,
    kind: ProviderKind.rule,
    label: 'Ad block',
    url: 'https://example.com/ads.yaml',
    behavior: RuleProviderBehavior.domain,
    format: RuleProviderFormat.mrs,
  );

  testWidgets('the proxy providers view lists only its own kind', (
    tester,
  ) async {
    final profile = Profile.normal(label: 'Subscription');
    final container = _containerFor(
      tester,
      profiles: [profile],
      overrides: [
        clashProvidersProvider.overrideWith2(
          (_) => _TestClashProviders([appProxies, appRules]),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          child: ClashProvidersView(kind: ProviderKind.proxy),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Shared nodes'), findsOneWidget);
    expect(find.text('Ad block'), findsNothing);
    expect(find.text('Subscription'), findsNothing);
    expect(tester.takeException(), null);
  });

  testWidgets('a url import rejects a name a profile already uses', (
    tester,
  ) async {
    final profile = Profile.normal(label: 'Subscription');
    final action = _RecordingClashProvidersAction();
    final container = _containerFor(
      tester,
      profiles: [profile],
      overrides: [
        clashProvidersProvider.overrideWith2(
          (_) => _TestClashProviders([appProxies]),
        ),
        clashProvidersActionProvider.overrideWith(() => action),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          child: ClashProvidersView(kind: ProviderKind.proxy),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Import from URL'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name'),
      'Subscription',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'URL'),
      'https://example.com/more.yaml',
    );
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(action.put, isEmpty);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name'),
      'Extra nodes',
    );
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(action.put.single.label, 'Extra nodes');
    expect(action.put.single.url, 'https://example.com/more.yaml');
    expect(action.put.single.kind, ProviderKind.proxy);
  });

  testWidgets('a url import without a name takes both name and format from '
      'the url', (tester) async {
    final action = _RecordingClashProvidersAction();
    final container = _containerFor(
      tester,
      overrides: [
        clashProvidersProvider.overrideWith2(
          (_) => _TestClashProviders(const []),
        ),
        clashProvidersActionProvider.overrideWith(() => action),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          child: ClashProvidersView(kind: ProviderKind.rule),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Import from URL'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'URL'),
      'https://example.com/ads.list',
    );
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(action.put, isEmpty);
    await tester.tap(find.text('domain'));
    await tester.pumpAndSettle();

    expect(action.put.single.label, 'ads');
    expect(action.put.single.format, RuleProviderFormat.text);
    expect(action.put.single.behavior, RuleProviderBehavior.domain);
    expect(action.put.single.url, 'https://example.com/ads.list');
  });

  testWidgets('a local provider offers the editor and keeps the url out of '
      'its options', (tester) async {
    const local = ClashProvider(
      id: 3,
      kind: ProviderKind.rule,
      label: 'Local list',
      behavior: RuleProviderBehavior.classical,
      format: RuleProviderFormat.yaml,
    );
    final container = _containerFor(
      tester,
      overrides: [
        clashProvidersProvider.overrideWith2(
          (_) => _TestClashProviders(const [local]),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          child: ClashProvidersView(kind: ProviderKind.rule),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('File'), findsOneWidget);

    await tester.tap(find.byGlyph(AppGlyphs.more));
    await tester.pumpAndSettle();
    expect(find.text('Edit'), findsOneWidget);

    await tester.tap(find.text('Options'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextFormField, 'Name'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'URL'), findsNothing);
    expect(find.text('Behavior'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'classical'), findsOneWidget);
  });

  testWidgets('an mrs rule set is offered only the behaviors the core takes', (
    tester,
  ) async {
    final action = _RecordingClashProvidersAction();
    final container = _containerFor(
      tester,
      overrides: [
        clashProvidersProvider.overrideWith2(
          (_) => _TestClashProviders([appRules]),
        ),
        clashProvidersActionProvider.overrideWith(() => action),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          child: ClashProvidersView(kind: ProviderKind.rule),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Ad block'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, 'Interval'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'domain'));
    await tester.pumpAndSettle();
    expect(find.text('classical'), findsNothing);
    await tester.tap(find.text('ipcidr'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(action.put.single.behavior, RuleProviderBehavior.ipcidr);
    expect(action.put.single.format, RuleProviderFormat.mrs);
    expect(action.put.single.id, appRules.id);
  });

  testWidgets(
    'a rule set whose url turns into an mrs link follows the format',
    (tester) async {
      const yamlRules = ClashProvider(
        id: 4,
        kind: ProviderKind.rule,
        label: 'Ads',
        url: 'https://example.com/ads.yaml',
        behavior: RuleProviderBehavior.classical,
        format: RuleProviderFormat.yaml,
      );
      final action = _RecordingClashProvidersAction();
      final container = _containerFor(
        tester,
        overrides: [
          clashProvidersProvider.overrideWith2(
            (_) => _TestClashProviders(const [yamlRules]),
          ),
          clashProvidersActionProvider.overrideWith(() => action),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(
            child: ClashProvidersView(kind: ProviderKind.rule),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Ads'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(FilledButton, 'yaml'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'classical'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'URL'),
        'https://example.com/ads.mrs',
      );
      await tester.pumpAndSettle();
      expect(find.widgetWithText(FilledButton, 'mrs'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'domain'), findsOneWidget);

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(action.put.single.url, 'https://example.com/ads.mrs');
      expect(action.put.single.format, RuleProviderFormat.mrs);
      expect(action.put.single.behavior, RuleProviderBehavior.domain);
    },
  );

  testWidgets('a rule set can be given a format its url does not name', (
    tester,
  ) async {
    const bareRules = ClashProvider(
      id: 5,
      kind: ProviderKind.rule,
      label: 'Bare',
      url: 'https://example.com/rules?token=abc',
      behavior: RuleProviderBehavior.classical,
      format: RuleProviderFormat.yaml,
    );
    final action = _RecordingClashProvidersAction();
    final container = _containerFor(
      tester,
      overrides: [
        clashProvidersProvider.overrideWith2(
          (_) => _TestClashProviders(const [bareRules]),
        ),
        clashProvidersActionProvider.overrideWith(() => action),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          child: ClashProvidersView(kind: ProviderKind.rule),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Bare'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'yaml'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('text'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(FilledButton, 'text'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'classical'), findsOneWidget);

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(action.put.single.format, RuleProviderFormat.text);
    expect(action.put.single.behavior, RuleProviderBehavior.classical);
  });

  testWidgets('deleting a provider goes through the action after confirming', (
    tester,
  ) async {
    final action = _RecordingClashProvidersAction();
    final container = _containerFor(
      tester,
      overrides: [
        clashProvidersProvider.overrideWith2(
          (_) => _TestClashProviders([appProxies]),
        ),
        clashProvidersActionProvider.overrideWith(() => action),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          child: ClashProvidersView(kind: ProviderKind.proxy),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byGlyph(AppGlyphs.more));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(action.deleted, [appProxies]);
  });
}
