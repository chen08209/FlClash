import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_ui/prism_ui.dart';

/// Checks that [row]'s list wraps it in nothing that keeps it alive and that
/// nothing in it asks to be kept, at rest, focused and pressed; then that the
/// row, scrolled out of its list and back while pressed, returns at rest.
Future<void> expectRowNeedsNoKeepAlive(WidgetTester tester, Finder row) async {
  void expectNoneAsks() {
    expect(
      find.ancestor(of: row, matching: find.byType(AutomaticKeepAlive)),
      findsNothing,
    );
    expect([
      for (final element in collectAllElementsFrom(
        row.evaluate().single,
        skipOffstage: false,
      ))
        if (element is StatefulElement &&
            element.state is AutomaticKeepAliveClientMixin)
          element.widget.runtimeType,
    ], isEmpty);
  }

  double press() => tester
      .widget<CardSurface>(
        find.descendant(of: row, matching: find.byType(CardSurface)).first,
      )
      .pressed
      .value;

  expectNoneAsks();
  Focus.of(
    tester.element(find.descendant(of: row, matching: find.byType(ListRow))),
  ).requestFocus();
  await tester.pump();
  expectNoneAsks();

  final gesture = await tester.startGesture(tester.getCenter(row));
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pump(const Duration(milliseconds: 100));
  expect(press(), greaterThan(0));
  expectNoneAsks();

  final position = tester
      .state<ScrollableState>(
        find.ancestor(of: row, matching: find.byType(Scrollable)).first,
      )
      .position;
  final start = position.pixels;
  position.jumpTo(
    start == position.maxScrollExtent
        ? position.minScrollExtent
        : position.maxScrollExtent,
  );
  await tester.pump();
  expect(row, findsNothing);
  position.jumpTo(start);
  await tester.pump();
  expectNoneAsks();
  expect(press(), 0);

  await gesture.cancel();
  await tester.pumpAndSettle();
}
