import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

Widget _action() {
  return CommonFloatingActionButton(
    key: const ValueKey('action'),
    onPressed: () {},
    icon: const GlyphIcon(AppGlyphs.add),
    label: 'action',
  );
}

Widget _content() {
  return ListView(
    children: [
      for (var index = 0; index < 20; index++)
        SizedBox(
          height: 80,
          child: TextButton(
            key: ValueKey('item$index'),
            onPressed: () {},
            child: Text('item $index'),
          ),
        ),
    ],
  );
}

bool _isActionFocused() {
  final context = FocusManager.instance.primaryFocus?.context;
  return context?.findAncestorWidgetOfExactType<FloatingActionButton>() != null;
}

void main() {
  testWidgets('non-TV CommonScaffold keeps the Scaffold FAB', (tester) async {
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: CommonScaffold(
          title: 'page',
          isTV: false,
          floatingActionButton: _action(),
          body: _content(),
        ),
      ),
    );

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));

    expect(scaffold.floatingActionButton, isNotNull);
  });

  testWidgets('CommonScaffold pins the FAB above scrollable content on TV', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: CommonScaffold(
          title: 'page',
          isTV: true,
          floatingActionButton: _action(),
          body: _content(),
        ),
      ),
    );

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    final action = find.byKey(const ValueKey('action'));
    final firstItem = find.byKey(const ValueKey('item0'));
    final initialActionTop = tester.getTopLeft(action).dy;

    expect(scaffold.floatingActionButton, isNull);
    expect(initialActionTop, lessThan(tester.getTopLeft(firstItem).dy));

    await tester.drag(firstItem, const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(action).dy, initialActionTop);
  });

  testWidgets('TV top action is the first focus target in page content', (
    tester,
  ) async {
    final outsideFocus = FocusNode();
    addTearDown(outsideFocus.dispose);
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: Column(
          children: [
            Focus(focusNode: outsideFocus, child: const SizedBox()),
            Expanded(
              child: CommonScaffold(
                title: 'page',
                isTV: true,
                floatingActionButton: _action(),
                body: _content(),
              ),
            ),
          ],
        ),
      ),
    );
    outsideFocus.requestFocus();
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();

    expect(_isActionFocused(), isTrue);
  });
}
