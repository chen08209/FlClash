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

  TextStyle of(BuildContext context, {bool emphasized = false}) =>
      _apply(_slotOf(Theme.of(context).textTheme)!, emphasized: emphasized);

  /// For text sized to the shape it marks, such as a letter in an icon.
  static TextStyle custom(
    BuildContext context, {
    required double size,
    required double leading,
    FontWeight weight = FontWeight.w400,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final base = size < title3.size
        ? textTheme.bodyLarge
        : textTheme.titleLarge;
    return base!.copyWith(
      fontSize: size,
      height: leading / size,
      fontWeight: weight,
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

  TextStyle _apply(TextStyle base, {required bool emphasized}) => base.copyWith(
    fontSize: size,
    height: leading / size,
    fontWeight: emphasized ? emphasizedWeight : weight,
    letterSpacing: 0,
  );

  TextStyle? _on(TextStyle? base, {bool emphasized = false}) =>
      base == null ? null : _apply(base, emphasized: emphasized);
}

extension AppTypographyThemeExt on ThemeData {
  ThemeData get withAppTypography => copyWith(
    textTheme: _onAppScale(textTheme),
    primaryTextTheme: _onAppScale(primaryTextTheme),
  );
}

TextTheme _onAppScale(TextTheme theme) => theme.copyWith(
  displayLarge: AppTextStyle.largeTitle._on(theme.displayLarge),
  displayMedium: AppTextStyle.largeTitle._on(theme.displayMedium),
  displaySmall: AppTextStyle.largeTitle._on(theme.displaySmall),
  headlineLarge: AppTextStyle.largeTitle._on(theme.headlineLarge),
  headlineMedium: AppTextStyle.title1._on(theme.headlineMedium),
  headlineSmall: AppTextStyle.title2._on(theme.headlineSmall),
  titleLarge: AppTextStyle.title3._on(theme.titleLarge),
  titleMedium: AppTextStyle.headline._on(theme.titleMedium),
  titleSmall: AppTextStyle.subheadline._on(theme.titleSmall, emphasized: true),
  bodyLarge: AppTextStyle.body._on(theme.bodyLarge),
  bodyMedium: AppTextStyle.subheadline._on(theme.bodyMedium),
  bodySmall: AppTextStyle.footnote._on(theme.bodySmall),
  labelLarge: AppTextStyle.subheadline._on(theme.labelLarge, emphasized: true),
  labelMedium: AppTextStyle.caption1._on(theme.labelMedium, emphasized: true),
  labelSmall: AppTextStyle.caption2._on(theme.labelSmall, emphasized: true),
);
