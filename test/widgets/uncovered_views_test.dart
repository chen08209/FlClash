import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/about.dart';
import 'package:fl_clash/views/config/scripts.dart';
import 'package:fl_clash/views/profiles/overwrite/standard.dart';
import 'package:fl_clash/views/proxies/setting.dart';
import 'package:fl_clash/widgets/inherited.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _TestScripts extends Scripts {
  _TestScripts(this.initial);

  final List<Script> initial;

  @override
  Stream<List<Script>> build() => Stream.value(initial);
}

class _TestGlobalRules extends GlobalRules {
  _TestGlobalRules(this.initial);

  final List<Rule> initial;

  @override
  Stream<List<Rule>> build() => Stream.value(initial);
}

class _TestProfileAddedRules extends ProfileAddedRules {
  _TestProfileAddedRules(this.initial);

  final List<Rule> initial;

  @override
  Stream<List<Rule>> build(int profileId) => Stream.value(initial);

  @override
  void order(int oldIndex, int newIndex) {}
}

class _TestProfileDisabledRuleIds extends ProfileDisabledRuleIds {
  _TestProfileDisabledRuleIds(this.initial);

  final List<int> initial;

  @override
  Stream<List<int>> build(int profileId) => Stream.value(initial);
}

ProviderContainer _containerFor(
  WidgetTester tester, {
  List<Override> overrides = const [],
  List<Profile>? profiles,
  Size size = const Size(1400, 1000),
}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer(
    overrides: [
      profilesProvider.overrideWith(
        profiles == null ? TestProfiles.new : () => TestProfiles(profiles),
      ),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  globalState.container = container;
  container.read(viewSizeProvider.notifier).update((_) => size);
  return container;
}

void main() {
  setUpAll(() {
    // AboutView reads globalState.packageInfo, which only the real app bootstrap
    // populates.
    globalState.packageInfo = PackageInfo(
      appName: 'FlClash',
      packageName: 'com.follow.clash',
      version: '0.0.0',
      buildNumber: '1',
    );
  });

  testWidgets('proxies setting sheet renders and switches layout type', (
    tester,
  ) async {
    final container = _containerFor(tester);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: Scaffold(body: ProxiesSetting())),
      ),
    );
    await tester.pump();

    expect(find.byType(ProxiesSetting), findsOneWidget);
    expect(tester.takeException(), null);

    container
        .read(proxiesStyleSettingProvider.notifier)
        .update((state) => state.copyWith(type: ProxiesType.list));
    await tester.pump();

    expect(container.read(proxiesStyleSettingProvider).type, ProxiesType.list);
    expect(tester.takeException(), null);
  });

  testWidgets('proxies setting sorts by delay when selected', (tester) async {
    final container = _containerFor(tester);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: Scaffold(body: ProxiesSetting())),
      ),
    );
    await tester.pump();

    container
        .read(proxiesStyleSettingProvider.notifier)
        .update((state) => state.copyWith(sortType: ProxiesSortType.delay));
    await tester.pump();

    expect(
      container.read(proxiesStyleSettingProvider).sortType,
      ProxiesSortType.delay,
    );
    expect(tester.takeException(), null);
  });

  testWidgets('about view renders version and link sections', (tester) async {
    final container = _containerFor(tester);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: AboutView()),
      ),
    );
    await tester.pump();

    expect(find.byType(AboutView), findsOneWidget);
    expect(find.text('Telegram'), findsOneWidget);
    expect(tester.takeException(), null);

    final scrollables = find.byType(Scrollable);
    if (scrollables.evaluate().isNotEmpty) {
      for (var index = 0; index < 4; index++) {
        await tester.drag(scrollables.first, const Offset(0, -400));
        await tester.pump();
      }
    }
    expect(tester.takeException(), null);
  });

  testWidgets('scripts view renders stored scripts and selects one', (
    tester,
  ) async {
    final scripts = List.generate(
      4,
      (index) => Script(
        id: index + 1,
        label: 'Script $index',
        lastUpdateTime: DateTime(2026, 1, index + 1),
      ),
    );
    final container = _containerFor(
      tester,
      overrides: [scriptsProvider.overrideWith(() => _TestScripts(scripts))],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ScriptsView()),
      ),
    );
    await tester.pump();

    expect(find.byType(ScriptsView), findsOneWidget);
    expect(find.text('Script 0'), findsOneWidget);
    expect(find.text('Script 3'), findsOneWidget);
    expect(tester.takeException(), null);

    await tester.tap(find.text('Script 1'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), null);
  });

  testWidgets('scripts view renders an empty state without scripts', (
    tester,
  ) async {
    final container = _containerFor(
      tester,
      overrides: [scriptsProvider.overrideWith(() => _TestScripts(const []))],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ScriptsView()),
      ),
    );
    await tester.pump();

    expect(find.byType(ScriptsView), findsOneWidget);
    expect(find.text('Script 0'), findsNothing);
    expect(tester.takeException(), null);
  });

  testWidgets('standard overwrite renders added rules and selection state', (
    tester,
  ) async {
    final profile = Profile.normal();
    final addedRules = List.generate(
      6,
      (index) => Rule(
        id: 300 + index,
        content: 'added$index.com',
        ruleTarget: 'DIRECT',
        order: index.toString(),
      ),
    );
    final globalRules = List.generate(
      3,
      (index) => Rule(
        id: 400 + index,
        content: 'global$index.com',
        ruleTarget: 'DIRECT',
        order: index.toString(),
      ),
    );
    final container = _containerFor(
      tester,
      profiles: [profile],
      overrides: [
        currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
        profileAddedRulesProvider.overrideWith2(
          (_) => _TestProfileAddedRules(addedRules),
        ),
        globalRulesProvider.overrideWith(() => _TestGlobalRules(globalRules)),
        profileDisabledRuleIdsProvider.overrideWith2(
          (_) => _TestProfileDisabledRuleIds(const []),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: ProfileIdProvider(
            profileId: profile.id,
            child: const Scaffold(
              body: CustomScrollView(slivers: [StandardContent()]),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(StandardContent), findsOneWidget);
    expect(find.text('added0.com'), findsOneWidget);
    expect(tester.takeException(), null);

    final scrollables = find.byType(Scrollable);
    if (scrollables.evaluate().isNotEmpty) {
      for (var index = 0; index < 4; index++) {
        await tester.drag(scrollables.first, const Offset(0, -400));
        await tester.pump();
      }
    }
    expect(tester.takeException(), null);
  });
}
