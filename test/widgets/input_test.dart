import 'dart:ui' as ui;

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

final _viewSizeOverride = viewSizeProvider.overrideWithBuild(
  (_, _) => const Size(1200, 1000),
);

void main() {
  testWidgets('ListItem.toggle toggles when tapping the row', (tester) async {
    bool? changedValue;

    await tester.pumpWidget(
      TestApp(
        overrides: [_viewSizeOverride],
        child: Scaffold(
          body: ListItem.toggle(
            title: const Text('Enabled'),
            value: false,
            onChanged: (value) {
              changedValue = value;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Enabled'));

    expect(changedValue, isTrue);
  });

  testWidgets('ListItem.toggle is disabled without onChanged', (tester) async {
    await tester.pumpWidget(
      TestApp(
        overrides: [_viewSizeOverride],
        child: Scaffold(
          body: ListItem.toggle(title: const Text('Disabled'), value: false),
        ),
      ),
    );

    final tile = tester.widget<ListTile>(find.byType(ListTile));
    final control = tester.widget<Switch>(find.byType(Switch));

    expect(tile.onTap, isNull);
    expect(control.onChanged, isNull);

    await tester.tap(find.text('Disabled'));
    await tester.pump();
  });

  testWidgets('ListItem takes the grouped card inside a V3 section', (
    tester,
  ) async {
    bool? changedValue;

    await tester.pumpWidget(
      TestApp(
        overrides: [_viewSizeOverride],
        child: Scaffold(
          body: generateSectionV3(
            items: [
              ListItem.toggle(
                title: const Text('Grouped'),
                value: false,
                onChanged: (value) {
                  changedValue = value;
                },
              ),
              ListItem.open(
                title: const Text('Opens'),
                widget: const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );

    ItemPosition positionOf(String text) => tester
        .widget<ItemPositionProvider>(
          find
              .ancestor(
                of: find.text(text),
                matching: find.byType(ItemPositionProvider),
              )
              .first,
        )
        .position;

    expect(find.byType(DecorationListItem), findsNWidgets(2));
    expect(positionOf('Grouped'), ItemPosition.start);
    expect(positionOf('Opens'), ItemPosition.end);

    await tester.tap(find.text('Grouped'));

    expect(changedValue, isTrue);
  });

  testWidgets('ListItem.checkbox toggles when tapping the row', (tester) async {
    bool? changedValue;

    await tester.pumpWidget(
      TestApp(
        overrides: [_viewSizeOverride],
        child: Scaffold(
          body: ListItem.checkbox(
            title: const Text('Selected'),
            onChanged: (value) {
              changedValue = value;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Selected'));

    expect(changedValue, isTrue);
  });

  testWidgets('ListItem.input limits dialog text by maxLength', (tester) async {
    String? changedValue;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          viewSizeProvider.overrideWithBuild((_, _) => const Size(1200, 1000)),
        ],
        child: TestApp(
          overrides: [
            viewSizeProvider.overrideWithBuild(
              (_, _) => const Size(1200, 1000),
            ),
          ],
          child: Scaffold(
            body: ListItem.input(
              title: const Text('Port'),
              dialogTitle: 'Port',
              value: '',
              maxLength: 5,
              onChanged: (value) {
                changedValue = value;
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Port'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '123456789');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(changedValue, '12345');
  });

  testWidgets('ListEditView reorders using final insertion index', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: TestApp(
          overrides: [
            viewSizeProvider.overrideWithBuild(
              (_, _) => const Size(1200, 1000),
            ),
          ],
          child: const ListEditView(
            title: 'Items',
            items: ['a', 'b', 'c'],
            titleBuilder: _textBuilder,
          ),
        ),
      ),
    );

    final listView = tester.widget<ReorderableListView>(
      find.byType(ReorderableListView),
    );

    listView.onReorderItem!(0, 2);
    await tester.pump();

    expect(_top(tester, 'b'), lessThan(_top(tester, 'c')));
    expect(_top(tester, 'c'), lessThan(_top(tester, 'a')));
  });

  testWidgets('OptionsDialog returns the tapped option', (tester) async {
    String? selected;

    await tester.pumpWidget(
      TestApp(
        overrides: [_viewSizeOverride],
        child: Builder(
          builder: (context) {
            return FilledButton(
              onPressed: () async {
                selected = await showDialog<String>(
                  context: context,
                  builder: (_) => const OptionsDialog<String>(
                    title: 'Options',
                    options: ['One', 'Two'],
                    value: 'One',
                    textBuilder: _optionText,
                  ),
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Two'));
    await tester.pumpAndSettle();

    expect(selected, 'Two');
  });

  testWidgets('InputDialog validates, submits, and resets values', (
    tester,
  ) async {
    String? result;

    await tester.pumpWidget(
      TestApp(
        overrides: [_viewSizeOverride],
        child: Builder(
          builder: (context) {
            return FilledButton(
              onPressed: () async {
                result = await showDialog<String>(
                  context: context,
                  builder: (_) => InputDialog(
                    title: 'Value',
                    value: 'changed',
                    resetValue: 'default',
                    labelText: 'Value',
                    suffixText: 'unit',
                    hintText: 'hint',
                    validator: (value) => value == 'valid' ? null : 'Invalid',
                  ),
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit'));
    await tester.pump();
    expect(find.text('Invalid'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'valid');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(result, 'valid');

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    expect(result, 'default');
  });

  testWidgets(
    'NamedUrlDialog puts the optional name first and focuses the url',
    (tester) async {
      ({String label, String url})? result;

      await tester.pumpWidget(
        TestApp(
          overrides: [_viewSizeOverride],
          child: Builder(
            builder: (context) {
              return FilledButton(
                onPressed: () async {
                  result = await showDialog<({String label, String url})>(
                    context: context,
                    builder: (_) => const NamedUrlDialog(title: 'Import'),
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final nameField = find.widgetWithText(TextFormField, 'Name');
      final urlField = find.widgetWithText(TextFormField, 'URL');
      expect(
        tester.getTopLeft(nameField).dy,
        lessThan(tester.getTopLeft(urlField).dy),
      );
      expect(find.text('Optional'), findsOneWidget);
      expect(
        tester
            .widget<EditableText>(
              find.descendant(
                of: urlField,
                matching: find.byType(EditableText),
              ),
            )
            .focusNode
            .hasFocus,
        isTrue,
      );

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(find.text('URL cannot be empty'), findsOneWidget);
      expect(result, isNull);

      await tester.enterText(nameField, 'Home');
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();
      expect(
        tester
            .widget<EditableText>(
              find.descendant(
                of: urlField,
                matching: find.byType(EditableText),
              ),
            )
            .focusNode
            .hasFocus,
        isTrue,
      );

      await tester.enterText(urlField, 'https://example.com/sub');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(result, (label: 'Home', url: 'https://example.com/sub'));
    },
  );

  testWidgets('EntryDialog returns scalar and map values', (tester) async {
    Object? result;

    await tester.pumpWidget(
      TestApp(
        overrides: [_viewSizeOverride],
        child: Builder(
          builder: (context) {
            return Column(
              children: [
                FilledButton(
                  onPressed: () async {
                    result = await showDialog<List<String>>(
                      context: context,
                      builder: (_) => const EntryDialog<String>(
                        title: 'Scalar',
                        valueField: Field(label: 'Value', value: ''),
                        valueMaxLength: 4,
                        toEntry: _scalarEntry,
                      ),
                    );
                  },
                  child: const Text('Scalar'),
                ),
                FilledButton(
                  onPressed: () async {
                    result = await showDialog<List<MapEntry<String, String>>>(
                      context: context,
                      builder: (_) =>
                          const EntryDialog<MapEntry<String, String>>(
                            title: 'Pair',
                            keyField: Field(label: 'Key', value: ''),
                            valueField: Field(label: 'Value', value: ''),
                            keyMaxLength: 3,
                            valueMaxLength: 4,
                            toEntry: _pairEntry,
                          ),
                    );
                  },
                  child: const Text('Pair'),
                ),
              ],
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Scalar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pump();
    expect(find.byType(EntryDialog<String>), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'value');
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(result, ['valu']);

    await tester.tap(find.text('Pair'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.first, 'key1');
    await tester.enterText(fields.last, 'value');
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    final pair = (result! as List<MapEntry<String, String>>).single;
    expect(pair.key, 'key');
    expect(pair.value, 'valu');
  });

  testWidgets('ListEditView adds, edits, selects, and deletes items', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: TestApp(
          overrides: [
            viewSizeProvider.overrideWithBuild(
              (_, _) => const Size(1200, 1000),
            ),
          ],
          child: const ListEditView(
            title: 'Items',
            items: ['a', 'b'],
            titleBuilder: _textBuilder,
            subtitleBuilder: _textBuilder,
            leadingBuilder: _textBuilder,
            itemMaxLength: 4,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'c');
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(find.text('c'), findsNWidgets(3));

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'x, y');
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(find.text('Value must be a single item'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'a');
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(find.text('Value already exists'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), ' x ');
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(find.text('x'), findsNWidgets(3));

    await tester.tap(find.text('c').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'd');
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(find.text('d'), findsNWidgets(3));

    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();
    expect(find.byGlyph(AppGlyphs.delete), findsOneWidget);
    await tester.tap(find.text('Select all'));
    await tester.pump();
    await tester.tap(find.byGlyph(AppGlyphs.delete));
    await tester.pump();
    expect(find.text('No data'), findsOneWidget);
  });

  testWidgets('MapEditView adds, reorders, selects, and deletes entries', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: TestApp(
          overrides: [
            viewSizeProvider.overrideWithBuild(
              (_, _) => const Size(1200, 1000),
            ),
          ],
          child: const MapEditView(
            title: 'Map',
            entries: {'a': '1', 'b': '2'},
            titleBuilder: _entryTitle,
            subtitleBuilder: _entrySubtitle,
            leadingBuilder: _entryTitle,
            keyMaxLength: 4,
            valueMaxLength: 4,
          ),
        ),
      ),
    );

    final listView = tester.widget<ReorderableListView>(
      find.byType(ReorderableListView),
    );
    listView.onReorderItem!(0, 1);
    await tester.pump();
    expect(
      tester.getTopLeft(find.text('b').first).dy,
      lessThan(tester.getTopLeft(find.text('a').first).dy),
    );

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.first, 'c');
    await tester.enterText(fields.last, '3');
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(find.text('c'), findsNWidgets(2));

    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();
    await tester.tap(find.text('Select all'));
    await tester.pump();
    await tester.tap(find.byGlyph(AppGlyphs.delete));
    await tester.pump();
    expect(find.text('No data'), findsOneWidget);
  });

  testWidgets(
    'ListEditView batch add previews, blocks issues, skips existing',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: TestApp(
            overrides: [
              viewSizeProvider.overrideWithBuild(
                (_, _) => const Size(1200, 1000),
              ),
            ],
            child: const ListEditView(
              title: 'Items',
              items: ['a'],
              titleBuilder: _textBuilder,
              itemMaxLength: 4,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Batch add'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Single add'), findsOneWidget);
      expect(_confirmButton(tester).onPressed, isNull);
      expect(
        find.text('One item per line, or separated by commas'),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextField), 'toolong\nx');
      await tester.pump();
      expect(
        find.text('Line 1: Value must be at most 4 characters'),
        findsOneWidget,
      );
      expect(_confirmButton(tester).onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'a, x\ny');
      await tester.pump();
      expect(find.text('2 to add, 1 skipped as existing'), findsOneWidget);
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(find.byType(EntryDialog<String>), findsNothing);
      expect(find.text('a'), findsOneWidget);
      expect(find.text('x'), findsOneWidget);
      expect(find.text('y'), findsOneWidget);
    },
  );

  testWidgets('MapEditView batch add parses lines and skips existing keys', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: TestApp(
          overrides: [
            viewSizeProvider.overrideWithBuild(
              (_, _) => const Size(1200, 1000),
            ),
          ],
          child: const MapEditView(
            title: 'Map',
            entries: {'a': '1'},
            titleBuilder: _entryTitle,
            subtitleBuilder: _entrySubtitle,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'c');
    await tester.enterText(find.byType(TextFormField).last, '3');
    await tester.tap(find.byTooltip('Batch add'));
    await tester.pumpAndSettle();
    expect(find.text('1 to add, 0 skipped as existing'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'c 3\na 9\nd');
    await tester.pump();
    expect(find.text('Line 3: Value cannot be empty'), findsOneWidget);
    expect(_confirmButton(tester).onPressed, isNull);

    await tester.enterText(
      find.byType(TextField),
      'geosite:cn tls://1.1.1.1:853\na 9',
    );
    await tester.pump();
    expect(find.text('1 to add, 1 skipped as existing'), findsOneWidget);
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(find.text('geosite:cn'), findsOneWidget);
    expect(find.text('tls://1.1.1.1:853'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('9'), findsNothing);
  });

  test('NoInputBorder implements border geometry and interior painting', () {
    const border = NoInputBorder();
    const rect = Rect.fromLTWH(1, 2, 30, 40);

    expect(border.copyWith(), isA<NoInputBorder>());
    expect(border.scale(2), isA<NoInputBorder>());
    expect(border.isOutline, isFalse);
    expect(border.dimensions, EdgeInsets.zero);
    expect(border.preferPaintInterior, isTrue);
    expect(border.getInnerPath(rect).getBounds(), rect);
    expect(border.getOuterPath(rect).getBounds(), rect);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    border.paintInterior(canvas, rect, Paint()..color = Colors.red);
    border.paint(canvas, rect);
    recorder.endRecording();
  });
}

String _optionText(String value) => value;

String _scalarEntry(String? key, String value) => value;

MapEntry<String, String> _pairEntry(String? key, String value) =>
    MapEntry(key!, value);

Widget _textBuilder(String value) {
  return Text(value);
}

Widget _entryTitle(MapEntry<String, String> value) => Text(value.key);

Widget _entrySubtitle(MapEntry<String, String> value) => Text(value.value);

TextButton _confirmButton(WidgetTester tester) {
  return tester.widget<TextButton>(
    find.ancestor(of: find.text('Confirm'), matching: find.byType(TextButton)),
  );
}

double _top(WidgetTester tester, String text) {
  return tester.getTopLeft(find.text(text)).dy;
}
