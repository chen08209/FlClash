import 'dart:async';
import 'dart:ui';

import 'package:fl_clash/ui/ui.dart';

extension FutureExt<T> on Future<T> {
  Future<T> withTimeout({
    Duration? timeout,
    String? tag,
    VoidCallback? onLast,
    FutureOr<T> Function()? onTimeout,
  }) {
    final realTimeout = timeout ?? const Duration(minutes: 3);
    final cleanupTimer = onLast == null
        ? null
        : Timer(realTimeout + commonDuration, onLast);
    if (cleanupTimer != null) {
      unawaited(
        then<void>(
          (_) => cleanupTimer.cancel(),
          onError: (Object _, StackTrace _) {
            cleanupTimer.cancel();
          },
        ),
      );
    }
    return this.timeout(
      realTimeout,
      onTimeout: () async {
        if (onTimeout != null) {
          return onTimeout();
        } else {
          throw TimeoutException('${tag ?? runtimeType} timeout');
        }
      },
    );
  }
}

/// Resolves once, then hands out the value rather than the future that
/// resolved it: a completed future still runs its listeners in the zone it was
/// created in, which under test may be a fake-async zone nothing drives.
class ResolveOnce<T> {
  final Future<T> Function() _resolve;
  Future<T>? _pending;
  ({T value})? _resolved;

  ResolveOnce(this._resolve);

  Future<T> get value async {
    if (_resolved case (:final value)) return value;
    final value = await (_pending ??= _resolve());
    _resolved = (value: value);
    return value;
  }
}

extension CompleterExt<T> on Completer<T> {
  void safeCompleter(T value) {
    if (isCompleted) {
      return;
    }
    complete(value);
  }
}
