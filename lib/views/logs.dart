import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LogListController extends ValueNotifier<LogsState> {
  LogListController() : super(const LogsState());

  void search(String query) {
    value = value.copyWith(query: query);
  }

  void setLogs(List<Log> logs) {
    if (identical(logs, value.logs)) {
      return;
    }
    value = value.copyWith(
      logs: value.autoScrollToEnd
          ? logs
          : retainTrimmedHead(value.logs, logs, pausedMaxLogsLength),
    );
  }

  void setAutoScrollToEnd(bool autoScrollToEnd) {
    value = value.copyWith(autoScrollToEnd: autoScrollToEnd);
  }

  void resumeAutoScrollToEnd(List<Log> logs) {
    value = value.copyWith(autoScrollToEnd: true, logs: logs);
  }
}

class LogsView extends ConsumerStatefulWidget {
  const LogsView({super.key});

  @override
  ConsumerState<LogsView> createState() => _LogsViewState();
}

class _LogsViewState extends ConsumerState<LogsView>
    with RouteMotionHoldMixin<LogsView> {
  final _listController = LogListController();
  final _filters = RecordFilterController<Log>(facets: logFacets);
  late final ScrollController _scrollController;
  late final _physics = FollowEndScrollPhysics(
    isFollowing: () => _listController.value.autoScrollToEnd,
  );

  @override
  void initState() {
    super.initState();
    _scrollController = sheetScrollController(context);
    _setLogs(ref.read(logsProvider).list);
    ref.listenManual(logsProvider.select((state) => state.revision), (_, _) {
      updateLogsThrottler();
    });
  }

  List<PopupMenuItem> _buildMenuItems(BuildContext context, LogLevel logLevel) {
    final appLocalizations = context.appLocalizations;
    return [
      PopupMenuItem(
        glyph: AppGlyphs.export,
        label: appLocalizations.exportLogs,
        onPressed: _handleExport,
      ),
      PopupMenuItem(
        glyph: AppGlyphs.sliders,
        label: appLocalizations.logLevel,
        subtitle: logLevel.name,
        subItems: [
          for (final option in LogLevel.values)
            PopupMenuItem(
              label: option.name,
              checked: option == logLevel,
              onPressed: () => ref
                  .read(patchClashConfigProvider.notifier)
                  .update((state) => state.copyWith(logLevel: option)),
            ),
        ],
      ),
    ];
  }

  @override
  void dispose() {
    _listController.dispose();
    _filters.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleExport() async {
    final appLocalizations = context.appLocalizations;
    final res = await globalState.safeRun<bool>(() async {
      return ref.read(logsProvider.notifier).exportLogs();
    }, title: appLocalizations.exportLogs);
    if (res != true) return;
    unawaited(
      dialogs.showAlert(
        title: appLocalizations.tip,
        message: TextSpan(text: appLocalizations.exportSuccess),
      ),
    );
  }

  void _setLogs(List<Log> logs) {
    _listController.setLogs(logs);
    _filters.offer(_listController.value.logs);
  }

  void updateLogsThrottler() {
    throttler.call(FunctionTag.logs, () {
      if (!mounted) {
        return;
      }
      updateWhenRouteSettled(() => _setLogs(ref.read(logsProvider).list));
    }, duration: renderThrottleDuration);
  }

  @override
  Widget build(BuildContext context) {
    final body = RecordFilterScope(
      onFilter: _filters.add,
      child: _buildBody(context),
    );
    return Consumer(
      child: body,
      builder: (context, ref, body) {
        final logLevel = ref.watch(
          patchClashConfigProvider.select((state) => state.logLevel),
        );
        return ListenableBuilder(
          listenable: Listenable.merge([_filters, _filters.options]),
          child: body,
          builder: (context, body) {
            return Scaffold(
              iconActions: [
                if (_filters.options.value.isNotEmpty)
                  IconButtonData(
                    glyph: AppGlyphs.filter,
                    tooltip: context.appLocalizations.filter,
                    onPressed: null,
                    menuItems: _filters.optionMenuItems,
                  ),
              ],
              keywords: _filters.keywords,
              menuItems: _buildMenuItems(context, logLevel),
              searchState: AppBarSearchState(onSearch: _listController.search),
              title: context.appLocalizations.logs,
              body: body!,
            );
          },
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return ListenableBuilder(
      listenable: Listenable.merge([_listController, _filters]),
      builder: (context, _) {
        final state = _listController.value;
        final logs = _filters.apply(state.list);
        return NullStatusSwitcher(
          isEmpty: logs.isEmpty,
          isSearching: state.isSearching || _filters.isFiltering,
          nullStatus: NullStatus(
            illustration: NullStatusIllustration.logs,
            label: appLocalizations.nullTip(appLocalizations.logs),
          ),
          child: _buildList(context, state, logs),
        );
      },
    );
  }

  Widget _buildList(BuildContext context, LogsState state, List<Log> logs) {
    final selectable = !ViewScope.isMobileOf(context);
    final padding = context.listInsets.page(
      top: context.contentTopPadding,
      bottom: 16 + context.bottomInset,
    );
    return Align(
      alignment: Alignment.topCenter,
      child: FloatingScrollbar(
        controller: _scrollController,
        hintBuilder: (fraction) {
          final index = (fraction * (logs.length - 1)).round();
          return logs[index].dateTime;
        },
        child: ScrollToEndBox(
          onCancelToEnd: () {
            _listController.setAutoScrollToEnd(false);
          },
          onResumeToEnd: () {
            _listController.resumeAutoScrollToEnd(ref.read(logsProvider).list);
            _filters.offer(_listController.value.logs);
          },
          controller: _scrollController,
          enable: state.autoScrollToEnd,
          child: RecordFeedList<Log>(
            physics: _physics,
            reverse: true,
            shrinkWrap: true,
            controller: _scrollController,
            padding: padding,
            items: logs,
            keyOf: ObjectKey.new,
            gap: recordListGap,
            estimatedItemExtent: recordListEstimatedExtent,
            itemBuilder: (log, _, _) => MemoBuilder(
              inputs: [log, selectable],
              builder: (_) => LogItem(log: log, selectable: selectable),
            ),
          ),
        ),
      ),
    );
  }
}

class LogItem extends StatelessWidget {
  final Log log;

  /// Whether the text is selected in place; otherwise a tap opens the log's
  /// details, where a phone can select and copy it without fighting the
  /// list's scroll.
  final bool selectable;

  const LogItem({super.key, required this.log, this.selectable = true});

  @override
  Widget build(BuildContext context) {
    final tone = switch (log.logLevel) {
      LogLevel.warning => RecordTone.warning,
      LogLevel.error => RecordTone.error,
      LogLevel.info || LogLevel.debug || LogLevel.silent => RecordTone.neutral,
    };
    final payload = log.parsed;
    return RecordListItem(
      onTap: selectable ? () {} : () => _showLogDetail(context, log),
      header: RecordHeader(
        children: [
          RecordTimestamp(log.dateTime),
          RecordLabel(
            label: log.logLevel.name,
            tone: tone,
            onPressed: () => RecordFilterScope.add(
              context,
              RecordFilter(RecordFacetKind.level, log.logLevel.name),
            ),
          ),
        ],
      ),
      body: _LogBody(
        payload: payload,
        errorColor: tone.accentColor(context),
        selectable: selectable,
      ),
    );
  }
}

class _LogBody extends StatelessWidget {
  final LogPayload payload;
  final Color? errorColor;
  final bool selectable;

  const _LogBody({
    required this.payload,
    required this.selectable,
    this.errorColor,
  });

  String get _sourceText => [
    payload.tag,
    if (payload.route case final route?) ...[route.source, route.sourceDetail],
  ].where((text) => text.isNotEmpty).join('  ·  ');

  @override
  Widget build(BuildContext context) {
    final styles = RecordTextStyles.of(context);
    final route = payload.route;
    if (route == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          selectable
              ? SelectableText(payload.message, style: styles.primary)
              : Text(payload.message, style: styles.primary),
          if (payload.tag.isNotEmpty)
            Text(payload.tag, style: styles.secondary),
        ],
      );
    }
    final text = TextSpan(
      children: [
        TextSpan(text: route.destination, style: styles.title),
        if (route.error.isNotEmpty)
          TextSpan(
            text: '\n${route.error}',
            style: styles.secondary.copyWith(color: errorColor),
          ),
        const TextSpan(text: '\n'),
        if (route.rule.isNotEmpty) ...[
          TextSpan(text: route.rule, style: styles.secondary),
          TextSpan(text: ' \u2192 ', style: styles.secondary.toJetBrainsMono),
        ],
        TextSpan(
          text: route.proxy,
          style: AppTextStyle.footnote
              .of(context, emphasized: true)
              .copyWith(color: context.colorScheme.primary),
        ),
        TextSpan(text: '\n$_sourceText', style: styles.secondary),
      ],
    );
    return selectable ? SelectableText.rich(text) : Text.rich(text);
  }
}

void _showLogDetail(BuildContext context, Log log) {
  final appLocalizations = context.appLocalizations;
  showNestedSheet<void>(
    context,
    builder: (context) => Scaffold(
      title: appLocalizations.details(appLocalizations.log),
      iconActions: [
        IconButtonData(
          glyph: AppGlyphs.copy,
          tooltip: appLocalizations.copy,
          onPressed: () => _copyLog(context, log),
        ),
      ],
      body: _LogDetailView(log: log),
    ),
  );
}

Future<void> _copyLog(BuildContext context, Log log) async {
  final copySuccess = context.appLocalizations.copySuccess;
  await Clipboard.setData(
    ClipboardData(
      text: '${log.dateTime} [${log.logLevel.name}] ${log.payload}',
    ),
  );
  dialogs.showBanner(copySuccess);
}

class _LogDetailView extends StatelessWidget {
  final Log log;

  const _LogDetailView({required this.log});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return ListView(
      padding: context.listInsets.page().copyWith(
        bottom: 20 + context.bottomInset,
        top: context.sectionsTopPadding,
      ),
      children: [
        generateSection(
          title: appLocalizations.basicInfo,
          items: [
            DetailRow.text(title: appLocalizations.time, value: log.dateTime),
            DetailRow.text(
              title: appLocalizations.logLevel,
              value: log.logLevel.name,
            ),
          ],
        ),
        generateSection(
          title: appLocalizations.content,
          items: [
            DecorationListItem(
              minVerticalPadding: 14,
              title: SelectableText(
                log.payload,
                style: AppTextStyle.subheadline.of(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
