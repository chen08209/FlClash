import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/proxies/card.dart';
import 'package:fl_clash/views/proxies/list.dart';
import 'package:fl_clash/widgets/widgets.dart' hide ListHeader;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _RecordingProxiesAction extends ProxiesAction {
  static final List<String> tested = [];

  @override
  Future<void> delayTestPageGroup(
    String groupName, {
    bool matchSearch = true,
  }) async {
    tested.add(groupName);
  }
}

Group _group(String name, int count) => Group(
  type: GroupType.Selector,
  name: name,
  all: [for (var i = 0; i < count; i++) Proxy(name: '$name-$i', type: 'ss')],
);

void main() {
  late ProviderContainer container;

  Future<void> pumpList(
    WidgetTester tester, {
    Map<String, String> selectedMap = const {},
    ViewMode viewMode = ViewMode.mobile,
    List<Group>? groups,
    Set<String> unfoldSet = const {'G0', 'G1', 'G2'},
    ValueListenable<Brightness>? brightness,
  }) async {
    tester.view.physicalSize = const Size(900, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    groups ??= [_group('G0', 40), _group('G1', 30), _group('G2', 60)];
    final profile = Profile.normal().copyWith(
      selectedMap: selectedMap,
      unfoldSet: unfoldSet,
    );
    _RecordingProxiesAction.tested.clear();
    container = ProviderContainer(
      overrides: [
        viewModeProvider.overrideWithValue(viewMode),
        currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
        profilesProvider.overrideWith(() => TestProfiles([profile])),
        currentGroupsStateProvider.overrideWithValue(
          GroupsState(value: groups),
        ),
        proxiesActionProvider.overrideWith(_RecordingProxiesAction.new),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(groupsProvider.notifier).value = groups;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          homeBuilder: (child) => Scaffold(
            body: Builder(
              builder: (context) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(padding: const EdgeInsets.only(top: 64)),
                child: child,
              ),
            ),
          ),
          child: brightness == null
              ? const ProxiesListView()
              : ValueListenableBuilder(
                  valueListenable: brightness,
                  builder: (_, brightness, child) => Theme(
                    data: ThemeData(brightness: brightness),
                    child: child!,
                  ),
                  child: const ProxiesListView(),
                ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder headerOf(String groupName) => find.ancestor(
    of: find.text(groupName, findRichText: true),
    matching: find.byType(ListHeader),
  );

  Finder actionOf(String groupName, String tooltip) => find.descendant(
    of: headerOf(groupName),
    matching: find.byTooltip(tooltip),
  );

  Finder scrollable() => find
      .descendant(
        of: find.byType(CustomScrollView),
        matching: find.byType(Scrollable),
      )
      .first;

  Future<void> revealHeaderOf(WidgetTester tester, String groupName) async {
    await tester.scrollUntilVisible(
      actionOf(groupName, 'Scroll to selected'),
      200,
      scrollable: scrollable(),
    );
    await tester.pumpAndSettle();
  }

  ShapeDecoration surfaceOf(WidgetTester tester, String groupName) =>
      tester
              .widget<DecoratedBox>(
                find
                    .descendant(
                      of: headerOf(groupName),
                      matching: find.byType(DecoratedBox),
                    )
                    .first,
              )
              .decoration
          as ShapeDecoration;

  testWidgets('scroll to selected lands the row under the pinned header', (
    tester,
  ) async {
    await pumpList(tester, selectedMap: {'G1': 'G1-25'});
    await revealHeaderOf(tester, 'G1');

    await tester.tap(actionOf('G1', 'Scroll to selected'));
    await tester.pumpAndSettle();

    final header = tester.getRect(headerOf('G1'));
    final card = tester.getRect(find.byKey(const ValueKey('G1.G1-25')).first);
    expect(card.top, header.bottom);
  });

  testWidgets('folding a group leaves the cards of the others as they were', (
    tester,
  ) async {
    await pumpList(tester);
    final card = find.byKey(const ValueKey('G0.G0-0')).first;
    final before = tester.widget(card);

    container.read(proxiesActionProvider.notifier).updateCurrentUnfoldSet({
      'G0',
      'G1',
    });
    await tester.pump();

    expect(tester.widget(card), same(before));
  });

  testWidgets('a group unfolds its rows from under its header and folds them '
      'back', (tester) async {
    await pumpList(tester);
    container.read(proxiesActionProvider.notifier).updateCurrentUnfoldSet({
      'G1',
      'G2',
    });
    await tester.pumpAndSettle();
    final radius = AppCorner.xl.ap(tester.element(find.text('G0')));
    final unfolding = find.byType(UnfoldEntryTransition);
    final cards = find.byWidgetPredicate(
      (widget) => widget is ProxyCard && widget.groupName == 'G0',
    );
    BorderRadiusGeometry headerCorners() =>
        (surfaceOf(tester, 'G0').shape as RoundedSuperellipseBorder)
            .borderRadius;

    await tester.tap(find.text('G0'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    expect(unfolding, findsWidgets);
    expect(headerCorners(), AppRadius.all(radius));

    await tester.pumpAndSettle();
    expect(unfolding, findsNothing);
    expect(cards, findsWidgets);
    expect(headerCorners(), AppRadius.vertical(top: radius));

    await tester.tap(find.text('G0'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    expect(unfolding, findsWidgets);
    expect(headerCorners(), AppRadius.all(radius));

    await tester.pumpAndSettle();
    expect(cards, findsNothing);
  });

  testWidgets('the pinned header floats over its rows and leaves with the '
      'bottom of its group card', (tester) async {
    await pumpList(tester);
    expect(surfaceOf(tester, 'G0').shadows, isNull);

    final position = tester.state<ScrollableState>(scrollable()).position;
    position.jumpTo(200);
    await tester.pump();
    final floating = surfaceOf(tester, 'G0');
    expect(floating.shadows, isNotEmpty);
    expect(
      (floating.shape as RoundedSuperellipseBorder).borderRadius,
      AppRadius.all(AppCorner.xl.ap(tester.element(headerOf('G0')))),
    );

    final pinnedTop = tester.getRect(headerOf('G0')).top;
    while (headerOf('G1').evaluate().isEmpty) {
      position.jumpTo(position.pixels + 100);
      await tester.pump();
    }
    final nextTop = tester.getRect(headerOf('G1')).top;
    position.jumpTo(position.pixels + nextTop - pinnedTop - 20);
    await tester.pump();

    expect(
      tester.getRect(headerOf('G0')).bottom,
      tester.getRect(headerOf('G1')).top -
          cardSpacingOf(tester.element(headerOf('G1')), ViewMode.mobile),
    );
    expect(surfaceOf(tester, 'G0').shadows, isNull);
  });

  testWidgets('a folded pinned header takes the page color of a new theme', (
    tester,
  ) async {
    final brightness = ValueNotifier(Brightness.light);
    addTearDown(brightness.dispose);
    await pumpList(tester, unfoldSet: const {}, brightness: brightness);

    brightness.value = Brightness.dark;
    await tester.pumpAndSettle();

    final header = find.ancestor(
      of: headerOf('G0'),
      matching: find.byType(PinnedHeaderSliver),
    );
    final context = tester.element(header);
    final cover = tester.widget<ColoredBox>(
      find.descendant(of: header, matching: find.byType(ColoredBox)).first,
    );
    expect(context.colorScheme.brightness, Brightness.dark);
    expect(cover.color, context.surfaceLevel.colorOf(context.colorScheme));
  });

  testWidgets('the last row sits as far from the bottom of its group card as '
      'from its sides', (tester) async {
    await pumpList(tester);
    final lastCard = find.byWidgetPredicate(
      (widget) => widget is ProxyCard && widget.proxy.name == 'G0-39',
    );
    await tester.scrollUntilVisible(lastCard, 200, scrollable: scrollable());
    await tester.pumpAndSettle();

    final header = tester.getRect(headerOf('G0'));
    final card = tester.getRect(lastCard);
    final nextHeader = tester.getRect(headerOf('G1'));
    final sideInset = header.right - card.right;
    expect(
      nextHeader.top -
          cardSpacingOf(tester.element(headerOf('G1')), ViewMode.mobile) -
          card.bottom,
      sideInset,
    );
  });

  testWidgets('a desktop window lays the groups out in columns and pins the '
      'header of an unfolded one', (tester) async {
    await pumpList(tester, viewMode: ViewMode.desktop);
    container.read(proxiesActionProvider.notifier).updateCurrentUnfoldSet({
      'G2',
    });
    await tester.pumpAndSettle();
    final first = tester.getRect(headerOf('G0'));
    final second = tester.getRect(headerOf('G1'));
    final third = tester.getRect(headerOf('G2'));

    expect(second.top, first.top);
    expect(
      second.left - first.right,
      cardSpacingOf(tester.element(headerOf('G1')), ViewMode.desktop),
    );
    expect(third.left, first.left);
    expect(third.top, greaterThan(first.bottom));

    final position = tester.state<ScrollableState>(scrollable()).position;
    position.jumpTo(40);
    await tester.pump();

    expect(tester.getRect(headerOf('G0')).top, first.top - 40);
    expect(tester.getRect(headerOf('G1')).top, second.top - 40);

    position.jumpTo(third.top - first.top + 200);
    await tester.pump();

    expect(tester.getRect(headerOf('G2')).top, first.top);
  });

  testWidgets('scroll to selected stays put without a selection', (
    tester,
  ) async {
    await pumpList(tester);
    await revealHeaderOf(tester, 'G1');
    final before = tester.getRect(headerOf('G1'));

    await tester.tap(actionOf('G1', 'Scroll to selected'));
    await tester.pumpAndSettle();

    expect(tester.getRect(headerOf('G1')), before);
  });

  testWidgets('a group name too long for its header stays on one line', (
    tester,
  ) async {
    await pumpList(
      tester,
      groups: [_group('Streaming Media Very Long Group Name 流媒体服务分组 ' * 3, 4)],
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('the delay test button tests its own group only', (tester) async {
    await pumpList(tester);

    await tester.tap(actionOf('G0', 'Delay test'));
    await tester.pump();

    expect(_RecordingProxiesAction.tested, ['G0']);
  });

  testWidgets('a group under test spins its button and ignores taps', (
    tester,
  ) async {
    await pumpList(tester);

    container.read(delayTestingGroupsProvider.notifier).start('G0');
    await tester.pump();

    expect(
      find.descendant(
        of: headerOf('G0'),
        matching: find.byType(CommonCircleLoading),
      ),
      findsOneWidget,
    );
    await tester.tap(actionOf('G0', 'Delay test'), warnIfMissed: false);
    await tester.pump();
    expect(_RecordingProxiesAction.tested, isEmpty);

    container.read(delayTestingGroupsProvider.notifier).stop('G0');
    await tester.pump();

    expect(find.byType(CommonCircleLoading), findsNothing);
  });
}
