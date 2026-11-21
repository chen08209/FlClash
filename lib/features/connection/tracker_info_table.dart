import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';

import 'tracker_info_item.dart';
import 'tracker_selection.dart';

const _ruleTableWidth = 880.0;
const _durationTableWidth = 800.0;
const _timeTableWidth = 760.0;

/// A table this wide shows every column; narrower, it gives up the rule,
/// then the duration, then the time.
List<RecordColumn<TrackerInfo>> trackerInfoColumns(
  BuildContext context, {
  required double width,
}) {
  final appLocalizations = context.appLocalizations;
  TableColumn fixed(
    String id,
    String label,
    double width, {
    bool end = false,
  }) => TableColumn(
    id,
    label,
    width: max(width, recordHeaderWidth(context, label)),
    end: end,
  );
  return [
    if (width >= _timeTableWidth)
      RecordColumn(
        fixed('time', appLocalizations.time, 96),
        cell: (_, info) => _TimeCell(info),
        sortKey: (info) => info.start,
        descendingFirst: true,
      ),
    RecordColumn(
      TableColumn('process', appLocalizations.app, width: 160),
      cell: (_, info) => _AppCell(info, showsState: width < _timeTableWidth),
      sortKey: (info) => info.progressText.toLowerCase(),
    ),
    RecordColumn(
      TableColumn('target', appLocalizations.target, flex: 1.4),
      cell: (_, info) => TrackerTargetText(info),
      sortKey: (info) => info.title.toLowerCase(),
    ),
    if (width >= _ruleTableWidth)
      RecordColumn(
        TableColumn('rule', appLocalizations.rule, flex: 1),
        cell: (_, info) => TrackerRuleText(info),
        sortKey: (info) => '${info.rule} ${info.rulePayload}'.toLowerCase(),
      ),
    RecordColumn(
      TableColumn('exit', appLocalizations.outboundExit, width: 120),
      cell: (_, info) => _ExitChip(exit: info.chains.firstOrNull ?? ''),
      sortKey: (info) => (info.chains.firstOrNull ?? '').toLowerCase(),
    ),
    RecordColumn(
      fixed('speed', appLocalizations.speed, 96, end: true),
      cell: (_, info) => _SpeedCell(info),
      sortKey: (info) => (info.uploadSpeed ?? 0) + (info.downloadSpeed ?? 0),
      descendingFirst: true,
    ),
    if (width >= _durationTableWidth)
      RecordColumn(
        fixed('duration', appLocalizations.duration, 80, end: true),
        cell: (_, info) => TrackerLifetime(
          trackerInfo: info,
          builder: (lifetime) => RecordCellText(lifetime, muted: true),
        ),
        sortKey: (info) =>
            (info.closedAt ?? DateTime.now()).difference(info.start),
        descendingFirst: true,
      ),
    RecordColumn(
      fixed('total', appLocalizations.total, 100, end: true),
      cell: (_, info) => _TotalCell(info),
      sortKey: (info) => info.upload + info.download,
      descendingFirst: true,
    ),
  ];
}

bool _isIdle(TrackerInfo info) =>
    (info.uploadSpeed ?? 0) + (info.downloadSpeed ?? 0) == 0;

String trackerDurationText(Duration duration) {
  final seconds = duration.inSeconds;
  if (seconds < 60) {
    return '${seconds < 0 ? 0 : seconds} s';
  }
  final minutes = seconds / 60;
  if (minutes < 60) {
    return '${minutes < 10 ? minutes.toStringAsFixed(1) : minutes.round()} min';
  }
  return '${(minutes / 60).toStringAsFixed(1)} h';
}

/// All a row shows but the traffic its cells take from [TrackerTraffic].
TrackerInfo trackerRowKeyOf(TrackerInfo trackerInfo) => trackerInfo.copyWith(
  upload: 0,
  download: 0,
  uploadSpeed: null,
  downloadSpeed: null,
);

bool trackerSameRows(List<TrackerInfo> a, List<TrackerInfo> b) {
  if (identical(a, b)) {
    return true;
  }
  if (a.length != b.length) {
    return false;
  }
  for (var i = 0; i < a.length; i++) {
    final x = a[i];
    final y = b[i];
    if (!identical(x, y) && trackerRowKeyOf(x) != trackerRowKeyOf(y)) {
      return false;
    }
  }
  return true;
}

class TrackerTraffic extends InheritedModel<String> {
  final Map<String, TrackerInfo> latest;

  const TrackerTraffic({super.key, required this.latest, required super.child});

  TrackerTraffic.from(
    Iterable<TrackerInfo> trackerInfos, {
    super.key,
    required super.child,
  }) : latest = {
         for (final trackerInfo in trackerInfos)
           if (trackerInfo.isActive) trackerInfo.id: trackerInfo,
       };

  static TrackerInfo latestOf(BuildContext context, TrackerInfo trackerInfo) {
    if (!trackerInfo.isActive) {
      return trackerInfo;
    }
    return InheritedModel.inheritFrom<TrackerTraffic>(
          context,
          aspect: trackerInfo.id,
        )?.latest[trackerInfo.id] ??
        trackerInfo;
  }

  @override
  bool updateShouldNotify(TrackerTraffic oldWidget) =>
      !identical(latest, oldWidget.latest);

  @override
  bool updateShouldNotifyDependent(
    TrackerTraffic oldWidget,
    Set<String> dependencies,
  ) =>
      dependencies.any((id) => !_sameTraffic(latest[id], oldWidget.latest[id]));
}

bool _sameTraffic(TrackerInfo? a, TrackerInfo? b) =>
    a?.upload == b?.upload &&
    a?.download == b?.download &&
    a?.uploadSpeed == b?.uploadSpeed &&
    a?.downloadSpeed == b?.downloadSpeed;

class _SpeedCell extends StatelessWidget {
  final TrackerInfo trackerInfo;

  const _SpeedCell(this.trackerInfo);

  @override
  Widget build(BuildContext context) {
    if (!trackerInfo.isActive) {
      return const RecordCellText('', muted: true);
    }
    final latest = TrackerTraffic.latestOf(context, trackerInfo);
    return RecordCellText(trackerSpeedText(latest), muted: _isIdle(latest));
  }
}

class _TotalCell extends StatelessWidget {
  final TrackerInfo trackerInfo;

  const _TotalCell(this.trackerInfo);

  @override
  Widget build(BuildContext context) {
    final latest = TrackerTraffic.latestOf(context, trackerInfo);
    return RecordCellText((latest.upload + latest.download).traffic.show);
  }
}

class TrackerInfoTableRow extends StatelessWidget {
  final TrackerInfo trackerInfo;
  final RecordTable<TrackerInfo> table;
  final bool striped;
  final String detailTitle;
  final ValueChanged<TrackerInfo>? onClose;

  const TrackerInfoTableRow({
    super.key,
    required this.trackerInfo,
    required this.table,
    required this.striped,
    required this.detailTitle,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return ContextMenuRegion(
      menuBuilder: (context) =>
          trackerInfoMenuItems(context, trackerInfo, onClose: onClose),
      child: TrackerSelected(
        id: trackerInfo.id,
        builder: (context, selected) => RecordTableRow(
          table: table,
          striped: striped,
          selected: selected,
          onTap: () => openTrackerInfo(context, trackerInfo, detailTitle),
          cells: table.cellsOf(context, trackerInfo),
        ),
      ),
    );
  }
}

class _TimeCell extends StatelessWidget {
  final TrackerInfo trackerInfo;

  const _TimeCell(this.trackerInfo);

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Row(
      spacing: 8,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: ShapeDecoration(
            color: trackerInfo.isActive ? colorScheme.success : null,
            shape: const CircleBorder(),
          ),
        ),
        Flexible(
          child: RecordCellText(trackerInfo.start.showTime.trim(), muted: true),
        ),
      ],
    );
  }
}

/// Marks an open connection where no time column does.
class _AppCell extends StatelessWidget {
  final TrackerInfo trackerInfo;
  final bool showsState;

  const _AppCell(this.trackerInfo, {required this.showsState});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        TrackerAppWell(
          trackerInfo: trackerInfo,
          size: 18,
          showsState: showsState,
        ),
        Flexible(child: RecordCellText(trackerInfo.progressText)),
      ],
    );
  }
}

class _ExitChip extends StatelessWidget {
  final String exit;

  const _ExitChip({required this.exit});

  @override
  Widget build(BuildContext context) {
    if (exit.isEmpty) {
      return const RecordCellText('');
    }
    final colorScheme = context.colorScheme;
    return TonalChip(
      label: exit,
      color: context.raisedSurfaceLevel.colorOf(colorScheme),
      foregroundColor: colorScheme.onSurfaceVariant,
      onPressed: () => RecordFilterScope.add(
        context,
        RecordFilter(RecordFacetKind.proxy, exit),
      ),
    );
  }
}

class TrackerTargetText extends StatelessWidget {
  final TrackerInfo trackerInfo;

  const TrackerTargetText(this.trackerInfo, {super.key});

  @override
  Widget build(BuildContext context) {
    final port = trackerInfo.metadata.destinationPort;
    final target = Text.rich(
      TextSpan(
        children: [
          TextSpan(text: trackerInfo.title),
          if (port.isNotEmpty)
            TextSpan(
              text: ':$port',
              style: TextStyle(color: context.colorScheme.onSurfaceVariant),
            ),
        ],
      ),
    );
    final labels = trackerLabels(context, trackerInfo);
    if (labels.isEmpty) {
      return target;
    }
    return ClipRect(
      child: CustomMultiChildLayout(
        delegate: _LabeledTargetLayout(Directionality.of(context)),
        children: [
          LayoutId(id: _LabeledTargetSlot.target, child: target),
          LayoutId(
            id: _LabeledTargetSlot.labels,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: labels,
            ),
          ),
        ],
      ),
    );
  }
}

enum _LabeledTargetSlot { target, labels }

/// The labels keep their width and the target gives way to them; labels
/// wider than a narrowed column are cut off rather than overflowing it.
class _LabeledTargetLayout extends MultiChildLayoutDelegate {
  final TextDirection direction;

  _LabeledTargetLayout(this.direction);

  static const _gap = 6.0;

  @override
  void performLayout(Size size) {
    final labels = layoutChild(
      _LabeledTargetSlot.labels,
      BoxConstraints(maxHeight: size.height),
    );
    final target = layoutChild(
      _LabeledTargetSlot.target,
      BoxConstraints(
        maxWidth: max(0, size.width - labels.width - _gap),
        maxHeight: size.height,
      ),
    );
    double startOf(double start, double width) =>
        direction == TextDirection.rtl ? size.width - start - width : start;
    positionChild(
      _LabeledTargetSlot.target,
      Offset(startOf(0, target.width), (size.height - target.height) / 2),
    );
    positionChild(
      _LabeledTargetSlot.labels,
      Offset(
        startOf(target.width + _gap, labels.width),
        (size.height - labels.height) / 2,
      ),
    );
  }

  @override
  bool shouldRelayout(_LabeledTargetLayout oldDelegate) =>
      direction != oldDelegate.direction;
}

class TrackerRuleText extends StatelessWidget {
  final TrackerInfo trackerInfo;

  const TrackerRuleText(this.trackerInfo, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: trackerInfo.rule,
            style: TextStyle(color: context.colorScheme.onSurfaceVariant),
          ),
          if (trackerInfo.rulePayload.isNotEmpty)
            TextSpan(text: ' ${trackerInfo.rulePayload}'),
        ],
      ),
    );
  }
}
