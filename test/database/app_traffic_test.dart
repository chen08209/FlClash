import 'dart:async';

import 'package:drift/native.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Database database;

  setUp(() {
    database = Database(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  AppTrafficDelta delta({
    required DateTime day,
    required int profileId,
    required String applicationId,
    required int upload,
    required int download,
    String applicationLabel = 'Browser',
    String proxy = 'Proxy A',
    String provider = 'Provider A',
  }) {
    return AppTrafficDelta(
      day: day,
      profileId: profileId,
      profileLabel: 'Plan $profileId',
      applicationId: applicationId,
      applicationLabel: applicationLabel,
      processPath: '/Applications/$applicationLabel.app/',
      proxy: proxy,
      provider: provider,
      upload: upload,
      download: download,
    );
  }

  test('upserts deltas and aggregates by application', () async {
    final today = DateTime(2026, 8, 27);
    await database.appTrafficDao.addAll([
      delta(
        day: today,
        profileId: 1,
        applicationId: 'browser',
        upload: 10,
        download: 20,
      ),
      delta(
        day: today,
        profileId: 1,
        applicationId: 'browser',
        upload: 3,
        download: 4,
      ),
      delta(
        day: today,
        profileId: 1,
        applicationId: 'browser',
        upload: 1,
        download: 2,
        proxy: 'Proxy B',
        provider: 'Provider B',
      ),
    ]);

    final usage = await database.appTrafficDao
        .queryUsage(profileId: 1, since: today)
        .getSingle();

    expect(usage.upload, 14);
    expect(usage.download, 26);
    expect(usage.proxies, containsAll(['Proxy A', 'Proxy B']));
    expect(usage.providers, containsAll(['Provider A', 'Provider B']));
    expect(await database.appTrafficRecords.count.getSingle(), 2);
  });

  test('live queries refresh after traffic is persisted', () async {
    final iterator = StreamIterator(
      database.appTrafficDao.queryUsage().watch(),
    );
    addTearDown(iterator.cancel);
    expect(await iterator.moveNext(), isTrue);
    expect(iterator.current, isEmpty);

    await database.appTrafficDao.addAll([
      delta(
        day: DateTime(2026, 11, 4),
        profileId: 1,
        applicationId: 'browser',
        upload: 12,
        download: 34,
      ),
    ]);

    expect(
      await iterator.moveNext().timeout(const Duration(seconds: 3)),
      isTrue,
    );
    expect(iterator.current.single.total, 46);
  });

  test(
    'filters by subscription and date and clears only selected scope',
    () async {
      final today = DateTime(2026, 8, 27);
      await database.appTrafficDao.addAll([
        delta(
          day: today.subtract(const Duration(days: 10)),
          profileId: 1,
          applicationId: 'old',
          upload: 100,
          download: 100,
        ),
        delta(
          day: today,
          profileId: 1,
          applicationId: 'current',
          upload: 10,
          download: 20,
        ),
        delta(
          day: today,
          profileId: 2,
          applicationId: 'other-plan',
          upload: 30,
          download: 40,
        ),
      ]);

      final recent = await database.appTrafficDao
          .queryUsage(
            profileId: 1,
            since: today.subtract(const Duration(days: 6)),
          )
          .get();
      expect(recent.map((usage) => usage.applicationId), ['current']);

      expect(await database.appTrafficDao.clear(profileId: 1), 2);
      final remaining = await database.appTrafficDao.queryUsage().get();
      expect(remaining.single.applicationId, 'other-plan');
    },
  );
}
