import 'dart:ui' as ui;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/theme.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ListItem.toggle toggles when tapping the row', (tester) async {
    bool? changedValue;

    await tester.pumpWidget(
      _TestApp(
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
      _TestApp(
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

  testWidgets('ListItem.checkbox toggles when tapping the row', (tester) async {
    bool? changedValue;

    await tester.pumpWidget(
      _TestApp(
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
        child: _TestApp(
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

  testWidgets('ListInputPage reorders using final insertion index', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: _TestApp(
          child: ListInputPage(
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
      _TestApp(
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
      _TestApp(
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

  testWidgets('AddDialog returns scalar and map values', (tester) async {
    Object? result;

    await tester.pumpWidget(
      _TestApp(
        child: Builder(
          builder: (context) {
            return Column(
              children: [
                FilledButton(
                  onPressed: () async {
                    result = await showDialog<String>(
                      context: context,
                      builder: (_) => const AddDialog(
                        title: 'Scalar',
                        valueField: Field(label: 'Value', value: ''),
                        valueMaxLength: 4,
                      ),
                    );
                  },
                  child: const Text('Scalar'),
                ),
                FilledButton(
                  onPressed: () async {
                    result = await showDialog<MapEntry<String, String>>(
                      context: context,
                      builder: (_) => const AddDialog(
                        title: 'Pair',
                        keyField: Field(label: 'Key', value: ''),
                        valueField: Field(label: 'Value', value: ''),
                        keyMaxLength: 3,
                        valueMaxLength: 4,
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
    expect(find.byType(AddDialog), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'value');
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(result, 'valu');

    await tester.tap(find.text('Pair'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.first, 'key1');
    await tester.enterText(fields.last, 'value');
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect((result! as MapEntry<String, String>).key, 'key');
    expect((result! as MapEntry<String, String>).value, 'valu');
  });

  testWidgets('ListInputPage adds, edits, selects, and deletes items', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: _TestApp(
          child: ListInputPage(
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

    await tester.tap(find.text('c').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'd');
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(find.text('d'), findsNWidgets(3));

    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();
    expect(find.byIcon(Icons.delete), findsOneWidget);
    await tester.tap(find.text('Select all'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();
    expect(find.text('No data'), findsOneWidget);
  });

  testWidgets('MapInputPage adds, reorders, selects, and deletes entries', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: _TestApp(
          child: MapInputPage(
            title: 'Map',
            map: {'a': '1', 'b': '2'},
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
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();
    expect(find.text('No data'), findsOneWidget);
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

Widget _textBuilder(String value) {
  return Text(value);
}

Widget _entryTitle(MapEntry<String, String> value) => Text(value.key);

Widget _entrySubtitle(MapEntry<String, String> value) => Text(value.value);

double _top(WidgetTester tester, String text) {
  return tester.getTopLeft(find.text(text)).dy;
}

class _TestApp extends StatelessWidget {
  final Widget child;

  const _TestApp({required this.child});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        viewSizeProvider.overrideWithBuild((_, _) => const Size(1200, 1000)),
      ],
      child: MaterialApp(
        navigatorKey: globalState.navigatorKey,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.delegate.supportedLocales,
        builder: (context, child) {
          globalState.measure = Measure.of(context, 1);
          globalState.theme = CommonTheme.of(context, 1);
          return child!;
        },
        home: child,
      ),
    );
  }
}
