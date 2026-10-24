import 'package:fl_clash/ui/typography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('the font weight slider', () {
    test('leaves the scale alone when it sits at rest', () {
      final theme = ThemeData.light().withAppTypography();

      expect(theme.textTheme.bodyLarge?.fontWeight, FontWeight.w400);
      expect(theme.textTheme.displayLarge?.fontWeight, FontWeight.w400);
      expect(theme.textTheme.labelMedium?.fontWeight, FontWeight.w600);
      expect(theme.extension<FontWeightAdjustment>()?.adjustment, 0);
    });

    test('thickens body text but caps the heavy end', () {
      final theme = ThemeData.light().withAppTypography(
        adjustment: maxFontWeightAdjustment,
      );

      // Body lands on 775, which a static family can only draw as w800, while
      // large text has already reached the heaviest face there is.
      expect(theme.textTheme.bodyLarge?.fontWeight, FontWeight.w800);
      expect(theme.textTheme.displayLarge?.fontWeight, FontWeight.w900);
      expect(theme.textTheme.labelMedium?.fontWeight, FontWeight.w900);
    });

    test('thins the scale on a light slider', () {
      final theme = ThemeData.light().withAppTypography(
        adjustment: minFontWeightAdjustment,
      );

      expect(theme.textTheme.bodyLarge?.fontWeight, FontWeight.w200);
      expect(theme.textTheme.displayLarge?.fontWeight, FontWeight.w100);
    });

    test('carries the unrounded weight so a variable font can render it', () {
      final theme = ThemeData.light().withAppTypography(
        adjustment: fontWeightAdjustmentStep,
      );

      final body = theme.textTheme.bodyLarge!;

      expect(body.fontWeight, FontWeight.w400);
      expect(body.fontVariations?.single.axis, 'wght');
      expect(body.fontVariations?.single.value, closeTo(418.75, 0.01));
    });

    test('treats the slider as steps, so a short move changes nothing', () {
      final theme = ThemeData.light().withAppTypography(
        adjustment: fontWeightAdjustmentStep,
      );

      expect(theme.textTheme.bodyLarge?.fontWeight, FontWeight.w400);
    });

    test('keeps one adjustment on the theme however often it is applied', () {
      final theme = ThemeData.light()
          .withAppTypography(adjustment: 250)
          .withAppTypography(adjustment: 250);

      final adjustments = theme.extensions.values
          .whereType<FontWeightAdjustment>()
          .toList();

      expect(adjustments, hasLength(1));
      expect(adjustments.single.adjustment, 250);
    });

    test('reaches every heavy face between the two ends', () {
      FontWeight? bodyAt(int adjustment) => ThemeData.light()
          .withAppTypography(adjustment: adjustment)
          .textTheme
          .bodyLarge
          ?.fontWeight;

      expect(bodyAt(0), FontWeight.w400);
      expect(bodyAt(200), FontWeight.w600);
      expect(bodyAt(400), FontWeight.w700);
      expect(bodyAt(-150), FontWeight.w300);
    });
  });

  testWidgets('a text style reads the adjustment off the theme', (
    tester,
  ) async {
    final theme = ThemeData.light().withAppTypography(
      adjustment: maxFontWeightAdjustment,
    );
    late TextStyle body;
    late TextStyle custom;
    late TextStyle emphasized;

    await tester.pumpWidget(
      Theme(
        data: theme,
        child: Builder(
          builder: (context) {
            body = AppTextStyle.body.of(context);
            custom = AppTextStyle.custom(context, size: 14, leading: 19);
            emphasized = AppTextStyle.body.of(context, emphasized: true);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(body.fontWeight, FontWeight.w800);
    expect(custom.fontWeight, FontWeight.w800);
    expect(emphasized.fontWeight, FontWeight.w900);
  });
}
