import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';

bool isDelaySortedGroupName(String groupName) {
  return groupName == 'FREE-NODES' ||
      _dateTokenFromGroupName(groupName) > 0 ||
      groupName == '优选节点' ||
      groupName == '宝藏积累' ||
      groupName == '历史';
}

int _dateTokenFromGroupName(String groupName) {
  final match = RegExp(
    r'(20\d{2})[-_/\.]?(\d{2})[-_/\.]?(\d{2})',
  ).firstMatch(groupName);
  if (match == null) return 0;
  return int.tryParse('${match.group(1)}${match.group(2)}${match.group(3)}') ??
      0;
}

List<Group> computeSort({
  required List<Group> groups,
  required ProxiesSortType sortType,
  required DelayMap delayMap,
  required Map<String, String> selectedMap,
  required String defaultTestUrl,
}) {
  final groupByName = {for (final group in groups) group.name: group};
  final selectedStateCache = <String, SelectedProxyState>{};

  List<Proxy> sortOfDelay({
    required List<Proxy> proxies,
    required DelayMap delayMap,
    required Map<String, String> selectedMap,
    required String testUrl,
  }) {
    final delayStates = computeProxyDelayStateMap(
      proxies: proxies,
      testUrl: testUrl,
      groupByName: groupByName,
      selectedMap: selectedMap,
      delayMap: delayMap,
      selectedStateCache: selectedStateCache,
    );
    return List.from(proxies)..sort((a, b) {
      final aDelayState = delayStates[a.name]!;
      final bDelayState = delayStates[b.name]!;
      return aDelayState.compareTo(bDelayState);
    });
  }

  List<Proxy> sortOfName(List<Proxy> proxies) {
    return List.of(proxies)..sort((a, b) => a.name.compareTo(b.name));
  }

  return groups.map((group) {
    final proxies = group.all;
    final effectiveSortType = isDelaySortedGroupName(group.name)
        ? ProxiesSortType.delay
        : sortType;
    final newProxies = switch (effectiveSortType) {
      ProxiesSortType.none => proxies,
      ProxiesSortType.delay => sortOfDelay(
        proxies: proxies,
        delayMap: delayMap,
        selectedMap: selectedMap,
        testUrl: group.testUrl.takeFirstValid([defaultTestUrl]),
      ),
      ProxiesSortType.name => sortOfName(proxies),
    };
    return group.copyWith(all: newProxies);
  }).toList();
}

SelectedProxyState getRealSelectedProxyState(
  SelectedProxyState state, {
  required List<Group> groups,
  required Map<String, String> selectedMap,
}) {
  final groupByName = {for (final group in groups) group.name: group};
  return getRealSelectedProxyStateByName(
    state,
    groupByName: groupByName,
    selectedMap: selectedMap,
  );
}

SelectedProxyState getRealSelectedProxyStateByName(
  SelectedProxyState state, {
  required Map<String, Group> groupByName,
  required Map<String, String> selectedMap,
}) {
  if (state.proxyName.isEmpty) return state;
  final newState = state.copyWith(group: true);
  final group = groupByName[state.proxyName];
  if (group == null) return newState;
  final currentSelectedName = group.getCurrentSelectedName(
    selectedMap[newState.proxyName] ?? '',
  );
  if (currentSelectedName.isEmpty) {
    return newState;
  }
  return getRealSelectedProxyStateByName(
    newState.copyWith(proxyName: currentSelectedName, testUrl: group.testUrl),
    groupByName: groupByName,
    selectedMap: selectedMap,
  );
}

SelectedProxyState computeRealSelectedProxyState(
  String proxyName, {
  required List<Group> groups,
  required Map<String, String> selectedMap,
}) {
  return getRealSelectedProxyState(
    SelectedProxyState(proxyName: proxyName),
    groups: groups,
    selectedMap: selectedMap,
  );
}

DelayState computeProxyDelayState({
  required String proxyName,
  required String testUrl,
  required List<Group> groups,
  required Map<String, String> selectedMap,
  required DelayMap delayMap,
}) {
  final groupByName = {for (final group in groups) group.name: group};
  return computeProxyDelayStateWithGroupMap(
    proxyName: proxyName,
    testUrl: testUrl,
    groupByName: groupByName,
    selectedMap: selectedMap,
    delayMap: delayMap,
  );
}

DelayState computeProxyDelayStateWithGroupMap({
  required String proxyName,
  required String testUrl,
  required Map<String, Group> groupByName,
  required Map<String, String> selectedMap,
  required DelayMap delayMap,
  Map<String, SelectedProxyState>? selectedStateCache,
}) {
  final state = (selectedStateCache ?? <String, SelectedProxyState>{})
      .putIfAbsent(
        proxyName,
        () => getRealSelectedProxyStateByName(
          SelectedProxyState(proxyName: proxyName),
          groupByName: groupByName,
          selectedMap: selectedMap,
        ),
      );
  final effectiveTestUrl = state.testUrl.takeFirstValid([testUrl]);
  final delay = visibleDelayValueForProxy(
    delayMap: delayMap,
    testUrl: effectiveTestUrl,
    proxyName: state.proxyName,
  );
  return DelayState(delay: delay ?? 0, group: state.group);
}

int? visibleDelayValueForProxy({
  required DelayMap delayMap,
  required String testUrl,
  required String proxyName,
}) {
  final currentDelay = delayMap[testUrl]?[proxyName];
  if (currentDelay != null && currentDelay >= 0) {
    return currentDelay;
  }
  final alternateDelay = positiveDelayValueForProxy(
    delayMap: delayMap,
    excludedTestUrl: testUrl,
    proxyName: proxyName,
  );
  return alternateDelay ?? currentDelay;
}

int? positiveDelayValueForProxy({
  required DelayMap delayMap,
  required String excludedTestUrl,
  required String proxyName,
}) {
  int? bestDelay;
  for (final entry in delayMap.entries) {
    if (entry.key == excludedTestUrl) {
      continue;
    }
    final delay = entry.value[proxyName];
    if (delay == null || delay <= 0) {
      continue;
    }
    if (bestDelay == null || delay < bestDelay) {
      bestDelay = delay;
    }
  }
  return bestDelay;
}

Map<String, DelayState> computeProxyDelayStateMap({
  required Iterable<Proxy> proxies,
  required String testUrl,
  required Map<String, Group> groupByName,
  required Map<String, String> selectedMap,
  required DelayMap delayMap,
  Map<String, SelectedProxyState>? selectedStateCache,
}) {
  final delayStateMap = <String, DelayState>{};
  for (final proxy in proxies) {
    delayStateMap.putIfAbsent(
      proxy.name,
      () => computeProxyDelayStateWithGroupMap(
        proxyName: proxy.name,
        testUrl: testUrl,
        groupByName: groupByName,
        selectedMap: selectedMap,
        delayMap: delayMap,
        selectedStateCache: selectedStateCache,
      ),
    );
  }
  return delayStateMap;
}
