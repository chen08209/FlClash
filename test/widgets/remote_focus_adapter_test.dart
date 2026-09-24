import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _buildApp({required bool enabled, required Widget home}) {
  return MaterialApp(
    builder: (context, child) {
      return RemoteFocusAdapter(enabled: enabled, child: child!);
    },
    home: home,
  );
}

Widget _buildForm() {
  return Scaffold(
    body: Column(
      children: [
        const TextField(key: ValueKey('name')),
        const TextField(key: ValueKey('url'), minLines: 1, maxLines: 5),
        Row(
          children: [
            TextButton(
              key: const ValueKey('cancel'),
              onPressed: () {},
              child: const Text('cancel'),
            ),
            TextButton(
              key: const ValueKey('submit'),
              onPressed: () {},
              child: const Text('submit'),
            ),
          ],
        ),
      ],
    ),
  );
}

bool _hasFocus(WidgetTester tester, Key key) {
  final editable = find.descendant(
    of: find.byKey(key),
    matching: find.byType(EditableText),
  );
  if (editable.evaluate().isNotEmpty) {
    return tester
        .state<EditableTextState>(editable)
        .widget
        .focusNode
        .hasPrimaryFocus;
  }
  final label = find.descendant(
    of: find.byKey(key),
    matching: find.byType(Text),
  );
  return Focus.of(tester.element(label.first)).hasPrimaryFocus;
}

bool _onActionRow(WidgetTester tester) {
  return _hasFocus(tester, const ValueKey('cancel')) ||
      _hasFocus(tester, const ValueKey('submit'));
}

TextEditingController _controllerOf(WidgetTester tester, Key key) {
  return tester
      .state<EditableTextState>(
        find.descendant(
          of: find.byKey(key),
          matching: find.byType(EditableText),
        ),
      )
      .widget
      .controller;
}

void main() {
  testWidgets('a pushed dialog focuses its first control', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        enabled: true,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              key: const ValueKey('open'),
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('title'),
                    actions: [
                      TextButton(
                        key: const ValueKey('ok'),
                        onPressed: () {},
                        child: const Text('ok'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('open')));
    await tester.pumpAndSettle();

    expect(_hasFocus(tester, const ValueKey('ok')), isTrue);
  });

  testWidgets('a pushed dialog keeps focus on its scope when disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(
        enabled: false,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              key: const ValueKey('open'),
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (_) => AlertDialog(
                    actions: [
                      TextButton(
                        key: const ValueKey('ok'),
                        onPressed: () {},
                        child: const Text('ok'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('open')));
    await tester.pumpAndSettle();

    expect(_hasFocus(tester, const ValueKey('ok')), isFalse);
    expect(FocusManager.instance.primaryFocus, isA<FocusScopeNode>());
  });

  testWidgets('down leaves an empty field for the control below', (
    tester,
  ) async {
    await tester.pumpWidget(_buildApp(enabled: true, home: _buildForm()));
    await tester.tap(find.byKey(const ValueKey('url')));
    await tester.pump();
    expect(_hasFocus(tester, const ValueKey('url')), isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();

    expect(_onActionRow(tester), isTrue);
  });

  testWidgets('up leaves the first line for the field above', (tester) async {
    await tester.pumpWidget(_buildApp(enabled: true, home: _buildForm()));
    await tester.enterText(find.byKey(const ValueKey('url')), 'https://a.b');
    await tester.pump();
    expect(_hasFocus(tester, const ValueKey('url')), isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();

    expect(_hasFocus(tester, const ValueKey('name')), isTrue);
  });

  testWidgets('left inside the text moves the caret, at the start it leaves', (
    tester,
  ) async {
    await tester.pumpWidget(_buildApp(enabled: true, home: _buildForm()));
    await tester.enterText(find.byKey(const ValueKey('url')), 'ab');
    await tester.pump();
    final controller = _controllerOf(tester, const ValueKey('url'));
    controller.selection = const TextSelection.collapsed(offset: 1);
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(_hasFocus(tester, const ValueKey('url')), isTrue);
    expect(controller.selection.baseOffset, 0);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(_onActionRow(tester), isTrue);
  });

  testWidgets('arrows stay in the field when disabled', (tester) async {
    await tester.pumpWidget(_buildApp(enabled: false, home: _buildForm()));
    await tester.tap(find.byKey(const ValueKey('url')));
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();

    expect(_hasFocus(tester, const ValueKey('url')), isTrue);
  });
}
