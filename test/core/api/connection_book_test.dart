import 'package:fl_clash/core/api/connection_book.dart';
import 'package:fl_clash/core/api/core_api.dart';
import 'package:fl_clash/core/api/dto.dart';
import 'package:flutter_test/flutter_test.dart';

ConnectionInfo _info(
  int id, {
  int upload = 0,
  int download = 0,
  Map<String, Object?> more = const {},
}) => ConnectionInfo.fromJson({
  'id': id,
  'start': 1000 + id,
  'network': 'tcp',
  'sourceIp': '10.0.0.1',
  'sourcePort': 5000 + id,
  'destinationPort': 443,
  'host': 'a$id.test',
  'inboundType': 'mixed',
  'chains': ['DIRECT'],
  'providerChains': <String>[],
  'rule': 'Match',
  'rulePayload': '',
  'upload': upload,
  'download': download,
  ...more,
});

void main() {
  test('a snapshot opens every connection and a resync repeats none', () {
    final book = ConnectionBook();
    final first = book.apply(
      ConnectionsReset(ConnectionSnapshot([_info(1), _info(2)])),
    );
    expect(first.opened.map((tracker) => tracker.id), [1, 2]);
    final again = book.apply(
      ConnectionsReset(ConnectionSnapshot([_info(2, upload: 5), _info(3)])),
    );
    expect(again.opened.map((tracker) => tracker.id), [3]);
    expect(book.list().map((tracker) => tracker.id), [2, 3]);
    expect(book.list().first.upload, 5);
    expect(again.counters, {2: (upload: 5, download: 0)});
    expect(again.closed, [1]);
  });

  test('a resync keeps each connection whose totals have not moved', () {
    final book = ConnectionBook();
    book.apply(ConnectionsReset(ConnectionSnapshot([_info(1), _info(2)])));
    final before = book.list();

    book.apply(
      ConnectionsReset(ConnectionSnapshot([_info(1), _info(2, upload: 5)])),
    );

    expect(book.list().first, same(before.first));
    expect(book.list().last, isNot(same(before.last)));
  });

  test(
    'a connection opened and closed in one batch still reaches the history',
    () {
      final book = ConnectionBook();
      final change = book.apply(
        ConnectionsChanged(
          ConnectionDelta(
            opened: [_info(7)],
            closed: const [7],
            counters: const [
              ConnectionCounter(id: 7, upload: 10, download: 20),
            ],
          ),
        ),
      );
      expect(change.opened.map((tracker) => tracker.id), [7]);
      expect(change.counters[7], (upload: 10, download: 20));
      expect(change.closed, [7]);
      expect(book.count, 0);
    },
  );

  test('counters update an open connection and a close removes it and '
      'reports it', () {
    final book = ConnectionBook()
      ..apply(ConnectionsReset(ConnectionSnapshot([_info(1), _info(2)])));
    final change = book.apply(
      const ConnectionsChanged(
        ConnectionDelta(
          counters: [ConnectionCounter(id: 1, upload: 3, download: 4)],
          closed: [2],
        ),
      ),
    );
    expect(change.closed, [2]);
    expect(book.list().map((tracker) => tracker.id), [1]);
    expect(book.list().single.download, 4);
  });

  test('an opened connection names the rule that decided it by position', () {
    final book = ConnectionBook();
    final change = book.apply(
      ConnectionsReset(
        ConnectionSnapshot([
          _info(1, more: {'ruleIndex': 4}),
          _info(2),
        ]),
      ),
    );
    expect(change.opened.map((tracker) => tracker.ruleIndex), [4, null]);
  });

  test('an opened connection carries when each step of setting it up '
      'happened', () {
    final book = ConnectionBook();
    final change = book.apply(
      ConnectionsChanged(
        ConnectionDelta(
          opened: [
            _info(
              1,
              more: {
                'timing': {
                  'accepted': 1000,
                  'dnsStart': 10,
                  'dnsEnd': 2010,
                  'routed': 2100,
                  'dialStart': 2200,
                  'connected': 9200,
                  'dialEnd': 15200,
                },
              },
            ),
            _info(2),
          ],
        ),
      ),
    );
    final timing = change.opened.first.timing!;
    expect(timing.accepted, DateTime.fromMillisecondsSinceEpoch(1000));
    expect(
      [timing.dnsStart, timing.dnsEnd, timing.routed, timing.dialStart],
      [10, 2010, 2100, 2200],
    );
    expect([timing.connected, timing.tls, timing.dialEnd], [9200, null, 15200]);
    expect(change.opened.last.timing, isNull);
  });
}
