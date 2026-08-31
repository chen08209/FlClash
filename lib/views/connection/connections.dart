import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/features/features.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectionsView extends ConsumerStatefulWidget {
  final Future<List<TrackerInfo>> Function()? connectionsReader;

  const ConnectionsView({super.key, @visibleForTesting this.connectionsReader});

  @override
  ConsumerState<ConnectionsView> createState() => _ConnectionsViewState();
}

class _ConnectionsViewState extends ConsumerState<ConnectionsView>
    with WidgetsBindingObserver, ActivePollingMixin<ConnectionsView> {
  CoreController get _core => ref.read(coreHandlerProvider);

  final _listController = TrackerInfoListController();
  final ScrollController _scrollController = ScrollController();

  @override
  Duration get pollInterval => const Duration(seconds: 1);

  List<Widget> _buildActions() {
    return [
      IconButton(
        tooltip: context.appLocalizations.closeConnections,
        onPressed: () async {
          unawaited(_core.closeConnections());
          await _refreshConnections();
        },
        icon: const Icon(Icons.delete_sweep_outlined),
      ),
    ];
  }

  @override
  Future<void> poll(PollGuard isCurrent) async {
    final trackerInfos = await _readConnections();
    if (trackerInfos == null || !isCurrent()) {
      return;
    }
    _applyConnections(trackerInfos);
  }

  Future<void> _refreshConnections() async {
    final trackerInfos = await _readConnections();
    if (trackerInfos == null || !mounted) {
      return;
    }
    _applyConnections(trackerInfos);
  }

  Future<List<TrackerInfo>?> _readConnections() async {
    try {
      final connectionsReader = widget.connectionsReader;
      return connectionsReader != null
          ? await connectionsReader()
          : await _core.getConnections();
    } catch (error) {
      commonPrint.log(
        'updateConnections error: $error',
        logLevel: coreFailureLogLevel(error),
      );
      return null;
    }
  }

  void _applyConnections(List<TrackerInfo> trackerInfos) {
    _listController.setTrackerInfos(trackerInfos);
  }

  Future<void> _handleBlockConnection(String id) async {
    await _core.closeConnection(id);
    await _refreshConnections();
  }

  @override
  void dispose() {
    _listController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonScaffold(
      title: appLocalizations.connections,
      onKeywordsUpdate: _listController.updateKeywords,
      searchState: AppBarSearchState(onSearch: _listController.search),
      actions: _buildActions(),
      body: ValueListenableBuilder<TrackerInfosState>(
        valueListenable: _listController,
        builder: (context, state, _) {
          final connections = state.list;
          if (connections.isEmpty) {
            return NullStatus(
              label: appLocalizations.nullTip(appLocalizations.connections),
              illustration: const ConnectionEmptyIllustration(),
            );
          }
          return TrackerInfoAnimatedList(
            controller: _scrollController,
            trackerInfos: connections,
            detailTitle: appLocalizations.details(appLocalizations.connection),
            trailingBuilder: (trackerInfo) => IconButton(
              tooltip: appLocalizations.blockConnection,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.block, size: 20),
              onPressed: () {
                _handleBlockConnection(trackerInfo.id);
              },
            ),
          );
        },
      ),
    );
  }
}
