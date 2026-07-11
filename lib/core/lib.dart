import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/plugins/service.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';

import 'interface.dart';
import 'method.dart';

class CoreLib extends CoreHandlerInterface {
  static CoreLib? _instance;

  Completer<bool> _connectedCompleter = Completer();

  CoreLib._internal();

  @override
  Future<String> preload() async {
    if (_connectedCompleter.isCompleted) {
      return 'core is connected';
    }
    final res = await service?.init();
    if (res?.isEmpty != true) {
      return res ?? '';
    }
    _connectedCompleter.complete(true);
    final syncRes = await service?.syncState(
      globalState.container.read(sharedStateProvider),
    );
    return syncRes ?? '';
  }

  factory CoreLib() {
    _instance ??= CoreLib._internal();
    return _instance!;
  }

  @override
  FutureOr<bool> destroy() async {
    return true;
  }

  @override
  Future<bool> shutdown(_) async {
    if (!_connectedCompleter.isCompleted) {
      return false;
    }
    _connectedCompleter = Completer();
    return service?.shutdown() ?? true;
  }

  @override
  Future<bool> startListener() async {
    final serviceStarted = await service?.start() ?? false;
    final listenerStarted = await super.startListener();
    return listenerStarted && serviceStarted;
  }

  @override
  Future<bool> stopListener() async {
    final serviceStopped = await service?.stop() ?? false;
    final listenerStopped = await super.stopListener();
    return serviceStopped && listenerStopped;
  }

  @override
  Future<T?> invokeMethod<T>({
    required CoreMethod method,
    Object? arguments,
    Duration? timeout,
  }) async {
    final id = nextMethodCallId;
    final response = await service
        ?.invokeMethod(
          CoreMethodCall(id: id, method: method, arguments: arguments),
        )
        .withTimeout(timeout: timeout, onTimeout: () => null);
    if (response == null) {
      return null;
    }
    return response.unwrap<T>();
  }

  @override
  Completer get completer => _connectedCompleter;
}

CoreLib? get coreLib => system.isAndroid ? CoreLib() : null;
