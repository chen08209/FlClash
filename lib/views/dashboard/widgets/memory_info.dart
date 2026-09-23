import 'dart:io';
import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/widget_metrics.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class MemorySnapshot {
  const MemorySnapshot({
    this.app = 0,
    this.coreTotal = 0,
    this.core,
    this.coreInProcess = false,
  });

  final int app;
  final int coreTotal;
  final CoreMemoryStats? core;
  final bool coreInProcess;

  int get total => app + coreTotal;

  int get coreOther => max(0, coreTotal - (core?.runtimeTotal ?? 0));

  /// On Android the Core shares the app process, so its runtime accounting is
  /// carved out of the process RSS instead of added on top of it.
  static MemorySnapshot resolve({
    required int rss,
    required CoreMemoryStats? core,
    required bool coreInProcess,
  }) {
    if (core == null) {
      return MemorySnapshot(app: rss, coreInProcess: coreInProcess);
    }
    if (coreInProcess) {
      final runtime = core.runtimeTotal;
      return MemorySnapshot(
        app: max(0, rss - runtime),
        coreTotal: runtime,
        core: core,
        coreInProcess: true,
      );
    }
    return MemorySnapshot(app: rss, coreTotal: core.rss, core: core);
  }
}

class MemoryInfo extends ConsumerStatefulWidget {
  final Future<MemorySnapshot> Function()? memoryReader;

  const MemoryInfo({super.key, @visibleForTesting this.memoryReader});

  @override
  ConsumerState<MemoryInfo> createState() => _MemoryInfoState();
}

class _MemoryInfoState extends ConsumerState<MemoryInfo>
    with WidgetsBindingObserver, ActivePollingMixin<MemoryInfo> {
  final _memoryStateNotifier = ValueNotifier<MemorySnapshot>(
    const MemorySnapshot(),
  );

  CoreController get _core => ref.read(coreHandlerProvider);

  @override
  Duration get pollInterval => const Duration(seconds: 2);

  @override
  void dispose() {
    _memoryStateNotifier.dispose();
    super.dispose();
  }

  @override
  Future<void> poll(PollGuard isCurrent) async {
    final memory = await _readMemory();
    if (memory == null || !isCurrent()) {
      return;
    }
    _memoryStateNotifier.value = memory;
  }

  Future<MemorySnapshot?> _readMemory() async {
    try {
      final memoryReader = widget.memoryReader;
      return memoryReader != null
          ? await memoryReader()
          : await _readSnapshot();
    } catch (error) {
      commonPrint.log(
        'updateMemory error: $error',
        logLevel: coreFailureLogLevel(error),
      );
      return null;
    }
  }

  Future<MemorySnapshot> _readSnapshot() async {
    final rss = ProcessInfo.currentRss;
    final coreConnected = ref.read(coreStatusProvider) == CoreStatus.connected;
    final core = coreConnected ? await _core.getMemoryStats() : null;
    return MemorySnapshot.resolve(
      rss: rss,
      core: core,
      coreInProcess: system.isAndroid,
    );
  }

  Future<int> _releaseMemory() async {
    final before = _memoryStateNotifier.value.total;
    await _core.requestGc();
    final memory = await _readMemory();
    if (memory == null || !mounted) {
      return 0;
    }
    _memoryStateNotifier.value = memory;
    return max(0, before - memory.total);
  }

  void _showDetail() {
    showSheet(
      context: context,
      builder: (_) {
        return MemoryDetailSheet(
          snapshot: _memoryStateNotifier,
          onRelease: _releaseMemory,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return SizedBox(
      height: DashboardWidgetMetrics.heightOf(context, 1),
      child: RepaintBoundary(
        child: CommonCard(
          radius: DashboardWidgetMetrics.radiusOf(context),
          infoPadding: DashboardWidgetMetrics.paddingOf(
            context,
          ).copyWith(bottom: 0),
          info: Info(
            glyph: AppGlyphs.memory,
            label: appLocalizations.memoryInfo,
          ),
          onPressed: _showDetail,
          child: Container(
            padding: DashboardWidgetMetrics.paddingOf(context).copyWith(top: 0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height:
                      globalState.measure.bodyMediumHeight *
                          DashboardWidgetMetrics.textScaleOf(context) +
                      2,
                  child: ValueListenableBuilder(
                    valueListenable: _memoryStateNotifier,
                    builder: (_, memory, _) {
                      final traffic = memory.total.traffic;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            traffic.value,
                            style: context.textTheme.bodyMedium?.toLight
                                .adjustSize(1),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            traffic.unit,
                            style: context.textTheme.bodyMedium?.toLight
                                .adjustSize(1),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MemoryDetailSheet extends StatefulWidget {
  const MemoryDetailSheet({
    super.key,
    required this.snapshot,
    required this.onRelease,
  });

  final ValueListenable<MemorySnapshot> snapshot;

  /// Resolves to the bytes freed.
  final Future<int> Function() onRelease;

  @override
  State<MemoryDetailSheet> createState() => _MemoryDetailSheetState();
}

class _MemoryDetailSheetState extends State<MemoryDetailSheet> {
  static const _minReleaseFeedback = Duration(milliseconds: 500);

  bool _isReleasing = false;

  Future<void> _handleRelease() async {
    if (_isReleasing) {
      return;
    }
    setState(() => _isReleasing = true);
    final appLocalizations = context.appLocalizations;
    String message;
    var level = MessageLevel.success;
    try {
      final (freed, _) = await (
        widget.onRelease(),
        Future<void>.delayed(_minReleaseFeedback),
      ).wait;
      message = freed > 0
          ? appLocalizations.memoryReleasedSize(freed.traffic.show)
          : appLocalizations.memoryReleased;
    } catch (error) {
      commonPrint.log(
        'releaseMemory error: $error',
        logLevel: coreFailureLogLevel(error),
      );
      message = appLocalizations.releaseMemoryFailed;
      level = MessageLevel.error;
    }
    if (!mounted) {
      return;
    }
    setState(() => _isReleasing = false);
    context.showNotifier(message, level: level);
  }

  List<Widget> _appItems(
    AppLocalizations appLocalizations,
    MemorySnapshot snapshot,
  ) {
    return [
      _MemoryRow(
        label: appLocalizations.memoryAppResident,
        bytes: snapshot.app,
        total: snapshot.app,
      ),
    ];
  }

  List<Widget> _coreItems(
    AppLocalizations appLocalizations,
    MemorySnapshot snapshot,
  ) {
    final core = snapshot.core;
    if (core == null) {
      return [ListItem(title: Text(appLocalizations.memoryCoreNotRunning))];
    }
    final total = snapshot.coreTotal;
    return [
      _MemoryRow(
        label: appLocalizations.memoryCoreHeapInuse,
        bytes: core.heapInuse,
        total: total,
      ),
      _MemoryRow(
        label: appLocalizations.memoryCoreHeapIdle,
        bytes: core.heapIdle,
        total: total,
      ),
      _MemoryRow(
        label: appLocalizations.memoryCoreStack,
        bytes: core.stackInuse,
        total: total,
      ),
      _MemoryRow(
        label: appLocalizations.memoryCoreRuntime,
        bytes: core.runtimeOther,
        total: total,
      ),
      if (snapshot.coreOther > 0)
        _MemoryRow(
          label: appLocalizations.other,
          bytes: snapshot.coreOther,
          total: total,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonScaffold(
      title: appLocalizations.memoryInfo,
      actions: [
        AppBarActionButton(
          data: IconButtonData(
            glyph: AppGlyphs.broom,
            tooltip: appLocalizations.releaseMemory,
            isLoading: _isReleasing,
            onPressed: _handleRelease,
          ),
        ),
      ],
      body: ValueListenableBuilder<MemorySnapshot>(
        valueListenable: widget.snapshot,
        builder: (context, snapshot, _) {
          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ).copyWith(top: context.sheetTopPadding, bottom: 20),
            children: [
              _MemoryOverview(snapshot: snapshot),
              _MemorySection(
                title: snapshot.coreInProcess
                    ? appLocalizations.memoryAppShared
                    : appLocalizations.app,
                bytes: snapshot.app,
                items: _appItems(appLocalizations, snapshot),
              ),
              _MemorySection(
                title: appLocalizations.core,
                bytes: snapshot.coreTotal,
                contentKey: ValueKey(snapshot.core != null),
                items: _coreItems(appLocalizations, snapshot),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MemorySection extends StatelessWidget {
  const _MemorySection({
    required this.title,
    required this.bytes,
    required this.items,
    this.contentKey,
  });

  final String title;
  final int bytes;
  final List<Widget> items;

  /// A change cross-fades the rows instead of swapping them in place.
  final Key? contentKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListHeader(
          title: title,
          actions: [
            Text(
              bytes.traffic.show,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.outline,
              ),
            ),
          ],
        ),
        AnimatedSize(
          alignment: Alignment.topCenter,
          duration: context.motionDuration(commonDuration),
          curve: Easing.standard,
          child: FadeThroughBox(
            alignment: Alignment.topCenter,
            child: KeyedSubtree(
              key: contentKey,
              child: generateSectionV2(items: items),
            ),
          ),
        ),
      ],
    );
  }
}

class _MemoryOverview extends StatelessWidget {
  const _MemoryOverview({required this.snapshot});

  /// The optical edge of the xl-radius cards, not their geometric one.
  static const _inset = 5.0;

  final MemorySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final total = snapshot.total.traffic;
    return Padding(
      padding: const EdgeInsets.fromLTRB(_inset, 8, _inset, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appLocalizations.total,
            style: context.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                total.value,
                style: context.textTheme.headlineMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                total.unit,
                style: context.textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary.opacity80,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MemoryBar(
            segments: [
              (bytes: snapshot.app, color: colorScheme.primary),
              (bytes: snapshot.coreTotal, color: colorScheme.tertiary),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            snapshot.coreInProcess
                ? appLocalizations.memoryEstimateSharedDesc
                : appLocalizations.memoryEstimateDesc,
            style: context.textTheme.bodySmall?.copyWith(
              color: colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _MemoryBar extends StatelessWidget {
  const _MemoryBar({required this.segments});

  static const _gap = 2.0;

  final List<({int bytes, Color color})> segments;

  @override
  Widget build(BuildContext context) {
    final duration = context.motionDuration(commonDuration);
    final isEmpty = segments.every((segment) => segment.bytes <= 0);
    return ClipRSuperellipse(
      borderRadius: AppRadius.full,
      child: SizedBox(
        height: 8,
        child: isEmpty
            ? ColoredBox(color: context.colorScheme.primary.opacity15)
            : Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (index, segment) in segments.indexed) ...[
                    if (index > 0)
                      AnimatedContainer(
                        duration: duration,
                        curve: Easing.standard,
                        width:
                            segment.bytes > 0 &&
                                segments
                                    .take(index)
                                    .any((previous) => previous.bytes > 0)
                            ? _gap
                            : 0,
                      ),
                    TweenAnimationBuilder<double>(
                      tween: Tween(end: segment.bytes.toDouble()),
                      duration: duration,
                      curve: Easing.standard,
                      builder: (_, bytes, child) =>
                          Expanded(flex: bytes.round(), child: child!),
                      child: ColoredBox(color: segment.color),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _MemoryRow extends StatelessWidget {
  const _MemoryRow({
    required this.label,
    required this.bytes,
    required this.total,
  });

  final String label;
  final int bytes;
  final int total;

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0 : bytes * 100 / total;
    return ListItem(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 20,
        children: [
          Flexible(child: Text(label)),
          Text(
            '${percent.fixed(decimals: 1)}%',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
