import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/plugins/service.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

import 'api/core_api.dart';
import 'api/core_client.dart';
import 'api/frame_channel.dart';
import 'api/errors.dart';
import 'api/rpc_core_api.dart';
import 'backend.dart';
import 'desktop/model.dart';

class CoreLib extends CoreBackend {
  static CoreLib? _instance;

  final Service? _service;

  @override
  final CoreApi api;

  final StreamController<String> _crashController =
      StreamController<String>.broadcast();
  StreamSubscription<ChannelEvent>? _sessionEvents;
  Completer<bool> _connectedCompleter = Completer<bool>();
  Future<CoreLifecycleResult>? _closeOperation;
  Future<void> _lastOperation = Future<void>.value();
  int _lifecycleRevision = 0;
  bool _wantsSession = false;
  bool _closed = false;

  CoreLib._internal() : this._(service);

  @visibleForTesting
  CoreLib.scoped(Service this._service, {CoreApi? api})
    : api = api ?? RpcCoreApi(CoreClient(_service.frames)) {
    _watchSession();
  }

  CoreLib._(Service? service)
    : _service = service,
      api = RpcCoreApi(CoreClient(service!.frames)) {
    _watchSession();
  }

  @override
  Stream<String> get crashes => _crashController.stream;

  void _watchSession() {
    _sessionEvents = _service?.frames.events.listen((event) {
      if (event is ChannelDisconnected &&
          _connectedCompleter.isCompleted &&
          !_closed) {
        _crashController.add(
          coreSessionLostMessage(event.error, currentAppLocalizations),
        );
      }
    });
  }

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
    if (!_wantsSession) {
      await _service?.shutdown();
      return _superseded(revision);
    }
    try {
      _service?.frames.connect();
    } catch (_) {
      await _service?.shutdown();
      rethrow;
    }
    _connectedCompleter.complete(true);
    final String syncError;
    try {
      await globalState.container.read(vpnOptionsProvider.future);
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
    _service?.frames.disconnect();
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
    _service?.frames.disconnect();
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
    try {
      return await _enqueue(_stop);
    } finally {
      await _sessionEvents?.cancel();
      await _crashController.close();
    }
  }

  // The service opens and closes the Core's listeners itself and reports a run
  // that ends, so the Core is not asked to.
  @override
  Future<void> startListener() async {
    if (!await _service!.start()) {
      throw const CoreMethodException(
        code: 'service_refused',
        message: 'The Android service did not start',
      );
    }
  }

  @override
  Future<void> stopListener() async {
    if (!await _service!.stop()) {
      throw const CoreMethodException(
        code: 'service_refused',
        message: 'The Android service did not stop',
      );
    }
  }
}

CoreLib? get coreLib => system.isAndroid ? CoreLib() : null;
