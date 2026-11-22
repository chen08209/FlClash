import 'dart:collection';
import 'dart:math';

import 'package:fl_clash/enum/enum.dart';
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

/// Counts how often a lookup reads it.
class _ReadQueries extends ListBase<int> {
  final List<int> _queries;
  var reads = 0;

  _ReadQueries(this._queries);

  @override
  int get length {
    reads++;
    return _queries.length;
  }

  @override
  set length(int length) => throw UnsupportedError('fixed');

  @override
  int operator [](int index) => _queries[index];

  @override
  void operator []=(int index, int value) => throw UnsupportedError('fixed');
}

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

  test('a snapshot keeps the connections it repeats and takes those whose '
      'traffic or anything else moved', () {
    final requestedAt = _t0.add(const Duration(minutes: 1));
    final log = ConnectionLog(10).sync([
      _connection('a', downloadSpeed: 10),
      _connection('b', downloadSpeed: 10),
      _connection('c', downloadSpeed: 10),
    ], requestedAt);
    final kept = log['a'];

    final next = log.sync([
      _connection('a', downloadSpeed: 10),
      _connection('b', downloadSpeed: 20),
      _connection('c', downloadSpeed: 10).copyWith(chains: const ['Tokyo']),
    ], requestedAt);

    expect(next.revision, log.revision + 1);
    expect(next['a'], same(kept));
    expect(next['b']!.downloadSpeed, 20);
    expect(next['c']!.chains, ['Tokyo']);
    expect(
      next.sync([
        _connection('a', downloadSpeed: 10),
        _connection('b', downloadSpeed: 20),
        _connection('c', downloadSpeed: 10).copyWith(chains: const ['Tokyo']),
      ], requestedAt).revision,
      next.revision,
    );
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

  test('a trimmed connection is kept as last held, up to the history\'s '
      'size', () {
    var log = ConnectionLog(1).open([
      _connection('a'),
      _connection('b', second: 1),
      _connection('c', second: 2),
    ]);
    log = log.updateTraffic({'a': (upload: 1, download: 2)});
    final closedAt = _t0.add(const Duration(seconds: 5));
    log = log.close(['a'], closedAt).close(['b'], _t0);

    expect(log['a'], isNull);
    final a = log.lastOf('a')!;
    expect((a.closedAt, a.upload, a.download), (closedAt, 1, 2));
    expect(log.lastOf('c'), log['c']);

    log = log.close(['c'], _t0);
    expect(log.lastOf('a'), isNull);
    expect(log.lastOf('b')?.isActive, isFalse);
  });

  test('a connection that arrives closed counts as history and makes way '
      'like any other', () {
    var log = ConnectionLog(2).open([
      _connection('open'),
      _connection('done', second: 1).copyWith(closedAt: _t0),
    ]);
    expect(log.activeCount, 1);

    log = log.open([
      for (var i = 0; i < 2; i++)
        _connection('$i', second: i + 2).copyWith(closedAt: _t0),
    ]);

    expect(_ids(log), ['open', '0', '1']);
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

  test('a snapshot without DNS queries keeps those the connection opened '
      'with', () {
    var log = ConnectionLog(10).open([
      _connection('a').copyWith(dnsQueries: const [7]),
    ]);

    log = log.sync([
      _connection('a', downloadSpeed: 40),
    ], _t0.add(const Duration(seconds: 2)));

    expect(log['a']!.dnsQueries, [7]);
    expect(log['a']!.downloadSpeed, 40);
  });

  test('an opening event that comes after a snapshot still brings its DNS '
      'queries, and the log ends as it would the other way round', () {
    final listedAt = _t0.add(const Duration(seconds: 2));
    final opened = _connection('a').copyWith(dnsQueries: const [7]);
    final snapshot = [
      _connection('a', downloadSpeed: 40).copyWith(download: 9),
    ];
    final eventFirst = ConnectionLog(
      10,
    ).open([opened]).sync(snapshot, listedAt);
    final listed = ConnectionLog(10).sync(snapshot, listedAt);

    final snapshotFirst = listed.open([opened]);

    expect(snapshotFirst['a'], eventFirst['a']);
    expect(snapshotFirst['a']!.dnsQueries, [7]);
    expect(snapshotFirst.changesSince(listed.revision), [
      (kind: ConnectionChangeKind.changed, id: 'a'),
    ]);
  });

  test('the connections a DNS query resolved for come newest first, and '
      'follow what opens and goes', () {
    var log = ConnectionLog(1).open([
      _connection('a', second: 1).copyWith(dnsQueries: const [7]),
      _connection('b', second: 2).copyWith(dnsQueries: const [8]),
      _connection('c', second: 3).copyWith(dnsQueries: const [7, 8]),
    ]);
    final resolved = log.resolvedBy(7);
    expect(resolved, ['c', 'a']);

    log = log.open([_connection('d', second: 4)]);
    expect(log.resolvedBy(7), same(resolved));
    log = log.close(['a'], _t0).close(['b'], _t0);
    expect(log.resolvedBy(7), ['c']);
    expect(log.resolvedBy(8), ['c', 'b']);
  });

  test('traffic alone does not send a DNS query\'s lookup through the '
      'connections again', () {
    final queries = [
      for (var index = 0; index < 50; index++) _ReadQueries([index]),
    ];
    var log = ConnectionLog(10).open([
      for (final (index, dnsQueries) in queries.indexed)
        _connection('c$index', second: index).copyWith(dnsQueries: dnsQueries),
    ]);
    final resolved = log.resolvedBy(49);
    int reads() => queries.fold(0, (sum, dnsQueries) => sum + dnsQueries.reads);
    final before = reads();

    for (var tick = 0; tick < 20; tick++) {
      log = log.updateTraffic({'c$tick': (upload: tick, download: tick)});
      expect(log.resolvedBy(49), same(resolved));
    }

    expect(reads(), before);
    log = log.open([_connection('n', second: 60)]);
    expect(log.resolvedBy(49), ['c49']);
    expect(reads(), greaterThan(before));
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

  test('the log tells what changed since a revision, apart from traffic', () {
    final log = ConnectionLog(
      1,
    ).open([_connection('a'), _connection('b', second: 1)]);

    final next = log
        .updateTraffic({'b': (upload: 1, download: 2)})
        .close(['a'], _t0)
        .open([_connection('c', second: 2)])
        .close(['b'], _t0);

    expect(next.changesSince(log.revision), [
      (kind: ConnectionChangeKind.closed, id: 'a'),
      (kind: ConnectionChangeKind.opened, id: 'c'),
      (kind: ConnectionChangeKind.closed, id: 'b'),
      (kind: ConnectionChangeKind.removed, id: 'a'),
    ]);
    expect(next.changesSince(next.revision), isEmpty);
    expect(log.changesSince(next.revision), isNull);
    expect(next['b']!.download, 2);
  });

  test('the failed connections are counted until they leave the history', () {
    const failure = ConnectionFailure(kind: ConnectionFailureKind.refused);
    var log = ConnectionLog(
      1,
    ).open([_connection('a').copyWith(closedAt: _t0, failure: failure)]);
    expect(log.failedCount, 1);

    log = log.open([_connection('b', second: 1).copyWith(closedAt: _t0)]);

    expect(_ids(log), ['b']);
    expect(log.failedCount, 0);
  });

  test('polls taken change by change leave the log a full snapshot would', () {
    final random = Random(11);
    for (var round = 0; round < 200; round++) {
      var synced = ConnectionLog(1 + random.nextInt(4));
      var polled = ConnectionLog(synced.closedCapacity);
      final core = <String, TrackerInfo>{};
      var samples = TrackerSamples.empty;
      var older = TrackerSamples.empty;
      var now = _t0;
      var next = 0;
      for (var step = 0; step < 40; step++) {
        now = now.add(Duration(milliseconds: 300 + random.nextInt(600)));
        (List<TrackerInfo>, ConnectionPoll) takePoll() {
          final listing = core.values.toList()..shuffle(random);
          final base = random.nextInt(5) == 0 ? older : samples;
          final poll = pollTrackerInfos(
            listing,
            base,
            now,
            generations: polled.slotGenerations,
          );
          return (listing, poll);
        }

        final inFlight = random.nextInt(4) == 0 ? takePoll() : null;
        final ids = core.keys.toList();
        switch (random.nextInt(6)) {
          case 0:
            for (var count = random.nextInt(4); count > 0; count--) {
              final opened = TrackerInfo(
                id: 'c${next++}',
                start: now.subtract(
                  Duration(milliseconds: random.nextInt(2000)),
                ),
                metadata: const Metadata(network: 'tcp', host: 'a.test'),
                chains: const ['Proxy'],
                rule: 'MATCH',
                rulePayload: '',
              );
              core[opened.id] = opened;
              if (random.nextBool()) {
                synced = synced.open([opened]);
                polled = polled.open([opened]);
              }
            }
          case 1 when ids.isNotEmpty:
            final id = ids[random.nextInt(ids.length)];
            final listedAfterClosing = random.nextInt(3) == 0;
            if (!listedAfterClosing) {
              core.remove(id);
            }
            if (listedAfterClosing || random.nextBool()) {
              synced = synced.close([id], now);
              polled = polled.close([id], now);
            }
          case 2 when ids.isNotEmpty:
            final id = ids[random.nextInt(ids.length)];
            core[id] = core[id]!.copyWith(chains: ['Proxy', 'hop $step']);
          case 3 when ids.isNotEmpty:
            final listing = core.values.toList()..shuffle(random);
            synced = synced.sync(listing, now);
            polled = polled.sync(listing, now);
          case _:
            for (final id in ids) {
              final info = core[id]!;
              core[id] = info.copyWith(
                upload: info.upload + random.nextInt(3) * 100,
                download: info.download + random.nextInt(3) * 1000,
              );
            }
        }
        final (listing, poll) = inFlight ?? takePoll();
        synced = synced.sync([
          for (final (index, info) in listing.indexed)
            info.copyWith(
              uploadSpeed: poll.samples.uploadSpeedAt(index),
              downloadSpeed: poll.samples.downloadSpeedAt(index),
            ),
        ], now);
        polled = polled.poll(poll, now);
        older = samples;
        samples = poll.samples;
        expect(
          _state(polled),
          _state(synced),
          reason: 'round $round step $step',
        );
      }
    }
  });
}

List<Object?> _state(ConnectionLog log) => [
  for (final info in log.list)
    (
      info.id,
      info.closedAt,
      info.upload,
      info.download,
      info.uploadSpeed,
      info.downloadSpeed,
      info.chains,
    ),
];
