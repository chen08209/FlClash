import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/widget_metrics.dart';
import 'package:fl_clash/views/dashboard/widgets/profile_detail.dart';
import 'package:fl_clash/views/dashboard/widgets/profiles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;

import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

const _gib = 1024 * 1024 * 1024;

class _MockCore extends Mock implements CoreHandlerInterface {}

class _FakePathProvider extends PathProviderPlatform {
  @override
  Future<String?> getApplicationSupportPath() async =>
      Directory.systemTemp.path;

  @override
  Future<String?> getTemporaryPath() async => Directory.systemTemp.path;

  @override
  Future<String?> getApplicationCachePath() async => Directory.systemTemp.path;
}

ExternalProvider _provider(String name, String type, int count) =>
    ExternalProvider(
      name: name,
      type: type,
      count: count,
      vehicleType: 'HTTP',
      updateAt: DateTime(2026),
    );

Profile _profile(int id, {SubscriptionInfo? info}) => Profile(
  id: id,
  label: 'P$id',
  url: 'https://sub$id.example.com/link',
  autoUpdateDuration: Duration.zero,
  lastUpdateDate: DateTime.now().subtract(const Duration(minutes: 5)),
  subscriptionInfo: info,
);

void main() {
  late ProviderContainer container;

  // appPath resolves its directories once per process; resolved inside a
  // test's fake async zone, later tests never see the future complete.
  setUpAll(() async {
    PathProviderPlatform.instance = _FakePathProvider();
    await appPath.homeDirPath;
  });

  void setUpProfiles(
    List<Profile> profiles, {
    List<Override> overrides = const [],
  }) {
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(() => TestProfiles(profiles)),
        viewSizeProvider.overrideWithBuild((_, _) => const Size(1200, 1000)),
        ...overrides,
      ],
    );
    globalState.container = container;
    container.listen(currentProfileIdProvider, (_, _) {});
    container.read(currentProfileIdProvider.notifier).value =
        profiles.firstOrNull?.id;
    addTearDown(container.dispose);
  }

  Future<void> pumpCard(
    WidgetTester tester, {
    double unitHeight = 80,
    double width = 320,
  }) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: width,
                child: DashboardWidgetMetrics(
                  unitHeight: unitHeight,
                  child: const ProfilesCard(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Finder label(String text) => find.text(text, findRichText: true);

  Future<void> openPicker(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Switch profile'));
    await tester.pumpAndSettle();
  }

  testWidgets('offers to add a profile without profiles', (tester) async {
    setUpProfiles([]);
    await pumpCard(tester);

    expect(find.text('Add profile'), findsOneWidget);
    expect(find.byTooltip('Switch profile'), findsNothing);
  });

  testWidgets('shows the current profile and its usage in one row', (
    tester,
  ) async {
    setUpProfiles([
      _profile(
        1,
        info: const SubscriptionInfo(
          upload: _gib,
          download: 41 * _gib,
          total: 100 * _gib,
        ),
      ),
      _profile(2),
    ]);
    await pumpCard(tester);

    expect(tester.getSize(find.byType(ProfilesCard)).height, 80);
    expect(label('P1'), findsOneWidget);
    expect(label('P2'), findsNothing);
    expect(find.text('42%'), findsOneWidget);
    expect(
      tester
          .widget<Tooltip>(
            find.ancestor(of: find.text('42%'), matching: find.byType(Tooltip)),
          )
          .message,
      '${(42 * _gib).traffic.show} / ${(100 * _gib).traffic.show}',
    );
  });

  testWidgets('hides the switch button with a single profile', (tester) async {
    setUpProfiles([_profile(1)]);
    await pumpCard(tester);

    expect(label('P1'), findsOneWidget);
    expect(find.byTooltip('Switch profile'), findsNothing);
  });

  testWidgets('switching picks a profile from a sheet', (tester) async {
    setUpProfiles([for (var id = 1; id <= 3; id++) _profile(id)]);
    await pumpCard(tester);

    await openPicker(tester);
    expect(find.byType(RadioGroup<int>), findsOneWidget);
    await tester.tap(label('P3'));
    await tester.pumpAndSettle();

    expect(container.read(currentProfileIdProvider), 3);
    expect(find.byType(RadioGroup<int>), findsNothing);
    expect(label('P3'), findsOneWidget);
  });

  _MockCore appliedConfigCore() {
    final core = _MockCore();
    when(() => core.getConfig(any())).thenAnswer(
      (_) async => {
        'proxies': [{}, {}],
        'proxy-groups': [{}],
        'rule': ['MATCH,DIRECT', 'DOMAIN,a.com,DIRECT', 'GEOIP,CN,DIRECT'],
      },
    );
    return core;
  }

  Future<void> openDetail(WidgetTester tester) async {
    await tester.tap(label('P1'));
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('reopening on the same config skips the read', (tester) async {
    final core = appliedConfigCore();
    globalState.lastConfigMd5 = 'applied';
    addTearDown(() => globalState.lastConfigMd5 = null);
    setUpProfiles(
      [_profile(1)],
      overrides: [
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
      ],
    );
    container.listen(groupsProvider, (_, _) {});
    await pumpCard(tester);

    await openDetail(tester);
    container.read(groupsProvider.notifier).value = [
      const Group(type: GroupType.Selector, name: 'G1'),
    ];
    await tester.pumpAndSettle();
    globalState.navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();
    await openDetail(tester);

    expect(find.text('3'), findsOneWidget);
    verify(() => core.getConfig(any())).called(1);
  });

  testWidgets('tapping the card shows what the Core was handed', (
    tester,
  ) async {
    final core = appliedConfigCore();
    setUpProfiles(
      [_profile(1), _profile(2)],
      overrides: [
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        providersProvider.overrideWithBuild(
          (_, _) => [_provider('nodes', 'Proxy', 5)],
        ),
      ],
    );
    container.read(currentProfileIdProvider.notifier).value = 1;
    await pumpCard(tester);

    await openDetail(tester);

    expect(find.byType(ProfileDetailSheet), findsOneWidget);
    expect(find.byTooltip('Preview'), findsOneWidget);
    expect(find.byTooltip('Edit'), findsNothing);
    for (final (title, value) in [
      ('Proxy group', '1'),
      ('Proxy node', '7'),
      ('Rules', '3'),
    ]) {
      expect(
        find.descendant(
          of: find
              .ancestor(of: find.text(title), matching: find.byType(Column))
              .first,
          matching: find.text(value),
        ),
        findsOneWidget,
      );
    }
  });

  test('counts provider proxies but not provider rules', () {
    final stats = profileStatsOf(
      configCountsOf({
        'proxies': [{}],
        'proxy-groups': [{}, {}],
        'rules': ['MATCH,DIRECT'],
      }),
      [_provider('nodes', 'Proxy', 4), _provider('ads', 'Rule', 900)],
    );

    expect(stats, (groups: 2, proxies: 5, rules: 1, providers: 2));
  });
}
