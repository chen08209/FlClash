import 'package:fl_clash/models/models.dart';
import 'package:flutter/foundation.dart';

import 'core_api.dart';
import 'dto.dart';
import 'mapping.dart';

typedef ConnectionChange = ({
  List<TrackerInfo> opened,
  Map<int, RequestTraffic> counters,
  List<int> closed,
  Map<int, ConnectionEnd> ended,
});

/// While no view shows per-connection traffic, the Core is not asked for counters.
class CounterDemand extends ChangeNotifier {
  int _holders = 0;

  bool get wanted => _holders > 0;

  void acquire() {
    if (_holders++ == 0) {
      notifyListeners();
    }
  }

  void release() {
    if (--_holders == 0) {
      notifyListeners();
    }
  }
}

class ConnectionBook {
  final _open = <int, TrackerInfo>{};

  final demand = CounterDemand();

  int get count => _open.length;

  void clear() => _open.clear();

  /// A snapshot replaces the set; only the connections new to the book are
  /// reported as opened, so a resync does not repeat the ones already seen,
  /// and the ones already seen report the totals they have reached since.
  ConnectionChange apply(ConnectionUpdate update) {
    switch (update) {
      case ConnectionsReset(:final snapshot):
        final previous = Map.of(_open);
        _open.clear();
        final opened = <TrackerInfo>[];
        final counters = <int, RequestTraffic>{};
        for (final info in snapshot.connections) {
          final known = previous[info.id];
          if (known != null) {
            if (known.upload == info.upload &&
                known.download == info.download) {
              _open[info.id] = known;
              continue;
            }
            _open[info.id] = known.copyWith(
              upload: info.upload,
              download: info.download,
            );
            counters[info.id] = (upload: info.upload, download: info.download);
            continue;
          }
          final tracker = trackerOf(info);
          _open[info.id] = tracker;
          opened.add(tracker);
        }
        final closed = [
          for (final id in previous.keys)
            if (!_open.containsKey(id)) id,
        ];
        return (
          opened: opened,
          counters: counters,
          closed: closed,
          ended: const <int, ConnectionEnd>{},
        );
      case ConnectionsChanged(:final delta):
        return _change(delta);
    }
  }

  ConnectionChange _change(ConnectionDelta delta) {
    final opened = <TrackerInfo>[];
    for (final info in delta.opened) {
      final tracker = trackerOf(info);
      _open[info.id] = tracker;
      opened.add(tracker);
    }
    final counters = <int, RequestTraffic>{};
    for (final counter in delta.counters) {
      counters[counter.id] = (
        upload: counter.upload,
        download: counter.download,
      );
      final tracker = _open[counter.id];
      if (tracker != null) {
        _open[counter.id] = tracker.copyWith(
          upload: counter.upload,
          download: counter.download,
        );
      }
    }
    for (final id in delta.closed) {
      _open.remove(id);
    }
    return (
      opened: opened,
      counters: counters,
      closed: delta.closed,
      ended: {for (final end in delta.ended) end.id: connectionEndOf(end)},
    );
  }

  /// Totals the counting watch reports for connections this book has open.
  Map<int, RequestTraffic> countersOf(ConnectionUpdate update) {
    final counters = <int, RequestTraffic>{};
    void take(int id, int upload, int download) {
      final known = _open[id];
      if (known == null ||
          known.upload == upload && known.download == download) {
        return;
      }
      _open[id] = known.copyWith(upload: upload, download: download);
      counters[id] = (upload: upload, download: download);
    }

    switch (update) {
      case ConnectionsReset(:final snapshot):
        for (final info in snapshot.connections) {
          take(info.id, info.upload, info.download);
        }
      case ConnectionsChanged(:final delta):
        for (final counter in delta.counters) {
          take(counter.id, counter.upload, counter.download);
        }
    }
    return counters;
  }

  List<TrackerInfo> list() => _open.values.toList(growable: false);
}
