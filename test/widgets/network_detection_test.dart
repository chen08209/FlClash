import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart' as app;
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/widgets/network_detection.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  for (final ipInfo in [
    const IpInfo(ip: '1.1.1.1', countryCode: 'US'),
    null,
  ]) {
    testWidgets(
      ipInfo == null
          ? 'tapping a timed-out card retries detection'
          : 'tapping a cached IP card refreshes detection',
      (tester) async {
        final notifier = _RecordingNetworkDetection(ipInfo);
        final container = ProviderContainer(
          overrides: [
            app.networkDetectionProvider.overrideWith(() => notifier),
          ],
        );
        addTearDown(container.dispose);
        globalState.container = container;

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: TestApp(
              includeNavigatorKey: false,
              homeBuilder: (child) => Scaffold(
                body: Center(child: SizedBox(width: 320, child: child)),
              ),
              child: const NetworkDetection(),
            ),
          ),
        );
        await tester.pump();

        await tester.tap(find.byType(CommonCard));
        await tester.pump();
        expect(notifier.refreshCount, 1);
        expect(
          tester.widget<CommonCard>(find.byType(CommonCard)).onPressed,
          isNull,
        );

        await tester.tap(find.byType(CommonCard));
        await tester.pump();
        expect(notifier.refreshCount, 1);

        notifier.complete();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.text('2.2.2.2'), findsOneWidget);
        expect(
          tester.widget<CommonCard>(find.byType(CommonCard)).onPressed,
          isNotNull,
        );
      },
    );
  }
}

class _RecordingNetworkDetection extends app.NetworkDetection {
  _RecordingNetworkDetection(this.ipInfo);

  final IpInfo? ipInfo;
  int refreshCount = 0;

  @override
  NetworkDetectionState build() {
    return NetworkDetectionState(isLoading: false, ipInfo: ipInfo);
  }

  @override
  Future<void> refresh() async {
    refreshCount++;
    state = state.copyWith(isLoading: true, ipInfo: null);
  }

  void complete() {
    state = state.copyWith(
      isLoading: false,
      ipInfo: const IpInfo(ip: '2.2.2.2', countryCode: 'US'),
    );
  }
}
