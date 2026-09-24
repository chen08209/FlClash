import 'package:fl_clash/common/function.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('waits for a frame it schedules while frames are enabled', (
    tester,
  ) async {
    var calls = 0;

    runAfterFrame(() => calls++);
    await tester.idle();

    expect(calls, 0);
    expect(tester.binding.hasScheduledFrame, isTrue);

    await tester.pump();

    expect(calls, 1);
  });

  testWidgets('runs without a frame while the window is hidden', (
    tester,
  ) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    addTearDown(
      () => tester.binding.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      ),
    );
    var calls = 0;

    runAfterFrame(() => calls++);

    expect(calls, 0);

    await tester.idle();

    expect(calls, 1);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}
