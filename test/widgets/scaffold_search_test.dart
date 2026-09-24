import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

Future<void> _sendFind(WidgetTester tester) async {
  final modifier = controlSingleActivator(LogicalKeyboardKey.keyF).meta
      ? LogicalKeyboardKey.metaLeft
      : LogicalKeyboardKey.controlLeft;
  await tester.sendKeyDownEvent(modifier);
  await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
  await tester.sendKeyUpEvent(modifier);
  await tester.pumpAndSettle();
}

Widget _page({
  ValueChanged<String>? onSearch,
  List<Widget> actions = const [],
  List<IconButtonData> searchActions = const [],
}) {
  return CommonScaffold(
    title: 'Page',
    searchState: onSearch == null
        ? null
        : AppBarSearchState(onSearch: onSearch),
    actions: actions,
    searchActions: searchActions,
    body: const SizedBox.expand(),
  );
}

void main() {
  testWidgets('the find shortcut opens search and refocuses the field', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(wrapInProviderScope: true, child: _page(onSearch: (_) {})),
    );

    await _sendFind(tester);
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'needle');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();

    await _sendFind(tester);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.focusNode!.hasFocus, isTrue);
    expect(
      field.controller!.selection,
      const TextSelection(baseOffset: 0, extentOffset: 6),
    );
  });

  testWidgets('the find shortcut leaves a page without search alone', (
    tester,
  ) async {
    await tester.pumpWidget(TestApp(wrapInProviderScope: true, child: _page()));

    await _sendFind(tester);

    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('the find shortcut skips a page under another route', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(wrapInProviderScope: true, child: _page(onSearch: (_) {})),
    );
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));

    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('covering route')),
      ),
    );
    await tester.pumpAndSettle();
    await _sendFind(tester);
    expect(find.byType(TextField, skipOffstage: false), findsNothing);

    navigator.pop();
    await tester.pumpAndSettle();
    await _sendFind(tester);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('the find shortcut skips an inactive page', (tester) async {
    final searches = <String>[];
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: PageActivityScope(
          isActive: false,
          child: _page(onSearch: searches.add),
        ),
      ),
    );

    await _sendFind(tester);

    expect(searches, isEmpty);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('search actions stay beside the field while actions hide', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: _page(
          onSearch: (_) {},
          actions: const [Text('page action')],
          searchActions: [
            IconButtonData(
              glyph: AppGlyphs.add,
              onPressed: () {},
              tooltip: 'search action',
            ),
          ],
        ),
      ),
    );
    expect(find.text('page action'), findsOneWidget);
    expect(find.byTooltip('search action'), findsNothing);

    await tester.tap(find.byGlyph(AppGlyphs.search));
    await tester.pumpAndSettle();

    expect(find.text('page action'), findsNothing);
    expect(find.byTooltip('search action'), findsOneWidget);
  });
}
