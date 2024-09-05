import 'dart:math';

import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Widget currentGroupProxyNameBuilder({
  required String groupName,
  required Widget Function(String currentGroupName) builder,
}) {
  return Selector2<AppState, Config, String>(
    selector: (_, appState, config) {
      final group = appState.getGroupWithName(groupName);
      final selectedProxyName = config.currentSelectedMap[groupName];
      return group?.getCurrentSelectedName(selectedProxyName ?? "") ?? "";
    },
    builder: (_, currentGroupName, ___) {
      return builder(currentGroupName);
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

delayTest(List<Proxy> proxies) async {
  final appController = globalState.appController;
  final delayProxies = proxies.map<Future>((proxy) async {
    final proxyName = appController.appState.getRealProxyName(proxy.name);
    globalState.appController.setDelay(
      Delay(
        name: proxyName,
        value: 0,
      ),
    );
    globalState.appController.setDelay(await clashCore.getDelay(proxyName));
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
    appController.config.proxiesLayout,
  );
  final proxyCardType = appController.config.proxyCardType;
  final selectedName = appController.getCurrentSelectedName(groupName);
  final findSelectedIndex = proxies.indexWhere(
    (proxy) => proxy.name == selectedName,
  );
  final selectedIndex = findSelectedIndex != -1 ? findSelectedIndex : 0;
  final rows = (selectedIndex / columns).floor();
  return max(rows * (getItemHeight(proxyCardType) + 8) - 8, 0);
}
