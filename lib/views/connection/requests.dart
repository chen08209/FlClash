import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/features.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RequestsView extends ConsumerStatefulWidget {
  final ScrollController? scrollController;

  const RequestsView({super.key, this.scrollController});

  @override
  ConsumerState<RequestsView> createState() => _RequestsViewState();
}

class _RequestsViewState extends ConsumerState<RequestsView>
    with RouteMotionHoldMixin<RequestsView> {
  final _listController = TrackerInfoListController();
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController =
        widget.scrollController ??
        ScrollController(initialScrollOffset: double.maxFinite);
    _listController.setTrackerInfos(ref.read(requestsProvider).list);
    ref.listenManual(requestsProvider.select((state) => state.revision), (
      _,
      _,
    ) {
      updateRequestsThrottler();
    });
  }

  @override
  void dispose() {
    _listController.dispose();
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void updateRequestsThrottler() {
    throttler.call(FunctionTag.requests, () {
      if (!mounted) {
        return;
      }
      updateWhenRouteSettled(
        () => _listController.setTrackerInfos(ref.read(requestsProvider).list),
      );
    }, duration: renderThrottleDuration);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonScaffold(
      title: PageLabel.requests.label,
      searchState: AppBarSearchState(onSearch: _listController.search),
      onKeywordsUpdate: _listController.updateKeywords,
      body: ValueListenableBuilder<TrackerInfosState>(
        valueListenable: _listController,
        builder: (context, state, _) {
          final requests = state.list;
          return NullStatusSwitcher(
            isEmpty: requests.isEmpty,
            isSearching: state.isSearching,
            nullStatus: NullStatus(
              label: appLocalizations.nullTip(appLocalizations.requests),
              illustration: NullStatusIllustration.requests,
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: FloatingScrollbar(
                controller: _scrollController,
                hintBuilder: (fraction) {
                  final index = (fraction * (requests.length - 1)).round();
                  return requests[index].start.showFull;
                },
                child: ScrollToEndBox(
                  controller: _scrollController,
                  dataSource: requests,
                  enable: state.autoScrollToEnd,
                  onCancelToEnd: () {
                    _listController.setAutoScrollToEnd(false);
                  },
                  onResumeToEnd: () {
                    _listController.resumeAutoScrollToEnd(
                      ref.read(requestsProvider).list,
                    );
                  },
                  child: TrackerInfoList(
                    reverse: true,
                    shrinkWrap: true,
                    physics: const NextClampingScrollPhysics(),
                    controller: _scrollController,
                    padding: EdgeInsets.only(
                      top: context.contentTopPadding,
                      bottom: 16 + BottomInsetScope.of(context),
                    ),
                    trackerInfos: requests,
                    detailTitle: appLocalizations.details(
                      appLocalizations.request,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
