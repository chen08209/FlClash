import 'dart:math';
import 'dart:typed_data';

import 'package:fl_clash/models/models.dart';

// Closing a connection triggers an out-of-band refresh; a delta over a few
// milliseconds would read as a spike, so such samples keep the last speed.
const _minSampleGapMicros = 500 * Duration.microsecondsPerMillisecond;
const _smoothing = 0.5;
const _upload = 0;
const _download = 1;
const _atMicros = 2;
const _uploadSpeed = 3;
const _downloadSpeed = 4;
const _stride = 5;

/// What [rankTrackerInfos] keeps of a poll, in ranked order: only ids and typed
/// data, so sending it to the isolate that decodes the next poll stays cheap.
final class TrackerRanking {
  final List<String> ids;
  final Int64List samples;
  final Float64List rankSpeeds;

  const TrackerRanking._(this.ids, this.samples, this.rankSpeeds);

  static final empty = TrackerRanking._(const [], Int64List(0), Float64List(0));
}

typedef RankedTrackerInfos = ({
  List<TrackerInfo> trackerInfos,
  TrackerRanking ranking,
});

RankedTrackerInfos Function(List<TrackerInfo>) rankAfter(
  TrackerRanking previous,
) {
  return (trackerInfos) =>
      rankTrackerInfos(trackerInfos, previous, DateTime.now());
}

/// Derives per-connection speed from successive cumulative snapshots and
/// orders connections by it without reshuffling the list every poll.
RankedTrackerInfos rankTrackerInfos(
  List<TrackerInfo> trackerInfos,
  TrackerRanking previous,
  DateTime now,
) {
  final nowMicros = now.microsecondsSinceEpoch;
  final previousIndex = <String, int>{
    for (final (index, id) in previous.ids.indexed) id: index,
  };
  final rankings = <_Ranking>[];
  for (final trackerInfo in trackerInfos) {
    final index = previousIndex[trackerInfo.id];
    final sample = index == null
        ? _Sample.first(trackerInfo, nowMicros)
        : _Sample.after(previous, index, trackerInfo, nowMicros);
    final bucket = sample.rankSpeed < 1
        ? 0
        : (log(sample.rankSpeed) / ln2).floor() + 1;
    rankings.add(
      _Ranking(
        trackerInfo.copyWith(
          uploadSpeed: sample.uploadSpeed,
          downloadSpeed: sample.downloadSpeed,
        ),
        sample,
        bucket: bucket,
        // Only a moving connection keeps its slot; idle ones sort by traffic.
        position: bucket > 0 ? index ?? trackerInfos.length : 0,
      ),
    );
  }
  rankings.sort(_Ranking.compare);

  final ranked = <TrackerInfo>[];
  final ids = <String>[];
  final samples = Int64List(rankings.length * _stride);
  final rankSpeeds = Float64List(rankings.length);
  for (final (index, ranking) in rankings.indexed) {
    ranked.add(ranking.trackerInfo);
    ids.add(ranking.trackerInfo.id);
    ranking.sample.writeTo(samples, index * _stride);
    rankSpeeds[index] = ranking.sample.rankSpeed;
  }
  return (
    trackerInfos: ranked,
    ranking: TrackerRanking._(ids, samples, rankSpeeds),
  );
}

class _Sample {
  final int upload;
  final int download;
  final int atMicros;
  final int uploadSpeed;
  final int downloadSpeed;
  final double rankSpeed;

  const _Sample({
    required this.upload,
    required this.download,
    required this.atMicros,
    required this.uploadSpeed,
    required this.downloadSpeed,
    required this.rankSpeed,
  });

  _Sample.first(TrackerInfo trackerInfo, int nowMicros)
    : this(
        upload: trackerInfo.upload,
        download: trackerInfo.download,
        atMicros: nowMicros,
        uploadSpeed: 0,
        downloadSpeed: 0,
        rankSpeed: 0,
      );

  factory _Sample.after(
    TrackerRanking previous,
    int index,
    TrackerInfo trackerInfo,
    int nowMicros,
  ) {
    final samples = previous.samples;
    final base = index * _stride;
    final last = _Sample(
      upload: samples[base + _upload],
      download: samples[base + _download],
      atMicros: samples[base + _atMicros],
      uploadSpeed: samples[base + _uploadSpeed],
      downloadSpeed: samples[base + _downloadSpeed],
      rankSpeed: previous.rankSpeeds[index],
    );
    final elapsedMicros = nowMicros - last.atMicros;
    if (elapsedMicros < _minSampleGapMicros) {
      return last;
    }
    final seconds = elapsedMicros / Duration.microsecondsPerSecond;
    final uploadSpeed = max(0, trackerInfo.upload - last.upload) / seconds;
    final downloadSpeed =
        max(0, trackerInfo.download - last.download) / seconds;
    final rankSpeed =
        last.rankSpeed +
        (uploadSpeed + downloadSpeed - last.rankSpeed) * _smoothing;
    return _Sample(
      upload: trackerInfo.upload,
      download: trackerInfo.download,
      atMicros: nowMicros,
      uploadSpeed: uploadSpeed.round(),
      downloadSpeed: downloadSpeed.round(),
      rankSpeed: rankSpeed < 1 ? 0 : rankSpeed,
    );
  }

  void writeTo(Int64List samples, int base) {
    samples[base + _upload] = upload;
    samples[base + _download] = download;
    samples[base + _atMicros] = atMicros;
    samples[base + _uploadSpeed] = uploadSpeed;
    samples[base + _downloadSpeed] = downloadSpeed;
  }
}

class _Ranking {
  final TrackerInfo trackerInfo;
  final _Sample sample;
  final int bucket;
  final int position;
  final int traffic;

  _Ranking(
    this.trackerInfo,
    this.sample, {
    required this.bucket,
    required this.position,
  }) : traffic = trackerInfo.upload + trackerInfo.download;

  static int compare(_Ranking a, _Ranking b) {
    final bucket = b.bucket.compareTo(a.bucket);
    if (bucket != 0) {
      return bucket;
    }
    final position = a.position.compareTo(b.position);
    if (position != 0) {
      return position;
    }
    final traffic = b.traffic.compareTo(a.traffic);
    if (traffic != 0) {
      return traffic;
    }
    final start = b.trackerInfo.start.compareTo(a.trackerInfo.start);
    return start != 0 ? start : a.trackerInfo.id.compareTo(b.trackerInfo.id);
  }
}
