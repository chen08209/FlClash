import 'dart:io';

import 'package:fl_clash/common/constant.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_ui/color.dart';
import 'package:prism_ui/color_scheme.dart';

const _accents = ['blue', 'purple', 'pink', 'red', 'orange', 'yellow', 'green'];

const _marker =
    "/* The app's seededColorScheme of each seed, written by\n"
    '   flutter test --update-goldens test/tool/site_palette_test.dart */\n';

final _file = File('site/assets/style.css');

String _hex(Color color) =>
    '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

// The page, card, block and inset levels `.agents/surfaces.md` gives each brightness.
Map<String, Color> _seedRoles(int index, Brightness brightness) {
  final scheme = _scheme(index, brightness);
  final dark = brightness == Brightness.dark;
  return {
    'page': dark ? scheme.surface : scheme.surfaceContainer,
    'card': dark ? scheme.surfaceContainer : scheme.surfaceBright,
    'block': dark ? scheme.surfaceContainerHigh : scheme.surfaceContainer,
    'inset': scheme.surfaceContainerHighest,
    'on-surface': scheme.onSurface,
    'on-surface-variant': scheme.onSurfaceVariant,
    'primary': scheme.primary,
    'on-primary': scheme.onPrimary,
    'primary-container': scheme.primaryContainer,
    'on-primary-container': scheme.onPrimaryContainer,
  };
}

Map<String, Color> _fixedRoles(ColorScheme scheme) => {
  'success': scheme.success,
  'warning': scheme.warning,
  'error': scheme.error,
  'error-container': scheme.errorContainer,
  'on-error-container': scheme.onErrorContainer,
};

ColorScheme _scheme(int index, Brightness brightness) => seededColorScheme(
  seedColor: Color(defaultPrimaryColors[index]),
  brightness: brightness,
  style: ColorStyle.vivid,
);

String _block(String selector, Map<String, Color> roles, String indent) {
  final lines = [
    for (final MapEntry(:key, :value) in roles.entries)
      '$indent  --$key: ${_hex(value)};',
  ];
  return '$indent$selector {\n${lines.join('\n')}\n$indent}\n';
}

String _palette() {
  final out = StringBuffer();
  for (final brightness in [Brightness.light, Brightness.dark]) {
    final dark = brightness == Brightness.dark;
    final indent = dark ? '  ' : '';
    if (dark) out.write('@media (prefers-color-scheme: dark) {\n');
    for (final (index, accent) in _accents.indexed) {
      if (index > 0) out.write('\n');
      out.write(
        index == 0
            ? _block(':root', {
                ..._seedRoles(index, brightness),
                ..._fixedRoles(_scheme(index, brightness)),
              }, indent)
            : _block(
                ':root[data-accent="$accent"]',
                _seedRoles(index, brightness),
                indent,
              ),
      );
    }
    out.write(dark ? '}\n' : '\n');
  }
  return out.toString();
}

void main() {
  test('the roles the site keeps once hold for every seed', () {
    for (final brightness in Brightness.values) {
      final first = _fixedRoles(_scheme(0, brightness));
      for (var index = 1; index < _accents.length; index++) {
        expect(_fixedRoles(_scheme(index, brightness)), first);
      }
    }
  });

  test('the site palette is the app scheme of every seed', () {
    final css = _file.readAsStringSync();
    final start = css.indexOf(_marker);
    expect(start, isNot(-1), reason: 'the palette marker is missing');
    final from = start + _marker.length + 1;
    final darkEnd = css.indexOf('\n}\n', css.indexOf('@media (prefers', from));
    final actual = css.substring(from, darkEnd + 3);
    final expected = _palette();
    if (autoUpdateGoldenFiles && actual != expected) {
      _file.writeAsStringSync(css.replaceRange(from, darkEnd + 3, expected));
      return;
    }
    expect(actual, expected);
  });
}
