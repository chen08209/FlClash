import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/app_localizations.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import '../helpers/test_app.dart';

String _flutter() {
  final root = Platform.environment['FLUTTER_ROOT'];
  final name = Platform.isWindows ? 'flutter.bat' : 'flutter';
  return root == null ? name : '$root/bin/$name';
}

void main() {
  test('a message missing from a locale generates its English text', () {
    final project = Directory.systemTemp.createTempSync('flclash-l10n-');
    addTearDown(() => project.deleteSync(recursive: true));
    File('${project.path}/pubspec.yaml').writeAsStringSync(
      'name: l10n_fixture\n'
      'environment:\n'
      "  sdk: '>=3.10.0 <4.0.0'\n"
      'flutter:\n'
      '  generate: true\n',
    );
    File('l10n.yaml').copySync('${project.path}/l10n.yaml');
    final arb = Directory('${project.path}/arb')..createSync();
    File('${arb.path}/intl_en.arb').writeAsStringSync(
      jsonEncode({'kept': 'Kept', 'dropped': 'Only in English'}),
    );
    File(
      '${arb.path}/intl_es.arb',
    ).writeAsStringSync(jsonEncode({'kept': 'Conservado'}));

    final result = Process.runSync(
      _flutter(),
      ['gen-l10n'],
      workingDirectory: project.path,
      runInShell: Platform.isWindows,
    );
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');

    final spanish = File(
      '${project.path}/lib/l10n/l10n_es.dart',
    ).readAsStringSync();
    expect(spanish, contains("String get kept => 'Conservado';"));
    expect(spanish, contains("String get dropped => 'Only in English';"));
  });

  test('an unsupported locale reads English', () {
    final appLocalizations = loadAppLocalizations(const Locale('de'));

    expect(appLocalizations.localeName, 'en');
    expect(currentAppLocalizations.settings, appLocalizations.settings);
  });

  testWidgets('currentAppLocalizations follows the locale the app switches '
      'to', (tester) async {
    for (final locale in const [
      Locale('zh', 'CN'),
      Locale('ja'),
      Locale('en'),
    ]) {
      await tester.pumpWidget(
        TestApp(locale: locale, child: const SizedBox.shrink()),
      );

      final expected = lookupAppLocalizations(locale);
      expect(currentAppLocalizations.localeName, expected.localeName);
      expect(currentAppLocalizations.settings, expected.settings);
      expect(Intl.getCurrentLocale(), expected.localeName);
    }
    expect(
      lookupAppLocalizations(const Locale('zh', 'CN')).settings,
      isNot(lookupAppLocalizations(const Locale('en')).settings),
    );
  });
}
