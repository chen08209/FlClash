import 'dart:math';

import 'package:fl_clash/common/boot_record.dart';
import 'package:fl_clash/common/preferences.dart';
import 'package:fl_clash/common/print.dart';
import 'package:fl_clash/common/system.dart';
import 'package:fl_clash/enum/enum.dart';

class BootGuard {
  final bool _supported;
  final Future<BootRecord?> Function() _readRecord;
  final Future<void> Function(BootRecord record) _writeRecord;
  final Future<AppExitInfo?> Function() _readExitInfo;
  final int Function() _now;

  BootDecision _decision = const BootDecision();

  BootGuard({
    bool? supported,
    Future<BootRecord?> Function()? readRecord,
    Future<void> Function(BootRecord record)? writeRecord,
    Future<AppExitInfo?> Function()? readExitInfo,
    int Function()? now,
  }) : _supported = supported ?? system.isAndroid,
       _readRecord = readRecord ?? preferences.getBootRecord,
       _writeRecord = writeRecord ?? preferences.saveBootRecord,
       _readExitInfo = readExitInfo ?? system.lastExitInfo,
       _now = now ?? _currentMilliseconds;

  static int _currentMilliseconds() => DateTime.now().millisecondsSinceEpoch;

  BootDecision get decision => _decision;

  Future<BootDecision> evaluate({required int? profileId}) async {
    if (!_supported) {
      return _decision;
    }
    final record = await _readRecord();
    final exitInfo = await _readExitInfo();
    final decision = resolveBootDecision(record: record, exitInfo: exitInfo);
    if (decision.isDegraded) {
      commonPrint.log(
        'Previous launch did not finish: $decision',
        logLevel: LogLevel.warning,
      );
    }
    await _writeRecord(
      BootRecord(
        stage: BootStage.starting,
        profileId: decision.recovery == BootRecovery.clearProfile
            ? null
            : profileId,
        startedAt: _now(),
        failureCount: decision.failureCount,
        lastFailedProfileId:
            decision.failedProfileId ?? record?.lastFailedProfileId,
        handledExitAt: max(
          record?.handledExitAt ?? 0,
          exitInfo?.timestamp ?? 0,
        ),
      ),
    );
    _decision = decision;
    return decision;
  }

  Future<void> markRunning() async {
    if (!_supported) {
      return;
    }
    final record = await _readRecord();
    if (record == null) {
      return;
    }
    await _writeRecord(
      BootRecord(
        stage: BootStage.running,
        profileId: record.profileId,
        startedAt: record.startedAt,
        failureCount: _decision.isDegraded ? record.failureCount : 0,
        lastFailedProfileId: record.lastFailedProfileId,
        handledExitAt: record.handledExitAt,
      ),
    );
  }

  Future<void> markClosed() async {
    if (!_supported) {
      return;
    }
    final record = await _readRecord();
    if (record == null) {
      return;
    }
    await _writeRecord(
      BootRecord(
        profileId: record.profileId,
        startedAt: record.startedAt,
        lastFailedProfileId: record.lastFailedProfileId,
        handledExitAt: record.handledExitAt,
      ),
    );
  }
}

final bootGuard = BootGuard();
