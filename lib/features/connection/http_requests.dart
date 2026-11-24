import 'dart:collection';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'connection_filters.dart';
import 'record_feed.dart';
import 'mitm_texts.dart';

typedef MitmQuery =
    Future<MitmQueryPage> Function({
      int? before,
      int? since,
      required int limit,
    });

/// The most Concord's `mitm.query` gives in one page.
const mitmQueryPageLimit = 64;

extension MitmExchangeSummaryExt on MitmExchangeSummary {
  /// Answered 4xx or 5xx, or not answered at all.
  bool get isFailed => switch (statusClass) {
    '4xx' || '5xx' || 'failed' => true,
    '' => status >= 400 || (!pending && status == 0),
    _ => false,
  };

  List<String> get searchFields => [
    method,
    host,
    path,
    if (status > 0) '$status',
    error,
    app?.process ?? '',
  ];
}

/// Every connection's requests the Core keeps, followed a pass at a time: the
/// first pass pages through all of them, each later one through what changed
/// since the pass before.
class HttpRequestFeed extends RecordFeed<MitmExchangeSummary> {
  HttpRequestFeed() : super((exchange) => exchange.searchFields);

  final _byId = SplayTreeMap<int, MitmExchangeSummary>();
  int? _version;
  var _session = 0;
  int? _readingIn;
  var _stale = false;
  var _runs = 0;

  /// The newest id shown as [holdsNew] started.
  int? _heldUpTo;

  /// Grows each time the Core is found restarted, which starts its ids over.
  int get runs => _runs;

  Future<void> read(MitmQuery query) async {
    final session = _session;
    if (_readingIn == session) {
      return;
    }
    _readingIn = session;
    try {
      await _pass(query, session);
    } finally {
      if (_readingIn == session) {
        _readingIn = null;
      }
    }
  }

  /// For a Core that has gone, whose ids the next one counts again.
  void reset() {
    _session++;
    _forget();
    _stale = false;
    _show();
  }

  Future<void> _pass(MitmQuery query, int session) async {
    final since = _version;
    int? version;
    int? before;
    var oldest = 0;
    do {
      final page = await query(
        before: before,
        since: since,
        limit: mitmQueryPageLimit,
      );
      if (session != _session) {
        return;
      }
      if (version == null && since != null && page.version < since) {
        _forget();
        return _pass(query, session);
      }
      version ??= page.version;
      oldest = page.oldest;
      for (final exchange in page.exchanges) {
        if (_byId[exchange.id] != exchange) {
          _byId[exchange.id] = exchange;
          _stale = _stale || _shows(exchange.id);
        }
      }
      for (final id in page.unmatched) {
        _stale = (_byId.remove(id) != null && _shows(id)) || _stale;
      }
      before = page.next;
    } while (before != null);
    while (_byId.isNotEmpty && _byId.firstKey()! < oldest) {
      _stale = _stale || _shows(_byId.firstKey()!);
      _byId.remove(_byId.firstKey());
    }
    _version = version;
    if (_stale) {
      _stale = false;
      _show();
    }
  }

  bool _shows(int id) {
    final upTo = _heldUpTo;
    return upTo == null || id <= upTo;
  }

  void _show() {
    final upTo = _heldUpTo;
    items = List.unmodifiable(
      upTo == null
          ? _byId.values
          : _byId.values.takeWhile((exchange) => exchange.id <= upTo),
    );
  }

  @override
  void hold() => _heldUpTo = items.isEmpty ? -1 : items.last.id;

  @override
  void release() {
    _heldUpTo = null;
    if (items.length != _byId.length) {
      _show();
    }
  }

  void _forget() {
    _byId.clear();
    _version = null;
    _stale = true;
    _runs++;
    if (_heldUpTo != null) {
      _heldUpTo = -1;
    }
  }

  @override
  void dispose() {
    _session++;
    super.dispose();
  }
}

enum HttpRequestStatus { all, failed, rewritten }

extension HttpRequestStatusExt on HttpRequestStatus {
  bool holds(MitmExchangeSummary exchange) => switch (this) {
    HttpRequestStatus.all => true,
    HttpRequestStatus.failed => exchange.isFailed,
    HttpRequestStatus.rewritten => exchange.rewritten,
  };

  String get label => switch (this) {
    HttpRequestStatus.all => currentAppLocalizations.connectionsAll,
    HttpRequestStatus.failed => currentAppLocalizations.connectionsFailed,
    HttpRequestStatus.rewritten => currentAppLocalizations.httpRewritten,
  };

  String emptyLabel(AppLocalizations appLocalizations) => switch (this) {
    HttpRequestStatus.all => appLocalizations.nullTip(
      appLocalizations.httpRequests,
    ),
    HttpRequestStatus.failed => appLocalizations.noFailedHttpRequests,
    HttpRequestStatus.rewritten => appLocalizations.noRewrittenHttpRequests,
  };
}

typedef HttpFilterController =
    ConditionFilterController<MitmExchangeSummary, HttpRequestStatus>;

HttpFilterController httpFilters() => ConditionFilterController(
  facets: const <RecordFacet<MitmExchangeSummary>>[],
  statuses: HttpRequestStatus.values,
  fields: HttpField.values,
  labelOf: (status) => status.label,
  statusHolds: (status, item) => status.holds(item),
  showsText: (count) => currentAppLocalizations.httpConditionShows(count),
  valuesInText: (field) => currentAppLocalizations.httpConditionValuesIn(field),
  conditionTip: () => currentAppLocalizations.httpConditionTip,
  suggestedValuesOf: (field, item) => switch (field) {
    HttpField.app => [item.app?.process ?? ''],
    _ => field.valuesOf(item),
  },
);

/// Every connection's requests in [feed] under the minute they started in,
/// following the newest.
class HttpRequestList extends StatelessWidget {
  final HttpRequestFeed feed;
  final HttpFilterController filters;
  final ScrollController scrollController;
  final ValueListenable<int?> selected;
  final ValueChanged<MitmExchangeSummary> onSelect;
  final String? emptyDescription;

  const HttpRequestList({
    super.key,
    required this.feed,
    required this.filters,
    required this.scrollController,
    required this.selected,
    required this.onSelect,
    this.emptyDescription,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return ListenableBuilder(
      listenable: Listenable.merge([feed, filters]),
      builder: (context, _) {
        final exchanges = filters.apply(feed.shown);
        return RecordFeedView<MitmExchangeSummary>(
          rows: GroupedMinuteRows(
            recordMinuteGroups(
              exchanges,
              (exchange) => exchange.start,
              DateTime.now(),
            ),
            (exchange) => ValueKey(exchange.id),
          ),
          isEmpty: exchanges.isEmpty,
          isSearching: feed.isSearching || filters.narrowsPastStatus,
          nullStatus: NullStatus(
            label: filters.status.emptyLabel(appLocalizations),
            description: emptyDescription,
            illustration: NullStatusIllustration.requests,
          ),
          controller: scrollController,
          timeAt: (fraction) => recordAtFraction(exchanges, fraction).start,
          following: feed.following,
          onStopFollowing: () => feed.following = false,
          onFollow: () => feed.following = true,
          onHover: (hovered) => feed.hovered = hovered,
          itemBuilder: (exchange) => MemoBuilder(
            inputs: [exchange, selected, onSelect],
            builder: (_) => RecordSelected(
              selected: selected,
              holds: (selected) => selected == exchange.id,
              builder: (context, selected) => HttpRequestRow(
                exchange: exchange,
                selected: selected,
                onPressed: () => onSelect(exchange),
              ),
            ),
          ),
        );
      },
    );
  }
}

class HttpRequestRow extends StatelessWidget {
  final MitmExchangeSummary exchange;
  final bool selected;
  final VoidCallback onPressed;

  const HttpRequestRow({
    super.key,
    required this.exchange,
    required this.onPressed,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final secondary = colorScheme.onSurfaceVariant;
    final status = exchange.status;
    final mark = exchangeMark(appLocalizations, exchange);
    final (statusText, statusColor) = switch (exchange) {
      _ when status > 0 => (
        '$status',
        httpStatusColor(colorScheme, status) ?? secondary,
      ),
      MitmExchangeSummary(pending: true) => (
        appLocalizations.inProgress,
        secondary,
      ),
      _ => (appLocalizations.connectionsFailed, colorScheme.error),
    };
    final row = DecorationListItem(
      isSelected: selected,
      leading: LabelWell(label: exchange.method),
      title: Text(
        exchange.path.isNotEmpty ? exchange.path : exchange.url,
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
          text: exchange.host,
          labels: [
            RecordLabel(label: httpMillisText(exchange.duration)),
            if (mark != null) RecordLabel(label: mark),
          ],
        ),
      ),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 2,
        children: [
          Text(
            statusText,
            style: AppTextStyle.footnote
                .of(context, emphasized: true)
                .toTabular
                .copyWith(color: statusColor),
          ),
          Text(
            exchange.responseSize.traffic.show,
            style: AppTextStyle.caption2
                .of(context)
                .toTabular
                .copyWith(color: secondary),
          ),
        ],
      ),
      onPressed: onPressed,
    );
    return selected ? RecordSelectedRow(child: row) : row;
  }
}
