import 'dart:collection';

import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import 'connection_filters.dart';

final class _Held {
  /// As last seen, which is all a row the log trimmed still has.
  TrackerInfo info;
  final int start;
  final int seq;

  _Held(this.info, this.seq) : start = info.start.microsecondsSinceEpoch;
}

/// Past this many changes, placing every row again costs less than each.
const _placedOneByOne = 128;

final class _Minute {
  final int minute;
  var count = 0;

  _Minute(this.minute);
}

int _minuteOf(int micros) => micros ~/ Duration.microsecondsPerMinute;

/// The connections a list holds and shows, kept up with the log change by
/// change, so a poll costs what it changed and the rows on screen rather than
/// a pass over every connection.
///
/// Following the log's end, the list holds what the log holds. Off the end,
/// it keeps the rows it has, trimmed or not, and takes new ones up to
/// [rowLimit].
class ConnectionRows extends ChangeNotifier implements MinuteRows<String> {
  final int rowLimit;

  ConnectionRows({this.rowLimit = 2 * maxRequestsLength});

  ConnectionLog? _log;
  final _traffic = StaggeredNotifier();
  var _revision = 0;
  var _following = true;
  var _hovered = false;
  var _staggersDetails = false;
  final _waiting = <String>[];
  var _refollowWhenFree = false;
  final _held = <String, _Held>{};
  var _active = 0;
  var _failed = 0;

  bool Function(TrackerInfo trackerInfo)? _shows;
  Object Function(TrackerInfo trackerInfo)? _repeatKeyOf;

  /// Oldest first.
  final _shown = <_Held>[];
  final _shownIds = HashSet<String>();
  final _minutes = <_Minute>[];
  Int32List? _minuteRows;
  final _runs = HashMap<Object, List<String>>();
  final _repeats = <String, int>{};
  Map<String, int>? _repeatsView;

  bool get following => _following;

  /// Whether new rows wait to go in: while the pointer rests on a list that
  /// follows the log's end, so a row does not move out from under it.
  bool get holdsNew => _hovered && _following;

  set hovered(bool hovered) {
    if (hovered == _hovered) {
      return;
    }
    _hovered = hovered;
    _release();
  }

  bool get staggersDetails => _staggersDetails;

  void later(VoidCallback callback) => _traffic.schedule(callback);

  int get shownCount => _shown.length;

  int countOf(ConnectionStatus status) => switch (status) {
    ConnectionStatus.all => _held.length,
    ConnectionStatus.active => _active,
    ConnectionStatus.failed => _failed,
  };

  Map<ConnectionStatus, int> get counts => {
    for (final status in ConnectionStatus.values) status: countOf(status),
  };

  /// What a draft reads, built only when asked.
  List<TrackerInfo> get held => [
    for (final MapEntry(key: id, value: held) in _held.entries)
      _log?[id] ?? held.info,
  ];

  /// How many failed dials each merged row stands for, where more than one.
  Map<String, int> get repeats => _repeatsView ??= Map.unmodifiable(_repeats);

  TrackerInfo infoOf(String id) => heldInfoOf(id)!;

  /// Null once the rows have let [id] go, which its row on screen may still
  /// be asked of until the next frame builds the rows again.
  TrackerInfo? heldInfoOf(String id) => _log?[id] ?? _held[id]?.info;

  /// As of its last change other than traffic, which [traffic] tells of.
  TrackerInfo detailsOf(String id) => _held[id]!.info;

  Listenable get traffic => _traffic;

  /// The row at [fraction] of the way from the oldest.
  TrackerInfo? atFraction(double fraction) => _shown.isEmpty
      ? null
      : infoOf(_shown[(fraction * (_shown.length - 1)).round()].info.id);

  set following(bool following) {
    if (following == _following) {
      return;
    }
    _following = following;
    _release();
    notifyListeners();
  }

  /// Holds what [log] holds and follows it from here.
  void follow(ConnectionLog log) {
    _following = true;
    _log = log;
    _revision = log.revision;
    _waiting.clear();
    _refollowWhenFree = false;
    _held.clear();
    _active = 0;
    _failed = 0;
    for (final trackerInfo in log.list) {
      _hold(trackerInfo, log.seqOf(trackerInfo.id)!);
    }
    _reshow();
    notifyListeners();
  }

  void update(ConnectionLog log) {
    final previous = _log;
    if (previous == null || !identical(previous.lineage, log.lineage)) {
      follow(log);
      return;
    }
    _log = log;
    final changes = log.changesSince(_revision);
    _revision = log.revision;
    _traffic.notify();
    if (changes == null) {
      _rehold(log);
      return;
    }
    if (changes.isEmpty) {
      return;
    }
    final placing = changes.length <= _placedOneByOne;
    for (final (:kind, :id) in changes) {
      switch (kind) {
        case ConnectionChangeKind.opened when holdsNew:
          if (_waiting.length < rowLimit) {
            _waiting.add(id);
          } else {
            _refollowWhenFree = true;
          }
        case ConnectionChangeKind.opened:
          _open(log, id, placing: placing);
        case ConnectionChangeKind.changed || ConnectionChangeKind.closed:
          final held = _held[id];
          if (held != null) {
            if (_lastOf(log, held) case final trackerInfo?) {
              _retake(held, trackerInfo, placing: placing);
            }
          }
        case ConnectionChangeKind.removed:
          final held = _held[id];
          if (held != null && _following) {
            if (placing) {
              _hide(held);
            }
            _unhold(held);
          }
      }
    }
    if (!placing) {
      _reshow();
    }
    notifyListeners();
  }

  /// Brings the list up to [log] after a time hidden, the rows whose details
  /// changed taking them a few a frame rather than all in the first.
  void catchUp(ConnectionLog log) {
    _staggersDetails = true;
    SchedulerBinding.instance.addPostFrameCallback(
      (_) => _staggersDetails = false,
    );
    update(log);
  }

  void _open(ConnectionLog log, String id, {required bool placing}) {
    final trackerInfo = log[id];
    if (trackerInfo == null || _held.containsKey(id)) {
      return;
    }
    if (_following || _held.length < rowLimit) {
      _hold(trackerInfo, log.seqOf(id)!);
      final shows = _shows;
      if (placing && (shows == null || shows(trackerInfo))) {
        _show(_held[id]!);
      }
    }
  }

  void _release() {
    final log = _log;
    if (holdsNew || log == null) {
      return;
    }
    if (_refollowWhenFree) {
      _refollowWhenFree = false;
      _waiting.clear();
      _rehold(log);
      return;
    }
    if (_waiting.isEmpty) {
      return;
    }
    for (final id in _waiting) {
      _open(log, id, placing: true);
    }
    _waiting.clear();
    notifyListeners();
  }

  /// The search and filters chosen; [repeatKeyOf] merges the rows that share
  /// a key into the newest of them.
  void showWhere(
    bool Function(TrackerInfo trackerInfo)? shows, {
    Object Function(TrackerInfo trackerInfo)? repeatKeyOf,
  }) {
    _shows = shows;
    _repeatKeyOf = repeatKeyOf;
    _reshow();
    notifyListeners();
  }

  void _rehold(ConnectionLog log) {
    if (holdsNew) {
      _refollowWhenFree = true;
    } else if (_following) {
      follow(log);
      return;
    }
    for (final held in _held.values) {
      if (_lastOf(log, held) case final trackerInfo?) {
        _count(held.info, -1);
        held.info = trackerInfo;
        _count(trackerInfo, 1);
      }
    }
    if (!_following) {
      _takeMissed(log);
    }
    _reshow();
    notifyListeners();
  }

  /// A row still open here closed unseen if the log has forgotten it.
  TrackerInfo? _lastOf(ConnectionLog log, _Held held) {
    final known = log.lastOf(held.info.id);
    if (known != null || !held.info.isActive) {
      return known;
    }
    final closedBy = log.forgottenBy;
    if (closedBy == null) {
      return null;
    }
    return held.info.copyWith(
      closedAt: closedBy,
      uploadSpeed: null,
      downloadSpeed: null,
    );
  }

  /// What [log] holds that the list missed, up to [rowLimit], as the changes
  /// would have brought it.
  void _takeMissed(ConnectionLog log) {
    for (final trackerInfo in log.list) {
      if (_held.length >= rowLimit) {
        return;
      }
      if (!_held.containsKey(trackerInfo.id)) {
        _hold(trackerInfo, log.seqOf(trackerInfo.id)!);
      }
    }
  }

  void _hold(TrackerInfo trackerInfo, int seq) {
    _held[trackerInfo.id] = _Held(trackerInfo, seq);
    _count(trackerInfo, 1);
  }

  void _unhold(_Held held) {
    _held.remove(held.info.id);
    _count(held.info, -1);
  }

  void _count(TrackerInfo trackerInfo, int by) {
    if (trackerInfo.isActive) {
      _active += by;
    }
    if (trackerInfo.failure != null) {
      _failed += by;
    }
  }

  void _retake(_Held held, TrackerInfo trackerInfo, {required bool placing}) {
    final moves = placing && !_placedAlike(held.info, trackerInfo);
    if (moves) {
      _hide(held);
    }
    _count(held.info, -1);
    held.info = trackerInfo;
    _count(trackerInfo, 1);
    final shows = _shows;
    if (moves && (shows == null || shows(trackerInfo))) {
      _show(held);
    }
  }

  bool _placedAlike(TrackerInfo before, TrackerInfo after) {
    final shows = _shows;
    if (shows != null && shows(before) != shows(after)) {
      return false;
    }
    final repeatKeyOf = _repeatKeyOf;
    return repeatKeyOf == null || repeatKeyOf(before) == repeatKeyOf(after);
  }

  void _reshow() {
    _shown.clear();
    _shownIds.clear();
    _minutes.clear();
    _minuteRows = null;
    _runs.clear();
    _repeats.clear();
    _repeatsView = null;
    final shows = _shows;
    final passing = [
      for (final held in _held.values)
        if (shows == null || shows(held.info)) held,
    ]..sort(_compare);
    for (final held in passing) {
      _show(held);
    }
  }

  static int _compare(_Held a, _Held b) =>
      a.start != b.start ? a.start.compareTo(b.start) : a.seq - b.seq;

  void _show(_Held held) {
    final repeatKeyOf = _repeatKeyOf;
    if (repeatKeyOf == null) {
      _place(held);
      return;
    }
    final run = _runs[repeatKeyOf(held.info)] ??= [];
    final at = _lowerBound(
      run.length,
      (index) => _compare(_held[run[index]]!, held),
    );
    run.insert(at, held.info.id);
    final newest = run.last;
    if (newest == held.info.id && run.length > 1) {
      final replaced = run[run.length - 2];
      _remove(_held[replaced]!);
      _repeats.remove(replaced);
      _place(held);
    } else if (run.length == 1) {
      _place(held);
    }
    if (run.length > 1) {
      _repeats[newest] = run.length;
    }
    _repeatsView = null;
  }

  void _hide(_Held held) {
    final id = held.info.id;
    final repeatKeyOf = _repeatKeyOf;
    if (repeatKeyOf == null) {
      if (_shownIds.contains(id)) {
        _remove(held);
      }
      return;
    }
    final key = repeatKeyOf(held.info);
    final run = _runs[key];
    if (run == null || !run.remove(id)) {
      return;
    }
    _repeatsView = null;
    if (!_shownIds.contains(id)) {
      _setRepeats(run);
      return;
    }
    _remove(held);
    _repeats.remove(id);
    if (run.isEmpty) {
      _runs.remove(key);
      return;
    }
    _place(_held[run.last]!);
    _setRepeats(run);
  }

  void _setRepeats(List<String> run) {
    if (run.length > 1) {
      _repeats[run.last] = run.length;
    } else {
      _repeats.remove(run.last);
    }
  }

  void _place(_Held held) {
    final at = _lowerBound(
      _shown.length,
      (index) => _compare(_shown[index], held),
    );
    _shown.insert(at, held);
    _shownIds.add(held.info.id);
    final minute = _minuteOf(held.start);
    final index = _minuteIndexOf(minute);
    if (index < _minutes.length && _minutes[index].minute == minute) {
      _minutes[index].count++;
    } else {
      _minutes.insert(index, _Minute(minute)..count = 1);
    }
    _minuteRows = null;
  }

  void _remove(_Held held) {
    final at = _shownIndexOf(held.info.id)!;
    _shown.removeAt(at);
    _shownIds.remove(held.info.id);
    final index = _minuteIndexOf(_minuteOf(held.start));
    if (--_minutes[index].count == 0) {
      _minutes.removeAt(index);
    }
    _minuteRows = null;
  }

  int? _shownIndexOf(String id) {
    if (!_shownIds.contains(id)) {
      return null;
    }
    final held = _held[id]!;
    return _lowerBound(_shown.length, (index) => _compare(_shown[index], held));
  }

  int _minuteIndexOf(int minute) =>
      _lowerBound(_minutes.length, (index) => _minutes[index].minute - minute);

  /// The first index in `0..length` whose comparison is not below zero.
  static int _lowerBound(int length, int Function(int index) compare) {
    var low = 0;
    var high = length;
    while (low < high) {
      final middle = (low + high) >> 1;
      if (compare(middle) < 0) {
        low = middle + 1;
      } else {
        high = middle;
      }
    }
    return low;
  }

  /// The row each minute's records start at, its header after them.
  Int32List get _rowsOfMinutes {
    final cached = _minuteRows;
    if (cached != null) {
      return cached;
    }
    final rows = Int32List(_minutes.length);
    var row = 0;
    for (final (index, minute) in _minutes.indexed) {
      rows[index] = row;
      row += minute.count + 1;
    }
    return _minuteRows = rows;
  }

  @override
  void dispose() {
    _traffic.dispose();
    super.dispose();
  }

  @override
  int get length => _shown.length + _minutes.length;

  @override
  MinuteRow<String> rowAt(int index) {
    final rows = _rowsOfMinutes;
    final group = _lowerBound(rows.length, (at) => rows[at] - index - 1) - 1;
    final minute = _minutes[group];
    final local = index - rows[group];
    if (local == minute.count) {
      return MinuteHeader(
        minute.minute,
        recordMinuteLabel(minute.minute, DateTime.now()),
        minute.count,
      );
    }
    final first = rows[group] - group;
    return MinuteRecord(
      _shown[first + local].info.id,
      ItemPosition.get(minute.count - 1 - local, minute.count),
    );
  }

  @override
  Key keyOf(String id) => ValueKey(id);

  @override
  int? indexOfKey(Key key) {
    if (key is! ValueKey) {
      return null;
    }
    switch (key.value) {
      case final String id:
        final at = _shownIndexOf(id);
        if (at == null) {
          return null;
        }
        return at + _minuteIndexOf(_minuteOf(_shown[at].start));
      case ('minute', final int minute):
        final group = _minuteIndexOf(minute);
        if (group >= _minutes.length || _minutes[group].minute != minute) {
          return null;
        }
        return _rowsOfMinutes[group] + _minutes[group].count;
    }
    return null;
  }
}
