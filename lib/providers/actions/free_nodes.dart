part of '../action.dart';

@visibleForTesting
enum FreeNodesAutoUpdateKind { firstFetch, dueSources, checkOnly }

@visibleForTesting
class FreeNodesAutoUpdateDecision {
  final FreeNodesAutoUpdateKind kind;

  const FreeNodesAutoUpdateDecision(this.kind);

  bool get shouldUpdate => kind != FreeNodesAutoUpdateKind.checkOnly;

  String get operation => switch (kind) {
    FreeNodesAutoUpdateKind.firstFetch => '正在首次获取节点',
    FreeNodesAutoUpdateKind.dueSources => '正在更新到期来源',
    FreeNodesAutoUpdateKind.checkOnly => '正在检查更新',
  };
}

@visibleForTesting
bool shouldPersistProfileBeforeRemoteUpdate(Profile profile) {
  return !profile.isFreeNodesProfile;
}

@visibleForTesting
bool shouldCheckFreeNodesAutoUpdateOnProfileSelection({
  required int? currentProfileId,
  required int selectedProfileId,
  required bool isFreeNodesProfile,
  required bool autoUpdate,
}) {
  return currentProfileId != selectedProfileId &&
      isFreeNodesProfile &&
      autoUpdate;
}

@visibleForTesting
FreeNodesAutoUpdateDecision resolveFreeNodesAutoUpdateDecision({
  required bool fileExists,
  required bool hasLastUpdateDate,
  required bool hasDueSources,
  bool hasInterruptedSession = false,
}) {
  if (hasInterruptedSession || !fileExists || !hasLastUpdateDate) {
    return const FreeNodesAutoUpdateDecision(
      FreeNodesAutoUpdateKind.firstFetch,
    );
  }
  return FreeNodesAutoUpdateDecision(
    hasDueSources
        ? FreeNodesAutoUpdateKind.dueSources
        : FreeNodesAutoUpdateKind.checkOnly,
  );
}

@visibleForTesting
bool shouldAutoUpdateFreeNodesProfile({
  required bool fileExists,
  required bool hasLastUpdateDate,
  required bool hasDueSources,
  bool hasInterruptedSession = false,
}) {
  return resolveFreeNodesAutoUpdateDecision(
    fileExists: fileExists,
    hasLastUpdateDate: hasLastUpdateDate,
    hasDueSources: hasDueSources,
    hasInterruptedSession: hasInterruptedSession,
  ).shouldUpdate;
}

@visibleForTesting
bool shouldApplyCurrentFreeNodesProfileAfterNoopAutoUpdate({
  required bool isCurrentProfile,
  required bool shouldUpdate,
  required bool hasLoadedGroups,
}) {
  return isCurrentProfile && !shouldUpdate && !hasLoadedGroups;
}

@visibleForTesting
FreeNodesProgress buildFreeNodesAutoUpdateStartProgress({
  required bool firstLaunch,
  required int proxyCount,
  bool resuming = false,
}) {
  return FreeNodesProgress(
    operation: resuming
        ? '正在继续上次获取'
        : firstLaunch
        ? '正在首次获取节点'
        : '正在检查更新',
    proxyCount: proxyCount,
    startedAt: DateTime.now(),
  );
}

@visibleForTesting
FreeNodesProgress buildFreeNodesAutoUpdateRunningProgress({
  required int proxyCount,
  FreeNodesProgress? currentProgress,
  DateTime? startedAt,
  bool preserveTerminalProgress = false,
}) {
  if (preserveTerminalProgress &&
      currentProgress != null &&
      (currentProgress.done || currentProgress.error)) {
    return currentProgress;
  }
  if (currentProgress != null &&
      !currentProgress.done &&
      !currentProgress.error &&
      currentProgress.startedAt != null) {
    return currentProgress.copyWith(
      proxyCount: currentProgress.proxyCount > 0
          ? currentProgress.proxyCount
          : proxyCount,
    );
  }
  return FreeNodesProgress(
    operation: '正在检查更新',
    proxyCount: proxyCount,
    startedAt: startedAt ?? DateTime.now(),
  );
}

@visibleForTesting
FreeNodesProgress buildFreeNodesAutoUpdateNoopProgress({
  required int proxyCount,
  required DateTime startedAt,
  DateTime? finishedAt,
}) {
  return FreeNodesProgress(
    operation: '已检查，无需更新',
    proxyCount: proxyCount,
    done: true,
    startedAt: startedAt,
    finishedAt: finishedAt ?? DateTime.now(),
  );
}

@visibleForTesting
FreeNodesProgress buildFreeNodesAutoUpdateFetchProgress({
  required FreeNodesProgress progress,
  required String runningOperation,
  required DateTime startedAt,
  required int proxyCount,
}) {
  if (progress.done || progress.error) {
    return progress.copyWith(
      proxyCount: progress.proxyCount > 0 ? progress.proxyCount : proxyCount,
      startedAt: startedAt,
      finishedAt: progress.finishedAt ?? DateTime.now(),
    );
  }
  return progress.copyWith(
    operation: runningOperation,
    proxyCount: progress.proxyCount > 0 ? progress.proxyCount : proxyCount,
    startedAt: startedAt,
  );
}

@visibleForTesting
Duration remainingFreeNodesAutoUpdateVisibleDelay({
  required DateTime startedAt,
  DateTime? now,
  Duration minVisibleDuration = const Duration(milliseconds: 1200),
}) {
  final elapsed = (now ?? DateTime.now()).difference(startedAt);
  if (elapsed >= minVisibleDuration) return Duration.zero;
  return minVisibleDuration - elapsed;
}

@visibleForTesting
bool shouldScheduleDeferredFreeNodesResume({
  required bool initialized,
  required bool hasInterruptedSession,
}) {
  return initialized && hasInterruptedSession;
}
