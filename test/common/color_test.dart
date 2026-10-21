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

const _accentStyles = {ColorStyle.vivid, ColorStyle.tinted};

const _materialVariants = {
  ColorStyle.vivid: DynamicSchemeVariant.content,
  ColorStyle.tinted: DynamicSchemeVariant.content,
  ColorStyle.soft: DynamicSchemeVariant.tonalSpot,
  ColorStyle.monochrome: DynamicSchemeVariant.monochrome,
};

double _contrast(Color a, Color b) {
  final lighter = max(a.computeLuminance(), b.computeLuminance());
  final darker = min(a.computeLuminance(), b.computeLuminance());
  return (lighter + 0.05) / (darker + 0.05);
}

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
      for (final style in ColorStyle.values) {
        for (final brightness in Brightness.values) {
          final dark = brightness == Brightness.dark;
          final scheme = seededColorScheme(
            seedColor: seed,
            brightness: brightness,
            style: style,
          );
          final material = ColorScheme.fromSeed(
            seedColor: seed,
            brightness: brightness,
            dynamicSchemeVariant: _materialVariants[style]!,
          );
          final reason = '$seed $style $brightness';
          final gray = style != ColorStyle.tinted;
          final surfaces = [
            (scheme.surfaceDim, material.surfaceDim, null),
            (
              scheme.surfaceContainerLowest,
              material.surfaceContainerLowest,
              null,
            ),
            (scheme.surfaceContainerLow, material.surfaceContainerLow, null),
            (scheme.surfaceContainer, material.surfaceContainer, 15.0),
            (scheme.surfaceContainerHigh, material.surfaceContainerHigh, 21.0),
            (
              scheme.surfaceContainerHighest,
              material.surfaceContainerHighest,
              27.0,
            ),
          ];
          for (final (ours, theirs, darkTone) in surfaces) {
            if (gray) {
              expect(_hct(ours).chroma, _grayish(theirs, 3.1), reason: reason);
            }
            expect(
              _hct(ours).tone,
              closeTo((dark ? darkTone : null) ?? _hct(theirs).tone, 0.6),
              reason: reason,
            );
          }
          final papers = {
            scheme.surface: material.surface,
            scheme.surfaceBright: material.surfaceBright,
          };
          for (final MapEntry(key: ours, value: theirs) in papers.entries) {
            if (gray) {
              expect(
                _hct(ours).chroma,
                _grayish(theirs, dark ? 3.1 : 1.6),
                reason: reason,
              );
            }
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
          if (!_accentStyles.contains(style)) {
            expect(scheme.primary, material.primary, reason: reason);
          }
          if (dark) {
            expect(
              _hct(scheme.onSurface).tone,
              closeTo(97, 0.5),
              reason: reason,
            );
          } else {
            expect(scheme.onSurface, material.onSurface, reason: reason);
          }
        }
      }
    }
  });

  test('vivid and tinted keep the seed as primary, lifted in dark', () {
    const blue = Color(0xFF007AFF);
    for (final style in _accentStyles) {
      final light = seededColorScheme(
        seedColor: blue,
        brightness: Brightness.light,
        style: style,
      );
      final dark = seededColorScheme(
        seedColor: blue,
        brightness: Brightness.dark,
        style: style,
      );

      expect(light.primary, blue, reason: '$style');
      expect(light.onPrimary, Colors.white, reason: '$style');
      expect(_hct(dark.primary).hue, closeTo(_hct(blue).hue, 1));
      expect(_hct(dark.primary).tone, closeTo(_hct(blue).tone + 3, 0.5));
      expect(dark.onPrimary, Colors.white, reason: '$style');
    }

    final soft = seededColorScheme(
      seedColor: blue,
      brightness: Brightness.light,
      style: ColorStyle.soft,
    );
    expect(_hct(soft.primary).tone, closeTo(40, 1));
    expect(_hct(soft.primary).chroma, lessThan(_hct(blue).chroma * 0.6));
  });

  test('tinted washes the surfaces with the seed and keeps their tones', () {
    const blue = Color(0xFF007AFF);
    for (final brightness in Brightness.values) {
      final vivid = seededColorScheme(seedColor: blue, brightness: brightness);
      final tinted = seededColorScheme(
        seedColor: blue,
        brightness: brightness,
        style: ColorStyle.tinted,
      );
      final reason = '$brightness';

      expect(tinted.primary, vivid.primary, reason: reason);
      for (final (ours, plain) in [
        (tinted.surface, vivid.surface),
        (tinted.surfaceContainer, vivid.surfaceContainer),
        (tinted.surfaceContainerHighest, vivid.surfaceContainerHighest),
      ]) {
        expect(_hct(ours).chroma, greaterThan(5), reason: reason);
        expect(_hct(ours).hue, closeTo(_hct(blue).hue, 15), reason: reason);
        expect(_hct(ours).tone, closeTo(_hct(plain).tone, 0.6), reason: reason);
      }
    }

    final graphite = seededColorScheme(
      seedColor: const Color(0xFF8E8E93),
      brightness: Brightness.light,
      style: ColorStyle.tinted,
    );
    expect(_hct(graphite.surfaceContainer).chroma, lessThan(3.1));
  });

  test('a primary kept from the seed stays readable under its text', () {
    for (var hue = 0.0; hue < 360; hue += 30) {
      for (final tone in [5.0, 35.0, 55.0, 70.0, 90.0, 98.0]) {
        final seed = Color(Hct.from(hue, 60, tone).toInt());
        for (final brightness in Brightness.values) {
          final scheme = seededColorScheme(
            seedColor: seed,
            brightness: brightness,
          );
          final reason = '$seed $brightness';

          expect(
            _contrast(scheme.primary, scheme.onPrimary),
            greaterThanOrEqualTo(3),
            reason: reason,
          );
          if (brightness == Brightness.dark) {
            expect(
              _contrast(scheme.primary, scheme.surface),
              greaterThanOrEqualTo(3),
              reason: reason,
            );
          }
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
