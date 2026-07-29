import 'package:fl_clash/common/free_nodes.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/proxies/free_nodes_group_menu.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String todayText() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  test('recognizes normalized free node groups for actions', () {
    final today = todayText();
    expect(isFreeNodesGroupName(freeNodesGroupName), isTrue);
    expect(isFreeNodesGroupName(today), isTrue);
    expect(isFreeNodesGroupName('日期 $today'), isTrue);
    expect(isFreeNodesGroupName('${today}T00:00:00Z'), isTrue);
    expect(isFreeNodesGroupName('日期 2026-05-30'), isTrue);
    expect(isFreeNodesGroupName('来源 Source A'), isTrue);
    expect(isFreeNodesGroupName(freeNodesTreasureGroupName), isTrue);
  });

  test('normalizes legacy and abnormal category names before menu actions', () {
    expect(
      normalizeFreeNodesGroupNameForTesting('2026-06-19T00:00:00Z'),
      '日期 2026-06-19',
    );
    expect(normalizeFreeNodesGroupNameForTesting('20260619'), '日期 2026-06-19');
    expect(
      normalizeFreeNodesGroupNameForTesting(freeNodesLegacyTreasureGroupName),
      freeNodesTreasureGroupName,
    );
    expect(
      normalizeFreeNodesGroupNameForTesting(' 来源  Source A  '),
      '来源 Source A',
    );
  });

  test('allows historical date groups so they can be deleted or preferred', () {
    expect(
      getFreeNodesGroupUnavailableReasonForTesting('日期 2026-05-30'),
      isNull,
    );
    expect(
      getFreeNodesGroupDeleteUnavailableReasonForTesting('日期 2026-05-30'),
      isNull,
    );
  });

  test('allows opening today normalized date group but blocks deleting it', () {
    final today = todayText();

    expect(getFreeNodesGroupUnavailableReasonForTesting('日期 $today'), isNull);
    expect(
      getFreeNodesGroupDeleteUnavailableReasonForTesting('日期 $today'),
      '不能删除本日免费节点',
    );
  });

  test('recognizes legacy free node profile label for category actions', () {
    final legacyProfile = Profile.normal(
      label: freeNodesProfileLabel,
      url: 'https://example.invalid/free-nodes.yaml',
    );

    expect(
      freeNodesProfileLooksActionableForTesting(
        legacyProfile,
        '2026-06-19T00:00:00Z',
      ),
      isTrue,
    );
  });

  test('shows menu entry for current custom free node category', () {
    final profile = freeNodesService.createProfile().copyWith(
      currentGroupName: '香港',
    );
    final groups = [
      const Group(type: GroupType.Selector, name: freeNodesGroupName),
      const Group(type: GroupType.Selector, name: '香港'),
    ];
    final container = ProviderContainer(
      overrides: [
        currentProfileProvider.overrideWithValue(profile),
        currentGroupsStateProvider.overrideWithValue(
          GroupsState(value: groups),
        ),
        groupsProvider.overrideWithValue(groups),
        profilesProvider.overrideWithValue([profile]),
      ],
    );
    globalState.container = container;
    addTearDown(container.dispose);

    expect(canShowFreeNodesGroupMenu('香港'), isTrue);
  });
}
