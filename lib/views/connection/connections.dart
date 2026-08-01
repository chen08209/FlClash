import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import 'item.dart';

class ConnectionsView extends ConsumerStatefulWidget {
  const ConnectionsView({super.key});

  @override
  ConsumerState<ConnectionsView> createState() => _ConnectionsViewState();
}

class _ConnectionsViewState extends ConsumerState<ConnectionsView> {
  final _connectionsStateNotifier = ValueNotifier<TrackerInfosState>(
    const TrackerInfosState(),
  );
  final ScrollController _scrollController = ScrollController();
  ConnectionSortType _sortType = ConnectionSortType.none;
  DateTime? _lastUpdateTime;

  Timer? timer;

  String _getSortLabel(BuildContext context, ConnectionSortType sortType) {
    final appLocalizations = context.appLocalizations;
    return switch (sortType) {
      ConnectionSortType.none => appLocalizations.defaultText,
      ConnectionSortType.downloadDesc => '${appLocalizations.download} ↓',
      ConnectionSortType.downloadAsc => '${appLocalizations.download} ↑',
      ConnectionSortType.uploadDesc => '${appLocalizations.upload} ↓',
      ConnectionSortType.uploadAsc => '${appLocalizations.upload} ↑',
      ConnectionSortType.processAsc => '${appLocalizations.process} ↑',
      ConnectionSortType.processDesc => '${appLocalizations.process} ↓',
    };
  }

  List<Widget> _buildActions(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return [
      PopupMenuButton<ConnectionSortType>(
        tooltip:
            '${appLocalizations.sort}: ${_getSortLabel(context, _sortType)}',
        icon: const Icon(Icons.sort),
        onSelected: (sortType) {
          setState(() {
            _sortType = sortType;
          });
        },
        itemBuilder: (context) {
          return [
            for (final item in ConnectionSortType.values)
              CheckedPopupMenuItem<ConnectionSortType>(
                value: item,
                checked: item == _sortType,
                child: Text(_getSortLabel(context, item)),
              ),
          ];
        },
      ),
      IconButton(
        onPressed: () async {
          coreController.closeConnections();
          await _updateConnections();
        },
        icon: const Icon(Icons.delete_sweep_outlined),
      ),
    ];
  }

  void _onSearch(String value) {
    _connectionsStateNotifier.value = _connectionsStateNotifier.value.copyWith(
      query: value,
    );
  }

  void _onKeywordsUpdate(List<String> keywords) {
    _connectionsStateNotifier.value = _connectionsStateNotifier.value.copyWith(
      keywords: keywords,
    );
  }

  Future<void> _updateConnectionsTask() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await _updateConnections();
        timer = Timer(const Duration(seconds: 1), () async {
          _updateConnectionsTask();
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _updateConnectionsTask();
  }

  Future<void> _updateConnections() async {
    final trackerInfos = await coreController.getConnections();
    final updateTime = DateTime.now();
    final previousUpdateTime = _lastUpdateTime;
    final previousById = {
      for (final item in _connectionsStateNotifier.value.trackerInfos)
        item.id: item,
    };
    final elapsed = previousUpdateTime == null
        ? Duration.zero
        : updateTime.difference(previousUpdateTime);
    final trackerInfosWithSpeed = trackerInfos.map((item) {
      return item.withSpeedFrom(previousById[item.id], elapsed);
    }).toList();
    _lastUpdateTime = updateTime;
    _connectionsStateNotifier.value = _connectionsStateNotifier.value.copyWith(
      trackerInfos: trackerInfosWithSpeed,
    );
  }

  Future<void> _handleBlockConnection(String id) async {
    await coreController.closeConnection(id);
    await _updateConnections();
  }

  @override
  void dispose() {
    timer?.cancel();
    _connectionsStateNotifier.dispose();
    _scrollController.dispose();
    timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonScaffold(
      title: appLocalizations.connections,
      onKeywordsUpdate: _onKeywordsUpdate,
      searchState: AppBarSearchState(onSearch: _onSearch),
      actions: _buildActions(context),
      body: ValueListenableBuilder<TrackerInfosState>(
        valueListenable: _connectionsStateNotifier,
        builder: (context, state, _) {
          final connections = state.list.sortedBy(_sortType);
          if (connections.isEmpty) {
            return NullStatus(
              label: appLocalizations.nullTip(appLocalizations.connections),
              illustration: const ConnectionEmptyIllustration(),
            );
          }
          final items = connections
              .map<Widget>(
                (trackerInfo) => TrackerInfoItem(
                  key: Key(trackerInfo.id),
                  trackerInfo: trackerInfo,
                  onClickKeyword: (value) {
                    context.commonScaffoldState?.addKeyword(value);
                  },
                  trailing: IconButton(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(minimumSize: Size.zero),
                    icon: const Icon(Icons.block),
                    onPressed: () {
                      _handleBlockConnection(trackerInfo.id);
                    },
                  ),
                  detailTitle: appLocalizations.details(
                    appLocalizations.connection,
                  ),
                ),
              )
              .separated(const Divider(height: 0))
              .toList();
          return SuperListView.builder(
            controller: _scrollController,
            itemBuilder: (context, index) {
              return items[index];
            },
            itemCount: connections.length,
          );
        },
      ),
    );
  }
}
