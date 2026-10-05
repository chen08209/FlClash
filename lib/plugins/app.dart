import 'dart:async';
import 'dart:io';

import 'package:fl_clash/common/boot_record.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

const _platformProbeTimeout = Duration(seconds: 2);

/// Extra shortcut surfaces for external automation (Samsung Modes and
/// Routines, Tasker). Mode shortcuts are on by default — three fixed entries;
/// profile shortcuts are opt-in because they multiply with the profile count.
const showModeShortcuts = bool.fromEnvironment(
  'flclash.show_mode_shortcuts',
  defaultValue: true,
);
const showProfileShortcuts = bool.fromEnvironment(
  'flclash.show_profile_shortcuts',
  defaultValue: false,
);

class App {
  static App? _instance;
  late MethodChannel methodChannel;
  Function()? onExit;
  Function()? onPackagesChanged;

  App._internal() {
    methodChannel = const MethodChannel('$packageName/app');
    methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'exit':
          if (onExit != null) {
            await onExit!();
          }
        case 'packagesChanged':
          onPackagesChanged?.call();
        case 'changeMode':
          if (call.arguments is String) {
            final mode = Mode.fromString(call.arguments as String);
            globalState.container
                .read(setupActionProvider.notifier)
                .changeMode(mode);
            // configProvider listener in app_manager debounces a save on any
            // config change — no explicit persistence needed here.
          }
        case 'selectProfile':
          if (call.arguments is int) {
            final profiles = globalState.container.read(profilesProvider);
            final profile = profiles.cast<Profile?>().firstWhere(
              (p) => p?.id == call.arguments,
              orElse: () => null,
            );
            if (profile != null) {
              // The single source of truth for "which profile is active" is
              // currentProfileIdProvider — CoreManager listens on it and runs
              // fullSetup(). setProfileAndAutoApply alone only reorders the list,
              // so a shortcut/routine firing it would silently do nothing when
              // another profile is already current. Set the id, then apply.
              globalState.container
                      .read(currentProfileIdProvider.notifier)
                      .value =
                  profile.id;
              globalState.container
                  .read(profilesActionProvider.notifier)
                  .setProfileAndAutoApply(profile);
            }
          }
        default:
          throw MissingPluginException();
      }
    });
  }

  factory App() {
    _instance ??= App._internal();
    return _instance!;
  }

  Future<bool?> moveTaskToBack() async {
    return methodChannel.invokeMethod<bool>('moveTaskToBack');
  }

  Future<List<Package>> getPackages() async {
    final packagesString = await methodChannel.invokeMethod<String>(
      'getPackages',
    );
    final List<dynamic> packagesRaw =
        (await packagesString?.decodeJson<List<dynamic>>()) ?? [];
    return packagesRaw.map((e) => Package.fromJson(e)).toSet().toList();
  }

  Future<bool> isInstalledAppsPermissionGranted() async {
    return await methodChannel.invokeMethod<bool>(
          'isInstalledAppsPermissionGranted',
        ) ??
        true;
  }

  Future<bool> requestInstalledAppsPermission() async {
    return await methodChannel.invokeMethod<bool>(
          'requestInstalledAppsPermission',
        ) ??
        false;
  }

  Future<List<String>> getChinaPackageNames() async {
    final packageNamesString = await methodChannel.invokeMethod<String>(
      'getChinaPackageNames',
    );
    final List<dynamic> packageNamesRaw =
        await packageNamesString?.decodeJson<List<dynamic>>() ?? [];
    return packageNamesRaw.map((e) => e.toString()).toList();
  }

  Future<bool?> requestNotificationsPermission() async {
    return methodChannel.invokeMethod<bool>('requestNotificationsPermission');
  }

  Future<bool> openFile(String path) async {
    return await methodChannel.invokeMethod<bool>('openFile', {'path': path}) ??
        false;
  }

  final Map<String, ImageProvider?> _packageIcons = {};
  final Map<String, Future<ImageProvider?>> _packageIconTasks = {};

  bool hasPackageIcon(String packageName) {
    return _packageIcons.containsKey(packageName);
  }

  ImageProvider? getCachedPackageIcon(String packageName) {
    return _packageIcons[packageName];
  }

  Future<ImageProvider?> getPackageIcon(String packageName) {
    if (_packageIcons.containsKey(packageName)) {
      return Future.value(_packageIcons[packageName]);
    }
    return _packageIconTasks[packageName] ??= _loadPackageIcon(packageName);
  }

  Future<ImageProvider?> _loadPackageIcon(String packageName) async {
    var icon = await _requestPackageIcon(packageName);
    if (icon == null && packageName.isNotEmpty) {
      icon = await getPackageIcon('');
    }
    _packageIcons[packageName] = icon;
    unawaited(_packageIconTasks.remove(packageName));
    return icon;
  }

  Future<ImageProvider?> _requestPackageIcon(String packageName) async {
    try {
      final path = await methodChannel.invokeMethod<String>('getPackageIcon', {
        'packageName': packageName,
      });
      if (path == null || path.isEmpty) {
        return null;
      }
      return FileImage(File(path));
    } catch (error) {
      commonPrint.log('getPackageIcon error: $error');
      return null;
    }
  }

  @visibleForTesting
  void clearPackageIconCache() {
    _packageIcons.clear();
    _packageIconTasks.clear();
  }

  Future<bool?> tip(String? message) async {
    return methodChannel.invokeMethod<bool>('tip', {'message': '$message'});
  }

  Future<bool?> initShortcuts() async {
    final labels = <String, String>{
      'start': currentAppLocalizations.start,
      'stop': currentAppLocalizations.stop,
      'toggle': currentAppLocalizations.toggle,
      if (showModeShortcuts) ...{
        'mode_rule': Mode.rule.label,
        'mode_global': Mode.global.label,
        'mode_direct': Mode.direct.label,
      },
      if (showProfileShortcuts)
        for (final profile in globalState.container.read(profilesProvider))
          'profile_${profile.id}': profile.realLabel,
    };
    return methodChannel.invokeMethod<bool>('initShortcuts', labels);
  }

  Future<bool?> updateExcludeFromRecents(bool value) async {
    return methodChannel.invokeMethod<bool>('updateExcludeFromRecents', {
      'value': value,
    });
  }

  Future<bool?> isBatteryOptimizationDisabled() async {
    if (!Platform.isAndroid) return true;
    return methodChannel.invokeMethod<bool>('isBatteryOptimizationDisabled');
  }

  Future<bool?> openBatteryOptimizationSettings() async {
    if (!Platform.isAndroid) return false;
    return methodChannel.invokeMethod<bool>('openBatteryOptimizationSettings');
  }

  Future<bool?> openAppSettings() async {
    if (!Platform.isAndroid) return false;
    return methodChannel.invokeMethod<bool>('openAppSettings');
  }

  Future<bool> didCrashOnPreviousExecution() async {
    try {
      final value = await methodChannel
          .invokeMethod<bool>('didCrashOnPreviousExecution')
          .timeout(_platformProbeTimeout);
      return value ?? false;
    } catch (error) {
      commonPrint.log(
        'Failed to read the previous-execution crash flag: '
        '${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      return false;
    }
  }

  Future<AppExitInfo?> getLastExitInfo() async {
    try {
      final raw = await methodChannel
          .invokeMapMethod<String, Object?>('getLastExitInfo')
          .timeout(_platformProbeTimeout);
      return AppExitInfo.fromJson(raw);
    } catch (error) {
      commonPrint.log(
        'Failed to read the last process exit info: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      return null;
    }
  }
}

final app = system.isAndroid ? App() : null;
