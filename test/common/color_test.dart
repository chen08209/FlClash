import 'dart:math';

import 'package:fl_clash/ui/color.dart';
import 'package:material_color_utilities/hct/hct.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

Hct _hct(Color color) => Hct.fromInt(color.toARGB32());

/// A neutral sRGB gray already measures about 2.8 in HCT, so a role Material
/// leaves gray, as monochrome does, is held to Material's own value.
Matcher _grayish(Color material, double limit) =>
    lessThanOrEqualTo(max(limit, _hct(material).chroma + 0.01));

void main() {
  test('opacity extensions use their named alpha values', () {
    const color = Colors.blue;
    const tolerance = 0.0001;

    expect(color.opacity80.a, closeTo(0.8, tolerance));
    expect(color.opacity50.a, closeTo(0.5, tolerance));
    expect(color.opacity10.a, closeTo(0.1, tolerance));
    expect(color.opacity0.a, 0);
  });

  test('a seeded scheme keeps surfaces near gray and selects from the '
      'primary palette', () {
    for (final seed in const [
      Color(0xFFFFFF00),
      Color(0xFFD8C0C3),
      Color(0xFF03A9F4),
      Color(0xFFE91E63),
    ]) {
      for (final variant in DynamicSchemeVariant.values) {
        for (final brightness in Brightness.values) {
          final dark = brightness == Brightness.dark;
          final scheme = seededColorScheme(
            seedColor: seed,
            brightness: brightness,
            variant: variant,
          );
          final material = ColorScheme.fromSeed(
            seedColor: seed,
            brightness: brightness,
            dynamicSchemeVariant: variant,
          );
          final reason = '$seed $variant $brightness';
          final surfaces = {
            scheme.surfaceDim: material.surfaceDim,
            scheme.surfaceContainerLowest: material.surfaceContainerLowest,
            scheme.surfaceContainerLow: material.surfaceContainerLow,
            scheme.surfaceContainer: material.surfaceContainer,
            scheme.surfaceContainerHigh: material.surfaceContainerHigh,
            scheme.surfaceContainerHighest: material.surfaceContainerHighest,
          };
          for (final MapEntry(key: ours, value: theirs) in surfaces.entries) {
            expect(_hct(ours).chroma, _grayish(theirs, 3.1), reason: reason);
            expect(
              _hct(ours).tone,
              closeTo(_hct(theirs).tone, 0.6),
              reason: reason,
            );
          }
          final papers = {
            scheme.surface: material.surface,
            scheme.surfaceBright: material.surfaceBright,
          };
          for (final MapEntry(key: ours, value: theirs) in papers.entries) {
            expect(
              _hct(ours).chroma,
              _grayish(theirs, dark ? 3.1 : 1.6),
              reason: reason,
            );
          }
          expect(
            _hct(scheme.primaryContainer).tone,
            closeTo(dark ? 30 : 90, 1),
            reason: reason,
          );
          expect(
            _hct(scheme.primaryContainer).chroma,
            lessThan(48.5),
            reason: reason,
          );
          expect(
            _hct(scheme.onPrimaryContainer).tone,
            closeTo(dark ? 90 : 30, 1),
            reason: reason,
          );
          expect(scheme.primary, material.primary, reason: reason);
          expect(scheme.onSurface, material.onSurface, reason: reason);
        }
      }
    }
  });

  test('status colors keep their hue whatever the seed and follow the '
      'brightness', () {
    ColorScheme of(Color seed, Brightness brightness) =>
        seededColorScheme(seedColor: seed, brightness: brightness);

    final rose = of(const Color(0xFFE91E63), Brightness.light);
    final blue = of(const Color(0xFF03A9F4), Brightness.light);
    final night = of(const Color(0xFFE91E63), Brightness.dark);

    expect(rose.success, blue.success);
    expect(rose.warning, blue.warning);
    expect(_hct(rose.success).tone, closeTo(40, 1));
    expect(_hct(night.success).tone, closeTo(80, 1));
    expect(_hct(rose.warningContainer).tone, closeTo(90, 1));
    expect(_hct(night.onWarningContainer).tone, closeTo(90, 1));
    final gap = (_hct(rose.warning).hue - _hct(rose.error).hue).abs();
    expect(gap, greaterThan(25));
    expect(rose.delayColor(120), rose.success);
    expect(rose.delayColor(800), rose.warning);
    expect(rose.delayColor(-1), rose.error);
  });
}
