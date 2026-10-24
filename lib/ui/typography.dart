import 'package:material_ui/material_ui.dart';

/// Apple's iOS Dynamic Type scale at its default size, a dp per point, with
/// two steps it lacks: [display] for a dashboard figure, [pageTitle] for an app
/// bar.
enum AppTextStyle {
  display(40, 44, emphasizedWeight: FontWeight.w700),
  largeTitle(34, 41, emphasizedWeight: FontWeight.w700),
  title1(28, 34, emphasizedWeight: FontWeight.w700),
  pageTitle(24, 30, weight: FontWeight.w600, emphasizedWeight: FontWeight.w700),
  title2(22, 28, emphasizedWeight: FontWeight.w700),
  title3(20, 25),
  headline(17, 22, weight: FontWeight.w600),
  body(17, 22),
  callout(16, 21),
  subheadline(15, 20),
  footnote(13, 18),
  caption1(12, 16),
  caption2(11, 13);

  const AppTextStyle(
    this.size,
    this.leading, {
    this.weight = FontWeight.w400,
    this.emphasizedWeight = FontWeight.w600,
  });

  final double size;
  final double leading;
  final FontWeight weight;
  final FontWeight emphasizedWeight;

  TextStyle of(BuildContext context, {bool emphasized = false}) {
    final theme = Theme.of(context);
    return _apply(
      _slotOf(theme.textTheme)!,
      _weightAdjustmentOf(theme),
      emphasized: emphasized,
    );
  }

  /// For text sized to the shape it marks, such as a letter in an icon.
  static TextStyle custom(
    BuildContext context, {
    required double size,
    required double leading,
    FontWeight weight = FontWeight.w400,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final base = size < title3.size
        ? textTheme.bodyLarge
        : textTheme.titleLarge;
    final exact = _exactWeight(weight, size, _weightAdjustmentOf(theme));
    return base!.copyWith(
      fontSize: size,
      height: leading / size,
      fontWeight: _weightOf(exact),
      fontVariations: _variationsOf(exact),
      letterSpacing: 0,
    );
  }

  // Typography.blackCupertino draws these slots with SF Pro Display and the
  // rest with SF Pro Text, which Apple switches between at 20 pt.
  TextStyle? _slotOf(TextTheme theme) => switch (this) {
    display || largeTitle => theme.headlineLarge,
    title1 => theme.headlineMedium,
    pageTitle || title2 => theme.headlineSmall,
    title3 => theme.titleLarge,
    headline => theme.titleMedium,
    body || callout => theme.bodyLarge,
    subheadline => theme.bodyMedium,
    footnote => theme.bodySmall,
    caption1 => theme.labelMedium,
    caption2 => theme.labelSmall,
  };

  TextStyle _apply(TextStyle base, int adjustment, {bool emphasized = false}) {
    final exact = _exactWeight(
      emphasized ? emphasizedWeight : weight,
      size,
      adjustment,
    );
    return base.copyWith(
      fontSize: size,
      height: leading / size,
      fontWeight: _weightOf(exact),
      fontVariations: _variationsOf(exact),
      letterSpacing: 0,
    );
  }

  TextStyle? _on(TextStyle? base, int adjustment, {bool emphasized = false}) =>
      base == null ? null : _apply(base, adjustment, emphasized: emphasized);
}

/// The font weight slider's offset for this app, carried on the theme so every
/// [AppTextStyle] can move its nominal weight by it.
class FontWeightAdjustment extends ThemeExtension<FontWeightAdjustment> {
  const FontWeightAdjustment(this.adjustment);

  final int adjustment;

  @override
  FontWeightAdjustment copyWith({int? adjustment}) =>
      FontWeightAdjustment(adjustment ?? this.adjustment);

  // A weight is a step, not a dial: a crossfade keeps the old one until the
  // midpoint rather than blending a hundredth of a step.
  @override
  FontWeightAdjustment lerp(FontWeightAdjustment? other, double t) =>
      other == null || t < 0.5 ? this : other;
}

extension AppTypographyThemeExt on ThemeData {
  /// Rebuilds the text theme at [adjustment], replacing any earlier offset so
  /// applying it twice cannot stack two steps.
  ThemeData withAppTypography({int adjustment = 0}) => copyWith(
    textTheme: _onAppScale(textTheme, adjustment),
    primaryTextTheme: _onAppScale(primaryTextTheme, adjustment),
    // Extensions are keyed by type, so a second pass replaces the first.
    extensions: [...extensions.values, FontWeightAdjustment(adjustment)],
  );
}

TextTheme _onAppScale(TextTheme theme, int adjustment) => theme.copyWith(
  displayLarge: AppTextStyle.largeTitle._on(theme.displayLarge, adjustment),
  displayMedium: AppTextStyle.largeTitle._on(theme.displayMedium, adjustment),
  displaySmall: AppTextStyle.largeTitle._on(theme.displaySmall, adjustment),
  headlineLarge: AppTextStyle.largeTitle._on(theme.headlineLarge, adjustment),
  headlineMedium: AppTextStyle.title1._on(theme.headlineMedium, adjustment),
  headlineSmall: AppTextStyle.title2._on(theme.headlineSmall, adjustment),
  titleLarge: AppTextStyle.title3._on(theme.titleLarge, adjustment),
  titleMedium: AppTextStyle.headline._on(theme.titleMedium, adjustment),
  titleSmall: AppTextStyle.subheadline._on(
    theme.titleSmall,
    adjustment,
    emphasized: true,
  ),
  bodyLarge: AppTextStyle.body._on(theme.bodyLarge, adjustment),
  bodyMedium: AppTextStyle.subheadline._on(theme.bodyMedium, adjustment),
  bodySmall: AppTextStyle.footnote._on(theme.bodySmall, adjustment),
  labelLarge: AppTextStyle.subheadline._on(
    theme.labelLarge,
    adjustment,
    emphasized: true,
  ),
  labelMedium: AppTextStyle.caption1._on(
    theme.labelMedium,
    adjustment,
    emphasized: true,
  ),
  labelSmall: AppTextStyle.caption2._on(
    theme.labelSmall,
    adjustment,
    emphasized: true,
  ),
);

int _weightAdjustmentOf(ThemeData theme) =>
    theme.extension<FontWeightAdjustment>()?.adjustment ?? 0;

/// The weight body text lands on at the slider's default, so the setting reads
/// as "where body text sits" rather than as an abstract offset.
const baseFontWeight = 400;

/// The slider reaches every weight a font can carry, a quarter of a step at a
/// time, so a variable font shows each landing instead of nine of them.
const maxFontWeightAdjustment = 500;
const minFontWeightAdjustment = -300;
const fontWeightAdjustmentStep = 25;

/// The weight a font actually asked for, kept finer than [FontWeight] so a
/// variable font can render the in-between value.
double _exactWeight(FontWeight nominal, double size, int adjustment) {
  final factor = size >= AppTextStyle.title1.size
      ? 1.0
      : (size >= AppTextStyle.footnote.size ? 0.75 : 0.5);
  return (nominal.value + adjustment * factor).clamp(
    FontWeight.w100.value.toDouble(),
    FontWeight.w900.value.toDouble(),
  );
}

/// A static family can only snap to the nearest of its nine faces.
FontWeight _weightOf(double exact) {
  final snapped = ((exact / 100).round() * 100).clamp(
    FontWeight.w100.value,
    FontWeight.w900.value,
  );
  return FontWeight.values[(snapped - FontWeight.w100.value) ~/ 100];
}

List<FontVariation> _variationsOf(double exact) => [
  FontVariation('wght', exact),
];
