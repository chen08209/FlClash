import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fl_clash/common/request.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/overwrite/overwrite.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/about.dart';
import 'package:fl_clash/views/config/scripts.dart';
import 'package:fl_clash/views/profiles/overwrite/standard.dart';
import 'package:fl_clash/views/proxies/setting.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _PendingAdapter implements HttpClientAdapter {
  final response = Completer<ResponseBody>();
  int requests = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests++;
    return response.future;
  }

  @override
  void close({bool force = false}) {}
}

class _TestScripts extends Scripts {
  _TestScripts(this.initial);

  final List<Script> initial;
  final orders = <(int, int)>[];

  @override
  Stream<List<Script>> build() => Stream.value(initial);

  @override
  void order(int oldIndex, int newIndex) {
    orders.add((oldIndex, newIndex));
  }
}

class _RecordingScriptsAction extends ScriptsAction {
  final updated = <Script>[];

  @override
  Future<void> updateScript(Script script) async {
    updated.add(script);
  }
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
    expect(
      tester.getRect(find.byType(ListTile).first).top,
      tester.getRect(find.byType(AppBar)).bottom + 12,
    );
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

  testWidgets('about view shows progress while checking for updates', (
    tester,
  ) async {
    final container = _containerFor(tester);
    final originalAdapter = request.dio.httpClientAdapter;
    addTearDown(() => request.dio.httpClientAdapter = originalAdapter);
    final adapter = _PendingAdapter();
    request.dio.httpClientAdapter = adapter;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: AboutView()),
      ),
    );
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsNothing);

    await tester.tap(find.text('Check for updates'));
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    await tester.tap(find.text('Check for updates'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(adapter.requests, 1);

    adapter.response.complete(
      ResponseBody.fromString(
        jsonEncode({'tag_name': 'v0.0.0'}),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.text('The app is already up to date'), findsOneWidget);
    expect(tester.takeException(), null);
  });

  testWidgets('scripts view lists scripts and offers the add menu', (
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
    expect(find.byGlyph(AppGlyphs.more), findsNWidgets(4));
    expect(tester.takeException(), null);

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.text('Start from scratch'), findsOneWidget);
    expect(find.text('Import from URL'), findsOneWidget);
    expect(find.text('Import from file'), findsOneWidget);
  });

  testWidgets('scripts view offers sync only for scripts with a source URL', (
    tester,
  ) async {
    const url = 'https://example.com/remote.js';
    final local = Script(id: 1, label: 'Local', lastUpdateTime: DateTime(2026));
    final remote = Script(
      id: 2,
      label: 'Remote',
      lastUpdateTime: DateTime(2026),
      url: url,
    );
    final action = _RecordingScriptsAction();
    final container = _containerFor(
      tester,
      overrides: [
        scriptsProvider.overrideWith(() => _TestScripts([local, remote])),
        scriptsActionProvider.overrideWith(() => action),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ScriptsView()),
      ),
    );
    await tester.pump();

    expect(find.text(url), findsNothing);

    Finder menuOf(String label) => find.descendant(
      of: find.ancestor(
        of: find.text(label),
        matching: find.byType(DecorationListItem),
      ),
      matching: find.byGlyph(AppGlyphs.more),
    );

    await tester.tap(menuOf('Local'));
    await tester.pumpAndSettle();
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Sync'), findsNothing);
    expect(find.text('URL'), findsNothing);
    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();

    await tester.tap(menuOf('Remote'));
    await tester.pumpAndSettle();
    expect(find.text('Sync'), findsOneWidget);
    expect(find.text('URL'), findsOneWidget);

    await tester.tap(find.text('Sync'));
    await tester.pump();

    expect(action.updated, [remote]);
  });

  testWidgets('scripts view reorders a script by long-press drag', (
    tester,
  ) async {
    final scripts = List.generate(
      3,
      (index) => Script(
        id: index + 1,
        label: 'Script $index',
        lastUpdateTime: DateTime(2026),
      ),
    );
    final notifier = _TestScripts(scripts);
    final container = _containerFor(
      tester,
      overrides: [scriptsProvider.overrideWith(() => notifier)],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ScriptsView()),
      ),
    );
    await tester.pump();

    final from = tester.getCenter(find.text('Script 0'));
    final to = tester.getCenter(find.text('Script 2'));
    final gesture = await tester.startGesture(from);
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    await gesture.moveTo(to + const Offset(0, 100));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(notifier.orders, [(0, 2)]);
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

  testWidgets('standard overwrite picks a MATCH-TARGET from the profile', (
    tester,
  ) async {
    final profile = Profile.normal();
    final container = _containerFor(
      tester,
      profiles: [profile],
      overrides: [
        currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
        profileAddedRulesProvider.overrideWith2(
          (_) => _TestProfileAddedRules(const []),
        ),
        globalRulesProvider.overrideWith(() => _TestGlobalRules(const [])),
        profileDisabledRuleIdsProvider.overrideWith2(
          (_) => _TestProfileDisabledRuleIds(const []),
        ),
        clashConfigProvider(profile.id).overrideWithValue(
          const AsyncData(
            ClashConfig(
              proxies: [Proxy(name: 'HK', type: 'ss')],
              proxyGroups: [
                ProxyGroup(id: 1, name: 'Proxy', type: GroupType.Selector),
              ],
            ),
          ),
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
    final l10n = AppLocalizations.current;
    expect(find.text(l10n.followProfile), findsOneWidget);

    await tester.tap(find.text(l10n.matchTarget));
    await tester.pumpAndSettle();
    expect(find.byType(OverwriteSelectionSheet<String>), findsOneWidget);
    expect(find.text('Proxy'), findsOneWidget);

    await tester.tap(find.text('HK'));
    await tester.pumpAndSettle();
    expect(find.byType(OverwriteSelectionSheet<String>), findsNothing);
    expect(container.read(profilesProvider).first.matchTarget, 'HK');
    expect(find.text('HK'), findsOneWidget);
    expect(tester.takeException(), null);
  });
}
