import 'dart:async';

import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

Future<void> _pushPage(
  WidgetTester tester, {
  required ValueListenable<bool> canSort,
}) async {
  await tester.pumpWidget(
    const TestApp(wrapInProviderScope: true, child: SizedBox()),
  );
  unawaited(
    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => ValueListenableBuilder<bool>(
              valueListenable: canSort,
              builder: (_, canSort, _) => CommonScaffold(
                title: 'Page',
                canSort: canSort,
                searchState: AppBarSearchState(onSearch: (_) {}),
                actions: [
                  TextButton(onPressed: () {}, child: const Text('Add')),
                ],
                body: Builder(
                  builder: (context) => Text(
                    SortModeScope.maybeOf(context)!.sorting
                        ? 'sorting'
                        : 'idle',
                  ),
                ),
              ),
            ),
          ),
        ),
  );
  await tester.pumpAndSettle();
}

Finder _inBar(Finder finder) =>
    find.descendant(of: find.byType(AppBar), matching: finder);

void _expectIdle(WidgetTester tester) {
  expect(find.text('idle'), findsOneWidget);
  expect(find.byType(BackButton).hitTestable(), findsOneWidget);
  expect(_inBar(find.byTooltip('Search')), findsOneWidget);
  expect(_inBar(find.text('Add')), findsOneWidget);
}

void _expectSorting(WidgetTester tester) {
  expect(find.text('sorting'), findsOneWidget);
  expect(find.byType(BackButton).hitTestable(), findsNothing);
  expect(_inBar(find.byTooltip('Search')), findsNothing);
  expect(_inBar(find.text('Add')), findsNothing);
  final toggle = _inBar(find.widgetWithGlyph(IconButton, AppGlyphs.sort));
  expect(tester.widget<IconButton>(toggle).isSelected, isTrue);
}

void main() {
  testWidgets('the bar toggle owns the bar until it or a back ends the mode', (
    tester,
  ) async {
    final canSort = ValueNotifier(true);
    addTearDown(canSort.dispose);
    await _pushPage(tester, canSort: canSort);
    _expectIdle(tester);

    await tester.tap(_inBar(find.byTooltip('Sort')));
    await tester.pumpAndSettle();
    _expectSorting(tester);

    await tester.tap(_inBar(find.byTooltip('Sort')));
    await tester.pumpAndSettle();
    _expectIdle(tester);

    await tester.tap(_inBar(find.byTooltip('Sort')));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    _expectIdle(tester);
  });

  testWidgets('the mode ends once the page can no longer sort', (tester) async {
    final canSort = ValueNotifier(true);
    addTearDown(canSort.dispose);
    await _pushPage(tester, canSort: canSort);

    await tester.tap(_inBar(find.byTooltip('Sort')));
    await tester.pumpAndSettle();
    canSort.value = false;
    await tester.pumpAndSettle();

    expect(find.text('idle'), findsOneWidget);
    expect(find.byType(BackButton).hitTestable(), findsOneWidget);
  });
}
