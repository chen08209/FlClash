import 'package:fl_clash/widgets/scroll.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

class _Host extends StatefulWidget {
  final List<int> data;
  final bool enable;
  final VoidCallback onCancelToEnd;
  final ScrollController controller;

  const _Host({
    required this.data,
    required this.enable,
    required this.onCancelToEnd,
    required this.controller,
  });

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ScrollToEndBox<int>(
          controller: widget.controller,
          dataSource: widget.data,
          enable: widget.enable,
          onCancelToEnd: widget.onCancelToEnd,
          child: ListView.builder(
            controller: widget.controller,
            itemCount: widget.data.length,
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

  setUp(() {
    controller = ScrollController();
    cancelCount = 0;
  });

  tearDown(() {
    controller.dispose();
  });

  Future<void> pump(
    WidgetTester tester, {
    required List<int> data,
    bool enable = true,
  }) {
    return tester.pumpWidget(
      _Host(
        data: data,
        enable: enable,
        controller: controller,
        onCancelToEnd: () => cancelCount++,
      ),
    );
  }

  testWidgets('scrolls to the end when the data source grows', (tester) async {
    await pump(tester, data: List.generate(20, (i) => i));
    expect(controller.offset, 0);

    await pump(tester, data: List.generate(21, (i) => i));
    await tester.pumpAndSettle();

    expect(controller.offset, controller.position.maxScrollExtent);
    expect(cancelCount, 0);
  });

  testWidgets('does not scroll when only identity of an equal list changes', (
    tester,
  ) async {
    final data = List.generate(20, (i) => i);
    await pump(tester, data: data);
    await pump(tester, data: List.of(data));
    await tester.pumpAndSettle();

    expect(controller.offset, 0);
  });

  testWidgets('cancels only when the user scrolls away from the end', (
    tester,
  ) async {
    await pump(tester, data: List.generate(20, (i) => i));
    await pump(tester, data: List.generate(21, (i) => i));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(cancelCount, 0);

    await tester.drag(find.byType(ListView), const Offset(0, 200));
    await tester.pumpAndSettle();
    expect(cancelCount, 1);
  });

  testWidgets('re-enabling scrolls back to the end', (tester) async {
    final data = List.generate(20, (i) => i);
    await pump(tester, data: data, enable: false);
    expect(controller.offset, 0);

    await pump(tester, data: data, enable: true);
    await tester.pumpAndSettle();

    expect(controller.offset, controller.position.maxScrollExtent);
  });
}
