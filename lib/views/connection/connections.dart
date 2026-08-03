import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
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

class _ConnectionsViewState extends ConsumerState<ConnectionsView>
    with WidgetsBindingObserver {
  final _connectionsStateNotifier = ValueNotifier<TrackerInfosState>(
    const TrackerInfosState(),
  );
  final ScrollController _scrollController = ScrollController();

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

  bool get _isPageActive {
    if (!mounted) {
      return false;
    }
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) {
      return false;
    }
    return WidgetsBinding.instance.lifecycleState ==
            AppLifecycleState.resumed ||
        WidgetsBinding.instance.lifecycleState == null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.listenManual(connectionsSnapshotProvider, (prev, next) {
      if (!_isPageActive) {
        return;
      }
      _applyTrackerInfos(next);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      await _updateConnections();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _updateConnections();
    }
  }

  bool _isSameSnapshot(List<TrackerInfo> previous, List<TrackerInfo> next) {
    if (identical(previous, next)) {
      return true;
    }
    if (previous.length != next.length) {
      return false;
    }
    for (var i = 0; i < previous.length; i++) {
      final a = previous[i];
      final b = next[i];
      if (a.id != b.id ||
          a.upload != b.upload ||
          a.download != b.download ||
          a.uploadSpeed != b.uploadSpeed ||
          a.downloadSpeed != b.downloadSpeed ||
          a.rule != b.rule ||
          a.rulePayload != b.rulePayload) {
        return false;
      }
    }
    return true;
  }

  void _applyTrackerInfos(List<TrackerInfo> trackerInfos) {
    final current = _connectionsStateNotifier.value;
    if (_isSameSnapshot(current.trackerInfos, trackerInfos)) {
      return;
    }
    _connectionsStateNotifier.value = current.copyWith(
      trackerInfos: trackerInfos,
    );
  }

  Future<void> _updateConnections() async {
    final trackerInfos = await coreController.getConnections();
    if (!mounted) {
      return;
    }
    _applyTrackerInfos(trackerInfos);
  }

  Future<void> _handleBlockConnection(String id) async {
    await coreController.closeConnection(id);
    await _updateConnections();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectionsStateNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildConnectionItem(TrackerInfo trackerInfo) {
    final appLocalizations = context.appLocalizations;
    return TrackerInfoItem(
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
      detailTitle: appLocalizations.details(appLocalizations.connection),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
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
              illustration: const ConnectionEmptyIllustration(),
            );
          }
          final itemCount = connections.length * 2 - 1;
          return SuperListView.builder(
            controller: _scrollController,
            itemBuilder: (context, index) {
              if (index.isOdd) {
                return const Divider(height: 0);
              }
              return _buildConnectionItem(connections[index ~/ 2]);
            },
            itemCount: itemCount,
          );
        },
      ),
    );
  }
}
