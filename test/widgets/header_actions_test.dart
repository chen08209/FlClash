import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/theme.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

void _noop() {}

const _width = 520.0;

List<Widget> _actions() => const [
  CommonMinIconButtonTheme(
    child: IconButton.filledTonal(
      onPressed: _noop,
      icon: GlyphIcon(AppGlyphs.delete, fill: 1),
    ),
  ),
  CommonMinFilledButtonTheme(
    child: FilledButton(onPressed: _noop, child: Text('Select all')),
  ),
];

Future<Rect> _pumpHeader(WidgetTester tester, Widget header) async {
  tester.view.physicalSize = const Size(_width, 200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    TestApp(
      child: Builder(
        builder: (context) {
          globalState.measure = Measure.of(context, 1);
          return Material(child: header);
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return tester.getRect(find.byType(FilledButton));
}

void main() {
  testWidgets('both headers end their actions at the same inset', (
    tester,
  ) async {
    final list = await _pumpHeader(
      tester,
      ListHeader(title: 'Exclude SSIDs', actions: _actions()),
    );
    final info = await _pumpHeader(
      tester,
      InfoHeader(
        info: const Info(label: 'Added rules'),
        actions: _actions(),
      ),
    );

    expect(_width - list.right, _width - info.right);
  });

  testWidgets('a card header ends where a plain one does', (tester) async {
    final info = await _pumpHeader(
      tester,
      InfoHeader(
        info: const Info(label: 'Theme color'),
        actions: _actions(),
      ),
    );
    final card = await _pumpHeader(
      tester,
      ItemCard(
        info: const Info(label: 'Theme color'),
        actions: _actions(),
        space: 8,
        child: const SizedBox(),
      ),
    );

    expect(_width - card.right, _width - info.right);
  });

  testWidgets('a header spaces its actions like an app bar', (tester) async {
    await _pumpHeader(
      tester,
      InfoHeader(
        info: const Info(label: 'Added rules'),
        actions: _actions(),
      ),
    );
    final icon = tester.getRect(
      find.widgetWithGlyph(IconButton, AppGlyphs.delete),
    );
    final pill = tester.getRect(find.byType(FilledButton));

    expect(pill.left - icon.right, appBarActionSpace);
  });
}
