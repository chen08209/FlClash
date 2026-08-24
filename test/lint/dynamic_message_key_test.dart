import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/views/navigation.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

const _arbDir = 'arb';
const _libDir = 'lib';

const _registeredSites = <String, Set<String>>{
  'lib/common/tray.dart': {'mode.name'},
  'lib/manager/app_manager.dart': {'item.label.name'},
  'lib/pages/home.dart': {'item.label.name'},
  'lib/views/hotkey.dart': {"'action_\$messageText'"},
  'lib/views/backup_and_restore.dart': {
    "'restoreStrategy_\${mode.name}'",
    "'restoreStrategy_\${restoreStrategy.name}'",
  },
  'lib/views/theme.dart': {
    "'\${item.name}Scheme'",
    "'\${schemeVariant.name}Scheme'",
  },
  'lib/views/config/network.dart': {"'routeMode_\${mode.name}'"},
  'lib/views/proxies/setting.dart': {'item.name'},
  'lib/views/dashboard/widgets/outbound_mode.dart': {'item.name'},
  'lib/views/tools.dart': {
    'navigationItem.label.name',
    'navigationItem.description!',
    'locale.toString()',
    'subTitle',
  },
};

Iterable<String> _suffixed(Iterable<Enum> values, String suffix) =>
    values.map((value) => '${value.name}$suffix');

Iterable<String> _prefixed(String prefix, Iterable<Enum> values) =>
    values.map((value) => '$prefix${value.name}');

Map<String, Iterable<String>> _families() => {
  'HotAction': _prefixed('action_', HotAction.values),
  'RestoreStrategy': _prefixed('restoreStrategy_', RestoreStrategy.values),
  'RouteMode': _prefixed('routeMode_', RouteMode.values),
  'DynamicSchemeVariant': _suffixed(DynamicSchemeVariant.values, 'Scheme'),
  'PageLabel': _suffixed(PageLabel.values, ''),
  'Mode': _suffixed(Mode.values, ''),
  'ProxiesType': _suffixed(ProxiesType.values, ''),
  'ProxyCardType': _suffixed(ProxyCardType.values, ''),
  'NavigationItem.description': navigation
      .getItems(openLogs: true, hasProxies: true)
      .map((item) => item.description)
      .whereType<String>(),
  'supportedLocales': AppLocalizations.delegate.supportedLocales.map(
    (locale) => locale.toString(),
  ),
};

Map<String, Set<String>> _arbKeys() {
  final result = <String, Set<String>>{};
  for (final entity in Directory(_arbDir).listSync()) {
    if (entity is! File || !entity.path.endsWith('.arb')) continue;
    final decoded =
        jsonDecode(entity.readAsStringSync()) as Map<String, Object?>;
    result[entity.uri.pathSegments.last] = decoded.keys
        .where((key) => !key.startsWith('@'))
        .toSet();
  }
  return result;
}

Map<String, Set<String>> _messageSites() {
  final sites = <String, Set<String>>{};
  for (final entity in Directory(_libDir).listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final path = entity.path;
    if (path.contains('/generated/') || path.contains('/l10n/')) continue;
    final source = entity.readAsStringSync();
    for (final match in RegExp(r'Intl\.message\(').allMatches(source)) {
      var depth = 1;
      var index = match.end;
      final buffer = StringBuffer();
      while (index < source.length && depth > 0) {
        final char = source[index];
        if (char == '(') depth++;
        if (char == ')') {
          depth--;
          if (depth == 0) break;
        }
        buffer.write(char);
        index++;
      }
      final argument = buffer
          .toString()
          .split(',')
          .first
          .replaceAll(RegExp(r'\s+'), '');
      sites.putIfAbsent(path, () => <String>{}).add(argument);
    }
  }
  return sites;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every locale carries the same keys', () {
    final byFile = _arbKeys();
    expect(byFile, isNotEmpty, reason: 'no .arb files were read from $_arbDir');

    final reference = byFile['intl_en.arb'];
    expect(reference, isNotNull, reason: 'arb/intl_en.arb is the reference');

    for (final entry in byFile.entries) {
      expect(
        entry.value,
        reference,
        reason:
            '${entry.key} does not carry the same keys as intl_en.arb. A key '
            'present in only one locale renders as the raw key elsewhere.',
      );
    }
  });

  test('every key built at runtime exists in every locale', () {
    final byFile = _arbKeys();
    final missing = <String>[];

    for (final family in _families().entries) {
      for (final key in family.value) {
        for (final arb in byFile.entries) {
          if (!arb.value.contains(key)) {
            missing.add('${family.key} -> "$key" missing from ${arb.key}');
          }
        }
      }
    }

    expect(
      missing,
      isEmpty,
      reason:
          'These keys reach AppLocalizations through Intl.message(<runtime '
          'string>), so the analyzer cannot see them. Intl.message returns its '
          'argument unchanged when the lookup fails, which ships the raw key '
          'to the UI instead of throwing:\n  ${missing.join('\n  ')}',
    );
  });

  test('no Intl.message site builds a key this test does not cover', () {
    final found = _messageSites();

    expect(
      found.keys.toSet(),
      _registeredSites.keys.toSet(),
      reason:
          'A file gained or lost Intl.message calls. Register it in '
          '_registeredSites and add its key family to _families, or the keys it '
          'builds go unchecked.',
    );

    for (final entry in found.entries) {
      expect(
        entry.value,
        _registeredSites[entry.key],
        reason:
            '${entry.key} builds a message key from an expression this test '
            'does not know about. Add the enum or list it derives from to '
            '_families so a rename cannot silently break the UI text.',
      );
    }
  });
}
