import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';

double get listHeaderHeight {
  final measure = globalState.measure;
  return 20 + measure.titleMediumHeight + 4 + measure.bodyMediumHeight;
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

proxyDelayTest(Proxy proxy, [String? testUrl]) async {
  final appController = globalState.appController;
  final state = appController.getProxyCardState(proxy.name);
  final url = state.testUrl.getSafeValue(
    appController.getRealTestUrl(testUrl),
  );
  if (state.proxyName.isEmpty) {
    return;
  }
  appController.setDelay(
    Delay(
      url: url,
      name: state.proxyName,
      value: 0,
    ),
  );
  appController.setDelay(
    await clashCore.getDelay(
      url,
      state.proxyName,
    ),
  );
}

delayTest(List<Proxy> proxies, [String? testUrl]) async {
  final appController = globalState.appController;
  final proxyNames = proxies.map((proxy) => proxy.name).toSet().toList();

  // 立即设置所有代理为测试中状态（显示加载动画）
  for (final proxyName in proxyNames) {
    final state = appController.getProxyCardState(proxyName);
    final url = state.testUrl.getSafeValue(
      appController.getRealTestUrl(testUrl),
    );
    final name = state.proxyName;
    if (name.isNotEmpty) {
      appController.setDelay(
        Delay(
          url: url,
          name: name,
          value: 0, // 0表示正在测试中
        ),
      );
    }
  }

  final delayProxies = proxyNames.map<Future>((proxyName) async {
    final state = appController.getProxyCardState(proxyName);
    final url = state.testUrl.getSafeValue(
      appController.getRealTestUrl(testUrl),
    );
    final name = state.proxyName;
    if (name.isEmpty) {
      return;
    }
    
    // 执行延迟测试
    final result = await clashCore.getDelay(url, name);
    appController.setDelay(result);
  }).toList();

  // 优化并发数：根据代理数量动态调整批处理大小
  final batchSize = proxyNames.length > 50 ? 20 : 10; // 较多代理时减少并发数，避免网络拥塞
  final batchesDelayProxies = delayProxies.batch(batchSize);
  
  for (final batchDelayProxies in batchesDelayProxies) {
    await Future.wait(batchDelayProxies, eagerError: false); // eagerError: false 确保即使部分失败也继续
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
