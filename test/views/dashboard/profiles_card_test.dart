import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/widget_metrics.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/views/dashboard/widgets/profiles.dart';
import 'package:fl_clash/views/dashboard/widgets/proxy_groups.dart';
import 'package:fl_clash/views/dashboard/widgets/row_card.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

const _gib = 1024 * 1024 * 1024;

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

  void setUpProfiles(List<Profile> profiles) {
    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(() => TestProfiles(profiles))],
    );
    globalState.container = container;
    container.listen(currentProfileIdProvider, (_, _) {});
    addTearDown(container.dispose);
  }

  Future<void> pumpCard(
    WidgetTester tester, {
    double unitHeight = 80,
    double width = 320,
    bool withGroups = false,
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
                  child: Column(
                    children: [
                      const ProfilesCard(),
                      if (withGroups) const ProxyGroupsCard(),
                    ],
                  ),
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

  testWidgets('shows an empty state without profiles', (tester) async {
    setUpProfiles([]);
    await pumpCard(tester);

    expect(find.byType(EmptyIllustration), findsOneWidget);
    expect(find.text('Add profile'), findsOneWidget);
  });

  testWidgets('fits as many profiles as proxy groups', (tester) async {
    setUpProfiles([for (var id = 1; id <= 8; id++) _profile(id)]);
    container.listen(groupsProvider, (_, _) {});
    container.read(groupsProvider.notifier).value = [
      for (var id = 1; id <= 8; id++)
        Group(type: GroupType.Selector, name: 'G$id', hidden: false),
    ];

    int shown(String prefix, Type card) => [
      for (var id = 1; id <= 8; id++)
        if (tester.any(label('$prefix$id')) &&
            tester.getRect(label('$prefix$id')).bottom <=
                tester.getRect(find.byType(card)).bottom)
          id,
    ].length;

    for (final unitHeight in [80.0, 120.0]) {
      await pumpCard(tester, unitHeight: unitHeight, withGroups: true);
      expect(shown('P', ProfilesCard), shown('G', ProxyGroupsCard));
      expect(
        tester.getSize(find.byType(RowCardPill).first),
        tester.getSize(
          find
              .descendant(
                of: find.byType(ProxyGroupsCard),
                matching: find.byType(RowCardPill),
              )
              .first,
        ),
      );
    }
  });

  testWidgets('shows usage as a bar and the expiry on the right', (
    tester,
  ) async {
    setUpProfiles([
      _profile(
        1,
        info: const SubscriptionInfo(
          upload: _gib,
          download: _gib,
          total: 100 * _gib,
        ),
      ),
      _profile(2),
    ]);
    await pumpCard(tester, width: 520);

    expect(find.text('Never expires'), findsOneWidget);
    expect(
      tester
          .widgetList<FractionallySizedBox>(find.byType(FractionallySizedBox))
          .map((bar) => bar.heightFactor),
      [0.02, 0.0],
    );
    final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
    expect(
      tooltip.message,
      '${(2 * _gib).traffic.show} / ${(100 * _gib).traffic.show} (2%)',
    );
  });

  testWidgets('drops the expiry when it does not fit', (tester) async {
    setUpProfiles([
      _profile(
        1,
        info: const SubscriptionInfo(
          upload: _gib,
          download: _gib,
          total: 100 * _gib,
        ),
      ),
    ]);
    await pumpCard(tester, width: 170);

    expect(label('P1'), findsOneWidget);
    expect(find.text('Never expires'), findsNothing);
  });

  testWidgets('scrolls to the profiles below the fold', (tester) async {
    setUpProfiles([for (var id = 1; id <= 5; id++) _profile(id)]);
    await pumpCard(tester);

    await tester.drag(label('P1'), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(tester.any(label('P1')), isFalse);
    expect(tester.any(label('P5')), isTrue);
  });

  testWidgets('tapping a profile selects it', (tester) async {
    setUpProfiles([_profile(1), _profile(2)]);
    container.read(currentProfileIdProvider.notifier).value = 1;
    await pumpCard(tester);

    await tester.tap(label('P2'));
    await tester.pump();

    expect(container.read(currentProfileIdProvider), 2);
  });
}
