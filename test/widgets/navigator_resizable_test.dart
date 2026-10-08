import 'package:fl_clash/widgets/navigator_resizable.dart';
import 'package:fl_clash/widgets/paged_sheet.dart';
import 'package:fl_clash/widgets/sheet.dart';
import 'package:fl_clash/widgets/inherited.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

PagedSheetRoute<void> _page(String label, double height) {
  return PagedSheetRoute<void>(
    builder: (_) => SizedBox(
      height: height,
      child: Center(child: Text(label)),
    ),
  );
}

Future<NavigatorState> _pumpSheet(WidgetTester tester, {Widget? first}) async {
  final navigatorKey = GlobalKey<NavigatorState>();
  await tester.pumpWidget(
    MaterialApp(
      home: SheetProvider(
        type: SheetType.bottomSheet,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: PagedSheet(
            child: Navigator(
              key: navigatorKey,
              onGenerateInitialRoutes: (_, _) => [
                if (first == null)
                  _page('first', 200)
                else
                  PagedSheetRoute<void>(builder: (_) => first),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  return navigatorKey.currentState!;
}

double _height(WidgetTester tester) {
  return tester.getSize(find.byType(NavigatorResizable)).height;
}

void main() {
  testWidgets('follows a drag back and settles on the page below', (
    tester,
  ) async {
    final navigator = await _pumpSheet(tester);
    navigator.push(_page('second', 400));
    await tester.pumpAndSettle();
    expect(_height(tester), 400);

    final width = tester.getSize(find.byType(NavigatorResizable)).width;
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('second')),
    );
    await gesture.moveBy(const Offset(20, 0));
    await gesture.moveBy(Offset(width / 2 - 20, 0));
    await tester.pump();
    expect(_height(tester), closeTo(300, 1));

    await gesture.moveBy(Offset(width / 4, 0));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('second'), findsNothing);
    expect(_height(tester), 200);
  });

  testWidgets('hands over to a page pushed while a drag back settles', (
    tester,
  ) async {
    final navigator = await _pumpSheet(tester);
    navigator.push(_page('second', 400));
    await tester.pumpAndSettle();

    await tester.fling(find.text('second'), const Offset(300, 0), 2000);
    await tester.pump();
    navigator.push(_page('third', 300));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('third'), findsOneWidget);
    expect(_height(tester), 300);
  });

  testWidgets('turns back from where a push was when popped mid-way', (
    tester,
  ) async {
    final navigator = await _pumpSheet(tester);
    navigator.push(_page('second', 400));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    final turn = _height(tester);
    expect(turn, inExclusiveRange(200, 400));

    navigator.pop();
    await tester.pump();
    expect(_height(tester), turn);
    await tester.pump(const Duration(milliseconds: 50));
    expect(_height(tester), lessThan(turn));

    await tester.pumpAndSettle();
    expect(_height(tester), 200);
  });

  testWidgets('follows the current page as its content grows', (tester) async {
    var height = 200.0;
    await _pumpSheet(
      tester,
      first: StatefulBuilder(
        builder: (context, setState) => SizedBox(
          height: height,
          child: TextButton(
            onPressed: () => setState(() => height = 260),
            child: const Text('grow'),
          ),
        ),
      ),
    );
    expect(_height(tester), 200);

    await tester.tap(find.text('grow'));
    await tester.pumpAndSettle();
    expect(_height(tester), 260);
  });
}
