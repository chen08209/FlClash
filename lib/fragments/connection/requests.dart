import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'item.dart';

class RequestsFragment extends ConsumerStatefulWidget {
  const RequestsFragment({super.key});

  @override
  ConsumerState<RequestsFragment> createState() => _RequestsFragmentState();
}

class _RequestsFragmentState extends ConsumerState<RequestsFragment>
    with PageMixin {
  final GlobalKey<CacheItemExtentListViewState> _key = GlobalKey();
  final _requestsStateNotifier =
      ValueNotifier<ConnectionsState>(const ConnectionsState());
  List<Connection> _requests = [];
  final _cacheKey = ValueKey("requests_list");
  late ScrollController _scrollController;

  double _currentMaxWidth = 0;

  @override
  get onSearch => (value) {
        _requestsStateNotifier.value = _requestsStateNotifier.value.copyWith(
          query: value,
        );
      };

  @override
  get onKeywordsUpdate => (keywords) {
        _requestsStateNotifier.value =
            _requestsStateNotifier.value.copyWith(keywords: keywords);
      };

  @override
  void initState() {
    super.initState();
    final preOffset = globalState.cacheScrollPosition[_cacheKey] ?? -1;
    _scrollController = ScrollController(
      initialScrollOffset: preOffset > 0 ? preOffset : double.maxFinite,
    );
    _requestsStateNotifier.value = _requestsStateNotifier.value.copyWith(
      connections: globalState.appState.requests.list,
    );
    ref.listenManual(
      isCurrentPageProvider(
        PageLabel.requests,
        handler: (pageLabel, viewMode) =>
            pageLabel == PageLabel.tools && viewMode == ViewMode.mobile,
      ),
      (prev, next) {
        if (prev != next && next == true) {
          initPageState();
        }
      },
      fireImmediately: true,
    );
    ref.listenManual(
      requestsProvider.select((state) => state.list),
      (prev, next) {
        if (!connectionListEquality.equals(prev, next)) {
          _requests = next;
          updateRequestsThrottler();
        }
      },
      fireImmediately: true,
    );
  }

  double _calcCacheHeight(Connection item) {
    final size = globalState.measure.computeTextSize(
      Text(
        item.desc,
        style: context.textTheme.bodyLarge,
      ),
      maxWidth: _currentMaxWidth,
    );
    final chainsText = item.chains.join("");
    final length = item.chains.length;
    final chainSize = globalState.measure.computeTextSize(
      Text(
        chainsText,
        style: context.textTheme.bodyMedium,
      ),
      maxWidth: (_currentMaxWidth - (length - 1) * 6 - length * 24),
    );
    final baseHeight = globalState.measure.bodyMediumHeight;
    final lines = (chainSize.height / baseHeight).round();
    final computerHeight =
        size.height + chainSize.height + 24 + 24 * (lines - 1);
    return computerHeight;
  }

  _handleTryClearCache(double maxWidth) {
    if (_currentMaxWidth != maxWidth) {
      _currentMaxWidth = maxWidth;
      _key.currentState?.clearCache();
    }
  }

  @override
  void dispose() {
    _requestsStateNotifier.dispose();
    _scrollController.dispose();
    _currentMaxWidth = 0;
    super.dispose();
  }

  updateRequestsThrottler() {
    throttler.call("request", () {
      final isEquality = connectionListEquality.equals(
        _requests,
        _requestsStateNotifier.value.connections,
      );
      if (isEquality) {
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _requestsStateNotifier.value = _requestsStateNotifier.value.copyWith(
          connections: _requests,
        );
      });
    }, duration: commonDuration);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return Consumer(
          builder: (_, ref, child) {
            final value = ref.watch(
              patchClashConfigProvider.select(
                (state) =>
                    state.findProcessMode == FindProcessMode.always &&
                    Platform.isAndroid,
              ),
            );
            _handleTryClearCache(constraints.maxWidth - 40 - (value ? 60 : 0));
            return child!;
          },
          child: ValueListenableBuilder<ConnectionsState>(
            valueListenable: _requestsStateNotifier,
            builder: (_, state, __) {
              final connections = state.list;
              if (connections.isEmpty) {
                return NullStatus(
                  label: appLocalizations.nullRequestsDesc,
                );
              }
              final items = connections
                  .map<Widget>(
                    (connection) => ConnectionItem(
                      key: Key(connection.id),
                      connection: connection,
                      onClickKeyword: (value) {
                        context.commonScaffoldState?.addKeyword(value);
                      },
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
                child: ScrollToEndBox(
                  controller: _scrollController,
                  cacheKey: _cacheKey,
                  dataSource: connections,
                  child: CommonScrollBar(
                    controller: _scrollController,
                    child: CacheItemExtentListView(
                      key: _key,
                      reverse: true,
                      shrinkWrap: true,
                      physics: NextClampingScrollPhysics(),
                      controller: _scrollController,
                      itemExtentBuilder: (index) {
                        final widget = items[index];
                        if (widget.runtimeType == Divider) {
                          return 0;
                        }
                        final measure = globalState.measure;
                        final bodyMediumHeight = measure.bodyMediumHeight;
                        final connection = connections[(index / 2).floor()];
                        final height = _calcCacheHeight(connection);
                        return height + bodyMediumHeight + 32;
                      },
                      itemBuilder: (_, index) {
                        return items[index];
                      },
                      itemCount: items.length,
                      keyBuilder: (int index) {
                        final widget = items[index];
                        if (widget.runtimeType == Divider) {
                          return "divider";
                        }
                        final connection = connections[(index / 2).floor()];
                        return connection.id;
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
