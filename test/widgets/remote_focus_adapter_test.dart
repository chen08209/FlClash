import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _buildApp({
  required bool enabled,
  required Widget home,
  ValueListenable<bool>? floatingKeyboard,
}) {
  return MaterialApp(
    builder: (context, child) {
      return RemoteFocusAdapter(
        enabled: enabled,
        floatingKeyboard: floatingKeyboard,
        child: child!,
      );
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

Widget _buildFieldsBelowButton() {
  return Scaffold(
    body: Column(
      children: [
        TextButton(onPressed: () {}, child: const Text('top')),
        const TextField(key: ValueKey('name')),
        const TextField(key: ValueKey('url')),
      ],
    ),
  );
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

  Widget buildList(ScrollController controller) {
    return Scaffold(
      body: ListView(
        controller: controller,
        children: [
          TextButton(
            key: const ValueKey('first'),
            onPressed: () {},
            child: const Text('first'),
          ),
          TextButton(
            key: const ValueKey('second'),
            onPressed: () {},
            child: const Text('second'),
          ),
          const SizedBox(height: 2000),
        ],
      ),
    );
  }

  Future<void> focusText(WidgetTester tester, String text) async {
    Focus.of(tester.element(find.text(text))).requestFocus();
    await tester.pump();
  }

  testWidgets('down with no control below scrolls by half a viewport', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _buildApp(enabled: true, home: buildList(controller)),
    );
    await focusText(tester, 'second');
    final second = FocusManager.instance.primaryFocus;

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();

    expect(FocusManager.instance.primaryFocus, same(second));
    expect(controller.offset, 300);
  });

  testWidgets('down that moves focus leaves the list where it is', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _buildApp(enabled: true, home: buildList(controller)),
    );
    await focusText(tester, 'first');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();

    expect(_hasFocus(tester, const ValueKey('second')), isTrue);
    expect(controller.offset, 0);
  });

  testWidgets('down from a bar below the list scrolls the route list', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(
        enabled: true,
        home: Scaffold(
          body: Column(
            children: [
              Expanded(
                child: ListView(children: const [SizedBox(height: 2000)]),
              ),
              TextButton(onPressed: () {}, child: const Text('bar')),
            ],
          ),
        ),
      ),
    );
    await focusText(tester, 'bar');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();

    final position = tester
        .state<ScrollableState>(find.byType(Scrollable))
        .position;
    expect(position.pixels, greaterThan(0));
  });

  testWidgets('down with no control below stays put when disabled', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _buildApp(enabled: false, home: buildList(controller)),
    );
    await focusText(tester, 'second');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();

    expect(controller.offset, 0);
  });

  testWidgets('arrows stay in the field when disabled', (tester) async {
    await tester.pumpWidget(_buildApp(enabled: false, home: _buildForm()));
    await tester.tap(find.byKey(const ValueKey('url')));
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();

    expect(_hasFocus(tester, const ValueKey('url')), isTrue);
  });

  testWidgets('a field the remote moves to opens the keyboard on select', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(enabled: true, home: _buildFieldsBelowButton()),
    );
    await focusText(tester, 'top');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(_hasFocus(tester, const ValueKey('name')), isTrue);
    expect(tester.testTextInput.hasAnyClients, isFalse);

    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pump();
    expect(_hasFocus(tester, const ValueKey('name')), isTrue);
    expect(tester.testTextInput.isVisible, isTrue);
  });

  testWidgets('a dialog the remote opens focuses its field without keyboard', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(
        enabled: true,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (_) => const AlertDialog(
                    content: TextField(key: ValueKey('field'), autofocus: true),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await focusText(tester, 'open');

    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();

    expect(_hasFocus(tester, const ValueKey('field')), isTrue);
    expect(tester.testTextInput.hasAnyClients, isFalse);
  });

  testWidgets('a field tapped after using the remote opens the keyboard', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(enabled: true, home: _buildFieldsBelowButton()),
    );
    await focusText(tester, 'top');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('url')));
    await tester.pump();

    expect(_hasFocus(tester, const ValueKey('url')), isTrue);
    expect(tester.testTextInput.isVisible, isTrue);
  });

  testWidgets('the next field keeps a keyboard select opened', (tester) async {
    await tester.pumpWidget(
      _buildApp(enabled: true, home: _buildFieldsBelowButton()),
    );
    await focusText(tester, 'top');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pump();

    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();

    expect(_hasFocus(tester, const ValueKey('url')), isTrue);
    expect(tester.testTextInput.isVisible, isTrue);
  });

  testWidgets('a remote key after select leaves the next field closed', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(enabled: true, home: _buildFieldsBelowButton()),
    );
    await focusText(tester, 'top');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();

    expect(_hasFocus(tester, const ValueKey('url')), isTrue);
    expect(tester.testTextInput.hasAnyClients, isFalse);
  });

  testWidgets('the next field keeps a keyboard that insets the view', (
    tester,
  ) async {
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(
      _buildApp(enabled: true, home: _buildFieldsBelowButton()),
    );
    await focusText(tester, 'top');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('name')));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.shiftLeft);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pump();

    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();

    expect(_hasFocus(tester, const ValueKey('url')), isTrue);
    expect(tester.testTextInput.isVisible, isTrue);
  });

  testWidgets('the next field keeps a floating keyboard', (tester) async {
    final floating = ValueNotifier(false);
    addTearDown(floating.dispose);
    await tester.pumpWidget(
      _buildApp(
        enabled: true,
        floatingKeyboard: floating,
        home: _buildFieldsBelowButton(),
      ),
    );
    await focusText(tester, 'top');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('name')));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.shiftLeft);
    floating.value = true;
    await tester.pump();

    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();

    expect(_hasFocus(tester, const ValueKey('url')), isTrue);
    expect(tester.testTextInput.isVisible, isTrue);
  });

  testWidgets('a floating keyboard insets the screen while it is up', (
    tester,
  ) async {
    final floating = ValueNotifier(false);
    addTearDown(floating.dispose);
    await tester.pumpWidget(
      _buildApp(
        enabled: true,
        floatingKeyboard: floating,
        home: const SizedBox(key: ValueKey('page')),
      ),
    );
    double bottomInset() => MediaQuery.viewInsetsOf(
      tester.element(find.byKey(const ValueKey('page'))),
    ).bottom;

    floating.value = true;
    await tester.pump();
    expect(bottomInset(), 300);

    floating.value = false;
    await tester.pump();
    expect(bottomInset(), 0);
  });

  testWidgets('a dialog field a floating keyboard covers is revealed', (
    tester,
  ) async {
    final floating = ValueNotifier(false);
    addTearDown(floating.dispose);
    await tester.pumpWidget(
      _buildApp(
        enabled: true,
        floatingKeyboard: floating,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (_) => const AlertDialog(
                    content: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 360),
                          TextField(key: ValueKey('field'), autofocus: true),
                        ],
                      ),
                    ),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byKey(const ValueKey('field'))).bottom,
      greaterThan(300),
    );

    floating.value = true;
    await tester.pumpAndSettle();

    expect(
      tester.getRect(find.byKey(const ValueKey('field'))).bottom,
      lessThanOrEqualTo(300),
    );
  });

  testWidgets('the keyboard follows focus when disabled', (tester) async {
    await tester.pumpWidget(
      _buildApp(enabled: false, home: _buildFieldsBelowButton()),
    );
    await focusText(tester, 'top');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();

    expect(_hasFocus(tester, const ValueKey('name')), isTrue);
    expect(tester.testTextInput.isVisible, isTrue);
  });
}
