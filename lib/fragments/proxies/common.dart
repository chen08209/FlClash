import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Widget currentSelectedProxyNameBuilder({
  required String groupName,
  required Widget Function(String currentGroupName) builder,
}) {
  return Selector2<AppState, Config, String>(
    selector: (_, appState, config) {
      final group = appState.getGroupWithName(groupName);
      final selectedProxyName = config.currentSelectedMap[groupName];
      return group?.getCurrentSelectedName(selectedProxyName ?? "") ?? "";
    },
    builder: (_, currentSelectedProxyName, ___) {
      return builder(currentSelectedProxyName);
    },
  );
}

double get listHeaderHeight {
  final measure = globalState.measure;
  return 24 + measure.titleMediumHeight + 4 + measure.bodyMediumHeight;
}

double getItemHeight(ProxyCardType proxyCardType) {
  final measure = globalState.measure;
  final baseHeight =
      12 * 2 + measure.bodyMediumHeight * 2 + measure.bodySmallHeight + 8;
  return switch (proxyCardType) {
    ProxyCardType.expand => baseHeight + measure.labelSmallHeight + 8,
    ProxyCardType.shrink => baseHeight,
    ProxyCardType.min => baseHeight - measure.bodyMediumHeight,
  };
}

proxyDelayTest(Proxy proxy, [String? testUrl]) async {
  final appController = globalState.appController;
  final proxyName = appController.appState.getRealProxyName(proxy.name);
  final url = appController.getRealTestUrl(testUrl);
  globalState.appController.setDelay(
    Delay(
      url: url,
      name: proxyName,
      value: 0,
    ),
  );
  globalState.appController.setDelay(
    await clashCore.getDelay(
      url,
      proxyName,
    ),
  );
}

delayTest(List<Proxy> proxies, [String? testUrl]) async {
  final appController = globalState.appController;
  final proxyNames = proxies
      .map((proxy) => appController.appState.getRealProxyName(proxy.name))
      .toSet()
      .toList();

  final url = appController.getRealTestUrl(testUrl);

  final delayProxies = proxyNames.map<Future>((proxyName) async {
    globalState.appController.setDelay(
      Delay(
        url: url,
        name: proxyName,
        value: 0,
      ),
    );
    globalState.appController.setDelay(
      await clashCore.getDelay(
        url,
        proxyName,
      ),
    );
  }).toList();

  final batchesDelayProxies = delayProxies.batch(100);
  for (final batchDelayProxies in batchesDelayProxies) {
    await Future.wait(batchDelayProxies);
  }
  appController.appState.sortNum++;
}

double getScrollToSelectedOffset({
  required String groupName,
  required List<Proxy> proxies,
}) {
  final appController = globalState.appController;
  final columns = other.getProxiesColumns(
    appController.appState.viewWidth,
    appController.config.proxiesStyle.layout,
  );
  final proxyCardType = appController.config.proxiesStyle.cardType;
  final selectedName = appController.getCurrentSelectedName(groupName);
  final findSelectedIndex = proxies.indexWhere(
        (proxy) => proxy.name == selectedName,
  );
  final selectedIndex = findSelectedIndex != -1 ? findSelectedIndex : 0;
  final rows = (selectedIndex / columns).floor();
  return rows * getItemHeight(proxyCardType) + (rows - 1) * 8;
}
