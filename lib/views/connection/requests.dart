import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'item.dart';

class RequestsView extends ConsumerStatefulWidget {
  const RequestsView({super.key});

  @override
  ConsumerState<RequestsView> createState() => _RequestsViewState();
}

class _RequestsViewState extends ConsumerState<RequestsView> {
  final _requestsStateNotifier = ValueNotifier<TrackerInfosState>(
    const TrackerInfosState(),
  );
  List<TrackerInfo> _requests = [];
  late ScrollController _scrollController;

  void _onSearch(String value) {
    _requestsStateNotifier.value = _requestsStateNotifier.value.copyWith(
      query: value,
    );
  }

  void _onKeywordsUpdate(List<String> keywords) {
    _requestsStateNotifier.value =
        _requestsStateNotifier.value.copyWith(keywords: keywords);
  }

  @override
  void initState() {
    super.initState();
    _requests = globalState.appState.requests.list;
    _scrollController = ScrollController(
      initialScrollOffset: _requests.length * TrackerInfoItem.height,
    );
    _requestsStateNotifier.value = _requestsStateNotifier.value.copyWith(
      trackerInfos: _requests,
    );
    ref.listenManual(
      requestsProvider.select((state) => state.list),
      (prev, next) {
        _requests = next;
      },
    );
  }

  @override
  void dispose() {
    _requestsStateNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void updateRequestsThrottler() {
    throttler.call(
      FunctionTag.requests,
      () {
        if (!mounted) {
          return;
        }
        final isEquality = trackerInfoListEquality.equals(
          _requests,
          _requestsStateNotifier.value.trackerInfos,
        );
        if (isEquality) {
          return;
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _requestsStateNotifier.value =
                _requestsStateNotifier.value.copyWith(
              trackerInfos: _requests,
            );
          }
        });
      },
      duration: commonDuration,
    );
  }

  List<Widget> _buildActions() {
    return [
      ValueListenableBuilder(
        valueListenable: _requestsStateNotifier,
        builder: (_, state, __) {
          return IconButton(
            style: state.autoScrollToEnd
                ? ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      context.colorScheme.secondaryContainer,
                    ),
                  )
                : null,
            onPressed: () {
              _requestsStateNotifier.value =
                  _requestsStateNotifier.value.copyWith(
                autoScrollToEnd: !_requestsStateNotifier.value.autoScrollToEnd,
              );
            },
            icon: const Icon(
              Icons.vertical_align_top_outlined,
            ),
          );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: appLocalizations.requests,
      actions: _buildActions(),
      searchState: AppBarSearchState(onSearch: _onSearch),
      onKeywordsUpdate: _onKeywordsUpdate,
      body: ValueListenableBuilder<TrackerInfosState>(
        valueListenable: _requestsStateNotifier,
        builder: (context, state, __) {
          final requests = state.list;
          if (requests.isEmpty) {
            return NullStatus(
              label: appLocalizations.nullTip(appLocalizations.requests),
            );
          }
          final items = requests
              .map<Widget>(
                (trackerInfo) => TrackerInfoItem(
                  key: Key(trackerInfo.id),
                  trackerInfo: trackerInfo,
                  onClickKeyword: (value) {
                    context.commonScaffoldState?.addKeyword(value);
                  },
                  detailTitle: appLocalizations.details(
                    appLocalizations.request,
                  ),
                ),
              )
              .separated(
                const Divider(
                  height: 0,
                ),
              )
              .toList();
          return Align(
            alignment: Alignment.topCenter,
            child: CommonScrollBar(
              trackVisibility: false,
              controller: _scrollController,
              child: ScrollToEndBox(
                controller: _scrollController,
                dataSource: requests,
                enable: state.autoScrollToEnd,
                onCancelToEnd: () {
                  _requestsStateNotifier.value =
                      _requestsStateNotifier.value.copyWith(
                    autoScrollToEnd: false,
                  );
                },
                child: ListView.builder(
                  reverse: true,
                  shrinkWrap: true,
                  physics: NextClampingScrollPhysics(),
                  controller: _scrollController,
                  itemBuilder: (_, index) {
                    return items[index];
                  },
                  itemExtentBuilder: (index, _) {
                    if (index.isOdd) {
                      return 0;
                    }
                    return TrackerInfoItem.height;
                  },
                  itemCount: items.length,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
