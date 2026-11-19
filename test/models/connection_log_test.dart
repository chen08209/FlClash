import 'dart:collection';
import 'dart:math';

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

final _t0 = DateTime.utc(2026, 11, 21, 8);

TrackerInfo _connection(int id, {int second = 0, int? downloadSpeed}) {
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

List<int> _ids(ConnectionLog log) => [for (final c in log.list) c.id];

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
      _connection(1),
      _connection(2, second: 1, downloadSpeed: 900),
      _connection(3, second: 2),
    ]);
    final closedAt = _t0.add(const Duration(minutes: 1));

    log = log.close([2], closedAt);

    expect(_ids(log), [1, 2, 3]);
    final closed = log[2]!;
    expect(closed.isActive, isFalse);
    expect(closed.closedAt, closedAt);
    expect(closed.downloadSpeed, isNull);
    expect(log.activeCount, 2);
  });

  test('a change that changes nothing keeps the revision', () {
    final log = ConnectionLog(10).open([_connection(1)]);

    expect(log.open([_connection(1)]).revision, log.revision);
    expect(log.close([99], _t0).revision, log.revision);
    expect(
      log.updateTraffic({99: (upload: 1, download: 1)}).revision,
      log.revision,
    );
    final closed = log.close([1], _t0);
    expect(closed.close([1], _t0).revision, closed.revision);
  });

  test('a snapshot keeps the connections it repeats and takes those whose '
      'traffic or anything else moved', () {
    final requestedAt = _t0.add(const Duration(minutes: 1));
    final log = ConnectionLog(10).sync([
      _connection(1, downloadSpeed: 10),
      _connection(2, downloadSpeed: 10),
      _connection(3, downloadSpeed: 10),
    ], requestedAt);
    final kept = log[1];

    final next = log.sync([
      _connection(1, downloadSpeed: 10),
      _connection(2, downloadSpeed: 20),
      _connection(3, downloadSpeed: 10).copyWith(chains: const ['Tokyo']),
    ], requestedAt);

    expect(next.revision, log.revision + 1);
    expect(next[1], same(kept));
    expect(next[2]!.downloadSpeed, 20);
    expect(next[3]!.chains, ['Tokyo']);
    expect(
      next.sync([
        _connection(1, downloadSpeed: 10),
        _connection(2, downloadSpeed: 20),
        _connection(3, downloadSpeed: 10).copyWith(chains: const ['Tokyo']),
      ], requestedAt).revision,
      next.revision,
    );
  });

  test('the history makes way for new closes, never the open connections', () {
    var log = ConnectionLog(2).open([
      _connection(100),
      for (var i = 0; i < 4; i++) _connection(i, second: i + 1),
    ]);

    log = log.close([0, 1, 2], _t0);
    expect(_ids(log), [100, 1, 2, 3]);

    log = log.close([3], _t0);
    expect(_ids(log), [100, 2, 3]);
    expect(log.activeCount, 1);
  });

  test('a trimmed connection is kept as last held, up to the history\'s '
      'size', () {
    var log = ConnectionLog(1).open([
      _connection(1),
      _connection(2, second: 1),
      _connection(3, second: 2),
    ]);
    log = log.updateTraffic({1: (upload: 1, download: 2)});
    final closedAt = _t0.add(const Duration(seconds: 5));
    log = log.close([1], closedAt).close([2], _t0);

    expect(log[1], isNull);
    final a = log.lastOf(1)!;
    expect((a.closedAt, a.upload, a.download), (closedAt, 1, 2));
    expect(log.lastOf(3), log[3]);

    log = log.close([3], _t0);
    expect(log.lastOf(1), isNull);
    expect(log.lastOf(2)?.isActive, isFalse);
  });

  test('a connection that arrives closed counts as history and makes way '
      'like any other', () {
    var log = ConnectionLog(2).open([
      _connection(10),
      _connection(11, second: 1).copyWith(closedAt: _t0),
    ]);
    expect(log.activeCount, 1);

    log = log.open([
      for (var i = 0; i < 2; i++)
        _connection(i, second: i + 2).copyWith(closedAt: _t0),
    ]);

    expect(_ids(log), [10, 0, 1]);
    expect(log.activeCount, 1);
  });

  test('a long-lived connection closing into a full history stays, and the '
      'earliest closed record makes way for it', () {
    var log = ConnectionLog(2).open([
      _connection(100),
      for (var i = 0; i < 2; i++) _connection(i, second: i + 1),
    ]);
    log = log.close([0, 1], _t0);

    log = log.close([100], _t0.add(const Duration(seconds: 1)));

    expect(_ids(log), [100, 1]);
    expect(log.activeCount, 0);
  });

  test('traffic reaches the connections it names, open or closed', () {
    var log = ConnectionLog(10).open([_connection(1), _connection(2)]);
    log = log.close([2], _t0);

    log = log.updateTraffic({
      1: (upload: 10, download: 20),
      2: (upload: 3, download: 4),
    });

    expect(
      [for (final c in log.list) (c.id, c.upload, c.download, c.isActive)],
      [(1, 10, 20, true), (2, 3, 4, false)],
    );
  });

  test('a snapshot adds what the log missed in the order they opened, '
      'refreshes the rest and closes those it no longer lists', () {
    var log = ConnectionLog(10).open([
      _connection(1, second: 10),
      _connection(2, second: 20),
      _connection(60, second: 60),
    ]);
    final at = _t0.add(const Duration(seconds: 60, milliseconds: 500));

    log = log.sync([
      _connection(5, second: 5),
      _connection(2, second: 20, downloadSpeed: 300),
    ], at);

    expect(_ids(log), [5, 1, 2, 60]);
    expect(log[1]!.closedAt, at, reason: 'missing from the snapshot');
    expect(log[2]!.downloadSpeed, 300);
    expect(
      log[60]!.isActive,
      isTrue,
      reason: 'it may be announced before the Core stores it',
    );
  });

  test('a snapshot without DNS queries keeps those the connection opened '
      'with', () {
    var log = ConnectionLog(10).open([
      _connection(1).copyWith(dnsQueries: const [7]),
    ]);

    log = log.sync([
      _connection(1, downloadSpeed: 40),
    ], _t0.add(const Duration(seconds: 2)));

    expect(log[1]!.dnsQueries, [7]);
    expect(log[1]!.downloadSpeed, 40);
  });

  test('an opening event that comes after a snapshot still brings its DNS '
      'queries, and the log ends as it would the other way round', () {
    final listedAt = _t0.add(const Duration(seconds: 2));
    final opened = _connection(1).copyWith(dnsQueries: const [7]);
    final snapshot = [_connection(1, downloadSpeed: 40).copyWith(download: 9)];
    final eventFirst = ConnectionLog(
      10,
    ).open([opened]).sync(snapshot, listedAt);
    final listed = ConnectionLog(10).sync(snapshot, listedAt);

    final snapshotFirst = listed.open([opened]);

    expect(snapshotFirst[1], eventFirst[1]);
    expect(snapshotFirst[1]!.dnsQueries, [7]);
    expect(snapshotFirst.changesSince(listed.revision), [
      (kind: ConnectionChangeKind.changed, id: 1),
    ]);
  });

  test('the connections a DNS query resolved for come newest first, and '
      'follow what opens and goes', () {
    var log = ConnectionLog(1).open([
      _connection(1, second: 1).copyWith(dnsQueries: const [7]),
      _connection(2, second: 2).copyWith(dnsQueries: const [8]),
      _connection(3, second: 3).copyWith(dnsQueries: const [7, 8]),
    ]);
    final resolved = log.resolvedBy(7);
    expect(resolved, [3, 1]);

    log = log.open([_connection(4, second: 4)]);
    expect(log.resolvedBy(7), same(resolved));
    log = log.close([1], _t0).close([2], _t0);
    expect(log.resolvedBy(7), [3]);
    expect(log.resolvedBy(8), [3, 2]);
  });

  test('traffic alone does not send a DNS query\'s lookup through the '
      'connections again', () {
    final queries = [
      for (var index = 0; index < 50; index++) _ReadQueries([index]),
    ];
    var log = ConnectionLog(10).open([
      for (final (index, dnsQueries) in queries.indexed)
        _connection(index, second: index).copyWith(dnsQueries: dnsQueries),
    ]);
    final resolved = log.resolvedBy(49);
    int reads() => queries.fold(0, (sum, dnsQueries) => sum + dnsQueries.reads);
    final before = reads();

    for (var tick = 0; tick < 20; tick++) {
      log = log.updateTraffic({tick: (upload: tick, download: tick)});
      expect(log.resolvedBy(49), same(resolved));
    }

    expect(reads(), before);
    log = log.open([_connection(100, second: 60)]);
    expect(log.resolvedBy(49), [49]);
    expect(reads(), greaterThan(before));
  });

  test('a snapshot does not reopen a closed connection', () {
    var log = ConnectionLog(10).open([_connection(1)]);
    log = log.close([1], _t0);

    log = log.sync([_connection(1, downloadSpeed: 5)], _t0);

    expect(log[1]!.isActive, isFalse);
  });

  test('closeAll closes every open connection at once', () {
    var log = ConnectionLog(10).open([_connection(1), _connection(2)]);

    log = log.closeAll(_t0);

    expect(log.activeCount, 0);
    expect(log.list.every((c) => c.closedAt == _t0), isTrue);
  });

  test('a first snapshot in another order is kept in the order they '
      'opened', () {
    final log = ConnectionLog(10).sync([
      _connection(2, second: 2),
      _connection(1),
      _connection(3, second: 3),
    ], _t0);

    expect(_ids(log), [1, 2, 3]);
  });

  test('a connection that reports late takes the place it opened in', () {
    var log = ConnectionLog(10).open([
      _connection(1),
      _connection(2, second: 10),
      _connection(3, second: 20),
    ]);

    log = log.open([_connection(5, second: 5), _connection(4, second: 30)]);
    expect(_ids(log), [1, 5, 2, 3, 4]);

    log = log.sync([
      for (final id in [1, 5, 2, 3, 4]) log[id]!,
      _connection(6, second: 15),
    ], _t0);
    expect(_ids(log), [1, 5, 2, 6, 3, 4]);

    log = log.open([_connection(7, second: 30)]);
    expect(_ids(log).last, 7);
  });

  test('a snapshot asked for before the history trimmed leaves out what was '
      'trimmed and still adds what it found new', () {
    final requestedAt = DateTime.now();
    var log = ConnectionLog(
      1,
    ).open([_connection(1), _connection(2, second: 1)]);
    final snapshot = [
      _connection(1),
      _connection(2, second: 1),
      _connection(3, second: 2),
    ];

    log = log.close([1], _t0).close([2], _t0);
    expect(_ids(log), [2]);

    log = log.sync(snapshot, requestedAt);

    expect(_ids(log), [2, 3]);
    expect(log[2]!.isActive, isFalse);
    expect(log[3]!.isActive, isTrue);
  });

  test('the log tells what changed since a revision, apart from traffic', () {
    final log = ConnectionLog(
      1,
    ).open([_connection(1), _connection(2, second: 1)]);

    final next = log
        .updateTraffic({2: (upload: 1, download: 2)})
        .close([1], _t0)
        .open([_connection(3, second: 2)])
        .close([2], _t0);

    expect(next.changesSince(log.revision), [
      (kind: ConnectionChangeKind.closed, id: 1),
      (kind: ConnectionChangeKind.opened, id: 3),
      (kind: ConnectionChangeKind.closed, id: 2),
      (kind: ConnectionChangeKind.removed, id: 1),
    ]);
    expect(next.changesSince(next.revision), isEmpty);
    expect(log.changesSince(next.revision), isNull);
    expect(next[2]!.download, 2);
  });

  test('the failed connections are counted until they leave the history', () {
    const failure = ConnectionFailure(kind: ConnectionFailureKind.refused);
    var log = ConnectionLog(
      1,
    ).open([_connection(1).copyWith(closedAt: _t0, failure: failure)]);
    expect(log.failedCount, 1);

    log = log.open([_connection(2, second: 1).copyWith(closedAt: _t0)]);

    expect(_ids(log), [2]);
    expect(log.failedCount, 0);
  });

  test('polls taken change by change leave the log a full snapshot would', () {
    final random = Random(11);
    for (var round = 0; round < 200; round++) {
      var synced = ConnectionLog(1 + random.nextInt(4));
      var polled = ConnectionLog(synced.closedCapacity);
      final core = <int, TrackerInfo>{};
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
                id: next++,
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
