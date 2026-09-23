import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
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

class _DnsQueriesViewState extends ConsumerState<DnsQueriesView> {
  final _listController = DnsQueryListController();
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController =
        widget.scrollController ??
        ScrollController(initialScrollOffset: double.maxFinite);
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
      _listController.setDnsQueries(ref.read(dnsQueriesProvider).list);
    }, duration: renderThrottleDuration);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonScaffold(
      title: PageLabel.dns.label,
      searchState: AppBarSearchState(onSearch: _listController.search),
      onKeywordsUpdate: _listController.updateKeywords,
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
            child: Align(
              alignment: Alignment.topCenter,
              child: FloatingScrollbar(
                controller: _scrollController,
                hintBuilder: (fraction) {
                  final index = (fraction * (dnsQueries.length - 1)).round();
                  return dnsQueries[index].time.showFull;
                },
                child: ScrollToEndBox(
                  controller: _scrollController,
                  dataSource: dnsQueries,
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
                    physics: const NextClampingScrollPhysics(),
                    controller: _scrollController,
                    padding: EdgeInsets.only(
                      top: context.sheetTopPadding,
                      bottom: 16 + BottomInsetScope.of(context),
                    ),
                    itemCount: dnsQueries.length,
                    separatorBuilder: (_, _) => const Divider(height: 0),
                    itemBuilder: (_, index) {
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
          );
        },
      ),
    );
  }
}

class DnsQueryItem extends StatelessWidget {
  final DnsQuery dnsQuery;
  final ValueChanged<String>? onClickKeyword;

  const DnsQueryItem({super.key, required this.dnsQuery, this.onClickKeyword});

  void _showDetail(BuildContext context) {
    showExtend(
      context,
      builder: (_) {
        return CommonScaffold(
          body: DnsQueryDetailView(dnsQuery: dnsQuery),
          title: context.appLocalizations.details('DNS'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final styles = RecordTextStyles.of(context);
    final tone = dnsQuery.isFailed ? RecordTone.error : RecordTone.neutral;
    final summary = dnsQuery.error.isNotEmpty
        ? dnsQuery.error
        : dnsQuery.answers.join(', ');
    return RecordListItem(
      tone: tone,
      onTap: () => _showDetail(context),
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
          Text(
            dnsQuery.domain,
            style: styles.primary?.copyWith(fontWeight: FontWeight.w500),
          ),
          if (summary.isNotEmpty)
            Text(
              summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: styles.secondary?.copyWith(
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
                Text(dnsQuery.upstream, style: styles.muted),
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
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ).copyWith(bottom: 20, top: context.sheetTopPadding),
      children: [
        generateSectionV3(
          title: appLocalizations.basicInfo,
          items: [
            for (final (title, value) in entries)
              if (value.isNotEmpty) DetailRow.text(title: title, value: value),
          ],
        ),
        if (dnsQuery.error.isNotEmpty)
          generateSectionV3(
            title: appLocalizations.error,
            items: [_ErrorRow(error: dnsQuery.error)],
          ),
        if (dnsQuery.answers.isNotEmpty)
          generateSectionV3(
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
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.error,
        ),
      ),
    );
  }
}
