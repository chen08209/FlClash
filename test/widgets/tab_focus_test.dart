import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _labels = <int, String>{0: 'One', 1: 'Two', 2: 'Three'};

Future<void> _pumpTabBar(
  WidgetTester tester, {
  required ValueChanged<int?> onValueChanged,
  Set<int> disabledChildren = const {},
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: FocusTraversalGroup(
          policy: PageTraversalPolicy(),
          child: PageFocusScope(
            child: Center(
              child: CommonTabBar<int>(
                groupValue: 0,
                disabledChildren: disabledChildren,
                thumbColor: Colors.blue,
                backgroundColor: Colors.grey,
                children: {
                  for (final entry in _labels.entries)
                    entry.key: Text(entry.value),
                },
                onValueChanged: onValueChanged,
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

String? _focusedLabel() {
  final context = FocusManager.instance.primaryFocus?.context;
  if (context == null) {
    return null;
  }
  final labels = find
      .descendant(
        of: find.byWidget(context.widget),
        matching: find.byType(Text),
      )
      .evaluate()
      .map((element) => (element.widget as Text).data)
      .whereType<String>()
      .toSet();
  return labels.isEmpty ? null : labels.first;
}

bool _hasFocusRing(WidgetTester tester, String label) {
  return tester
      .widgetList<DecoratedBox>(
        find.ancestor(
          of: find.text(label).first,
          matching: find.byType(DecoratedBox),
        ),
      )
      .any((box) {
        final decoration = box.decoration;
        return decoration is ShapeDecoration &&
            decoration.shape is RoundedSuperellipseBorder &&
            (decoration.shape as RoundedSuperellipseBorder).side.style ==
                BorderStyle.solid;
      });
}

Future<void> _focusFirstSegment(WidgetTester tester) async {
  await tester.sendKeyEvent(LogicalKeyboardKey.tab);
  await tester.pump();
  expect(_focusedLabel(), 'One', reason: 'tab should seed focus on a segment');
}

void main() {
  testWidgets('arrow right walks from one segment to the next', (tester) async {
    await _pumpTabBar(tester, onValueChanged: (_) {});
    await _focusFirstSegment(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();

    expect(_focusedLabel(), 'Two');
  });

  testWidgets('the focused segment shows a focus ring', (tester) async {
    await _pumpTabBar(tester, onValueChanged: (_) {});
    expect(_hasFocusRing(tester, 'One'), isFalse);

    await _focusFirstSegment(tester);

    expect(_hasFocusRing(tester, 'One'), isTrue);
    expect(_hasFocusRing(tester, 'Two'), isFalse);
  });

  testWidgets('activating a focused segment reports its value', (tester) async {
    final values = <int?>[];
    await _pumpTabBar(tester, onValueChanged: values.add);
    await _focusFirstSegment(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(_focusedLabel(), 'Two');

    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();
    expect(values, <int>[1]);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(values, <int>[1, 1]);
  });

  testWidgets('traversal skips a disabled segment', (tester) async {
    final values = <int?>[];
    await _pumpTabBar(
      tester,
      onValueChanged: values.add,
      disabledChildren: const {1},
    );
    await _focusFirstSegment(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();

    expect(_focusedLabel(), 'Three');

    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();
    expect(values, <int>[2]);
  });
}
