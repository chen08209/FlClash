import 'dart:math';

import 'package:flutter/foundation.dart' show clampDouble;
import 'package:material_color_utilities/material_color_utilities.dart'
    show
        DynamicColor,
        DynamicScheme,
        Hct,
        MaterialDynamicColors,
        SchemeContent,
        SchemeExpressive,
        SchemeFidelity,
        SchemeFruitSalad,
        SchemeMonochrome,
        SchemeNeutral,
        SchemeRainbow,
        SchemeTonalSpot,
        SchemeVibrant,
        TonalPalette;
import 'package:material_ui/material_ui.dart';

/// `.agents/surfaces.md` explains why surfaces stay near gray and why
/// `primaryContainer` leaves the seed's own tone.
ColorScheme seededColorScheme({
  required Color seedColor,
  required Brightness brightness,
  DynamicSchemeVariant variant = DynamicSchemeVariant.tonalSpot,
}) {
  final dark = brightness == Brightness.dark;
  final scheme = _dynamicScheme(
    Hct.fromInt(seedColor.toARGB32()),
    dark,
    variant,
  );
  final primary = scheme.primaryPalette;
  final container = TonalPalette.of(
    primary.hue,
    min(primary.chroma, _primaryContainerChroma),
  );
  Color neutral(DynamicColor role, double maxChroma) {
    final palette = role.palette(scheme);
    return Color(
      Hct.from(
        palette.hue,
        min(palette.chroma, maxChroma),
        role.getTone(scheme),
      ).toInt(),
    );
  }

  final paperChroma = dark ? _surfaceChroma : _paperChroma;
  return ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: brightness,
    dynamicSchemeVariant: variant,
    primaryContainer: Color(container.get(dark ? 30 : 90)),
    onPrimaryContainer: Color(container.get(dark ? 90 : 30)),
    surface: neutral(MaterialDynamicColors.surface, paperChroma),
    surfaceBright: neutral(MaterialDynamicColors.surfaceBright, paperChroma),
    surfaceDim: neutral(MaterialDynamicColors.surfaceDim, _surfaceChroma),
    surfaceContainerLowest: neutral(
      MaterialDynamicColors.surfaceContainerLowest,
      _surfaceChroma,
    ),
    surfaceContainerLow: neutral(
      MaterialDynamicColors.surfaceContainerLow,
      _surfaceChroma,
    ),
    surfaceContainer: neutral(
      MaterialDynamicColors.surfaceContainer,
      _surfaceChroma,
    ),
    surfaceContainerHigh: neutral(
      MaterialDynamicColors.surfaceContainerHigh,
      _surfaceChroma,
    ),
    surfaceContainerHighest: neutral(
      MaterialDynamicColors.surfaceContainerHighest,
      _surfaceChroma,
    ),
    outlineVariant: neutral(MaterialDynamicColors.outlineVariant, 4),
  );
}

const _surfaceChroma = 3.0;

const _paperChroma = 1.5;

const _primaryContainerChroma = 48.0;

// Mirrors the private builder behind ColorScheme.fromSeed, so these palettes
// are the ones the scheme it returns was drawn from.
DynamicScheme _dynamicScheme(
  Hct source,
  bool dark,
  DynamicSchemeVariant variant,
) => switch (variant) {
  DynamicSchemeVariant.tonalSpot => SchemeTonalSpot(
    sourceColorHct: source,
    isDark: dark,
    contrastLevel: 0,
  ),
  DynamicSchemeVariant.fidelity => SchemeFidelity(
    sourceColorHct: source,
    isDark: dark,
    contrastLevel: 0,
  ),
  DynamicSchemeVariant.content => SchemeContent(
    sourceColorHct: source,
    isDark: dark,
    contrastLevel: 0,
  ),
  DynamicSchemeVariant.monochrome => SchemeMonochrome(
    sourceColorHct: source,
    isDark: dark,
    contrastLevel: 0,
  ),
  DynamicSchemeVariant.neutral => SchemeNeutral(
    sourceColorHct: source,
    isDark: dark,
    contrastLevel: 0,
  ),
  DynamicSchemeVariant.vibrant => SchemeVibrant(
    sourceColorHct: source,
    isDark: dark,
    contrastLevel: 0,
  ),
  DynamicSchemeVariant.expressive => SchemeExpressive(
    sourceColorHct: source,
    isDark: dark,
    contrastLevel: 0,
  ),
  DynamicSchemeVariant.rainbow => SchemeRainbow(
    sourceColorHct: source,
    isDark: dark,
    contrastLevel: 0,
  ),
  DynamicSchemeVariant.fruitSalad => SchemeFruitSalad(
    sourceColorHct: source,
    isDark: dark,
    contrastLevel: 0,
  ),
};

final _successPalette = TonalPalette.fromHct(
  Hct.fromInt(Colors.green.toARGB32()),
);

final _warningPalette = TonalPalette.fromHct(
  Hct.fromInt(Colors.orange.toARGB32()),
);

extension ColorExtension on Color {
  Color get opacity80 {
    return withValues(alpha: 0.8);
  }

  Color get opacity60 {
    return withValues(alpha: 0.6);
  }

  Color get opacity50 {
    return withValues(alpha: 0.5);
  }

  Color get opacity38 {
    return withValues(alpha: 0.38);
  }

  Color get opacity30 {
    return withValues(alpha: 0.3);
  }

  Color get opacity12 {
    return withValues(alpha: 0.12);
  }

  Color get opacity15 {
    return withValues(alpha: 0.15);
  }

  Color get opacity10 {
    return withValues(alpha: 0.1);
  }

  Color get opacity0 {
    return withValues(alpha: 0);
  }

  double get tone => Hct.fromInt(toARGB32()).tone;

  Color shiftTone(double delta) {
    final hct = Hct.fromInt(toARGB32());
    return Color(
      Hct.from(
        hct.hue,
        hct.chroma,
        clampDouble(hct.tone + delta, 0, 100),
      ).toInt(),
    );
  }

  String get hex {
    final value = toARGB32();
    final red = (value >> 16) & 0xFF;
    final green = (value >> 8) & 0xFF;
    final blue = value & 0xFF;
    return '#${red.toRadixString(16).padLeft(2, '0')}'
            '${green.toRadixString(16).padLeft(2, '0')}'
            '${blue.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }
}

extension ColorSchemeExtension on ColorScheme {
  ColorScheme toPureBlack(bool isPureBlack) {
    if (!isPureBlack || brightness != Brightness.dark) {
      return this;
    }
    final shift = surface.tone;
    Color lower(Color color) => color.shiftTone(-shift);

    return copyWith(
      surface: Colors.black,
      surfaceDim: Colors.black,
      surfaceContainerLowest: Colors.black,
      surfaceContainerLow: lower(surfaceContainerLow),
      surfaceContainer: lower(surfaceContainer),
      surfaceContainerHigh: lower(surfaceContainerHigh),
      surfaceContainerHighest: lower(surfaceContainerHighest),
      surfaceBright: lower(surfaceBright),
    );
  }

  Color get modalScrim => scrim.withValues(alpha: 0.32);

  Color _toneOf(TonalPalette palette, int light, int dark) =>
      Color(palette.get(brightness == Brightness.dark ? dark : light));

  Color get success => _toneOf(_successPalette, 40, 80);

  Color get successContainer => _toneOf(_successPalette, 90, 30);

  Color get onSuccessContainer => _toneOf(_successPalette, 30, 90);

  Color get warning => _toneOf(_warningPalette, 40, 80);

  Color get warningContainer => _toneOf(_warningPalette, 90, 30);

  Color get onWarningContainer => _toneOf(_warningPalette, 30, 90);

  Color? delayColor(int? delay) {
    if (delay == null) return null;
    if (delay < 0) return error;
    if (delay < 600) return success;
    return warning;
  }
}
