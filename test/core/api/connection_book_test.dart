import 'package:fl_clash/core/api/connection_book.dart';
import 'package:fl_clash/core/api/core_api.dart';
import 'package:fl_clash/core/api/dto.dart';
import 'package:flutter_test/flutter_test.dart';

ConnectionInfo _info(int id, {int upload = 0, int download = 0}) =>
    ConnectionInfo.fromJson({
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
      expect(book.count, 0);
    },
  );

  test('counters update an open connection and a close removes it', () {
    final book = ConnectionBook()
      ..apply(ConnectionsReset(ConnectionSnapshot([_info(1), _info(2)])));
    book.apply(
      const ConnectionsChanged(
        ConnectionDelta(
          counters: [ConnectionCounter(id: 1, upload: 3, download: 4)],
          closed: [2],
        ),
      ),
    );
    expect(book.list().map((tracker) => tracker.id), [1]);
    expect(book.list().single.download, 4);
  });
}
