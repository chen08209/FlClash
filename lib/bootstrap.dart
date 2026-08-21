import 'dart:async';
import 'dart:io';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/launch.dart';
import 'package:fl_clash/common/migration.dart';
import 'package:fl_clash/common/permission.dart';
import 'package:fl_clash/common/tray.dart';
import 'package:fl_clash/common/window.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_color_utilities/palettes/core_palette.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Bootstrap {
  static Bootstrap? _instance;

  Bootstrap._internal();

  factory Bootstrap() {
    _instance ??= Bootstrap._internal();
    return _instance!;
  }

  bool _didCrashOnPreviousExecution = false;

  Future<ProviderContainer> init(int version) async {
    globalState.appEnv = const String.fromEnvironment(
      'APP_ENV',
      defaultValue: 'pre',
    );
    windowPort = window;
    trayPort = appTray;
    navigationPort = navigation;
    final dynamicColor = await _initDynamicColor();
    return _initData(version, dynamicColor);
  }

  Future<DynamicColorSeeds> _initDynamicColor() async {
    // ignore: deprecated_member_use
    CorePalette? corePalette;
    Color? accentColor;
    try {
      corePalette = await DynamicColorPlugin.getCorePalette();
    } catch (error) {
      commonPrint.log(
        'Failed to get core palette: $error',
        logLevel: LogLevel.warning,
      );
    }
    try {
      accentColor = await DynamicColorPlugin.getAccentColor();
    } catch (error) {
      commonPrint.log(
        'Failed to get accent color: $error',
        logLevel: LogLevel.warning,
      );
    }
    return (
      lightSeed: corePalette?.toColorScheme().primary,
      darkSeed: corePalette?.toColorScheme(brightness: Brightness.dark).primary,
      accentColor: accentColor ?? const Color(defaultPrimaryColor),
    );
  }

  Future<ProviderContainer> _initData(
    int version,
    DynamicColorSeeds dynamicColor,
  ) async {
    globalState.packageInfo = await PackageInfo.fromPlatform();
    var config = await migration.run();
    _didCrashOnPreviousExecution = await system.didCrashOnPreviousExecution();
    if (_didCrashOnPreviousExecution) {
      config = config.copyWith(currentProfileId: null);
      await preferences.saveConfig(config);
    }
    final appState = AppState(
      brightness: WidgetsBinding.instance.platformDispatcher.platformBrightness,
      version: version,
      viewSize: Size.zero,
      requests: FixedList(maxLength),
      logs: FixedList(maxLength),
      traffics: FixedList(trafficSampleLength),
      totalTraffic: const Traffic(),
      systemUiOverlayStyle: const SystemUiOverlayStyle(),
    );
    final appStateOverrides = buildAppStateOverrides(appState);
    final configOverrides = buildConfigOverrides(config);
    final container = ProviderContainer(
      overrides: [...appStateOverrides, ...configOverrides],
    );
    globalState.container = container;
    container
        .read(dynamicColorProvider.notifier)
        .seed(
          lightSeed: dynamicColor.lightSeed,
          darkSeed: dynamicColor.darkSeed,
          accentColor: dynamicColor.accentColor,
        );
    final profiles = await database.profilesDao.query().get();
    container.read(profilesProvider.notifier).setAndReorder(profiles);
    await AppLocalizations.load(
      getLocaleForString(config.appSettingProps.locale) ??
          WidgetsBinding.instance.platformDispatcher.locale,
    );
    await window?.init(version, config.windowProps);
    if (system.isAndroid) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    return container;
  }

  Future<void> attach() async {
    if (globalState.isAttach == true) {
      return;
    }
    await _initApp();
    globalState.isAttach = true;
  }

  ProviderContainer get _container => globalState.container;

  Future<void> _initApp() async {
    unawaited(_container.read(systemActionProvider.notifier).updateTray());
    unawaited(
      _container.read(profilesActionProvider.notifier).autoUpdateProfiles(),
    );
    unawaited(_container.read(commonActionProvider.notifier).autoCheckUpdate());
    unawaited(
      autoLaunch?.updateStatus(_container.read(appSettingProvider).autoLaunch),
    );
    if (!_container.read(appSettingProvider).silentLaunch) {
      unawaited(window?.show());
    } else {
      unawaited(window?.hide());
    }
    await _handleFailedPreference();
    await _handlerDisclaimer();
    await _showCrashRecoveryTip();
    await _showCrashlyticsTip();
    await _container.read(coreActionProvider.notifier).startCore();
    if (!_didCrashOnPreviousExecution) {
      await _container.read(setupActionProvider.notifier).initStatus();
    }
    _container.read(initProvider.notifier).value = true;
    permissions.check(_container.read);
  }

  Future<void> _showCrashRecoveryTip() async {
    if (!_didCrashOnPreviousExecution) return;
    await dialogs.showMessage(
      title: currentAppLocalizations.crashDetected,
      cancelable: false,
      dismissible: false,
      message: TextSpan(text: currentAppLocalizations.crashDetectedTip),
    );
  }

  Future<void> _handleFailedPreference() async {
    if (await preferences.isInit) return;
    final res = await dialogs.showMessage(
      title: currentAppLocalizations.tip,
      message: TextSpan(text: currentAppLocalizations.cacheCorrupt),
    );
    if (res == true) {
      final file = File(await appPath.sharedPreferencesPath);
      await file.safeDelete();
    }
    await _container.read(systemActionProvider.notifier).handleExit();
  }

  Future<void> _showCrashlyticsTip() async {
    if (!system.isAndroid) return;
    if (_container.read(
      appSettingProvider.select((state) => state.crashlyticsTip),
    )) {
      return;
    }
    await dialogs.showMessage(
      title: currentAppLocalizations.dataCollectionTip,
      cancelable: false,
      message: TextSpan(text: currentAppLocalizations.dataCollectionContent),
    );
    _container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(crashlyticsTip: true));
  }

  Future<void> _handlerDisclaimer() async {
    if (_container.read(
      appSettingProvider.select((state) => state.disclaimerAccepted),
    )) {
      return;
    }
    final isDisclaimerAccepted = await dialogs.showDisclaimer();
    if (!isDisclaimerAccepted) {
      await _container.read(systemActionProvider.notifier).handleExit();
    }
    _container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(disclaimerAccepted: true));
  }
}

final bootstrap = Bootstrap();
