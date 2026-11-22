import 'dart:math';

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/features.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

final _t0 = DateTime.utc(2026, 11, 21, 8);

TrackerInfo _connection(
  String id, {
  int second = 0,
  String host = 'example.com',
  bool failed = false,
}) => TrackerInfo(
  id: id,
  start: _t0.add(Duration(seconds: second)),
  metadata: Metadata(network: 'tcp', host: host),
  chains: const ['Proxy'],
  rule: 'MATCH',
  rulePayload: '',
  closedAt: failed ? _t0 : null,
  failure: failed
      ? const ConnectionFailure(kind: ConnectionFailureKind.refused)
      : null,
);

List<String> _ids(ConnectionRows rows) => [
  for (var index = 0; index < rows.length; index++)
    if (rows.rowAt(index) case MinuteRecord(:final item)) item,
];

List<String> _rows(ConnectionRows rows) => [
  for (var index = 0; index < rows.length; index++)
    switch (rows.rowAt(index)) {
      MinuteRecord(:final item, :final position) =>
        '$item ${position.name} ${rows.infoOf(item).isActive}',
      MinuteHeader(:final minute, :final count) => '[$minute $count]',
    },
];

void main() {
  test('a scrollbar asking the time of a list emptied under it gets none, '
      'and of a full one the row at that point', () {
    final rows = ConnectionRows();
    addTearDown(rows.dispose);
    var log = ConnectionLog(10).open([
      _connection('a'),
      _connection('b', second: 1),
      _connection('c', second: 2),
    ]);
    rows.follow(log);
    expect(rows.atFraction(0.5)?.id, 'b');

    log = ConnectionLog(10);
    rows.follow(log);

    expect(rows.atFraction(0.5), isNull);
  });

  test('a following list the pointer rests on keeps the connections that '
      'open out until it leaves, and goes on changing the rows it shows', () {
    final rows = ConnectionRows();
    addTearDown(rows.dispose);
    var log = ConnectionLog(10).open([_connection('a')]);
    rows
      ..follow(log)
      ..hovered = true;

    log = log
        .open([_connection('b', second: 1)])
        .updateTraffic({'a': (upload: 0, download: 10)})
        .close(['a'], _t0);
    rows.update(log);

    expect(_ids(rows), ['a']);
    expect(rows.infoOf('a').isActive, isFalse);
    expect(rows.infoOf('a').download, 10);
    expect(rows.countOf(ConnectionStatus.all), 1);

    rows.hovered = false;

    expect(_ids(rows), ['a', 'b']);
    expect(rows.countOf(ConnectionStatus.active), 1);
  });

  test(
    'scrolled off its end under the pointer, a list takes in the '
    'connections that waited and keeps the pointer\'s rows where they are',
    () {
      final rows = ConnectionRows();
      addTearDown(rows.dispose);
      var log = ConnectionLog(10).open([_connection('a')]);
      rows
        ..follow(log)
        ..hovered = true;
      log = log.open([_connection('b', second: 1)]);
      rows.update(log);

      rows.following = false;

      expect(_ids(rows), ['a', 'b']);
      expect(rows.following, isFalse);
      expect(rows.holdsNew, isFalse);
    },
  );

  test('a list off its end does not hold the connections that open under '
      'the pointer', () {
    final rows = ConnectionRows();
    addTearDown(rows.dispose);
    var log = ConnectionLog(10).open([_connection('a')]);
    rows
      ..follow(log)
      ..following = false
      ..hovered = true;

    log = log.open([_connection('b', second: 1)]);
    rows.update(log);

    expect(_ids(rows), ['a', 'b']);
  });

  test('a list off its end keeps its rows, gone or not, and adds the new '
      'connections after them', () {
    final rows = ConnectionRows();
    addTearDown(rows.dispose);
    var log = ConnectionLog(
      1,
    ).open([_connection('a'), _connection('b', second: 1)]);
    rows
      ..follow(log)
      ..following = false;

    log = log
        .updateTraffic({'b': (upload: 0, download: 10)})
        .close(['a'], _t0)
        .close(['b'], _t0)
        .open([_connection('c', second: 2), _connection('d', second: 3)]);
    rows.update(log);

    expect(log['a'], isNull);
    expect(_ids(rows), ['a', 'b', 'c', 'd']);
    expect(rows.infoOf('a').isActive, isFalse);
    expect(rows.infoOf('b').download, 10);
    expect(rows.countOf(ConnectionStatus.active), 2);
  });

  test('a list off its end that missed the changes ends as one that saw '
      'them: its rows, the trimmed ones closed, then new ones up to its '
      'limit', () {
    final start = ConnectionLog(
      1,
    ).open([_connection('a'), _connection('b', second: 1)]);
    ConnectionRows offEnd() {
      final rows = ConnectionRows(rowLimit: 6)
        ..follow(start)
        ..following = false;
      addTearDown(rows.dispose);
      return rows;
    }

    final seen = offEnd();
    final missed = offEnd();
    var log = start.close(['a'], _t0).close(['b'], _t0);
    seen.update(log);
    for (var batch = 0; batch < 9; batch++) {
      log = log.open([
        for (var index = batch * 1000; index < (batch + 1) * 1000; index++)
          _connection('n$index', second: 2),
      ]);
      seen.update(log);
    }
    expect(log.changesSince(start.revision), isNull);
    missed.update(log);

    expect(_ids(seen), ['a', 'b', 'n0', 'n1', 'n2', 'n3']);
    expect(_rows(missed), _rows(seen));
    expect(missed.counts, seen.counts);
  });

  for (final missesChanges in [false, true]) {
    test('a held row the log has forgotten altogether still closes, by the '
        'oldest close the log remembers'
        '${missesChanges ? ', though the list missed the changes' : ''}', () {
      final rows = ConnectionRows();
      addTearDown(rows.dispose);
      var log = ConnectionLog(1).open([
        for (final (second, id) in ['a', 'b', 'c', 'd'].indexed)
          _connection(id, second: second),
      ]);
      rows
        ..follow(log)
        ..following = false;

      for (final (second, id) in ['a', 'b', 'c'].indexed) {
        log = log.close([id], _t0.add(Duration(seconds: 10 + second)));
      }
      if (missesChanges) {
        log = log.open([
          for (var index = 0; index < 9000; index++)
            _connection('n$index', second: 5),
        ]);
      }
      expect(log.lastOf('a'), isNull);
      rows.update(log);

      expect(rows.infoOf('a').closedAt, _t0.add(const Duration(seconds: 11)));
      expect(rows.infoOf('b').closedAt, _t0.add(const Duration(seconds: 11)));
      expect(rows.infoOf('d').isActive, isTrue);
      expect(rows.countOf(ConnectionStatus.active), rows.held.length - 3);
    });
  }

  test('a held list that missed the changes keeps its rows once it is '
      'scrolled off its end, rather than starting over from the log', () {
    final rows = ConnectionRows(rowLimit: 6);
    addTearDown(rows.dispose);
    var log = ConnectionLog(
      1,
    ).open([_connection('a'), _connection('b', second: 1)]);
    rows
      ..follow(log)
      ..hovered = true;

    log = log.close(['a'], _t0).close(['b'], _t0).open([
      for (var index = 0; index < 9000; index++)
        _connection('n$index', second: 2),
    ]);
    rows
      ..update(log)
      ..following = false;

    expect(_ids(rows), ['a', 'b', 'n0', 'n1', 'n2', 'n3']);
    expect(rows.countOf(ConnectionStatus.active), 4);
  });

  test('a list off its end takes new connections only up to its row limit, '
      'and has the latest again once it follows', () {
    final rows = ConnectionRows(rowLimit: 4);
    addTearDown(rows.dispose);
    List<TrackerInfo> range(int from, int to) => [
      for (var index = from; index < to; index++)
        _connection('c$index', second: index),
    ];
    var log = ConnectionLog(10).open(range(0, 2));
    rows
      ..follow(log)
      ..following = false;

    log = log.open(range(2, 7));
    rows.update(log);
    expect(_ids(rows), ['c0', 'c1', 'c2', 'c3']);

    log = log.open(range(7, 12));
    rows.update(log);
    expect(_ids(rows), ['c0', 'c1', 'c2', 'c3']);

    rows.follow(log);
    expect(_ids(rows), [for (var index = 0; index < 12; index++) 'c$index']);
  });

  testWidgets('traffic alone ticks the traffic, not the rows', (tester) async {
    final rows = ConnectionRows();
    addTearDown(rows.dispose);
    var log = ConnectionLog(1).open([_connection('a')]);
    rows.follow(log);
    var rowsChanged = 0;
    var trafficTicked = 0;
    rows.addListener(() => rowsChanged++);
    rows.traffic.addListener(() => trafficTicked++);

    log = log.updateTraffic({'a': (upload: 0, download: 10)});
    rows.update(log);
    await tester.pump();
    expect((rowsChanged, trafficTicked), (0, 1));
    expect(rows.infoOf('a').download, 10);
    expect(rows.detailsOf('a').download, 0);

    log = log.close(['a'], _t0);
    rows.update(log);
    expect(rowsChanged, 1);
    await tester.pump();
    expect(trafficTicked, 2);
    expect(rows.detailsOf('a').isActive, isFalse);
  });

  test('a row keeps its index across what the log changes around it', () {
    final rows = ConnectionRows();
    addTearDown(rows.dispose);
    var log = ConnectionLog(1).open([
      _connection('a'),
      _connection('b', second: 61),
      _connection('c', second: 62),
    ]);
    rows.follow(log);

    log = log.close(['a', 'b'], _t0);
    rows.update(log);

    expect(_rows(rows), ['b end false', 'c start true', '[29920801 2]']);
    expect(rows.indexOfKey(rows.keyOf('c')), 1);
    expect(rows.indexOfKey(const MinuteHeader(29920801, '', 0).key), 2);
    expect(rows.indexOfKey(rows.keyOf('a')), isNull);
  });

  test('a log of a new run replaces the rows, however far its revision '
      'has come', () {
    final rows = ConnectionRows();
    addTearDown(rows.dispose);
    final old = ConnectionLog(4)
        .open([_connection('a')])
        .open([_connection('b', second: 1)])
        .updateTraffic({'b': (upload: 0, download: 10)});
    rows.follow(old);

    var log = ConnectionLog(4);
    for (final (index, id) in ['c', 'd', 'e', 'f'].indexed) {
      log = log.open([_connection(id, second: 2 + index)]);
    }
    expect(log.revision, greaterThan(old.revision));
    rows.update(log);

    expect(_ids(rows), ['c', 'd', 'e', 'f']);
    expect(rows.counts, {
      ConnectionStatus.all: 4,
      ConnectionStatus.active: 4,
      ConnectionStatus.failed: 0,
    });
  });

  void expectFreshRows({required int most}) {
    final random = Random(7);
    for (var round = 0; round < 40; round++) {
      final rows = ConnectionRows();
      var log = ConnectionLog(1 + random.nextInt(12));
      var next = 0;
      final shows = switch (round % 4) {
        0 => null,
        1 => (TrackerInfo info) => info.isActive,
        2 => (TrackerInfo info) => info.metadata.host != 'b.test',
        _ => (TrackerInfo info) => info.failure != null,
      };
      final repeatKeyOf = round % 4 == 3 ? trackerRepeatKeyOf : null;
      rows
        ..follow(log)
        ..showWhere(shows, repeatKeyOf: repeatKeyOf);
      for (var step = 0; step < 30; step++) {
        final open = [
          for (final info in log.list)
            if (info.isActive) info.id,
        ];
        switch (random.nextInt(4)) {
          case 0 || 1:
            log = log.open([
              for (var count = random.nextInt(most); count > 0; count--)
                _connection(
                  'n${next++}',
                  second: random.nextInt(240),
                  host: ['a.test', 'b.test'][random.nextInt(2)],
                  failed: random.nextInt(3) == 0,
                ),
            ]);
          case 2 when open.isNotEmpty:
            log = log.close([
              for (var count = 1 + random.nextInt(most); count > 0; count--)
                open[random.nextInt(open.length)],
            ], _t0);
          case _ when open.isNotEmpty:
            log = log.updateTraffic({
              open[random.nextInt(open.length)]: (
                upload: random.nextInt(100),
                download: random.nextInt(100),
              ),
            });
        }
        rows.update(log);
      }
      final fresh = ConnectionRows()
        ..follow(log)
        ..showWhere(shows, repeatKeyOf: repeatKeyOf);
      expect(_rows(rows), _rows(fresh), reason: 'round $round');
      expect(rows.repeats, fresh.repeats, reason: 'round $round');
      expect(rows.counts, fresh.counts, reason: 'round $round');
      for (var index = 0; index < rows.length; index++) {
        final key = switch (rows.rowAt(index)) {
          MinuteRecord(:final item) => rows.keyOf(item),
          final MinuteHeader<String> header => header.key,
        };
        expect(rows.indexOfKey(key), index, reason: 'round $round');
      }
      rows.dispose();
      fresh.dispose();
    }
  }

  test(
    'changes taken one by one leave the rows a fresh read of the log '
    'would show',
    () => expectFreshRows(most: 4),
  );

  test(
    'changes taken hundreds at a time leave the rows a fresh read of the '
    'log would show',
    () => expectFreshRows(most: 300),
  );

  test('closing thousands of connections at once costs about what placing '
      'every row again does, not a move of the rows per connection', () {
    final connections = [
      for (var index = 0; index < 5000; index++)
        _connection('c$index', second: index),
    ];
    var update = 1 << 62;
    var replace = 1 << 62;
    for (var round = 0; round < 3; round++) {
      var log = ConnectionLog(connections.length).open(connections);
      final rows = ConnectionRows()..follow(log);
      log = log.closeAll(_t0);
      final watch = Stopwatch()..start();
      rows.update(log);
      update = min(update, watch.elapsedMicroseconds);
      watch.reset();
      rows.showWhere(null);
      replace = min(replace, watch.elapsedMicroseconds);
      expect(rows.countOf(ConnectionStatus.active), 0);
      rows.dispose();
    }
    expect(update, lessThan(4 * replace));
  });
}
