import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';

List<Group> computeSort({
  required List<Group> groups,
  required ProxiesSortType sortType,
  required DelayMap delayMap,
  required Map<String, String> selectedMap,
  required String defaultTestUrl,
}) {
  List<Proxy> sortOfDelay({
    required List<Group> groups,
    required List<Proxy> proxies,
    required DelayMap delayMap,
    required Map<String, String> selectedMap,
    required String testUrl,
  }) {
    final delayStates = {
      for (final proxy in proxies)
        proxy.name: computeProxyDelayState(
          proxyName: proxy.name,
          testUrl: testUrl,
          groups: groups,
          selectedMap: selectedMap,
          delayMap: delayMap,
        ),
    };
    return List.of(proxies)
      ..sort((a, b) => delayStates[a.name]!.compareTo(delayStates[b.name]!));
  }

  List<Proxy> sortOfName(List<Proxy> proxies) {
    return List.of(proxies)..sort((a, b) => a.name.compareTo(b.name));
  }

  return groups.map((group) {
    final proxies = group.all;
    final newProxies = switch (sortType) {
      ProxiesSortType.none => proxies,
      ProxiesSortType.delay => sortOfDelay(
        groups: groups,
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

List<Group> computeHideTimeout({
  required List<Group> groups,
  required List<Group> allGroups,
  required DelayMap delayMap,
  required Map<String, String> selectedMap,
  required String defaultTestUrl,
}) {
  final realStates = <String, SelectedProxyState>{};
  return groups.map((group) {
    final groupTestUrl = group.testUrl.takeFirstValid([defaultTestUrl]);
    final groupWithNow = allGroups.getGroup(group.name) ?? group;
    final selectedName = groupWithNow.getCurrentSelectedName(
      selectedMap[group.name] ?? '',
    );
    final visible = group.all.where((proxy) {
      if (proxy.name == selectedName) {
        return true;
      }
      final state = realStates.putIfAbsent(
        proxy.name,
        () => computeRealSelectedProxyState(
          proxy.name,
          groups: allGroups,
          selectedMap: selectedMap,
        ),
      );
      final testUrl = state.testUrl.takeFirstValid([groupTestUrl]);
      final delay = delayMap[testUrl]?[state.proxyName];
      return delay == null || delay > 0;
    }).toList();
    return group.copyWith(all: visible.isEmpty ? group.all : visible);
  }).toList();
}

SelectedProxyState getRealSelectedProxyState(
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
  return getRealSelectedProxyState(
    newState.copyWith(proxyName: currentSelectedName, testUrl: group.testUrl),
    groups: groups,
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

String delayTestKey(String testUrl, String proxyName) {
  return '$testUrl\u0000$proxyName';
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
  final currentDelayMap =
      delayMap[state.testUrl.takeFirstValid([testUrl])] ?? {};
  final delay = currentDelayMap[state.proxyName];
  return DelayState(delay: delay ?? 0, group: state.group);
}
