import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/features.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RequestsView extends ConsumerStatefulWidget {
  const RequestsView({super.key});

  @override
  ConsumerState<RequestsView> createState() => _RequestsViewState();
}

class _RequestsViewState extends ConsumerState<RequestsView> {
  final _listController = TrackerInfoListController();
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: double.maxFinite);
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
    _scrollController.dispose();
    super.dispose();
  }

  void updateRequestsThrottler() {
    throttler.call(FunctionTag.requests, () {
      if (!mounted) {
        return;
      }
      _listController.setTrackerInfos(ref.read(requestsProvider).list);
    }, duration: commonDuration);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonScaffold(
      title: appLocalizations.requests,
      searchState: AppBarSearchState(onSearch: _listController.search),
      onKeywordsUpdate: _listController.updateKeywords,
      floatingActionButton: ValueListenableBuilder(
        valueListenable: _listController,
        builder: (_, state, _) {
          final autoScrollToEnd = state.autoScrollToEnd;
          return FadeRotationScaleBox(
            child: FloatingActionButton(
              key: ValueKey(autoScrollToEnd),
              onPressed: () {
                if (autoScrollToEnd) {
                  _listController.setAutoScrollToEnd(false);
                } else {
                  _listController.resumeAutoScrollToEnd(
                    ref.read(requestsProvider).list,
                  );
                }
              },
              child: autoScrollToEnd
                  ? const Icon(Icons.block)
                  : const Icon(Icons.vertical_align_top),
            ),
          );
        },
      ),
      body: ValueListenableBuilder<TrackerInfosState>(
        valueListenable: _listController,
        builder: (context, state, _) {
          final requests = state.list;
          if (requests.isEmpty) {
            return NullStatus(
              label: appLocalizations.nullTip(appLocalizations.requests),
            );
          }
          return Align(
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
                child: TrackerInfoList(
                  reverse: true,
                  shrinkWrap: true,
                  physics: const NextClampingScrollPhysics(),
                  controller: _scrollController,
                  padding: EdgeInsets.only(
                    bottom: 16 + BottomInsetScope.of(context),
                  ),
                  trackerInfos: requests,
                  detailTitle: appLocalizations.details(
                    appLocalizations.request,
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
