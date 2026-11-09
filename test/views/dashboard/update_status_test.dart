import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/layout.dart';
import 'package:fl_clash/views/dashboard/widgets/update_status.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';
import 'package:prism_ui/prism_ui.dart';
import '../../helpers/host_scaffold.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    globalState.container = container;
  });

  tearDown(() => container.dispose());

  Future<void> pumpCard(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          locale: Locale('en'),
          child: HostScaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 380,
                child: DashboardDensityScope(
                  density: DashboardDensity.mobile,
                  scale: 1,
                  child: UpdateStatusSlot(gap: 12),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows nothing without an update', (tester) async {
    await pumpCard(tester);

    expect(find.text('Downloading update'), findsNothing);
    expect(find.text('Update ready'), findsNothing);
  });

  testWidgets('follows a download to its end', (tester) async {
    final download = container.read(updateDownloadStateProvider.notifier);
    download.value = const UpdateDownloading(
      'v0.9.3',
      received: 1 << 20,
      total: 4 << 20,
    );
    await pumpCard(tester);

    expect(find.text('Downloading update'), findsOneWidget);
    expect(find.text('v0.9.3'), findsOneWidget);
    final bar = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(bar.value, 0.25);

    download.value = const UpdateReady('v0.9.3', '/update/FlClash.apk');
    await tester.pump();

    expect(find.text('Update ready'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('grows in and keeps its last state while it leaves', (
    tester,
  ) async {
    await pumpCard(tester);
    final slot = find.byType(UpdateStatusSlot);
    expect(tester.getSize(slot).height, 0);

    final download = container.read(updateDownloadStateProvider.notifier);
    download.value = const UpdateReady('v0.9.3', '/update/FlClash.apk');
    await tester.pump();
    await tester.pump(commonDuration ~/ 2);
    final midway = tester.getSize(slot).height;
    await tester.pumpAndSettle();
    final full = tester.getSize(slot).height;
    expect(midway, inExclusiveRange(0, full));

    download.value = null;
    await tester.pump();
    await tester.pump(commonDuration ~/ 2);
    expect(find.text('Update ready'), findsOneWidget);
    expect(tester.getSize(slot).height, inExclusiveRange(0, full));

    await tester.pumpAndSettle();
    expect(find.text('Update ready'), findsNothing);
    expect(tester.getSize(slot).height, 0);
  });

  testWidgets('a download that returns as the card leaves stays', (
    tester,
  ) async {
    await pumpCard(tester);
    final download = container.read(updateDownloadStateProvider.notifier);
    download.value = const UpdateReady('v0.9.3', '/update/FlClash.apk');
    await tester.pumpAndSettle();

    download.value = null;
    await tester.pump();
    await tester.pump(commonDuration ~/ 2);
    download.value = const UpdateDownloading('v0.9.4', received: 1, total: 4);
    await tester.pumpAndSettle();

    expect(find.text('Downloading update'), findsOneWidget);
  });
}
