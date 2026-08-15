import 'package:fl_clash/common/free_nodes.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  test(
    'free node fetch progress survives when dashboard stops listening',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final subscription = container.listen<FreeNodesProgress?>(
        freeNodesFetchProgressProvider,
        (_, _) {},
      );
      const progress = FreeNodesProgress(
        operation: '获取中',
        completed: 7,
        total: 187,
        successfulSources: 6,
        failedSources: 1,
        proxyCount: 321,
      );

      container.read(freeNodesFetchProgressProvider.notifier).value = progress;
      subscription.close();
      await container.pump();

      expect(container.read(freeNodesFetchProgressProvider), same(progress));
    },
  );
}
