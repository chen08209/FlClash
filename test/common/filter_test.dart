import 'dart:ui';

import 'package:fl_clash/common/app_localizations.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/connection/connection.dart';
import 'package:fl_clash/models/models.dart';
import 'package:test/test.dart';

void main() {
  group('DnsQueryFeed.shown', () {
    setUpAll(() => loadAppLocalizations(const Locale('en')));

    DnsQuery dnsQuery(
      String domain, {
      String type = 'A',
      DnsQueryInitiator? initiator,
      bool cached = false,
      List<String> answers = const [],
      String rcode = 'NOERROR',
    }) => DnsQuery(
      domain: domain,
      type: type,
      initiator: initiator,
      cached: cached,
      answers: answers,
      rcode: rcode,
      time: DateTime.utc(2026),
    );

    final queries = [
      dnsQuery('a.test', initiator: DnsQueryInitiator.app),
      dnsQuery('b.test', type: 'AAAA', answers: ['2001:DB8::1']),
      dnsQuery('c.test', rcode: 'NXDOMAIN'),
      dnsQuery('d.test', initiator: DnsQueryInitiator.direct, cached: true),
    ];

    DnsQueryFeed searched(List<DnsQuery> queries, String query) =>
        DnsQueryFeed()
          ..offer(queries)
          ..search(query);

    List<String> domains(List<DnsQuery> queries, String query) => searched(
      queries,
      query,
    ).shown.map((dnsQuery) => dnsQuery.domain).toList();

    List<String> filtered(RecordFacetKind kind, String value) => queries
        .whereFilters(dnsQueryFacets, [RecordFilter(kind, value)])
        .map((dnsQuery) => dnsQuery.domain)
        .toList();

    test('filters match the chips a query shows', () {
      expect(filtered(RecordFacetKind.initiator, 'App'), ['a.test']);
      expect(filtered(RecordFacetKind.type, 'AAAA'), ['b.test']);
      expect(filtered(RecordFacetKind.rcode, 'NXDOMAIN'), ['c.test']);
      expect(filtered(RecordFacetKind.rcode, 'NOERROR'), isEmpty);
      expect(filtered(RecordFacetKind.initiator, 'Direct'), ['d.test']);
      expect(filtered(RecordFacetKind.cache, 'Cache'), ['d.test']);
    });

    test('the initiator and a cache hit are chips', () {
      expect(queries[3].tags, ['A', 'Direct', 'Cache']);
    });

    test('an unknown initiator and a clean rcode are not chips', () {
      expect(queries[1].tags, ['AAAA']);
    });

    test('query matches the domain or an answer, case-insensitively', () {
      expect(domains(queries, 'C.TEST'), ['c.test']);
      expect(domains(queries, '2001:db8'), ['b.test']);
    });

    test('query matches the upstream, the error and the chips', () {
      final queries = [
        DnsQuery(
          domain: 'a.test',
          type: 'A',
          upstream: 'https://dns.example/dns-query',
          time: DateTime.utc(2026),
        ),
        DnsQuery(
          domain: 'b.test',
          type: 'AAAA',
          error: 'i/o timeout',
          time: DateTime.utc(2026),
        ),
      ];
      expect(domains(queries, 'dns.example'), ['a.test']);
      expect(domains(queries, 'timeout'), ['b.test']);
      expect(domains(queries, 'aaaa'), ['b.test']);
    });

    test('every query term has to match', () {
      expect(domains(queries, 'test app'), ['a.test']);
      expect(domains(queries, 'a.test aaaa'), isEmpty);
    });

    test('is searching once a query is set', () {
      expect(searched(queries, '').isSearching, isFalse);
      expect(searched(queries, '  ').isSearching, isFalse);
      expect(searched(queries, 'a').isSearching, isTrue);
    });
  });

  group('LogsState.list', () {
    Log log(LogLevel level, String payload) =>
        Log(logLevel: level, payload: payload, dateTime: '2024-01-01');

    test('returns all logs when the query is empty', () {
      final state = LogsState(
        logs: [
          log(LogLevel.info, 'test message'),
          log(LogLevel.error, 'error occurred'),
        ],
      );
      expect(state.list.length, 2);
    });

    test('filters by log level', () {
      final logs =
          [
            log(LogLevel.info, 'info msg'),
            log(LogLevel.error, 'error msg'),
          ].whereFilters(logFacets, const [
            RecordFilter(RecordFacetKind.level, 'error'),
          ]).toList();
      expect(logs.length, 1);
      expect(logs[0].logLevel, LogLevel.error);
    });

    test('filters by query matching payload', () {
      final state = LogsState(
        logs: [
          log(LogLevel.info, 'connection established'),
          log(LogLevel.info, 'timeout error'),
        ],
        query: 'timeout',
      );
      expect(state.list.length, 1);
      expect(state.list[0].payload, 'timeout error');
    });

    test('query is case insensitive', () {
      final state = LogsState(
        logs: [log(LogLevel.info, 'Connection Established')],
        query: 'connection',
      );
      expect(state.list.length, 1);
    });

    test('query also matches log level name', () {
      final state = LogsState(
        logs: [log(LogLevel.info, 'test'), log(LogLevel.error, 'test')],
        query: 'error',
      );
      expect(state.list.length, 1);
      expect(state.list[0].logLevel, LogLevel.error);
    });

    test('empty result when no match', () {
      final state = LogsState(
        logs: [log(LogLevel.info, 'hello')],
        query: 'nonexistent',
      );
      expect(state.list, isEmpty);
    });

    test('query terms match in any order and across fields', () {
      final state = LogsState(
        logs: [
          log(LogLevel.error, 'dial tcp timeout'),
          log(LogLevel.info, 'dial tcp ok'),
        ],
        query: 'TIMEOUT dial',
      );
      expect(state.list.single.payload, 'dial tcp timeout');
      expect(
        state.copyWith(query: 'error dial').list.single.payload,
        'dial tcp timeout',
      );
    });
  });

  group('trackerInfoQueryMatcher', () {
    Metadata meta({
      String network = 'tcp',
      String host = 'example.com',
      String destinationIP = '1.2.3.4',
      String process = 'chrome',
    }) => Metadata(
      network: network,
      host: host,
      destinationIP: destinationIP,
      process: process,
    );

    TrackerInfo tracker(
      int id, {
      List<String> chains = const ['proxy-a'],
      Metadata? metadata,
      String rule = 'MATCH',
      String rulePayload = '',
    }) => TrackerInfo(
      id: id,
      start: DateTime(2024),
      metadata: metadata ?? meta(),
      chains: chains,
      rule: rule,
      rulePayload: rulePayload,
    );

    test('returns all when the query is empty', () {
      final state = _searched(trackerInfos: [tracker(1)]);
      expect(state.list.length, 1);
    });

    test('filters by a proxy anywhere in the chain', () {
      final infos =
          [
            tracker(1, chains: ['proxy-a', 'proxy-b']),
            tracker(2, chains: ['proxy-c']),
          ].whereFilters(trackerInfoFacets, const [
            RecordFilter(RecordFacetKind.proxy, 'proxy-b'),
          ]).toList();
      expect(infos.map((info) => info.id), [1]);
    });

    test('filters by process', () {
      final infos =
          [
            tracker(1, metadata: meta(process: 'chrome')),
            tracker(2, metadata: meta(process: 'firefox')),
          ].whereFilters(trackerInfoFacets, const [
            RecordFilter(RecordFacetKind.app, 'firefox'),
          ]).toList();
      expect(infos.map((info) => info.id), [2]);
    });

    test('query matches host', () {
      final state = _searched(
        trackerInfos: [
          tracker(1, metadata: meta(host: 'google.com')),
          tracker(2, metadata: meta(host: 'github.com')),
        ],
        query: 'github',
      );
      expect(state.list.length, 1);
      expect(state.list[0].id, 2);
    });

    test('query matches network', () {
      final state = _searched(
        trackerInfos: [
          tracker(1, metadata: meta(network: 'tcp')),
          tracker(2, metadata: meta(network: 'udp')),
        ],
        query: 'udp',
      );
      expect(state.list.length, 1);
      expect(state.list[0].id, 2);
    });

    test('query matches destinationIP', () {
      final state = _searched(
        trackerInfos: [
          tracker(1, metadata: meta(destinationIP: '10.0.0.1')),
          tracker(2, metadata: meta(destinationIP: '192.168.1.1')),
        ],
        query: '192.168',
      );
      expect(state.list.length, 1);
      expect(state.list[0].id, 2);
    });

    test('query matches chains text', () {
      final state = _searched(
        trackerInfos: [
          tracker(1, chains: ['proxy-a']),
          tracker(2, chains: ['proxy-b']),
        ],
        query: 'proxy-b',
      );
      expect(state.list.length, 1);
      expect(state.list[0].id, 2);
    });

    test('query matches the rule and its payload', () {
      final trackerInfos = [
        tracker(1),
        tracker(2, rule: 'DomainSuffix', rulePayload: 'googleapis.com'),
      ];
      expect(
        _searched(
          trackerInfos: trackerInfos,
          query: 'domainsuffix',
        ).list.single.id,
        2,
      );
      expect(
        _searched(
          trackerInfos: trackerInfos,
          query: 'googleapis',
        ).list.single.id,
        2,
      );
    });

    test('query matches the source address and the process path', () {
      final trackerInfos = [
        tracker(1),
        tracker(
          2,
          metadata: const Metadata(
            sourceIP: '198.18.0.1',
            sourcePort: '53211',
            processPath: '/usr/bin/curl',
          ),
        ),
      ];
      expect(
        _searched(
          trackerInfos: trackerInfos,
          query: '198.18.0.1',
        ).list.single.id,
        2,
      );
      expect(
        _searched(trackerInfos: trackerInfos, query: '53211').list.single.id,
        2,
      );
      expect(
        _searched(trackerInfos: trackerInfos, query: '/usr/bin').list.single.id,
        2,
      );
    });

    test('every query term has to match', () {
      final state = _searched(
        trackerInfos: [
          tracker(1, metadata: meta(host: 'github.com')),
          tracker(
            2,
            chains: ['proxy-b'],
            metadata: meta(host: 'github.com'),
          ),
        ],
        query: 'GitHub proxy-b',
      );
      expect(state.list.single.id, 2);
    });
  });
}

({List<TrackerInfo> list}) _searched({
  required List<TrackerInfo> trackerInfos,
  String query = '',
}) {
  final matches = trackerInfoQueryMatcher(query);
  return (
    list: matches == null ? trackerInfos : trackerInfos.where(matches).toList(),
  );
}
