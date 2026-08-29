import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildPage({bool wrapNavigator = false}) {
  final page = Scaffold(
    body: Column(
      children: [
        for (var i = 0; i < 3; i++)
          TextButton(
            key: ValueKey('item$i'),
            onPressed: () {},
            child: Text('item $i'),
          ),
      ],
    ),
    floatingActionButton: CommonFloatingActionButton(
      onPressed: () {},
      icon: const Icon(Icons.add),
      label: 'add',
    ),
  );
  final scopedPage = PageFocusScope(child: page);
  return FocusTraversalGroup(
    policy: PageTraversalPolicy(),
    child: wrapNavigator
        ? Navigator(
            pages: [MaterialPage(child: scopedPage)],
            onDidRemovePage: (_) {},
          )
        : scopedPage,
  );
}

Future<FocusNode> _pumpWithOutsideFocus(
  WidgetTester tester,
  Widget child,
) async {
  final outsideFocus = FocusNode();
  addTearDown(outsideFocus.dispose);
  await tester.pumpWidget(
    MaterialApp(
      home: Column(
        children: [
          Focus(focusNode: outsideFocus, child: const SizedBox()),
          Expanded(child: child),
        ],
      ),
    ),
  );
  await tester.pump();
  outsideFocus.requestFocus();
  await tester.pump();
  return outsideFocus;
}

bool _isFabFocused() {
  final context = FocusManager.instance.primaryFocus?.context;
  return context?.findAncestorWidgetOfExactType<FloatingActionButton>() != null;
}

String? _focusedItemKey() {
  final context = FocusManager.instance.primaryFocus?.context;
  final button = context?.findAncestorWidgetOfExactType<TextButton>();
  return switch (button?.key) {
    ValueKey<String>(value: final value) => value,
    _ => null,
  };
}

void main() {
  for (final wrapNavigator in [false, true]) {
    testWidgets(
      'page${wrapNavigator ? ' navigator' : ''} uses natural focus order',
      (tester) async {
        await _pumpWithOutsideFocus(
          tester,
          _buildPage(wrapNavigator: wrapNavigator),
        );

        for (var i = 0; i < 3; i++) {
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();
          expect(_focusedItemKey(), 'item$i');
        }

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(_isFabFocused(), isTrue);
      },
    );
  }

  testWidgets('tab leaves the page after the final control', (tester) async {
    final outsideFocus = await _pumpWithOutsideFocus(tester, _buildPage());

    for (var i = 0; i < 4; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    }
    expect(_isFabFocused(), isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();

    expect(FocusManager.instance.primaryFocus, outsideFocus);
  });

  testWidgets('shift-tab leaves the page from the first control', (
    tester,
  ) async {
    final outsideFocus = await _pumpWithOutsideFocus(tester, _buildPage());

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(_focusedItemKey(), 'item0');

    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();

    expect(FocusManager.instance.primaryFocus, outsideFocus);
  });

  testWidgets('directional keys keep moving inside page content', (
    tester,
  ) async {
    await _pumpWithOutsideFocus(tester, _buildPage());

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(_focusedItemKey(), 'item0');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();

    expect(_focusedItemKey(), 'item1');
  });

  testWidgets('left leaves page content for an adjacent sidebar', (
    tester,
  ) async {
    final sidebarFocus = FocusNode();
    addTearDown(sidebarFocus.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Row(
          children: [
            Focus(
              focusNode: sidebarFocus,
              child: const SizedBox(width: 80, height: 80),
            ),
            Expanded(child: _buildPage(wrapNavigator: true)),
          ],
        ),
      ),
    );
    await tester.pump();
    sidebarFocus.requestFocus();
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(_focusedItemKey(), 'item0');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();

    expect(FocusManager.instance.primaryFocus, sidebarFocus);
  });
}
