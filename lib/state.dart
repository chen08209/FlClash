import 'dart:async';

import 'common/common.dart';
import 'enum/enum.dart';
import 'models/models.dart';

import 'package:fl_clash/common/theme.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

class GlobalState {
  static GlobalState? _instance;
  GlobalKey<NavigatorState> get navigatorKey => rootNavigatorKey;
  late final String appEnv;
  late final PackageInfo packageInfo;
  Function? updateCurrentDelayDebounce;
  late Measure measure;
  late CommonTheme theme;
  late ProviderContainer container;
  bool needInitStatus = true;

  bool get isPre => appEnv != 'stable';

  bool get canCrashCore => canCrashCoreFor(isDebug: kDebugMode, appEnv: appEnv);

  @visibleForTesting
  static bool canCrashCoreFor({required bool isDebug, required String appEnv}) {
    return isDebug || appEnv == 'dev';
  }

  String? lastConfigMd5;
  VpnState? lastVpnState;
  bool isAttach = false;

  GlobalState._internal();

  factory GlobalState() {
    _instance ??= GlobalState._internal();
    return _instance!;
  }

  String get ua => container
      .read(patchClashConfigProvider.select((state) => state.globalUa))
      .takeFirstValid([packageInfo.ua]);

  Future<T?> loadingRun<T>(
    FutureOr<T> Function() futureFunction, {
    String? title,
    required LoadingTag? tag,
    bool silence = false,
  }) async {
    return globalState.safeRun(
      futureFunction,
      silence: silence,
      title: title,
      onStart: () {
        if (tag != null) {
          container.read(loadingProvider(tag).notifier).start();
        }
      },
      onEnd: () {
        if (tag != null) {
          container.read(loadingProvider(tag).notifier).stop();
        }
      },
    );
  }

  Future<T?> safeRun<T>(
    FutureOr<T> Function() futureFunction, {
    String? title,
    VoidCallback? onStart,
    VoidCallback? onEnd,
    bool silence = true,
  }) async {
    try {
      onStart?.call();
      return await futureFunction();
    } catch (e, s) {
      commonPrint.log(
        title == null
            ? '${compactError(e)}, $s'
            : '$title ===> ${compactError(e)}, $s',
        logLevel: LogLevel.warning,
      );
      final message = userFacingErrorMessage(e, currentAppLocalizations);
      if (silence) {
        dialogs.showNotifier(message, level: MessageLevel.error);
      } else {
        unawaited(
          dialogs.showMessage(
            title: title ?? currentAppLocalizations.tip,
            message: TextSpan(text: message),
          ),
        );
      }
      return null;
    } finally {
      onEnd?.call();
    }
  }
}

final globalState = GlobalState();
