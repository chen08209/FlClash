import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

final _viewSizeOverride = viewSizeProvider.overrideWithBuild(
  (_, _) => const Size(400, 800),
);

Future<void> _pumpDialog(
  WidgetTester tester,
  List<String> labels, {
  TextDirection textDirection = TextDirection.ltr,
  ValueChanged<String>? onPressed,
  bool destructive = false,
}) async {
  await tester.pumpWidget(
    TestApp(
      overrides: [_viewSizeOverride],
      child: Directionality(
        textDirection: textDirection,
        child: Scaffold(
          body: Center(
            child: CommonDialog(
              title: 'Title',
              destructive: destructive,
              actions: [
                for (final label in labels)
                  TextButton(
                    onPressed: () => onPressed?.call(label),
                    child: Text(label),
                  ),
              ],
              child: const Text('Body'),
            ),
          ),
        ),
      ),
    ),
  );
}

Rect _rectOf(WidgetTester tester, String label) =>
    tester.getRect(find.widgetWithText(TextButton, label));

Color? _labelColor(WidgetTester tester, String label) =>
    tester.renderObject<RenderParagraph>(find.text(label)).text.style?.color;

Color? _buttonFill(WidgetTester tester, String label) => tester
    .widget<Material>(
      find.descendant(
        of: find.widgetWithText(TextButton, label),
        matching: find.byType(Material),
      ),
    )
    .color;

Future<void> _pumpLauncher(WidgetTester tester) async {
  await tester.pumpWidget(
    TestApp(
      overrides: [_viewSizeOverride],
      child: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showFloatingDialog<void>(
              context: context,
              child: const CommonDialog(title: 'Title', child: Text('Body')),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
}

double _dialogScale(WidgetTester tester) => tester
    .widget<Transform>(
      find
          .ancestor(
            of: find.byType(CommonDialog),
            matching: find.byType(Transform),
          )
          .first,
    )
    .transform
    .entry(0, 0);

double _dialogOpacity(WidgetTester tester) => tester
    .widget<LiquidGlassFade>(
      find
          .ancestor(
            of: find.byType(CommonDialog),
            matching: find.byType(LiquidGlassFade),
          )
          .first,
    )
    .opacity
    .value;

void main() {
  testWidgets('two short actions share a row, the default one at the end', (
    tester,
  ) async {
    await _pumpDialog(tester, ['No', 'Yes']);

    final no = _rectOf(tester, 'No');
    final yes = _rectOf(tester, 'Yes');
    expect(no.top, yes.top);
    expect(no.width, yes.width);
    expect(no.right, lessThan(yes.left));
  });

  testWidgets('a destructive last action is red on the plain fill', (
    tester,
  ) async {
    await _pumpDialog(tester, ['Cancel', 'Delete'], destructive: true);
    final colorScheme = Theme.of(
      tester.element(find.text('Delete')),
    ).colorScheme;

    expect(_labelColor(tester, 'Delete'), colorScheme.destructive);
    expect(_labelColor(tester, 'Cancel'), colorScheme.onSurface);
    expect(_buttonFill(tester, 'Delete'), _buttonFill(tester, 'Cancel'));
    expect(_buttonFill(tester, 'Delete'), isNot(colorScheme.primary));
  });

  testWidgets('a row follows the reading direction', (tester) async {
    await _pumpDialog(tester, ['No', 'Yes'], textDirection: TextDirection.rtl);

    expect(_rectOf(tester, 'Yes').right, lessThan(_rectOf(tester, 'No').left));
  });

  testWidgets('a label too long for half the width stacks the default on top', (
    tester,
  ) async {
    await _pumpDialog(tester, ['No', 'A label far too long to share a row']);

    final no = _rectOf(tester, 'No');
    final long = _rectOf(tester, 'A label far too long to share a row');
    expect(long.bottom, lessThan(no.top));
    expect(long.width, no.width);
  });

  testWidgets('three actions stack in order with the first at the bottom', (
    tester,
  ) async {
    final pressed = <String>[];
    await _pumpDialog(tester, ['No', 'Remove', 'Yes'], onPressed: pressed.add);

    final no = _rectOf(tester, 'No');
    final remove = _rectOf(tester, 'Remove');
    final yes = _rectOf(tester, 'Yes');
    expect(remove.bottom, lessThan(yes.top));
    expect(yes.bottom, lessThan(no.top));

    for (final label in ['No', 'Remove', 'Yes']) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }
    expect(pressed, ['No', 'Remove', 'Yes']);
  });

  testWidgets('a dialog grows in as it fades in and only fades out', (
    tester,
  ) async {
    await _pumpLauncher(tester);

    await tester.tap(find.text('Open'));
    await tester.pump();
    expect(_dialogScale(tester), closeTo(1.2, 0.001));
    expect(_dialogOpacity(tester), 0);

    await tester.pump(const Duration(milliseconds: 100));
    expect(_dialogScale(tester), inExclusiveRange(1, 1.2));
    expect(_dialogOpacity(tester), inExclusiveRange(0, 1));

    await tester.pumpAndSettle();
    expect(_dialogScale(tester), 1);
    expect(_dialogOpacity(tester), 1);

    Navigator.of(tester.element(find.byType(CommonDialog))).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(_dialogScale(tester), 1);
    expect(_dialogOpacity(tester), inExclusiveRange(0, 1));

    await tester.pumpAndSettle();
    expect(find.byType(CommonDialog), findsNothing);
  });

  testWidgets('on glass a pane lies under the surface and fades with it', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (_, child) => LiquidGlassScope(
          enabled: true,
          child: LiquidGlassHost(enabled: true, child: child!),
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showFloatingDialog<void>(
                context: context,
                child: const CommonDialog(title: 'Title', child: Text('Body')),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(_dialogOpacity(tester), inExclusiveRange(0, 1));
    expect(LiquidGlassHost.debugLastCapture!.panes, hasLength(1));

    await tester.pumpAndSettle();
    final surface = find
        .descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(Material),
        )
        .first;
    expect(
      LiquidGlassHost.debugLastCapture!.panes.single.pane,
      rectMoreOrLessEquals(tester.getRect(surface)),
    );
  });

  testWidgets('a tap on the scrim dismisses a dismissible dialog', (
    tester,
  ) async {
    await _pumpLauncher(tester);
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();
    expect(find.byType(CommonDialog), findsNothing);
  });
}
