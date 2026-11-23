import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/mitm.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tracker_detail_parts.dart';
import 'tracker_texts.dart';
import 'mitm_texts.dart';
import 'tracker_clock.dart';

class TimelineEvent {
  final String kind;
  final String title;
  final String note;
  final DateTime? at;
  final RailMark mark;

  final bool now;

  /// Builds the title from the connection's lifetime, which ticks.
  final String Function(String lifetime)? titleOf;
  final VoidCallback? onPressed;

  const TimelineEvent({
    required this.kind,
    this.title = '',
    this.note = '',
    this.at,
    this.mark = RailMark.step,
    this.now = false,
    this.titleOf,
    this.onPressed,
  });
}

/// The queries [ids] name, newest first, as far as the log still holds them.
@immutable
class _LinkedQueries {
  final List<DnsQuery> queries;

  const _LinkedQueries(this.queries);

  factory _LinkedQueries.of(FixedList<DnsQuery> log, List<int> ids) {
    final queries = <DnsQuery>[];
    for (var index = log.length - 1; index >= 0; index--) {
      final query = log[index];
      if (ids.contains(query.id)) {
        queries.add(query);
        if (queries.length == ids.length) {
          break;
        }
      }
    }
    return _LinkedQueries(queries);
  }

  @override
  bool operator ==(Object other) =>
      other is _LinkedQueries && listEquals(other.queries, queries);

  @override
  int get hashCode => Object.hashAll(queries);
}

String? _dnsModeLabel(AppLocalizations appLocalizations, DnsMode? mode) =>
    switch (mode) {
      DnsMode.fakeIp => appLocalizations.fakeIpMapping,
      DnsMode.redirHost => 'redir-host',
      DnsMode.hosts => appLocalizations.dnsFromHosts,
      DnsMode.normal || null => null,
    };

/// A reload may since have put another rule where this one was routed by.
int? _standingRuleIndex(TrackerInfo trackerInfo, RuleTable? rules) {
  final index = trackerInfo.ruleIndex;
  return index != null &&
          rules != null &&
          rules.holds(
            index,
            type: trackerInfo.rule,
            payload: trackerInfo.rulePayload,
          )
      ? index
      : null;
}

String _milliseconds(int from, int to) =>
    '${((to - from) / Duration.microsecondsPerMillisecond).round()} ms';

List<TimelineEvent> trackerTimelineEvents(
  AppLocalizations appLocalizations,
  TrackerInfo trackerInfo, {
  required List<DnsQuery> dnsQueries,
  required Group? pickedBy,
  required int? delay,
  required int? ruleIndex,
  required List<MitmExchangeSummary> exchanges,
  VoidCallback? onOpenRequests,
}) {
  final metadata = trackerInfo.metadata;
  final timing = trackerInfo.timing;
  final failure = trackerInfo.failure;
  final end = trackerInfo.end;
  final chains = trackerInfo.chains;
  DateTime? at(int? offset) => timing == null || offset == null
      ? null
      : timing.accepted.add(Duration(microseconds: offset));
  String join(List<String?> parts) =>
      parts.whereType<String>().where((part) => part.isNotEmpty).join(' · ');
  final dnsMode = _dnsModeLabel(appLocalizations, metadata.dnsMode);
  final dnsTime = switch (timing) {
    ConnectionTiming(:final dnsStart?, :final dnsEnd?) => _milliseconds(
      dnsStart,
      dnsEnd,
    ),
    _ => null,
  };
  final dialTime = switch (timing) {
    ConnectionTiming(:final dialStart?, :final dialEnd?) =>
      '${appLocalizations.handshake} ${_milliseconds(dialStart, dialEnd)}',
    _ => null,
  };
  final address = metadata.destinationIP.isNotEmpty
      ? metadata.destinationIP
      : metadata.host;
  final target = trackerEndpointText(address, metadata.destinationPort);
  final traffic = join([
    '${appLocalizations.download} ${trackerInfo.download.traffic.show}',
    '${appLocalizations.upload} ${trackerInfo.upload.traffic.show}',
  ]);
  final failed =
      failure != null ||
      end?.reason == ConnectionEndReason.error ||
      end?.reason == ConnectionEndReason.failed;
  MitmExchangeSummary? first;
  MitmExchangeSummary? latest;
  for (final exchange in exchanges) {
    if (first == null || exchange.start.isBefore(first.start)) {
      first = exchange;
    }
    if (latest == null || !exchange.start.isBefore(latest.start)) {
      latest = exchange;
    }
  }
  return [
    for (final query in dnsQueries)
      TimelineEvent(
        kind: 'DNS',
        title: '${query.type} → ${query.summary}',
        note: join([
          dnsMode,
          if (query.cached) appLocalizations.cache,
          '${query.delay} ms',
        ]),
        at: at(timing?.dnsStart),
        mark: query.isFailed ? RailMark.error : RailMark.step,
      ),
    if (dnsQueries.isEmpty &&
        metadata.host.isNotEmpty &&
        (dnsMode != null || dnsTime != null))
      TimelineEvent(
        kind: 'DNS',
        title: metadata.host,
        note: join([dnsMode, dnsTime]),
        at: at(timing?.dnsStart),
      ),
    TimelineEvent(
      kind: appLocalizations.rule,
      title: trackerRuleLine(appLocalizations, trackerInfo),
      note: [
        if (ruleIndex != null)
          appLocalizations.connectionRuleIndex(ruleIndex + 1),
        if (chains.lastOrNull case final target?) '→ $target',
      ].join(' '),
      at: at(timing?.routed),
    ),
    if (chains.length > 1)
      TimelineEvent(
        kind: appLocalizations.proxyNode,
        title: chains.first,
        note: join([
          pickedBy?.type.name,
          if (delay != null) '${appLocalizations.delay} $delay ms',
        ]),
        at: at(timing?.dialStart),
      ),
    TimelineEvent(
      kind: appLocalizations.connection,
      title: '${metadata.network.toUpperCase()} $target',
      note: failure != null
          ? join([failure.kind.label, failure.message])
          : dialTime ?? '',
      at: at(timing?.dialEnd ?? timing?.connected),
      mark: failure != null ? RailMark.error : RailMark.step,
    ),
    if (metadata.mitm)
      TimelineEvent(
        kind: appLocalizations.decryption,
        title: appLocalizations.connectionsDecrypted,
        at: at(timing?.decrypted),
      ),
    if (metadata.mitmRefused)
      TimelineEvent(
        kind: appLocalizations.decryption,
        title: appLocalizations.mitmCertificateRefused,
        mark: RailMark.error,
      ),
    if (first != null && latest != null)
      TimelineEvent(
        kind: 'HTTP',
        title: appLocalizations.httpRequestCount(exchanges.length),
        note: appLocalizations.latestHttpRequest(
          [
            latest.method,
            exchangePathOf(latest.url),
            if (latest.status > 0) '${latest.status}',
          ].join(' '),
        ),
        at: timing == null ? null : first.start,
        onPressed: onOpenRequests,
      ),
    if (trackerInfo.isActive)
      TimelineEvent(
        kind: appLocalizations.status,
        titleOf: (lifetime) =>
            '${appLocalizations.connectionsActive} $lifetime',
        note: traffic,
        mark: RailMark.end,
        now: true,
      )
    else
      TimelineEvent(
        kind: appLocalizations.status,
        titleOf: (lifetime) => '${appLocalizations.connectionClosed} $lifetime',
        note: join([end?.reason.label, traffic]),
        at: timing == null ? null : trackerInfo.endedAt,
        mark: failed ? RailMark.error : RailMark.end,
      ),
  ];
}

/// What happened to a connection, step by step from its address to now; the
/// steps the Core timed carry their time.
class TrackerTimeline extends ConsumerWidget {
  final TrackerInfo trackerInfo;

  /// Shows the connection's HTTP requests, which the timeline sums up in one
  /// step when it is set.
  final VoidCallback? onOpenRequests;

  const TrackerTimeline({
    super.key,
    required this.trackerInfo,
    this.onOpenRequests,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = trackerInfo.dnsQueries;
    final dnsQueries = ids.isEmpty
        ? const <DnsQuery>[]
        : ref
              .watch(
                dnsQueriesProvider.select((log) => _LinkedQueries.of(log, ids)),
              )
              .queries;
    final chains = trackerInfo.chains;
    final pickedBy = chains.length > 1
        ? ref.watch(groupsProvider).getGroup(chains[1])
        : null;
    final delay = chains.length > 1
        ? ref.watch(
            delayProvider(proxyName: chains.first, testUrl: pickedBy?.testUrl),
          )
        : null;
    var exchanges = const <MitmExchangeSummary>[];
    if (onOpenRequests != null) {
      exchanges =
          ref.watch(mitmExchangesProvider(trackerInfo.id)).value?.exchanges ??
          const [];
    }
    final events = trackerTimelineEvents(
      context.appLocalizations,
      trackerInfo,
      onOpenRequests: onOpenRequests,
      exchanges: exchanges,
      dnsQueries: dnsQueries,
      pickedBy: pickedBy,
      delay: delay != null && delay > 0 ? delay : null,
      ruleIndex: trackerInfo.ruleIndex == null
          ? null
          : _standingRuleIndex(
              trackerInfo,
              ref.watch(activeRulesProvider).value,
            ),
    );
    final timed = trackerInfo.timing != null;
    final times = timed ? _timeLabels(context, events) : null;
    return generateSection(
      atTop: true,
      items: [
        for (final (index, event) in events.indexed)
          _EventRow(
            trackerInfo: trackerInfo,
            event: event,
            time: times?[index],
            first: index == 0,
            last: index == events.length - 1,
          ),
      ],
    );
  }
}

/// Each second in full, and only the milliseconds in one already given.
List<String> _timeLabels(BuildContext context, List<TimelineEvent> events) {
  final now = context.appLocalizations.now;
  int? shownSecond;
  final labels = <String>[];
  for (final event in events) {
    final at = event.at?.toLocal();
    if (at == null) {
      labels.add(event.now ? now : '');
      continue;
    }
    final second = at.millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
    labels.add(
      second == shownSecond
          ? '.${at.millisecond.toString().padLeft(3, '0')}'
          : '${twoDigits(at.hour)}:${twoDigits(at.minute)}:${twoDigits(at.second)}',
    );
    shownSecond = second;
  }
  return labels;
}

class _EventRow extends StatelessWidget {
  final TrackerInfo trackerInfo;
  final TimelineEvent event;
  final String? time;
  final bool first;
  final bool last;

  const _EventRow({
    required this.trackerInfo,
    required this.event,
    required this.time,
    required this.first,
    required this.last,
  });

  Widget _build(String title) {
    final time = this.time;
    return TrackerRailRow(
      title: title,
      subtitle: [
        event.kind,
        event.note,
      ].where((part) => part.isNotEmpty).join(' · '),
      trailing: time == null || time.isEmpty ? null : Text(time),
      mark: event.mark,
      first: first,
      last: last,
      onPressed: event.onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleOf = event.titleOf;
    if (titleOf == null) {
      return _build(event.title);
    }
    return TrackerLifetime(
      trackerInfo: trackerInfo,
      builder: (lifetime) => _build(titleOf(lifetime)),
    );
  }
}
