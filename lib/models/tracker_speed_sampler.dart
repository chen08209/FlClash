import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';

import 'common.dart';

// Closing a connection triggers an out-of-band refresh; a delta over a few
// milliseconds would read as a spike, so such samples keep the last speed.
const _minSampleGapMicros = 500 * Duration.microsecondsPerMillisecond;
const _upload = 0;
const _download = 1;
const _uploadSpeed = 2;
const _downloadSpeed = 3;
const _baseUpload = 4;
const _baseDownload = 5;
const _baseMicros = 6;
const _stride = 7;

/// Typed only, so sending it to the isolate that decodes the next poll is cheap.
final class TrackerSamples {
  final Int64List ids;
  final Int64List details;
  final Int64List samples;

  /// The log's slot for each connection, -1 until the log places it.
  final Int32List slots;
  final Int32List generations;

  const TrackerSamples._(
    this.ids,
    this.details,
    this.samples,
    this.slots,
    this.generations,
  );

  static final empty = TrackerSamples._(
    Int64List(0),
    Int64List(0),
    Int64List(0),
    Int32List(0),
    Int32List(0),
  );

  int get length => ids.length;

  int uploadAt(int index) => samples[index * _stride + _upload];

  int downloadAt(int index) => samples[index * _stride + _download];

  int uploadSpeedAt(int index) => samples[index * _stride + _uploadSpeed];

  int downloadSpeedAt(int index) => samples[index * _stride + _downloadSpeed];
}

/// In full only what the last poll did not list or whose details moved.
typedef ConnectionPoll = ({
  List<TrackerInfo> fresh,
  Int32List freshAt,
  TrackerSamples samples,
});

ConnectionPoll Function(List<TrackerInfo>) pollAfter(
  TrackerSamples previous,
  Int32List generations,
) {
  return (trackerInfos) => pollTrackerInfos(
    trackerInfos,
    previous,
    DateTime.now(),
    generations: generations,
  );
}

ConnectionPoll pollTrackerInfos(
  List<TrackerInfo> trackerInfos,
  TrackerSamples previous,
  DateTime now, {
  Int32List? generations,
}) {
  final nowMicros = now.microsecondsSinceEpoch;
  final previousIndex = HashMap<int, int>();
  for (var index = 0; index < previous.length; index++) {
    previousIndex[previous.ids[index]] = index;
  }
  final length = trackerInfos.length;
  final ids = Int64List(length);
  final details = Int64List(length);
  final samples = Int64List(length * _stride);
  final slots = Int32List(length);
  final slotGenerations = Int32List(length);
  final fresh = <TrackerInfo>[];
  final freshAt = <int>[];
  for (final (index, trackerInfo) in trackerInfos.indexed) {
    final id = trackerInfo.id;
    final detail = _detailHashOf(trackerInfo);
    final last = previousIndex[id];
    ids[index] = id;
    details[index] = detail;
    _sample(trackerInfo, previous, last, nowMicros, samples, index * _stride);
    final slot = last == null ? -1 : previous.slots[last];
    final placed =
        slot >= 0 &&
        (generations == null ||
            slot < generations.length &&
                generations[slot] == previous.generations[last!]);
    if (placed) {
      slots[index] = slot;
      slotGenerations[index] = previous.generations[last!];
    } else {
      slots[index] = -1;
    }
    if (!placed || previous.details[last!] != detail) {
      final base = index * _stride;
      fresh.add(
        trackerInfo.copyWith(
          uploadSpeed: samples[base + _uploadSpeed],
          downloadSpeed: samples[base + _downloadSpeed],
        ),
      );
      freshAt.add(index);
    }
  }
  return (
    fresh: fresh,
    freshAt: Int32List.fromList(freshAt),
    samples: TrackerSamples._(ids, details, samples, slots, slotGenerations),
  );
}

void _sample(
  TrackerInfo trackerInfo,
  TrackerSamples previous,
  int? last,
  int nowMicros,
  Int64List samples,
  int base,
) {
  samples[base + _upload] = trackerInfo.upload;
  samples[base + _download] = trackerInfo.download;
  if (last == null) {
    samples[base + _baseUpload] = trackerInfo.upload;
    samples[base + _baseDownload] = trackerInfo.download;
    samples[base + _baseMicros] = nowMicros;
    return;
  }
  final from = previous.samples;
  final lastBase = last * _stride;
  final elapsedMicros = nowMicros - from[lastBase + _baseMicros];
  if (elapsedMicros < _minSampleGapMicros) {
    samples.setRange(
      base + _uploadSpeed,
      base + _stride,
      from,
      lastBase + _uploadSpeed,
    );
    return;
  }
  final seconds = elapsedMicros / Duration.microsecondsPerSecond;
  samples[base + _uploadSpeed] =
      (max(0, trackerInfo.upload - from[lastBase + _baseUpload]) / seconds)
          .round();
  samples[base + _downloadSpeed] =
      (max(0, trackerInfo.download - from[lastBase + _baseDownload]) / seconds)
          .round();
  samples[base + _baseUpload] = trackerInfo.upload;
  samples[base + _baseDownload] = trackerInfo.download;
  samples[base + _baseMicros] = nowMicros;
}

int _detailHashOf(TrackerInfo trackerInfo) => trackerInfo
    .copyWith(upload: 0, download: 0, uploadSpeed: null, downloadSpeed: null)
    .hashCode;
