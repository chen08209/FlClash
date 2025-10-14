import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';

import 'string.dart';

List<Group> computeSort({
  required List<Group> groups,
  required ProxiesSortType sortType,
  required DelayMap delayMap,
  required Map<String, String> selectedMap,
  required String defaultTestUrl,
}) {
  return groups.map((group) {
    final proxies = group.all;
    final newProxies = switch (sortType) {
      ProxiesSortType.none => proxies,
      ProxiesSortType.delay => _sortOfDelay(
        groups: groups,
        proxies: proxies,
        delayMap: delayMap,
        selectedMap: selectedMap,
        testUrl: group.testUrl.getSafeValue(defaultTestUrl),
      ),
      ProxiesSortType.name => _sortOfName(proxies),
    };
    return group.copyWith(all: newProxies);
  }).toList();
}

DelayState computeProxyDelayState({
  required String proxyName,
  required String testUrl,
  required List<Group> groups,
  required Map<String, String> selectedMap,
  required DelayMap delayMap,
}) {
  final state = computeRealSelectedProxyState(
    proxyName,
    groups: groups,
    selectedMap: selectedMap,
  );
  final currentDelayMap = delayMap[state.testUrl.getSafeValue(testUrl)] ?? {};
  final delay = currentDelayMap[state.proxyName];
  return DelayState(delay: delay ?? 0, group: state.group);
}

SelectedProxyState computeRealSelectedProxyState(
  String proxyName, {
  required List<Group> groups,
  required Map<String, String> selectedMap,
}) {
  return _getRealSelectedProxyState(
    SelectedProxyState(proxyName: proxyName),
    groups: groups,
    selectedMap: selectedMap,
  );
}

SelectedProxyState _getRealSelectedProxyState(
  SelectedProxyState state, {
  required List<Group> groups,
  required Map<String, String> selectedMap,
}) {
  if (state.proxyName.isEmpty) return state;
  final index = groups.indexWhere((element) => element.name == state.proxyName);
  final newState = state.copyWith(group: true);
  if (index == -1) return newState;
  final group = groups[index];
  final currentSelectedName = group.getCurrentSelectedName(
    selectedMap[newState.proxyName] ?? '',
  );
  if (currentSelectedName.isEmpty) {
    return newState;
  }
  return _getRealSelectedProxyState(
    newState.copyWith(proxyName: currentSelectedName, testUrl: group.testUrl),
    groups: groups,
    selectedMap: selectedMap,
  );
}

List<Proxy> _sortOfDelay({
  required List<Group> groups,
  required List<Proxy> proxies,
  required DelayMap delayMap,
  required Map<String, String> selectedMap,
  required String testUrl,
}) {
  return List.from(proxies)..sort((a, b) {
    final aDelayState = computeProxyDelayState(
      proxyName: a.name,
      testUrl: testUrl,
      groups: groups,
      selectedMap: selectedMap,
      delayMap: delayMap,
    );
    final bDelayState = computeProxyDelayState(
      proxyName: b.name,
      testUrl: testUrl,
      groups: groups,
      selectedMap: selectedMap,
      delayMap: delayMap,
    );
    return aDelayState.compareTo(bDelayState);
  });
}

List<Proxy> _sortOfName(List<Proxy> proxies) {
  return List.of(proxies)..sort((a, b) => a.name.compareTo(b.name));
}
