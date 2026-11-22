import 'dart:collection';

import 'package:collection/collection.dart';

import 'common.dart';

/// A connection is announced before the Core stores it, so one missing from a
/// snapshot this soon after it opened may still be opening.
const _openingGrace = Duration(seconds: 1);

class _Entries {
  final byId = <String, TrackerInfo>{};
  final closedOrder = Queue<String>();
}

/// The connections of this run in the order they opened: every open one, and
/// the last [closedCapacity] that closed. A connection keeps its place when it
/// closes, and the open ones never make way for the history.
class ConnectionLog {
  final int closedCapacity;
  final _Entries _entries;
  final int revision;
  List<TrackerInfo>? _list;

  ConnectionLog(this.closedCapacity)
    : assert(closedCapacity > 0, 'a log without a cap grows without bound'),
      _entries = _Entries(),
      revision = 0;

  ConnectionLog._(this.closedCapacity, this._entries, this.revision);

  List<TrackerInfo> get list =>
      _list ??= List.unmodifiable(_entries.byId.values);

  int get length => _entries.byId.length;

  int get activeCount => _entries.byId.length - _entries.closedOrder.length;

  TrackerInfo? operator [](String id) => _entries.byId[id];

  ConnectionLog _next() =>
      ConnectionLog._(closedCapacity, _entries, revision + 1);

  ConnectionLog open(Iterable<TrackerInfo> trackerInfos) {
    final byId = _entries.byId;
    var changed = false;
    for (final trackerInfo in trackerInfos) {
      if (byId.containsKey(trackerInfo.id)) {
        continue;
      }
      byId[trackerInfo.id] = trackerInfo;
      changed = true;
    }
    return changed ? _next() : this;
  }

  ConnectionLog updateTraffic(Map<String, RequestTraffic> traffic) {
    final byId = _entries.byId;
    var changed = false;
    traffic.forEach((id, traffic) {
      final trackerInfo = byId[id];
      if (trackerInfo == null ||
          trackerInfo.upload == traffic.upload &&
              trackerInfo.download == traffic.download) {
        return;
      }
      byId[id] = trackerInfo.copyWith(
        upload: traffic.upload,
        download: traffic.download,
      );
      changed = true;
    });
    return changed ? _next() : this;
  }

  ConnectionLog close(Iterable<String> ids, DateTime at) {
    var changed = false;
    for (final id in ids) {
      changed = _close(id, at) || changed;
    }
    if (!changed) {
      return this;
    }
    _trim();
    return _next();
  }

  ConnectionLog closeAll(DateTime at) => close([
    for (final trackerInfo in _entries.byId.values)
      if (trackerInfo.isActive) trackerInfo.id,
  ], at);

  /// [requestedAt] is when [open] was asked for: a connection opened after
  /// it is missing from the snapshot however late the answer comes.
  ConnectionLog sync(List<TrackerInfo> open, DateTime requestedAt) {
    final byId = _entries.byId;
    final listed = <String>{};
    var changed = false;
    var outOfOrder = false;
    final latestStart = byId.isEmpty ? null : byId.values.last.start;
    for (final trackerInfo in open) {
      listed.add(trackerInfo.id);
      final known = byId[trackerInfo.id];
      if (known == null) {
        outOfOrder =
            outOfOrder ||
            latestStart != null && trackerInfo.start.isBefore(latestStart);
        byId[trackerInfo.id] = trackerInfo;
        changed = true;
      } else if (known.isActive && known != trackerInfo) {
        byId[trackerInfo.id] = trackerInfo;
        changed = true;
      }
    }
    final settled = requestedAt.subtract(_openingGrace);
    final gone = [
      for (final trackerInfo in byId.values)
        if (trackerInfo.isActive &&
            !listed.contains(trackerInfo.id) &&
            trackerInfo.start.isBefore(settled))
          trackerInfo.id,
    ];
    for (final id in gone) {
      changed = _close(id, requestedAt) || changed;
    }
    if (!changed) {
      return this;
    }
    if (outOfOrder) {
      _sortByStart();
    }
    _trim();
    return _next();
  }

  bool _close(String id, DateTime at) {
    final trackerInfo = _entries.byId[id];
    if (trackerInfo == null || !trackerInfo.isActive) {
      return false;
    }
    _entries.byId[id] = trackerInfo.copyWith(
      closedAt: at,
      uploadSpeed: null,
      downloadSpeed: null,
    );
    _entries.closedOrder.add(id);
    return true;
  }

  void _trim() {
    final closedOrder = _entries.closedOrder;
    while (closedOrder.length > closedCapacity) {
      _entries.byId.remove(closedOrder.removeFirst());
    }
  }

  void _sortByStart() {
    final byId = _entries.byId;
    final sorted = byId.values.toList();
    mergeSort(sorted, compare: (a, b) => a.start.compareTo(b.start));
    byId
      ..clear()
      ..addEntries(
        sorted.map((trackerInfo) => MapEntry(trackerInfo.id, trackerInfo)),
      );
  }

  @override
  bool operator ==(Object other) =>
      other is ConnectionLog &&
      identical(other._entries, _entries) &&
      other.revision == revision;

  @override
  int get hashCode => Object.hash(identityHashCode(_entries), revision);
}
