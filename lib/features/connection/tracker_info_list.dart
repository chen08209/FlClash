import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import 'tracker_info_item.dart';
import 'tracker_info_table.dart';

class TrackerInfoListController extends ValueNotifier<TrackerInfosState> {
  TrackerInfoListController() : super(const TrackerInfosState());

  void search(String query) {
    value = value.copyWith(query: query);
  }

  void updateKeywords(List<String> keywords) {
    value = value.copyWith(keywords: keywords);
  }

  void setTrackerInfos(List<TrackerInfo> trackerInfos) {
    if (identical(trackerInfos, value.trackerInfos)) {
      return;
    }
    value = value.copyWith(
      trackerInfos: value.autoScrollToEnd
          ? trackerInfos
          : retainTrimmedHead(
              value.trackerInfos,
              trackerInfos,
              pausedMaxRequestsLength,
              keyOf: (trackerInfo) => trackerInfo.id,
            ),
    );
  }

  void setAutoScrollToEnd(bool autoScrollToEnd) {
    value = value.copyWith(autoScrollToEnd: autoScrollToEnd);
  }

  void resumeAutoScrollToEnd(List<TrackerInfo> trackerInfos) {
    value = value.copyWith(autoScrollToEnd: true, trackerInfos: trackerInfos);
  }
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
  final Widget? Function(TrackerInfo trackerInfo)? actionBuilder;

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
    this.actionBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return SuperListView.separated(
      reverse: reverse,
      shrinkWrap: shrinkWrap,
      physics: physics,
      controller: controller,
      padding: padding,
      itemCount: trackerInfos.length,
      extentEstimation: table?.estimateExtent ?? recordListExtentEstimation,
      separatorBuilder: (_, _) => table == null
          ? const SizedBox(height: recordListGap)
          : const SizedBox.shrink(),
      itemBuilder: (_, index) => _buildTrackerInfoItem(
        context,
        trackerInfos[index],
        isLive: false,
        detailTitle: detailTitle,
        table: table,
        striped: index.isOdd,
        actionBuilder: actionBuilder,
      ),
    );
  }
}

/// Same rows as [TrackerInfoList], but diffed by connection id so closed
/// connections collapse out and surviving rows slide to their new slot.
class TrackerInfoAnimatedList extends StatelessWidget {
  final List<TrackerInfo> trackerInfos;
  final String detailTitle;
  final RecordTable<TrackerInfo>? table;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final Widget? Function(TrackerInfo trackerInfo)? actionBuilder;

  const TrackerInfoAnimatedList({
    super.key,
    required this.trackerInfos,
    required this.detailTitle,
    this.table,
    this.controller,
    this.padding,
    this.actionBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final table = this.table;
    final positions = table == null
        ? const <String, int>{}
        : {
            for (final (index, trackerInfo) in trackerInfos.indexed)
              trackerInfo.id: index,
          };
    return KeyedAnimatedList<TrackerInfo>(
      controller: controller,
      padding: padding,
      items: trackerInfos,
      keyOf: (trackerInfo) => trackerInfo.id,
      separator: table == null ? const SizedBox(height: recordListGap) : null,
      itemBuilder: (context, trackerInfo) => _buildTrackerInfoItem(
        context,
        trackerInfo,
        isLive: true,
        detailTitle: detailTitle,
        table: table,
        striped: positions[trackerInfo.id]?.isOdd ?? false,
        actionBuilder: actionBuilder,
      ),
    );
  }
}

Widget _buildTrackerInfoItem(
  BuildContext context,
  TrackerInfo trackerInfo, {
  required bool isLive,
  required String detailTitle,
  required RecordTable<TrackerInfo>? table,
  required bool striped,
  required Widget? Function(TrackerInfo trackerInfo)? actionBuilder,
}) {
  if (table != null) {
    return TrackerInfoTableRow(
      key: Key(trackerInfo.id),
      trackerInfo: trackerInfo,
      table: table,
      striped: striped,
      detailTitle: detailTitle,
    );
  }
  return TrackerInfoItem(
    key: Key(trackerInfo.id),
    trackerInfo: trackerInfo,
    isLive: isLive,
    onClickKeyword: (value) {
      context.commonScaffoldState?.addKeyword(value);
    },
    action: actionBuilder?.call(trackerInfo),
    detailTitle: detailTitle,
  );
}
