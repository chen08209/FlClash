import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/free_nodes.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';

bool isFreeNodesGroupName(String groupName) {
  return isActionableFreeNodesGroupName(groupName);
}

bool canShowFreeNodesGroupMenu(String groupName) {
  if (isFreeNodesGroupName(groupName)) return true;
  final profile = _readFreeNodesProfile(groupName);
  return profile != null && _currentGroupsContainGroup(groupName);
}

String? _getUnavailableReason(String groupName) {
  return freeNodesGroupActionUnavailableReason(groupName);
}

String? _getDeleteUnavailableReason(String groupName) {
  if (isTodayFreeNodesGroupName(groupName)) return '不能删除本日免费节点';
  return _getUnavailableReason(groupName);
}

@visibleForTesting
String normalizeFreeNodesGroupNameForTesting(String groupName) {
  return normalizeFreeNodesGroupName(groupName);
}

@visibleForTesting
String? getFreeNodesGroupUnavailableReasonForTesting(String groupName) {
  return _getUnavailableReason(groupName);
}

@visibleForTesting
String? getFreeNodesGroupDeleteUnavailableReasonForTesting(String groupName) {
  return _getDeleteUnavailableReason(groupName);
}

@visibleForTesting
bool freeNodesProfileLooksActionableForTesting(
  Profile profile,
  String? groupName,
) {
  return _profileLooksLikeFreeNodes(profile, groupName);
}

Future<void> showFreeNodesGroupMenu(
  BuildContext context,
  String groupName,
) async {
  final normalizedGroupName = normalizeFreeNodesGroupName(groupName);
  final profile = _readFreeNodesProfile(groupName);
  final canShowMenu =
      isFreeNodesGroupName(groupName) ||
      (profile != null && _currentGroupsContainGroup(groupName));
  if (!canShowMenu) {
    context.showNotifier(_getUnavailableReason(groupName) ?? '只能操作免费节点分类');
    return;
  }
  if (profile == null) {
    context.showNotifier('未找到免费节点配置');
    return;
  }
  final isMainGroup = normalizedGroupName == freeNodesGroupName;
  final isTreasureGroup = normalizedGroupName == freeNodesTreasureGroupName;
  final unavailableReason = _getUnavailableReason(normalizedGroupName);
  if (!isMainGroup && !isTreasureGroup && unavailableReason != null) {
    context.showNotifier(unavailableReason);
    return;
  }
  final deleteUnavailableReason = _getDeleteUnavailableReason(
    normalizedGroupName,
  );
  final sheetContext =
      Navigator.maybeOf(context)?.context ??
      globalState.navigatorKey.currentContext ??
      context;
  await showSheet(
    context: sheetContext,
    builder: (_) => AdaptiveSheetScaffold(
      title: normalizedGroupName,
      body: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: CommonPopupMenu(
            items: [
              PopupMenuItemData(
                icon: Icons.auto_awesome_outlined,
                label: isMainGroup
                    ? '优选全部免费节点'
                    : isTreasureGroup
                    ? '二次优选'
                    : '优选（仅优选不删除）',
                onPressed: () {
                  _preferGroup(normalizedGroupName);
                },
              ),
              if (!isMainGroup &&
                  !isTreasureGroup &&
                  deleteUnavailableReason == null)
                PopupMenuItemData(
                  danger: true,
                  icon: Icons.delete_outline,
                  label: '删除并整合到优选节点',
                  onPressed: () {
                    _deleteGroup(normalizedGroupName);
                  },
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> _preferGroup(String groupName) async {
  final ref = globalState.container;
  final profile = _readFreeNodesProfile(groupName);
  if (profile == null) return;
  await globalState.safeRun(() async {
    final result = await ref
        .read(profilesActionProvider.notifier)
        .preferFreeNodesGroup(profile, groupName);
    globalState.showNotifier('已优选 ${result.affectedCount} 个节点');
  }, title: '优选节点');
}

Future<void> _deleteGroup(String groupName) async {
  final res = await globalState.showMessage(
    title: groupName,
    message: const TextSpan(text: '删除该日期分类，并把仍可用节点整合到优选节点？'),
    confirmText: '删除',
  );
  if (res != true) return;
  final ref = globalState.container;
  final profile = _readFreeNodesProfile(groupName);
  if (profile == null) return;
  await globalState.safeRun(() async {
    final result = await ref
        .read(profilesActionProvider.notifier)
        .deleteFreeNodesDateGroup(profile, groupName);
    globalState.showNotifier('已整合 ${result.affectedCount} 个节点到优选节点');
  }, title: '删除日期分类');
}

Profile? _readFreeNodesProfile([String? groupName]) {
  final ref = globalState.container;
  final currentProfile = ref.read(currentProfileProvider);
  if (currentProfile != null &&
      _profileLooksLikeFreeNodes(currentProfile, groupName)) {
    return currentProfile;
  }
  for (final profile in ref.read(profilesProvider)) {
    if (_profileLooksLikeFreeNodes(profile, groupName)) return profile;
  }
  if (currentProfile != null && _currentGroupsLookLikeFreeNodes(groupName)) {
    return currentProfile;
  }
  return null;
}

bool _profileLooksLikeFreeNodes(Profile profile, String? groupName) {
  if (profile.isFreeNodesProfile) return true;
  if (profile.label == freeNodesProfileLabel &&
      (groupName == null || isFreeNodesGroupName(groupName))) {
    return true;
  }
  final currentGroupName = profile.currentGroupName;
  return currentGroupName != null &&
      isFreeNodesGroupName(currentGroupName) &&
      _currentGroupsLookLikeFreeNodes(groupName);
}

bool _currentGroupsLookLikeFreeNodes(String? groupName) {
  if (groupName == null || !isFreeNodesGroupName(groupName)) return false;
  var hasFreeNodesRoot = false;
  var hasRequestedGroup = false;
  final requestedGroupName = normalizeFreeNodesGroupName(groupName);
  for (final group in _readCurrentProxyGroups()) {
    final normalizedName = normalizeFreeNodesGroupName(group.name);
    if (normalizedName == freeNodesGroupName) {
      hasFreeNodesRoot = true;
    }
    if (normalizedName == requestedGroupName) {
      hasRequestedGroup = true;
    }
  }
  return hasFreeNodesRoot && hasRequestedGroup;
}

bool _currentGroupsContainGroup(String groupName) {
  final requestedGroupName = normalizeFreeNodesGroupName(groupName);
  for (final group in _readCurrentProxyGroups()) {
    if (normalizeFreeNodesGroupName(group.name) == requestedGroupName) {
      return true;
    }
  }
  return false;
}

Iterable<Group> _readCurrentProxyGroups() sync* {
  final ref = globalState.container;
  yield* _readGroupsOrEmpty(() => ref.read(groupsProvider));
  yield* _readGroupsOrEmpty(() => ref.read(currentGroupsStateProvider).value);
  yield* _readGroupsOrEmpty(() => ref.read(proxiesTabStateProvider).groups);
}

List<Group> _readGroupsOrEmpty(List<Group> Function() read) {
  try {
    return read();
  } catch (_) {
    return const [];
  }
}
