import 'dart:async';

import 'package:fl_clash/common/app_localizations.dart';
import 'package:fl_clash/common/indexing.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/form/form.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart' hide FileInfo;
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/custom/custom_proxies.dart';
import 'package:fl_clash/views/profiles/custom/dialers.dart';
import 'package:fl_clash/views/profiles/custom/groups.dart';
import 'package:fl_clash/views/profiles/custom/rules.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _TestProfileRules extends ProfileRules {
  final List<Rule> initial;

  _TestProfileRules(this.initial);

  @override
  Stream<List<Rule>> build(int profileId) => Stream.value(initial);

  @override
  void order(int oldIndex, int newIndex) {}

  @override
  void optimistic(List<Rule> next, FutureOr<void> Function() action) {
    value = next;
  }
}

class _TestProxyGroups extends ProxyGroups {
  final List<ProxyGroup> initial;
  final List<Set<int>> deleted = [];
  final List<(int, int)> orders = [];

  _TestProxyGroups(this.initial);

  @override
  Stream<List<ProxyGroup>> build(int profileId) => Stream.value(initial);

  @override
  void order(int oldIndex, int newIndex) => orders.add((oldIndex, newIndex));

  @override
  void delAll(Iterable<int> proxyGroupIds) {
    deleted.add(proxyGroupIds.toSet());
  }

  @override
  void optimistic(List<ProxyGroup> next, FutureOr<void> Function() action) {
    value = next;
  }
}

class _RecordingCustomProxies extends CustomProxies {
  final List<CustomProxy> initial;
  final saved = <CustomProxy>[];

  _RecordingCustomProxies([this.initial = const []]);

  @override
  Stream<List<CustomProxy>> build() => Stream.value(initial);

  @override
  void put(CustomProxy proxy) {
    saved.add(proxy);
    value = [...value, proxy];
  }
}

class _RecordingProxyDialers extends ProxyDialers {
  final calls = <(int, String?)>[];

  @override
  Stream<Map<int, String>> build(int profileId) => Stream.value(const {});

  @override
  void set(int proxyId, String? target) => calls.add((proxyId, target));
}

class _MockCore extends Mock implements CoreHandlerInterface {}

class _RecordingClashProvidersAction extends ClashProvidersAction {
  final applied = <Set<String>>[];

  @override
  Future<void> applyIfProxiesNamed(Set<String> names) async {
    applied.add(names);
  }
}

class _TestCustomData extends Notifier<CustomProfileData> {
  @override
  CustomProfileData build() {
    return const CustomProfileData(ruleTargets: {'DIRECT'});
  }

  void setRuleTargets(Set<String> ruleTargets) {
    state = state.copyWith(ruleTargets: ruleTargets);
  }
}

final _testCustomDataProvider =
    NotifierProvider<_TestCustomData, CustomProfileData>(_TestCustomData.new);

Future<void> _dismissSaveBlocked(WidgetTester tester, String reason) async {
  final dialog = find.byType(CommonDialog);
  expect(
    find.descendant(
      of: dialog,
      matching: find.text(AppLocalizations.current.cannotSave),
    ),
    findsOneWidget,
  );
  expect(
    find.descendant(of: dialog, matching: find.textContaining(reason)),
    findsOneWidget,
  );
  await tester.tap(find.text(AppLocalizations.current.confirm));
  await tester.pumpAndSettle();
}

Future<void> _expectClosesWithoutIssues(WidgetTester tester) async {
  final form = find.byType(ErrorBanner, skipOffstage: false);
  final message = find.descendant(
    of: form,
    matching: find.byType(Text),
    skipOffstage: false,
  );
  for (var frame = 0; frame < 120 && form.evaluate().isNotEmpty; frame++) {
    await tester.pump(const Duration(milliseconds: 16));
    expect(message, findsNothing);
  }
  expect(form, findsNothing);
}

Finder _menuItem(String label) => find.descendant(
  of: find.byType(CommonPopupMenu),
  matching: find.text(label),
);

Widget _proxyGroupsPage(int profileId) => CommonScaffold(
  title: 'Groups',
  body: CustomScrollView(slivers: [CustomProxyGroupsSection(profileId)]),
);

void _setViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1400, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

class _GroupsInUse extends ProfilesAction {
  final Set<String> names;

  _GroupsInUse(this.names);

  @override
  Future<Set<String>> groupsInUse(int profileId, Set<int> groupIds) async =>
      names;
}

Future<_TestProxyGroups> _pumpProxyGroups(
  WidgetTester tester, {
  bool pushed = false,
  Set<String> inUse = const {},
}) async {
  _setViewport(tester);
  final profile = Profile.custom();
  final proxyGroups = List.generate(
    3,
    (index) => ProxyGroup(
      id: 100 + index,
      profileId: profile.id,
      name: 'Group $index',
      type: GroupType.Selector,
      proxies: const ['DIRECT'],
    ),
  );
  final notifier = _TestProxyGroups(proxyGroups);
  final container = ProviderContainer(
    overrides: [
      profilesProvider.overrideWith(() => TestProfiles([profile])),
      currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
      proxyGroupsProvider.overrideWith2((_) => notifier),
      profilesActionProvider.overrideWith(() => _GroupsInUse(inUse)),
      customProfileDataProvider(profile.id).overrideWithValue(
        CustomProfileData(
          proxyGroups: proxyGroups,
          proxyProviders: const {'provider'},
          ruleTargets: {
            ...RuleTarget.baseTargets,
            ...proxyGroups.map((group) => group.name),
          },
        ),
      ),
    ],
  );
  addTearDown(container.dispose);
  globalState.container = container;
  container
      .read(viewSizeProvider.notifier)
      .update((_) => const Size(1400, 1000));

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TestApp(
        child: pushed ? const SizedBox() : _proxyGroupsPage(profile.id),
      ),
    ),
  );
  if (pushed) {
    unawaited(
      tester
          .state<NavigatorState>(find.byType(Navigator).first)
          .push(
            MaterialPageRoute<void>(
              builder: (_) => _proxyGroupsPage(profile.id),
            ),
          ),
    );
    await tester.pumpAndSettle();
  }
  await tester.pump();
  return notifier;
}

Future<_TestProfileRules> _pumpRules(WidgetTester tester) async {
  _setViewport(tester);
  final profile = Profile.custom();
  final orders = indexing.generateNKeys(3);
  final notifier = _TestProfileRules([
    for (final (index, domain) in ['a.com', 'b.com', 'c.com'].indexed)
      Rule.parse(
        'DOMAIN,$domain,DIRECT',
        id: index + 1,
      ).copyWith(order: orders[index]),
  ]);
  final container = ProviderContainer(
    overrides: [
      profilesProvider.overrideWith(() => TestProfiles([profile])),
      currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
      profileRulesProvider.overrideWith2((_) => notifier),
      customProfileDataProvider(
        profile.id,
      ).overrideWithValue(const CustomProfileData(ruleTargets: {'DIRECT'})),
    ],
  );
  addTearDown(container.dispose);
  globalState.container = container;
  container
      .read(viewSizeProvider.notifier)
      .update((_) => const Size(1400, 1000));

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TestApp(child: CustomRulesView(profile.id)),
    ),
  );
  await tester.pump();
  return notifier;
}

void main() {
  group('rules list menu', () {
    final menu = find.byType(CommonPopupMenu);
    Finder menuItem(String label) =>
        find.descendant(of: menu, matching: find.text(label));

    testWidgets('a right click copies the rule right below it', (tester) async {
      final notifier = await _pumpRules(tester);

      await tester.tap(
        find.text('a.com'),
        buttons: kSecondaryButton,
        kind: PointerDeviceKind.mouse,
      );
      await tester.pumpAndSettle();
      await tester.tap(menuItem(AppLocalizations.current.copy));
      await tester.pumpAndSettle();

      expect(notifier.value.map((rule) => rule.content), [
        'a.com',
        'a.com',
        'b.com',
        'c.com',
      ]);
      expect(notifier.value[1].id, isNot(1));
      expect(find.text('a.com'), findsNWidgets(2));

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('a right click deletes the rule once confirmed', (
      tester,
    ) async {
      final notifier = await _pumpRules(tester);

      await tester.tap(
        find.text('b.com'),
        buttons: kSecondaryButton,
        kind: PointerDeviceKind.mouse,
      );
      await tester.pumpAndSettle();
      await tester.tap(menuItem(AppLocalizations.current.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppLocalizations.current.confirm));
      await tester.pumpAndSettle();

      expect(notifier.value.map((rule) => rule.id), [1, 3]);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('a right click opens it among search results too', (
      tester,
    ) async {
      await _pumpRules(tester);

      await tester.tap(find.byGlyph(AppGlyphs.search));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'c.com');
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(ContextMenuRegion),
          matching: find.text('c.com'),
        ),
        buttons: kSecondaryButton,
        kind: PointerDeviceKind.mouse,
      );
      await tester.pumpAndSettle();

      expect(menuItem(AppLocalizations.current.copy), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });

  testWidgets('a rules selection offers delete and select all but no copy', (
    tester,
  ) async {
    await _pumpRules(tester);

    await tester.tap(find.byType(CommonCheckBox).at(0));
    await tester.pump();

    expect(find.byTooltip(AppLocalizations.current.copy), findsNothing);
    expect(
      find.descendant(
        of: find.byType(TonalButtonGroup),
        matching: find.byType(IconButton),
      ),
      findsNWidgets(2),
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('groups list rounds only the first and last rows', (
    tester,
  ) async {
    await _pumpProxyGroups(tester);

    final rows = find.byType(DecorationListItem);
    expect(rows, findsNWidgets(3));
    final color = Theme.of(
      tester.element(rows.first),
    ).colorScheme.outlineVariant;
    final separator = paints
      ..something(
        (method, arguments) =>
            method == #drawRect &&
            (arguments[1] as Paint).color.toARGB32() == color.toARGB32(),
      );
    expect(tester.renderObject(rows.first), separator);
    expect(tester.renderObject(rows.last), isNot(separator));

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('groups list deletes the checked groups', (tester) async {
    final notifier = await _pumpProxyGroups(tester);

    await tester.tap(find.byType(CommonCheckBox).at(0));
    await tester.pump();
    await tester.tap(find.text('Group 2'));
    await tester.pump();
    await tester.tap(find.byTooltip(AppLocalizations.current.delete));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppLocalizations.current.confirm));
    await tester.pumpAndSettle();

    expect(notifier.deleted.single, {100, 102});

    await tester.pumpWidget(const SizedBox.shrink());
  });

  group('groups list menu', () {
    final menu = find.byType(CommonPopupMenu);
    Finder menuItem(String label) =>
        find.descendant(of: menu, matching: find.text(label));

    Future<void> rightClick(WidgetTester tester, String name) async {
      await tester.tap(
        find.text(name),
        buttons: kSecondaryButton,
        kind: PointerDeviceKind.mouse,
      );
      await tester.pumpAndSettle();
    }

    testWidgets('a right click opens it, and copy numbers the copies on', (
      tester,
    ) async {
      final notifier = await _pumpProxyGroups(tester);

      await rightClick(tester, 'Group 0');
      expect(menuItem(AppLocalizations.current.delete), findsOneWidget);
      await tester.tap(menuItem(AppLocalizations.current.copy));
      await tester.pumpAndSettle();

      expect(menu, findsNothing);
      final copy = notifier.value[1];
      expect(copy.name, 'Group 0-01');
      expect(copy.id, isNot(100));
      expect(copy.proxies, ['DIRECT']);
      expect(find.text('Group 0-01'), findsOneWidget);

      await rightClick(tester, 'Group 0-01');
      await tester.tap(menuItem(AppLocalizations.current.copy));
      await tester.pumpAndSettle();

      expect(notifier.value.map((group) => group.name), [
        'Group 0',
        'Group 0-01',
        'Group 0-02',
        'Group 1',
        'Group 2',
      ]);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('a touch long press opens it without moving the row', (
      tester,
    ) async {
      final notifier = await _pumpProxyGroups(tester);

      await tester.longPress(find.text('Group 0'));
      await tester.pumpAndSettle();

      expect(menuItem(AppLocalizations.current.copy), findsOneWidget);
      expect(notifier.orders, isEmpty);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('a right click opens it, and delete asks first', (
      tester,
    ) async {
      final notifier = await _pumpProxyGroups(tester);

      await tester.tap(
        find.text('Group 1'),
        buttons: kSecondaryButton,
        kind: PointerDeviceKind.mouse,
      );
      await tester.pumpAndSettle();
      await tester.tap(menuItem(AppLocalizations.current.delete));
      await tester.pumpAndSettle();
      expect(
        find.text(AppLocalizations.current.confirmDeleteProxyGroup),
        findsOneWidget,
      );
      await tester.tap(find.text(AppLocalizations.current.confirm));
      await tester.pumpAndSettle();

      expect(notifier.deleted.single, {101});

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('delete says when the profile still names the group', (
      tester,
    ) async {
      final notifier = await _pumpProxyGroups(tester, inUse: {'Group 1'});

      await tester.tap(
        find.text('Group 1'),
        buttons: kSecondaryButton,
        kind: PointerDeviceKind.mouse,
      );
      await tester.pumpAndSettle();
      await tester.tap(menuItem(AppLocalizations.current.delete));
      await tester.pumpAndSettle();
      expect(
        find.text(AppLocalizations.current.proxyGroupInUse('Group 1')),
        findsOneWidget,
      );
      await tester.tap(find.text(AppLocalizations.current.confirm));
      await tester.pumpAndSettle();

      expect(notifier.deleted.single, {101});

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('a row only drags by its handle in sort mode', (tester) async {
      final notifier = await _pumpProxyGroups(tester);
      final rowHeight = tester.getSize(find.byType(DecorationListItem).first);

      final pressed = await tester.startGesture(
        tester.getCenter(find.text('Group 0')),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
      await pressed.moveBy(Offset(0, rowHeight.height * 2));
      await tester.pump();
      await pressed.up();
      await tester.pumpAndSettle();
      expect(notifier.orders, isEmpty);

      await tester.tap(find.byGlyph(AppGlyphs.sort));
      await tester.pumpAndSettle();
      expect(find.byType(CommonCheckBox).hitTestable(), findsNothing);

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(SortHandle).first),
      );
      await tester.pump(kPressTimeout);
      await gesture.moveBy(const Offset(0, 20));
      await tester.pump();
      await gesture.moveBy(Offset(0, rowHeight.height * 2));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(menu, findsNothing);
      expect(notifier.orders.single.$1, 0);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('sort mode stays in the section and keeps adding', (
      tester,
    ) async {
      await _pumpProxyGroups(tester, pushed: true);
      final l10n = AppLocalizations.current;

      await tester.tap(find.byTooltip(l10n.sort));
      await tester.pumpAndSettle();
      expect(find.byType(CommonCheckBox).hitTestable(), findsNothing);
      expect(find.byType(BackButton).hitTestable(), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(CommonCheckBox).hitTestable(), findsNWidgets(3));

      await tester.tap(find.byTooltip(l10n.sort));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(l10n.add));
      await tester.pumpAndSettle();
      expect(find.byType(EditProxyGroupView), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('stays closed while groups are being checked', (tester) async {
      await _pumpProxyGroups(tester);

      await tester.tap(find.byType(CommonCheckBox).at(0));
      await tester.pump();
      await rightClick(tester, 'Group 1');

      expect(menu, findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });

  testWidgets('group editor sets the options mihomo reads per type', (
    tester,
  ) async {
    await _pumpProxyGroups(tester);
    tester.view.physicalSize = const Size(1400, 2600);
    final l10n = AppLocalizations.current;
    Finder row(String title) =>
        find.ancestor(of: find.text(title), matching: find.byType(FormRow));
    Finder valueIn(String title, String value) =>
        find.descendant(of: row(title), matching: find.text(value));
    Future<void> tapRow(String title) async {
      await tester.ensureVisible(row(title));
      await tester.tap(row(title));
      await tester.pumpAndSettle();
    }

    final addOption = find.widgetWithText(FormRow, l10n.addSettingEntry);
    Finder offered(String title) => find.descendant(
      of: find.byWidgetPredicate((widget) => widget is SelectionSheet),
      matching: find.text(title),
    );
    Future<void> openOptions() async {
      await tester.ensureVisible(addOption);
      await tester.tap(addOption);
      await tester.pumpAndSettle();
    }

    Future<void> add(String title) async {
      await openOptions();
      await tester.tap(offered(title));
      await tester.pumpAndSettle();
      expect(offered(title), findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Group 0'));
    await tester.pumpAndSettle();
    expect(row(l10n.emptyFallback), findsNothing);
    expect(row(l10n.defaultSelected), findsNothing);

    await add(l10n.defaultSelected);
    expect(valueIn(l10n.defaultSelected, l10n.defaultText), findsOneWidget);
    await tapRow(l10n.defaultSelected);
    await tester.tap(find.text('DIRECT'));
    await tester.pumpAndSettle();
    expect(valueIn(l10n.defaultSelected, 'DIRECT'), findsOneWidget);

    await add(l10n.emptyFallback);
    expect(valueIn(l10n.emptyFallback, 'COMPATIBLE'), findsOneWidget);
    await tapRow(l10n.emptyFallback);
    await tester.tap(find.text('REJECT'));
    await tester.pumpAndSettle();
    expect(valueIn(l10n.emptyFallback, 'REJECT'), findsOneWidget);

    await tapRow(l10n.proxyType);
    await tester.tap(find.text(GroupType.LoadBalance.name));
    await tester.pumpAndSettle();
    expect(row(l10n.defaultSelected), findsNothing);

    await add(l10n.strategy);
    await tapRow(l10n.strategy);
    await tester.tap(find.text(LoadBalanceStrategy.roundRobin.value));
    await tester.pumpAndSettle();
    await openOptions();
    expect(offered(l10n.hashByInUser), findsNothing);
    expect(offered(l10n.defaultSelected), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tapRow(l10n.proxyType);
    await tester.tap(find.text(GroupType.Selector.name).last);
    await tester.pumpAndSettle();
    expect(valueIn(l10n.defaultSelected, 'DIRECT'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('group options left at their defaults stay after reopening', (
    tester,
  ) async {
    await _pumpProxyGroups(tester);
    tester.view.physicalSize = const Size(1400, 2600);
    final l10n = AppLocalizations.current;
    Finder row(String title) =>
        find.ancestor(of: find.text(title), matching: find.byType(FormRow));
    final addOption = find.widgetWithText(FormRow, l10n.addSettingEntry);
    Future<void> add(String title) async {
      await tester.ensureVisible(addOption);
      await tester.tap(addOption);
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byWidgetPredicate((widget) => widget is SelectionSheet),
          matching: find.text(title),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
    }

    Future<void> setType(GroupType type) async {
      await tester.ensureVisible(row(l10n.proxyType));
      await tester.tap(row(l10n.proxyType));
      await tester.pumpAndSettle();
      await tester.tap(find.text(type.name).last);
      await tester.pumpAndSettle();
    }

    final loadBalanceOptions = [
      l10n.emptyFallback,
      l10n.expectedStatus,
      l10n.hashByInUser,
    ];
    await tester.tap(find.text('Group 0'));
    await tester.pumpAndSettle();
    await add(l10n.defaultSelected);
    await setType(GroupType.LoadBalance);
    for (final title in loadBalanceOptions) {
      await add(title);
    }
    await tester.tap(find.byTooltip(currentAppLocalizations.save));
    await _expectClosesWithoutIssues(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Group 0'));
    await tester.pumpAndSettle();
    for (final title in loadBalanceOptions) {
      expect(row(title), findsOneWidget, reason: title);
    }
    ProviderScope.containerOf(tester.element(find.byType(EditProxyGroupView)))
        .read(proxyGroupProvider.notifier)
        .update((state) => state.copyWith(emptyFallback: ''));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: row(l10n.emptyFallback),
        matching: find.text('COMPATIBLE'),
      ),
      findsOneWidget,
    );
    await setType(GroupType.Selector);
    expect(row(l10n.defaultSelected), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('group options emptied after holding a value are gone after '
      'reopening', (tester) async {
    await _pumpProxyGroups(tester);
    tester.view.physicalSize = const Size(1400, 2600);
    final l10n = AppLocalizations.current;
    final titles = [l10n.testUrl, l10n.timeout, l10n.expectedStatus];
    Finder row(String title) =>
        find.ancestor(of: find.text(title), matching: find.byType(FormRow));
    Finder fieldIn(String title) =>
        find.descendant(of: row(title), matching: find.byType(EditableText));
    final addOption = find.widgetWithText(FormRow, l10n.addSettingEntry);

    await tester.tap(find.text('Group 0'));
    await tester.pumpAndSettle();
    for (final title in titles) {
      await tester.ensureVisible(addOption);
      await tester.tap(addOption);
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byWidgetPredicate((widget) => widget is SelectionSheet),
          matching: find.text(title),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
    await tester.enterText(fieldIn(l10n.expectedStatus), '200');
    for (final title in titles) {
      await tester.enterText(fieldIn(title), '');
    }
    await tester.pump();
    await tester.tap(find.byTooltip(currentAppLocalizations.save));
    await _expectClosesWithoutIssues(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Group 0'));
    await tester.pumpAndSettle();
    for (final title in titles) {
      expect(row(title), findsNothing, reason: title);
    }

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a saved new group closes without flagging its own copy', (
    tester,
  ) async {
    _setViewport(tester);
    final profile = Profile.custom();
    final proxyGroups = _TestProxyGroups(const []);
    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(() => TestProfiles([profile])),
        currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
        proxyGroupsProvider.overrideWith2((_) => proxyGroups),
        customProfileDataProvider(profile.id).overrideWith((ref) {
          final groups =
              ref.watch(proxyGroupsProvider(profile.id)).value ??
              const <ProxyGroup>[];
          return CustomProfileData(
            proxyGroups: groups,
            ruleTargets: {
              ...RuleTarget.baseTargets,
              ...groups.map((group) => group.name),
            },
          );
        }),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(1400, 1000));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(child: _proxyGroupsPage(profile.id)),
      ),
    );
    await tester.pump();
    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();
    ProviderScope.containerOf(tester.element(find.byType(EditProxyGroupView)))
        .read(proxyGroupProvider.notifier)
        .update(
          (state) => state.copyWith(name: 'Mine', proxies: const ['DIRECT']),
        );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(currentAppLocalizations.save));
    await _expectClosesWithoutIssues(tester);

    expect(proxyGroups.value.map((group) => group.name), ['Mine']);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  group('saving a group', () {
    late _TestProxyGroups proxyGroups;
    late _MockCore core;
    late ProviderContainer container;

    Future<ProxyGroupProvider> openNewGroup(WidgetTester tester) async {
      _setViewport(tester);
      final profile = Profile.custom();
      proxyGroups = _TestProxyGroups(const []);
      core = _MockCore();
      registerFallbackValue(<String>[]);
      container = ProviderContainer(
        overrides: [
          coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
          profilesProvider.overrideWith(() => TestProfiles([profile])),
          currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
          proxyGroupsProvider.overrideWith2((_) => proxyGroups),
          customProfileDataProvider(profile.id).overrideWith((ref) {
            final groups =
                ref.watch(proxyGroupsProvider(profile.id)).value ??
                const <ProxyGroup>[];
            return CustomProfileData(
              proxyGroups: groups,
              ruleTargets: {
                ...RuleTarget.baseTargets,
                ...groups.map((group) => group.name),
              },
            );
          }),
        ],
      );
      addTearDown(container.dispose);
      globalState.container = container;
      container
          .read(viewSizeProvider.notifier)
          .update((_) => const Size(1400, 1000));
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(child: _proxyGroupsPage(profile.id)),
        ),
      );
      await tester.pump();
      await tester.tap(find.byTooltip('Add'));
      await tester.pumpAndSettle();
      return ProviderScope.containerOf(
        tester.element(find.byType(EditProxyGroupView)),
      ).read(proxyGroupProvider.notifier);
    }

    testWidgets('an empty fallback the core refuses keeps the group unsaved', (
      tester,
    ) async {
      final form = await openNewGroup(tester);
      form.update(
        (state) => state.copyWith(
          name: 'Mine',
          proxies: const ['DIRECT'],
          emptyFallback: 'Gone',
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(currentAppLocalizations.save));
      await tester.pumpAndSettle();

      expect(proxyGroups.value, isEmpty);
      expect(find.byType(EditProxyGroupView), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('edits made while the core checks the filters are saved', (
      tester,
    ) async {
      final form = await openNewGroup(tester);
      final checked = Completer<List<String>>();
      when(() => core.validateFilters(any())).thenAnswer((_) => checked.future);
      form.update(
        (state) => state.copyWith(
          name: 'Mine',
          proxies: const ['DIRECT'],
          filter: 'HK',
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(currentAppLocalizations.save));
      await tester.pump();
      form.update((state) => state.copyWith(name: 'Later'));
      when(() => core.validateFilters(any())).thenAnswer((_) async => ['', '']);
      checked.complete(['', '']);
      await _expectClosesWithoutIssues(tester);

      expect(proxyGroups.value.map((group) => group.name), ['Later']);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });

  testWidgets('group editor keeps long values inside its rows', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final profile = Profile.custom();
    final proxyGroups = [
      ProxyGroup(
        id: 100,
        profileId: profile.id,
        name: 'a-very-long-proxy-group-name-that-goes-on-and-on',
        type: GroupType.URLTest,
        icon: 'https://example.com/a/very/long/path/to/an/icon/file/name.png',
        filter: '(?i)hk|hong ?kong|an extremely long filter expression here',
        url: 'https://www.gstatic.com/generate_204/a/very/long/url/path',
      ),
    ];
    final core = _MockCore();
    registerFallbackValue(<String>[]);
    when(() => core.validateFilters(any())).thenAnswer((_) async => ['', '']);
    final container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        profilesProvider.overrideWith(() => TestProfiles([profile])),
        currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
        proxyGroupsProvider.overrideWith2((_) => _TestProxyGroups(proxyGroups)),
        customProfileDataProvider(profile.id).overrideWithValue(
          CustomProfileData(
            proxyGroups: proxyGroups,
            ruleTargets: RuleTarget.baseTargets,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(360, 800));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(child: _proxyGroupsPage(profile.id)),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text(proxyGroups.single.name));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(FormRow), findsWidgets);

    await tester.enterText(find.byType(TextFormField).first, 'y' * 400);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a provider dragged above the proxies is listed first', (
    tester,
  ) async {
    await _pumpProxyGroups(tester);
    tester.view.physicalSize = const Size(1400, 2600);
    await tester.tap(find.text('Group 0'));
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(EditProxyGroupView)),
    );
    container
        .read(proxyGroupProvider.notifier)
        .update(
          (state) => state.copyWith(
            proxies: const ['DIRECT', 'REJECT'],
            use: const ['provider'],
          ),
        );
    await tester.pumpAndSettle();
    Finder row(String name) => find.ancestor(
      of: find.text(name),
      matching: find.byType(DecorationListItem),
    );
    final handle = find.descendant(
      of: row('provider'),
      matching: find.byType(SortHandle),
    );
    await tester.ensureVisible(handle);
    await tester.pumpAndSettle();
    final directTop = tester.getTopLeft(row('DIRECT')).dy;
    final rise = tester.getCenter(handle).dy - directTop;

    final gesture = await tester.startGesture(tester.getCenter(handle));
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    for (var step = 0; step < 4; step++) {
      await gesture.moveBy(Offset(0, -rise / 4 - 10));
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.getTopLeft(row('DIRECT')).dy, greaterThan(directTop));

    await gesture.up();
    await tester.pumpAndSettle();
    final group = container.read(proxyGroupProvider);
    expect(group.proxies, ['DIRECT', 'REJECT']);
    expect(group.use, ['provider']);
    expect(group.usePosition, {'provider': 0});

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('rule invalid state refreshes when rule targets change', (
    tester,
  ) async {
    _setViewport(tester);
    final profile = Profile.custom();
    final rules = [
      const Rule(
        id: 1,
        content: 'example.com',
        ruleTarget: 'missing',
        order: '1',
      ),
    ];
    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(() => TestProfiles([profile])),
        currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
        profileRulesProvider.overrideWith2((_) => _TestProfileRules(rules)),
        customProfileDataProvider(profile.id).overrideWith((ref) {
          return ref.watch(_testCustomDataProvider);
        }),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(1400, 1000));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(child: CustomRulesView(profile.id)),
      ),
    );
    await tester.pump();

    expect(find.byGlyph(AppGlyphs.info), findsOneWidget);

    container.read(_testCustomDataProvider.notifier).setRuleTargets({
      ...container.read(_testCustomDataProvider).ruleTargets,
      'missing',
    });
    await tester.pump();

    expect(find.byGlyph(AppGlyphs.info), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'a rule the core would reject is flagged despite a DIRECT target',
    (tester) async {
      _setViewport(tester);
      final profile = Profile.custom();
      final rules = [
        Rule.parse('NETWORK,tcp,DIRECT', id: 1).copyWith(order: '1'),
        Rule.parse('NETWORK,icmp,DIRECT', id: 2).copyWith(order: '2'),
        Rule.parse('RULE-SET,known,DIRECT', id: 3).copyWith(order: '3'),
        Rule.parse('RULE-SET,gone,DIRECT', id: 4).copyWith(order: '4'),
      ];
      final container = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(() => TestProfiles([profile])),
          currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
          profileRulesProvider.overrideWith2((_) => _TestProfileRules(rules)),
          customProfileDataProvider(profile.id).overrideWithValue(
            const CustomProfileData(
              ruleTargets: {'DIRECT'},
              ruleProviders: {'known'},
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      globalState.container = container;
      container
          .read(viewSizeProvider.notifier)
          .update((_) => const Size(1400, 1000));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(child: CustomRulesView(profile.id)),
        ),
      );
      await tester.pump();

      expect(find.byGlyph(AppGlyphs.info), findsNWidgets(2));

      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  Future<void> pumpNodes(WidgetTester tester, List<CustomProxy> nodes) async {
    _setViewport(tester);
    final container = ProviderContainer(
      overrides: [
        customGroupNamesProvider.overrideWith(
          (_) => Stream.value(const <String>{}),
        ),
        customProxiesProvider.overrideWith(
          () => _RecordingCustomProxies(nodes),
        ),
        customProxyCoreErrorsProvider.overrideWith((_) async => const {}),
        clashProvidersActionProvider.overrideWith(
          _RecordingClashProvidersAction.new,
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(500, 1000));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: CustomProxiesView()),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  const nodes = [
    CustomProxy(
      id: 1,
      definition: {
        'name': 'HK',
        'type': 'ss',
        'server': 'hk.example.com',
        'port': 8388,
        'udp': true,
      },
    ),
    CustomProxy(
      id: 2,
      definition: {
        'name': 'JP',
        'type': 'vless',
        'server': 'jp.example.com',
        'port': 443,
        'network': 'ws',
        'tls': true,
      },
    ),
  ];

  testWidgets('each node shows only its name and type', (tester) async {
    await pumpNodes(tester, nodes);
    final l = currentAppLocalizations;

    expect(find.text(l.proxies), findsOneWidget);
    expect(find.text('ss'), findsOneWidget);
    expect(find.text('vless'), findsOneWidget);
    expect(find.text('hk.example.com:8388'), findsNothing);
    expect(find.byType(MetaChip), findsNothing);
    expect(find.byType(SliverReorderableList), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('an empty nodes page offers to add one', (tester) async {
    await pumpNodes(tester, const []);
    final l = currentAppLocalizations;

    expect(find.text(l.nullTip(l.proxies)), findsOneWidget);
    expect(find.widgetWithText(FilledButton, l.add), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a second save while the core validates stores nothing more', (
    tester,
  ) async {
    _setViewport(tester);
    final validated = Completer<List<String>>();
    final proxies = _RecordingCustomProxies();
    final core = _MockCore();
    registerFallbackValue(<Map<String, dynamic>>[]);
    when(() => core.validateProxies(any())).thenAnswer((_) => validated.future);
    final container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        customGroupNamesProvider.overrideWith(
          (_) => Stream.value(const <String>{}),
        ),
        customProxiesProvider.overrideWith(() => proxies),
        clashProvidersActionProvider.overrideWith(
          _RecordingClashProvidersAction.new,
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(500, 1000));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: CustomProxiesView()),
      ),
    );
    await tester.pump();
    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();
    await tester.tap(_menuItem('Add'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Mine');
    await tester.tap(find.byTooltip('Save'));
    await tester.pump();
    await tester.tap(find.byTooltip('Save'));
    await tester.pump();

    validated.complete(['']);
    await tester.pumpAndSettle();

    expect(proxies.saved.map((proxy) => proxy.name), ['Mine']);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a saved new proxy closes without flagging its own copy or an '
      'outdated core verdict', (tester) async {
    _setViewport(tester);
    final proxies = _RecordingCustomProxies();
    final core = _MockCore();
    registerFallbackValue(<Map<String, dynamic>>[]);
    when(() => core.validateProxies(any())).thenAnswer((invocation) async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return [
        for (final definition
            in invocation.positionalArguments.single as List<Object?>)
          (definition! as Map)['server'] == null ? 'missing server' : '',
      ];
    });
    final container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        customGroupNamesProvider.overrideWith(
          (_) => Stream.value(const <String>{}),
        ),
        customProxiesProvider.overrideWith(() => proxies),
        clashProvidersActionProvider.overrideWith(
          _RecordingClashProvidersAction.new,
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(500, 1000));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: CustomProxiesView()),
      ),
    );
    await tester.pump();
    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();
    await tester.tap(_menuItem('Add'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Mine');
    await tester.pump(const Duration(seconds: 1));
    await tester.enterText(find.byType(TextFormField).at(1), 'example.com');
    await tester.tap(find.byTooltip('Save'));
    await _expectClosesWithoutIssues(tester);
    await tester.pumpAndSettle();

    expect(proxies.saved.map((proxy) => proxy.name), ['Mine']);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a new proxy shows what the core rejects only after a save', (
    tester,
  ) async {
    _setViewport(tester);
    final core = _MockCore();
    registerFallbackValue(<Map<String, dynamic>>[]);
    when(
      () => core.validateProxies(any()),
    ).thenAnswer((_) async => ['missing server']);
    final container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        customGroupNamesProvider.overrideWith(
          (_) => Stream.value(const <String>{}),
        ),
        customProxiesProvider.overrideWith(_RecordingCustomProxies.new),
        clashProvidersActionProvider.overrideWith(
          _RecordingClashProvidersAction.new,
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(500, 1000));
    final rejected = find.descendant(
      of: find.byType(ErrorBanner),
      matching: find.textContaining('missing server'),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: CustomProxiesView()),
      ),
    );
    await tester.pump();
    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();
    await tester.tap(_menuItem('Add'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Mine');
    await tester.pump(const Duration(seconds: 1));

    expect(rejected, findsNothing);

    await tester.tap(find.byTooltip('Save'));
    await tester.pumpAndSettle();
    await _dismissSaveBlocked(tester, 'missing server');

    expect(rejected, findsOneWidget);
    expect(find.textContaining('missing server'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a save the core cannot check is refused in the banner', (
    tester,
  ) async {
    _setViewport(tester);
    final core = _MockCore();
    registerFallbackValue(<Map<String, dynamic>>[]);
    when(
      () => core.validateProxies(any()),
    ).thenAnswer((_) async => throw Exception('core down'));
    final proxies = _RecordingCustomProxies();
    final container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        customGroupNamesProvider.overrideWith(
          (_) => Stream.value(const <String>{}),
        ),
        customProxiesProvider.overrideWith(() => proxies),
        clashProvidersActionProvider.overrideWith(
          _RecordingClashProvidersAction.new,
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(500, 1000));
    final rejected = find.descendant(
      of: find.byType(ErrorBanner),
      matching: find.textContaining('core down'),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: CustomProxiesView()),
      ),
    );
    await tester.pump();
    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();
    await tester.tap(_menuItem('Add'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Mine');
    await tester.pump(const Duration(seconds: 1));
    expect(rejected, findsNothing);

    await tester.tap(find.byTooltip('Save'));
    await tester.pumpAndSettle();
    await _dismissSaveBlocked(tester, 'core down');

    expect(rejected, findsOneWidget);
    expect(find.textContaining('core down'), findsOneWidget);
    expect(proxies.saved, isEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('an easytier proxy edits its network in place of a server', (
    tester,
  ) async {
    _setViewport(tester);
    final proxies = _RecordingCustomProxies(const [
      CustomProxy(id: 1, definition: {'name': 'Mesh', 'type': 'easytier'}),
    ]);
    final core = _MockCore();
    registerFallbackValue(<Map<String, dynamic>>[]);
    when(() => core.validateProxies(any())).thenAnswer((_) async => ['']);
    final container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        customGroupNamesProvider.overrideWith(
          (_) => Stream.value(const <String>{}),
        ),
        customProxiesProvider.overrideWith(() => proxies),
        clashProvidersActionProvider.overrideWith(
          _RecordingClashProvidersAction.new,
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(500, 1000));
    Finder row(String title) => find.widgetWithText(FormRow, title);
    Finder fieldIn(String title) =>
        find.descendant(of: row(title), matching: find.byType(TextFormField));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: CustomProxiesView()),
      ),
    );
    await tester.pump();
    final l10n = AppLocalizations.current;
    await tester.tap(find.text('Mesh'));
    await tester.pumpAndSettle();

    expect(row(l10n.server), findsNothing);
    expect(row(l10n.port), findsNothing);
    expect(
      find.descendant(of: row(l10n.peers), matching: find.text(l10n.none)),
      findsOneWidget,
    );

    await tester.enterText(fieldIn(l10n.networkName), 'home');
    await tester.enterText(fieldIn(l10n.networkSecret), 'secret');
    await tester.tap(row(l10n.peers));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(ListEditorPage<String, String>),
        matching: find.byTooltip(l10n.add),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(EntryDialog<String>),
        matching: find.byType(TextFormField),
      ),
      'tcp://peer.example.com:11010',
    );
    await tester.tap(find.text(l10n.confirm));
    await tester.pumpAndSettle();
    expect(find.text('tcp://peer.example.com:11010'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: row(l10n.peers),
        matching: find.text(l10n.itemsCount(1)),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip(l10n.save));
    await tester.pumpAndSettle();

    expect(proxies.saved.single.definition, {
      'name': 'Mesh',
      'type': 'easytier',
      'network-name': 'home',
      'network-secret': 'secret',
      'peers': ['tcp://peer.example.com:11010'],
    });

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('an app-level proxy saves outside a profile and reapplies on '
      'leaving', (tester) async {
    _setViewport(tester);
    final proxies = _RecordingCustomProxies();
    final action = _RecordingClashProvidersAction();
    final core = _MockCore();
    registerFallbackValue(<Map<String, dynamic>>[]);
    when(() => core.validateProxies(any())).thenAnswer((_) async => ['']);
    final container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        customGroupNamesProvider.overrideWith(
          (_) => Stream.value(const <String>{}),
        ),
        customProxiesProvider.overrideWith(() => proxies),
        clashProvidersActionProvider.overrideWith(() => action),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(500, 1000));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: CustomProxiesView()),
      ),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();
    await tester.tap(_menuItem('Add'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Home');
    await tester.tap(find.byTooltip('Save'));
    await tester.pumpAndSettle();

    expect(proxies.saved.map((proxy) => proxy.name), ['Home']);
    expect(action.applied, isEmpty);

    await tester.pumpWidget(const SizedBox.shrink());

    expect(action.applied, [
      {'Home'},
    ]);
  });

  testWidgets('app-level proxies left as they were, or changed only in the '
      'options they list empty, do not reapply', (tester) async {
    _setViewport(tester);
    final action = _RecordingClashProvidersAction();
    final core = _MockCore();
    registerFallbackValue(<Map<String, dynamic>>[]);
    when(() => core.validateProxies(any())).thenAnswer((_) async => ['']);
    final container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        customGroupNamesProvider.overrideWith(
          (_) => Stream.value(const <String>{}),
        ),
        customProxiesProvider.overrideWith(
          () => _RecordingCustomProxies(const [
            CustomProxy(id: 1, definition: {'name': 'Home', 'type': 'ss'}),
          ]),
        ),
        clashProvidersActionProvider.overrideWith(() => action),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(500, 1000));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: CustomProxiesView()),
      ),
    );
    await tester.pumpAndSettle();
    container.read(customProxiesProvider.notifier).value = const [
      CustomProxy(
        id: 1,
        definition: {'name': 'Home', 'type': 'ss'},
        emptyOptions: {ProxyField.tfo},
      ),
    ];
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());

    expect(action.applied, isEmpty);
  });

  testWidgets('dialers list the declared proxies and offer what does not '
      'loop back', (tester) async {
    _setViewport(tester);
    const profileId = 1;
    final dialers = _RecordingProxyDialers();
    final container = ProviderContainer(
      overrides: [
        customGroupNamesProvider.overrideWith(
          (_) => Stream.value(const <String>{}),
        ),
        customProxiesProvider.overrideWith(
          () => _RecordingCustomProxies(const [
            CustomProxy(id: 10, definition: {'name': 'Home', 'type': 'ss'}),
            CustomProxy(id: 11, definition: {'name': 'Work', 'type': 'ss'}),
            CustomProxy(id: 12, definition: {'name': 'Spare', 'type': 'ss'}),
          ]),
        ),
        proxyDialersProvider.overrideWith2((_) => dialers),
        customProfileDataProvider(profileId).overrideWithValue(
          const CustomProfileData(
            proxyGroups: [
              ProxyGroup(
                id: 1,
                name: 'Landing',
                type: GroupType.Selector,
                proxies: ['Work', 'Home'],
              ),
              ProxyGroup(
                id: 2,
                name: 'Relay',
                type: GroupType.Selector,
                proxies: ['DIRECT'],
              ),
            ],
            ruleTargets: {'DIRECT', 'Landing', 'Relay'},
            proxies: {'Home', 'Work', 'Spare'},
            dialers: {'Home': 'Work'},
          ),
        ),
        customProfileIssuesProvider(profileId).overrideWithValue(
          const CustomProfileIssues(
            dialers: {
              11: [CustomIssue.missingDialer('Gone')],
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(1400, 1000));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: CustomProxyDialersView(profileId)),
      ),
    );
    await tester.pump();

    expect(find.text(currentAppLocalizations.none), findsNothing);
    expect(find.text('Spare'), findsNothing);
    expect(find.byGlyph(AppGlyphs.info), findsOneWidget);

    Finder offered(String name) => find.descendant(
      of: find.byType(SelectionSheet<String>),
      matching: find.text(name),
    );

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(offered(currentAppLocalizations.localProxies), findsOneWidget);
    expect(offered('Work'), findsOneWidget);
    expect(offered('Home'), findsNothing);
    expect(offered('Relay'), findsOneWidget);
    expect(offered('Landing'), findsNothing);
    await tester.tap(offered('Work'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Work'));
    await tester.pumpAndSettle();
    expect(offered('Home'), findsNothing);
    expect(offered('Work'), findsNothing);
    expect(offered('Landing'), findsNothing);
    await tester.tap(offered('Relay'));
    await tester.pumpAndSettle();

    expect(dialers.calls, [(10, 'Work'), (11, 'Relay')]);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('quick edit opens over the sheet but beside the navigation', (
    tester,
  ) async {
    _setViewport(tester);
    final profile = Profile.custom();
    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(() => TestProfiles([profile])),
        currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
        proxyGroupsProvider.overrideWith2((_) => _TestProxyGroups(const [])),
        customProfileDataProvider(
          profile.id,
        ).overrideWithValue(const CustomProfileData()),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(1400, 1000));
    final pageNavigator = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Navigator(
            key: pageNavigator,
            pages: [MaterialPage(child: _proxyGroupsPage(profile.id))],
            onDidRemovePage: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(currentAppLocalizations.quickEdit));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final editorNavigator = tester.state<NavigatorState>(
      find
          .ancestor(
            of: find.byType(EditorPage),
            matching: find.byType(Navigator),
          )
          .first,
    );
    expect(editorNavigator, same(pageNavigator.currentState));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
