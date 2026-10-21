import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class DnsQueryListController extends ValueNotifier<DnsQueriesState> {
  DnsQueryListController() : super(const DnsQueriesState());

  void search(String query) {
    value = value.copyWith(query: query);
  }

  void updateKeywords(List<String> keywords) {
    value = value.copyWith(keywords: keywords);
  }

  void setDnsQueries(List<DnsQuery> dnsQueries) {
    if (identical(dnsQueries, value.dnsQueries)) {
      return;
    }
    value = value.copyWith(
      dnsQueries: value.autoScrollToEnd
          ? dnsQueries
          : retainTrimmedHead(
              value.dnsQueries,
              dnsQueries,
              pausedMaxDnsQueriesLength,
            ),
    );
  }

  void setAutoScrollToEnd(bool autoScrollToEnd) {
    value = value.copyWith(autoScrollToEnd: autoScrollToEnd);
  }

  void resumeAutoScrollToEnd(List<DnsQuery> dnsQueries) {
    value = value.copyWith(autoScrollToEnd: true, dnsQueries: dnsQueries);
  }
}

class DnsQueriesView extends ConsumerStatefulWidget {
  final ScrollController? scrollController;

  const DnsQueriesView({super.key, this.scrollController});

  @override
  ConsumerState<DnsQueriesView> createState() => _DnsQueriesViewState();
}

class _DnsQueriesViewState extends ConsumerState<DnsQueriesView>
    with RouteMotionHoldMixin<DnsQueriesView> {
  final _listController = DnsQueryListController();
  late final ScrollController _scrollController;
  late final _physics = FollowEndScrollPhysics(
    isFollowing: () => _listController.value.autoScrollToEnd,
  );

  @override
  void initState() {
    super.initState();
    _scrollController =
        widget.scrollController ??
        sheetScrollController(context, initialScrollOffset: double.maxFinite);
    _listController.setDnsQueries(ref.read(dnsQueriesProvider).list);
    ref.listenManual(dnsQueriesProvider.select((state) => state.revision), (
      _,
      _,
    ) {
      _updateDnsQueriesThrottler();
    });
  }

  @override
  void dispose() {
    _listController.dispose();
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _updateDnsQueriesThrottler() {
    throttler.call(FunctionTag.dnsQueries, () {
      if (!mounted) {
        return;
      }
      updateWhenRouteSettled(
        () => _listController.setDnsQueries(ref.read(dnsQueriesProvider).list),
      );
    }, duration: renderThrottleDuration);
  }

  Future<void> _clearDnsCache() async {
    final appLocalizations = context.appLocalizations;
    var cleared = false;
    try {
      cleared = await ref.read(coreHandlerProvider).clearDnsCache();
    } catch (error) {
      commonPrint.log(
        'clearDnsCache error: $error',
        logLevel: coreFailureLogLevel(error),
      );
    }
    if (!mounted) {
      return;
    }
    context.showNotifier(
      cleared
          ? appLocalizations.dnsCacheCleared
          : appLocalizations.clearDnsCacheFailed,
      level: cleared ? MessageLevel.success : MessageLevel.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonScaffold(
      title: PageLabel.dns.label,
      searchState: AppBarSearchState(onSearch: _listController.search),
      onKeywordsUpdate: _listController.updateKeywords,
      iconActions: [
        IconButtonData(
          glyph: AppGlyphs.broom,
          tooltip: appLocalizations.clearDnsCache,
          onPressed: _clearDnsCache,
        ),
      ],
      body: ValueListenableBuilder<DnsQueriesState>(
        valueListenable: _listController,
        builder: (context, state, _) {
          final dnsQueries = state.list;
          return NullStatusSwitcher(
            isEmpty: dnsQueries.isEmpty,
            isSearching: state.isSearching,
            nullStatus: NullStatus(
              label: appLocalizations.nullTip(appLocalizations.dnsQueries),
              illustration: NullStatusIllustration.dns,
            ),
            child: RecordTableFrame<DnsQuery>(
              tableId: 'dns',
              items: dnsQueries,
              reverse: true,
              columnsOf: (width) => _dnsQueryColumns(
                context,
                wide: width >= recordWideTableWidth,
              ),
              builder: (context, table, dnsQueries) => Align(
                alignment: Alignment.topCenter,
                child: FloatingScrollbar(
                  controller: _scrollController,
                  hintBuilder: (fraction) {
                    final index = (fraction * (dnsQueries.length - 1)).round();
                    return dnsQueries[index].time.showFull;
                  },
                  child: ScrollToEndBox(
                    controller: _scrollController,
                    enable: state.autoScrollToEnd,
                    onCancelToEnd: () {
                      _listController.setAutoScrollToEnd(false);
                    },
                    onResumeToEnd: () {
                      _listController.resumeAutoScrollToEnd(
                        ref.read(dnsQueriesProvider).list,
                      );
                    },
                    child: SuperListView.separated(
                      reverse: true,
                      shrinkWrap: true,
                      physics: _physics,
                      controller: _scrollController,
                      padding: EdgeInsets.only(
                        top: context.contentTopPadding,
                        bottom: 16 + context.bottomInset,
                      ),
                      itemCount: dnsQueries.length,
                      extentEstimation:
                          table?.estimateExtent ?? recordListExtentEstimation,
                      separatorBuilder: (_, _) => table == null
                          ? const SizedBox(height: recordListGap)
                          : const SizedBox.shrink(),
                      itemBuilder: (_, index) {
                        if (table != null) {
                          return _DnsQueryTableRow(
                            dnsQuery: dnsQueries[index],
                            table: table,
                            striped: index.isOdd,
                          );
                        }
                        return DnsQueryItem(
                          dnsQuery: dnsQueries[index],
                          onClickKeyword: (value) {
                            context.commonScaffoldState?.addKeyword(value);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

void _showDnsQueryDetail(BuildContext context, DnsQuery dnsQuery) {
  showInSheet<void>(
    context,
    builder: (_) {
      return CommonScaffold(
        body: DnsQueryDetailView(dnsQuery: dnsQuery),
        title: context.appLocalizations.details('DNS'),
      );
    },
  );
}

List<RecordColumn<DnsQuery>> _dnsQueryColumns(
  BuildContext context, {
  required bool wide,
}) {
  final appLocalizations = context.appLocalizations;
  return [
    RecordColumn(
      TableColumn('time', appLocalizations.time, width: 80),
      cell: (_, query) =>
          RecordCellText(query.time.showTime.trim(), muted: true),
      sortKey: (query) => query.time,
      descendingFirst: true,
    ),
    RecordColumn(
      TableColumn('domain', appLocalizations.domain, flex: 1.3),
      cell: (_, query) => RecordCellText(query.domain),
      sortKey: (query) => query.domain.toLowerCase(),
    ),
    RecordColumn(
      TableColumn('type', appLocalizations.ipType, width: 72),
      cell: (_, query) => _DnsKeyword(query.type),
      sortKey: (query) => query.type,
    ),
    RecordColumn(
      TableColumn('initiator', appLocalizations.initiatorShort, width: 72),
      cell: (_, query) => switch (query.initiator) {
        final initiator? => _DnsKeyword(initiator.label),
        null => const RecordCellText(''),
      },
      sortKey: (query) => query.initiator?.label ?? '',
    ),
    RecordColumn(
      TableColumn('result', appLocalizations.result, flex: 1),
      cell: (_, query) => _DnsResult(query),
      sortKey: (query) => query.summary.toLowerCase(),
    ),
    if (wide)
      RecordColumn(
        TableColumn('upstream', appLocalizations.source, flex: 0.8),
        cell: (_, query) => RecordCellText(query.upstream, muted: true),
        sortKey: (query) => query.upstream.toLowerCase(),
      ),
    RecordColumn(
      TableColumn('elapsed', appLocalizations.elapsed, width: 76, end: true),
      cell: (_, query) => RecordCellText('${query.delay} ms', muted: true),
      sortKey: (query) => query.delay,
      descendingFirst: true,
    ),
  ];
}

class _DnsKeyword extends StatelessWidget {
  final String label;
  final RecordTone tone;

  const _DnsKeyword(this.label, {this.tone = RecordTone.neutral});

  @override
  Widget build(BuildContext context) {
    return RecordLabel(
      label: label,
      tone: tone,
      onPressed: () => context.commonScaffoldState?.addKeyword(label),
    );
  }
}

class _DnsResult extends StatelessWidget {
  final DnsQuery dnsQuery;

  const _DnsResult(this.dnsQuery);

  @override
  Widget build(BuildContext context) {
    final summary = dnsQuery.summary;
    return Row(
      spacing: 6,
      children: [
        if (dnsQuery.cached) _DnsKeyword(context.appLocalizations.cache),
        if (dnsQuery.hasFailureRcode)
          _DnsKeyword(dnsQuery.rcode, tone: RecordTone.error),
        if (summary.isNotEmpty)
          Flexible(
            child: Text(
              summary,
              style: TextStyle(
                color: dnsQuery.isFailed
                    ? context.colorScheme.error
                    : context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

class _DnsQueryTableRow extends StatelessWidget {
  final DnsQuery dnsQuery;
  final RecordTable<DnsQuery> table;
  final bool striped;

  const _DnsQueryTableRow({
    required this.dnsQuery,
    required this.table,
    required this.striped,
  });

  @override
  Widget build(BuildContext context) {
    return RecordTableRow(
      table: table,
      striped: striped,
      onTap: () => _showDnsQueryDetail(context, dnsQuery),
      cells: table.cellsOf(context, dnsQuery),
    );
  }
}

class DnsQueryItem extends StatelessWidget {
  final DnsQuery dnsQuery;
  final ValueChanged<String>? onClickKeyword;

  const DnsQueryItem({super.key, required this.dnsQuery, this.onClickKeyword});

  @override
  Widget build(BuildContext context) {
    final styles = RecordTextStyles.of(context);
    final tone = dnsQuery.isFailed ? RecordTone.error : RecordTone.neutral;
    final summary = dnsQuery.summary;
    return RecordListItem(
      onTap: () => _showDnsQueryDetail(context, dnsQuery),
      header: RecordHeader(
        trailing: Text('${dnsQuery.delay} ms'),
        children: [
          RecordTimestamp(dnsQuery.time.showFull),
          RecordLabel(
            label: dnsQuery.type,
            onPressed: () => onClickKeyword?.call(dnsQuery.type),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(dnsQuery.domain, style: styles.title),
          if (summary.isNotEmpty)
            Text(
              summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: styles.secondary.copyWith(
                color: tone.accentColor(context),
              ),
            ),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final tag in dnsQuery.resultTags)
                RecordLabel(
                  label: tag,
                  tone: dnsQuery.hasFailureRcode && tag == dnsQuery.rcode
                      ? RecordTone.error
                      : RecordTone.neutral,
                  onPressed: () => onClickKeyword?.call(tag),
                ),
              if (dnsQuery.upstream.isNotEmpty)
                Text(dnsQuery.upstream, style: styles.secondary),
            ],
          ),
        ],
      ),
    );
  }
}

class DnsQueryDetailView extends StatelessWidget {
  final DnsQuery dnsQuery;

  const DnsQueryDetailView({super.key, required this.dnsQuery});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final entries = [
      (appLocalizations.time, dnsQuery.time.showFull),
      (appLocalizations.domain, dnsQuery.domain),
      (appLocalizations.recordType, dnsQuery.type),
      (appLocalizations.initiator, dnsQuery.initiator?.label ?? ''),
      (appLocalizations.source, dnsQuery.upstream),
      (
        appLocalizations.cache,
        dnsQuery.cached ? appLocalizations.yes : appLocalizations.no,
      ),
      (appLocalizations.responseCode, dnsQuery.rcode),
      (appLocalizations.delay, '${dnsQuery.delay} ms'),
    ];
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
        bottom: 20 + context.bottomInset,
        top: context.contentTopPadding,
      ),
      children: [
        generateSection(
          title: appLocalizations.basicInfo,
          items: [
            for (final (title, value) in entries)
              if (value.isNotEmpty) DetailRow.text(title: title, value: value),
          ],
        ),
        if (dnsQuery.error.isNotEmpty)
          generateSection(
            title: appLocalizations.error,
            items: [_ErrorRow(error: dnsQuery.error)],
          ),
        if (dnsQuery.answers.isNotEmpty)
          generateSection(
            title: appLocalizations.answers,
            items: [
              for (final answer in dnsQuery.answers)
                DetailRow(title: answer, copyText: answer),
            ],
          ),
      ],
    );
  }
}

Future<void> _copy(BuildContext context, String text) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (!context.mounted) return;
  context.showNotifier(context.appLocalizations.copySuccess);
}

class _ErrorRow extends StatelessWidget {
  final String error;

  const _ErrorRow({required this.error});

  @override
  Widget build(BuildContext context) {
    return DecorationListItem(
      onPressed: () => _copy(context, error),
      minVerticalPadding: 14,
      title: Text(
        error,
        style: AppTextStyle.subheadline
            .of(context)
            .copyWith(color: context.colorScheme.error),
      ),
    );
  }
}
