import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/foundation.dart';

import 'api/channels/socket_channel.dart';
import 'api/core_api.dart';
import 'api/core_client.dart';
import 'api/rpc_core_api.dart';
import 'backend.dart';
import 'desktop/helper_client.dart';
import 'desktop/launcher.dart';
import 'desktop/lifecycle.dart';
import 'desktop/model.dart';
import 'desktop/transport.dart';

class CoreService extends CoreBackend {
  static CoreService? _instance;

  final DesktopCoreLifecycleController _lifecycle;
  final CoreClient? _client;
  @override
  final CoreApi api;
  Future<CoreLifecycleResult>? _closeOperation;

  factory CoreService() {
    return _instance ??= CoreService._create();
  }

  @visibleForTesting
  static void resetInstance() {
    _instance = null;
  }

  factory CoreService._create() {
    final address = system.isWindows ? windowsPipeName : unixSocketPath;
    final directLauncher = DirectCoreLauncher();

    final lifecycle = DesktopCoreLifecycle(
      transport: IpcCoreTransport(address: address),
      launcherResolver: HelperLauncherResolver(
        hasHelper: system.hasHelperService && !safeModeBuild,
        directLauncher: directLauncher,
        helperLauncher: HelperLauncher(helperClient),
        helperReady: () => helperClient.readiness(),
      ),
      verifyPeerPid: system.isWindows,
    );
    final client = CoreClient(
      SocketFrameChannel(lifecycle.transport),
      debug: kDebugMode,
    );
    return CoreService._(
      lifecycle: lifecycle,
      client: client,
      api: RpcCoreApi(client),
    );
  }

  @visibleForTesting
  CoreService.forTesting({
    required DesktopCoreLifecycleController lifecycle,
    required CoreApi api,
  }) : this._(lifecycle: lifecycle, client: null, api: api);

  CoreService._({
    required DesktopCoreLifecycleController lifecycle,
    required CoreClient? client,
    required this.api,
  }) : _lifecycle = lifecycle,
       _client = client;

  @override
  Stream<String> get crashes => _lifecycle.crashEvents.map((failure) {
    commonPrint.log('Core session lost: $failure', logLevel: LogLevel.warning);
    return coreSessionLostMessage(failure.cause, currentAppLocalizations);
  });

  @override
  Future<CoreLifecycleResult> start() => _lifecycle.start();

  @override
  Future<CoreLifecycleResult> restart() => _lifecycle.restart();

  @override
  Future<CoreLifecycleResult> stop() => _lifecycle.stop();

  @override
  Future<CoreLifecycleResult> close() {
    return _closeOperation ??= _close();
  }

  Future<CoreLifecycleResult> _close() async {
    try {
      return await _lifecycle.close();
    } finally {
      await _client?.close();
    }
  }

  @override
  Future<void> startListener() => api.startEngine();

  @override
  Future<void> stopListener() => api.stopEngine();
}

final coreService = system.isDesktop ? CoreService() : null;
