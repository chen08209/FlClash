import 'dart:async';

import 'package:fl_clash/common/free_nodes.dart';
import 'package:fl_clash/common/preferences.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/views/dashboard/widgets/free_nodes_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

FreeNodeSourceOption _sourceOption({
  required String id,
  required int intervalHours,
  DateTime? lastFetchTime,
}) {
  return FreeNodeSourceOption(
    id: id,
    label: id,
    seed: 'https://$id.example.com/',
    updateIntervalHours: intervalHours,
    staleTimeoutHours: 36,
    fetchTimeoutSeconds: 10,
    lastFetchTime: lastFetchTime,
  );
}

String _formatTime(DateTime dateTime) {
  return '${dateTime.month.toString().padLeft(2, '0')}-'
      '${dateTime.day.toString().padLeft(2, '0')} '
      '${dateTime.hour.toString().padLeft(2, '0')}:'
      '${dateTime.minute.toString().padLeft(2, '0')}';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('shows completed auto-check result instead of generic ready state', () {
    final text = buildFreeNodesStatusText(
      profile: freeNodesService.createProfile(),
      progress: const FreeNodesProgress(
        operation: '已检查，无需更新',
        proxyCount: 5555,
        done: true,
      ),
      isUpdating: false,
      proxyCount: 5555,
    );

    expect(text, '已检查，无需更新 · 5555 个');
  });

  test('uses profile proxy count after completed progress becomes stale', () {
    final count = buildFreeNodesProxyCount(
      profile: freeNodesService.createProfile().copyWith(
        subscriptionInfo: const SubscriptionInfo(total: 6000),
      ),
      progress: const FreeNodesProgress(
        operation: '已检查，无需更新',
        proxyCount: 5555,
        done: true,
      ),
      isUpdating: false,
    );

    expect(count, 6000);
  });

  test('uses progress proxy count while update is running', () {
    final count = buildFreeNodesProxyCount(
      profile: freeNodesService.createProfile().copyWith(
        subscriptionInfo: const SubscriptionInfo(total: 5000),
      ),
      progress: const FreeNodesProgress(
        operation: '正在更新到期来源',
        proxyCount: 5555,
      ),
      isUpdating: true,
    );

    expect(count, 5555);
  });

  test('shows source-level progress during first Rust fetch', () {
    final text = buildFreeNodesStatusText(
      profile: freeNodesService.createProfile(),
      progress: const FreeNodesProgress(
        operation: 'Rust 高并发获取免费节点',
        completed: 0,
        total: 128,
      ),
      isUpdating: true,
      proxyCount: 0,
    );

    expect(text, '已获取 0/128 源 · 失败 0 源');
  });

  test('startup due check is not presented as a node fetch', () {
    final text = buildFreeNodesStatusText(
      profile: freeNodesService.createProfile().copyWith(
        subscriptionInfo: const SubscriptionInfo(total: 5555),
      ),
      progress: FreeNodesProgress(
        operation: '正在检查更新',
        proxyCount: 5555,
        startedAt: DateTime(2026, 6, 19, 12),
      ),
      isUpdating: true,
      proxyCount: 5555,
    );

    expect(text, '检查更新中');
  });

  test('shows fetching while automatic first launch progress is checking', () {
    final startedAt = DateTime(2026, 6, 19, 12);
    final progress = FreeNodesProgress(
      operation: '正在首次获取节点',
      startedAt: startedAt,
      proxyCount: 0,
    );

    expect(
      buildFreeNodesVisibleUpdating(progress: progress, isUpdating: false),
      isTrue,
    );
    expect(
      buildFreeNodesStatusText(
        profile: freeNodesService.createProfile(),
        progress: progress,
        isUpdating: false,
        proxyCount: 0,
      ),
      '获取中',
    );
  });

  test('uses due-source progress count before updating flag flips', () {
    final startedAt = DateTime(2026, 6, 19, 12);
    final profile = freeNodesService.createProfile().copyWith(
      subscriptionInfo: const SubscriptionInfo(total: 5000),
    );
    final progress = FreeNodesProgress(
      operation: '正在更新到期来源',
      startedAt: startedAt,
      proxyCount: 5555,
    );

    expect(
      buildFreeNodesProxyCount(
        profile: profile,
        progress: progress,
        isUpdating: false,
      ),
      5555,
    );
  });

  test('uses real zero progress before the first source returns', () {
    const progress = FreeNodesProgress(
      operation: 'Rust 高并发获取免费节点',
      completed: 0,
      total: 128,
    );

    expect(progress.value, 0);
  });

  test('shows successful and failed source counts while fetching', () {
    final text = buildFreeNodesStatusText(
      profile: freeNodesService.createProfile(),
      progress: const FreeNodesProgress(
        operation: '获取中',
        completed: 7,
        total: 10,
        successfulSources: 5,
        failedSources: 2,
      ),
      isUpdating: true,
      proxyCount: 120,
    );

    expect(text, '已获取 5/10 源 · 失败 2 源');
  });

  test('keeps source result counts after fetching completes', () {
    final text = buildFreeNodesStatusText(
      profile: freeNodesService.createProfile(),
      progress: const FreeNodesProgress(
        operation: '已完成',
        completed: 10,
        total: 10,
        successfulSources: 8,
        failedSources: 2,
        done: true,
      ),
      isUpdating: false,
      proxyCount: 320,
    );

    expect(text, '已获取 8/10 源 · 失败 2 源 · 320 个节点');
  });

  test('shows remaining estimate while updating', () {
    final startedAt = DateTime(2026, 6, 19, 12);
    final text = buildFreeNodesTimingText(
      progress: FreeNodesProgress(
        operation: 'Rust 高并发获取免费节点',
        completed: 25,
        total: 100,
        startedAt: startedAt,
      ),
      isUpdating: true,
      now: startedAt.add(const Duration(seconds: 20)),
    );

    expect(text, '预计剩余 1分 · 已用 20秒');
  });

  test(
    'shows remaining estimate for visible automatic progress before updating flag flips',
    () {
      final startedAt = DateTime(2026, 6, 19, 12);
      final text = buildFreeNodesTimingText(
        progress: FreeNodesProgress(
          operation: '正在更新到期来源',
          completed: 25,
          total: 100,
          startedAt: startedAt,
        ),
        isUpdating: false,
        now: startedAt.add(const Duration(seconds: 20)),
      );

      expect(text, '预计剩余 1分 · 已用 20秒');
    },
  );

  test('shows actual used time after update finishes', () {
    final startedAt = DateTime(2026, 6, 19, 12);
    final text = buildFreeNodesTimingText(
      progress: FreeNodesProgress(
        operation: '已完成',
        done: true,
        startedAt: startedAt,
        finishedAt: startedAt.add(const Duration(minutes: 2, seconds: 5)),
      ),
      isUpdating: false,
      now: startedAt.add(const Duration(minutes: 3)),
    );

    expect(text, '本次用时 2分5秒');
  });

  test('shows actual used time after no-op automatic check finishes', () {
    final startedAt = DateTime(2026, 6, 19, 12);
    final text = buildFreeNodesTimingText(
      progress: FreeNodesProgress(
        operation: '已检查，无需更新',
        done: true,
        startedAt: startedAt,
        finishedAt: startedAt.add(const Duration(seconds: 3)),
      ),
      isUpdating: false,
      now: startedAt.add(const Duration(minutes: 1)),
    );

    expect(text, '本次用时 3秒');
  });

  test('shows automatic update detail while hiding technical Rust wording', () {
    final text = buildFreeNodesDetailText(
      lastUpdateText: '上次更新：无记录',
      nextUpdateText: '等待首次更新',
      progress: const FreeNodesProgress(operation: 'Rust 高并发获取免费节点'),
      isUpdating: true,
    );

    expect(text, '获取中 · 上次更新：无记录');
  });

  test('shows due source update in the detail line', () {
    final text = buildFreeNodesDetailText(
      lastUpdateText: '上次更新：4小时前',
      nextUpdateText: '已到来源更新时间',
      progress: const FreeNodesProgress(operation: '正在更新到期来源'),
      isUpdating: true,
    );

    expect(text, '正在更新到期来源 · 上次更新：4小时前');
  });

  test('shows due source detail before updating flag flips', () {
    final text = buildFreeNodesDetailText(
      lastUpdateText: '上次更新：4小时前',
      nextUpdateText: '已到来源更新时间',
      progress: FreeNodesProgress(
        operation: '正在更新到期来源',
        startedAt: DateTime(2026, 6, 19, 12),
      ),
      isUpdating: false,
    );

    expect(text, '正在更新到期来源 · 上次更新：4小时前');
  });

  test('shows source schedule check while automatic decision is loading', () {
    final text = buildFreeNodesDetailText(
      lastUpdateText: '上次更新：昨天',
      nextUpdateText: '正在检查来源更新时间',
      progress: FreeNodesProgress(
        operation: '正在检查更新',
        startedAt: DateTime(2026, 6, 19, 12),
      ),
      isUpdating: true,
    );

    expect(text, '正在检查来源更新时间 · 上次更新：昨天');
  });

  test('shows specific first check while automatic decision is loading', () {
    final text = buildFreeNodesDetailText(
      lastUpdateText: '上次更新：无记录',
      nextUpdateText: '正在检查首次更新',
      progress: FreeNodesProgress(
        operation: '正在检查更新',
        startedAt: DateTime(2026, 6, 19, 12),
      ),
      isUpdating: true,
    );

    expect(text, '正在检查首次更新 · 上次更新：无记录');
  });

  test(
    'shows first fetch when checking progress resolves first update due',
    () {
      final text = buildFreeNodesDetailText(
        lastUpdateText: '上次更新：无记录',
        nextUpdateText: '已到首次更新时间',
        progress: FreeNodesProgress(
          operation: '正在检查更新',
          startedAt: DateTime(2026, 6, 19, 12),
        ),
        isUpdating: true,
      );

      expect(text, '正在首次获取节点 · 上次更新：无记录');
    },
  );

  test('shows first-launch auto-update reason in running detail', () {
    final text = buildFreeNodesDetailText(
      lastUpdateText: '上次更新：无记录',
      nextUpdateText: '已到首次更新时间',
      progress: FreeNodesProgress(
        operation: '正在首次获取节点',
        startedAt: DateTime(2026, 6, 19, 12),
      ),
      isUpdating: true,
    );

    expect(text, '正在首次获取节点 · 上次更新：无记录');
  });

  test('hides technical running detail operation text', () {
    final text = buildFreeNodesDetailText(
      lastUpdateText: '上次更新：无记录',
      nextUpdateText: '已到首次更新时间',
      progress: FreeNodesProgress(
        operation: 'Rust 高并发获取免费节点',
        startedAt: DateTime(2026, 6, 19, 12),
      ),
      isUpdating: true,
    );

    expect(text, '获取中 · 上次更新：无记录');
  });

  test('keeps next update detail after updating finishes', () {
    final text = buildFreeNodesDetailText(
      lastUpdateText: '上次更新：刚刚',
      nextUpdateText: '下次来源更新 06-20 00:00（剩余12小时）',
      progress: const FreeNodesProgress(operation: '已完成', done: true),
      isUpdating: false,
    );

    expect(text, '上次更新：刚刚 · 下次来源更新 06-20 00:00（剩余12小时）');
  });

  test('splits completed free node detail into two visible card lines', () {
    final lines = buildFreeNodesDetailLines(
      lastUpdateText: '上次更新：刚刚',
      nextUpdateText: '下次来源更新 06-20 00:00（剩余12小时）',
      progress: const FreeNodesProgress(operation: '已完成', done: true),
      isUpdating: false,
    );

    expect(lines, ['上次更新：刚刚', '下次来源更新 06-20 00:00（剩余12小时）']);
  });

  test('keeps running free node detail on one visible card line', () {
    final lines = buildFreeNodesDetailLines(
      lastUpdateText: '上次更新：昨天',
      nextUpdateText: '已到来源更新时间',
      progress: FreeNodesProgress(
        operation: '正在更新到期来源',
        startedAt: DateTime(2026, 6, 19, 12),
      ),
      isUpdating: false,
    );

    expect(lines, ['正在更新到期来源 · 上次更新：昨天']);
  });

  test(
    'crossing a calendar day does not force an update before source due',
    () {
      final now = DateTime(2026, 6, 19, 12);
      final text = buildFreeNodesNextUpdateText(
        profile: freeNodesService.createProfile().copyWith(
          lastUpdateDate: DateTime(2026, 6, 18, 23),
        ),
        sourceOptions: [
          _sourceOption(
            id: 'daily-source',
            intervalHours: 24,
            lastFetchTime: DateTime(2026, 6, 18, 20),
          ),
        ],
        enabledSourceIds: const {'daily-source'},
        sourceScheduleLoaded: true,
        formatTime: _formatTime,
        now: now,
      );

      expect(text, '下次来源更新 06-19 20:00（剩余8小时）');
    },
  );

  test('shows a 24-hour source due from its own last fetch time', () {
    final now = DateTime(2026, 6, 19, 12);
    final text = buildFreeNodesNextUpdateText(
      profile: freeNodesService.createProfile().copyWith(
        lastUpdateDate: DateTime(2026, 6, 19, 1),
      ),
      sourceOptions: [
        _sourceOption(
          id: 'daily-source',
          intervalHours: 24,
          lastFetchTime: DateTime(2026, 6, 18, 11),
        ),
      ],
      enabledSourceIds: const {'daily-source'},
      sourceScheduleLoaded: true,
      formatTime: _formatTime,
      now: now,
    );

    expect(text, '已到来源更新时间');
  });

  test('shows due source from its own interval', () {
    final now = DateTime(2026, 6, 19, 12);
    final text = buildFreeNodesNextUpdateText(
      profile: freeNodesService.createProfile().copyWith(
        lastUpdateDate: DateTime(2026, 6, 19, 1),
      ),
      sourceOptions: [
        _sourceOption(
          id: 'short',
          intervalHours: 6,
          lastFetchTime: DateTime(2026, 6, 19, 5),
        ),
      ],
      enabledSourceIds: const {'short'},
      sourceScheduleLoaded: true,
      formatTime: _formatTime,
      now: now,
    );

    expect(text, '已到来源更新时间');
  });

  test('shows next short interval update time', () {
    final now = DateTime(2026, 6, 19, 12);
    final text = buildFreeNodesNextUpdateText(
      profile: freeNodesService.createProfile().copyWith(
        lastUpdateDate: DateTime(2026, 6, 19, 1),
      ),
      sourceOptions: [
        _sourceOption(
          id: 'short',
          intervalHours: 6,
          lastFetchTime: DateTime(2026, 6, 19, 10),
        ),
      ],
      enabledSourceIds: const {'short'},
      sourceScheduleLoaded: true,
      formatTime: _formatTime,
      now: now,
    );

    expect(text, '下次来源更新 06-19 16:00（剩余4小时）');
  });

  test('shows unavailable state when no source is enabled', () {
    final now = DateTime(2026, 6, 19, 12);
    final text = buildFreeNodesNextUpdateText(
      profile: freeNodesService.createProfile().copyWith(
        lastUpdateDate: DateTime(2026, 6, 19, 1),
      ),
      sourceOptions: const [],
      enabledSourceIds: const {},
      sourceScheduleLoaded: true,
      formatTime: _formatTime,
      now: now,
    );

    expect(text, '未启用节点来源');
  });

  test('shows source schedule check while source options are loading', () {
    final now = DateTime(2026, 6, 19, 12);
    final text = buildFreeNodesNextUpdateText(
      profile: freeNodesService.createProfile().copyWith(
        lastUpdateDate: DateTime(2026, 6, 19, 1),
      ),
      sourceOptions: const [],
      enabledSourceIds: const {},
      sourceScheduleLoaded: false,
      formatTime: _formatTime,
      now: now,
    );

    expect(text, '正在检查来源更新时间');
  });

  test('shows first update check while preferences are still loading', () {
    final now = DateTime(2026, 6, 19, 12);
    final text = buildFreeNodesNextUpdateText(
      profile: freeNodesService.createProfile(),
      sourceOptions: const [],
      enabledSourceIds: const {},
      sourceScheduleLoaded: false,
      formatTime: _formatTime,
      now: now,
    );

    expect(text, '正在检查首次更新');
  });

  test('shows first update due instead of waiting after preferences load', () {
    final now = DateTime(2026, 6, 19, 12);
    final text = buildFreeNodesNextUpdateText(
      profile: freeNodesService.createProfile(),
      sourceOptions: const [],
      enabledSourceIds: const {},
      sourceScheduleLoaded: true,
      formatTime: _formatTime,
      now: now,
    );

    expect(text, '已到首次更新时间');
  });

  test('resolves first update due after preferences load', () async {
    await preferences.isInit;
    SharedPreferences.setMockInitialValues({});
    preferences.sharedPreferencesCompleter = Completer<SharedPreferences?>()
      ..complete(await SharedPreferences.getInstance());

    final text = await resolveFreeNodesNextUpdateText(
      profile: freeNodesService.createProfile(),
      formatTime: _formatTime,
    );

    expect(text, '已到首次更新时间');
  });
}
