import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  Timer? timer;

  List<Widget> _buildActions() {
    return [
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
        timer = Timer(Duration(seconds: 1), () async {
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
    _connectionsStateNotifier.value = _connectionsStateNotifier.value.copyWith(
      trackerInfos: await coreController.getConnections(),
    );
  }

  Future<void> _handleBlockConnection(String id) async {
    coreController.closeConnection(id);
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
    return CommonScaffold(
      title: appLocalizations.connections,
      onKeywordsUpdate: _onKeywordsUpdate,
      searchState: AppBarSearchState(onSearch: _onSearch),
      actions: _buildActions(),
      body: ValueListenableBuilder<TrackerInfosState>(
        valueListenable: _connectionsStateNotifier,
        builder: (context, state, _) {
          final connections = state.list;
          if (connections.isEmpty) {
            return NullStatus(
              label: appLocalizations.nullTip(appLocalizations.connections),
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
          return ListView.builder(
            controller: _scrollController,
            itemBuilder: (context, index) {
              return items[index];
            },
            itemExtentBuilder: (index, _) {
              if (index.isOdd) {
                return 0;
              }
              return TrackerInfoItem.height;
            },
            itemCount: connections.length,
          );
        },
      ),
    );
  }
}
