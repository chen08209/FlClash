import 'dart:collection';

import 'package:collection/collection.dart';

import 'common.dart';

/// A connection is announced before the Core stores it, so one missing from a
/// snapshot this soon after it opened may still be opening.
const _openingGrace = Duration(seconds: 1);

class _Entries {
  final byId = <String, TrackerInfo>{};
  final closedOrder = Queue<String>();

  /// Never before the latest start held.
  DateTime? latestStart;

  /// A snapshot asked for before this may list what was cleared.
  DateTime? clearedAt;

  final trimmed = <String>{};
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
    final placed = byId.length;
    var changed = false;
    var late = false;
    for (final trackerInfo in trackerInfos) {
      if (byId.containsKey(trackerInfo.id)) {
        continue;
      }
      late = _appendWasLate(trackerInfo) || late;
      changed = true;
    }
    if (late) {
      _placeLate(placed);
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

  ConnectionLog clearClosed() {
    final closedOrder = _entries.closedOrder;
    if (closedOrder.isEmpty) {
      return this;
    }
    final byId = _entries.byId;
    for (final id in closedOrder) {
      byId.remove(id);
    }
    closedOrder.clear();
    _entries.clearedAt = DateTime.now();
    _forgetLatestIfEmpty();
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
    final placed = byId.length;
    final clearedAt = _entries.clearedAt;
    final stale = clearedAt != null && requestedAt.isBefore(clearedAt);
    final trimmed = _entries.trimmed;
    final listed = <String>{};
    var changed = false;
    var late = false;
    for (final trackerInfo in open) {
      listed.add(trackerInfo.id);
      final known = byId[trackerInfo.id];
      if (known == null) {
        if (stale || trimmed.contains(trackerInfo.id)) {
          continue;
        }
        late = _appendWasLate(trackerInfo) || late;
        changed = true;
      } else if (known.isActive) {
        final next = _keepingSpeed(trackerInfo, known);
        if (next != known) {
          byId[trackerInfo.id] = next;
          changed = true;
        }
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
    if (late) {
      _placeLate(placed);
    }
    _trim();
    return _next();
  }

  /// An unranked snapshot has no speeds; it keeps the last ranked ones.
  static TrackerInfo _keepingSpeed(TrackerInfo next, TrackerInfo known) {
    if (next.uploadSpeed != null || next.downloadSpeed != null) {
      return next;
    }
    return next.copyWith(
      uploadSpeed: known.uploadSpeed,
      downloadSpeed: known.downloadSpeed,
    );
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
    if (closedOrder.length <= closedCapacity) {
      return;
    }
    final trimmed = _entries.trimmed;
    while (closedOrder.length > closedCapacity) {
      final id = closedOrder.removeFirst();
      _entries.byId.remove(id);
      trimmed.add(id);
      if (trimmed.length > closedCapacity) {
        trimmed.remove(trimmed.first);
      }
    }
    _forgetLatestIfEmpty();
  }

  void _forgetLatestIfEmpty() {
    if (_entries.byId.isEmpty) {
      _entries.latestStart = null;
    }
  }

  bool _appendWasLate(TrackerInfo trackerInfo) {
    _entries.byId[trackerInfo.id] = trackerInfo;
    final latest = _entries.latestStart;
    if (latest != null && trackerInfo.start.isBefore(latest)) {
      return true;
    }
    _entries.latestStart = trackerInfo.start;
    return false;
  }

  void _placeLate(int placed) {
    final byId = _entries.byId;
    final all = byId.values.toList(growable: false);
    int byStart(TrackerInfo a, TrackerInfo b) => a.start.compareTo(b.start);
    final appended = all.sublist(placed);
    mergeSort(appended, compare: byStart);
    final earliest = appended.first.start;
    var from = placed;
    while (from > 0 && all[from - 1].start.isAfter(earliest)) {
      from--;
    }
    final moved = [...all.sublist(from, placed), ...appended];
    mergeSort(moved, compare: byStart);
    for (final trackerInfo in all.skip(from)) {
      byId.remove(trackerInfo.id);
    }
    for (final trackerInfo in moved) {
      byId[trackerInfo.id] = trackerInfo;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is ConnectionLog &&
      identical(other._entries, _entries) &&
      other.revision == revision;

  @override
  int get hashCode => Object.hash(identityHashCode(_entries), revision);
}
