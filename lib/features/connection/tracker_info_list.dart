import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tracker_info_item.dart';
import 'tracker_info_table.dart';

class TrackerInfoListController extends ValueNotifier<TrackerInfosState> {
  TrackerInfoListController() : super(const TrackerInfosState());

  void search(String query) {
    value = value.copyWith(query: query);
  }

  /// Off the end, the rows shown stay as they are but for their changes: a
  /// connection that opens is only counted, so nothing shifts under the reader.
  void setTrackerInfos(
    List<TrackerInfo> trackerInfos, {
    List<TrackerInfo> Function(List<TrackerInfo> trackerInfos)? shown,
  }) {
    if (identical(trackerInfos, value.trackerInfos)) {
      return;
    }
    if (value.autoScrollToEnd) {
      value = value.copyWith(trackerInfos: trackerInfos, pending: 0);
      return;
    }
    final latest = {
      for (final trackerInfo in trackerInfos) trackerInfo.id: trackerInfo,
    };
    final rows = <TrackerInfo>[];
    for (final trackerInfo in value.trackerInfos) {
      rows.add(latest.remove(trackerInfo.id) ?? trackerInfo);
    }
    final arrived = value.copyWith(trackerInfos: [...latest.values]).list;
    value = value.copyWith(
      trackerInfos: List.unmodifiable(rows),
      pending: (shown?.call(arrived) ?? arrived).length,
    );
  }

  void setAutoScrollToEnd(bool autoScrollToEnd) {
    value = value.copyWith(autoScrollToEnd: autoScrollToEnd);
  }

  void resumeAutoScrollToEnd(List<TrackerInfo> trackerInfos) {
    value = value.copyWith(
      autoScrollToEnd: true,
      trackerInfos: trackerInfos,
      pending: 0,
    );
  }
}

/// Each minute once, newest first, whatever order [trackerInfos] come in.
List<RecordGroup<TrackerInfo>> trackerInfoMinuteGroups(
  List<TrackerInfo> trackerInfos,
  DateTime now,
) {
  final byMinute = <int, List<TrackerInfo>>{};
  for (final trackerInfo in trackerInfos.reversed) {
    final minute = trackerInfo.start.millisecondsSinceEpoch ~/ 60000;
    (byMinute[minute] ??= []).add(trackerInfo);
  }
  final today = now.toLocal();
  String two(int value) => value.toString().padLeft(2, '0');
  String labelOf(int minute) {
    final local = DateTime.fromMillisecondsSinceEpoch(minute * 60000);
    final time = '${two(local.hour)}:${two(local.minute)}';
    final isToday =
        local.year == today.year &&
        local.month == today.month &&
        local.day == today.day;
    return isToday ? time : '${two(local.month)}-${two(local.day)} $time';
  }

  return [
    for (final MapEntry(key: minute, value: items) in byMinute.entries)
      RecordGroup(labelOf(minute), items),
  ];
}

class TrackerInfoList extends StatelessWidget {
  final List<TrackerInfo> trackerInfos;
  final String detailTitle;
  final RecordTable<TrackerInfo>? table;
  final ScrollController? controller;
  final bool reverse;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final ValueChanged<TrackerInfo>? onClose;

  const TrackerInfoList({
    super.key,
    required this.trackerInfos,
    required this.detailTitle,
    this.table,
    this.controller,
    this.reverse = false,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final table = this.table;
    final list = RecordFeedList<TrackerInfo>(
      reverse: reverse,
      shrinkWrap: shrinkWrap,
      physics: physics,
      controller: controller,
      padding: padding,
      items: trackerInfos,
      keyOf: (trackerInfo) => ValueKey(trackerInfo.id),
      gap: 0,
      estimatedItemExtent: table?.rowHeight ?? recordListEstimatedExtent,
      itemBuilder: (trackerInfo, striped, latest) => MemoBuilder(
        inputs: [_memoKeyOf(trackerInfo, table), detailTitle, table, striped],
        builder: (_) => _buildTrackerInfoItem(
          trackerInfo,
          detailTitle: detailTitle,
          table: table,
          striped: striped,
          onClose: onClose,
          latest: latest,
        ),
      ),
    );
    if (table == null) {
      return list;
    }
    return TrackerTraffic.from(
      trackerInfos,
      child: MemoBuilder(
        inputs: [
          _Rows(trackerInfos),
          detailTitle,
          table,
          controller,
          reverse,
          shrinkWrap,
          physics,
          padding,
          onClose,
        ],
        builder: (_) => list,
      ),
    );
  }
}

class TrackerInfoGroupedList extends ConsumerStatefulWidget {
  final List<RecordGroup<TrackerInfo>> groups;

  /// Null groups by the minute the connections opened.
  final RecordGrouping? grouping;
  final String detailTitle;
  final RecordTable<TrackerInfo>? table;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final ValueChanged<TrackerInfo>? onClose;

  const TrackerInfoGroupedList({
    super.key,
    required this.groups,
    required this.grouping,
    required this.detailTitle,
    this.table,
    this.controller,
    this.padding,
    this.onClose,
  });

  @override
  ConsumerState<TrackerInfoGroupedList> createState() =>
      _TrackerInfoGroupedListState();
}

class _TrackerInfoGroupedListState
    extends ConsumerState<TrackerInfoGroupedList> {
  Map<String, TrackerInfo>? _byId;
  final _leadings = <String, Widget>{};

  @override
  void didUpdateWidget(TrackerInfoGroupedList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.groups, widget.groups)) {
      _byId = null;
    }
  }

  Widget? _leadingOf(String packageName) {
    if (packageName.isEmpty) {
      return null;
    }
    return _leadings[packageName] ??= OwnPackageIcon(
      packageName: packageName,
      size: 24,
      builder: (_, icon) => icon ?? const SizedBox.shrink(),
    );
  }

  TrackerInfo _latest(TrackerInfo trackerInfo) =>
      (_byId ??= {
        for (final group in widget.groups)
          for (final item in group.items) item.id: item,
      })[trackerInfo.id] ??
      trackerInfo;

  @override
  Widget build(BuildContext context) {
    final TrackerInfoGroupedList(:grouping, :detailTitle, :table, :onClose) =
        widget;
    if (grouping == null) {
      return _TrackerInfoMinuteList(
        groups: widget.groups,
        controller: widget.controller,
        padding: widget.padding,
        itemBuilder: (trackerInfo) => MemoBuilder(
          inputs: [trackerInfo, detailTitle],
          builder: (_) => _buildTrackerInfoItem(
            trackerInfo,
            detailTitle: detailTitle,
            table: null,
            striped: false,
            onClose: onClose,
            latest: () => _latest(trackerInfo),
          ),
        ),
      );
    }
    final showsIcons =
        grouping == RecordGrouping.app &&
        ref.watch(packageIconSourceProvider) != null;
    final list = RecordGroupedList<TrackerInfo>(
      groups: widget.groups,
      grouping: grouping,
      controller: widget.controller,
      padding: widget.padding,
      estimatedItemExtent: table?.rowHeight ?? recordListEstimatedExtent,
      leadingOf: showsIcons ? (group) => _leadingOf(group.key) : null,
      trailingOf: (group) => _buildSpeed(context, group.items),
      itemBuilder: (_, trackerInfo, index) {
        final striped = index.isOdd;
        return MemoBuilder(
          key: ValueKey(trackerInfo.id),
          inputs: [_memoKeyOf(trackerInfo, table), detailTitle, table, striped],
          builder: (_) => _buildTrackerInfoItem(
            trackerInfo,
            detailTitle: detailTitle,
            table: table,
            striped: striped,
            onClose: onClose,
            latest: () => _latest(trackerInfo),
          ),
        );
      },
    );
    if (table == null) {
      return list;
    }
    return TrackerTraffic.from([
      for (final group in widget.groups) ...group.items,
    ], child: list);
  }

  Widget _buildSpeed(BuildContext context, List<TrackerInfo> trackerInfos) {
    var upload = 0;
    var download = 0;
    for (final trackerInfo in trackerInfos) {
      upload += trackerInfo.uploadSpeed ?? 0;
      download += trackerInfo.downloadSpeed ?? 0;
    }
    final color = context.colorScheme.onSurfaceVariant;
    WidgetSpan arrow(Glyph glyph) => WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: GlyphIcon(glyph, size: 12, color: color),
    );
    return Text.rich(
      TextSpan(
        children: [
          arrow(AppGlyphs.arrowUp),
          TextSpan(text: ' ${upload.traffic.show}/s   '),
          arrow(AppGlyphs.arrowDown),
          TextSpan(text: ' ${download.traffic.show}/s'),
        ],
      ),
    );
  }
}

class _Rows {
  final List<TrackerInfo> items;

  const _Rows(this.items);

  @override
  bool operator ==(Object other) =>
      other is _Rows && trackerSameRows(items, other.items);

  @override
  int get hashCode => items.length;
}

/// A table row's cells take their traffic from [TrackerTraffic]; a list item
/// shows it in place, so it rebuilds with it.
Object _memoKeyOf(TrackerInfo trackerInfo, RecordTable<TrackerInfo>? table) =>
    table == null ? trackerInfo : trackerRowKeyOf(trackerInfo);

Widget _buildTrackerInfoItem(
  TrackerInfo trackerInfo, {
  required String detailTitle,
  required RecordTable<TrackerInfo>? table,
  required bool striped,
  ValueChanged<TrackerInfo>? onClose,
  ValueGetter<TrackerInfo>? latest,
}) {
  if (table != null) {
    return TrackerInfoTableRow(
      key: ValueKey(trackerInfo.id),
      trackerInfo: trackerInfo,
      table: table,
      striped: striped,
      detailTitle: detailTitle,
      onClose: onClose,
    );
  }
  return TrackerInfoItem(
    key: ValueKey(trackerInfo.id),
    trackerInfo: trackerInfo,
    onClose: onClose,
    detailTitle: detailTitle,
    latest: latest,
  );
}

/// Groups that never fold, each row keyed to its connection so one opening
/// above them moves the rows built rather than building them anew.
class _TrackerInfoMinuteList extends StatefulWidget {
  final List<RecordGroup<TrackerInfo>> groups;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final Widget Function(TrackerInfo trackerInfo) itemBuilder;

  const _TrackerInfoMinuteList({
    required this.groups,
    required this.itemBuilder,
    this.controller,
    this.padding,
  });

  @override
  State<_TrackerInfoMinuteList> createState() => _TrackerInfoMinuteListState();
}

class _TrackerInfoMinuteListState extends State<_TrackerInfoMinuteList> {
  late List<(RecordGroup<TrackerInfo>, int)> _rows;
  Map<Key, int>? _indexes;

  @override
  void initState() {
    super.initState();
    _flatten();
  }

  @override
  void didUpdateWidget(_TrackerInfoMinuteList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.groups, widget.groups)) {
      _flatten();
    }
  }

  void _flatten() {
    _indexes = null;
    _rows = [
      for (final group in widget.groups) ...[
        (group, -1),
        for (var index = 0; index < group.items.length; index++) (group, index),
      ],
    ];
  }

  Key _keyOf((RecordGroup<TrackerInfo>, int) row) => switch (row) {
    (final group, -1) => ValueKey(('minute', group.key)),
    (final group, final index) => ValueKey(group.items[index].id),
  };

  int? _indexOf(Key key) => (_indexes ??= {
    for (final (index, row) in _rows.indexed) _keyOf(row): index,
  })[key];

  @override
  Widget build(BuildContext context) {
    return ArrivalCacheExtentBuilder(
      builder: (cacheExtent) => CustomScrollView(
        controller: widget.controller,
        scrollCacheExtent: cacheExtent,
        slivers: [
          SliverPadding(
            padding: widget.padding ?? EdgeInsets.zero,
            sliver: SliverPrismList(
              itemCount: _rows.length,
              estimatedItemExtent: recordListEstimatedExtent,
              findChildIndexCallback: _indexOf,
              itemBuilder: (context, index) {
                final row = _rows[index];
                final (group, item) = row;
                return KeyedSubtree(
                  key: _keyOf(row),
                  child: item < 0
                      ? CollapsibleHeader(
                          label: group.key,
                          count: group.items.length,
                          unfold: kAlwaysCompleteAnimation,
                        )
                      : ItemPositionProvider(
                          position: ItemPosition.get(item, group.items.length),
                          child: widget.itemBuilder(group.items[item]),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
