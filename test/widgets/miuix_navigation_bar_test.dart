import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/widgets/miuix_navigation_bar.dart';
import 'package:fl_clash/widgets/navigation_dock.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

const _labels = ['Dashboard', 'Proxies', 'Tools'];

Future<void> _pumpBar(
  WidgetTester tester, {
  int selectedIndex = 0,
  ValueChanged<int>? onSelected,
  Color? color,
}) async {
  tester.view.physicalSize = const Size(400, 800);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(bottom: 20);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    TestApp(
      child: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: MiuixNavigationBar(
            destinations: [
              for (final label in _labels)
                NavigationDockDestination(glyph: AppGlyphs.tools, label: label),
            ],
            selectedIndex: selectedIndex,
            onSelected: onSelected ?? (_) {},
            color: color,
          ),
        ),
      ),
    ),
  );
}

GlyphIcon _glyph(WidgetTester tester, String label) {
  return tester.widget<GlyphIcon>(
    find.descendant(
      of: find.bySemanticsLabel(label),
      matching: find.byType(GlyphIcon),
    ),
  );
}

Text _label(WidgetTester tester, String label) =>
    tester.widget<Text>(find.text(label));

void main() {
  testWidgets('the bar sits on the surface under a hairline', (tester) async {
    await _pumpBar(tester);
    final colorScheme = ThemeData().colorScheme;
    final bar = find.byType(MiuixNavigationBar);

    expect(tester.getSize(bar).height, 0.75 + 64 + 20);
    expect(
      MiuixNavigationBar.heightOf(tester.element(bar)),
      tester.getSize(bar).height,
    );
    expect(tester.getRect(bar).bottom, 800);
    final divider = tester.widget<Divider>(find.byType(Divider));
    expect(divider.thickness, 0.75);
    expect(divider.color, colorScheme.outlineVariant);
    expect(
      tester
          .widget<ColoredBox>(
            find.descendant(of: bar, matching: find.byType(ColoredBox)).first,
          )
          .color,
      colorScheme.surface,
    );
    for (final label in _labels) {
      expect(tester.getSize(find.bySemanticsLabel(label)).height, 64);
      expect(_glyph(tester, label).size, 26);
      expect(_label(tester, label).style!.fontSize, 12);
    }
  });

  testWidgets('only the selection is bold and at full strength', (
    tester,
  ) async {
    await _pumpBar(tester, selectedIndex: 1);
    final onSurface = ThemeData().colorScheme.onSurface;

    expect(_glyph(tester, 'Proxies').color, onSurface);
    expect(_label(tester, 'Proxies').style!.fontWeight, FontWeight.w700);
    expect(
      _glyph(tester, 'Tools').color,
      onSurface.withValues(alpha: onSurface.a * 0.4),
    );
    expect(_label(tester, 'Tools').style!.fontWeight, FontWeight.w400);
    expect(
      find.descendant(
        of: find.byType(MiuixNavigationBar),
        matching: find.byType(InkWell),
      ),
      findsNothing,
    );

    final press = await tester.startGesture(
      tester.getCenter(find.text('Tools')),
    );
    await tester.pump();
    expect(
      _glyph(tester, 'Tools').color,
      onSurface.withValues(alpha: onSurface.a * 0.6),
    );
    await press.cancel();
    await tester.pump();

    final pressSelected = await tester.startGesture(
      tester.getCenter(find.text('Proxies')),
    );
    await tester.pump();
    expect(
      _glyph(tester, 'Proxies').color,
      onSurface.withValues(alpha: onSurface.a * 0.5),
    );
    await pressSelected.up();
    await tester.pump();
    expect(_glyph(tester, 'Proxies').color, onSurface);
  });

  testWidgets('destinations are buttons that tell their selection', (
    tester,
  ) async {
    final selected = <int>[];
    await _pumpBar(tester, onSelected: selected.add);

    expect(
      tester.getSemantics(find.bySemanticsLabel('Dashboard')),
      isSemantics(isButton: true, isSelected: true, hasTapAction: true),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Tools')),
      isSemantics(isButton: true, isSelected: false, hasTapAction: true),
    );

    await tester.tap(find.text('Tools'));
    expect(selected, [2]);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(selected, [2, 1]);
  });

  testWidgets('a given color replaces the surface', (tester) async {
    await _pumpBar(tester, color: Colors.transparent);

    expect(
      tester
          .widget<ColoredBox>(
            find
                .descendant(
                  of: find.byType(MiuixNavigationBar),
                  matching: find.byType(ColoredBox),
                )
                .first,
          )
          .color,
      Colors.transparent,
    );
  });
}
