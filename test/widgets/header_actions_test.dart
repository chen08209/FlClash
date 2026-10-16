import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

void _noop() {}

const _width = 520.0;

List<Widget> _actions() => const [
  CommonMinIconButtonTheme(
    child: IconButton.filledTonal(
      tooltip: 'Delete',
      onPressed: _noop,
      icon: GlyphIcon(AppGlyphs.delete, fill: 1),
    ),
  ),
  CommonMinIconButtonTheme(
    child: IconButton.filledTonal(
      tooltip: 'Select all',
      onPressed: _noop,
      icon: GlyphIcon(AppGlyphs.selectAll),
    ),
  ),
];

const _data = [
  IconButtonData(glyph: AppGlyphs.delete, tooltip: 'Delete', onPressed: _noop),
  IconButtonData(
    glyph: AppGlyphs.selectAll,
    tooltip: 'Select all',
    onPressed: _noop,
  ),
];

Future<void> _pumpHeader(WidgetTester tester, Widget header) async {
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
}

void main() {
  testWidgets('both headers end their actions at the same inset', (
    tester,
  ) async {
    await _pumpHeader(
      tester,
      const ListHeader(title: 'Exclude SSIDs', actions: _data),
    );
    final list = tester.getRect(find.byTooltip('Select all'));
    await _pumpHeader(
      tester,
      InfoHeader(
        info: const Info(label: 'Added rules'),
        actions: _actions(),
      ),
    );
    final info = tester.getRect(find.byTooltip('Select all'));

    expect(_width - list.right, _width - info.right);
  });

  testWidgets('a header spaces its actions like an app bar', (tester) async {
    await _pumpHeader(
      tester,
      InfoHeader(
        info: const Info(label: 'Added rules'),
        actions: _actions(),
      ),
    );
    final first = tester.getRect(find.byTooltip('Delete'));
    final second = tester.getRect(find.byTooltip('Select all'));

    expect(second.left - first.right, appBarActionSpace);
  });

  testWidgets('a list header stands as tall with actions as without', (
    tester,
  ) async {
    await _pumpHeader(tester, const ListHeader(title: 'Rules'));
    final bare = tester.getRect(find.text('Rules'));
    final bareHeader = tester.getSize(find.byType(ListHeader));
    await _pumpHeader(tester, const ListHeader(title: 'Rules', actions: _data));
    final withActions = tester.getRect(find.text('Rules'));
    final button = tester.getRect(find.byTooltip('Select all'));

    expect(withActions.topLeft, bare.topLeft);
    expect(tester.getSize(find.byType(ListHeader)).height, bareHeader.height);
    expect(button.height, TonalButtonSize.section.button);
    expect(button.center.dy, closeTo(withActions.center.dy, 1));
    expect(
      tester.getBottomLeft(find.byType(ListHeader)).dy - button.bottom,
      greaterThanOrEqualTo(6),
    );
  });
}
