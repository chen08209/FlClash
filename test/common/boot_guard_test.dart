import 'package:fl_clash/common/boot_guard.dart';
import 'package:fl_clash/common/boot_record.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordStore {
  BootRecord? record;
  var writes = 0;

  Future<BootRecord?> read() async => record;

  Future<void> write(BootRecord value) async {
    record = value;
    writes++;
  }
}

BootGuard _guard(
  _RecordStore store, {
  bool supported = true,
  AppExitInfo? exitInfo,
  bool crashReported = false,
  int now = 5000,
  void Function()? onCrashProbe,
}) {
  return BootGuard(
    supported: supported,
    readRecord: store.read,
    writeRecord: store.write,
    readExitInfo: () async => exitInfo,
    readCrashReport: () async {
      onCrashProbe?.call();
      return crashReported;
    },
    now: () => now,
  );
}

void main() {
  test(
    'a first launch records a starting stage and recovers nothing',
    () async {
      final store = _RecordStore();
      final guard = _guard(store);

      final decision = await guard.evaluate(
        profileId: 7,
        crashlyticsEnabled: false,
      );

      expect(decision.recovery, BootRecovery.none);
      expect(store.record?.stage, BootStage.starting);
      expect(store.record?.profileId, 7);
      expect(store.record?.startedAt, 5000);
      expect(store.record?.failureCount, 0);
    },
  );

  test(
    'the Crashlytics probe stays out of the path unless it is enabled',
    () async {
      final store = _RecordStore();
      var probes = 0;
      final guard = _guard(store, onCrashProbe: () => probes++);

      await guard.evaluate(profileId: 7, crashlyticsEnabled: false);
      expect(probes, 0);

      await guard.evaluate(profileId: 7, crashlyticsEnabled: true);
      expect(probes, 1);
    },
  );

  test('an interrupted launch is carried into the next boot record', () async {
    final store = _RecordStore()
      ..record = const BootRecord(
        stage: BootStage.starting,
        profileId: 7,
        startedAt: 1000,
      );
    final guard = _guard(store);

    final decision = await guard.evaluate(
      profileId: 7,
      crashlyticsEnabled: false,
    );

    expect(decision.recovery, BootRecovery.skipAutoSetup);
    expect(store.record?.failureCount, 1);
    expect(store.record?.profileId, 7);
    expect(store.record?.lastFailedProfileId, 7);
  });

  test('clearing the profile also drops it from the new boot record', () async {
    final store = _RecordStore()
      ..record = const BootRecord(
        stage: BootStage.starting,
        profileId: 7,
        startedAt: 1000,
        failureCount: 1,
      );
    final guard = _guard(store);

    final decision = await guard.evaluate(
      profileId: 7,
      crashlyticsEnabled: false,
    );

    expect(decision.recovery, BootRecovery.clearProfile);
    expect(store.record?.profileId, isNull);
    expect(store.record?.lastFailedProfileId, 7);
    expect(store.record?.failureCount, 2);
  });

  test('a consumed exit timestamp is remembered across launches', () async {
    final store = _RecordStore();
    final guard = _guard(
      store,
      exitInfo: const AppExitInfo(
        reason: AppExitReason.userRequested,
        timestamp: 4000,
      ),
    );

    await guard.evaluate(profileId: 7, crashlyticsEnabled: false);

    expect(store.record?.handledExitAt, 4000);

    final next = _guard(
      store,
      exitInfo: const AppExitInfo(
        reason: AppExitReason.userRequested,
        timestamp: 4000,
      ),
      now: 6000,
    );
    final decision = await next.evaluate(
      profileId: 7,
      crashlyticsEnabled: false,
    );

    expect(decision.recovery, BootRecovery.skipAutoSetup);
    expect(store.record?.handledExitAt, 4000);
  });

  test('a completed launch resets the failure count', () async {
    final store = _RecordStore();
    final guard = _guard(store);
    await guard.evaluate(profileId: 7, crashlyticsEnabled: false);

    await guard.markRunning();

    expect(store.record?.stage, BootStage.running);
    expect(store.record?.failureCount, 0);
  });

  test('a degraded launch keeps its failure count until a clean run', () async {
    final store = _RecordStore()
      ..record = const BootRecord(
        stage: BootStage.starting,
        profileId: 7,
        startedAt: 1000,
      );
    final guard = _guard(store);
    await guard.evaluate(profileId: 7, crashlyticsEnabled: false);

    await guard.markRunning();

    expect(store.record?.stage, BootStage.running);
    expect(store.record?.failureCount, 1);
  });

  test('a clean exit closes the record and clears the failure count', () async {
    final store = _RecordStore()
      ..record = const BootRecord(
        stage: BootStage.starting,
        profileId: 7,
        startedAt: 1000,
        failureCount: 1,
        lastFailedProfileId: 7,
        handledExitAt: 900,
      );
    final guard = _guard(store);

    await guard.markClosed();

    expect(store.record?.stage, isNull);
    expect(store.record?.failureCount, 0);
    expect(store.record?.lastFailedProfileId, 7);
    expect(store.record?.handledExitAt, 900);
  });

  test('markRunning and markClosed do nothing without a record', () async {
    final store = _RecordStore();
    final guard = _guard(store);

    await guard.markRunning();
    await guard.markClosed();

    expect(store.writes, 0);
    expect(store.record, isNull);
  });

  test('an unsupported platform never reads, writes or recovers', () async {
    final store = _RecordStore()
      ..record = const BootRecord(
        stage: BootStage.starting,
        profileId: 7,
        startedAt: 1000,
        failureCount: 1,
      );
    var probes = 0;
    final guard = _guard(
      store,
      supported: false,
      crashReported: true,
      onCrashProbe: () => probes++,
    );

    final decision = await guard.evaluate(
      profileId: 7,
      crashlyticsEnabled: true,
    );
    await guard.markRunning();
    await guard.markClosed();

    expect(decision.recovery, BootRecovery.none);
    expect(guard.decision.recovery, BootRecovery.none);
    expect(probes, 0);
    expect(store.writes, 0);
    expect(store.record?.stage, BootStage.starting);
  });
}
