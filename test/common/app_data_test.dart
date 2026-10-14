import 'dart:io';

import 'package:drift/drift.dart';
import 'package:fl_clash/common/app_data.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/database/database.dart' as db;
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory home;

  setUpAll(() {
    home = Directory.systemTemp.createTempSync('flclash-app-data-');
    AppPath.supportDirectory = () async => home;
    AppPath.temporaryDirectory = () async => home;
    AppPath.cacheDirectory = () async => home;
    AppPath.downloadDirectory = () async => home;
  });

  tearDownAll(() {
    if (home.existsSync()) home.deleteSync(recursive: true);
  });

  test('clears what a startup failure left behind without the Core', () async {
    SharedPreferences.setMockInitialValues({});
    await preferences.setVersion(7);
    final databaseFile = File(await appPath.databasePath)
      ..writeAsStringSync('not a database');
    final profilesDir = Directory(join(await appPath.profilesPath, '1'))
      ..createSync(recursive: true);
    final broken = db.Database(
      LazyDatabase(() async => throw const FileSystemException('corrupt')),
    );
    db.database = broken;
    await expectLater(broken.profilesDao.query().get(), throwsA(anything));

    await clearAppData();

    expect(await preferences.getVersion(), 0);
    expect(
      databaseFile.existsSync(),
      isFalse,
      reason:
          'a database that failed to open rethrows from close, and it is '
          'the file most likely to be why startup failed',
    );
    expect(profilesDir.parent.existsSync(), isFalse);
  });
}
