import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/preferences.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('preferences_test');
  });

  tearDown(() {
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  String storagePath() => '${tempDir.path}/shared_preferences.json';

  group('Preferences', () {
    test('round-trips version and config', () async {
      final prefs = Preferences.createForTest(path: storagePath());

      expect(await prefs.getVersion(), 0);
      expect(await prefs.getConfig(), isNull);

      await prefs.setVersion(1);
      const config = Config(themeProps: defaultThemeProps);
      expect(await prefs.saveConfig(config), isTrue);

      final reloaded = Preferences.createForTest(path: storagePath());
      expect(await reloaded.getVersion(), 1);
      expect((await reloaded.getConfig())?.themeProps, defaultThemeProps);
    });

    test('strips the legacy flutter. prefix from migrated files', () async {
      const config = Config(themeProps: defaultThemeProps);
      await File(storagePath()).writeAsString(
        jsonEncode({
          'flutter.version': 2,
          'flutter.config': jsonEncode(config),
        }),
      );

      final prefs = Preferences.createForTest(path: storagePath());

      expect(await prefs.getVersion(), 2);
      expect(await prefs.getConfig(), isNotNull);
    });

    test('reports isInit false when the file is corrupt', () async {
      await File(storagePath()).writeAsString('not json');

      final prefs = Preferences.createForTest(path: storagePath());

      expect(await prefs.isInit, isFalse);
    });

    test('handles a missing file as an empty store', () async {
      final prefs = Preferences.createForTest(path: storagePath());

      expect(await prefs.isInit, isTrue);
      expect(await prefs.getVersion(), 0);
    });

    test('saves shared state and clears all values', () async {
      final prefs = Preferences.createForTest(path: storagePath());

      await prefs.setVersion(1);
      await prefs.saveShareState(
        const SharedState(
          setupParams: null,
          vpnOptions: null,
          stopTip: '',
          startTip: '',
          currentProfileName: 'test',
          stopText: '',
          onlyStatisticsProxy: false,
          crashlytics: false,
        ),
      );

      final raw = jsonDecode(await File(storagePath()).readAsString())
          as Map<String, dynamic>;
      expect(raw, contains('sharedState'));

      await prefs.clearPreferences();
      final cleared = Preferences.createForTest(path: storagePath());
      expect(await cleared.getVersion(), 0);
    });
  });
}