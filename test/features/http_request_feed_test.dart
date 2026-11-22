import 'dart:async';

import 'package:fl_clash/features/features.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

MitmExchangeSummary _exchange(
  int id, {
  int status = 200,
  bool pending = false,
}) => MitmExchangeSummary(
  id: id,
  start: DateTime.utc(2026, 11, 22, 6, 0, id),
  method: 'GET',
  host: 'a.test',
  path: '/$id',
  status: status,
  pending: pending,
);

/// Answers as Concord does: newest first, [limit] at a time, and with
/// `since` only what changed after that version.
class _Core {
  final exchanges = <MitmExchangeSummary>[];
  final changedAt = <int, int>{};
  var version = 0;
  var oldest = 0;
  final calls = <({int? before, int? since, int limit})>[];

  void put(MitmExchangeSummary exchange) {
    version++;
    exchanges
      ..removeWhere((kept) => kept.id == exchange.id)
      ..add(exchange);
    changedAt[exchange.id] = version;
  }

  Future<MitmQueryPage> query({
    int? before,
    int? since,
    required int limit,
  }) async {
    calls.add((before: before, since: since, limit: limit));
    final matching = [
      for (final exchange in exchanges.reversed)
        if (exchange.id >= oldest &&
            (before == null || exchange.id < before) &&
            (since == null ||
                changedAt[exchange.id]! > since ||
                exchange.pending))
          exchange,
    ]..sort((a, b) => b.id - a.id);
    final page = matching.take(limit).toList();
    return MitmQueryPage(
      version: version,
      oldest: oldest,
      exchanges: page,
      next: matching.length > page.length ? page.last.id : null,
    );
  }
}

void main() {
  test('a following list the pointer rests on keeps new requests out until '
      'it leaves, and goes on updating the requests it shows', () async {
    final core = _Core()..put(_exchange(1, pending: true));
    final feed = HttpRequestFeed();
    addTearDown(feed.dispose);
    await feed.read(core.query);
    feed.hovered = true;

    core
      ..put(_exchange(1))
      ..put(_exchange(2));
    await feed.read(core.query);

    expect(feed.items, [_exchange(1)]);

    feed.hovered = false;

    expect(feed.items, [_exchange(1), _exchange(2)]);
  });

  test(
    'a held list hears nothing of requests that only wait to go in',
    () async {
      final core = _Core()..put(_exchange(1));
      final feed = HttpRequestFeed();
      addTearDown(feed.dispose);
      await feed.read(core.query);
      feed.hovered = true;
      var heard = 0;
      feed.addListener(() => heard++);

      core.put(_exchange(2));
      await feed.read(core.query);
      core.put(_exchange(2, status: 404));
      await feed.read(core.query);

      expect(heard, 0);
      feed.hovered = false;
      expect(feed.items, [_exchange(1), _exchange(2, status: 404)]);
      expect(heard, 1);
    },
  );

  test('the first read pages through every request, oldest first', () async {
    final core = _Core();
    for (var id = 1; id <= 150; id++) {
      core.put(_exchange(id));
    }
    final feed = HttpRequestFeed();
    addTearDown(feed.dispose);

    await feed.read(core.query);

    expect(feed.items.map((exchange) => exchange.id), [
      for (var id = 1; id <= 150; id++) id,
    ]);
    expect(core.calls, [
      (before: null, since: null, limit: mitmQueryPageLimit),
      (before: 87, since: null, limit: mitmQueryPageLimit),
      (before: 23, since: null, limit: mitmQueryPageLimit),
    ]);
  });

  test('a later read asks only for what changed since, and drops what the '
      'Core no longer keeps', () async {
    final core = _Core();
    core
      ..put(_exchange(1))
      ..put(_exchange(2, status: 0, pending: true))
      ..put(_exchange(3));
    final feed = HttpRequestFeed();
    addTearDown(feed.dispose);
    await feed.read(core.query);
    final first = core.version;

    core
      ..put(_exchange(2))
      ..put(_exchange(4))
      ..oldest = 2;
    await feed.read(core.query);

    expect(core.calls.last.since, first);
    expect(feed.items.map((exchange) => exchange.id), [2, 3, 4]);
    expect(feed.items.first.pending, isFalse);
  });

  test('a read that changes nothing keeps the list as it was', () async {
    final core = _Core()..put(_exchange(1));
    final feed = HttpRequestFeed();
    addTearDown(feed.dispose);
    await feed.read(core.query);
    final kept = feed.items;

    await feed.read(core.query);

    expect(identical(feed.items, kept), isTrue);
  });

  test('a Core that counts from the start again is read afresh', () async {
    final core = _Core();
    for (var id = 1; id <= 3; id++) {
      core.put(_exchange(id));
    }
    final feed = HttpRequestFeed();
    addTearDown(feed.dispose);
    await feed.read(core.query);

    final restarted = _Core()..put(_exchange(1, status: 404));
    await feed.read(restarted.query);

    expect(feed.items.single.status, 404);
    expect(restarted.calls.last.since, isNull);
  });

  test('a Core that counts from the start again with no request yet leaves '
      'the list empty', () async {
    final core = _Core();
    for (var id = 1; id <= 3; id++) {
      core.put(_exchange(id));
    }
    final feed = HttpRequestFeed();
    addTearDown(feed.dispose);
    await feed.read(core.query);

    await feed.read(_Core().query);

    expect(feed.items, isEmpty);
  });

  test('a restart found by a read that then fails still empties the list '
      'on the next read, and counts as a run', () async {
    final core = _Core();
    for (var id = 1; id <= 3; id++) {
      core.put(_exchange(id));
    }
    final feed = HttpRequestFeed();
    addTearDown(feed.dispose);
    await feed.read(core.query);
    expect(feed.runs, 0);

    final restarted = _Core();
    var calls = 0;
    Future<MitmQueryPage> failingOnce({
      int? before,
      int? since,
      required int limit,
    }) {
      if (++calls == 2) {
        throw StateError('Core went away');
      }
      return restarted.query(before: before, since: since, limit: limit);
    }

    await expectLater(feed.read(failingOnce), throwsStateError);
    expect(feed.runs, 1);
    await feed.read(restarted.query);

    expect(feed.items, isEmpty);
    expect(feed.runs, 1);
  });

  test('a reset empties the list and drops the page a read still waits '
      'on, and the next read starts from the first page', () async {
    final core = _Core();
    for (var id = 1; id <= 3; id++) {
      core.put(_exchange(id));
    }
    final feed = HttpRequestFeed();
    addTearDown(feed.dispose);
    await feed.read(core.query);
    final waiting = Completer<MitmQueryPage>();
    final reading = feed.read(
      ({before, since, required limit}) => waiting.future,
    );

    feed.reset();
    final restarted = _Core()..put(_exchange(1, status: 404));
    for (var id = 2; id <= 5; id++) {
      restarted.put(_exchange(id, status: 500));
    }
    waiting.complete(await core.query(limit: mitmQueryPageLimit));
    await reading;

    expect(feed.items, isEmpty);
    await feed.read(restarted.query);
    expect(restarted.calls.single.since, isNull);
    expect(feed.items.map((exchange) => exchange.status), [
      404,
      500,
      500,
      500,
      500,
    ]);
  });

  test('a feed disposed while a read waits asks for no further page', () async {
    final core = _Core();
    for (var id = 1; id <= 100; id++) {
      core.put(_exchange(id));
    }
    final feed = HttpRequestFeed();
    final waiting = Completer<void>();
    var calls = 0;
    final reading = feed.read(({before, since, required limit}) async {
      calls++;
      await waiting.future;
      return core.query(before: before, since: since, limit: limit);
    });

    feed.dispose();
    waiting.complete();
    await reading;

    expect(calls, 1);
  });

  test('a restarted Core\'s requests wait while the list holds new ones, '
      'whatever their ids', () async {
    final core = _Core();
    for (var id = 1; id <= 3; id++) {
      core.put(_exchange(id));
    }
    final feed = HttpRequestFeed();
    addTearDown(feed.dispose);
    await feed.read(core.query);
    feed.hovered = true;

    await feed.read((_Core()..put(_exchange(1, status: 404))).query);

    expect(feed.items, isEmpty);
    feed.hovered = false;
    expect(feed.items.single.status, 404);
  });

  test(
    'a search narrows the list by method, host, path, status or app',
    () async {
      final core = _Core()
        ..put(_exchange(1))
        ..put(
          _exchange(
            2,
            status: 404,
          ).copyWith(app: const MitmApp(process: 'Slack')),
        );
      final feed = HttpRequestFeed();
      addTearDown(feed.dispose);
      await feed.read(core.query);

      feed.search('slack');
      expect(feed.shown.single.id, 2);
      feed.search('404');
      expect(feed.shown.single.id, 2);
      feed.search('/1');
      expect(feed.shown.single.id, 1);
    },
  );
}
