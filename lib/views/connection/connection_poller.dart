import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reads the open connections into the log, after the samples it last kept.
class ConnectionPoller {
  var _samples = TrackerSamples.empty;
  Object? _lineage;
  var _reads = 0;
  var _shownRead = 0;

  Future<void> read(
    WidgetRef ref, {
    required Future<List<TrackerInfo>> Function()? reader,
    required bool Function() mounted,
  }) async {
    final read = ++_reads;
    final log = ref.read(requestsProvider);
    final lineage = log.lineage;
    if (!identical(lineage, _lineage)) {
      _samples = TrackerSamples.empty;
      _lineage = lineage;
    }
    final poll = pollAfter(_samples, log.slotGenerations);
    final requestedAt = DateTime.now();
    try {
      final polled = poll(
        reader != null
            ? await reader()
            : ref.read(coreStatusProvider) == CoreStatus.connected
            ? ref.read(connectionBookProvider).list()
            : const [],
      );
      // A refresh after closing a connection can overlap a poll.
      if (read < _shownRead ||
          !mounted() ||
          !ref
              .read(requestsProvider.notifier)
              .poll(polled, requestedAt: requestedAt, lineage: lineage)) {
        return;
      }
      _shownRead = read;
      _samples = polled.samples;
    } catch (error) {
      commonPrint.log(
        'updateConnections error: $error',
        logLevel: coreFailureLogLevel(error),
      );
    }
  }
}
