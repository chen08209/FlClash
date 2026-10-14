import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/tun.dart';
import 'package:fl_clash/views/profiles/add.dart';
import 'package:fl_clash/views/profiles/custom/custom.dart';
import 'package:fl_clash/views/profiles/custom/providers.dart';
import 'package:fl_clash/views/profiles/extend/extend.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _TestProfileRules extends ProfileRules {
  final List<Rule> initial;

  _TestProfileRules(this.initial);

  @override
  Stream<List<Rule>> build(int profileId) => Stream.value(initial);

  @override
  void order(int oldIndex, int newIndex) {}
}

class _TestProxyGroups extends ProxyGroups {
  final List<ProxyGroup> initial;

  _TestProxyGroups(this.initial);

  @override
  Stream<List<ProxyGroup>> build(int profileId) => Stream.value(initial);

  @override
  void order(int oldIndex, int newIndex) {}
}

class _TestCustomProxies extends CustomProxies {
  final List<CustomProxy> initial;

  _TestCustomProxies(this.initial);

  @override
  Stream<List<CustomProxy>> build() => Stream.value(initial);
}

class _RecordingProfilesAction extends ProfilesAction {
  @override
  Future<void> deleteProfile(int id) =>
      ref.read(profilesProvider.notifier).del(id);
}

class _RecordingSetupAction extends SetupAction {
  int autoApplyCalls = 0;

  @override
  void autoApplyProfile() {
    autoApplyCalls++;
  }
}

void main() {
  void setViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> expectAppliesOnUnmount(
    WidgetTester tester,
    ProviderContainer container,
    Widget view, {
    void Function()? edit,
  }) async {
    addTearDown(container.dispose);
    globalState.container = container;
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(1400, 1000));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(child: view),
      ),
    );
    await tester.pump();
    expect(find.byWidget(view), findsOneWidget);
    if (edit != null) {
      await tester.pump();
      edit();
      await tester.pump();
    }

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(
      (container.read(setupActionProvider.notifier) as _RecordingSetupAction)
          .autoApplyCalls,
      1,
    );
  }

  testWidgets('unmounting ExtendView applies the profile without using ref', (
    tester,
  ) async {
    setViewport(tester);
    final profile = Profile.normal();
    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(() => TestProfiles([profile])),
        currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
        profileRulesProvider.overrideWith2((_) => _TestProfileRules([])),
        clashConfigProvider(profile.id).overrideWithValue(
          const AsyncData(
            ClashConfig(
              proxies: [Proxy(name: 'DIRECT', type: 'Direct')],
            ),
          ),
        ),
        setupActionProvider.overrideWith(_RecordingSetupAction.new),
      ],
    );

    await expectAppliesOnUnmount(
      tester,
      container,
      ExtendView(profileId: profile.id),
    );
  });

  testWidgets(
    'unmounting an edited CustomProfileView stamps and applies the profile '
    'without using ref',
    (tester) async {
      setViewport(tester);
      final edited = DateTime(2020);
      final profile = Profile.custom(
        label: 'mine',
      ).copyWith(lastUpdateDate: edited);
      final container = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(() => TestProfiles([profile])),
          currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
          profileRulesProvider.overrideWith2((_) => _TestProfileRules([])),
          proxyGroupsProvider.overrideWith2((_) => _TestProxyGroups([])),
          customProfileDataProvider(
            profile.id,
          ).overrideWithValue(const CustomProfileData(ruleTargets: {'DIRECT'})),
          setupActionProvider.overrideWith(_RecordingSetupAction.new),
        ],
      );

      await expectAppliesOnUnmount(
        tester,
        container,
        CustomProfileView(profileId: profile.id),
        edit: () => container
            .read(profilesProvider.notifier)
            .updateProfile(
              profile.id,
              (profile) => profile.copyWith(label: 'renamed'),
            ),
      );
      expect(
        container
            .read(profileProvider(profile.id))!
            .lastUpdateDate!
            .isAfter(edited),
        isTrue,
      );
    },
  );

  group('CustomProfileView', () {
    Future<void> pumpCustom(
      WidgetTester tester, {
      List<ProxyGroup> groups = const [],
    }) async {
      setViewport(tester);
      final profile = Profile.custom(label: 'mine').copyWith(
        overrides: const ProfileOverrides(
          dns: Dns(enable: false),
          dnsOverrideKeys: {DnsOverrideKey.enable},
          ntp: Ntp(enable: true),
          ntpOverrideKeys: {NtpOverrideKey.enable},
          sniffer: Sniffer(enable: true),
        ),
      );
      final container = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(() => TestProfiles([profile])),
          currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
          profileRulesProvider.overrideWith2((_) => _TestProfileRules([])),
          proxyGroupsProvider.overrideWith2((_) => _TestProxyGroups(groups)),
          customProfileDataProvider(profile.id).overrideWithValue(
            CustomProfileData(
              proxyGroups: groups,
              proxyProviders: const {'Sub'},
              ruleTargets: {'DIRECT', for (final group in groups) group.name},
            ),
          ),
          setupActionProvider.overrideWith(_RecordingSetupAction.new),
          customProxiesProvider.overrideWith(
            () => _TestCustomProxies(const []),
          ),
          customProxyCoreErrorsProvider.overrideWith((_) async => const {}),
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
          child: TestApp(child: CustomProfileView(profileId: profile.id)),
        ),
      );
      await tester.pumpAndSettle();
    }

    Finder tile(String label) =>
        find.ancestor(of: find.text(label), matching: find.byType(CommonCard));

    String? statusOf(WidgetTester tester, String label) {
      final l = currentAppLocalizations;
      return tester
          .widget<Text>(
            find.descendant(
              of: tile(label),
              matching: find.byWidgetPredicate(
                (widget) =>
                    widget is Text &&
                    (widget.data == l.enabled || widget.data == l.disabled),
              ),
            ),
          )
          .data;
    }

    testWidgets('leads its proxy groups with a tile per section', (
      tester,
    ) async {
      await pumpCustom(
        tester,
        groups: const [
          ProxyGroup(id: 1, name: 'Proxy', type: GroupType.Selector),
        ],
      );

      final l = currentAppLocalizations;
      expect(find.text('mine'), findsOneWidget);
      expect(find.text(l.preview), findsNothing);
      expect(tile(l.rule), findsOneWidget);
      expect(statusOf(tester, 'DNS'), l.disabled);
      expect(
        find.descendant(
          of: tile(l.more),
          matching: find.text(l.sectionsInEffect(1)),
        ),
        findsOneWidget,
      );
      final header = find.widgetWithText(ListHeader, l.proxyGroup);
      expect(
        tester.getTopLeft(header).dy,
        lessThan(tester.getTopLeft(find.text('Proxy')).dy),
      );
    });

    testWidgets('counts the providers its groups name on a tile', (
      tester,
    ) async {
      await pumpCustom(
        tester,
        groups: const [
          ProxyGroup(
            id: 1,
            name: 'Proxy',
            type: GroupType.Selector,
            use: ['Sub'],
          ),
        ],
      );
      final l = currentAppLocalizations;

      expect(tile(l.nodes), findsNothing);
      expect(
        find.descendant(of: tile(l.providers), matching: find.text('1')),
        findsOneWidget,
      );
      await tester.tap(tile(l.providers));
      await tester.pumpAndSettle();
      expect(find.byType(CustomProvidersView), findsOneWidget);
      expect(find.text('Sub'), findsOneWidget);
    });

    testWidgets('offers importing a config from a link or a file', (
      tester,
    ) async {
      await pumpCustom(tester);
      final l = currentAppLocalizations;

      await tester.tap(find.widgetWithText(FilledButton, l.import));
      await tester.pumpAndSettle();
      expect(find.text(l.importUrl), findsOneWidget);
      expect(find.text(l.importFile), findsOneWidget);
    });

    testWidgets('keeps its tiles above an empty group list', (tester) async {
      await pumpCustom(tester);

      final l = currentAppLocalizations;
      expect(find.text(l.proxyGroupEmpty), findsOneWidget);
      expect(tile('DNS'), findsOneWidget);
      expect(
        tester.getTopLeft(tile('DNS')).dy,
        lessThan(tester.getTopLeft(find.text(l.proxyGroupEmpty)).dy),
      );
    });

    testWidgets('gathers the rarely changed sections on a more page', (
      tester,
    ) async {
      await pumpCustom(tester);
      final l = currentAppLocalizations;
      Finder row(String title) =>
          find.ancestor(of: find.text(title), matching: find.byType(ListTile));
      Finder state(String title, String text) =>
          find.descendant(of: row(title), matching: find.text(text));

      expect(tile(l.dialerProxy), findsNothing);
      await tester.tap(tile(l.more));
      await tester.pumpAndSettle();
      expect(state(l.dialerProxy, l.none), findsOneWidget);
      expect(state('NTP', l.enabled), findsOneWidget);
      expect(state(l.sniffer, l.disabled), findsOneWidget);
      expect(state(l.tun, l.defaultText), findsOneWidget);

      final container = globalState.container;
      container
          .read(profilesProvider.notifier)
          .updateProfile(
            container.read(currentProfileIdProvider)!,
            (profile) => profile.copyWith.overrides(
              tunOverrideKeys: {TunOverrideKey.excludeInterface},
            ),
          );
      await tester.pump();
      expect(state(l.tun, l.settingsCount(1)), findsOneWidget);

      await tester.tap(row(l.tun));
      await tester.pumpAndSettle();
      expect(find.byType(TunView), findsOneWidget);
    });
  });

  group('a new custom profile', () {
    ProviderContainer buildContainer(
      List<Profile> profiles, {
      List<ProxyGroup> groups = const [],
    }) {
      final container = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(() => TestProfiles(profiles)),
          profileRulesProvider.overrideWith2((_) => _TestProfileRules([])),
          proxyGroupsProvider.overrideWith2((_) => _TestProxyGroups(groups)),
          customProfileDataProvider.overrideWith(
            (_, _) => CustomProfileData(
              proxyGroups: groups,
              ruleTargets: {'DIRECT', for (final group in groups) group.name},
            ),
          ),
          setupActionProvider.overrideWith(_RecordingSetupAction.new),
          profilesActionProvider.overrideWith(_RecordingProfilesAction.new),
          customProxiesProvider.overrideWith(
            () => _TestCustomProxies(const []),
          ),
          customProxyCoreErrorsProvider.overrideWith((_) async => const {}),
        ],
      );
      addTearDown(container.dispose);
      globalState.container = container;
      container
          .read(viewSizeProvider.notifier)
          .update((_) => const Size(1400, 1000));
      return container;
    }

    Future<void> pumpOver(
      WidgetTester tester,
      ProviderContainer container,
      Widget editor,
    ) async {
      setViewport(tester);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(
            child: Builder(
              builder: (context) => FilledButton(
                onPressed: () => BaseNavigator.push(context, editor),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    final editor = find.byType(CustomProfileView);

    Future<void> leave(WidgetTester tester) async {
      await globalState.navigatorKey.currentState!.maybePop();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 1));
    }

    testWidgets('replaces the add page and opens under a default name', (
      tester,
    ) async {
      setViewport(tester);
      final container = buildContainer(const []);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(
            child: Builder(
              builder: (context) => FilledButton(
                onPressed: () => showAddProfilePage(context),
                child: const Text('home'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('home'));
      await tester.pumpAndSettle();
      final l = currentAppLocalizations;

      await tester.tap(find.text(l.customProfile));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNothing);
      expect(find.byType(AddProfileView, skipOffstage: false), findsNothing);
      expect(editor, findsOneWidget);
      expect(container.read(profilesProvider).single.label, l.unnamed);

      await leave(tester);
      expect(find.text('home'), findsOneWidget);
      expect(container.read(profilesProvider), isEmpty);
    });

    testWidgets('opens in the tab the add sheet came from on desktop', (
      tester,
    ) async {
      setViewport(tester);
      final container = buildContainer(const []);
      final tabNavigator = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(
            child: Navigator(
              key: tabNavigator,
              pages: [
                MaterialPage(
                  child: Builder(
                    builder: (context) => FilledButton(
                      onPressed: () => showAddProfilePage(context),
                      child: const Text('home'),
                    ),
                  ),
                ),
              ],
              onDidRemovePage: (_) {},
            ),
          ),
        ),
      );
      await tester.tap(find.text('home'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(currentAppLocalizations.customProfile));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AddProfileView), findsOneWidget);
      expect(editor, findsNothing);
      expect(container.read(profilesProvider), isEmpty);

      await tester.pumpAndSettle();
      expect(find.byType(AddProfileView, skipOffstage: false), findsNothing);
      expect(editor, findsNothing);

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.byType(AddProfileView, skipOffstage: false), findsNothing);
      expect(
        find.descendant(of: find.byKey(tabNavigator), matching: editor),
        findsOneWidget,
      );

      await tabNavigator.currentState!.maybePop();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 1));
      expect(find.text('home'), findsOneWidget);
      expect(container.read(profilesProvider), isEmpty);
    });

    testWidgets('is dropped on leaving it as it was created', (tester) async {
      final profile = Profile.custom(label: 'Unnamed');
      final container = buildContainer([profile]);
      await pumpOver(
        tester,
        container,
        CustomProfileView(profileId: profile.id, isNew: true),
      );

      unawaited(globalState.navigatorKey.currentState!.maybePop());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      expect(container.read(profilesProvider), isEmpty);
      expect(editor, findsOneWidget);
      expect(
        find.descendant(of: editor, matching: find.text('Unnamed')),
        findsOneWidget,
      );

      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 1));
      expect(editor, findsNothing);
    });

    const proxyGroup = ProxyGroup(
      id: 1,
      name: 'Proxy',
      type: GroupType.Selector,
    );

    testWidgets('is kept once it has a group, under its name if not given', (
      tester,
    ) async {
      final profile = Profile.custom(label: 'Unnamed');
      final container = buildContainer([profile], groups: const [proxyGroup]);
      await pumpOver(
        tester,
        container,
        CustomProfileView(profileId: profile.id, isNew: true),
      );

      await leave(tester);
      expect(find.byType(InputDialog), findsOneWidget);
      await tester.tap(find.text(currentAppLocalizations.cancel));
      await tester.pumpAndSettle();

      expect(editor, findsNothing);
      expect(container.read(profilesProvider), [profile]);
    });

    testWidgets('asks for a name on leaving with its name selected', (
      tester,
    ) async {
      final profile = Profile.custom(label: 'Unnamed');
      final container = buildContainer([profile], groups: const [proxyGroup]);
      await pumpOver(
        tester,
        container,
        CustomProfileView(profileId: profile.id, isNew: true),
      );

      await leave(tester);
      final field = find.descendant(
        of: find.byType(InputDialog),
        matching: find.byType(EditableText),
      );
      final editable = tester.widget<EditableText>(field);
      expect(editable.focusNode.hasFocus, isTrue);
      expect(
        editable.controller.selection,
        const TextSelection(baseOffset: 0, extentOffset: 7),
      );
      await tester.enterText(field, 'Mine');
      await tester.tap(find.text(currentAppLocalizations.submit));
      await tester.pumpAndSettle();

      expect(editor, findsNothing);
      expect(container.read(profilesProvider).single.label, 'Mine');
    });

    testWidgets('is kept once renamed while its page is open', (tester) async {
      final profile = Profile.custom(label: 'Unnamed');
      final container = buildContainer([profile]);
      await pumpOver(
        tester,
        container,
        CustomProfileView(profileId: profile.id, isNew: true),
      );
      expect(find.byTooltip(currentAppLocalizations.rename), findsNothing);

      container
          .read(profilesProvider.notifier)
          .updateProfile(
            profile.id,
            (profile) => profile.copyWith(label: 'Mine'),
          );
      await tester.pump();
      expect(find.text('Mine'), findsOneWidget);

      await leave(tester);

      expect(container.read(profilesProvider).single.label, 'Mine');
      expect(find.byType(InputDialog), findsNothing);
    });

    testWidgets('an existing profile is kept when left untouched', (
      tester,
    ) async {
      final profile = Profile.custom(label: 'mine');
      final container = buildContainer([profile]);
      await pumpOver(
        tester,
        container,
        CustomProfileView(profileId: profile.id),
      );

      await leave(tester);

      expect(container.read(profilesProvider), [profile]);
      final setupAction =
          container.read(setupActionProvider.notifier) as _RecordingSetupAction;
      expect(setupAction.autoApplyCalls, 0);
    });

    testWidgets('an existing profile applies on leaving once edited', (
      tester,
    ) async {
      final profile = Profile.custom(label: 'mine');
      final container = buildContainer([profile]);
      await pumpOver(
        tester,
        container,
        CustomProfileView(profileId: profile.id),
      );

      container
          .read(profilesProvider.notifier)
          .updateProfile(
            profile.id,
            (profile) => profile.copyWith(label: 'renamed'),
          );
      await tester.pump();
      await leave(tester);

      final setupAction =
          container.read(setupActionProvider.notifier) as _RecordingSetupAction;
      expect(setupAction.autoApplyCalls, 1);
    });
  });
}
