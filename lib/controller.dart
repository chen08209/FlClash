import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'clash/core.dart';
import 'enum/enum.dart';
import 'models/models.dart';
import 'common/common.dart';

class AppController {
  final BuildContext context;
  late AppState appState;
  late Config config;
  late ClashConfig clashConfig;
  late Measure measure;
  late Function updateClashConfigDebounce;

  AppController(this.context) {
    appState = context.read<AppState>();
    config = context.read<Config>();
    clashConfig = context.read<ClashConfig>();
    updateClashConfigDebounce = debounce<Function()>(() async {
      await updateClashConfig();
    });
    measure = Measure.of(context);
  }

  Future<void> updateSystemProxy(bool isStart) async {
    if (isStart) {
      await globalState.startSystemProxy(
        config: config,
        clashConfig: clashConfig,
      );

      updateRunTime();
      updateTraffic();
      globalState.updateFunctionLists = [
        updateRunTime,
        updateTraffic,
      ];
    } else {
      await globalState.stopSystemProxy();
      appState.traffics = [];
      appState.runTime = null;
    }
  }

  updateCoreVersionInfo() {
    globalState.updateCoreVersionInfo(appState);
  }

  updateRunTime() {
    if (proxyManager.startTime != null) {
      final startTimeStamp = proxyManager.startTime!.millisecondsSinceEpoch;
      final nowTimeStamp = DateTime
          .now()
          .millisecondsSinceEpoch;
      appState.runTime = nowTimeStamp - startTimeStamp;
    } else {
      appState.runTime = null;
    }
  }

  updateTraffic() {
    globalState.updateTraffic(
      config: config,
      appState: appState,
    );
  }

  changeProxy() {
    globalState.changeProxy(
      appState: appState,
      config: config,
      clashConfig: clashConfig,
    );
  }

  addProfile(Profile profile) {
    config.setProfile(profile);
    if (config.currentProfileId != null) return;
    changeProfile(profile.id);
  }

  deleteProfile(String id) async {
    config.deleteProfileById(id);
    final profilePath = await appPath.getProfilePath(id);
    if (profilePath == null) return;
    final file = File(profilePath);
    Isolate.run(() async {
      final isExists = await file.exists();
      if (isExists) {
        file.delete();
      }
    });
    if (config.currentProfileId == id) {
      if (config.profiles.isNotEmpty) {
        final updateId = config.profiles.first.id;
        changeProfile(updateId);
      } else {
        changeProfile(null);
      }
    }
  }

  updateProfile(String id) async {
    final profile = config.getCurrentProfileForId(id);
    if (profile != null) {
      final res = await profile.update();
      if (res.type == ResultType.success) {
        config.setProfile(profile);
      }
    }
  }

  Future<String> updateClashConfig({bool isPatch = true}) async {
    return await globalState.updateClashConfig(
      clashConfig: clashConfig,
      config: config,
      isPatch: isPatch,
    );
  }

  applyProfile() async {
    await globalState.applyProfile(
      appState: appState,
      config: config,
      clashConfig: clashConfig,
    );
  }

  Function?  _changeProfileDebounce;

  changeProfileDebounce(String? profileId) {
    if (profileId == config.currentProfileId) return;
    config.currentProfileId = profileId;
    _changeProfileDebounce ??= debounce<Function(String?)>((profileId) async {
      await applyProfile();
      appState.delayMap = {};
      saveConfigPreferences();
    });
    _changeProfileDebounce!([profileId]);
  }

  changeProfile(String? value) async {
    if (value == config.currentProfileId) return;
    config.currentProfileId = value;
    await applyProfile();
    appState.delayMap = {};
    saveConfigPreferences();
  }

  autoUpdateProfiles() async {
    for (final profile in config.profiles) {
      if (!profile.autoUpdate) return;
      final isNotNeedUpdate = profile.lastUpdateDate
          ?.add(
        profile.autoUpdateDuration,
      )
          .isBeforeNow();
      if (isNotNeedUpdate == false) continue;
      await profile.update();
    }
  }

  Future<void> updateGroups() async {
    await globalState.updateGroups(appState);
  }

  updateSystemColorSchemes(SystemColorSchemes systemColorSchemes) {
    appState.systemColorSchemes = systemColorSchemes;
  }

  clearCurrentDelay() {
    final currentProxyName =
    appState.getCurrentProxyName(config.currentProxyName, clashConfig.mode);
    if (currentProxyName == null) return;
    appState.setDelay(Delay(name: currentProxyName, value: null));
  }

  savePreferences() async {
    await saveConfigPreferences();
    await saveClashConfigPreferences();
  }

  saveConfigPreferences() async {
    debugPrint("saveConfigPreferences");
    await preferences.saveConfig(config);
  }

  saveClashConfigPreferences() async {
    debugPrint("saveClashConfigPreferences");
    await preferences.saveClashConfig(clashConfig);
  }

  handleBackOrExit() async {
    if (config.isMinimizeOnExit) {
      if (system.isDesktop) {
        await savePreferences();
      }
      await system.back();
    } else {
      await handleExit();
    }
  }

  handleExit() async {
    await updateSystemProxy(false);
    await savePreferences();
    clashCore.shutdown();
    system.exit();
  }

  updateLogStatus() {
    if (config.openLogs) {
      clashCore.startLog();
    } else {
      clashCore.stopLog();
      appState.logs = [];
    }
  }

  afterInit() async {
    if (appState.isInit) {
      if (config.autoRun) {
        await updateSystemProxy(true);
      } else {
        await proxyManager.updateStartTime();
        await updateSystemProxy(proxyManager.isStart);
      }
      autoUpdateProfiles();
      updateLogStatus();
      if (!config.silentLaunch) {
        window?.show();
      }
    }
  }

  setDelay(Delay delay) {
    appState.setDelay(delay);
  }

  toPage(int index, {bool hasAnimate = false}) {
    final nextLabel = globalState.currentNavigationItems[index].label;
    appState.currentLabel = nextLabel;
    if ((config.isAnimateToPage || hasAnimate)) {
      globalState.pageController?.animateToPage(
        index,
        duration: kTabScrollDuration,
        curve: Curves.easeOut,
      );
    } else {
      globalState.pageController?.jumpToPage(index);
    }
  }

  updatePackages() async {
    await globalState.updatePackages(appState);
  }

  toProfiles() {
    final index = globalState.currentNavigationItems.indexWhere(
          (element) => element.label == "profiles",
    );
    if (index != -1) {
      toPage(index);
    }
  }

  addProfileFormURL(String url) async {
    globalState.navigatorKey.currentState?.popUntil((route) => route.isFirst);
    toProfiles();
    final commonScaffoldState = globalState.homeScaffoldKey.currentState;
    if (commonScaffoldState?.mounted != true) return;
    commonScaffoldState?.loadingRun(
          () async {
        await Future.delayed(const Duration(milliseconds: 300));
        final profile = Profile(
          url: url,
        );
        final res = await profile.update();
        if (res.type == ResultType.success) {
          addProfile(profile);
        } else {
          debugPrint(res.message);
          globalState.showMessage(
            title: "${appLocalizations.add}${appLocalizations.profile}",
            message: TextSpan(text: res.message!),
          );
        }
      },
    );
  }

  initLink() {
    linkManager.initAppLinksListen(
          (url) {
        globalState.showMessage(
          title: "${appLocalizations.add}${appLocalizations.profile}",
          message: TextSpan(
            children: [
              TextSpan(text: appLocalizations.doYouWantToPass),
              TextSpan(
                text: " $url ",
                style: TextStyle(
                  color: Theme
                      .of(context)
                      .colorScheme
                      .primary,
                  decoration: TextDecoration.underline,
                  decorationColor: Theme
                      .of(context)
                      .colorScheme
                      .primary,
                ),
              ),
              TextSpan(
                  text:
                  "${appLocalizations.create}${appLocalizations.profile}"),
            ],
          ),
          onTab: () {
            addProfileFormURL(url);
          },
        );
      },
    );
  }

  addProfileFormFile() async {
    final result = await FileUtil.pickerConfig();
    if (result.type == ResultType.error) return;
    if (!context.mounted) return;
    globalState.navigatorKey.currentState?.popUntil((route) => route.isFirst);
    toProfiles();
    final commonScaffoldState = globalState.homeScaffoldKey.currentState;
    if (commonScaffoldState?.mounted != true) return;
    commonScaffoldState?.loadingRun(
          () async {
        await Future.delayed(const Duration(milliseconds: 300));
        final bytes = result.data?.bytes;
        if (bytes == null) {
          return;
        }
        final profile = Profile(label: result.data?.name);
        final sRes = await profile.saveFile(bytes);
        if (sRes.type == ResultType.error) {
          debugPrint(sRes.message);
          globalState.showMessage(
            title: "${appLocalizations.add}${appLocalizations.profile}",
            message: TextSpan(text: sRes.message!),
          );
          return;
        }
        addProfile(profile);
      },
    );
  }
}
