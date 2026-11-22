import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/host_scaffold.dart';

void main() {
  Rect rowRect(WidgetTester tester, String title) =>
      tester.getRect(find.widgetWithText(DecorationListItem, title));

  testWidgets('a section without a title keeps the space a title stands in', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        child: HostScaffold(
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
            child: HostScaffold(
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
        child: HostScaffold(
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

  testWidgets('a grouped list item keeps the padding and alignment it is '
      'given, as one standing alone does', (tester) async {
    Widget item(String name) => ListItem(
      leading: SizedBox(key: ValueKey('$name leading'), width: 24, height: 10),
      title: Text('$name title'),
      subtitle: const Text('one\ntwo\nthree'),
      minVerticalPadding: 30,
      alignment: ListRowAlignment.top,
    );
    await tester.pumpWidget(
      TestApp(
        child: HostScaffold(
          body: Column(
            children: [
              item('alone'),
              generateGroup([item('grouped')]),
            ],
          ),
        ),
      ),
    );

    Offset inRow(String name, Finder part) =>
        tester.getTopLeft(part) -
        tester.getTopLeft(
          find.ancestor(of: part, matching: find.byType(ListItem<dynamic>)),
        );
    for (final part in ['leading', 'title']) {
      Finder of(String name) => part == 'leading'
          ? find.byKey(ValueKey('$name leading'))
          : find.text('$name title');
      expect(inRow('grouped', of('grouped')), inRow('alone', of('alone')));
    }
  });
}
