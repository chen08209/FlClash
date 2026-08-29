part of '../action.dart';

const updatingSweepInterval = Duration(seconds: 30);
const updatingStaleTimeout = Duration(minutes: 3);

@Riverpod(keepAlive: true)
class UpdatingAction extends _$UpdatingAction {
  Timer? _sweepTimer;
  final _elapsed = <String, Duration>{};

  @override
  void build() {
    ref.onDispose(_cancelSweep);
    ref.listen(updatingKeysProvider, (_, next) {
      _elapsed.removeWhere((key, _) => !next.contains(key));
      if (next.isEmpty) {
        _cancelSweep();
        return;
      }
      _sweepTimer ??= Timer.periodic(updatingSweepInterval, (_) => _sweep());
    });
  }

  void _cancelSweep() {
    _sweepTimer?.cancel();
    _sweepTimer = null;
  }

  void _sweep() {
    // Core-scope updates hang if the Core process wedges without dropping the
    // connection, so they get a stale-timeout safety net. Local-scope updates
    // (e.g. large subscription downloads) have no such upper bound and rely
    // on their own network timeout/error handling instead.
    final notifier = ref.read(updatingKeysProvider.notifier);
    final expired = <String>[];
    for (final key in ref.read(updatingKeysProvider)) {
      if (notifier.scopeOf(key) != UpdatingScope.core) {
        continue;
      }
      final elapsed = (_elapsed[key] ?? Duration.zero) + updatingSweepInterval;
      _elapsed[key] = elapsed;
      if (elapsed >= updatingStaleTimeout) {
        expired.add(key);
      }
    }
    if (expired.isEmpty) {
      return;
    }
    commonPrint.log(
      'discard stale updating state: ${expired.join(', ')}',
      logLevel: LogLevel.warning,
    );
    ref.read(updatingKeysProvider.notifier).stopKeys(expired);
  }
}
