import 'dart:convert';

import 'package:fl_clash/common/boot_record.dart';
import 'package:flutter_test/flutter_test.dart';

const _startedAt = 1000;

BootRecord _starting({
  int failureCount = 0,
  int? profileId = 7,
  int handledExitAt = 0,
}) {
  return BootRecord(
    stage: BootStage.starting,
    profileId: profileId,
    startedAt: _startedAt,
    failureCount: failureCount,
    handledExitAt: handledExitAt,
  );
}

AppExitInfo _exit(AppExitReason reason, {int timestamp = _startedAt + 500}) {
  return AppExitInfo(reason: reason, timestamp: timestamp);
}

void main() {
  group('AppExitReason', () {
    test('maps the ApplicationExitInfo codes it is given', () {
      expect(AppExitReason.fromCode(4), AppExitReason.crash);
      expect(AppExitReason.fromCode(5), AppExitReason.crashNative);
      expect(AppExitReason.fromCode(6), AppExitReason.anr);
      expect(AppExitReason.fromCode(10), AppExitReason.userRequested);
      expect(AppExitReason.fromCode(null), AppExitReason.unknown);
      expect(AppExitReason.fromCode('4'), AppExitReason.unknown);
      expect(AppExitReason.fromCode(99), AppExitReason.unknown);
    });

    test('separates crashes, external stops and undecidable reasons', () {
      expect(AppExitReason.crashNative.isCrash, isTrue);
      expect(AppExitReason.initializationFailure.isCrash, isTrue);
      expect(AppExitReason.crash.isExternalStop, isFalse);
      expect(AppExitReason.lowMemory.isExternalStop, isTrue);
      expect(AppExitReason.signaled.isExternalStop, isTrue);
      expect(AppExitReason.unknown.isCrash, isFalse);
      expect(AppExitReason.unknown.isExternalStop, isFalse);
      expect(AppExitReason.other.isExternalStop, isFalse);
    });
  });

  group('AppExitInfo', () {
    test('parses a platform map', () {
      final info = AppExitInfo.fromJson({
        'reason': 6,
        'timestamp': 42,
        'description': 'anr',
      });

      expect(info?.reason, AppExitReason.anr);
      expect(info?.timestamp, 42);
      expect(info?.description, 'anr');
    });

    test('rejects payloads without a usable timestamp', () {
      expect(AppExitInfo.fromJson(null), isNull);
      expect(AppExitInfo.fromJson('crash'), isNull);
      expect(AppExitInfo.fromJson({'reason': 4}), isNull);
    });
  });

  group('BootRecord', () {
    test('round-trips through JSON', () {
      const record = BootRecord(
        stage: BootStage.running,
        profileId: 3,
        startedAt: 12,
        failureCount: 2,
        lastFailedProfileId: 9,
        handledExitAt: 34,
      );

      expect(BootRecord.fromJson(json.decode(json.encode(record))), record);
    });

    test('falls back to a closed record when fields are missing or wrong', () {
      final record = BootRecord.fromJson({'stage': 'gone', 'profileId': '3'});

      expect(record, const BootRecord());
      expect(BootRecord.fromJson('boot'), isNull);
    });
  });

  group('resolveBootDecision', () {
    test('does nothing when the last run reached the running stage', () {
      final decision = resolveBootDecision(
        record: const BootRecord(stage: BootStage.running, profileId: 7),
        exitInfo: _exit(AppExitReason.crash),
        crashReported: true,
      );

      expect(decision.recovery, BootRecovery.none);
      expect(decision.failureCount, 0);
    });

    test('does nothing on a first launch', () {
      final decision = resolveBootDecision(
        record: null,
        exitInfo: null,
        crashReported: true,
      );

      expect(decision.recovery, BootRecovery.none);
    });

    test('skips automatic setup after one interrupted launch', () {
      final decision = resolveBootDecision(
        record: _starting(),
        exitInfo: null,
        crashReported: false,
      );

      expect(decision.recovery, BootRecovery.skipAutoSetup);
      expect(decision.failureCount, 1);
      expect(decision.failedProfileId, 7);
      expect(decision.crashConfirmed, isFalse);
    });

    test('clears the profile once launches fail twice in a row', () {
      final decision = resolveBootDecision(
        record: _starting(failureCount: 1),
        exitInfo: _exit(AppExitReason.crashNative),
        crashReported: false,
      );

      expect(decision.recovery, BootRecovery.clearProfile);
      expect(decision.failureCount, 2);
      expect(decision.crashConfirmed, isTrue);
      expect(decision.exitReason, AppExitReason.crashNative);
    });

    test('keeps skipping when there is no profile left to clear', () {
      final decision = resolveBootDecision(
        record: _starting(failureCount: 3, profileId: null),
        exitInfo: null,
        crashReported: false,
      );

      expect(decision.recovery, BootRecovery.skipAutoSetup);
      expect(decision.failureCount, 4);
    });

    test('an external stop is not counted as a failed launch', () {
      for (final reason in [
        AppExitReason.userRequested,
        AppExitReason.userStopped,
        AppExitReason.lowMemory,
        AppExitReason.signaled,
        AppExitReason.exitSelf,
      ]) {
        final decision = resolveBootDecision(
          record: _starting(failureCount: 1),
          exitInfo: _exit(reason),
          crashReported: true,
        );

        expect(decision.recovery, BootRecovery.none, reason: reason.name);
        expect(decision.failureCount, 0, reason: reason.name);
      }
    });

    test('an already consumed exit record cannot veto or confirm again', () {
      final decision = resolveBootDecision(
        record: _starting(handledExitAt: _startedAt + 600),
        exitInfo: _exit(AppExitReason.userRequested),
        crashReported: false,
      );

      expect(decision.recovery, BootRecovery.skipAutoSetup);
      expect(decision.exitReason, isNull);
    });

    test('an exit older than the interrupted run is ignored', () {
      final decision = resolveBootDecision(
        record: _starting(),
        exitInfo: _exit(AppExitReason.userRequested, timestamp: _startedAt - 1),
        crashReported: false,
      );

      expect(decision.recovery, BootRecovery.skipAutoSetup);
      expect(decision.exitReason, isNull);
    });

    test('a reported crash confirms an interruption it cannot cause', () {
      final skipped = resolveBootDecision(
        record: _starting(),
        exitInfo: null,
        crashReported: true,
      );
      final clean = resolveBootDecision(
        record: const BootRecord(),
        exitInfo: null,
        crashReported: true,
      );

      expect(skipped.crashConfirmed, isTrue);
      expect(skipped.recovery, BootRecovery.skipAutoSetup);
      expect(clean.recovery, BootRecovery.none);
    });
  });
}
