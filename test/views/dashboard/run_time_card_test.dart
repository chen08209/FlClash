import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/widgets/run_time.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('the start card shows the run time without a switch', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(body: ListView(children: const [RunTimeCard()])),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Switch), findsNothing);
    expect(find.text(getTimeText(null)), findsOneWidget);

    const runTime = (60 * 60 + 61) * 1000;
    container.read(runTimeProvider.notifier).value = runTime;
    await tester.pump();

    expect(find.text(getTimeText(runTime)), findsOneWidget);
  });
}
