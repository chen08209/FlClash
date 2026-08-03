import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/free_nodes.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@visibleForTesting
String buildFreeNodesStatusText({
  required Profile? profile,
  required FreeNodesProgress? progress,
  required bool isUpdating,
  required int proxyCount,
}) {
  if (buildFreeNodesVisibleUpdating(
    progress: progress,
    isUpdating: isUpdating,
  )) {
    if (progress?.operation == '正在检查更新') return '检查更新中';
    if ((progress?.total ?? 0) > 0) {
      return '已获取 ${progress!.successfulSources}/${progress.total} 源'
          ' · 失败 ${progress.failedSources} 源';
    }
    return '获取中';
  }
  if (progress?.error == true) {
    if ((progress?.total ?? 0) > 0) {
      return '更新失败 · 已获取 ${progress!.successfulSources}/${progress.total} 源'
          ' · 失败 ${progress.failedSources} 源';
    }
    return '更新失败 · $proxyCount 个';
  }
  if (progress?.done == true && (progress?.operation ?? '').isNotEmpty) {
    if ((progress?.total ?? 0) > 0) {
      return '已获取 ${progress!.successfulSources}/${progress.total} 源'
          ' · 失败 ${progress.failedSources} 源 · $proxyCount 个节点';
    }
    return '${progress!.operation} · $proxyCount 个';
  }
  if (profile == null) return '已删除';
  if (proxyCount <= 0) return '未就绪';
  return '已就绪 · $proxyCount 个';
}

@visibleForTesting
int buildFreeNodesProxyCount({
  required Profile? profile,
  required FreeNodesProgress? progress,
  required bool isUpdating,
}) {
  final profileCount = profile?.subscriptionInfo?.total ?? 0;
  final progressCount = progress?.proxyCount ?? 0;
  if (buildFreeNodesVisibleUpdating(
        progress: progress,
        isUpdating: isUpdating,
      ) &&
      progressCount > 0) {
    return progressCount;
  }
  if (profileCount > 0) return profileCount;
  return progressCount;
}

@visibleForTesting
bool buildFreeNodesVisibleUpdating({
  required FreeNodesProgress? progress,
  required bool isUpdating,
}) {
  if (isUpdating) return true;
  if (progress == null) return false;
  if (progress.done || progress.error) return false;
  return progress.startedAt != null;
}

@visibleForTesting
String? buildFreeNodesTimingText({
  required FreeNodesProgress? progress,
  required bool isUpdating,
  DateTime? now,
}) {
  final startedAt = progress?.startedAt;
  if (startedAt == null) return null;
  final current = now ?? DateTime.now();
  final elapsed = current.difference(startedAt);
  final isVisibleUpdating = buildFreeNodesVisibleUpdating(
    progress: progress,
    isUpdating: isUpdating,
  );
  if (isVisibleUpdating) {
    final completed = progress?.completed ?? 0;
    final total = progress?.total ?? 0;
    if (completed > 0 && total > completed && elapsed > Duration.zero) {
      final remaining = Duration(
        milliseconds: (elapsed.inMilliseconds / completed * (total - completed))
            .round(),
      );
      return '预计剩余 ${_formatShortDuration(remaining)} · 已用 ${_formatShortDuration(elapsed)}';
    }
    return '已用 ${_formatShortDuration(elapsed)}';
  }
  final finishedAt = progress?.finishedAt ?? current;
  final used = finishedAt.difference(startedAt);
  if (progress?.error == true) {
    return '失败前用时 ${_formatShortDuration(used)}';
  }
  if (progress?.done == true) {
    return '本次用时 ${_formatShortDuration(used)}';
  }
  return null;
}

@visibleForTesting
String buildFreeNodesDetailText({
  required String lastUpdateText,
  required String nextUpdateText,
  required FreeNodesProgress? progress,
  required bool isUpdating,
}) {
  final isVisibleUpdating = buildFreeNodesVisibleUpdating(
    progress: progress,
    isUpdating: isUpdating,
  );
  if (isVisibleUpdating) {
    return '${_buildVisibleRunningOperation(progress, nextUpdateText)} · $lastUpdateText';
  }
  return '$lastUpdateText · $nextUpdateText';
}

@visibleForTesting
List<String> buildFreeNodesDetailLines({
  required String lastUpdateText,
  required String nextUpdateText,
  required FreeNodesProgress? progress,
  required bool isUpdating,
}) {
  final isVisibleUpdating = buildFreeNodesVisibleUpdating(
    progress: progress,
    isUpdating: isUpdating,
  );
  if (isVisibleUpdating) {
    return [
      '${_buildVisibleRunningOperation(progress, nextUpdateText)} · $lastUpdateText',
    ];
  }
  return [lastUpdateText, nextUpdateText];
}

String _buildVisibleRunningOperation(
  FreeNodesProgress? progress,
  String nextUpdateText,
) {
  if (progress?.operation == '正在检查更新' &&
      (nextUpdateText == '正在检查来源更新时间' || nextUpdateText == '正在检查首次更新')) {
    return nextUpdateText;
  }
  if (progress?.operation == '正在检查更新') {
    if (nextUpdateText == '已到首次更新时间') return '正在首次获取节点';
  }
  return switch (progress?.operation) {
    '正在首次获取节点' => '正在首次获取节点',
    '正在更新到期来源' => '正在更新到期来源',
    '正在检查更新' => '正在检查更新',
    _ => '获取中',
  };
}

@visibleForTesting
String buildFreeNodesNextUpdateText({
  required Profile? profile,
  required List<FreeNodeSourceOption> sourceOptions,
  required Set<String> enabledSourceIds,
  required String Function(DateTime dateTime) formatTime,
  required bool sourceScheduleLoaded,
  DateTime? now,
}) {
  if (profile == null) return '点击恢复并更新';
  final current = now ?? DateTime.now();
  if (profile.lastUpdateDate == null) {
    return sourceScheduleLoaded ? '已到首次更新时间' : '正在检查首次更新';
  }
  if (!sourceScheduleLoaded) return '正在检查来源更新时间';
  return _buildSourceIntervalUpdateText(
    current: current,
    sourceOptions: sourceOptions,
    enabledSourceIds: enabledSourceIds,
    formatTime: formatTime,
  );
}

@visibleForTesting
Future<String> resolveFreeNodesNextUpdateText({
  required Profile? profile,
  required String Function(DateTime dateTime) formatTime,
}) async {
  if (profile == null) {
    return buildFreeNodesNextUpdateText(
      profile: profile,
      sourceOptions: const [],
      enabledSourceIds: const {},
      sourceScheduleLoaded: false,
      formatTime: formatTime,
    );
  }
  final sourceOptions = await freeNodesService.getSourceOptions();
  final enabledSourceIds = await freeNodesService.getEnabledSourceIds();
  return buildFreeNodesNextUpdateText(
    profile: profile,
    sourceOptions: sourceOptions,
    enabledSourceIds: enabledSourceIds,
    sourceScheduleLoaded: true,
    formatTime: formatTime,
  );
}

String _buildSourceIntervalUpdateText({
  required DateTime current,
  required List<FreeNodeSourceOption> sourceOptions,
  required Set<String> enabledSourceIds,
  required String Function(DateTime dateTime) formatTime,
}) {
  DateTime? nextUpdateDate;
  var hasEnabledSource = false;
  for (final option in sourceOptions) {
    if (!enabledSourceIds.contains(option.id)) continue;
    hasEnabledSource = true;
    final lastFetchTime = option.lastFetchTime;
    if (lastFetchTime == null) return '已到来源更新时间';
    final optionNextUpdate = lastFetchTime.add(
      Duration(hours: option.updateIntervalHours),
    );
    if (!optionNextUpdate.isAfter(current)) return '已到来源更新时间';
    if (nextUpdateDate == null || optionNextUpdate.isBefore(nextUpdateDate)) {
      nextUpdateDate = optionNextUpdate;
    }
  }
  if (!hasEnabledSource) return '未启用节点来源';
  if (nextUpdateDate == null) return '来源更新时间不可用';
  return _buildNextUpdateTimeText(
    prefix: '下次来源更新',
    dateTime: nextUpdateDate,
    current: current,
    formatTime: formatTime,
  );
}

String _buildNextUpdateTimeText({
  required String prefix,
  required DateTime dateTime,
  required DateTime current,
  required String Function(DateTime dateTime) formatTime,
}) {
  final remaining = dateTime.difference(current);
  if (remaining <= Duration.zero) return '$prefix ${formatTime(dateTime)}';
  return '$prefix ${formatTime(dateTime)}（剩余${_formatShortDuration(remaining)}）';
}

String _formatShortDuration(Duration duration) {
  final seconds = duration.inSeconds;
  if (seconds <= 0) return '<1秒';
  final minutes = seconds ~/ 60;
  final remainSeconds = seconds % 60;
  if (minutes <= 0) return '$remainSeconds秒';
  if (minutes < 60) {
    return remainSeconds == 0 ? '$minutes分' : '$minutes分$remainSeconds秒';
  }
  final hours = minutes ~/ 60;
  final remainMinutes = minutes % 60;
  return remainMinutes == 0 ? '$hours小时' : '$hours小时$remainMinutes分';
}

class FreeNodesStatus extends ConsumerWidget {
  const FreeNodesStatus({super.key});

  Future<void> _handleUpdate(BuildContext context, WidgetRef ref) async {
    final res = await globalState.showMessage(
      title: freeNodesProfileLabel,
      message: const TextSpan(text: '手动更新免费节点？'),
      confirmText: '更新',
    );
    if (res != true) return;
    await globalState.safeRun(
      () => ref
          .read(profilesActionProvider.notifier)
          .updateFreeNodesProfile(showLoading: true),
      title: freeNodesProfileLabel,
    );
  }

  String _formatTime(DateTime dateTime) {
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$month-$day $hour:$minute';
  }

  String _getNextUpdateText(Profile? profile) {
    return buildFreeNodesNextUpdateText(
      profile: profile,
      sourceOptions: const [],
      enabledSourceIds: const {},
      sourceScheduleLoaded: false,
      formatTime: _formatTime,
    );
  }

  Future<String> _getFreeNodesNextUpdateText(Profile? profile) async {
    return resolveFreeNodesNextUpdateText(
      profile: profile,
      formatTime: _formatTime,
    );
  }

  String _getLastUpdateText(BuildContext context, Profile? profile) {
    final lastUpdateDate = profile?.lastUpdateDate;
    if (lastUpdateDate == null) return '上次更新：无记录';
    return '上次更新：${lastUpdateDate.getLastUpdateTimeDesc(context)}';
  }

  Color _getStatusColor(
    BuildContext context, {
    required Profile? profile,
    required FreeNodesProgress? progress,
    required bool isUpdating,
    required int proxyCount,
  }) {
    final colorScheme = context.colorScheme;
    if (isUpdating) return colorScheme.primary;
    if (progress?.error == true) return colorScheme.error;
    if (progress?.done == true) return Colors.green;
    if (profile == null) return colorScheme.outline;
    if (proxyCount <= 0) return colorScheme.tertiary;
    return Colors.green;
  }

  IconData _getIcon({
    required Profile? profile,
    required FreeNodesProgress? progress,
    required bool isUpdating,
    required int proxyCount,
  }) {
    if (isUpdating) return Icons.sync;
    if (progress?.error == true) return Icons.error_outline;
    if (progress?.done == true) return Icons.check_circle_outline;
    if (profile == null) return Icons.delete_outline;
    if (proxyCount <= 0) return Icons.warning_amber_rounded;
    return Icons.verified_outlined;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(
      profilesProvider.select(
        (profiles) =>
            profiles.firstWhereOrNull((profile) => profile.isFreeNodesProfile),
      ),
    );
    final progressValue = ref.watch(itemProvider(freeNodesProgressKey));
    final progress = progressValue is FreeNodesProgress ? progressValue : null;
    final isUpdating = profile == null
        ? false
        : ref.watch(isUpdatingProvider(profile.updatingKey));
    final isVisibleUpdating = buildFreeNodesVisibleUpdating(
      progress: progress,
      isUpdating: isUpdating,
    );
    final proxyCount = buildFreeNodesProxyCount(
      profile: profile,
      progress: progress,
      isUpdating: isVisibleUpdating,
    );
    final statusColor = _getStatusColor(
      context,
      profile: profile,
      progress: progress,
      isUpdating: isVisibleUpdating,
      proxyCount: proxyCount,
    );
    final icon = _getIcon(
      profile: profile,
      progress: progress,
      isUpdating: isVisibleUpdating,
      proxyCount: proxyCount,
    );
    final statusText = buildFreeNodesStatusText(
      profile: profile,
      progress: progress,
      isUpdating: isVisibleUpdating,
      proxyCount: proxyCount,
    );
    return TickBuilder(
      duration: isVisibleUpdating
          ? const Duration(seconds: 1)
          : const Duration(minutes: 1),
      builder: (context, _) {
        final lastUpdateText = _getLastUpdateText(context, profile);
        final timingText = buildFreeNodesTimingText(
          progress: progress,
          isUpdating: isVisibleUpdating,
        );
        return SizedBox(
          width: double.infinity,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: getWidgetHeight(1.35)),
            child: CommonCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(icon, color: statusColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '免费节点',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.titleSmall?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                              height: 1.0,
                            ),
                          ),
                        ),
                        if (isVisibleUpdating)
                          SizedBox.square(
                            dimension: 16.ap,
                            child: const CommonCircleLoading(),
                          )
                        else
                          Tooltip(
                            message: '手动更新',
                            child: IconButton.filledTonal(
                              onPressed: () => _handleUpdate(context, ref),
                              icon: const Icon(Icons.sync, size: 20),
                              constraints: const BoxConstraints.tightFor(
                                width: 48,
                                height: 48,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    TooltipText(
                      text: Text(
                        statusText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: statusColor,
                          height: 1.08,
                        ),
                      ),
                    ),
                    const SizedBox(height: 1),
                    if (timingText != null) ...[
                      TooltipText(
                        text: Text(
                          timingText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.primary,
                            height: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 1),
                    ],
                    FutureBuilder<String>(
                      future: _getFreeNodesNextUpdateText(profile),
                      initialData: _getNextUpdateText(profile),
                      builder: (context, snapshot) {
                        final nextUpdateText =
                            snapshot.data ?? _getNextUpdateText(profile);
                        final detailLines = buildFreeNodesDetailLines(
                          lastUpdateText: lastUpdateText,
                          nextUpdateText: nextUpdateText,
                          progress: progress,
                          isUpdating: isVisibleUpdating,
                        );
                        return TooltipText(
                          text: Text(
                            detailLines.join('\n'),
                            maxLines: detailLines.length,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                              height: 1.0,
                            ),
                          ),
                        );
                      },
                    ),
                    if (isVisibleUpdating) ...[
                      const SizedBox(height: 3),
                      LinearProgressIndicator(value: progress?.value),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
