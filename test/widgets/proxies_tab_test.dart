import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/proxies/tab.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

final _tabStateProvider = NotifierProvider<_TabStateNotifier, ProxiesTabState>(
  _TabStateNotifier.new,
);

class _TabStateNotifier extends Notifier<ProxiesTabState> {
  @override
  ProxiesTabState build() => _tabState([_group('B'), _group('C')]);

  void set(ProxiesTabState value) => state = value;
}

void main() {
  late ProviderContainer globalContainer;
  late ProviderSubscription<Profile?> currentProfileSubscription;

  setUp(() {
    final profile = Profile.normal().copyWith(currentGroupName: 'B');
    globalContainer = ProviderContainer(
      overrides: [
        currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
        profilesProvider.overrideWith(() => TestProfiles([profile])),
        currentGroupsStateProvider.overrideWithValue(
          GroupsState(value: [_group('A'), _group('B'), _group('C')]),
        ),
        proxiesTabStateProvider.overrideWith(
          (ref) => ref.watch(_tabStateProvider),
        ),
      ],
    );
    globalState.container = globalContainer;
    currentProfileSubscription = globalContainer.listen(
      currentProfileProvider,
      (_, _) {},
    );
  });

  tearDown(() {
    currentProfileSubscription.close();
    globalContainer.dispose();
  });

  Future<GlobalKey<ProxiesTabViewState>> pumpTabView(
    WidgetTester tester,
  ) async {
    final key = GlobalKey<ProxiesTabViewState>();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: globalContainer,
        child: TestApp(
          child: ProxiesTabView(key: key),
          homeBuilder: (child) => Scaffold(body: child),
        ),
      ),
    );
    await tester.pump();
    return key;
  }

  testWidgets('current group follows the rendered tab list', (tester) async {
    final key = await pumpTabView(tester);

    expect(key.currentState?.currentGroup?.name, 'B');

    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    tabBar.controller?.animateTo(1);
    await tester.pumpAndSettle();

    expect(key.currentState?.currentGroup?.name, 'C');
    expect(globalContainer.read(currentProfileProvider)?.currentGroupName, 'C');
  });

  testWidgets(
    'keeps the outgoing tab bar usable while the empty state enters',
    (tester) async {
      final key = await pumpTabView(tester);

      globalContainer.read(_tabStateProvider.notifier).set(_tabState([]));
      await tester.pump();

      expect(find.byType(TabBar), findsOneWidget);
      await tester.tap(find.byType(Tab).at(1), warnIfMissed: false);
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(key.currentState?.currentGroup, isNull);

      await tester.pumpAndSettle();

      expect(find.byType(TabBar), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('rebuilds the tab bar when groups return', (tester) async {
    final key = await pumpTabView(tester);

    globalContainer.read(_tabStateProvider.notifier).set(_tabState([]));
    await tester.pumpAndSettle();
    globalContainer
        .read(_tabStateProvider.notifier)
        .set(_tabState([_group('A'), _group('B'), _group('C')]));
    await tester.pumpAndSettle();

    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.controller?.length, 3);
    expect(key.currentState?.currentGroup?.name, 'B');
    expect(tester.takeException(), isNull);
  });
}

ProxiesTabState _tabState(List<Group> groups) {
  return ProxiesTabState(
    groups: groups,
    currentGroupName: 'B',
    proxyCardType: ProxyCardType.expand,
  );
}

Group _group(String name) {
  return Group(type: GroupType.Selector, name: name);
}
