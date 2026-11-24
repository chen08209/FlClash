import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'connection_filters.dart';
import 'dns_query_detail.dart';
import 'record_feed.dart';

enum DnsStatus { all, failed, cached }

extension DnsStatusExt on DnsStatus {
  bool holds(DnsQuery dnsQuery) => switch (this) {
    DnsStatus.all => true,
    DnsStatus.failed => dnsQuery.isFailed,
    DnsStatus.cached => dnsQuery.cached,
  };

  String get label => switch (this) {
    DnsStatus.all => currentAppLocalizations.connectionsAll,
    DnsStatus.failed => currentAppLocalizations.connectionsFailed,
    DnsStatus.cached => currentAppLocalizations.cache,
  };

  String emptyLabel(AppLocalizations appLocalizations) => switch (this) {
    DnsStatus.all => appLocalizations.nullTip(appLocalizations.dnsQueries),
    DnsStatus.failed => appLocalizations.noFailedDnsQueries,
    DnsStatus.cached => appLocalizations.noCachedDnsQueries,
  };
}

/// Holds the shown queries still, but for the oldest, while not following.
class DnsQueryFeed extends RecordFeed<DnsQuery> {
  DnsQueryFeed() : super((dnsQuery) => dnsQuery.searchFields);

  List<DnsQuery>? _waiting;

  void offer(List<DnsQuery> dnsQueries) {
    if (holdsNew) {
      _waiting = dnsQueries;
      return;
    }
    _waiting = null;
    items = following
        ? dnsQueries
        : retainTrimmedHead(items, dnsQueries, pausedMaxDnsQueriesLength);
  }

  @override
  void release() {
    if (_waiting case final waiting?) {
      offer(waiting);
    }
  }
}

typedef DnsFilterController = ConditionFilterController<DnsQuery, DnsStatus>;

DnsFilterController dnsFilters() => ConditionFilterController(
  facets: dnsQueryFacets,
  statuses: DnsStatus.values,
  fields: DnsField.values,
  labelOf: (status) => status.label,
  statusHolds: (status, item) => status.holds(item),
  showsText: (count) => currentAppLocalizations.dnsConditionShows(count),
  valuesInText: (field) => currentAppLocalizations.dnsConditionValuesIn(field),
  conditionTip: () => currentAppLocalizations.dnsConditionTip,
  fieldOf: (kind) => switch (kind) {
    RecordFacetKind.type => DnsField.type,
    RecordFacetKind.initiator => DnsField.initiator,
    _ => null,
  },
);

/// The DNS queries in [feed] under the minute they were made in, following
/// the newest.
class DnsQueryList extends StatelessWidget {
  final DnsQueryFeed feed;
  final DnsFilterController filters;
  final ScrollController scrollController;
  final ValueListenable<DnsQuery?> selected;
  final ValueChanged<DnsQuery> onSelect;
  final VoidCallback onFollow;

  const DnsQueryList({
    super.key,
    required this.feed,
    required this.filters,
    required this.scrollController,
    required this.selected,
    required this.onSelect,
    required this.onFollow,
  });

  void _onlyDomain(String domain) => filters.onlyCondition(
    RecordCondition(DnsField.domain, domain, match: ConditionMatch.equals),
  );

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return ListenableBuilder(
      listenable: Listenable.merge([feed, filters]),
      builder: (context, _) {
        final dnsQueries = filters.apply(feed.shown);
        return RecordFeedView<DnsQuery>(
          rows: GroupedMinuteRows(
            recordMinuteGroups(
              dnsQueries,
              (dnsQuery) => dnsQuery.time,
              DateTime.now(),
            ),
            ObjectKey.new,
          ),
          isEmpty: dnsQueries.isEmpty,
          isSearching: feed.isSearching || filters.narrowsPastStatus,
          nullStatus: NullStatus(
            label: filters.status.emptyLabel(appLocalizations),
            illustration: NullStatusIllustration.dns,
          ),
          controller: scrollController,
          timeAt: (fraction) => recordAtFraction(dnsQueries, fraction).time,
          following: feed.following,
          onStopFollowing: () => feed.following = false,
          onFollow: onFollow,
          onHover: (hovered) => feed.hovered = hovered,
          itemBuilder: (dnsQuery) => MemoBuilder(
            inputs: [dnsQuery, selected, onSelect],
            builder: (_) => RecordSelected(
              selected: selected,
              holds: (selected) => identical(selected, dnsQuery),
              builder: (context, selected) => DnsQueryRow(
                dnsQuery: dnsQuery,
                selected: selected,
                onPressed: () => onSelect(dnsQuery),
                onOnlyDomain: _onlyDomain,
              ),
            ),
          ),
        );
      },
    );
  }
}

class DnsQueryRow extends StatelessWidget {
  final DnsQuery dnsQuery;
  final bool selected;
  final VoidCallback onPressed;
  final ValueChanged<String>? onOnlyDomain;

  const DnsQueryRow({
    super.key,
    required this.dnsQuery,
    required this.onPressed,
    this.selected = false,
    this.onOnlyDomain,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final secondary = colorScheme.onSurfaceVariant;
    final failed = dnsQuery.isFailed;
    final initiator = dnsQuery.initiator;
    final row = DecorationListItem(
      isSelected: selected,
      leading: LabelWell(label: dnsQuery.type),
      title: Text(
        dnsQuery.domain,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyle.subheadline.of(context),
      ),
      subtitle: DefaultTextStyle.merge(
        style: AppTextStyle.caption1
            .of(context)
            .toTabular
            .copyWith(color: secondary),
        child: RecordLabelLine(
          underTitle: true,
          text: failed ? '' : dnsQuery.summary,
          labels: [
            if (failed)
              RecordLabel(
                label: dnsFailureTitle(appLocalizations, dnsQuery),
                tone: RecordTone.error,
              ),
            if (initiator != null) RecordLabel(label: initiator.label),
            if (dnsQuery.cached) RecordLabel(label: appLocalizations.cache),
          ],
        ),
      ),
      trailing: Text(
        '${dnsQuery.delay} ms',
        style: AppTextStyle.footnote
            .of(context)
            .toTabular
            .copyWith(color: secondary),
      ),
      onPressed: onPressed,
    );
    return ContextMenuRegion(
      menuBuilder: (context) =>
          dnsQueryMenuItems(context, dnsQuery, onOnlyDomain: onOnlyDomain),
      child: selected ? RecordSelectedRow(child: row) : row,
    );
  }
}
