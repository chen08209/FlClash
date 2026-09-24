import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/theme.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/widget_metrics.dart';
import 'package:fl_clash/views/dashboard/widgets/outbound_mode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_color_utilities/hct/hct.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/glyph_finders.dart';
import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    globalState.container = container;
  });

  tearDown(() => container.dispose());

  Future<void> pumpCard(
    WidgetTester tester, {
    required double width,
    required double unitHeight,
    double textScale = 1.0,
  }) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: width,
                child: MediaQuery.withClampedTextScaling(
                  minScaleFactor: textScale,
                  maxScaleFactor: textScale,
                  child: Builder(
                    builder: (context) {
                      globalState.measure = Measure.of(context, textScale);
                      globalState.theme = CommonTheme.of(context, textScale);
                      return DashboardWidgetMetrics(
                        unitHeight: unitHeight,
                        child: const OutboundMode(),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  final highlight = find.byKey(const ValueKey('outbound-mode-highlight'));

  Finder rowOf(Mode mode) {
    return find
        .ancestor(of: find.text(mode.label), matching: find.byType(InkWell))
        .first;
  }

  Color highlightColor() {
    final box = find.descendant(
      of: highlight,
      matching: find.byType(DecoratedBox),
    );
    final decoration =
        (box.evaluate().first.widget as DecoratedBox).decoration
            as ShapeDecoration;
    return decoration.color!;
  }

  testWidgets('the phone-height card lists every mode on one line each', (
    tester,
  ) async {
    await pumpCard(tester, width: 280, unitHeight: 80);

    for (final mode in Mode.values) {
      expect(find.text(mode.label), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  for (final unitHeight in [60.0, 80.0, 120.0]) {
    testWidgets('a ${unitHeight.toInt()}-high card gives every mode the '
        'same height and spacing', (tester) async {
      await pumpCard(tester, width: 280, unitHeight: unitHeight);

      final rule = tester.getRect(rowOf(Mode.rule));
      final global = tester.getRect(rowOf(Mode.global));
      final direct = tester.getRect(rowOf(Mode.direct));
      expect(rule.height, closeTo(global.height, 0.01));
      expect(global.height, closeTo(direct.height, 0.01));
      expect(global.top - rule.bottom, greaterThanOrEqualTo(0));
      expect(
        direct.top - global.bottom,
        closeTo(global.top - rule.bottom, 0.01),
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('each mode shows its own glyph on the header icon column', (
    tester,
  ) async {
    await pumpCard(tester, width: 280, unitHeight: 80);

    final headerGlyph = find.byGlyph(AppGlyphs.split);
    final glyphs = {
      Mode.rule: AppGlyphs.rules,
      Mode.global: AppGlyphs.language,
      Mode.direct: AppGlyphs.target,
    };
    for (final MapEntry(key: mode, value: glyph) in glyphs.entries) {
      final icon = find.descendant(
        of: rowOf(mode),
        matching: find.byGlyph(glyph),
      );
      expect(icon, findsOneWidget);
      expect(
        tester.getCenter(icon).dx,
        closeTo(tester.getCenter(headerGlyph).dx, 0.01),
      );
      expect(
        tester.getTopLeft(find.text(mode.label)).dx,
        closeTo(tester.getTopLeft(find.text('Outbound mode')).dx, 0.01),
      );
    }
  });

  ShapeBorder highlightShape(WidgetTester tester) {
    final box = tester.widget<DecoratedBox>(
      find.descendant(of: highlight, matching: find.byType(DecoratedBox)),
    );
    return (box.decoration as ShapeDecoration).shape;
  }

  for (final (unitHeight, textScale) in [
    (60.0, 1.0),
    (80.0, 1.0),
    (120.0, 1.0),
    (80.0, 1.4),
    (120.0, 1.4),
  ]) {
    testWidgets('at ${unitHeight.toInt()} high and x$textScale text the '
        'highlight sits concentric in the card corners up to a third of '
        'its height', (tester) async {
      await pumpCard(
        tester,
        width: 280,
        unitHeight: unitHeight,
        textScale: textScale,
      );
      await tester.tap(rowOf(Mode.direct));
      await tester.pumpAndSettle();

      final card = tester.getRect(find.byType(OutboundMode));
      final box = tester.getRect(highlight);
      final side = box.left - card.left;
      expect(side, greaterThan(1));
      expect(card.right - box.right, closeTo(side, 0.01));
      expect(card.bottom - box.bottom, closeTo(side, 0.01));

      final outer = DashboardWidgetMetrics.radiusOf(tester.element(highlight));
      final shape = highlightShape(tester) as RoundedSuperellipseBorder;
      final inner = (shape.borderRadius as BorderRadius).bottomLeft.x;
      expect(inner, closeTo(min(outer - side, box.height / 3), 0.01));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('selecting a row slides the highlight across the rows', (
    tester,
  ) async {
    await pumpCard(tester, width: 280, unitHeight: 80);
    final from = tester.getRect(highlight);
    final rows = {
      for (final mode in Mode.values) mode: tester.getRect(rowOf(mode)),
    };

    await tester.tap(rowOf(Mode.direct));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    expect(container.read(patchClashConfigProvider).mode, Mode.direct);
    final midway = tester.getRect(highlight);
    expect(midway.height, closeTo(from.height, 0.01));
    expect(midway.top, greaterThan(from.top));

    await tester.pumpAndSettle();
    final to = tester.getRect(highlight);
    expect(midway.top, lessThan(to.top));
    expect(to, tester.getRect(rowOf(Mode.direct)));
    for (final mode in Mode.values) {
      expect(tester.getRect(rowOf(mode)), rows[mode]);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'global warns and direct reads as safe, each in a container tone',
    (tester) async {
      await pumpCard(tester, width: 280, unitHeight: 80);
      final colorScheme = Theme.of(
        tester.element(find.byType(OutboundMode)),
      ).colorScheme;
      final colors = <Mode, Color>{};
      for (final mode in Mode.values) {
        await tester.tap(rowOf(mode));
        await tester.pumpAndSettle();
        colors[mode] = highlightColor();
      }

      expect(colors[Mode.rule], colorScheme.secondaryContainer);
      double hueOf(Color color) => Hct.fromInt(color.toARGB32()).hue;
      double hueGap(double a, double b) {
        final d = (a - b).abs() % 360;
        return d > 180 ? 360 - d : d;
      }

      expect(
        hueGap(hueOf(colors[Mode.global]!), hueOf(colorScheme.warning)),
        lessThan(10),
      );
      expect(
        hueGap(hueOf(colors[Mode.direct]!), hueOf(colorScheme.success)),
        lessThan(10),
      );
      expect(colors.values.toSet(), hasLength(Mode.values.length));
    },
  );
}
