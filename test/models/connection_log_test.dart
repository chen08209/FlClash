import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

final _t0 = DateTime.utc(2026, 11, 21, 8);

TrackerInfo _connection(String id, {int second = 0, int? downloadSpeed}) {
  return TrackerInfo(
    id: id,
    start: _t0.add(Duration(seconds: second)),
    metadata: Metadata(network: 'tcp', host: '$id.example.com'),
    chains: const ['Proxy'],
    rule: 'MATCH',
    rulePayload: '',
    downloadSpeed: downloadSpeed,
  );
}

List<String> _ids(ConnectionLog log) => [for (final c in log.list) c.id];

void main() {
  test('a connection keeps its place when it closes', () {
    var log = ConnectionLog(10).open([
      _connection('a'),
      _connection('b', second: 1, downloadSpeed: 900),
      _connection('c', second: 2),
    ]);
    final closedAt = _t0.add(const Duration(minutes: 1));

    log = log.close(['b'], closedAt);

    expect(_ids(log), ['a', 'b', 'c']);
    final closed = log['b']!;
    expect(closed.isActive, isFalse);
    expect(closed.closedAt, closedAt);
    expect(closed.downloadSpeed, isNull);
    expect(log.activeCount, 2);
  });

  test('a change that changes nothing keeps the revision', () {
    final log = ConnectionLog(10).open([_connection('a')]);

    expect(log.open([_connection('a')]).revision, log.revision);
    expect(log.close(['gone'], _t0).revision, log.revision);
    expect(
      log.updateTraffic({'gone': (upload: 1, download: 1)}).revision,
      log.revision,
    );
    final closed = log.close(['a'], _t0);
    expect(closed.close(['a'], _t0).revision, closed.revision);
  });

  test('the history makes way for new closes, never the open connections', () {
    var log = ConnectionLog(2).open([
      _connection('long'),
      for (var i = 0; i < 4; i++) _connection('$i', second: i + 1),
    ]);

    log = log.close(['0', '1', '2'], _t0);
    expect(_ids(log), ['long', '1', '2', '3']);

    log = log.close(['3'], _t0);
    expect(_ids(log), ['long', '2', '3']);
    expect(log.activeCount, 1);
  });

  test('a long-lived connection closing into a full history stays, and the '
      'earliest closed record makes way for it', () {
    var log = ConnectionLog(2).open([
      _connection('long'),
      for (var i = 0; i < 2; i++) _connection('$i', second: i + 1),
    ]);
    log = log.close(['0', '1'], _t0);

    log = log.close(['long'], _t0.add(const Duration(seconds: 1)));

    expect(_ids(log), ['long', '1']);
    expect(log.activeCount, 0);
  });

  test('traffic reaches the connections it names, open or closed', () {
    var log = ConnectionLog(10).open([_connection('a'), _connection('b')]);
    log = log.close(['b'], _t0);

    log = log.updateTraffic({
      'a': (upload: 10, download: 20),
      'b': (upload: 3, download: 4),
    });

    expect(
      [for (final c in log.list) (c.id, c.upload, c.download, c.isActive)],
      [('a', 10, 20, true), ('b', 3, 4, false)],
    );
  });

  test('a snapshot adds what the log missed in the order they opened, '
      'refreshes the rest and closes those it no longer lists', () {
    var log = ConnectionLog(10).open([
      _connection('a', second: 10),
      _connection('b', second: 20),
      _connection('fresh', second: 60),
    ]);
    final at = _t0.add(const Duration(seconds: 60, milliseconds: 500));

    log = log.sync([
      _connection('early', second: 5),
      _connection('b', second: 20, downloadSpeed: 300),
    ], at);

    expect(_ids(log), ['early', 'a', 'b', 'fresh']);
    expect(log['a']!.closedAt, at, reason: 'missing from the snapshot');
    expect(log['b']!.downloadSpeed, 300);
    expect(
      log['fresh']!.isActive,
      isTrue,
      reason: 'it may be announced before the Core stores it',
    );
  });

  test('a snapshot does not reopen a closed connection', () {
    var log = ConnectionLog(10).open([_connection('a')]);
    log = log.close(['a'], _t0);

    log = log.sync([_connection('a', downloadSpeed: 5)], _t0);

    expect(log['a']!.isActive, isFalse);
  });

  test('closeAll closes every open connection at once', () {
    var log = ConnectionLog(10).open([_connection('a'), _connection('b')]);

    log = log.closeAll(_t0);

    expect(log.activeCount, 0);
    expect(log.list.every((c) => c.closedAt == _t0), isTrue);
  });

  test('clearing the history keeps the open connections in their order', () {
    var log = ConnectionLog(10).open([
      _connection('a'),
      _connection('b', second: 1),
      _connection('c', second: 2),
    ]);
    log = log.close(['b'], _t0);

    final cleared = log.clearClosed();

    expect(_ids(cleared), ['a', 'c']);
    expect(cleared.revision, log.revision + 1);
    expect(identical(cleared.clearClosed(), cleared), isTrue);
    expect(_ids(cleared.close(['a'], _t0)), ['a', 'c']);
  });

  test('a first snapshot in another order is kept in the order they '
      'opened', () {
    final log = ConnectionLog(10).sync([
      _connection('b', second: 2),
      _connection('a'),
      _connection('c', second: 3),
    ], _t0);

    expect(_ids(log), ['a', 'b', 'c']);
  });

  test('a connection that reports late takes the place it opened in', () {
    var log = ConnectionLog(10).open([
      _connection('a'),
      _connection('b', second: 10),
      _connection('c', second: 20),
    ]);

    log = log.open([
      _connection('late', second: 5),
      _connection('d', second: 30),
    ]);
    expect(_ids(log), ['a', 'late', 'b', 'c', 'd']);

    log = log.sync([
      for (final id in ['a', 'late', 'b', 'c', 'd']) log[id]!,
      _connection('also late', second: 15),
    ], _t0);
    expect(_ids(log), ['a', 'late', 'b', 'also late', 'c', 'd']);

    log = log.open([_connection('same second', second: 30)]);
    expect(_ids(log).last, 'same second');
  });

  test('a snapshot asked for before the history was cleared puts nothing '
      'back', () {
    final requestedAt = DateTime.now();
    var log = ConnectionLog(
      10,
    ).open([_connection('a'), _connection('b', second: 1)]).close(['a'], _t0);
    final stale = [_connection('a'), log['b']!, _connection('c', second: 2)];

    log = log.clearClosed();
    log = log.sync(stale, requestedAt);

    expect(_ids(log), ['b']);
    log = log.sync(stale, DateTime.now());
    expect(_ids(log), ['a', 'b', 'c']);
  });

  test('a snapshot asked for before the history trimmed leaves out what was '
      'trimmed and still adds what it found new', () {
    final requestedAt = DateTime.now();
    var log = ConnectionLog(
      1,
    ).open([_connection('a'), _connection('b', second: 1)]);
    final snapshot = [
      _connection('a'),
      _connection('b', second: 1),
      _connection('c', second: 2),
    ];

    log = log.close(['a'], _t0).close(['b'], _t0);
    expect(_ids(log), ['b']);

    log = log.sync(snapshot, requestedAt);

    expect(_ids(log), ['b', 'c']);
    expect(log['b']!.isActive, isFalse);
    expect(log['c']!.isActive, isTrue);
  });
}
