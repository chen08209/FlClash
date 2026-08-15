import 'package:fl_clash/common/free_nodes.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/views/proxies/tab.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const total = Group(
    type: GroupType.Selector,
    name: freeNodesGroupName,
    hidden: true,
  );
  const treasure = Group(
    type: GroupType.Selector,
    name: freeNodesTreasureGroupName,
    hidden: true,
  );
  const date = Group(
    type: GroupType.Selector,
    name: '日期 2026-08-15',
    hidden: true,
  );
  const sourceA = Group(type: GroupType.Selector, name: '来源 Source A');
  const sourceB = Group(type: GroupType.Selector, name: '来源 Source B');

  test('free node tab labels hide aggregate and inactive date groups', () {
    final visible = normalizeVisibleFreeNodesGroups(const [
      total,
      treasure,
      date,
      sourceA,
      sourceB,
    ], selectedGroupName: '来源 Source B');

    expect(visible.map((group) => group.name).toList(), [
      '来源 Source A',
      '来源 Source B',
      freeNodesTreasureGroupName,
    ]);
  });

  test('manually selected date is appended to visible source categories', () {
    final visible = normalizeVisibleFreeNodesGroups(const [
      total,
      treasure,
      date,
      sourceA,
      sourceB,
    ], selectedGroupName: date.name);

    expect(visible.map((group) => group.name).toList(), [
      '来源 Source A',
      '来源 Source B',
      freeNodesTreasureGroupName,
      date.name,
    ]);
  });

  test('delay test resolves the active visible category first', () {
    const groups = [sourceA, sourceB, treasure];

    expect(
      resolveCurrentDelayTestGroup(
        groups: groups,
        activeIndex: 1,
        selectedGroupName: sourceA.name,
      )?.name,
      sourceB.name,
    );
  });

  test('delay test falls back to the selected visible category name', () {
    const groups = [sourceA, sourceB, treasure];

    expect(
      resolveCurrentDelayTestGroup(
        groups: groups,
        activeIndex: null,
        selectedGroupName: sourceA.name,
      )?.name,
      sourceA.name,
    );
  });

  test('free node source categories switch to the compact two-row layout', () {
    expect(
      shouldUseTwoRowFreeNodesGroupTabs(
        isFreeNodesProfile: true,
        groupCount: 3,
      ),
      isTrue,
    );
    expect(
      shouldUseTwoRowFreeNodesGroupTabs(
        isFreeNodesProfile: false,
        groupCount: 3,
      ),
      isFalse,
    );
  });
}
