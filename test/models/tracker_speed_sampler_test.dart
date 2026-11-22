import 'dart:isolate';
import 'dart:typed_data';

import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

TrackerInfo _tracker(
  String id, {
  int upload = 0,
  int download = 0,
  String host = 'example.com',
}) {
  return TrackerInfo(
    id: id,
    upload: upload,
    download: download,
    start: DateTime.utc(2026),
    metadata: Metadata(host: host),
    chains: const [],
    rule: 'MATCH',
    rulePayload: '',
  );
}

void main() {
  final t0 = DateTime.utc(2026, 1, 1, 12);
  DateTime at(double seconds) =>
      t0.add(Duration(milliseconds: (seconds * 1000).round()));
  List<String> ids(ConnectionPoll poll) =>
      poll.fresh.map((trackerInfo) => trackerInfo.id).toList();

  ConnectionPoll placed(ConnectionPoll poll) {
    for (final (index, at) in poll.freshAt.indexed) {
      poll.samples.slots[at] = index;
    }
    return poll;
  }

  test('reports no speed on the first sample', () {
    final poll = pollTrackerInfos(
      [_tracker('a', download: 10)],
      TrackerSamples.empty,
      t0,
    );
    expect(poll.fresh.single.downloadSpeed, 0);
    expect(poll.samples.downloadAt(0), 10);
  });

  test('derives speed from the delta over the elapsed time', () {
    final first = placed(
      pollTrackerInfos([_tracker('a')], TrackerSamples.empty, t0),
    );
    final second = pollTrackerInfos(
      [_tracker('a', upload: 1000, download: 4000)],
      first.samples,
      at(2),
    );
    expect(second.fresh, isEmpty);
    expect(second.samples.uploadSpeedAt(0), 500);
    expect(second.samples.downloadSpeedAt(0), 2000);
  });

  test(
    'a sample taken too soon keeps the last speed and takes the traffic',
    () {
      final first = placed(
        pollTrackerInfos([_tracker('a')], TrackerSamples.empty, t0),
      );
      final second = pollTrackerInfos(
        [_tracker('a', download: 1000)],
        first.samples,
        at(1),
      );
      final third = pollTrackerInfos(
        [_tracker('a', download: 1010)],
        second.samples,
        at(1.01),
      );
      expect(third.samples.downloadSpeedAt(0), 1000);
      expect(third.samples.downloadAt(0), 1010);

      final fourth = pollTrackerInfos(
        [_tracker('a', download: 3000)],
        third.samples,
        at(2),
      );
      expect(fourth.samples.downloadSpeedAt(0), 2000);
    },
  );

  test('sends in full only what is new, changed, or not yet placed', () {
    final first = pollTrackerInfos(
      [_tracker('a'), _tracker('b')],
      TrackerSamples.empty,
      t0,
    );
    expect(ids(first), ['a', 'b']);
    first.samples.slots[0] = 0;

    final second = pollTrackerInfos(
      [
        _tracker('c'),
        _tracker('a', download: 100),
        _tracker('b', host: 'moved.test'),
      ],
      first.samples,
      at(1),
    );

    expect(ids(second), ['c', 'b']);
    expect(second.freshAt, [0, 2]);
    expect(second.samples.slots, [-1, 0, -1]);
  });

  test('polls in another isolate from what the last poll kept', () async {
    final first = placed(
      pollTrackerInfos([_tracker('a')], TrackerSamples.empty, t0),
    );
    final poll = pollAfter(first.samples, Int32List(1));

    final second = await Isolate.run(
      () => poll([_tracker('a', download: 10), _tracker('b')]),
    );

    expect(ids(second), ['b']);
    expect(second.samples.downloadAt(0), 10);
  });
}
