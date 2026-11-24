import 'dart:math';

import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';

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
            text: trackerInfo.rule.isNotEmpty
                ? trackerInfo.rule
                : trackerRuleText(context.appLocalizations, trackerInfo),
            style: TextStyle(color: context.colorScheme.onSurfaceVariant),
          ),
          if (trackerInfo.rulePayload.isNotEmpty)
            TextSpan(text: ' ${trackerInfo.rulePayload}'),
        ],
      ),
    );
  }
}

String twoDigits(int value) => value.toString().padLeft(2, '0');

String trackerEndpointText(String ip, String port) {
  if (ip.isEmpty) {
    return '';
  }
  if (port.isEmpty) {
    return ip;
  }
  return ip.contains(':') ? '[$ip]:$port' : '$ip:$port';
}

/// What copying a connection gives: its host, or its address without one.
String trackerCopyText(TrackerInfo trackerInfo) {
  final metadata = trackerInfo.metadata;
  if (metadata.host.isNotEmpty) {
    return metadata.host;
  }
  return trackerEndpointText(metadata.destinationIP, metadata.destinationPort);
}

/// The line under a connection's name: its app, the node it left by, and
/// whether it is still open.
String trackerHeadline(
  AppLocalizations appLocalizations,
  TrackerInfo trackerInfo,
  String lifetime,
) => [
  trackerInfo.metadata.process.trim(),
  for (final part in trackerHeadlineLabels(
    appLocalizations,
    trackerInfo,
    lifetime,
  ))
    part.text,
].where((part) => part.isNotEmpty).join(' · ');

List<({String text, bool failed})> trackerHeadlineLabels(
  AppLocalizations appLocalizations,
  TrackerInfo trackerInfo,
  String lifetime,
) => [
  if (trackerInfo.chains.firstOrNull case final node? when node.isNotEmpty)
    (text: node, failed: false),
  if (trackerInfo.failure != null) ...[
    (text: appLocalizations.connectionsFailed, failed: true),
    (text: lifetime, failed: false),
  ] else if (trackerInfo.isActive)
    (text: '${appLocalizations.connectionsActive} $lifetime', failed: false)
  else
    (text: appLocalizations.connectionClosed, failed: false),
];

String trackerSummaryText(
  AppLocalizations appLocalizations,
  TrackerInfo trackerInfo,
) {
  final metadata = trackerInfo.metadata;
  final failure = trackerInfo.failure;
  return [
    trackerInfo.title,
    trackerHeadline(
      appLocalizations,
      trackerInfo,
      trackerLifetimeText(trackerInfo, DateTime.now()),
    ),
    for (final (label, value) in [
      (
        appLocalizations.source,
        trackerEndpointText(metadata.sourceIP, metadata.sourcePort),
      ),
      (
        appLocalizations.destination,
        trackerEndpointText(metadata.destinationIP, metadata.destinationPort),
      ),
      (appLocalizations.processPath, metadata.processPath),
      (appLocalizations.rule, trackerInfo.ruleText),
      (
        appLocalizations.connectionPath,
        trackerInfo.chains.reversed.join(' → '),
      ),
      if (failure != null) (failure.kind.label, failure.message),
    ])
      if (value.isNotEmpty) '$label: $value',
  ].join('\n');
}

String trackerLifetimeText(TrackerInfo trackerInfo, DateTime now) {
  final endedAt = trackerInfo.endedAt;
  if (endedAt != null) {
    return trackerDurationText(endedAt.difference(trackerInfo.start));
  }
  final elapsed = max(0, now.difference(trackerInfo.start).inSeconds);
  final seconds = twoDigits(elapsed % 60);
  if (elapsed < 3600) {
    return '${elapsed ~/ 60}:$seconds';
  }
  return '${elapsed ~/ 3600}:${twoDigits(elapsed ~/ 60 % 60)}:$seconds';
}

String trackerSpeedText(TrackerInfo trackerInfo) {
  final speed =
      (trackerInfo.uploadSpeed ?? 0) + (trackerInfo.downloadSpeed ?? 0);
  return '${speed.traffic.show}/s';
}

/// How many failed dials to the same target each merged row stands for.
class TrackerRepeats extends InheritedModel<String> {
  final Map<String, int> counts;

  const TrackerRepeats({super.key, required this.counts, required super.child});

  static int of(BuildContext context, String id) =>
      InheritedModel.inheritFrom<TrackerRepeats>(
        context,
        aspect: id,
      )?.counts[id] ??
      1;

  @override
  bool updateShouldNotify(TrackerRepeats oldWidget) =>
      !identical(counts, oldWidget.counts);

  @override
  bool updateShouldNotifyDependent(
    TrackerRepeats oldWidget,
    Set<String> dependencies,
  ) => dependencies.any((id) => counts[id] != oldWidget.counts[id]);
}

List<Widget> trackerLabels(
  BuildContext context,
  TrackerInfo trackerInfo, {
  bool failure = true,
}) {
  final repeats = TrackerRepeats.of(context, trackerInfo.id);
  return [
    if (failure)
      if (trackerInfo.failure case final failure?)
        RecordLabel(label: failure.kind.label, tone: RecordTone.error),
    if (repeats > 1) RecordLabel(label: '×$repeats'),
    if (rsFeature && trackerInfo.metadata.mitm)
      const RecordLabel(label: 'MITM'),
  ];
}
