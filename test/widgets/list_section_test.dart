import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

void main() {
  Rect rowRect(WidgetTester tester, String title) =>
      tester.getRect(find.widgetWithText(DecorationListItem, title));

  testWidgets('a section without a title keeps the space a title stands in', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        child: Scaffold(
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              generateSection(
                items: [const DecorationListItem(title: Text('first'))],
                footer: 'note',
              ),
              generateSection(
                items: [const DecorationListItem(title: Text('second'))],
              ),
              generateSection(
                items: [const DecorationListItem(title: Text('third'))],
              ),
            ],
          ),
        ),
      ),
    );

    final context = tester.element(find.byType(ListView));
    final gap = listHeaderPaddingOf(context).top;
    expect(rowRect(tester, 'first').top, gap);
    expect(
      rowRect(tester, 'second').top,
      tester.getRect(find.byType(ListFooter)).bottom + gap,
    );
    expect(
      rowRect(tester, 'third').top,
      rowRect(tester, 'second').bottom + gap,
    );
  });

  for (final title in [null, 'title']) {
    testWidgets(
      'a page opening on a ${title ?? 'bare'} section starts it where content '
      'starts',
      (tester) async {
        late double contentTop;
        await tester.pumpWidget(
          TestApp(
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  contentTop = context.contentTopPadding;
                  return ListView(
                    padding: EdgeInsets.only(top: context.sectionsTopPadding),
                    children: [
                      generateSection(
                        title: title,
                        items: [const DecorationListItem(title: Text('row'))],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );

        final opening = title == null
            ? rowRect(tester, 'row')
            : tester.getRect(find.text(title));
        expect(opening.top, contentTop);
      },
    );
  }

  testWidgets('a group under its caller\'s header keeps no space of its own', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        child: Scaffold(
          body: Column(
            children: [
              generateGroup([const DecorationListItem(title: Text('row'))]),
            ],
          ),
        ),
      ),
    );

    expect(rowRect(tester, 'row').top, 0);
  });
}
