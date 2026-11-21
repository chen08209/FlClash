import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/features.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'http_capture.dart';

/// Every connection of this run, open or closed, newest first. The log the
/// Core's events keep is shown as it changes; polling the open connections
/// adds their speeds and settles what the events missed.
class RequestsView extends ConsumerStatefulWidget {
  final ScrollController? scrollController;
  final Future<List<TrackerInfo>> Function()? connectionsReader;

  const RequestsView({
    super.key,
    this.scrollController,
    @visibleForTesting this.connectionsReader,
  });

  @override
  ConsumerState<RequestsView> createState() => _RequestsViewState();
}

class _RequestsViewState extends ConsumerState<RequestsView>
    with
        WidgetsBindingObserver,
        ActivePollingMixin<RequestsView>,
        RouteMotionHoldMixin<RequestsView> {
  final _list = TrackerInfoListController();
  late final _filters = ConnectionFilterController.saved(
    ref,
    'requests',
    onAskCondition: _askCondition,
  );
  late final ScrollController _scrollController;
  late final _physics = FollowEndScrollPhysics(
    isFollowing: () => _list.value.autoScrollToEnd,
  );
  final _selected = ValueNotifier<String?>(null);

  /// The rows as the list shows them, top down.
  Iterable<TrackerInfo> Function() _shownOrder = () => const [];
  var _cardShown = false;
  BuildContext? _sheet;
  final _paused = ValueNotifier(false);
  late final _menuActions = TrackerMenuActions(
    close: _closeConnection,
    onlyApp: _onlyApp,
    hideHost: _hideHost,
  );
  TrackerInfosState? _presentedState;
  _Presented? _presented;
  var _ranking = TrackerRanking.empty;
  var _reads = 0;
  var _shownRead = 0;

  CoreController get _core => ref.read(coreHandlerProvider);

  /// The dashboard's sheet can show over this page, each refreshing its own.
  late final _refreshTag = (FunctionTag.requests, this);

  @override
  void initState() {
    super.initState();
    _scrollController =
        widget.scrollController ?? sheetScrollController(context);
    _follow();
    _filters.addListener(_forgetPresented);
    ref.listenManual(requestsProvider.select((state) => state.revision), (
      _,
      _,
    ) {
      _dropGone();
      _scheduleRefresh();
    });
  }

  @override
  void dispose() {
    throttler.cancel(_refreshTag);
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    _list.dispose();
    _filters.dispose();
    _selected.dispose();
    _paused.dispose();
    super.dispose();
  }

  @override
  Duration get pollInterval => const Duration(seconds: 1);

  @override
  Future<void> poll(PollGuard isCurrent) => _readConnections();

  Future<void> _readConnections() async {
    final read = ++_reads;
    final rank = rankAfter(_ranking);
    final requestedAt = DateTime.now();
    try {
      final connectionsReader = widget.connectionsReader;
      final ranked = connectionsReader != null
          ? rank(await connectionsReader())
          : ref.read(coreStatusProvider) == CoreStatus.connected
          ? await _core.getConnectionsWith(rank)
          : rank(const []);
      // A refresh after closing a connection can overlap a poll.
      if (read < _shownRead || !mounted) {
        return;
      }
      _shownRead = read;
      _ranking = ranked.ranking;
      ref
          .read(requestsProvider.notifier)
          .sync(ranked.trackerInfos, requestedAt: requestedAt);
    } catch (error) {
      commonPrint.log(
        'updateConnections error: $error',
        logLevel: coreFailureLogLevel(error),
      );
    }
  }

  /// Pausing holds only the refresh each poll brings; what the user does to
  /// the log shows at once.
  void _scheduleRefresh({bool evenPaused = false}) {
    if (_paused.value && !evenPaused) {
      return;
    }
    if (evenPaused) {
      // A refresh already queued would swallow this one, then find the list
      // paused and drop it.
      throttler.cancel(_refreshTag);
    }
    throttler.call(_refreshTag, () {
      if (!mounted || _paused.value && !evenPaused) {
        return;
      }
      updateWhenRouteSettled(() {
        _list.setTrackerInfos(
          ref.read(requestsProvider).list,
          shown: (items) => _filters.present(items).items,
        );
        _filters.offer(_list.value.trackerInfos);
      });
    }, duration: renderThrottleDuration);
  }

  void _follow() {
    _list.resumeAutoScrollToEnd(ref.read(requestsProvider).list);
    _filters.offer(_list.value.trackerInfos);
  }

  Future<void> _close(Future<void> Function() close) async {
    await globalState.safeRun(close, title: 'close connections');
    if (mounted) {
      await _readConnections();
    }
    if (mounted) {
      _scheduleRefresh(evenPaused: true);
    }
  }

  String get _detailTitle {
    final appLocalizations = context.appLocalizations;
    return appLocalizations.details(appLocalizations.connection);
  }

  void _select(TrackerInfo trackerInfo) {
    _selected.value = trackerInfo.id;
    if (!_cardShown && _sheet == null) {
      _openSheet();
    }
  }

  Future<void> _openSheet() async {
    await showNestedSheet<void>(
      context,
      builder: (context) {
        _sheet = context;
        return TrackerInfoDetailSheet(
          selected: _selected,
          title: _detailTitle,
          refresh: _list,
          actions: _menuActions,
          onStep: _step,
          canStep: (step) => _stepTarget(step) != null,
        );
      },
    );
    _sheet = null;
    if (mounted && !_cardShown) {
      _selected.value = null;
    }
  }

  void _closeSheet() {
    final sheet = _sheet;
    if (sheet != null && sheet.mounted) {
      SheetProvider.of(sheet)?.nestedNavigatorPop?.call();
    }
  }

  /// A filtered-out connection stays selected, as the log still holds it.
  void _dropGone() {
    final id = _selected.value;
    if (id != null && ref.read(requestsProvider)[id] == null) {
      _selected.value = null;
      _closeSheet();
    }
  }

  /// Narrowed past the card, the selection goes with it, as a sheet opening
  /// on its own would cover the list; widened, the card takes the sheet's.
  void _setCardShown(bool cardShown) {
    if (cardShown == _cardShown) {
      return;
    }
    _cardShown = cardShown;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted || cardShown != _cardShown) {
        return;
      }
      if (cardShown) {
        _closeSheet();
      } else {
        _selected.value = null;
      }
    });
  }

  String? _stepTarget(int step) {
    final order = _shownOrder().toList();
    final index = order.indexWhere((info) => info.id == _selected.value);
    final next = index + step;
    return index >= 0 && next >= 0 && next < order.length
        ? order[next].id
        : null;
  }

  void _step(int step) {
    if (_stepTarget(step) case final id?) {
      _selected.value = id;
    }
  }

  void _togglePaused() {
    _paused.value = !_paused.value;
    if (!_paused.value) {
      _scheduleRefresh();
    }
  }

  void _onlyApp(TrackerInfo trackerInfo) {
    _filters
      ..clear(RecordFacetKind.app)
      ..add(RecordFilter(RecordFacetKind.app, trackerInfo.metadata.process));
  }

  void _hideHost(TrackerInfo trackerInfo) {
    final host = trackerInfo.metadata.host;
    _filters.addCondition(
      ConnectionCondition(
        ConnectionField.host,
        host.isNotEmpty ? host : trackerInfo.title,
        excludes: true,
      ),
    );
  }

  void _forgetPresented() => _presented = null;

  _Presented _present(TrackerInfosState state) {
    final presented = _presented;
    if (presented != null && identical(state, _presentedState)) {
      return presented;
    }
    final (:items, :repeats) = _filters.present(state.list);
    _presentedState = state;
    return _presented = (
      items: items,
      repeats: repeats,
      active: items.where((item) => item.isActive).length,
    );
  }

  Widget _buildCounts(
    Widget Function(BuildContext context, _Presented presented) builder,
  ) {
    return ListenableBuilder(
      listenable: Listenable.merge([_list, _filters]),
      builder: (context, _) => builder(context, _present(_list.value)),
    );
  }

  Future<void> _askCondition() async {
    final condition = await showConnectionConditionForm(context);
    if (condition != null && mounted) {
      _filters.addCondition(condition);
    }
  }

  Future<void> _closeConnection(TrackerInfo trackerInfo) =>
      _close(() => _core.closeConnection(trackerInfo.id));

  List<PopupMenuItem> _buildMenuItems(bool pinned) {
    final appLocalizations = context.appLocalizations;
    return [
      ..._filters.menuItems(context, pinned: pinned),
      PopupMenuItem(
        glyph: AppGlyphs.block,
        label: appLocalizations.disconnectActiveConnections,
        section: const PopupMenuSection(),
        onPressed: () => _close(_core.closeConnections),
      ),
      PopupMenuItem(
        glyph: AppGlyphs.clearAll,
        label: appLocalizations.clearClosedConnections,
        onPressed: () {
          ref.read(requestsProvider.notifier).clearClosed();
          _scheduleRefresh(evenPaused: true);
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final body = RecordFilterScope(
      onFilter: _filters.add,
      child: ValueListenableBuilder<TrackerInfosState>(
        valueListenable: _list,
        builder: (context, state, _) => ListenableBuilder(
          listenable: _filters,
          builder: (context, _) => _buildBody(state),
        ),
      ),
    );
    return ListenableBuilder(
      listenable: Listenable.merge([_filters, _filters.options, _paused]),
      child: body,
      builder: (context, body) => LayoutBuilder(
        builder: (context, constraints) {
          final pinned = !ViewScope.isMobileOf(context);
          final facetBar = pinned && constraints.maxWidth >= _facetBarMinWidth;
          final cardShown =
              pinned && constraints.maxWidth >= _detailCardMinWidth;
          _setCardShown(cardShown);
          return Scaffold(
            title: context.appLocalizations.connections,
            searchState: AppBarSearchState(onSearch: _list.search),
            keywords: facetBar
                ? _filters.barKeywords
                : _filters.keywordsOf(pinned: pinned),
            keywordsCaption: pinned
                ? null
                : _buildCounts(
                    (context, presented) => ConnectionSummary(
                      shown: presented.items.length,
                      active: presented.active,
                      filtering:
                          _filters.isFiltering || _list.value.isSearching,
                    ),
                  ),
            statusActions: [
              if (rsFeature && !pinned)
                HttpCaptureEntry(isAndroid: system.isAndroid),
            ],
            iconActions: [
              IconButtonData(
                glyph: AppGlyphs.playPause(_paused.value ? 0 : 1),
                tooltip: _paused.value
                    ? context.appLocalizations.resumeRefreshing
                    : context.appLocalizations.pauseRefreshing,
                onPressed: _togglePaused,
              ),
            ],
            menuItems: _buildMenuItems(pinned),
            body: _DetailMode(
              cardShown: cardShown,
              child: TrackerMenuScope(
                actions: _menuActions,
                child: pinned
                    ? Column(
                        children: [
                          Expanded(child: _buildFacetRow(body!, facetBar)),
                          _buildStatusBar(cardShown),
                        ],
                      )
                    : _buildFacetRow(body!, facetBar),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBar(bool cardShown) {
    return Builder(
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: context.bottomInset),
        child: _buildCounts(
          (context, presented) => ValueListenableBuilder(
            valueListenable: _selected,
            builder: (context, selected, _) => ConnectionStatusBar(
              shown: presented.items.length,
              active: presented.active,
              selected: cardShown && selected != null,
              trailing: [
                if (rsFeature) HttpCaptureEntry(isAndroid: system.isAndroid),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFacetRow(Widget body, bool facetBar) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (facetBar)
          SizedBox(
            width: connectionFacetBarWidth,
            child: Builder(
              builder: (context) => ConnectionFacetBar(
                controller: _filters,
                padding: EdgeInsetsDirectional.only(
                  start: 8,
                  top: context.contentTopPadding,
                  bottom: 16 + context.bottomInset,
                ),
              ),
            ),
          ),
        Expanded(key: const ValueKey('list'), child: body),
      ],
    );
  }

  Widget _buildBody(TrackerInfosState state) {
    final appLocalizations = context.appLocalizations;
    final (items: connections, :repeats, active: _) = _present(state);
    return NullStatusSwitcher(
      isEmpty: connections.isEmpty && state.pending == 0,
      isSearching: state.isSearching || _filters.isFiltering,
      nullStatus: NullStatus(
        label: appLocalizations.nullTip(appLocalizations.connections),
        illustration: NullStatusIllustration.connections,
      ),
      child: _buildDetailLayout(
        (cardShown) => Stack(
          children: [
            TrackerRepeats(
              counts: repeats,
              child: TrackerClock(
                child: RecordTableFrame<TrackerInfo>(
                  tableId: 'connections',
                  items: connections,
                  reverse: true,
                  columnsOf: (width) =>
                      trackerInfoColumns(context, width: width),
                  minWidth: cardShown ? 0 : recordTableMinWidth,
                  dense: true,
                  builder: (context, table, connections) => _buildList(
                    state,
                    table,
                    connections,
                    padding: EdgeInsets.only(
                      top: context.contentTopPadding,
                      bottom: 16 + context.bottomInset,
                    ),
                  ),
                ),
              ),
            ),
            if (state.pending > 0)
              PositionedDirectional(
                top: context.contentTopPadding + 8,
                start: 0,
                end: 0,
                child: Center(
                  child: _NewConnectionsButton(
                    count: state.pending,
                    onPressed: _follow,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// A desktop page selects the row it opens: wide, it shows the selected
  /// connection in a card beside the list, and narrower, in a side sheet.
  Widget _buildDetailLayout(Widget Function(bool cardShown) builder) {
    if (ViewScope.isMobileOf(context)) {
      return builder(false);
    }
    return Builder(
      builder: (context) {
        final cardShown = _DetailMode.cardShownOf(context);
        return TrackerSelection(
          selected: _selected,
          onSelect: _select,
          child: !cardShown
              ? builder(false)
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: builder(true)),
                    ValueListenableBuilder(
                      valueListenable: _selected,
                      builder: (context, id, _) => id == null
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: EdgeInsetsDirectional.only(
                                top: context.contentTopPadding,
                                end: 16,
                                bottom: 16 + context.bottomInset,
                              ),
                              child: SizedBox(
                                width: _detailCardWidth,
                                child: TrackerInfoDetailCard(
                                  id: id,
                                  onClose: () => _selected.value = null,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildList(
    TrackerInfosState state,
    RecordTable<TrackerInfo>? table,
    List<TrackerInfo> connections, {
    required EdgeInsets padding,
  }) {
    final detailTitle = _detailTitle;
    final grouping = _filters.value.grouping;
    final groups = grouping != null
        ? _filters.groupsOf(connections, reverse: true)
        : table == null
        ? trackerInfoMinuteGroups(connections, DateTime.now())
        : null;
    _shownOrder = groups != null
        ? () => groups.expand((group) => group.items)
        : () => connections.reversed;
    if (groups != null) {
      final count = groups.fold(0, (sum, group) => sum + group.items.length);
      return _FollowTop(
        controller: _scrollController,
        following: state.autoScrollToEnd,
        onLeave: () => _list.setAutoScrollToEnd(false),
        onReturn: _follow,
        child: FloatingScrollbar(
          controller: _scrollController,
          hintBuilder: (fraction) {
            var index = (fraction * (count - 1)).round();
            for (final group in groups) {
              if (index < group.items.length) {
                return group.items[index].start.showFull;
              }
              index -= group.items.length;
            }
            return '';
          },
          child: TrackerInfoGroupedList(
            groups: groups,
            grouping: grouping,
            controller: _scrollController,
            padding: padding,
            table: table,
            detailTitle: detailTitle,
            onClose: _closeConnection,
          ),
        ),
      );
    }
    return Align(
      alignment: Alignment.topCenter,
      child: FloatingScrollbar(
        controller: _scrollController,
        hintBuilder: (fraction) {
          final index = (fraction * (connections.length - 1)).round();
          return connections[index].start.showFull;
        },
        child: ScrollToEndBox(
          controller: _scrollController,
          enable: state.autoScrollToEnd,
          onCancelToEnd: () => _list.setAutoScrollToEnd(false),
          onResumeToEnd: _follow,
          child: TrackerInfoList(
            reverse: true,
            shrinkWrap: true,
            physics: _physics,
            controller: _scrollController,
            padding: padding,
            trackerInfos: connections,
            table: table,
            detailTitle: detailTitle,
            onClose: _closeConnection,
          ),
        ),
      ),
    );
  }
}

typedef _Presented = ({
  List<TrackerInfo> items,
  Map<String, int> repeats,
  int active,
});

class _DetailMode extends InheritedWidget {
  final bool cardShown;

  const _DetailMode({required this.cardShown, required super.child});

  static bool cardShownOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_DetailMode>()?.cardShown ??
      false;

  @override
  bool updateShouldNotify(_DetailMode oldWidget) =>
      cardShown != oldWidget.cardShown;
}

const _facetBarMinWidth = 1240.0;
const _detailCardMinWidth = 1040.0;
const _detailCardWidth = 360.0;

/// Tells a list that reads newest first when the reader leaves its top and
/// comes back to it, and takes it back to the top once it follows again.
class _FollowTop extends StatefulWidget {
  final ScrollController controller;
  final bool following;
  final VoidCallback onLeave;
  final VoidCallback onReturn;
  final Widget child;

  const _FollowTop({
    required this.controller,
    required this.following,
    required this.onLeave,
    required this.onReturn,
    required this.child,
  });

  @override
  State<_FollowTop> createState() => _FollowTopState();
}

class _FollowTopState extends State<_FollowTop> {
  @override
  void didUpdateWidget(_FollowTop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.following && !oldWidget.following) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final controller = widget.controller;
        if (mounted && widget.following && controller.hasClients) {
          controller.jumpTo(controller.position.minScrollExtent);
        }
      });
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0 ||
        notification is! ScrollUpdateNotification &&
            notification is! ScrollEndNotification) {
      return false;
    }
    final metrics = notification.metrics;
    final atTop = metrics.pixels <= metrics.minScrollExtent;
    if (widget.following && !atTop) {
      widget.onLeave();
    } else if (!widget.following &&
        atTop &&
        notification is ScrollEndNotification) {
      widget.onReturn();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: widget.child,
    );
  }
}

class _NewConnectionsButton extends StatelessWidget {
  final int count;
  final VoidCallback onPressed;

  const _NewConnectionsButton({required this.count, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const GlyphIcon(AppGlyphs.arrowUp, fill: 1),
      label: Text(context.appLocalizations.newConnections(count)),
    );
  }
}
