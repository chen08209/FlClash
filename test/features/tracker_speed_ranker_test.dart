import 'dart:isolate';

import 'package:fl_clash/features/connection/tracker_speed_ranker.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

TrackerInfo _tracker(
  int id, {
  int upload = 0,
  int download = 0,
  DateTime? start,
}) {
  return TrackerInfo(
    id: id,
    upload: upload,
    download: download,
    start: start ?? DateTime.utc(2026),
    metadata: const Metadata(),
    chains: const [],
    rule: 'MATCH',
    rulePayload: '',
  );
}

void main() {
  final t0 = DateTime.utc(2026, 1, 1, 12);
  DateTime at(double seconds) =>
      t0.add(Duration(milliseconds: (seconds * 1000).round()));
  List<int> ids(List<TrackerInfo> trackerInfos) =>
      trackerInfos.map((trackerInfo) => trackerInfo.id).toList();

  test('reports no speed on the first sample and ranks by traffic', () {
    final ranked = _Ranker().rank([
      _tracker(1, download: 100),
      _tracker(2, download: 900),
    ], t0);

    expect(ids(ranked), [2, 1]);
    expect(ranked.map((trackerInfo) => trackerInfo.downloadSpeed), [0, 0]);
  });

  test('derives speed from the delta over the elapsed time', () {
    final ranker = _Ranker();
    ranker.rank([_tracker(1, upload: 100, download: 1000)], t0);

    final ranked = ranker.rank([
      _tracker(1, upload: 1100, download: 5000),
    ], at(2));

    expect(ranked.single.uploadSpeed, 500);
    expect(ranked.single.downloadSpeed, 2000);
  });

  test('puts an active connection above a larger idle one', () {
    final ranker = _Ranker();
    ranker.rank([_tracker(1, download: 1 << 30), _tracker(2)], t0);

    final ranked = ranker.rank([
      _tracker(1, download: 1 << 30),
      _tracker(2, download: 4096),
    ], at(1));

    expect(ids(ranked), [2, 1]);
  });

  test('keeps the order of connections with similar speeds', () {
    final ranker = _Ranker();
    ranker.rank([_tracker(1), _tracker(2)], t0);
    final first = ranker.rank([
      _tracker(1, download: 5000),
      _tracker(2, download: 4500),
    ], at(1));
    expect(ids(first), [1, 2]);

    final second = ranker.rank([
      _tracker(1, download: 10000),
      _tracker(2, download: 10200),
    ], at(2));

    expect(ids(second), [1, 2]);
    expect(second.last.downloadSpeed, greaterThan(second.first.downloadSpeed!));
  });

  test('ignores a sample taken too soon after the previous one', () {
    final ranker = _Ranker();
    ranker.rank([_tracker(1)], t0);
    ranker.rank([_tracker(1, download: 1000)], at(1));

    final ranked = ranker.rank([_tracker(1, download: 1100)], at(1.05));

    expect(ranked.single.downloadSpeed, 1000);
  });

  test('ranks in another isolate from what the last poll kept', () async {
    final first = rankTrackerInfos(
      [_tracker(1), _tracker(2)],
      TrackerRanking.empty,
      t0,
    );
    final rank = rankAfter(first.ranking);
    final next = [_tracker(1, download: 10), _tracker(2, download: 5000)];

    final second = await Isolate.run(() => rank(next));

    expect(ids(second.trackerInfos), [2, 1]);
    expect(second.ranking.ids, [2, 1]);
  });
}

class _Ranker {
  var _ranking = TrackerRanking.empty;

  List<TrackerInfo> rank(List<TrackerInfo> trackerInfos, DateTime now) {
    final ranked = rankTrackerInfos(trackerInfos, _ranking, now);
    _ranking = ranked.ranking;
    return ranked.trackerInfos;
  }
}
