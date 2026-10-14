import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/widgets/scroll.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

class _Host extends StatefulWidget {
  final int itemCount;
  final bool enable;
  final VoidCallback onCancelToEnd;
  final VoidCallback onResumeToEnd;
  final ScrollController controller;

  const _Host({
    required this.itemCount,
    required this.enable,
    required this.onCancelToEnd,
    required this.onResumeToEnd,
    required this.controller,
  });

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late final _physics = FollowEndScrollPhysics(
    isFollowing: () => widget.enable,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ScrollToEndBox(
          controller: widget.controller,
          enable: widget.enable,
          onCancelToEnd: widget.onCancelToEnd,
          onResumeToEnd: widget.onResumeToEnd,
          child: ListView.builder(
            controller: widget.controller,
            physics: _physics,
            itemCount: widget.itemCount,
            itemExtent: 100,
            itemBuilder: (_, index) => Text('item $index'),
          ),
        ),
      ),
    );
  }
}

void main() {
  late ScrollController controller;
  late int cancelCount;
  late int resumeCount;

  setUp(() {
    controller = ScrollController();
    cancelCount = 0;
    resumeCount = 0;
  });

  tearDown(() {
    controller.dispose();
  });

  Future<void> pump(
    WidgetTester tester, {
    required int itemCount,
    bool enable = true,
  }) {
    return tester.pumpWidget(
      _Host(
        itemCount: itemCount,
        enable: enable,
        controller: controller,
        onCancelToEnd: () => cancelCount++,
        onResumeToEnd: () => resumeCount++,
      ),
    );
  }

  // The viewport is 600 tall and a row is 100, so six rows fill a screen.
  Future<void> pumpAtEnd(WidgetTester tester, {bool enable = true}) async {
    await pump(tester, itemCount: 20, enable: enable);
    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pumpAndSettle();
  }

  testWidgets('a following list keeps to its end in the frame rows arrive', (
    tester,
  ) async {
    await pumpAtEnd(tester);

    await pump(tester, itemCount: 23);

    expect(controller.offset, controller.position.maxScrollExtent);
    expect(controller.offset, 2300 - 600);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('rows arriving below a following list leave it where it is', (
    tester,
  ) async {
    await pump(tester, itemCount: 20);
    expect(controller.offset, 0);

    await pump(tester, itemCount: 25);
    await tester.pumpAndSettle();

    expect(controller.offset, 0);
  });

  testWidgets('a list that stopped following stays put when rows arrive', (
    tester,
  ) async {
    await pumpAtEnd(tester, enable: false);
    final end = controller.offset;

    await pump(tester, itemCount: 25, enable: false);
    await tester.pumpAndSettle();

    expect(controller.offset, end);
  });

  testWidgets('a viewport that shrinks keeps a following list at the end', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await pumpAtEnd(tester);

    tester.view.physicalSize = const Size(800, 400);
    await tester.pump();

    expect(controller.offset, controller.position.maxScrollExtent);

    await pump(tester, itemCount: 20, enable: false);
    tester.view.physicalSize = const Size(800, 300);
    await tester.pumpAndSettle();

    expect(controller.offset, lessThan(controller.position.maxScrollExtent));
  });

  testWidgets('cancels only when the user scrolls away from the end', (
    tester,
  ) async {
    await pumpAtEnd(tester);

    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(cancelCount, 0);

    await tester.drag(find.byType(ListView), const Offset(0, 200));
    await tester.pumpAndSettle();
    expect(cancelCount, greaterThan(0));
  });

  testWidgets('a scroll that ends off the end without a drag cancels too', (
    tester,
  ) async {
    await pumpAtEnd(tester);

    unawaited(
      controller.animateTo(
        controller.offset - 300,
        duration: const Duration(milliseconds: 200),
        curve: Curves.linear,
      ),
    );
    await tester.pumpAndSettle();

    expect(cancelCount, 1);
  });

  testWidgets('resumes when the user scrolls back to the end', (tester) async {
    await pumpAtEnd(tester);

    await tester.drag(find.byType(ListView), const Offset(0, 200));
    await tester.pumpAndSettle();
    expect(cancelCount, greaterThan(0));

    await pump(tester, itemCount: 20, enable: false);
    await tester.drag(find.byType(ListView), const Offset(0, -100));
    await tester.pumpAndSettle();
    expect(resumeCount, 0);

    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(controller.offset, controller.position.maxScrollExtent);
    expect(resumeCount, 1);
  });

  testWidgets('re-enabling scrolls back to the end', (tester) async {
    await pump(tester, itemCount: 20, enable: false);
    expect(controller.offset, 0);

    await pump(tester, itemCount: 20);
    await tester.pumpAndSettle();

    expect(controller.offset, controller.position.maxScrollExtent);
  });
}
