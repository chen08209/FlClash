import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fl_clash/common/app_localizations.dart';
import 'package:fl_clash/common/exception.dart';
import 'package:fl_clash/common/l10n_labels.dart';
import 'package:fl_clash/common/release_asset.dart';
import 'package:fl_clash/common/request.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/form/form.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/about.dart';
import 'package:fl_clash/views/config/rules.dart';
import 'package:fl_clash/views/config/scripts.dart';
import 'package:fl_clash/views/profiles/extend/added_rules.dart';
import 'package:fl_clash/views/proxies/proxies.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../helpers/context_menu.dart';
import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';
import '../plugins/code_forge/support.dart';
import '../helpers/host_scaffold.dart';

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

class _TestProfileAddedRules extends ProfileRules {
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

  Future<void> openProxiesMenu(WidgetTester tester) async {
    await tester.tap(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byGlyph(AppGlyphs.more),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder inMenu(Finder finder) =>
      find.descendant(of: find.byType(PopupMenu), matching: finder);

  testWidgets('the proxies menu picks the style from a sub menu', (
    tester,
  ) async {
    final container = _containerFor(tester);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ProxiesView()),
      ),
    );
    await tester.pump();
    final l10n = currentAppLocalizations;

    await openProxiesMenu(tester);
    expect(inMenu(find.text(l10n.iconStyle)), findsOneWidget);

    await tester.tap(inMenu(find.text(l10n.style)));
    await tester.pumpAndSettle();
    await tester.tap(inMenu(find.text(ProxiesType.tab.label)));
    await tester.pumpAndSettle();

    expect(container.read(proxiesStyleSettingProvider).type, ProxiesType.tab);
    expect(find.byType(PopupMenu), findsNothing);

    await openProxiesMenu(tester);
    expect(inMenu(find.text(l10n.iconStyle)), findsNothing);
    expect(
      tester.getTopLeft(inMenu(find.text(l10n.scrollToSelected))).dy,
      lessThan(tester.getTopLeft(inMenu(find.byType(Divider)).first).dy),
    );
    expect(
      tester.getTopLeft(inMenu(find.byType(Divider)).first).dy,
      lessThan(tester.getTopLeft(inMenu(find.text(l10n.style))).dy),
    );
    expect(tester.takeException(), null);
  });

  testWidgets('the proxies menu sorts by delay and hides timed-out proxies', (
    tester,
  ) async {
    final container = _containerFor(tester);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ProxiesView()),
      ),
    );
    await tester.pump();
    final l10n = currentAppLocalizations;

    await openProxiesMenu(tester);
    await tester.tap(inMenu(find.text(l10n.sort)));
    await tester.pumpAndSettle();
    await tester.tap(inMenu(find.text(l10n.delay)));
    await tester.pumpAndSettle();

    expect(
      container.read(proxiesStyleSettingProvider).sortType,
      ProxiesSortType.delay,
    );

    await openProxiesMenu(tester);
    expect(
      inMenu(
        find.descendant(
          of: find.ancestor(
            of: find.text(l10n.hideTimeoutProxies),
            matching: find.byType(Row),
          ),
          matching: find.byGlyph(AppGlyphs.check),
        ),
      ),
      findsNothing,
    );
    await tester.tap(inMenu(find.text(l10n.hideTimeoutProxies)));
    await tester.pumpAndSettle();

    expect(
      container.read(proxiesStyleSettingProvider).hideTimeoutProxies,
      isTrue,
    );
    expect(find.byType(PopupMenu), findsNothing);
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
    final hero = find.byWidgetPredicate(
      (widget) => widget.runtimeType.toString() == '_AboutHero',
    );
    expect(
      tester.getRect(hero).top,
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

  testWidgets('about view sets updates between the hero and more', (
    tester,
  ) async {
    final container = _containerFor(tester, size: const Size(1400, 2000));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: AboutView()),
      ),
    );
    await tester.pump();
    final l10n = currentAppLocalizations;
    final hero = find.byWidgetPredicate(
      (widget) => widget.runtimeType.toString() == '_AboutHero',
    );
    final update = tester.getRect(find.widgetWithText(ListHeader, l10n.update));
    expect(update.top, greaterThan(tester.getRect(hero).bottom));
    expect(
      update.bottom,
      lessThan(tester.getRect(find.text(l10n.autoCheckUpdate)).top),
    );
    expect(
      tester.getRect(find.text(l10n.autoCheckUpdate)).bottom,
      lessThan(tester.getRect(find.widgetWithText(ListHeader, l10n.more)).top),
    );
    expect(find.text(l10n.updateChannel), findsNothing);

    expect(container.read(appSettingProvider).autoCheckUpdate, isTrue);
    await tester.tap(
      find.descendant(
        of: find.widgetWithText(ListItem, l10n.autoCheckUpdate),
        matching: find.byType(Switch),
      ),
    );
    await tester.pumpAndSettle();
    expect(container.read(appSettingProvider).autoCheckUpdate, isFalse);

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
    expect(tester.widget<LoadingBar>(find.byType(LoadingBar)).active, isFalse);

    await tester.tap(find.text('Check for updates'));
    await tester.pump();
    expect(tester.widget<LoadingBar>(find.byType(LoadingBar)).active, isTrue);

    await tester.tap(find.text('Check for updates'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(adapter.requests, 1);

    adapter.response.complete(
      ResponseBody.fromString(
        jsonEncode([
          {
            'tag_name': 'v0.0.0-rs.1',
            'draft': false,
            'assets': [
              {'name': updateChecksumsName('v0.0.0-rs.1')},
            ],
          },
        ]),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(tester.widget<LoadingBar>(find.byType(LoadingBar)).active, isFalse);
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
    expect(find.byGlyph(AppGlyphs.more), findsNothing);
    expect(find.text('Local'), findsNWidgets(4));
    expect(tester.takeException(), null);

    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();
    expect(find.text('Start from scratch'), findsOneWidget);
    expect(find.text('Import from URL'), findsOneWidget);
    expect(find.text('Import from file'), findsOneWidget);
  });

  testWidgets('a new script asks before a name alone is discarded', (
    tester,
  ) async {
    await tester.runAsync(initEditorNative);
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
    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start from scratch'));
    await settle(tester, 22);

    await tester.enterText(
      find.descendant(
        of: find.byType(EditorPage),
        matching: find.byType(TextField),
      ),
      'Named',
    );
    await tester.pump();
    await tester.binding.handlePopRoute();
    await settle(tester, 12);

    expect(find.text('Save the changes?'), findsOneWidget);
  });

  testWidgets('scripts view offers sync only for scripts with a source URL', (
    tester,
  ) async {
    const url = 'https://example.com/remote.js';
    final local = Script(
      id: 1,
      label: 'Local script',
      lastUpdateTime: DateTime(2026),
    );
    final remote = Script(
      id: 2,
      label: 'Remote script',
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
    expect(find.byType(LastUpdateTimeText), findsNWidgets(2));
    expect(find.text('Local'), findsOneWidget);
    expect(find.text('Remote'), findsOneWidget);

    await rightClick(tester, find.text('Local script'));
    await tester.pumpAndSettle();
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Sync'), findsNothing);
    expect(find.text('URL'), findsNothing);
    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Remote script'));
    await tester.pumpAndSettle();
    expect(find.text('Sync'), findsOneWidget);
    expect(find.text('URL'), findsOneWidget);

    await tester.tap(find.text('Sync'));
    await tester.pump();

    expect(action.updated, [remote]);
  });

  testWidgets('scripts view reorders a script by its handle in sort mode', (
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

    final to = tester.getCenter(find.text('Script 2'));
    final pressed = await tester.startGesture(
      tester.getCenter(find.text('Script 0')),
    );
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    await pressed.moveTo(to + const Offset(0, 100));
    await tester.pump();
    await pressed.up();
    await tester.pumpAndSettle();
    expect(notifier.orders, isEmpty);
    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Sort'));
    await tester.pumpAndSettle();
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(SortHandle).first),
    );
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    await gesture.moveTo(
      Offset(tester.getCenter(find.byType(SortHandle).first).dx, to.dy + 100),
    );
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

  testWidgets('standard extension renders added rules and selection state', (
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
        profileRulesProvider.overrideWith2(
          (_) => _TestProfileAddedRules(addedRules),
        ),
        globalRulesProvider.overrideWith(() => _TestGlobalRules(globalRules)),
        profileDisabledRuleIdsProvider.overrideWith2(
          (_) => _TestProfileDisabledRuleIds(const []),
        ),
        clashConfigProvider(
          profile.id,
        ).overrideWithValue(const AsyncData(ClashConfig())),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: ProfileIdProvider(
            profileId: profile.id,
            child: const HostScaffold(
              body: CustomScrollView(slivers: [AddedRulesContent()]),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(AddedRulesContent), findsOneWidget);
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

  group('the exits of a profile', () {
    Rule exitRule(int id, String exit) => Rule(
      id: id,
      ruleAction: RuleAction.DOMAIN,
      content: '$id.example',
      ruleTarget: exit,
      customExit: true,
    );

    const outbounds = ClashConfig(
      proxies: [Proxy(name: 'HK', type: 'ss')],
      proxyGroups: [ProxyGroup(id: 1, name: 'Final', type: GroupType.Selector)],
    );

    Future<ProviderContainer> pumpExits(
      WidgetTester tester, {
      required Profile profile,
      List<Rule> own = const [],
      List<Rule> global = const [],
      List<int> disabled = const [],
      ClashConfig config = outbounds,
      AsyncValue<ClashConfig?> scripted = const AsyncData(null),
    }) async {
      final container = _containerFor(
        tester,
        profiles: [profile],
        overrides: [
          currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
          profileRulesProvider.overrideWith2(
            (_) => _TestProfileAddedRules(own),
          ),
          globalRulesProvider.overrideWith(() => _TestGlobalRules(global)),
          profileDisabledRuleIdsProvider.overrideWith2(
            (_) => _TestProfileDisabledRuleIds(disabled),
          ),
          clashConfigProvider(profile.id).overrideWithValue(AsyncData(config)),
          scriptOutboundsProvider(profile.id).overrideWithValue(scripted),
          profileMatchTargetProvider(
            profile.id,
          ).overrideWithValue(const AsyncData('Final')),
        ],
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(
            child: ProfileIdProvider(
              profileId: profile.id,
              child: const HostScaffold(
                body: CustomScrollView(slivers: [AddedRulesContent()]),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      return container;
    }

    Finder exitRow(String exit) => find
        .ancestor(of: find.text(exit), matching: find.byType(ListItem<dynamic>))
        .first;

    Finder inRow(String exit, String text) =>
        find.descendant(of: exitRow(exit), matching: find.text(text));

    testWidgets('lists each exit the rules in force go to, once, on default '
        'and where that goes', (tester) async {
      final l10n = currentAppLocalizations;
      await pumpExits(
        tester,
        profile: Profile.normal(),
        own: [
          exitRule(1, 'Media'),
          exitRule(2, 'AI'),
          exitRule(3, 'Media'),
          Rule.parse('DOMAIN,plain.example,Final', id: 4),
        ],
        global: [exitRule(5, 'Media'), exitRule(6, 'Off')],
        disabled: [6],
      );

      expect(find.text(l10n.outboundExit), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ExitsSection),
          matching: find.byType(ListItem<dynamic>),
        ),
        findsNWidgets(2),
      );
      for (final exit in ['Media', 'AI']) {
        expect(inRow(exit, l10n.exitDefault), findsOneWidget);
        expect(inRow(exit, 'Final'), findsOneWidget);
      }
      expect(find.text('Off'), findsNothing);
      expect(tester.takeException(), null);
    });

    testWidgets('a profile with no exit shows no section', (tester) async {
      await pumpExits(
        tester,
        profile: Profile.normal(),
        own: [Rule.parse('DOMAIN,plain.example,DIRECT', id: 1)],
      );

      expect(find.text(currentAppLocalizations.outboundExit), findsNothing);
    });

    testWidgets('the exits line up with the rows above them', (tester) async {
      await pumpExits(
        tester,
        profile: Profile.normal(),
        global: [exitRule(1, 'Media')],
      );

      final global = tester.getRect(
        exitRow(currentAppLocalizations.controlGlobalAddedRules),
      );
      final exit = tester.getRect(exitRow('Media'));
      expect(exit.left, global.left);
      expect(exit.right, global.right);
    });

    testWidgets('the global added rules row ends its count in a chevron at '
        'the margin, as an open row does', (tester) async {
      final global = currentAppLocalizations.controlGlobalAddedRules;
      await pumpExits(
        tester,
        profile: Profile.normal(),
        global: [exitRule(1, 'Media')],
      );

      final row = tester.getRect(exitRow(global));
      final chevron = tester.getRect(
        find.descendant(
          of: exitRow(global),
          matching: find.byGlyph(AppGlyphs.chevronForward),
        ),
      );
      final insets = tester.element(exitRow(global)).listInsets;
      expect(
        chevron.right,
        row.right - insets.trailing + ListItem.chevronInset,
      );
      expect(tester.getRect(find.text('1/1')).right, lessThan(chevron.left));
    });

    testWidgets('the global added rules row sits under the header as a first '
        'row does, and a section gap apart from the profile own rules', (
      tester,
    ) async {
      final global = currentAppLocalizations.controlGlobalAddedRules;
      await pumpExits(tester, profile: Profile.normal());

      expect(
        tester.getRect(exitRow(global)).top,
        tester.getRect(find.byType(ListHeader)).bottom,
      );

      await pumpExits(
        tester,
        profile: Profile.normal(),
        own: [Rule.parse('DOMAIN,plain.example,DIRECT', id: 1)],
      );

      expect(
        tester.getRect(exitRow(global)).top,
        tester.getRect(find.byType(RuleItem)).bottom +
            tester.getSize(find.byType(ListSectionGap)).height,
      );
    });

    testWidgets('a group of its name is where a default exit goes, while a '
        'picked target holds until it is put back on default', (tester) async {
      final l10n = currentAppLocalizations;
      final container = await pumpExits(
        tester,
        profile: Profile.normal().copyWith(exitTargets: {'AI': 'HK'}),
        own: [exitRule(1, 'Media'), exitRule(2, 'AI')],
        config: const ClashConfig(
          proxies: [Proxy(name: 'HK', type: 'ss')],
          proxyGroups: [
            ProxyGroup(id: 1, name: 'Media', type: GroupType.Selector),
            ProxyGroup(id: 2, name: 'AI', type: GroupType.Selector),
          ],
        ),
      );

      expect(inRow('Media', l10n.exitDefault), findsOneWidget);
      expect(inRow('Media', 'Media'), findsNWidgets(2));
      expect(inRow('AI', 'HK'), findsOneWidget);
      expect(inRow('AI', l10n.exitDefault), findsNothing);

      await tester.tap(exitRow('AI'));
      await tester.pumpAndSettle();
      final sheet = find.byType(SelectionSheet<String>);
      expect(
        find.descendant(of: sheet, matching: find.text(l10n.exitDefault)),
        findsOneWidget,
      );
      await tester.tap(
        find.descendant(of: sheet, matching: find.text(l10n.exitDefault)),
      );
      await tester.pumpAndSettle();

      expect(container.read(profilesProvider).first.exitTargets, isEmpty);
      expect(inRow('AI', l10n.exitDefault), findsOneWidget);
      expect(inRow('AI', 'AI'), findsNWidgets(2));
      expect(tester.takeException(), null);
    });

    testWidgets('a picked target that is gone shows red over where the exit '
        'falls back to', (tester) async {
      await pumpExits(
        tester,
        profile: Profile.normal().copyWith(exitTargets: {'Media': 'Gone'}),
        own: [exitRule(1, 'Media')],
      );

      final gone = tester.element(find.text('Gone'));
      expect(
        tester.widget<Text>(find.text('Gone')).style?.color,
        gone.colorScheme.error,
      );
      expect(inRow('Media', 'Final'), findsOneWidget);
    });

    testWidgets('picks a target for an exit into the mapping', (tester) async {
      final container = await pumpExits(
        tester,
        profile: Profile.normal(),
        own: [exitRule(1, 'Media')],
      );

      await tester.tap(exitRow('Media'));
      await tester.pumpAndSettle();
      expect(find.byType(SelectionSheet<String>), findsOneWidget);
      await tester.tap(find.text('HK'));
      await tester.pumpAndSettle();

      expect(find.byType(SelectionSheet<String>), findsNothing);
      expect(container.read(profilesProvider).first.exitTargets, {
        'Media': 'HK',
      });
      expect(inRow('Media', 'HK'), findsOneWidget);
      expect(tester.takeException(), null);
    });

    testWidgets('a script profile picks from the groups its script leaves', (
      tester,
    ) async {
      await pumpExits(
        tester,
        profile: Profile.normal().copyWith(scriptId: 7),
        own: [exitRule(1, 'Media')],
        config: const ClashConfig(
          proxyGroups: [
            ProxyGroup(id: 1, name: 'Before', type: GroupType.Selector),
          ],
        ),
        scripted: const AsyncData(
          ClashConfig(
            proxyGroups: [
              ProxyGroup(id: 2, name: 'After', type: GroupType.URLTest),
            ],
          ),
        ),
      );
      await tester.tap(exitRow('Media'));
      await tester.pumpAndSettle();

      final sheet = find.byType(SelectionSheet<String>);
      expect(
        find.descendant(of: sheet, matching: find.text('After')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: sheet, matching: find.text('Before')),
        findsNothing,
      );
      expect(tester.takeException(), null);
    });

    testWidgets('a script that fails leaves only default', (tester) async {
      final container = await pumpExits(
        tester,
        profile: Profile.normal().copyWith(
          scriptId: 7,
          exitTargets: {'Media': 'HK'},
        ),
        own: [exitRule(1, 'Media')],
        scripted: const AsyncError(
          MessageException('main is not a function'),
          StackTrace.empty,
        ),
      );
      final l10n = currentAppLocalizations;
      await tester.tap(exitRow('Media'));
      await tester.pumpAndSettle();

      expect(find.byType(SelectionSheet<String>), findsNothing);
      expect(find.text(l10n.scriptFailed), findsOneWidget);
      await tester.tap(find.text(l10n.exitDefault).last);
      await tester.pumpAndSettle();
      expect(container.read(profilesProvider).first.exitTargets, isEmpty);
      expect(tester.takeException(), null);
    });
  });

  testWidgets('the global added rules page opens where they are added in a '
      'sheet over itself', (tester) async {
    final profile = Profile.normal();
    final container = _containerFor(
      tester,
      profiles: [profile],
      overrides: [
        currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
        profileRulesProvider.overrideWith2(
          (_) => _TestProfileAddedRules(const []),
        ),
        globalRulesProvider.overrideWith(() => _TestGlobalRules(const [])),
        profileDisabledRuleIdsProvider.overrideWith2(
          (_) => _TestProfileDisabledRuleIds(const []),
        ),
        clashConfigProvider(
          profile.id,
        ).overrideWithValue(const AsyncData(ClashConfig())),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: ProfileIdProvider(
            profileId: profile.id,
            child: const HostScaffold(
              body: CustomScrollView(slivers: [AddedRulesContent()]),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    final l10n = currentAppLocalizations;

    await tester.tap(find.text(l10n.controlGlobalAddedRules));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.goToConfigureAddedRules));
    await tester.pumpAndSettle();

    expect(find.byType(AddedRulesView), findsOneWidget);
    expect(find.text(l10n.editGlobalRules), findsOneWidget);
    expect(tester.takeException(), null);
  });
  testWidgets('the global added rules row counts the ones this profile keeps '
      'and the page opens their editor from a row', (tester) async {
    final profile = Profile.normal();
    const rules = [
      Rule(id: 1, ruleAction: RuleAction.DOMAIN, content: 'a.com'),
      Rule(id: 2, ruleAction: RuleAction.DOMAIN, content: 'b.com'),
    ];
    final container = _containerFor(
      tester,
      profiles: [profile],
      overrides: [
        currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
        profileRulesProvider.overrideWith2(
          (_) => _TestProfileAddedRules(const []),
        ),
        globalRulesProvider.overrideWith(() => _TestGlobalRules(rules)),
        profileDisabledRuleIdsProvider.overrideWith2(
          (_) => _TestProfileDisabledRuleIds(const [2]),
        ),
        clashConfigProvider(
          profile.id,
        ).overrideWithValue(const AsyncData(ClashConfig())),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: ProfileIdProvider(
            profileId: profile.id,
            child: const HostScaffold(
              body: CustomScrollView(slivers: [AddedRulesContent()]),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    final l10n = currentAppLocalizations;

    expect(find.text('1/2'), findsOneWidget);
    await tester.tap(find.text(l10n.controlGlobalAddedRules));
    await tester.pumpAndSettle();
    expect(find.text(l10n.editGlobalRules), findsOneWidget);
    expect(find.byTooltip(l10n.goToConfigureAddedRules), findsNothing);
    await tester.tap(find.text(l10n.goToConfigureAddedRules));
    await tester.pumpAndSettle();

    expect(find.byType(AddedRulesView), findsOneWidget);
    expect(tester.takeException(), null);
  });
}
