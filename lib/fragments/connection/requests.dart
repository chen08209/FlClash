import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'item.dart';

double _preOffset = 0;

class RequestsFragment extends StatefulWidget {
  const RequestsFragment({super.key});

  @override
  State<RequestsFragment> createState() => _RequestsFragmentState();
}

class _RequestsFragmentState extends State<RequestsFragment> with ViewMixin {
  final _requestsStateNotifier =
      ValueNotifier<ConnectionsState>(const ConnectionsState());
  List<Connection> _requests = [];

  final ScrollController _scrollController = ScrollController(
    initialScrollOffset: _preOffset != 0 ? _preOffset : double.maxFinite,
  );

  final FixedMap<String, double?> _cacheDynamicHeightMap = FixedMap(1000);

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
    final appController = globalState.appController;
    final appState = appController.appState;
    _requestsStateNotifier.value = _requestsStateNotifier.value.copyWith(
      connections: appState.requests,
    );
  }

  _initActions() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        initViewState();
      },
    );
  }

  double _calcCacheHeight(Connection item) {
    final cacheHeight = _cacheDynamicHeightMap.get(item.id);
    if (cacheHeight != null) {
      return cacheHeight;
    }
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
    _cacheDynamicHeightMap.put(item.id, computerHeight);
    return computerHeight;
  }

  _handleTryClearCache(double maxWidth) {
    if (_currentMaxWidth != maxWidth) {
      _currentMaxWidth = maxWidth;
      _cacheDynamicHeightMap.clear();
    }
  }

  @override
  void dispose() {
    _requestsStateNotifier.dispose();
    _scrollController.dispose();
    _currentMaxWidth = 0;
    _cacheDynamicHeightMap.clear();
    super.dispose();
  }

  Widget _wrapPage(Widget child) {
    return Selector<AppState, bool?>(
      selector: (_, appState) =>
          appState.currentLabel == 'requests' ||
          appState.viewMode == ViewMode.mobile &&
              appState.currentLabel == "tools",
      builder: (_, isCurrent, child) {
        if (isCurrent == null || isCurrent) {
          _initActions();
        }
        return child!;
      },
      child: child,
    );
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

  Widget _wrapRequestsUpdate(Widget child) {
    return Selector<AppState, List<Connection>>(
      selector: (_, appState) => appState.requests,
      shouldRebuild: (prev, next) {
        final isEquality = connectionListEquality.equals(prev, next);
        if (!isEquality) {
          _requests = next;
          updateRequestsThrottler();
        }
        return !isEquality;
      },
      builder: (_, next, child) {
        return child!;
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return FindProcessBuilder(builder: (value) {
          _handleTryClearCache(constraints.maxWidth - 40 - (value ? 60 : 0));
          return _wrapPage(
            _wrapRequestsUpdate(
              ValueListenableBuilder<ConnectionsState>(
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
                          onClick: (value) {
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
                    child: NotificationListener<ScrollEndNotification>(
                      onNotification: (details) {
                        _preOffset = details.metrics.pixels;
                        return false;
                      },
                      child: CommonScrollBar(
                        controller: _scrollController,
                        child: ListView.builder(
                          reverse: true,
                          shrinkWrap: true,
                          physics: NextClampingScrollPhysics(),
                          controller: _scrollController,
                          itemExtentBuilder: (index, __) {
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
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        });
      },
    );
  }
}
