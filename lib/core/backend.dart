import 'dart:async';

import 'api/core_api.dart';
import 'desktop/model.dart';

abstract class CoreBackend {
  CoreApi get api;

  Stream<String> get crashes => const Stream.empty();

  Future<CoreLifecycleResult> start();

  Future<CoreLifecycleResult> restart();

  Future<CoreLifecycleResult> stop();

  Future<CoreLifecycleResult> close();

  /// Opens the Core's listeners.
  Future<void> startListener();

  Future<void> stopListener();
}
