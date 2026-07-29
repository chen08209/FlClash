import 'package:fl_clash/common/free_nodes.dart';
import 'package:fl_clash/common/measure.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/proxies/tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('proxy group tabs use full-width mode only while real sources fit', () {
    expect(
      shouldUseScrollableProxyGroupTabs(groupCount: 2, maxWidth: 430),
      isFalse,
    );
    expect(
      shouldUseScrollableProxyGroupTabs(groupCount: 4, maxWidth: 430),
      isTrue,
    );
  });

  test('proxy tab controller exposes one category per real source', () {
    final profile = Profile.normal(
      label: freeNodesProfileLabel,
      url: freeNodesProfileUrl,
    ).copyWith(currentGroupName: '来源 Source B');
    final groups = [
      const Group(
        type: GroupType.Selector,
        name: freeNodesGroupName,
        hidden: true,
      ),
      const Group(
        type: GroupType.Selector,
        name: freeNodesTreasureGroupName,
        hidden: true,
      ),
      const Group(
        type: GroupType.Selector,
        name: '日期 2026-06-19',
        hidden: true,
      ),
      const Group(type: GroupType.Selector, name: '来源 Source A'),
      const Group(type: GroupType.Selector, name: '来源 Source B'),
    ];
    final container = ProviderContainer(
      overrides: [
        currentProfileProvider.overrideWithValue(profile),
        proxiesTabStateProvider.overrideWithValue(
          ProxiesTabState(
            groups: groups,
            currentGroupName: '来源 Source B',
            proxyCardType: ProxyCardType.expand,
            columns: 1,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final state = container.read(proxiesTabControllerStateProvider);

    expect(state.a, ['来源 Source A', '来源 Source B', freeNodesTreasureGroupName]);
    expect(state.b, '来源 Source B');
  });

  test(
    'toolbar-selected date is temporarily added after source categories',
    () {
      final profile = Profile.normal(
        label: freeNodesProfileLabel,
        url: freeNodesProfileUrl,
      ).copyWith(currentGroupName: '日期 2026-06-19');
      final groups = [
        const Group(
          type: GroupType.Selector,
          name: freeNodesGroupName,
          hidden: true,
        ),
        const Group(
          type: GroupType.Selector,
          name: '日期 2026-06-19',
          hidden: true,
        ),
        const Group(type: GroupType.Selector, name: '来源 Source A'),
        const Group(type: GroupType.Selector, name: '来源 Source B'),
      ];
      final container = ProviderContainer(
        overrides: [
          currentProfileProvider.overrideWithValue(profile),
          proxiesTabStateProvider.overrideWithValue(
            ProxiesTabState(
              groups: groups,
              currentGroupName: '日期 2026-06-19',
              proxyCardType: ProxyCardType.expand,
              columns: 1,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(proxiesTabControllerStateProvider);

      expect(state.a, ['来源 Source A', '来源 Source B', '日期 2026-06-19']);
      expect(state.b, '日期 2026-06-19');
    },
  );

  testWidgets(
    'free node card toolbar opens date and preferred switch without total category',
    (tester) async {
      final profile = Profile.normal(
        label: freeNodesProfileLabel,
        url: freeNodesProfileUrl,
      ).copyWith(currentGroupName: '来源 Source A');
      final groups = [
        const Group(
          type: GroupType.Selector,
          name: freeNodesGroupName,
          hidden: true,
        ),
        const Group(
          type: GroupType.Selector,
          name: '日期 2026-06-19',
          hidden: true,
        ),
        const Group(
          type: GroupType.Selector,
          name: freeNodesTreasureGroupName,
          hidden: true,
        ),
        const Group(type: GroupType.Selector, name: '来源 Source A'),
        const Group(type: GroupType.Selector, name: '来源 Source B'),
      ];
      final container = ProviderContainer(
        overrides: [
          isMobileViewProvider.overrideWithValue(true),
          currentProfileProvider.overrideWithValue(profile),
          groupsProvider.overrideWithValue(groups),
          profilesProvider.overrideWithValue([profile]),
        ],
      );
      globalState.container = container;
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.delegate.supportedLocales,
            home: Scaffold(
              body: SizedBox(
                width: 430,
                height: 720,
                child: Builder(
                  builder: (context) {
                    globalState.measure = Measure.of(context, 1);
                    return const ProxiesTabView();
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('proxy-group-tab-来源 Source A')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('proxy-group-tab-来源 Source B')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey('proxy-group-tab-$freeNodesTreasureGroupName'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('proxy-group-tab-FREE-NODES')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('proxy-group-tab-日期 2026-06-19')),
        findsNothing,
      );

      await tester.tap(
        find.byKey(const ValueKey('proxy-group-category-action-button')),
      );
      await tester.pumpAndSettle();

      expect(find.text('切换日期或优选节点'), findsOneWidget);
      expect(find.text('日期 2026-06-19'), findsOneWidget);
      expect(find.text(freeNodesTreasureGroupName), findsOneWidget);
      expect(find.text('优选全部免费节点'), findsNothing);
      expect(find.text(freeNodesGroupName), findsNothing);
    },
  );

  testWidgets('proxy group tab keeps direct tap and long-press semantics', (
    tester,
  ) async {
    var taps = 0;
    var longPresses = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProxyGroupTabLabel(
            groupName: '来源 Source A',
            onTap: () => taps++,
            onLongPress: () => longPresses++,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('proxy-group-tab-来源 Source A')));
    await tester.longPress(
      find.byKey(const ValueKey('proxy-group-tab-来源 Source A')),
    );

    expect(taps, 1);
    expect(longPresses, 1);
  });
}
