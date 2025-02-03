import 'dart:async';

import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'item.dart';

class ConnectionsFragment extends StatefulWidget {
  const ConnectionsFragment({super.key});

  @override
  State<ConnectionsFragment> createState() => _ConnectionsFragmentState();
}

class _ConnectionsFragmentState extends State<ConnectionsFragment>
    with ViewMixin {
  final _connectionsStateNotifier = ValueNotifier<ConnectionsState>(
    const ConnectionsState(),
  );
  final ScrollController _scrollController = ScrollController(
    keepScrollOffset: false,
  );

  Timer? timer;

  @override
  List<Widget> get actions => [
        IconButton(
          onPressed: () async {
            clashCore.closeConnections();
            _connectionsStateNotifier.value =
                _connectionsStateNotifier.value.copyWith(
              connections: await clashCore.getConnections(),
            );
          },
          icon: const Icon(Icons.delete_sweep_outlined),
        ),
      ];

  @override
  get onSearch => (value) {
        _connectionsStateNotifier.value =
            _connectionsStateNotifier.value.copyWith(
          query: value,
        );
      };

  @override
  get onKeywordsUpdate => (keywords) {
        _connectionsStateNotifier.value =
            _connectionsStateNotifier.value.copyWith(keywords: keywords);
      };

  _updateConnections() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _connectionsStateNotifier.value =
          _connectionsStateNotifier.value.copyWith(
        connections: await clashCore.getConnections(),
      );
      timer = Timer(Duration(seconds: 1), () async {
        _updateConnections();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _updateConnections();
  }

  _initActions() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        initViewState();
      },
    );
  }

  _handleBlockConnection(String id) async {
    clashCore.closeConnection(id);
    _connectionsStateNotifier.value = _connectionsStateNotifier.value.copyWith(
      connections: await clashCore.getConnections(),
    );
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
    return Selector<AppState, bool?>(
      selector: (_, appState) =>
          appState.currentLabel == 'connections' ||
          appState.viewMode == ViewMode.mobile &&
              appState.currentLabel == "tools",
      builder: (_, isCurrent, child) {
        if (isCurrent == null || isCurrent) {
          _initActions();
        }
        return child!;
      },
      child: ValueListenableBuilder<ConnectionsState>(
        valueListenable: _connectionsStateNotifier,
        builder: (_, state, __) {
          final connections = state.list;
          if (connections.isEmpty) {
            return NullStatus(
              label: appLocalizations.nullConnectionsDesc,
            );
          }
          return CommonScrollBar(
            controller: _scrollController,
            child: ListView.separated(
              controller: _scrollController,
              itemBuilder: (_, index) {
                final connection = connections[index];
                return ConnectionItem(
                  key: Key(connection.id),
                  connection: connection,
                  onClick: (value) {
                    context.commonScaffoldState?.addKeyword(value);
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.block),
                    onPressed: () {
                      _handleBlockConnection(connection.id);
                    },
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(
                  height: 0,
                );
              },
              itemCount: connections.length,
            ),
          );
        },
      ),
    );
  }
}
