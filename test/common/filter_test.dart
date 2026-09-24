import 'dart:ui';

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:test/test.dart';

void main() {
  group('DnsQueriesState.list', () {
    setUpAll(() => AppLocalizations.load(const Locale('en')));

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

    final state = DnsQueriesState(
      dnsQueries: [
        dnsQuery('a.test', initiator: DnsQueryInitiator.app),
        dnsQuery('b.test', type: 'AAAA', answers: ['2001:DB8::1']),
        dnsQuery('c.test', rcode: 'NXDOMAIN'),
        dnsQuery('d.test', initiator: DnsQueryInitiator.direct, cached: true),
      ],
    );

    List<String> domains(DnsQueriesState state) =>
        state.list.map((dnsQuery) => dnsQuery.domain).toList();

    test('keywords match the chips a query shows', () {
      expect(domains(state.copyWith(keywords: ['App'])), ['a.test']);
      expect(domains(state.copyWith(keywords: ['AAAA'])), ['b.test']);
      expect(domains(state.copyWith(keywords: ['NXDOMAIN'])), ['c.test']);
      expect(domains(state.copyWith(keywords: ['NOERROR'])), isEmpty);
      expect(domains(state.copyWith(keywords: ['Direct'])), ['d.test']);
      expect(domains(state.copyWith(keywords: ['Cache'])), ['d.test']);
    });

    test('the initiator and a cache hit are chips', () {
      expect(state.dnsQueries[3].tags, ['A', 'Direct', 'Cache']);
    });

    test('an unknown initiator and a clean rcode are not chips', () {
      expect(state.dnsQueries[1].tags, ['AAAA']);
    });

    test('query matches the domain or an answer, case-insensitively', () {
      expect(domains(state.copyWith(query: 'C.TEST')), ['c.test']);
      expect(domains(state.copyWith(query: '2001:db8')), ['b.test']);
    });

    test('query matches the upstream, the error and the chips', () {
      final state = DnsQueriesState(
        dnsQueries: [
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
        ],
      );
      expect(domains(state.copyWith(query: 'dns.example')), ['a.test']);
      expect(domains(state.copyWith(query: 'timeout')), ['b.test']);
      expect(domains(state.copyWith(query: 'aaaa')), ['b.test']);
    });

    test('every query term has to match', () {
      expect(domains(state.copyWith(query: 'test app')), ['a.test']);
      expect(domains(state.copyWith(query: 'a.test aaaa')), isEmpty);
    });

    test('is searching once a query or a keyword is set', () {
      expect(state.isSearching, isFalse);
      expect(state.copyWith(query: '  ').isSearching, isFalse);
      expect(state.copyWith(query: 'a').isSearching, isTrue);
      expect(state.copyWith(keywords: ['A']).isSearching, isTrue);
    });
  });

  group('LogsState.list', () {
    Log log(LogLevel level, String payload) =>
        Log(logLevel: level, payload: payload, dateTime: '2024-01-01');

    test('returns all logs when no keywords and empty query', () {
      final state = LogsState(
        logs: [
          log(LogLevel.info, 'test message'),
          log(LogLevel.error, 'error occurred'),
        ],
      );
      expect(state.list.length, 2);
    });

    test('filters by keyword matching log level', () {
      final state = LogsState(
        logs: [
          log(LogLevel.info, 'info msg'),
          log(LogLevel.error, 'error msg'),
        ],
        keywords: ['error'],
      );
      expect(state.list.length, 1);
      expect(state.list[0].logLevel, LogLevel.error);
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

  group('TrackerInfosState.list', () {
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
      String id, {
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

    test('returns all when no keywords and empty query', () {
      final state = TrackerInfosState(trackerInfos: [tracker('1')]);
      expect(state.list.length, 1);
    });

    test('filters by keyword matching chain name', () {
      final state = TrackerInfosState(
        trackerInfos: [
          tracker('1', chains: ['proxy-a', 'proxy-b']),
          tracker('2', chains: ['proxy-c']),
        ],
        keywords: ['proxy-a'],
      );
      expect(state.list.length, 1);
      expect(state.list[0].id, '1');
    });

    test('filters by keyword matching process', () {
      final state = TrackerInfosState(
        trackerInfos: [
          tracker('1', metadata: meta(process: 'chrome')),
          tracker('2', metadata: meta(process: 'firefox')),
        ],
        keywords: ['firefox'],
      );
      expect(state.list.length, 1);
      expect(state.list[0].id, '2');
    });

    test('query matches host', () {
      final state = TrackerInfosState(
        trackerInfos: [
          tracker('1', metadata: meta(host: 'google.com')),
          tracker('2', metadata: meta(host: 'github.com')),
        ],
        query: 'github',
      );
      expect(state.list.length, 1);
      expect(state.list[0].id, '2');
    });

    test('query matches network', () {
      final state = TrackerInfosState(
        trackerInfos: [
          tracker('1', metadata: meta(network: 'tcp')),
          tracker('2', metadata: meta(network: 'udp')),
        ],
        query: 'udp',
      );
      expect(state.list.length, 1);
      expect(state.list[0].id, '2');
    });

    test('query matches destinationIP', () {
      final state = TrackerInfosState(
        trackerInfos: [
          tracker('1', metadata: meta(destinationIP: '10.0.0.1')),
          tracker('2', metadata: meta(destinationIP: '192.168.1.1')),
        ],
        query: '192.168',
      );
      expect(state.list.length, 1);
      expect(state.list[0].id, '2');
    });

    test('query matches chains text', () {
      final state = TrackerInfosState(
        trackerInfos: [
          tracker('1', chains: ['proxy-a']),
          tracker('2', chains: ['proxy-b']),
        ],
        query: 'proxy-b',
      );
      expect(state.list.length, 1);
      expect(state.list[0].id, '2');
    });

    test('query matches the rule and its payload', () {
      final state = TrackerInfosState(
        trackerInfos: [
          tracker('1'),
          tracker('2', rule: 'DomainSuffix', rulePayload: 'googleapis.com'),
        ],
      );
      expect(state.copyWith(query: 'domainsuffix').list.single.id, '2');
      expect(state.copyWith(query: 'googleapis').list.single.id, '2');
    });

    test('query matches the source address and the process path', () {
      final state = TrackerInfosState(
        trackerInfos: [
          tracker('1'),
          tracker(
            '2',
            metadata: const Metadata(
              sourceIP: '198.18.0.1',
              sourcePort: '53211',
              processPath: '/usr/bin/curl',
            ),
          ),
        ],
      );
      expect(state.copyWith(query: '198.18.0.1').list.single.id, '2');
      expect(state.copyWith(query: '53211').list.single.id, '2');
      expect(state.copyWith(query: '/usr/bin').list.single.id, '2');
    });

    test('every query term has to match', () {
      final state = TrackerInfosState(
        trackerInfos: [
          tracker('1', metadata: meta(host: 'github.com')),
          tracker(
            '2',
            chains: ['proxy-b'],
            metadata: meta(host: 'github.com'),
          ),
        ],
        query: 'GitHub proxy-b',
      );
      expect(state.list.single.id, '2');
    });
  });
}
