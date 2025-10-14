import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';

double get listHeaderHeight {
  final measure = globalState.measure;
  return 20 + measure.titleMediumHeight + 4 + measure.bodyMediumHeight + 2;
}

double getItemHeight(ProxyCardType proxyCardType) {
  final measure = globalState.measure;
  final baseHeight =
      16 + measure.bodyMediumHeight * 2 + measure.bodySmallHeight + 8 + 4;
  return switch (proxyCardType) {
    ProxyCardType.expand => baseHeight + measure.labelSmallHeight + 6,
    ProxyCardType.shrink => baseHeight,
    ProxyCardType.min => baseHeight - measure.bodyMediumHeight,
  };
}

Future<void> proxyDelayTest(Proxy proxy, [String? testUrl]) async {
  final appController = globalState.appController;
  final groups = globalState.appState.groups;
  final selectedMap = globalState.config.currentProfile?.selectedMap ?? {};
  final state = computeRealSelectedProxyState(
    proxy.name,
    groups: groups,
    selectedMap: selectedMap,
  );
  final currentTestUrl = state.testUrl.getSafeValue(
    appController.getRealTestUrl(testUrl),
  );
  if (state.proxyName.isEmpty) {
    return;
  }
  appController.setDelay(
    Delay(url: currentTestUrl, name: state.proxyName, value: 0),
  );
  appController.setDelay(
    await coreController.getDelay(currentTestUrl, state.proxyName),
  );
}

Future<void> delayTest(List<Proxy> proxies, [String? testUrl]) async {
  final appController = globalState.appController;
  final proxyNames = proxies.map((proxy) => proxy.name).toSet().toList();

  final delayProxies = proxyNames.map<Future>((proxyName) async {
    final groups = globalState.appState.groups;
    final selectedMap = globalState.config.currentProfile?.selectedMap ?? {};
    final state = computeRealSelectedProxyState(
      proxyName,
      groups: groups,
      selectedMap: selectedMap,
    );
    final url = state.testUrl.getSafeValue(
      appController.getRealTestUrl(testUrl),
    );
    final name = state.proxyName;
    if (name.isEmpty) {
      return;
    }
    appController.setDelay(Delay(url: url, name: name, value: 0));
    appController.setDelay(await coreController.getDelay(url, name));
  }).toList();

  final batchesDelayProxies = delayProxies.batch(100);
  for (final batchDelayProxies in batchesDelayProxies) {
    await Future.wait(batchDelayProxies);
  }
  appController.addSortNum();
}

double getScrollToSelectedOffset({
  required String groupName,
  required List<Proxy> proxies,
}) {
  final appController = globalState.appController;
  final columns = appController.getProxiesColumns();
  final proxyCardType = globalState.config.proxiesStyle.cardType;
  final selectedProxyName = appController.getSelectedProxyName(groupName);
  final findSelectedIndex = proxies.indexWhere(
    (proxy) => proxy.name == selectedProxyName,
  );
  final selectedIndex = findSelectedIndex != -1 ? findSelectedIndex : 0;
  final rows = (selectedIndex / columns).floor();
  return rows * getItemHeight(proxyCardType) + (rows - 1) * 8;
}
