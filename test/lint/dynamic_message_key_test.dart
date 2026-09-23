import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/l10n_labels.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:flutter_test/flutter_test.dart';

const _arbDir = 'arb';
const _libDir = 'lib';

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

  test('no Intl.message call builds a key at runtime', () {
    final offenders = <String>[];
    for (final entity in Directory(_libDir).listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final path = entity.path;
      if (path.contains('/generated/') || path.contains('/l10n/')) continue;
      if (entity.readAsStringSync().contains('Intl.message(')) {
        offenders.add(path);
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Intl.message(<runtime string>) is invisible to the analyzer and '
          'returns its argument unchanged when the lookup fails, shipping the '
          'raw key to the UI. Add an exhaustive-switch label to '
          'lib/common/l10n_labels.dart instead:\n  ${offenders.join('\n  ')}',
    );
  });

  test('every supported locale has a translated display name', () async {
    for (final locale in AppLocalizations.delegate.supportedLocales) {
      await AppLocalizations.load(locale);
      expect(
        locale.label,
        isNot(locale.toString()),
        reason:
            'LocaleL10n.label fell back to the raw locale code for $locale. '
            'Add the locale to the switch in lib/common/l10n_labels.dart and '
            'a display-name key to every .arb file.',
      );
    }
  });
}
