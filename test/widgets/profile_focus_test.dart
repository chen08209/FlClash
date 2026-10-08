import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/theme.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/profiles.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../helpers/context_menu.dart';
import '../helpers/test_profiles.dart';

Profile urlProfile(String label) =>
    Profile.normal(label: label, url: 'https://example.com/sub').copyWith(
      subscriptionInfo: const SubscriptionInfo(
        upload: 1024,
        download: 2048,
        total: 4096,
        expire: 1234567890,
      ),
    );

class _RecordingProfilesAction extends ProfilesAction {
  final List<Profile> users;
  final deleted = <int>[];

  _RecordingProfilesAction(this.users);

  @override
  Future<List<Profile>> providerUsers(Profile profile) async => users;

  @override
  Future<void> deleteProfile(int id) async => deleted.add(id);
}

Future<ProviderContainer> pumpProfiles(
  WidgetTester tester, {
  required List<Profile> profiles,
  int? currentProfileId,
  ValueListenable<bool>? isActive,
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = const Size(900, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer(
    overrides: [
      profilesProvider.overrideWith(() => TestProfiles(profiles)),
      currentProfileIdProvider.overrideWithBuild(
        (_, _) => currentProfileId ?? profiles.first.id,
      ),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  globalState.container = container;
  container.read(viewSizeProvider.notifier).value = const Size(900, 800);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        navigatorKey: globalState.navigatorKey,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.delegate.supportedLocales,
        builder: (context, child) {
          globalState.measure = Measure.of(context, 1);
          globalState.theme = CommonTheme.of(context, 1);
          return child!;
        },
        home: isActive == null
            ? const ProfilesView()
            : ValueListenableBuilder(
                valueListenable: isActive,
                builder: (_, isActive, child) =>
                    PageActivityScope(isActive: isActive, child: child!),
                child: const ProfilesView(),
              ),
      ),
    ),
  );
  await tester.pump();
  return container;
}

void main() {
  testWidgets('a focused profile card opens its menu and reaches its '
      'subscription info', (tester) async {
    final profiles = [
      urlProfile('url 1'),
      Profile.normal(label: 'file 1'),
      urlProfile('url 2'),
    ];
    await pumpProfiles(tester, profiles: profiles);

    final cards = find
        .byType(OutlinedButton)
        .evaluate()
        .map((element) => element.widget)
        .toList();

    Future<void> focusCard(int index) async {
      for (var tab = 0; tab < 50; tab++) {
        final context = FocusManager.instance.primaryFocus?.context;
        final focusedCard = context
            ?.findAncestorWidgetOfExactType<OutlinedButton>();
        final focusedAction = context
            ?.findAncestorWidgetOfExactType<IconButton>();
        if (focusedAction == null && identical(focusedCard, cards[index])) {
          return;
        }
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
      }
      fail('Profile card $index was not reachable');
    }

    for (var profileIndex = 0; profileIndex < profiles.length; profileIndex++) {
      await focusCard(profileIndex);

      await tester.sendKeyEvent(LogicalKeyboardKey.contextMenu);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(CommonPopupMenu),
          matching: find.text(currentAppLocalizations.delete),
        ),
        findsOneWidget,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(CommonPopupMenu), findsNothing);

      if (profiles[profileIndex].subscriptionInfo == null) {
        continue;
      }
      await focusCard(profileIndex);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      final context = FocusManager.instance.primaryFocus?.context;
      expect(
        context?.findAncestorWidgetOfExactType<IconButton>()?.tooltip,
        currentAppLocalizations.subscriptionInfo,
      );
      expect(
        context?.findAncestorWidgetOfExactType<ListItem>()?.key,
        Key(profiles[profileIndex].id.toString()),
      );
    }
  });

  testWidgets('a card shows its traffic under the title and its update time '
      'at the end, without an edit button', (tester) async {
    final file = Profile.normal(label: 'file');
    final url = urlProfile('url').copyWith(
      lastUpdateDate: DateTime.now().subtract(const Duration(minutes: 5)),
    );
    final container = await pumpProfiles(tester, profiles: [url, file]);

    expect(find.byTooltip(currentAppLocalizations.edit), findsNothing);
    expect(find.text('3KB / 4KB'), findsOneWidget);
    expect(find.text('5m ago'), findsOneWidget);

    container.read(updatingKeysProvider.notifier).start(url.updatingKey);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('5m ago'), findsNothing);
    expect(
      find.descendant(
        of: find.ancestor(
          of: find.text('url'),
          matching: find.byType(ProfileItem),
        ),
        matching: find.byType(CommonCircleLoading),
      ),
      findsOneWidget,
    );
  });

  testWidgets('the usage icon opens the subscription dialog', (tester) async {
    await pumpProfiles(tester, profiles: [urlProfile('url')]);

    await tester.tap(find.byTooltip(currentAppLocalizations.subscriptionInfo));
    await tester.pumpAndSettle();

    expect(find.byType(CommonDialog), findsOneWidget);
    expect(find.byType(SubscriptionInfoDetailView), findsOneWidget);
    expect(find.text(currentAppLocalizations.subscriptionInfo), findsOneWidget);
  });

  Future<void> openProfileMenu(WidgetTester tester, String label) async {
    await rightClick(tester, find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets('an external profile lists extend and keeps its final config '
      'under more', (tester) async {
    final l = currentAppLocalizations;
    await pumpProfiles(tester, profiles: [urlProfile('url')]);

    await openProfileMenu(tester, 'url');
    expect(find.text(l.extend), findsOneWidget);
    expect(find.text(l.finalConfig), findsNothing);
    expect(find.text(l.rename), findsNothing);

    await tester.tap(find.text(l.more).last);
    await tester.pumpAndSettle();
    expect(find.text(l.finalConfig), findsOneWidget);
    expect(find.text(l.subscriptionInfo), findsNothing);
  });

  testWidgets('a custom profile lists its final config and no extend', (
    tester,
  ) async {
    final l = currentAppLocalizations;
    await pumpProfiles(tester, profiles: [Profile.custom(label: 'mine')]);

    await openProfileMenu(tester, 'mine');
    expect(find.text(l.finalConfig), findsOneWidget);
    expect(find.text(l.extend), findsNothing);
    expect(find.text(l.more), findsNothing);
  });

  testWidgets('a custom profile renames from its menu', (tester) async {
    final l = currentAppLocalizations;
    await pumpProfiles(tester, profiles: [Profile.custom(label: 'mine')]);

    await openProfileMenu(tester, 'mine');
    await tester.tap(find.text(l.rename));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'ours');
    await tester.tap(find.text(l.submit));
    await tester.pumpAndSettle();

    expect(find.text('ours'), findsOneWidget);
    expect(find.text('mine'), findsNothing);
  });

  testWidgets('a profile another one uses as a provider is deleted once '
      'confirmed', (tester) async {
    final action = _RecordingProfilesAction([Profile.normal(label: 'Work')]);
    final home = urlProfile('Home');
    await pumpProfiles(
      tester,
      profiles: [home],
      overrides: [profilesActionProvider.overrideWith(() => action)],
    );

    await openProfileMenu(tester, 'Home');
    await tester.tap(find.text(currentAppLocalizations.delete));
    await tester.pumpAndSettle();

    expect(find.textContaining('Home is still used'), findsOneWidget);
    expect(find.textContaining('used by Work'), findsOneWidget);
    await tester.tap(find.text(currentAppLocalizations.confirm));
    await tester.pumpAndSettle();

    expect(action.deleted, [home.id]);
  });

  group('the selected profile is revealed', () {
    final profiles = [
      for (var index = 0; index < 40; index++) urlProfile('profile $index'),
    ];
    final selected = profiles[36];

    Rect selectedRect(WidgetTester tester) => tester.getRect(
      find.ancestor(
        of: find.text(selected.label),
        matching: find.byType(ProfileItem),
      ),
    );

    void expectRevealed(WidgetTester tester) {
      final viewport = tester.getRect(find.byKey(profilesStoreKey));
      final rect = selectedRect(tester);
      expect(rect.top, greaterThanOrEqualTo(viewport.top));
      expect(rect.bottom, lessThanOrEqualTo(viewport.bottom));
    }

    testWidgets('on first build', (tester) async {
      await pumpProfiles(
        tester,
        profiles: profiles,
        currentProfileId: selected.id,
      );
      await tester.pumpAndSettle();

      expectRevealed(tester);
    });

    testWidgets('not when the kept page becomes active again', (tester) async {
      final isActive = ValueNotifier(true);
      addTearDown(isActive.dispose);
      await pumpProfiles(
        tester,
        profiles: profiles,
        currentProfileId: selected.id,
        isActive: isActive,
      );
      await tester.pumpAndSettle();

      isActive.value = false;
      await tester.pump();
      final scrollable = tester.state<ScrollableState>(
        find.descendant(
          of: find.byKey(profilesStoreKey),
          matching: find.byType(Scrollable),
        ),
      );
      scrollable.position.jumpTo(0);
      await tester.pumpAndSettle();
      expect(find.text(selected.label), findsNothing);

      isActive.value = true;
      await tester.pumpAndSettle();

      expect(scrollable.position.pixels, 0);
      expect(find.text(selected.label), findsNothing);
    });
  });
}
