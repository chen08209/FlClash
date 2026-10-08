import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/form/form.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/custom/groups.dart';
import 'package:fl_clash/views/profiles/custom/members.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

const _profileId = 1;

class _MockCore extends Mock implements CoreHandlerInterface {}

class _TestClashProviders extends ClashProviders {
  @override
  Stream<List<ClashProvider>> build() => Stream.value(const []);
}

ProxyGroup _group({
  List<String>? proxies,
  List<String>? use,
  Map<String, int>? usePosition,
  String? filter,
}) {
  return ProxyGroup(
    id: 100,
    profileId: _profileId,
    name: 'Group',
    type: GroupType.Selector,
    proxies: proxies,
    use: use,
    usePosition: usePosition,
    filter: filter,
  );
}

const _home = CustomProxy(
  id: 1,
  definition: {
    'name': 'Home',
    'type': 'socks5',
    'server': '1.1.1.1',
    'port': 1080,
  },
);

class _TestCustomProxies extends CustomProxies {
  _TestCustomProxies(this.proxies);

  final List<CustomProxy> proxies;

  @override
  Stream<List<CustomProxy>> build() => Stream.value(proxies);
}

class _TestProxyGroups extends ProxyGroups {
  @override
  Stream<List<ProxyGroup>> build(int profileId) => Stream.value(const []);
}

class _TestProxyDialers extends ProxyDialers {
  @override
  Stream<Map<int, String>> build(int profileId) => Stream.value(const {});
}

class _PendingProfileData extends Notifier<CustomProfileData?> {
  @override
  CustomProfileData? build() => null;

  void load(CustomProfileData data) => state = data;
}

final _pendingProfileDataProvider =
    NotifierProvider<_PendingProfileData, CustomProfileData?>(
      _PendingProfileData.new,
    );

final _hongKong = defaultFilters.first;

final _remainingTraffic = defaultFilters.firstWhere(
  (filter) => filter.label == 'Remaining Traffic',
);

Finder _rowOf(String title) =>
    find.ancestor(of: find.text(title), matching: find.byType(FormRow)).first;

final _optionSheet = find.byWidgetPredicate(
  (widget) => widget is SelectionSheet,
);

Future<void> _addOption(WidgetTester tester, String label) async {
  await _openOptions(tester);
  final option = find.descendant(of: _optionSheet, matching: find.text(label));
  await tester.tap(option);
  await tester.pumpAndSettle();
  expect(option, findsNothing);
  expect(_optionSheet, findsOneWidget);
  await tester.pageBack();
  await tester.pumpAndSettle();
  expect(_optionSheet, findsNothing);
}

Future<void> _openOptions(WidgetTester tester) async {
  final add = find.widgetWithText(
    FormRow,
    currentAppLocalizations.addSettingEntry,
  );
  await tester.ensureVisible(add);
  await tester.pump();
  await tester.tap(add);
  await tester.pumpAndSettle();
  expect(_optionSheet, findsOneWidget);
}

Finder _bannerText(String text) => find.descendant(
  of: find.byType(ErrorBanner),
  matching: find.textContaining(text),
);

Future<void> _dismissSaveBlocked(WidgetTester tester, String reason) async {
  final dialog = find.byType(CommonDialog);
  expect(
    find.descendant(
      of: dialog,
      matching: find.text(currentAppLocalizations.cannotSave),
    ),
    findsOneWidget,
  );
  expect(
    find.descendant(of: dialog, matching: find.textContaining(reason)),
    findsOneWidget,
  );
  await tester.tap(find.text(currentAppLocalizations.confirm));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ProviderContainer container;
  late _MockCore core;

  setUpAll(() async {
    await AppLocalizations.load(const Locale('en'));
    registerFallbackValue(<String>[]);
  });

  ProviderContainer buildContainer(
    ProxyGroup group, {
    List<CustomProxy> customProxies = const [],
    List<Override> overrides = const [],
  }) {
    final profile = Profile.custom(label: 'mine').copyWith(id: _profileId);
    final subscription = Profile.normal(
      label: 'p',
      url: 'https://example.com/p',
    ).copyWith(id: 2);
    core = _MockCore();
    when(() => core.validateFilters(any())).thenAnswer(
      (invocation) async => [
        for (final filter
            in invocation.positionalArguments.single as List<String>)
          filter.contains('(') ? 'missing closing )' : '',
      ],
    );
    final built = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        profilesProvider.overrideWith(
          () => TestProfiles([profile, subscription]),
        ),
        clashProvidersProvider.overrideWith(_TestClashProviders.new),
        customProxiesProvider.overrideWith(
          () => _TestCustomProxies(customProxies),
        ),
        proxyGroupsProvider.overrideWith2((_) => _TestProxyGroups()),
        proxyDialersProvider.overrideWith2((_) => _TestProxyDialers()),
        currentProfileIdProvider.overrideWithBuild((_, _) => _profileId),
        proxyGroupProvider.overrideWithBuild((_, _) => group),
        ...overrides,
      ],
    );
    addTearDown(built.dispose);
    globalState.container = built;
    built.read(viewSizeProvider.notifier).update((_) => const Size(1400, 1000));
    return built;
  }

  Future<void> pumpEditView(WidgetTester tester, Widget view) async {
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
            child: ProfileIdProvider(profileId: _profileId, child: view),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  /// The option sheet pages over the form, as it does in the app.
  Future<void> pumpGroupSheet(WidgetTester tester) async {
    await pumpEditView(
      tester,
      Builder(
        builder: (context) => FilledButton(
          onPressed: () => showNestedFormSheet<ProxyGroup>(
            context: context,
            profileId: _profileId,
            overrides: const [],
            currentOf: (ref) => ref.read(proxyGroupProvider),
            formBuilder: (_) => const EditProxyGroupView(),
          ),
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  group('group members', () {
    Finder rowOf(String title) => find.ancestor(
      of: find.text(title),
      matching: find.byType(DecorationListItem),
    );

    testWidgets('every member sits in one list that ends in an add row', (
      tester,
    ) async {
      final l = currentAppLocalizations;
      container = buildContainer(
        _group(
          proxies: ['DIRECT', 'Home'],
          use: ['p'],
          filter: '${_hongKong.regex}`mine',
        ).copyWith(excludeFilter: _remainingTraffic.regex),
        customProxies: const [_home],
      );

      await pumpEditView(tester, const EditProxyGroupView());
      await tester.pump();

      double top(String text) => tester.getTopLeft(find.text(text)).dy;
      final order = [
        'DIRECT',
        'Home',
        'p',
        _hongKong.label,
        'mine',
        _remainingTraffic.label,
        l.addNodes,
      ];
      for (final (index, name) in order.indexed.skip(1)) {
        expect(top(name), greaterThan(top(order[index - 1])), reason: name);
      }
      expect(find.text(l.basicStrategy), findsOneWidget);
      expect(find.text('socks5'), findsOneWidget);
      expect(
        find.descendant(of: rowOf('p'), matching: find.text(l.proxyProviders)),
        findsOneWidget,
      );
      expect(find.text(l.filters), findsNWidgets(2));
      expect(
        find.descendant(
          of: rowOf(_remainingTraffic.label),
          matching: find.text(l.excludeFilter),
        ),
        findsOneWidget,
      );
      expect(find.text(_hongKong.regex), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('removing the last exclude filter clears it', (tester) async {
      container = buildContainer(
        _group(proxies: ['DIRECT']).copyWith(excludeFilter: 'x'),
      );

      await pumpEditView(tester, const EditProxyGroupView());
      await tester.tap(
        find.descendant(
          of: rowOf('x'),
          matching: find.byTooltip(currentAppLocalizations.remove),
        ),
      );
      await tester.pump();

      expect(container.read(proxyGroupProvider).excludeFilter, isNull);
      expect(container.read(proxyGroupProvider).proxies, ['DIRECT']);
    });

    testWidgets('every member reorders in one list', (tester) async {
      container = buildContainer(
        _group(
          proxies: ['DIRECT', 'REJECT'],
          use: ['a', 'b'],
          filter: 'x`y',
        ).copyWith(excludeFilter: 'z'),
      );

      await pumpEditView(tester, const EditProxyGroupView());
      final list = find.byType(SuperSliverReorderableList);
      Future<void> move(int from, int to) async {
        tester.widget<SliverReorderableList>(list).onReorderItem!(from, to);
        await tester.pump();
      }

      expect(list, findsOneWidget);
      await move(0, 1);
      await move(3, 0);
      await move(5, 0);
      await move(6, 2);

      final group = container.read(proxyGroupProvider);
      expect(group.proxies, ['REJECT', 'DIRECT']);
      expect(group.use, ['b', 'a']);
      expect(group.usePosition, {'b': 0});
      expect(group.filter, 'y`x');
      expect(group.excludeFilter, 'z');
      expect(group.memberLayout, ['filter', 'proxy', 'excludeFilter']);
      expect(group.definition, isNot(contains('memberLayout')));
      double top(String text) => tester.getTopLeft(find.text(text)).dy;
      final order = ['y', 'b', 'z', 'REJECT', 'DIRECT', 'a', 'x'];
      for (final (index, name) in order.indexed.skip(1)) {
        expect(top(name), greaterThan(top(order[index - 1])), reason: name);
      }
    });

    testWidgets('a provider sits where use-position puts it until it is last', (
      tester,
    ) async {
      container = buildContainer(
        _group(
          proxies: ['DIRECT', 'REJECT'],
          use: ['a', 'b'],
          usePosition: {'b': 1},
        ),
      );

      await pumpEditView(tester, const EditProxyGroupView());
      double top(String text) => tester.getTopLeft(find.text(text)).dy;
      final order = ['DIRECT', 'b', 'REJECT', 'a'];
      for (final (index, name) in order.indexed.skip(1)) {
        expect(top(name), greaterThan(top(order[index - 1])), reason: name);
      }

      await tester.tap(
        find.descendant(
          of: rowOf('REJECT'),
          matching: find.byTooltip(currentAppLocalizations.remove),
        ),
      );
      await tester.pump();

      final group = container.read(proxyGroupProvider);
      expect(group.proxies, ['DIRECT']);
      expect(group.use, ['b', 'a']);
      expect(group.usePosition, isNull);
    });

    testWidgets('removing the last filter clears it', (tester) async {
      container = buildContainer(_group(proxies: ['DIRECT'], filter: 'x'));

      await pumpEditView(tester, const EditProxyGroupView());
      await tester.tap(
        find.descendant(
          of: rowOf('x'),
          matching: find.byTooltip(currentAppLocalizations.remove),
        ),
      );
      await tester.pump();

      expect(container.read(proxyGroupProvider).filter, isNull);
      expect(container.read(proxyGroupProvider).proxies, ['DIRECT']);
    });

    testWidgets('a removed member collapses out, and a move skips it', (
      tester,
    ) async {
      container = buildContainer(_group(proxies: ['DIRECT', 'REJECT', 'PASS']));

      await pumpEditView(tester, const EditProxyGroupView());
      await tester.tap(
        find.descendant(
          of: rowOf('DIRECT'),
          matching: find.byTooltip(currentAppLocalizations.remove),
        ),
      );
      await tester.pump();
      expect(container.read(proxyGroupProvider).proxies, ['REJECT', 'PASS']);
      expect(find.text('DIRECT'), findsOneWidget);

      tester
          .widget<SliverReorderableList>(
            find.byType(SuperSliverReorderableList),
          )
          .onReorderItem!(2, 1);
      await tester.pump();
      expect(container.read(proxyGroupProvider).proxies, ['PASS', 'REJECT']);

      await tester.pumpAndSettle();
      expect(find.text('DIRECT'), findsNothing);
    });

    testWidgets('the picker offers what the group lacks and adds each pick', (
      tester,
    ) async {
      final l = currentAppLocalizations;
      container = buildContainer(
        _group(proxies: ['DIRECT'], filter: 'mine'),
        customProxies: const [_home],
      );
      final picker = find.byWidgetPredicate(
        (widget) =>
            widget.runtimeType.toString() == '_MemberPicker<ProxyGroup>',
      );
      Finder offered(String name) =>
          find.descendant(of: picker, matching: find.text(name));

      await pumpGroupSheet(tester);
      await tester.ensureVisible(find.text(l.addNodes));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.addNodes));
      await tester.pumpAndSettle();

      expect(offered('REJECT'), findsNothing);
      for (final header in [
        '${l.basicStrategy} (5)',
        '${l.localProxies} (1)',
        '${l.proxyProviders} (1)',
      ]) {
        await tester.tap(offered(header));
        await tester.pumpAndSettle();
      }
      await tester.tap(
        find.descendant(
          of: picker,
          matching: find.textContaining('${l.filters} ('),
        ),
      );
      await tester.pumpAndSettle();
      expect(offered('DIRECT'), findsNothing);
      expect(offered('mine'), findsNothing);
      expect(offered(l.url), findsOneWidget);
      expect(offered('https://example.com/p'), findsNothing);
      await tester.tap(offered('REJECT'));
      await tester.pump();
      expect(container.read(proxyGroupProvider).proxies, ['DIRECT', 'REJECT']);
      expect(offered('REJECT'), findsOneWidget);
      await tester.tap(offered('REJECT'));
      await tester.pump();
      expect(container.read(proxyGroupProvider).proxies, ['DIRECT']);
      await tester.tap(offered('REJECT'));
      await tester.tap(offered('Home'));
      await tester.tap(offered('p'));
      await tester.scrollUntilVisible(
        offered(_hongKong.label),
        200,
        scrollable: find
            .descendant(of: picker, matching: find.byType(Scrollable))
            .first,
      );
      await tester.tap(offered(_hongKong.label));
      await tester.pump();
      expect(find.byTooltip(l.confirm), findsNothing);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(picker, findsNothing);

      final group = container.read(proxyGroupProvider);
      expect(group.proxies, ['DIRECT', 'REJECT', 'Home']);
      expect(group.use, ['p']);
      expect(group.filter, 'mine`${_hongKong.regex}');
    });

    testWidgets('the picker adds exclude filters as members of their own', (
      tester,
    ) async {
      final l = currentAppLocalizations;
      container = buildContainer(_group(proxies: ['DIRECT']));
      final picker = find.byWidgetPredicate(
        (widget) =>
            widget.runtimeType.toString() == '_MemberPicker<ProxyGroup>',
      );

      await pumpGroupSheet(tester);
      await tester.ensureVisible(find.text(l.addNodes));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.addNodes));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: picker,
          matching: find.textContaining('${l.excludeFilter} ('),
        ),
      );
      await tester.pumpAndSettle();
      final info = find.descendant(
        of: picker,
        matching: find.text(_remainingTraffic.label),
      );
      await tester.scrollUntilVisible(
        info,
        200,
        scrollable: find
            .descendant(of: picker, matching: find.byType(Scrollable))
            .first,
      );
      await tester.tap(info);
      await tester.pump();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      final group = container.read(proxyGroupProvider);
      expect(group.excludeFilter, _remainingTraffic.regex);
      expect(group.filter, isNull);
      expect(
        find.descendant(
          of: find.byType(SuperSliverReorderableList),
          matching: find.text(_remainingTraffic.label),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(SuperSliverReorderableList),
          matching: find.text(l.excludeFilter),
        ),
        findsOneWidget,
      );
    });
  });

  testWidgets('an exclude filter of a provider sorts among its filters', (
    tester,
  ) async {
    const options = ProxyProviderOptions(filter: 'x`y', excludeFilter: 'z');
    container = buildContainer(
      _group(),
      overrides: [
        proxyProviderOptionsProvider.overrideWithBuild((_, _) => options),
      ],
    );

    await pumpEditView(
      tester,
      const CustomScrollView(slivers: [ProxyProviderFiltersSliver()]),
    );
    final list = find.byType(SuperSliverReorderableList);
    Future<void> move(int from, int to) async {
      tester.widget<SliverReorderableList>(list).onReorderItem!(from, to);
      await tester.pump();
    }

    await move(2, 1);
    final moved = container.read(proxyProviderOptionsProvider);
    expect(moved.filter, 'x`y');
    expect(moved.memberLayout, ['filter', 'excludeFilter']);
    expect(moved.definition, isNot(contains('memberLayout')));
    double top(String text) => tester.getTopLeft(find.text(text)).dy;
    expect(top('z'), greaterThan(top('x')));
    expect(top('y'), greaterThan(top('z')));

    await move(1, 2);
    expect(container.read(proxyProviderOptionsProvider), options);
  });

  group('EditProxyGroupView', () {
    testWidgets('a new group holds its unfilled fields back until a save', (
      tester,
    ) async {
      container = buildContainer(_group().copyWith(id: -1, name: ''));

      await pumpEditView(tester, const EditProxyGroupView());
      expect(
        _bannerText(currentAppLocalizations.customIssueEmptyName),
        findsNothing,
      );
      expect(
        _bannerText(currentAppLocalizations.customIssueNoProxySource),
        findsNothing,
      );

      container
          .read(proxyGroupProvider.notifier)
          .update((state) => state.copyWith(name: 'DIRECT'));
      await tester.pumpAndSettle();
      expect(
        _bannerText(currentAppLocalizations.customIssueReservedName('DIRECT')),
        findsOneWidget,
      );
      expect(
        _bannerText(currentAppLocalizations.customIssueNoProxySource),
        findsNothing,
      );

      await tester.tap(find.byTooltip(currentAppLocalizations.save));
      await tester.pumpAndSettle();
      expect(
        _bannerText(currentAppLocalizations.customIssueNoProxySource),
        findsOneWidget,
      );
    });

    testWidgets('saving on the way out shows what an unfinished group lacks', (
      tester,
    ) async {
      final l = currentAppLocalizations;
      container = buildContainer(_group().copyWith(id: -1, name: ''));
      await pumpGroupSheet(tester);

      container
          .read(proxyGroupProvider.notifier)
          .update((state) => state.copyWith(name: 'g2'));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text(l.saveChanges), findsOneWidget);

      await tester.tap(find.text(l.confirm));
      await tester.pumpAndSettle();
      await _dismissSaveBlocked(tester, l.customIssueNoProxySource);

      expect(find.byType(CommonDialog), findsNothing);
      expect(find.byType(EditProxyGroupView), findsOneWidget);
      expect(_bannerText(l.customIssueNoProxySource), findsOneWidget);
    });

    testWidgets('a save before the profile data loads does nothing', (
      tester,
    ) async {
      container = buildContainer(
        _group().copyWith(id: -1, name: ''),
        overrides: [
          customProfileDataProvider(
            _profileId,
          ).overrideWith((ref) => ref.watch(_pendingProfileDataProvider)),
        ],
      );
      final emptyName = _bannerText(
        currentAppLocalizations.customIssueEmptyName,
      );

      await pumpEditView(tester, const EditProxyGroupView());
      await tester.tap(find.byTooltip(currentAppLocalizations.save));
      await tester.pumpAndSettle();
      expect(find.byType(EditProxyGroupView), findsOneWidget);

      container
          .read(_pendingProfileDataProvider.notifier)
          .load(const CustomProfileData(ruleTargets: {'DIRECT'}));
      await tester.pumpAndSettle();
      expect(emptyName, findsNothing);

      await tester.tap(find.byTooltip(currentAppLocalizations.save));
      await tester.pumpAndSettle();
      expect(emptyName, findsOneWidget);
    });

    testWidgets('refuses an edit that makes an app proxy dial through itself', (
      tester,
    ) async {
      final group = _group(proxies: ['DIRECT']);
      container = buildContainer(
        group,
        overrides: [
          customProfileDataProvider(_profileId).overrideWithValue(
            CustomProfileData(
              proxyGroups: [
                const ProxyGroup(
                  id: 1,
                  name: 'Landing',
                  type: GroupType.Selector,
                  proxies: ['Home'],
                ),
                group,
              ],
              ruleTargets: const {'DIRECT', 'Landing', 'Group'},
              proxies: const {'Home'},
              dialers: const {'Home': 'Group'},
            ),
          ),
        ],
      );
      final message = currentAppLocalizations.customIssueDialerLoop(
        'Home',
        'Group',
      );

      await pumpEditView(tester, const EditProxyGroupView());
      expect(_bannerText(message), findsNothing);

      container
          .read(proxyGroupProvider.notifier)
          .update((state) => state.copyWith(proxies: ['DIRECT', 'Landing']));
      await tester.pumpAndSettle();
      expect(_bannerText(message), findsOneWidget);

      await tester.tap(find.byTooltip(currentAppLocalizations.save));
      await tester.pumpAndSettle();
      await _dismissSaveBlocked(tester, message);
      expect(find.byType(EditProxyGroupView), findsOneWidget);
      expect(_bannerText(message), findsOneWidget);
    });

    testWidgets('the issues banner stays on top as the form scrolls', (
      tester,
    ) async {
      final l = currentAppLocalizations;
      container = buildContainer(
        _group().copyWith(
          url: 'https://example.com',
          interval: 600,
          timeout: 2000,
          maxFailedTimes: 3,
          lazy: false,
          hidden: true,
          disableUDP: true,
        ),
      );
      await pumpEditView(tester, const EditProxyGroupView());
      tester.view.physicalSize = const Size(1400, 600);
      await tester.pumpAndSettle();
      final banner = _bannerText(l.customIssueNoProxySource);
      final top = tester.getTopLeft(banner).dy;
      final general = tester.getTopLeft(find.text(l.general)).dy;

      await tester.drag(find.text(l.nodes), const Offset(0, -200));
      await tester.pumpAndSettle();

      expect(tester.getTopLeft(find.text(l.general)).dy, lessThan(general));
      expect(tester.getTopLeft(banner).dy, top);
    });

    testWidgets('an existing group shows its issues on opening', (
      tester,
    ) async {
      container = buildContainer(_group());

      await pumpEditView(tester, const EditProxyGroupView());
      await tester.pumpAndSettle();

      expect(
        _bannerText(currentAppLocalizations.customIssueNoProxySource),
        findsOneWidget,
      );
    });

    testWidgets('a new group opens on the basics alone', (tester) async {
      final l = currentAppLocalizations;
      container = buildContainer(_group().copyWith(id: -1, name: ''));

      await pumpEditView(tester, const EditProxyGroupView());

      expect(find.text(l.name), findsOneWidget);
      expect(find.text(l.nodes), findsOneWidget);
      expect(find.text(l.addSettingEntry), findsOneWidget);
      for (final title in [l.hideFromList, l.filter, l.testWhenUsed]) {
        expect(find.text(title), findsNothing);
      }
    });

    testWidgets('an option is added at the core default', (tester) async {
      container = buildContainer(_group());

      await pumpGroupSheet(tester);
      await _addOption(tester, currentAppLocalizations.testWhenUsed);

      final lazy = tester.widget<Switch>(
        find.descendant(
          of: _rowOf(currentAppLocalizations.testWhenUsed),
          matching: find.byType(Switch),
        ),
      );
      expect(lazy.value, isTrue);
      expect(container.read(proxyGroupProvider).lazy, isTrue);
    });

    testWidgets('an option set on the group shows, and removing it clears it', (
      tester,
    ) async {
      container = buildContainer(_group().copyWith(interval: 600));

      await pumpGroupSheet(tester);
      expect(find.text('600'), findsOneWidget);
      expect(find.text(currentAppLocalizations.timeout), findsNothing);

      await tester.tap(
        find.descendant(
          of: _rowOf(currentAppLocalizations.testInterval),
          matching: find.byTooltip(currentAppLocalizations.remove),
        ),
      );
      await tester.pumpAndSettle();

      expect(container.read(proxyGroupProvider).interval, isNull);
      expect(find.text(currentAppLocalizations.testInterval), findsNothing);
    });

    testWidgets('does not offer the relay type the core removed', (
      tester,
    ) async {
      container = buildContainer(_group());

      await pumpGroupSheet(tester);
      await tester.tap(find.text(currentAppLocalizations.proxyType));
      await tester.pumpAndSettle();

      expect(find.text(GroupType.Selector.name), findsWidgets);
      expect(find.text(GroupType.LoadBalance.name), findsOneWidget);
      expect(find.text(GroupType.Relay.name), findsNothing);
    });

    testWidgets('offers tolerance only to a url-test group', (tester) async {
      container = buildContainer(_group());

      await pumpGroupSheet(tester);
      await _openOptions(tester);
      expect(find.text(currentAppLocalizations.tolerance), findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();

      container
          .read(proxyGroupProvider.notifier)
          .update((state) => state.copyWith(type: GroupType.URLTest));
      await tester.pump();
      await _openOptions(tester);

      expect(find.text(currentAppLocalizations.tolerance), findsOneWidget);
      expect(find.text(currentAppLocalizations.strategy), findsNothing);
    });

    testWidgets('offers strategy only to a load-balance group', (tester) async {
      container = buildContainer(_group());

      await pumpGroupSheet(tester);
      container
          .read(proxyGroupProvider.notifier)
          .update((state) => state.copyWith(type: GroupType.LoadBalance));
      await tester.pump();
      await _addOption(tester, currentAppLocalizations.strategy);

      expect(find.text(currentAppLocalizations.strategy), findsOneWidget);
      expect(
        find.text(LoadBalanceStrategy.consistentHashing.value),
        findsOneWidget,
      );

      await tester.ensureVisible(find.text(currentAppLocalizations.strategy));
      await tester.pump();
      await tester.tap(find.text(currentAppLocalizations.strategy));
      await tester.pumpAndSettle();
      await tester.tap(find.text(LoadBalanceStrategy.roundRobin.value));
      await tester.pumpAndSettle();

      expect(
        container.read(proxyGroupProvider).strategy,
        LoadBalanceStrategy.roundRobin,
      );
    });

    testWidgets('writes the timeout the core reads in milliseconds', (
      tester,
    ) async {
      container = buildContainer(_group());

      await pumpGroupSheet(tester);
      await _addOption(tester, currentAppLocalizations.timeout);
      expect(container.read(proxyGroupProvider).timeout, 5000);
      await tester.ensureVisible(find.text(currentAppLocalizations.timeout));
      await tester.pump();
      await tester.enterText(
        find.descendant(
          of: _rowOf(currentAppLocalizations.timeout),
          matching: find.byType(TextFormField),
        ),
        '2500',
      );
      await tester.pump();

      expect(container.read(proxyGroupProvider).timeout, 2500);
      expect(find.text('ms'), findsWidgets);
    });

    testWidgets('a filter the core rejects is shown and blocks the save', (
      tester,
    ) async {
      container = buildContainer(
        _group(proxies: ['DIRECT']).copyWith(filter: 'hk`(jp'),
      );
      final message = currentAppLocalizations.customIssueInvalidFilter(
        currentAppLocalizations.filter,
        'missing closing )',
      );

      await pumpEditView(tester, const EditProxyGroupView());
      expect(_bannerText(message), findsNothing);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(_bannerText(message), findsOneWidget);

      await tester.tap(find.byTooltip(currentAppLocalizations.save));
      await tester.pumpAndSettle();
      await _dismissSaveBlocked(tester, message);
      expect(find.byType(EditProxyGroupView), findsOneWidget);
      expect(_bannerText(message), findsOneWidget);
    });

    testWidgets('an exclude filter the core rejects is named in the banner', (
      tester,
    ) async {
      final l = currentAppLocalizations;
      container = buildContainer(
        _group(proxies: ['DIRECT']).copyWith(excludeFilter: 'hk`(jp'),
      );
      final message = l.customIssueInvalidFilter(
        l.excludeFilter,
        'missing closing )',
      );

      await pumpEditView(tester, const EditProxyGroupView());
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(_bannerText(message), findsOneWidget);
    });
  });
}
