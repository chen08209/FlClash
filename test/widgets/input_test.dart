import 'dart:ui' as ui;

import 'package:fl_clash/features/form/form.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';
import '../helpers/host_scaffold.dart';

final _viewSizeOverride = viewSizeProvider.overrideWithBuild(
  (_, _) => const Size(1200, 1000),
);

void main() {
  testWidgets('ListItem.toggle toggles when tapping the row', (tester) async {
    bool? changedValue;

    await tester.pumpWidget(
      TestApp(
        overrides: [_viewSizeOverride],
        child: HostScaffold(
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
        child: HostScaffold(
          body: ListItem.toggle(title: const Text('Disabled'), value: false),
        ),
      ),
    );

    final control = tester.widget<Switch>(find.byType(Switch));

    expect(find.byType(PressSurface), findsNothing);
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
        child: HostScaffold(
          body: generateSection(
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
        child: HostScaffold(
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
          child: HostScaffold(
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

    final listView = tester.widget<PrismReorderableListView>(
      find.byType(PrismReorderableListView),
    );

    listView.onReorderItem(0, 2);
    await tester.pump();

    expect(_top(tester, 'b'), lessThan(_top(tester, 'c')));
    expect(_top(tester, 'c'), lessThan(_top(tester, 'a')));
  });

  testWidgets('ListItem.options picks from a menu its value opens', (
    tester,
  ) async {
    final changes = <String?>[];

    await tester.pumpWidget(
      TestApp(
        overrides: [_viewSizeOverride],
        child: HostScaffold(
          body: ListItem<String?>.options(
            title: const Text('Language'),
            options: const [null, 'en'],
            value: 'en',
            textBuilder: (value) => value ?? 'Default',
            onChanged: changes.add,
          ),
        ),
      ),
    );

    expect(find.text('en'), findsOneWidget);
    expect(find.byGlyph(AppGlyphs.picker), findsOneWidget);

    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();

    expect(find.byType(PopupMenu), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(PopupMenu),
        matching: find.byGlyph(AppGlyphs.check),
      ),
      findsOneWidget,
    );

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.text('Default'), findsNothing);
    expect(changes, isEmpty);

    await tester.tap(find.text('en'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Default'));
    await tester.pumpAndSettle();

    expect(changes, [null]);
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

  testWidgets('InputDialog offers reset only while the text differs from it', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        overrides: [_viewSizeOverride],
        child: Builder(
          builder: (context) {
            return FilledButton(
              onPressed: () => showDialog<String>(
                context: context,
                builder: (_) => const InputDialog(
                  title: 'Value',
                  value: 'changed',
                  resetValue: 'default',
                ),
              ),
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Reset'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'default');
    await tester.pump();
    expect(find.text('Reset'), findsNothing);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'other');
    await tester.pump();
    expect(find.text('Reset'), findsOneWidget);
  });

  testWidgets('InputDialog grows with a long value instead of scrolling it', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        overrides: [_viewSizeOverride],
        child: Builder(
          builder: (context) {
            return FilledButton(
              onPressed: () => showDialog<String>(
                context: context,
                builder: (_) => const InputDialog(title: 'Value', value: ''),
              ),
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField),
      List.filled(6, 'https://a.example').join('/'),
    );
    await tester.pumpAndSettle();

    final scrollables = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(Scrollable),
    );
    expect(scrollables, findsWidgets);
    for (final element in scrollables.evaluate()) {
      final position = (element as StatefulElement).state as ScrollableState;
      expect(position.position.maxScrollExtent, 0);
    }
  });

  testWidgets('SecretTextFormField hides the text until revealed', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'AGE-SECRET-KEY-1A');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      TestApp(
        overrides: [_viewSizeOverride],
        child: Surface(
          child: SecretTextFormField(controller: controller, maxLines: 5),
        ),
      ),
    );

    EditableText editable() => tester.widget(find.byType(EditableText));
    expect(editable().obscureText, isTrue);
    expect(editable().maxLines, 1);

    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(editable().obscureText, isFalse);
    expect(editable().maxLines, 5);

    await tester.tap(find.byTooltip('Hide password'));
    await tester.pump();
    expect(editable().obscureText, isTrue);
    expect(controller.text, 'AGE-SECRET-KEY-1A');
  });

  testWidgets('EntryDialog returns a scalar value', (tester) async {
    Object? result;

    await tester.pumpWidget(
      TestApp(
        overrides: [_viewSizeOverride],
        child: Builder(
          builder: (context) {
            return FilledButton(
              onPressed: () async {
                result = await showDialog<String>(
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
    expect(result, 'valu');
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
            itemMaxLength: 4,
          ),
        ),
      ),
    );

    await _openAddMenuItem(tester, 'Add');
    await tester.enterText(find.byType(TextFormField), 'c');
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(find.text('c'), findsOneWidget);

    await _openAddMenuItem(tester, 'Add');
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
    expect(find.text('x'), findsOneWidget);

    await tester.tap(find.text('c').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'd');
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(find.text('d'), findsOneWidget);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();
    expect(find.byGlyph(AppGlyphs.delete), findsOneWidget);
    await tester.tap(find.byTooltip('Select all'));
    await tester.pump();
    await tester.tap(find.byGlyph(AppGlyphs.delete));
    await tester.pumpAndSettle();
    expect(find.text('No data'), findsNothing);
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(find.text('No data'), findsOneWidget);
  });

  Future<Object? Function()> openListEditView(WidgetTester tester) async {
    Object? result;
    await tester.pumpWidget(
      ProviderScope(
        child: TestApp(
          overrides: [_viewSizeOverride],
          child: HostScaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  result = await Navigator.of(context).push<Object?>(
                    CardPageRoute<Object?>(
                      builder: (_) => const ListEditView(
                        title: 'Items',
                        items: ['a', 'b'],
                        titleBuilder: _textBuilder,
                      ),
                    ),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Save'), findsNothing);
    await _openAddMenuItem(tester, 'Add');
    await tester.enterText(find.byType(TextFormField), 'c');
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    return () => result;
  }

  testWidgets('ListEditView hands its items back once saved', (tester) async {
    final result = await openListEditView(tester);

    await tester.tap(find.byTooltip('Save'));
    await tester.pumpAndSettle();

    expect(find.text('open'), findsOneWidget);
    expect(result(), ['a', 'b', 'c']);
  });

  testWidgets('ListEditView asks before dropping unsaved items', (
    tester,
  ) async {
    final result = await openListEditView(tester);

    await tester.timedDrag(
      find.text('a'),
      const Offset(800, 0),
      const Duration(seconds: 1),
    );
    await tester.pumpAndSettle();
    expect(find.text('open'), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Save the changes?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('open'), findsOneWidget);
    expect(result(), isNull);
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
            keyMaxLength: 4,
            valueMaxLength: 4,
          ),
        ),
      ),
    );

    final listView = tester.widget<PrismReorderableListView>(
      find.byType(PrismReorderableListView),
    );
    listView.onReorderItem(0, 1);
    await tester.pump();
    expect(
      tester.getTopLeft(find.text('b').first).dy,
      lessThan(tester.getTopLeft(find.text('a').first).dy),
    );

    await _openAddMenuItem(tester, 'Add');
    final fields = find.byType(TextFormField);
    await tester.tap(find.byTooltip('Confirm'));
    await tester.pumpAndSettle();
    expect(find.text('Key cannot be empty'), findsOneWidget);
    await tester.enterText(fields.first, 'a');
    await tester.pumpAndSettle();
    expect(find.text('Key already exists'), findsOneWidget);
    await tester.enterText(fields.first, 'ccccc');
    await tester.enterText(fields.last, '33333');
    await tester.tap(find.byTooltip('Confirm'));
    await tester.pumpAndSettle();
    expect(find.text('cccc'), findsOneWidget);
    expect(find.text('3333'), findsOneWidget);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();
    await tester.tap(find.byTooltip('Select all'));
    await tester.pump();
    await tester.tap(find.byGlyph(AppGlyphs.delete));
    await tester.pumpAndSettle();
    expect(find.text('No data'), findsNothing);
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(find.text('No data'), findsOneWidget);
  });

  testWidgets('ListEditView quick edit replaces items line by line', (
    tester,
  ) async {
    _setViewport(tester);
    await tester.pumpWidget(
      ProviderScope(
        child: TestApp(
          overrides: [_viewSizeOverride],
          child: const ListEditView(
            title: 'Items',
            items: ['a', 'b'],
            titleBuilder: _textBuilder,
            itemMaxLength: 4,
          ),
        ),
      ),
    );

    final (:editor, :context) = await _openQuickEdit(tester);
    expect(editor.content, 'a\nb');
    final refused = editor.onPop!(
      context,
      editor.title,
      const EditorContent.text('toolong\nx'),
    );
    await tester.pump();
    await tester.pump();
    expect(
      find.textContaining('Line 1: Value must be at most 4 characters'),
      findsOneWidget,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pump();
    expect(await refused, isFalse);

    expect(
      await editor.onPop!(
        context,
        editor.title,
        const EditorContent.text('- b\nx, y\nx'),
      ),
      isTrue,
    );
    Navigator.of(context).pop();
    await tester.pumpAndSettle();
    expect(find.text('a'), findsNothing);
    expect(_top(tester, 'b'), lessThan(_top(tester, 'x')));
    expect(_top(tester, 'x'), lessThan(_top(tester, 'y')));
    await _unmount(tester);
  });

  testWidgets('MapEditView quick edit writes key: value lines back', (
    tester,
  ) async {
    _setViewport(tester);
    await tester.pumpWidget(
      ProviderScope(
        child: TestApp(
          overrides: [_viewSizeOverride],
          child: const MapEditView(
            title: 'Map',
            entries: {'a': '1'},
            titleBuilder: _entryTitle,
            subtitleBuilder: _entrySubtitle,
          ),
        ),
      ),
    );

    final (:editor, :context) = await _openQuickEdit(tester);
    expect(editor.content, 'a: 1');
    final refused = editor.onPop!(
      context,
      editor.title,
      const EditorContent.text('a: 1\nd'),
    );
    await tester.pump();
    await tester.pump();
    expect(
      find.textContaining('Line 2: Value cannot be empty'),
      findsOneWidget,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pump();
    expect(await refused, isFalse);

    expect(
      await editor.onPop!(
        context,
        editor.title,
        const EditorContent.text('geosite:cn: tls://1.1.1.1:853\na: 9'),
      ),
      isTrue,
    );
    Navigator.of(context).pop();
    await tester.pumpAndSettle();
    expect(find.text('geosite:cn'), findsOneWidget);
    expect(find.text('tls://1.1.1.1:853'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(find.text('1'), findsNothing);
    await _unmount(tester);
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
    border.paintInterior(
      canvas,
      rect,
      Paint()..color = const Color(0xFFF44336),
    );
    border.paint(canvas, rect);
    recorder.endRecording();
  });
}

String _scalarEntry(String value) => value;

Widget _textBuilder(String value) {
  return Text(value);
}

Widget _entryTitle(MapEntry<String, String> value) => Text(value.key);

Widget _entrySubtitle(MapEntry<String, String> value) => Text(value.value);

Future<void> _openAddMenuItem(WidgetTester tester, String label) async {
  await tester.tap(find.byTooltip('Add'));
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(of: find.byType(PopupMenu), matching: find.text(label)),
  );
  await tester.pumpAndSettle();
}

Future<({EditorPage editor, BuildContext context})> _openQuickEdit(
  WidgetTester tester,
) async {
  await _openAddMenuItem(tester, 'Quick edit');
  return (
    editor: tester.widget<EditorPage>(find.byType(EditorPage)),
    context: tester.element(find.byType(EditorPage)),
  );
}

/// The editor's loading indicator schedules its next morph past unmount.
Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
}

void _setViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1400, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

double _top(WidgetTester tester, String text) {
  return tester.getTopLeft(find.text(text)).dy;
}
