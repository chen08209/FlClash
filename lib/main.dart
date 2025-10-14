import 'dart:async';
import 'dart:io';

import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/plugins/tile.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'application.dart';
import 'common/common.dart';
import 'core/controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final version = await system.version;
  await globalState.initApp(version);
  HttpOverrides.global = FlClashHttpOverrides();
  runApp(ProviderScope(child: const Application()));
}

@pragma('vm:entry-point')
Future<void> _service(List<String> flags) async {
  WidgetsFlutterBinding.ensureInitialized();
  globalState.isService = true;
  await globalState.init();
  await coreController.preload();
  tile?.addListener(
    _TileListenerWithService(
      onStop: () async {
        await app?.tip(appLocalizations.stopVpn);
        await globalState.handleStop();
      },
    ),
  );
  app?.tip(appLocalizations.startVpn);
  final version = await system.version;
  await coreController.init(version);
  final clashConfig = globalState.config.patchClashConfig.copyWith.tun(
    enable: false,
  );
  final setupState = globalState.getSetupState(
    globalState.config.currentProfileId,
  );
  globalState.setupConfig(
    setupState: setupState,
    patchConfig: clashConfig,
    preloadInvoke: () {
      globalState.handleStart();
    },
  );
}

@immutable
class _TileListenerWithService with TileListener {
  final Function() _onStop;

  const _TileListenerWithService({required Function() onStop})
    : _onStop = onStop;

  @override
  void onStop() {
    _onStop();
  }
}
