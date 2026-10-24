part of 'connections_table.dart';

class _ApplicationProxyView extends ConsumerStatefulWidget {
  const _ApplicationProxyView({this.scrollController});

  final ScrollController? scrollController;

  @override
  ConsumerState<_ApplicationProxyView> createState() =>
      _ApplicationProxyViewState();
}

class _ApplicationProxyViewState extends ConsumerState<_ApplicationProxyView>
    with
        WidgetsBindingObserver,
        ActivePollingMixin<_ApplicationProxyView>,
        RouteMotionHoldMixin<_ApplicationProxyView>,
        ConnectionsPolling<_ApplicationProxyView> {
  @override
  bool get pollsConnections => true;

  @override
  bool get sortsConnections => false;

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: context.appLocalizations.applicationProxy,
      body: Builder(
        builder: (context) => Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, context.bottomInset + 16),
          child: ApplicationProxyPanel(
            connections: connections,
            sampledAt: connectionsSampledAt,
            stale: connectionsStale,
            rowHeight: 44 * MediaQuery.textScalerOf(context).scale(1),
            scrollController: widget.scrollController,
          ),
        ),
      ),
    );
  }
}

class ApplicationProxyPanel extends ConsumerStatefulWidget {
  const ApplicationProxyPanel({
    super.key,
    required this.connections,
    required this.sampledAt,
    required this.stale,
    required this.rowHeight,
    this.scrollController,
    this.onCountChanged,
    this.isWindows,
  });

  final List<TrackerInfo> connections;
  final DateTime? sampledAt;
  final bool stale;
  final double rowHeight;
  final ScrollController? scrollController;
  final ValueChanged<int>? onCountChanged;
  final bool? isWindows;

  @override
  ConsumerState<ApplicationProxyPanel> createState() =>
      _ApplicationProxyPanelState();
}

class _ApplicationProxyPanelState extends ConsumerState<ApplicationProxyPanel> {
  String? _saving;
  String? _error;

  @override
  void initState() {
    super.initState();
    ref.listenManual(currentProfileIdProvider, (_, _) {
      setState(() => _error = null);
    });
  }

  Future<void> _change(
    int profileId,
    ApplicationIdentity application,
    String? target,
  ) async {
    if (_saving != null || ref.read(currentProfileIdProvider) != profileId) {
      return;
    }
    final l = context.appLocalizations;
    setState(() {
      _saving = application.key;
      _error = null;
    });
    // ignore: avoid_print
    print('>>> _change start key=${application.key} mounted=$mounted');
    try {
      final applied = await ref
          .read(setupActionProvider.notifier)
          .setApplicationProxy(
            profileId: profileId,
            application: application,
            target: target,
          );
      // ignore: avoid_print
      print('>>> _change returned applied=$applied');
      if (!applied && mounted && ref.read(currentProfileIdProvider) == profileId) {
        setState(() => _error = l.applicationProxyApplyFailed);
      }
    } catch (error) {
      // ignore: avoid_print
      print('>>> _change error $error');
      if (mounted && ref.read(currentProfileIdProvider) == profileId) {
        setState(() => _error = error.toString());
      }
    } finally {
      // ignore: avoid_print
      print('>>> _change finally mounted=$mounted');
      if (mounted) setState(() => _saving = null);
    }
  }

  Widget _policy(
    ApplicationProxyInfo application,
    int? profileId,
    bool editable,
    List<String> groups,
  ) {
    final l = context.appLocalizations;
    final identity = application.identity;
    String label(String? target) => switch (target) {
      null => l.applicationProxyFollowRules,
      'DIRECT' => l.direct,
      String value => value,
    };
    final enabled = editable && identity?.canRoute == true && _saving == null;
    // ignore: avoid_print
    print(
      '>>> _policy saving=$_saving identityKey=${identity?.key} '
      'identityNull=${identity == null} enabled=$enabled',
    );
    return CommonPopupBox(
      targetBuilder: (open) => TextButton(
        onPressed: enabled ? open : null,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          minimumSize: Size.zero,
        ),
        child: _saving != null && _saving == identity?.key
            ? const SizedBox.square(
                dimension: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  Flexible(
                    child: Text(
                      identity == null ? l.unknown : label(application.target),
                    ),
                  ),
                  if (enabled)
                    const GlyphIcon(AppGlyphs.chevronDown, size: 12),
                ],
              ),
      ),
      popupBuilder: (_) => CommonPopupMenu(
        maxVisibleItems: 7,
        items: [
          for (final target in <String?>[null, 'DIRECT', ...groups])
            CommonPopupMenuItem(
              label: label(target),
              checked: target == application.target,
              onPressed: enabled
                  ? () => _change(profileId!, identity!, target)
                  : null,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    // ignore: avoid_print
    print('>>> panel build saving=$_saving');
    final profile = ref.watch(currentProfileProvider);
    final profileId = profile?.id;
    final editable = profile != null &&
        (profile.type == ProfileType.custom ||
            profile.extendType == ExtendType.standard);
    final rulesState = profileId == null || !editable
        ? const AsyncData<List<Rule>>([])
        : ref.watch(applicationRulesProvider(profileId));
    final patch = ref.watch(patchClashConfigProvider);
    final invalidTarget = RegExp(r'[,\r\n]');
    final groups = ref.watch(groupsProvider)
        .map((group) => group.name)
        .where((name) => name != 'DIRECT' && !invalidTarget.hasMatch(name))
        .toSet()
        .toList();
    String? action;
    VoidCallback? onAction;
    String notice;
    if (widget.stale) {
      notice = l.applicationProxyRefreshFailed;
    } else if (profile == null) {
      notice = l.applicationProxyNoProfile;
    } else if (!editable) {
      notice = l.applicationProxyScriptUnsupported;
    } else if (patch.mode != Mode.rule) {
      notice = l.applicationProxyRuleMode;
      action = l.rule;
      onAction = () =>
          ref.read(setupActionProvider.notifier).changeMode(Mode.rule);
    } else if (patch.findProcessMode != FindProcessMode.always) {
      notice = l.applicationProxyEnableProcess;
      action = l.findProcessMode;
      onAction = () => ref.read(patchClashConfigProvider.notifier).update(
        (state) => state.copyWith(findProcessMode: FindProcessMode.always),
      );
    } else {
      notice = l.applicationProxyScope;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _cellInset),
          child: Row(
            spacing: 8,
            children: [
              Expanded(
                child: Tooltip(
                  message: _error ?? notice,
                  child: Text(
                    _error ?? notice,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.caption1.of(context).copyWith(
                      color: _error == null
                          ? context.colorScheme.onSurfaceVariant
                          : context.colorScheme.error,
                    ),
                  ),
                ),
              ),
              if (action != null)
                TextButton(
                  onPressed: _saving == null ? onAction : null,
                  child: Text(action),
                ),
              Tooltip(
                message: l.applicationProxyCoverage,
                child: const GlyphIcon(AppGlyphs.info, size: 16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: rulesState.hasError
              ? Center(child: Text(l.error))
              : rulesState.value == null
              ? const SizedBox.shrink()
              : _ApplicationRows(
                  key: ValueKey(profileId),
                  connections: widget.connections,
                  sampledAt: widget.sampledAt,
                  stale: widget.stale,
                  rules: rulesState.value!,
                  isWindows: widget.isWindows ?? system.isWindows,
                  aggregator: ref.watch(applicationProxyAggregatorProvider),
                  rowHeight: widget.rowHeight,
                  scrollController: widget.scrollController,
                  onCountChanged: widget.onCountChanged,
                  policyBuilder: (application) => _policy(
                    application,
                    profileId,
                    editable,
                    groups,
                  ),
                ),
        ),
      ],
    );
  }
}

class _ApplicationRows extends StatefulWidget {
  const _ApplicationRows({
    super.key,
    required this.connections,
    required this.sampledAt,
    required this.stale,
    required this.rules,
    required this.isWindows,
    required this.aggregator,
    required this.rowHeight,
    required this.policyBuilder,
    this.scrollController,
    this.onCountChanged,
  });

  final List<TrackerInfo> connections;
  final DateTime? sampledAt;
  final bool stale;
  final List<Rule> rules;
  final bool isWindows;
  final ApplicationProxyAggregator aggregator;
  final double rowHeight;
  final Widget Function(ApplicationProxyInfo application) policyBuilder;
  final ScrollController? scrollController;
  final ValueChanged<int>? onCountChanged;

  @override
  State<_ApplicationRows> createState() => _ApplicationRowsState();
}

class _ApplicationRowsState extends State<_ApplicationRows>
    with RouteMotionHoldMixin<_ApplicationRows> {
  ApplicationProxySnapshot? _snapshot;
  int _generation = 0;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_refresh());
  }

  @override
  void didUpdateWidget(covariant _ApplicationRows oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.connections, oldWidget.connections) ||
        widget.sampledAt != oldWidget.sampledAt ||
        !identical(widget.rules, oldWidget.rules)) {
      unawaited(_refresh());
    }
  }

  Future<void> _refresh() async {
    final generation = ++_generation;
    try {
      final snapshot = await widget.aggregator((
        connections: applicationConnectionsOf(widget.connections),
        rules: widget.rules,
        sampledAt: widget.sampledAt,
        previousSamples: _snapshot?.samples ?? const {},
        previousAt: _snapshot?.sampledAt,
        windows: widget.isWindows,
      ));
      if (!mounted || generation != _generation) return;
      void show() {
        if (!mounted || generation != _generation) return;
        setState(() {
          _snapshot = snapshot;
          _failed = false;
        });
        widget.onCountChanged?.call(snapshot.applications.length);
      }
      if (_snapshot == null) {
        show();
      } else {
        updateWhenRouteSettled(show);
      }
    } catch (error) {
      if (!mounted || generation != _generation) return;
      commonPrint.log('application proxy statistics error: $error');
      setState(() => _failed = true);
    }
  }

  String _speed(ApplicationProxyInfo application, bool download) => widget.stale
      ? '—'
      : '${dashboardTraffic(download ? application.downloadSpeed : application.uploadSpeed)}/s';

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    // ignore: avoid_print
    print('>>> rows build');
    if (_failed) return Center(child: Text(l.error));
    final applications = _snapshot?.applications;
    if (applications == null) return const SizedBox.shrink();
    if (applications.isEmpty) {
      return Center(child: Text(l.applicationProxyNoConnections));
    }
    return _Table<ApplicationProxyInfo>(
      tableId: 'dashboard.applications',
      items: applications,
      rowHeight: widget.rowHeight,
      maxRows: null,
      scrollController: widget.scrollController,
      columnsOf: (width) => [
        RecordColumn(
          TableColumn('application', l.app, flex: 1),
          cell: (_, item) => Tooltip(
            message: item.identity?.content ?? l.unknown,
            child: _Source(item.identity?.name ?? l.unknown),
          ),
          sortKey: (item) => item.identity?.name.toLowerCase() ?? '',
        ),
        RecordColumn(
          TableColumn('status', l.status, width: 76),
          cell: (_, item) => _ApplicationRouteText(item),
          sortKey: (item) => item.route.index,
        ),
        RecordColumn(
          TableColumn('policy', l.strategy, width: width < _midTableWidth ? 112 : 144),
          cell: (_, item) => widget.policyBuilder(item),
          sortKey: (item) => item.target ?? '',
        ),
        if (width >= _midTableWidth) ...[
          RecordColumn(
            TableColumn('connections', l.liveConnections, width: 70, end: true),
            cell: (_, item) => _Number(dashboardCount(item.connections)),
            sortKey: (item) => item.connections,
            descendingFirst: true,
          ),
          for (final download in [true, false])
            RecordColumn(
              TableColumn(
                download ? 'download' : 'upload',
                download ? l.download : l.upload,
                width: 80,
                end: true,
              ),
              cell: (_, item) => Tooltip(
                message: dashboardTraffic(download ? item.download : item.upload),
                child: _Number(_speed(item, download)),
              ),
              sortKey: (item) => download ? item.downloadSpeed : item.uploadSpeed,
              descendingFirst: true,
            ),
        ] else
          RecordColumn(
            TableColumn('speed', l.networkSpeed, width: 88, end: true),
            cell: (_, item) => Tooltip(
              message: '${l.download}: ${_speed(item, true)} · ${l.upload}: ${_speed(item, false)}',
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final download in [true, false])
                    Text(
                      '${download ? '↓' : '↑'} ${_speed(item, download)}',
                      style: AppTextStyle.caption2.of(context).toTabular,
                    ),
                ],
              ),
            ),
            sortKey: (item) => item.downloadSpeed + item.uploadSpeed,
            descendingFirst: true,
          ),
      ],
    );
  }
}

class _ApplicationRouteText extends StatelessWidget {
  const _ApplicationRouteText(this.application);

  final ApplicationProxyInfo application;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final label = application.route.label;
    return Tooltip(
      message: [
        label,
        '${l.proxies}: ${application.proxy}',
        '${l.direct}: ${application.direct}',
        '${l.applicationProxyBlocked}: ${application.blocked}',
        '${l.unknown}: ${application.unknown}',
      ].join(' · '),
      child: Text(
        label,
        style: TextStyle(
          color: switch (application.route) {
            ApplicationRoute.direct => context.colorScheme.success,
            ApplicationRoute.mixed => context.colorScheme.warning,
            ApplicationRoute.blocked => context.colorScheme.error,
            _ => context.colorScheme.onSurfaceVariant,
          },
        ),
      ),
    );
  }
}
