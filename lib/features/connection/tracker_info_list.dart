import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import 'tracker_info_item.dart';

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
  final ScrollController? controller;
  final bool reverse;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final Widget? Function(TrackerInfo trackerInfo)? trailingBuilder;

  const TrackerInfoList({
    super.key,
    required this.trackerInfos,
    required this.detailTitle,
    this.controller,
    this.reverse = false,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
    this.trailingBuilder,
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
      separatorBuilder: (_, _) => const Divider(height: 0),
      itemBuilder: (_, index) => _buildTrackerInfoItem(
        context,
        trackerInfos[index],
        detailTitle: detailTitle,
        trailingBuilder: trailingBuilder,
      ),
    );
  }
}

/// Same rows as [TrackerInfoList], but diffed by connection id so closed
/// connections collapse out and surviving rows slide to their new slot.
class TrackerInfoAnimatedList extends StatelessWidget {
  final List<TrackerInfo> trackerInfos;
  final String detailTitle;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final Widget? Function(TrackerInfo trackerInfo)? trailingBuilder;

  const TrackerInfoAnimatedList({
    super.key,
    required this.trackerInfos,
    required this.detailTitle,
    this.controller,
    this.padding,
    this.trailingBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return KeyedAnimatedList<TrackerInfo>(
      controller: controller,
      padding: padding,
      items: trackerInfos,
      keyOf: (trackerInfo) => trackerInfo.id,
      separator: const Divider(height: 0),
      itemBuilder: (context, trackerInfo) => _buildTrackerInfoItem(
        context,
        trackerInfo,
        detailTitle: detailTitle,
        trailingBuilder: trailingBuilder,
      ),
    );
  }
}

Widget _buildTrackerInfoItem(
  BuildContext context,
  TrackerInfo trackerInfo, {
  required String detailTitle,
  required Widget? Function(TrackerInfo trackerInfo)? trailingBuilder,
}) {
  return TrackerInfoItem(
    key: Key(trackerInfo.id),
    trackerInfo: trackerInfo,
    onClickKeyword: (value) {
      context.commonScaffoldState?.addKeyword(value);
    },
    trailing: trailingBuilder?.call(trackerInfo),
    detailTitle: detailTitle,
  );
}
