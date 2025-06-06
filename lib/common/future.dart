import 'dart:async';
import 'dart:ui';

import 'package:fl_clash/common/common.dart';

extension CompleterExt<T> on Completer<T> {
  Future<T> safeFuture({
    Duration? timeout,
    VoidCallback? onLast,
    FutureOr<T> Function()? onTimeout,
    required String functionName,
  }) {
    final realTimeout = timeout ?? const Duration(seconds: 30);
    Timer(realTimeout + commonDuration, () {
      if (onLast != null) {
        onLast();
      }
    });
    return future.withTimeout(
      timeout: realTimeout,
      functionName: functionName,
      onTimeout: onTimeout,
    );
  }
}

extension FutureExt<T> on Future<T> {
  Future<T> withTimeout({
    required Duration timeout,
    required String functionName,
    FutureOr<T> Function()? onTimeout,
  }) {
    return this.timeout(
      timeout,
      onTimeout: () async {
        if (onTimeout != null) {
          return onTimeout();
        } else {
          throw TimeoutException('$functionName timeout');
        }
      },
    );
  }
}
