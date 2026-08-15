import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

List<Group> getCurrentGroups() {
  return globalState.container.read(currentGroupsStateProvider).value;
}

List<Group> getGroups() {
  return globalState.container.read(groupsProvider);
}

void updateCurrentGroupName(String groupName) {
  globalState.container
      .read(proxiesActionProvider.notifier)
      .updateCurrentGroupName(groupName);
}

void updateCurrentUnfoldSet(Set<String> value) {
  globalState.container
      .read(proxiesActionProvider.notifier)
      .updateCurrentUnfoldSet(value);
}

typedef ProxyDelayRequester =
    Future<Delay> Function(String testUrl, String proxyName);

@visibleForTesting
Future<Delay> requestProxyDelayWithFallback({
  required String testUrl,
  required String proxyName,
  ProxyDelayRequester? requestDelay,
}) async {
  try {
    return await (requestDelay ?? coreController.getDelay)(testUrl, proxyName);
  } catch (error) {
    commonPrint.log(
      'Delay test failed for $proxyName: $error',
      logLevel: coreFailureLogLevel(error),
    );
    return Delay(url: testUrl, name: proxyName, value: -1);
  }
}

Future<void> proxyDelayTest(Proxy proxy, [String? testUrl]) async {
  final ref = globalState.container;
  final groups = getGroups();
  final selectedMap = ref.read(
    currentProfileProvider.select((state) => state?.selectedMap ?? {}),
  );
  final state = computeRealSelectedProxyState(
    proxy.name,
    groups: groups,
    selectedMap: selectedMap,
  );
  final currentTestUrl = state.testUrl.takeFirstValid([
    ref.read(realTestUrlProvider(testUrl)),
  ]);
  if (state.proxyName.isEmpty) return;
  ref
      .read(proxiesActionProvider.notifier)
      .setDelay(Delay(url: currentTestUrl, name: state.proxyName, value: 0));
  ref
      .read(proxiesActionProvider.notifier)
      .setDelay(
        await requestProxyDelayWithFallback(
          testUrl: currentTestUrl,
          proxyName: state.proxyName,
        ),
      );
}

typedef ProxyDelayTestRunner =
    Future<void> Function(Proxy proxy, String? testUrl);

@visibleForTesting
Future<void> runProxyDelayTestBatches({
  required List<Proxy> proxies,
  String? testUrl,
  int batchSize = 100,
  ProxyDelayTestRunner? testProxy,
}) async {
  if (batchSize <= 0) {
    throw ArgumentError.value(batchSize, 'batchSize', 'must be positive');
  }
  final runner = testProxy ?? proxyDelayTest;
  Object? firstError;
  StackTrace? firstStackTrace;
  for (final batch in proxies.batch(batchSize)) {
    await Future.wait(
      batch.map((proxy) async {
        try {
          await runner(proxy, testUrl);
        } catch (error, stackTrace) {
          firstError ??= error;
          firstStackTrace ??= stackTrace;
        }
      }),
    );
  }
  if (firstError != null) {
    Error.throwWithStackTrace(firstError!, firstStackTrace!);
  }
}

Future<void> delayTest(List<Proxy> proxies, [String? testUrl]) async {
  if (proxies.isEmpty) return;
  try {
    await runProxyDelayTestBatches(proxies: proxies, testUrl: testUrl);
  } finally {
    globalState.container.read(sortNumProvider.notifier).add();
  }
}

double getScrollToSelectedOffset({
  required String groupName,
  required List<Proxy> proxies,
  required int columns,
}) {
  final ref = globalState.container;
  final proxyCardType = ref.read(
    proxiesStyleSettingProvider.select((state) => state.cardType),
  );
  final selectedProxyName = ref.read(selectedProxyNameProvider(groupName));
  final findSelectedIndex = proxies.indexWhere(
    (proxy) => proxy.name == selectedProxyName,
  );
  final selectedIndex = findSelectedIndex != -1 ? findSelectedIndex : 0;
  final rows = (selectedIndex / columns).floor();
  return rows * getItemHeight(proxyCardType) + (rows - 1) * 8;
}
