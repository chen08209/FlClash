import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

TrackerInfo _tracker(
  String id, {
  String host = 'example.com',
  String process = 'curl',
  List<String> chains = const ['Proxy'],
  String? rule = 'DOMAIN',
  String specialProxy = '',
}) {
  return TrackerInfo(
    id: id,
    start: DateTime.utc(2026),
    metadata: Metadata(
      network: 'tcp',
      host: host,
      process: process,
      specialProxy: specialProxy,
    ),
    chains: chains,
    rule: rule ?? '',
    rulePayload: rule == null ? '' : host,
  );
}

void main() {
  final trackers = [
    _tracker('a', host: 'api.github.com', process: 'chrome'),
    _tracker('b', host: 'github.com', process: 'curl', chains: ['Tokyo']),
    _tracker('c', host: 'ads.doubleclick.net', process: 'chrome'),
    _tracker('d', host: 'example.com', process: 'firefox'),
    _tracker('e', host: 'www.google.com', process: 'Google Chrome Helper'),
  ];

  List<String> matching(String query) => [
    for (final tracker in trackers)
      if (ConnectionQuery.parse(query).matcher(tracker)) tracker.id,
  ];

  test('reads the conditions out of a search and keeps the rest as text', () {
    final query = ConnectionQuery.parse('  host:github.com  chrome -app:curl ');
    expect(query.conditions, [
      ConnectionCondition(ConnectionField.host, 'github.com'),
      ConnectionCondition(ConnectionField.app, 'curl', excludes: true),
    ]);
    expect(query.text, 'chrome');
    expect(ConnectionQuery.parse('nohost:x').conditions, isEmpty);
    expect(ConnectionQuery.parse('host:').conditions, isEmpty);
    expect('${query.conditions.last}', '-app:curl');
  });

  test('conditions on one field widen, on different fields narrow', () {
    expect(matching('host:github app:chrome'), ['a']);
    expect(matching('app:chrome app:firefox'), ['a', 'c', 'd', 'e']);
    expect(matching('host:GitHub exit:tokyo'), ['b']);
  });

  test('a value in quotes keeps its spaces, and an unclosed one runs to '
      'the end', () {
    final query = ConnectionQuery.parse(
      'app:"Google Chrome" -host:"ads x" helper',
    );
    expect(query.conditions, [
      ConnectionCondition(ConnectionField.app, 'Google Chrome'),
      ConnectionCondition(ConnectionField.host, 'ads x', excludes: true),
    ]);
    expect(query.text, 'helper');
    expect('${query.conditions.first}', 'app:"Google Chrome"');
    expect(matching('app:"google chrome"'), ['e']);
    expect(matching('app:"Google Chr'), ['e']);
    expect(ConnectionQuery.parse('host:""').conditions, isEmpty);
  });

  test('an = after the colon asks for the whole value', () {
    final query = ConnectionQuery.parse('host:=github.com -app:=chrome app:=');
    expect(query.conditions, [
      ConnectionCondition(
        ConnectionField.host,
        'github.com',
        match: ConditionMatch.equals,
      ),
      ConnectionCondition(
        ConnectionField.app,
        'chrome',
        excludes: true,
        match: ConditionMatch.equals,
      ),
    ]);
    expect(query.text, 'app:=');
    expect('${query.conditions.last}', '-app:=chrome');
    expect(matching('host:=GitHub.com'), ['b']);
    expect(matching('host:github.com'), ['a', 'b']);
    expect(matching('app:=chrome'), ['a', 'c']);
    expect(matching('app:="google chrome"'), isEmpty);
    expect(matching('app:="google chrome helper"'), ['e']);
  });

  test('an excluding condition drops what it holds', () {
    expect(matching('app:chrome -host:doubleclick'), ['a', 'e']);
    expect(matching('-app:chrome -app:curl'), ['d']);
  });

  test('a connection no rule matched names what routed it', () {
    final appLocalizations = currentAppLocalizations;
    final unruled = [
      _tracker('global', rule: null, chains: ['Tokyo', 'GLOBAL']),
      _tracker('direct', rule: null, chains: ['DIRECT']),
      _tracker(
        'listener',
        rule: null,
        chains: ['GLOBAL'],
        specialProxy: 'GLOBAL',
      ),
    ];
    expect(
      [
        for (final tracker in unruled)
          trackerRuleText(appLocalizations, tracker),
      ],
      [
        appLocalizations.connectionRuleGlobal,
        appLocalizations.connectionRuleNone,
        appLocalizations.connectionRuleNone,
      ],
    );
    expect(
      trackerRuleText(appLocalizations, trackers.first),
      'DOMAIN(api.github.com)',
    );
    final ruleFacet = trackerInfoFacets.firstWhere(
      (facet) => facet.kind == RecordFacetKind.rule,
    );
    expect(ruleFacet.valuesOf(unruled.first), [
      appLocalizations.connectionRuleGlobal,
    ]);
    expect(ruleFacet.valuesOf(trackers.first), ['DOMAIN']);
    final query = ConnectionQuery.parse(
      'rule:"${appLocalizations.connectionRuleNone}"',
    );
    expect(
      [
        for (final tracker in unruled)
          if (query.matcher(tracker)) tracker.id,
      ],
      ['direct', 'listener'],
    );
  });
}
