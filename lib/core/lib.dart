import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/plugins/service.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

import 'desktop/model.dart';
import 'interface.dart';
import 'method.dart';
import 'spill.dart';

class CoreLib extends CoreHandlerInterface {
  static CoreLib? _instance;

  final Service? _service;

  Completer<bool> _connectedCompleter = Completer<bool>();
  Future<CoreLifecycleResult>? _closeOperation;
  Future<void> _lastOperation = Future<void>.value();
  int _lifecycleRevision = 0;
  int _methodCallId = 0;
  bool _wantsSession = false;
  bool _closed = false;

  CoreLib._internal() : _service = service;

  @visibleForTesting
  CoreLib.scoped(Service this._service);

  @visibleForTesting
  static void resetInstance() {
    _instance = null;
  }

  factory CoreLib() {
    _instance ??= CoreLib._internal();
    return _instance!;
  }

  /// Runs one transition at a time, so a stop or close waits for a start in
  /// flight to give back what it had already opened.
  Future<CoreLifecycleResult> _enqueue(
    Future<CoreLifecycleResult> Function(int revision) transition,
  ) {
    final revision = ++_lifecycleRevision;
    final result = _lastOperation.then((_) => transition(revision));
    _lastOperation = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }

  @override
  Future<CoreLifecycleResult> start() {
    if (_closed) {
      return Future.error(StateError('Core lifecycle is closed'));
    }
    _wantsSession = true;
    return _enqueue(_start);
  }

  Future<CoreLifecycleResult> _start(int revision) async {
    if (_connectedCompleter.isCompleted) {
      return CoreLifecycleResult(
        revision: revision,
        outcome: CoreLifecycleOutcome.coalesced,
      );
    }
    if (!_wantsSession) {
      return _superseded(revision);
    }
    final initializationError = await _service?.init() ?? '';
    if (initializationError.isNotEmpty) {
      throw StateError(initializationError);
    }
    await globalState.container.read(vpnOptionsProvider.future);
    if (!_wantsSession) {
      await _service?.shutdown();
      return _superseded(revision);
    }
    _connectedCompleter.complete(true);
    final String syncError;
    try {
      syncError =
          await _service?.syncState(
            globalState.container.read(sharedStateProvider),
          ) ??
          '';
    } catch (_) {
      await _disconnect();
      rethrow;
    }
    if (syncError.isNotEmpty) {
      await _disconnect();
      throw StateError(syncError);
    }
    if (!_wantsSession) {
      return _superseded(revision);
    }
    return CoreLifecycleResult(
      revision: revision,
      outcome: CoreLifecycleOutcome.applied,
    );
  }

  Future<void> _disconnect() async {
    _connectedCompleter = Completer<bool>();
    await _service?.shutdown();
  }

  CoreLifecycleResult _superseded(int revision) => CoreLifecycleResult(
    revision: revision,
    outcome: CoreLifecycleOutcome.superseded,
  );

  @override
  Future<CoreLifecycleResult> restart() async {
    await stop();
    return start();
  }

  @override
  Future<CoreLifecycleResult> stop() {
    if (_closed) {
      return Future.error(StateError('Core lifecycle is closed'));
    }
    _wantsSession = false;
    return _enqueue(_stop);
  }

  Future<CoreLifecycleResult> _stop(int revision) async {
    if (!_connectedCompleter.isCompleted) {
      return CoreLifecycleResult(
        revision: revision,
        outcome: CoreLifecycleOutcome.coalesced,
      );
    }
    _connectedCompleter = Completer<bool>();
    final stopped = await _service?.shutdown() ?? true;
    if (!stopped) {
      throw StateError('Android Core service shutdown failed');
    }
    return CoreLifecycleResult(
      revision: revision,
      outcome: CoreLifecycleOutcome.applied,
    );
  }

  @override
  Future<CoreLifecycleResult> close() {
    return _closeOperation ??= _close();
  }

  Future<CoreLifecycleResult> _close() async {
    _closed = true;
    _wantsSession = false;
    return _enqueue(_stop);
  }

  // The service opens and closes the Core's listeners itself and reports a run
  // that ends, so once it takes the command the Core's own answer is moot.
  @override
  Future<void> startListener() async {
    await _ignoreUnanswered(super.startListener);
    if (!await _service!.start()) {
      throw const CoreMethodException(
        code: 'service_refused',
        message: 'The Android service did not start',
      );
    }
  }

  @override
  Future<void> stopListener() async {
    final serviceStopped = await _service!.stop();
    await _ignoreUnanswered(super.stopListener);
    if (!serviceStopped) {
      throw const CoreMethodException(
        code: 'service_refused',
        message: 'The Android service did not stop',
      );
    }
  }

  Future<void> _ignoreUnanswered(Future<void> Function() command) async {
    try {
      await command();
    } catch (error) {
      if (!isUnansweredCoreError(error)) {
        rethrow;
      }
    }
  }

  @override
  Future<Object?> invokeMethod({
    required CoreMethod method,
    Object? arguments,
    Duration? timeout,
    CoreResultModel? model,
  }) {
    final call = _send(method: method, arguments: arguments, model: model);
    return call.withTimeout(
      timeout: timeout,
      onTimeout: () {
        unawaited(call.then(discardSpilledFile, onError: (_) {}));
        throw TimeoutException('Core method ${method.wireName} timed out');
      },
    );
  }

  Future<Object?> _send({
    required CoreMethod method,
    Object? arguments,
    CoreResultModel? model,
  }) async {
    try {
      await _connectedCompleter.future.timeout(coreConnectionWaitDuration);
    } on TimeoutException {
      throw CoreMethodException(
        code: 'core_unavailable',
        message: 'Core is not connected for ${method.wireName}',
      );
    }
    final id = '${++_methodCallId}';
    final response = await _service!.invokeMethod(
      CoreMethodCall(id: id, method: method, arguments: arguments),
      model: model,
    );
    return response.unwrap<Object?>();
  }
}

CoreLib? get coreLib => system.isAndroid ? CoreLib() : null;
