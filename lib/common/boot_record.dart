const crashRecoveryClearThreshold = 2;

enum AppExitReason {
  unknown,
  exitSelf,
  signaled,
  lowMemory,
  crash,
  crashNative,
  anr,
  initializationFailure,
  permissionChange,
  excessiveResourceUsage,
  userRequested,
  userStopped,
  dependencyDied,
  other,
  freezer,
  packageStateChange,
  packageUpdated;

  static AppExitReason fromCode(Object? code) => switch (code) {
    1 => exitSelf,
    2 => signaled,
    3 => lowMemory,
    4 => crash,
    5 => crashNative,
    6 => anr,
    7 => initializationFailure,
    8 => permissionChange,
    9 => excessiveResourceUsage,
    10 => userRequested,
    11 => userStopped,
    12 => dependencyDied,
    13 => other,
    14 => freezer,
    15 => packageStateChange,
    16 => packageUpdated,
    _ => unknown,
  };

  bool get isCrash => switch (this) {
    crash || crashNative || anr || initializationFailure => true,
    _ => false,
  };

  bool get isExternalStop => switch (this) {
    exitSelf ||
    signaled ||
    lowMemory ||
    permissionChange ||
    excessiveResourceUsage ||
    userRequested ||
    userStopped ||
    dependencyDied ||
    freezer ||
    packageStateChange ||
    packageUpdated => true,
    _ => false,
  };
}

class AppExitInfo {
  final AppExitReason reason;
  final int timestamp;
  final String? description;

  const AppExitInfo({
    required this.reason,
    required this.timestamp,
    this.description,
  });

  static AppExitInfo? fromJson(Object? json) {
    if (json is! Map) {
      return null;
    }
    final timestamp = json['timestamp'];
    if (timestamp is! int) {
      return null;
    }
    final description = json['description'];
    return AppExitInfo(
      reason: AppExitReason.fromCode(json['reason']),
      timestamp: timestamp,
      description: description is String ? description : null,
    );
  }

  @override
  String toString() =>
      'AppExitInfo(${reason.name}, $timestamp, ${description ?? '-'})';
}

enum BootStage { starting, running }

class BootRecord {
  final BootStage? stage;
  final int? profileId;
  final int startedAt;
  final int failureCount;
  final int? lastFailedProfileId;
  final int handledExitAt;

  const BootRecord({
    this.stage,
    this.profileId,
    this.startedAt = 0,
    this.failureCount = 0,
    this.lastFailedProfileId,
    this.handledExitAt = 0,
  });

  static BootRecord? fromJson(Object? json) {
    if (json is! Map) {
      return null;
    }
    final stage = json['stage'];
    return BootRecord(
      stage: BootStage.values.where((value) => value.name == stage).firstOrNull,
      profileId: json['profileId'] is int ? json['profileId'] as int : null,
      startedAt: json['startedAt'] is int ? json['startedAt'] as int : 0,
      failureCount: json['failureCount'] is int
          ? json['failureCount'] as int
          : 0,
      lastFailedProfileId: json['lastFailedProfileId'] is int
          ? json['lastFailedProfileId'] as int
          : null,
      handledExitAt: json['handledExitAt'] is int
          ? json['handledExitAt'] as int
          : 0,
    );
  }

  Map<String, Object?> toJson() => {
    'stage': stage?.name,
    'profileId': profileId,
    'startedAt': startedAt,
    'failureCount': failureCount,
    'lastFailedProfileId': lastFailedProfileId,
    'handledExitAt': handledExitAt,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BootRecord &&
          other.stage == stage &&
          other.profileId == profileId &&
          other.startedAt == startedAt &&
          other.failureCount == failureCount &&
          other.lastFailedProfileId == lastFailedProfileId &&
          other.handledExitAt == handledExitAt;

  @override
  int get hashCode => Object.hash(
    stage,
    profileId,
    startedAt,
    failureCount,
    lastFailedProfileId,
    handledExitAt,
  );

  @override
  String toString() =>
      'BootRecord(${stage?.name ?? 'closed'}, profile: $profileId, '
      'failures: $failureCount)';
}

enum BootRecovery { none, skipAutoSetup, clearProfile }

class BootDecision {
  final BootRecovery recovery;
  final int failureCount;
  final int? failedProfileId;
  final bool crashConfirmed;
  final AppExitReason? exitReason;

  const BootDecision({
    this.recovery = BootRecovery.none,
    this.failureCount = 0,
    this.failedProfileId,
    this.crashConfirmed = false,
    this.exitReason,
  });

  bool get isDegraded => recovery != BootRecovery.none;

  @override
  String toString() =>
      'BootDecision(${recovery.name}, failures: $failureCount, '
      'profile: $failedProfileId, confirmed: $crashConfirmed, '
      'exit: ${exitReason?.name ?? '-'})';
}

BootDecision resolveBootDecision({
  required BootRecord? record,
  required AppExitInfo? exitInfo,
  required bool crashReported,
}) {
  if (record == null || record.stage != BootStage.starting) {
    return const BootDecision();
  }
  final matchesLastRun =
      exitInfo != null &&
      exitInfo.timestamp > record.handledExitAt &&
      exitInfo.timestamp >= record.startedAt;
  final reason = matchesLastRun ? exitInfo.reason : null;
  if (reason != null && reason.isExternalStop) {
    return BootDecision(exitReason: reason);
  }
  final failureCount = record.failureCount + 1;
  final shouldClear =
      failureCount >= crashRecoveryClearThreshold && record.profileId != null;
  return BootDecision(
    recovery: shouldClear
        ? BootRecovery.clearProfile
        : BootRecovery.skipAutoSetup,
    failureCount: failureCount,
    failedProfileId: record.profileId,
    crashConfirmed: (reason?.isCrash ?? false) || crashReported,
    exitReason: reason,
  );
}
