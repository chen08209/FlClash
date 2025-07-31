import 'dart:async';
import 'dart:io';

import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/plugins/service.dart';
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
  await globalState.init();
  await service?.init();
  tile?.addListener(
    _TileListenerWithService(
      onStop: () async {
        await app?.tip(appLocalizations.stopVpn);
        globalState.handleStop();
      },
    ),
  );
  Future(() async {
    app?.tip(appLocalizations.startVpn);
    final version = await system.version;
    await coreController.init(version);
    final clashConfig = globalState.config.patchClashConfig.copyWith.tun(
      enable: false,
    );
    final params = await globalState.getSetupParams(pathConfig: clashConfig);
    await coreController.setupConfig(params);
    await globalState.handleStart();
  });
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
