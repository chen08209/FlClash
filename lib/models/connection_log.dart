import 'dart:collection';
import 'dart:typed_data';

import 'package:collection/collection.dart';

import 'common.dart';
import 'tracker_speed_sampler.dart';

/// A connection is announced before the Core stores it, so one missing from a
/// snapshot this soon after it opened may still be opening.
const _openingGrace = Duration(seconds: 1);

const _noSpeed = -1;

/// Changes past this many are dropped oldest first, and a reader that missed
/// them reads the whole log again.
const _changesKept = 8192;

enum ConnectionChangeKind { opened, changed, closed, removed }

typedef ConnectionChange = ({ConnectionChangeKind kind, int id});

class _Entry {
  /// Traffic as of the last write here; the log's arrays hold the latest.
  TrackerInfo info;
  final int slot;

  final int seq;

  _Entry(this.info, this.slot, this.seq);
}

class _Entries {
  final byId = <int, _Entry>{};
  final closedOrder = Queue<int>();

  /// Never before the latest start held.
  DateTime? latestStart;

  /// As each was last held, oldest first.
  final trimmed = <int, TrackerInfo>{};

  var upload = Int64List(0);
  var download = Int64List(0);
  var uploadSpeed = Int64List(0);
  var downloadSpeed = Int64List(0);
  var open = Uint8List(0);
  var generations = Int32List(0);
  var listedIn = Int32List(0);
  var polls = 0;
  final bySlot = <_Entry?>[];
  final freeSlots = <int>[];
  var slots = 0;
  var seq = 0;

  var failed = 0;

  final changes = Queue<(int, ConnectionChange)>();

  var changesFrom = 0;
  var changeCount = 0;
  ({int dnsQueryId, int changeCount, List<int> ids})? resolved;
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
      _list ??= List.unmodifiable(_entries.byId.values.map(_infoOf));

  int get length => _entries.byId.length;

  /// A poll's slots hold only within one lineage.
  Object get lineage => _entries;

  /// A slot freed and taken again holds another connection.
  Int32List get slotGenerations =>
      Int32List.sublistView(_entries.generations, 0, _entries.slots).sublist(0);

  int get activeCount => _entries.byId.length - _entries.closedOrder.length;

  int get failedCount => _entries.failed;

  TrackerInfo? operator [](int id) {
    final entry = _entries.byId[id];
    return entry == null ? null : _infoOf(entry);
  }

  /// [id] as held, or as last held if the log has since trimmed it.
  TrackerInfo? lastOf(int id) => this[id] ?? _entries.trimmed[id];

  /// When every connection the log no longer knows had closed by.
  DateTime? get forgottenBy => _entries.trimmed.values.firstOrNull?.closedAt;

  /// The connections DNS query [dnsQueryId] resolved for, newest first.
  List<int> resolvedBy(int dnsQueryId) {
    final entries = _entries;
    final last = entries.resolved;
    if (last != null &&
        last.dnsQueryId == dnsQueryId &&
        last.changeCount == entries.changeCount) {
      return last.ids;
    }
    final found = List<int>.unmodifiable(
      [
        for (final entry in entries.byId.values)
          if (entry.info.dnsQueries.contains(dnsQueryId)) entry.info.id,
      ].reversed,
    );
    final ids =
        last != null &&
            last.dnsQueryId == dnsQueryId &&
            const ListEquality<int>().equals(last.ids, found)
        ? last.ids
        : found;
    entries.resolved = (
      dnsQueryId: dnsQueryId,
      changeCount: entries.changeCount,
      ids: ids,
    );
    return ids;
  }

  /// Orders connections that opened at the same instant.
  int? seqOf(int id) => _entries.byId[id]?.seq;

  /// What changed after [revision] other than traffic, oldest first, or null
  /// when the changes no longer reach that far back.
  List<ConnectionChange>? changesSince(int revision) {
    if (revision < _entries.changesFrom || revision > this.revision) {
      return null;
    }
    return [
      for (final (at, change) in _entries.changes)
        if (at > revision && at <= this.revision) change,
    ];
  }

  TrackerInfo _infoOf(_Entry entry) {
    final entries = _entries;
    final slot = entry.slot;
    final info = entry.info;
    final upload = entries.upload[slot];
    final download = entries.download[slot];
    final uploadSpeed = entries.uploadSpeed[slot];
    final downloadSpeed = entries.downloadSpeed[slot];
    if (info.upload == upload &&
        info.download == download &&
        (info.uploadSpeed ?? _noSpeed) == uploadSpeed &&
        (info.downloadSpeed ?? _noSpeed) == downloadSpeed) {
      return info;
    }
    return entry.info = info.copyWith(
      upload: upload,
      download: download,
      uploadSpeed: uploadSpeed == _noSpeed ? null : uploadSpeed,
      downloadSpeed: downloadSpeed == _noSpeed ? null : downloadSpeed,
    );
  }

  ConnectionLog _next() =>
      ConnectionLog._(closedCapacity, _entries, revision + 1);

  void _record(ConnectionChangeKind kind, int id) {
    _entries.changeCount++;
    final changes = _entries.changes;
    changes.add((revision + 1, (kind: kind, id: id)));
    while (changes.length > _changesKept) {
      _entries.changesFrom = changes.removeFirst().$1;
    }
  }

  ConnectionLog open(Iterable<TrackerInfo> trackerInfos) {
    final byId = _entries.byId;
    final placed = byId.length;
    var changed = false;
    var late = false;
    for (final trackerInfo in trackerInfos) {
      if (byId[trackerInfo.id] case final entry?) {
        changed = _takeQueries(entry, trackerInfo.dnsQueries) || changed;
        continue;
      }
      late = _appendWasLate(trackerInfo) || late;
      changed = true;
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

  /// Only the opening event names a connection's DNS queries, and a snapshot
  /// can reach the log first.
  bool _takeQueries(_Entry entry, List<int> queries) {
    if (queries.isEmpty || entry.info.dnsQueries.isNotEmpty) {
      return false;
    }
    _replace(entry, _infoOf(entry).copyWith(dnsQueries: queries));
    _record(ConnectionChangeKind.changed, entry.info.id);
    return true;
  }

  ConnectionLog updateTraffic(Map<int, RequestTraffic> traffic) {
    final entries = _entries;
    var changed = false;
    traffic.forEach((id, traffic) {
      final slot = entries.byId[id]?.slot;
      if (slot == null ||
          entries.upload[slot] == traffic.upload &&
              entries.download[slot] == traffic.download) {
        return;
      }
      entries.upload[slot] = traffic.upload;
      entries.download[slot] = traffic.download;
      changed = true;
    });
    return changed ? _next() : this;
  }

  ConnectionLog close(
    Iterable<int> ids,
    DateTime at, {
    Map<int, ConnectionEnd> ends = const {},
  }) {
    var changed = false;
    for (final id in ids) {
      changed = _close(id, at, ends[id]) || changed;
    }
    if (!changed) {
      return this;
    }
    _trim();
    return _next();
  }

  ConnectionLog closeAll(DateTime at) => close([
    for (final entry in _entries.byId.values)
      if (entry.info.isActive) entry.info.id,
  ], at);

  /// [requestedAt] is when [open] was asked for: a connection opened after
  /// it is missing from the snapshot however late the answer comes.
  ConnectionLog sync(List<TrackerInfo> open, DateTime requestedAt) {
    final entries = _entries;
    final byId = entries.byId;
    final placed = byId.length;
    final trimmed = entries.trimmed;
    final listed = <int>{};
    var changed = false;
    var late = false;
    for (final trackerInfo in open) {
      listed.add(trackerInfo.id);
      final entry = byId[trackerInfo.id];
      if (entry == null) {
        if (trimmed.containsKey(trackerInfo.id)) {
          continue;
        }
        late = _appendWasLate(trackerInfo) || late;
        changed = true;
      } else if (entry.info.isActive) {
        changed = _takeSnapshot(entry, trackerInfo) || changed;
      }
    }
    final settled = requestedAt.subtract(_openingGrace);
    final gone = [
      for (final entry in byId.values)
        if (entry.info.isActive &&
            !listed.contains(entry.info.id) &&
            entry.info.start.isBefore(settled))
          entry.info.id,
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

  /// Like [sync], from what changed since the poll [poll] was taken after;
  /// the slots it learns are written back into its samples for the next.
  ConnectionLog poll(ConnectionPoll poll, DateTime requestedAt) {
    final entries = _entries;
    final byId = entries.byId;
    final placed = byId.length;
    final samples = poll.samples;
    var changed = false;
    var late = false;
    for (final (index, trackerInfo) in poll.fresh.indexed) {
      var entry = byId[trackerInfo.id];
      if (entry == null) {
        if (entries.trimmed.containsKey(trackerInfo.id)) {
          continue;
        }
        late = _appendWasLate(trackerInfo) || late;
        changed = true;
        entry = byId[trackerInfo.id]!;
      } else if (entry.info.isActive) {
        changed = _takeSnapshot(entry, trackerInfo) || changed;
      }
      final at = poll.freshAt[index];
      samples.slots[at] = entry.slot;
      samples.generations[at] = entries.generations[entry.slot];
    }
    final stamp = ++entries.polls;
    var listedOpen = 0;
    for (var index = 0; index < samples.length; index++) {
      final slot = samples.slots[index];
      if (slot >= 0 &&
          entries.generations[slot] == samples.generations[index] &&
          entries.open[slot] == 1 &&
          entries.listedIn[slot] != stamp) {
        entries.listedIn[slot] = stamp;
        listedOpen++;
        changed = _takeSample(slot, samples, index) || changed;
      }
    }
    if (listedOpen < activeCount) {
      final settled = requestedAt.subtract(_openingGrace);
      final gone = [
        for (var slot = 0; slot < entries.slots; slot++)
          if (entries.open[slot] == 1 && entries.listedIn[slot] != stamp)
            if (entries.bySlot[slot]! case final entry
                when entry.info.start.isBefore(settled))
              entry,
      ]..sort(_inLogOrder);
      for (final entry in gone) {
        changed = _close(entry.info.id, requestedAt) || changed;
      }
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

  static int _inLogOrder(_Entry a, _Entry b) {
    final byStart = a.info.start.compareTo(b.info.start);
    return byStart != 0 ? byStart : a.seq - b.seq;
  }

  bool _takeSample(int slot, TrackerSamples samples, int index) {
    final entries = _entries;
    final upload = samples.uploadAt(index);
    final download = samples.downloadAt(index);
    final uploadSpeed = samples.uploadSpeedAt(index);
    final downloadSpeed = samples.downloadSpeedAt(index);
    if (entries.upload[slot] == upload &&
        entries.download[slot] == download &&
        entries.uploadSpeed[slot] == uploadSpeed &&
        entries.downloadSpeed[slot] == downloadSpeed) {
      return false;
    }
    entries.upload[slot] = upload;
    entries.download[slot] = download;
    entries.uploadSpeed[slot] = uploadSpeed;
    entries.downloadSpeed[slot] = downloadSpeed;
    return true;
  }

  bool _takeSnapshot(_Entry entry, TrackerInfo snapshot) {
    final entries = _entries;
    final slot = entry.slot;
    final ranked =
        snapshot.uploadSpeed != null || snapshot.downloadSpeed != null;
    var moved = false;
    if (entries.upload[slot] != snapshot.upload ||
        entries.download[slot] != snapshot.download) {
      entries.upload[slot] = snapshot.upload;
      entries.download[slot] = snapshot.download;
      moved = true;
    }
    if (ranked) {
      final uploadSpeed = snapshot.uploadSpeed ?? _noSpeed;
      final downloadSpeed = snapshot.downloadSpeed ?? _noSpeed;
      if (entries.uploadSpeed[slot] != uploadSpeed ||
          entries.downloadSpeed[slot] != downloadSpeed) {
        entries.uploadSpeed[slot] = uploadSpeed;
        entries.downloadSpeed[slot] = downloadSpeed;
        moved = true;
      }
    }
    final known = _infoOf(entry);
    final next = _keepingKnown(snapshot, known);
    if (next == known) {
      return moved;
    }
    _replace(entry, next);
    _record(ConnectionChangeKind.changed, next.id);
    return true;
  }

  /// An unranked snapshot keeps the last speeds, and one without DNS queries,
  /// as a dev Core's always is, keeps those its opening event named.
  static TrackerInfo _keepingKnown(TrackerInfo next, TrackerInfo known) {
    final ranked = next.uploadSpeed != null || next.downloadSpeed != null;
    final keepsQueries = next.dnsQueries.isEmpty && known.dnsQueries.isNotEmpty;
    if (ranked && !keepsQueries) {
      return next;
    }
    return next.copyWith(
      uploadSpeed: ranked ? next.uploadSpeed : known.uploadSpeed,
      downloadSpeed: ranked ? next.downloadSpeed : known.downloadSpeed,
      dnsQueries: keepsQueries ? known.dnsQueries : next.dnsQueries,
    );
  }

  bool _close(int id, DateTime at, [ConnectionEnd? end]) {
    final entry = _entries.byId[id];
    if (entry == null || !entry.info.isActive) {
      return false;
    }
    final info = _infoOf(entry);
    _replace(
      entry,
      info.copyWith(
        closedAt: at,
        end: end ?? info.end,
        uploadSpeed: null,
        downloadSpeed: null,
      ),
    );
    _entries.closedOrder.add(id);
    _entries.open[entry.slot] = 0;
    _record(ConnectionChangeKind.closed, id);
    return true;
  }

  void _replace(_Entry entry, TrackerInfo info) {
    final entries = _entries;
    if ((entry.info.failure != null) != (info.failure != null)) {
      entries.failed += info.failure != null ? 1 : -1;
    }
    entry.info = info;
    _writeTraffic(entry.slot, info);
  }

  void _writeTraffic(int slot, TrackerInfo info) {
    final entries = _entries;
    entries.upload[slot] = info.upload;
    entries.download[slot] = info.download;
    entries.uploadSpeed[slot] = info.uploadSpeed ?? _noSpeed;
    entries.downloadSpeed[slot] = info.downloadSpeed ?? _noSpeed;
  }

  void _trim() {
    final entries = _entries;
    final closedOrder = entries.closedOrder;
    if (closedOrder.length <= closedCapacity) {
      return;
    }
    final trimmed = entries.trimmed;
    while (closedOrder.length > closedCapacity) {
      final id = closedOrder.removeFirst();
      final entry = entries.byId.remove(id)!;
      trimmed[id] = _infoOf(entry);
      if (trimmed.length > closedCapacity) {
        trimmed.remove(trimmed.keys.first);
      }
      if (entry.info.failure != null) {
        entries.failed--;
      }
      entries.freeSlots.add(entry.slot);
      entries.generations[entry.slot]++;
      entries.bySlot[entry.slot] = null;
      entries.open[entry.slot] = 0;
      _record(ConnectionChangeKind.removed, id);
    }
    _forgetLatestIfEmpty();
  }

  void _forgetLatestIfEmpty() {
    if (_entries.byId.isEmpty) {
      _entries.latestStart = null;
    }
  }

  int _takeSlot() {
    final entries = _entries;
    if (entries.freeSlots.isNotEmpty) {
      return entries.freeSlots.removeLast();
    }
    final slot = entries.slots++;
    if (slot == entries.upload.length) {
      final capacity = slot == 0 ? 64 : slot * 2;
      Int64List grown(Int64List from) => Int64List(capacity)..setAll(0, from);
      entries.upload = grown(entries.upload);
      entries.download = grown(entries.download);
      entries.uploadSpeed = grown(entries.uploadSpeed);
      entries.downloadSpeed = grown(entries.downloadSpeed);
      entries.open = Uint8List(capacity)..setAll(0, entries.open);
      entries.generations = Int32List(capacity)..setAll(0, entries.generations);
      entries.listedIn = Int32List(capacity)..setAll(0, entries.listedIn);
    }
    entries.bySlot.add(null);
    return slot;
  }

  bool _appendWasLate(TrackerInfo trackerInfo) {
    final entries = _entries;
    final entry = _Entry(trackerInfo, _takeSlot(), entries.seq++);
    entries.byId[trackerInfo.id] = entry;
    entries.bySlot[entry.slot] = entry;
    entries.open[entry.slot] = trackerInfo.isActive ? 1 : 0;
    _writeTraffic(entry.slot, trackerInfo);
    if (trackerInfo.failure != null) {
      entries.failed++;
    }
    if (!trackerInfo.isActive) {
      entries.closedOrder.add(trackerInfo.id);
    }
    _record(ConnectionChangeKind.opened, trackerInfo.id);
    final latest = entries.latestStart;
    if (latest != null && trackerInfo.start.isBefore(latest)) {
      return true;
    }
    entries.latestStart = trackerInfo.start;
    return false;
  }

  void _placeLate(int placed) {
    final byId = _entries.byId;
    final all = byId.values.toList(growable: false);
    int byStart(_Entry a, _Entry b) => a.info.start.compareTo(b.info.start);
    final appended = all.sublist(placed);
    mergeSort(appended, compare: byStart);
    final earliest = appended.first.info.start;
    var from = placed;
    while (from > 0 && all[from - 1].info.start.isAfter(earliest)) {
      from--;
    }
    final moved = [...all.sublist(from, placed), ...appended];
    mergeSort(moved, compare: byStart);
    for (final entry in all.skip(from)) {
      byId.remove(entry.info.id);
    }
    for (final entry in moved) {
      byId[entry.info.id] = entry;
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
