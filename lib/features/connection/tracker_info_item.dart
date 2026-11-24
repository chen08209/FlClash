import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';

import 'tracker_app_well.dart';
import 'tracker_clock.dart';
import 'tracker_menu.dart';
import 'tracker_selection.dart';
import 'tracker_texts.dart';

List<PopupMenuItem> trackerInfoMenuItems(
  BuildContext context,
  TrackerInfo trackerInfo, {
  ValueChanged<TrackerInfo>? onClose,
}) {
  final appLocalizations = context.appLocalizations;
  final metadata = trackerInfo.metadata;
  final destination = trackerEndpointText(
    metadata.destinationIP,
    metadata.destinationPort,
  );
  final menuActions = TrackerMenuScope.of(context);
  final close = onClose ?? menuActions?.close;
  final onlyApp = menuActions?.onlyApp;
  final hideHost = menuActions?.hideHost;
  // The row that opened the menu can leave the list before its sheet opens.
  final formHost = Navigator.of(context).overlay!.context;
  return [
    if (close != null && trackerInfo.isActive)
      PopupMenuItem(
        glyph: AppGlyphs.block,
        label: appLocalizations.closeConnection,
        danger: true,
        onPressed: () => close(trackerInfo),
      ),
    if (metadata.host.isNotEmpty)
      copyMenuItem(
        appLocalizations.copyHost,
        trackerCopyText(trackerInfo),
        section: const PopupMenuSection(),
      ),
    if (metadata.host.isEmpty && destination.isNotEmpty)
      copyMenuItem(
        appLocalizations.copyDestination,
        trackerCopyText(trackerInfo),
        section: const PopupMenuSection(),
      ),
    if (onlyApp != null && metadata.process.isNotEmpty)
      PopupMenuItem(
        glyph: AppGlyphs.filter,
        label: appLocalizations.onlyThisApp,
        section: const PopupMenuSection(),
        onPressed: () => onlyApp(trackerInfo),
      ),
    if (hideHost != null && trackerInfo.title.isNotEmpty)
      PopupMenuItem(
        glyph: AppGlyphs.eyeOff,
        label: appLocalizations.hideThisHost,
        section: onlyApp == null || metadata.process.isEmpty
            ? const PopupMenuSection()
            : null,
        onPressed: () => hideHost(trackerInfo),
      ),
    if (rsFeature && metadata.mitm)
      PopupMenuItem(
        glyph: AppGlyphs.eye,
        label: appLocalizations.viewHttp,
        section: const PopupMenuSection(),
        onPressed: () => showTrackerInfoDetail(
          formHost,
          trackerInfo,
          appLocalizations.details(appLocalizations.connection),
          opensRequests: true,
        ),
      ),
  ];
}

class TrackerInfoItem extends StatelessWidget {
  final TrackerInfo trackerInfo;
  final ValueChanged<TrackerInfo>? onClose;
  final String detailTitle;

  /// With its latest traffic, which [traffic] tells of.
  final ValueGetter<TrackerInfo>? latest;
  final Listenable? traffic;

  const TrackerInfoItem({
    super.key,
    required this.trackerInfo,
    this.onClose,
    required this.detailTitle,
    this.latest,
    this.traffic,
  });

  @override
  Widget build(BuildContext context) {
    final selection = TrackerSelection.maybeOf(context);
    if (selection == null) {
      return _buildRow(context, selected: false);
    }
    return TrackerSelected(
      id: trackerInfo.id,
      builder: (context, selected) => _buildRow(context, selected: selected),
    );
  }

  Widget _buildRow(BuildContext context, {required bool selected}) {
    final colorScheme = context.colorScheme;
    final metadata = trackerInfo.metadata;
    final secondary = colorScheme.onSurfaceVariant;
    final failure = trackerInfo.failure;
    final row = DecorationListItem(
      isSelected: selected,
      leading: TrackerAppWell(trackerInfo: trackerInfo, size: 40),
      title: Text(
        metadata.host.isNotEmpty
            ? metadata.host
            : trackerEndpointText(
                metadata.destinationIP,
                metadata.destinationPort,
              ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyle.subheadline.of(context),
      ),
      subtitle: DefaultTextStyle.merge(
        style: AppTextStyle.caption1
            .of(context)
            .toTabular
            .copyWith(color: secondary),
        child: failure != null
            ? RecordLabelLine(
                labels: trackerLabels(context, trackerInfo),
                underTitle: true,
              )
            : TrackerLifetime(
                trackerInfo: trackerInfo,
                builder: (lifetime) => RecordLabelLine(
                  underTitle: true,
                  labels: [
                    if (trackerInfo.chains.lastOrNull case final node?
                        when node.isNotEmpty)
                      RecordLabel(label: node),
                    RecordLabel(label: lifetime),
                    ...trackerLabels(context, trackerInfo, failure: false),
                  ],
                ),
              ),
      ),
      trailing: switch ((traffic, latest)) {
        (final traffic?, final latest?) => ListenableBuilder(
          listenable: traffic,
          builder: (context, _) {
            final trackerInfo = latest();
            return MemoBuilder(
              inputs: [trackerInfo],
              builder: (_) => TrackerTraffic(trackerInfo: trackerInfo),
            );
          },
        ),
        _ => TrackerTraffic(trackerInfo: trackerInfo),
      },
      onPressed: () =>
          openTrackerInfo(context, latest?.call() ?? trackerInfo, detailTitle),
    );
    return ContextMenuRegion(
      menuBuilder: (context) => trackerInfoMenuItems(
        context,
        latest?.call() ?? trackerInfo,
        onClose: onClose,
      ),
      child: selected ? RecordSelectedRow(child: row) : row,
    );
  }
}

class TrackerTraffic extends StatelessWidget {
  final TrackerInfo trackerInfo;

  const TrackerTraffic({super.key, required this.trackerInfo});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final secondary = colorScheme.onSurfaceVariant;
    final total = (trackerInfo.upload + trackerInfo.download).traffic.show;
    final active = trackerInfo.isActive;
    return PlainTextLines(spacing: 2, [
      (
        text: active ? trackerSpeedText(trackerInfo) : total,
        style: AppTextStyle.footnote
            .of(context, emphasized: active)
            .toTabular
            .copyWith(color: active ? colorScheme.onSurface : secondary),
      ),
      if (active)
        (
          text: total,
          style: AppTextStyle.caption2
              .of(context)
              .toTabular
              .copyWith(color: secondary),
        ),
    ]);
  }
}
