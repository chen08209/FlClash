import 'dart:async';
import 'dart:ui';

import 'package:fl_clash/common/common.dart';

extension FutureExt<T> on Future<T> {
  Future<T> withTimeout({
    Duration? timeout,
    String? tag,
    VoidCallback? onLast,
    FutureOr<T> Function()? onTimeout,
  }) {
    final realTimout = timeout ?? const Duration(minutes: 3);
    Timer(realTimout + commonDuration, () {
      if (onLast != null) {
        onLast();
      }
    });
    return this.timeout(
      realTimout,
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

extension CompleterExt<T> on Completer<T> {
  void safeCompleter(T value) {
    if (isCompleted) {
      return;
    }
    complete(value);
  }
}
