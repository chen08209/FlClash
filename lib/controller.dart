import 'dart:async';
import 'dart:io';

import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'common/common.dart';
import 'database/database.dart';
import 'models/models.dart';
import 'providers/database.dart';

class AppController {
  late final BuildContext _context;
  late final WidgetRef _ref;
  bool isAttach = false;

  static AppController? _instance;

  AppController._internal();

  factory AppController() {
    _instance ??= AppController._internal();
    return _instance!;
  }

  Future<void> attach(BuildContext context, WidgetRef ref) async {
    _context = context;
    _ref = ref;
    await _init();
    isAttach = true;
  }
}

extension InitControllerExt on AppController {
  Future<void> _init() async {
    FlutterError.onError = (details) {
      commonPrint.log(
        'exception: ${details.exception} stack: ${details.stack}',
        logLevel: LogLevel.warning,
      );
    };
    updateTray();
    autoUpdateProfiles();
    autoCheckUpdate();
    autoLaunch?.updateStatus(_ref.read(appSettingProvider).autoLaunch);
    if (!_ref.read(appSettingProvider).silentLaunch) {
      window?.show();
    } else {
      window?.hide();
    }
    await _handleFailedPreference();
    await _handlerDisclaimer();
    await _showCrashlyticsTip();
    await _connectCore();
    await _initCore();
    await _initStatus();
    _ref.read(initProvider.notifier).value = true;
  }

  Future<void> _handleFailedPreference() async {
    if (await preferences.isInit) {
      return;
    }
    final res = await globalState.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(text: appLocalizations.cacheCorrupt),
    );
    if (res == true) {
      final file = File(await appPath.sharedPreferencesPath);
      await file.safeDelete();
    }
    await handleExit();
  }

  Future<bool> showDisclaimer() async {
    return await globalState.showCommonDialog<bool>(
          dismissible: false,
          child: CommonDialog(
            title: appLocalizations.disclaimer,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(_context).pop<bool>(false);
                },
                child: Text(appLocalizations.exit),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(_context).pop<bool>(true);
                },
                child: Text(appLocalizations.agree),
              ),
            ],
            child: Text(appLocalizations.disclaimerDesc),
          ),
        ) ??
        false;
  }

  Future<void> _showCrashlyticsTip() async {
    if (!system.isAndroid) {
      return;
    }
    if (_ref.read(appSettingProvider.select((state) => state.crashlyticsTip))) {
      return;
    }
    await globalState.showMessage(
      title: appLocalizations.dataCollectionTip,
      cancelable: false,
      message: TextSpan(text: appLocalizations.dataCollectionContent),
    );
    _ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(crashlyticsTip: true));
  }

  Future<void> _handlerDisclaimer() async {
    if (_ref.read(
      appSettingProvider.select((state) => state.disclaimerAccepted),
    )) {
      return;
    }
    final isDisclaimerAccepted = await showDisclaimer();
    if (!isDisclaimerAccepted) {
      await handleExit();
    }
    _ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(disclaimerAccepted: true));
    return;
  }

  Future<void> _initStatus() async {
    if (!globalState.needInitStatus) {
      commonPrint.log('init status cancel');
      return;
    }
    commonPrint.log('init status');
    if (system.isAndroid) {
      await globalState.updateStartTime();
    }
    final status = globalState.isStart == true
        ? true
        : _ref.read(appSettingProvider).autoRun;
    if (status == true) {
      await updateStatus(true, isInit: true);
    } else {
      await applyProfile(force: true);
    }
  }

  Future<void> autoCheckUpdate() async {
    if (!_ref.read(appSettingProvider).autoCheckUpdate) return;
    final res = await request.checkForUpdate();
    checkUpdateResultHandle(data: res);
  }

  Future<void> checkUpdateResultHandle({
    Map<String, dynamic>? data,
    bool isUser = false,
  }) async {
    if (data != null) {
      final tagName = data['tag_name'];
      final body = data['body'];
      final submits = utils.parseReleaseBody(body);
      final textTheme = _context.textTheme;
      final res = await globalState.showMessage(
        title: appLocalizations.discoverNewVersion,
        message: TextSpan(
          text: '$tagName \n',
          style: textTheme.headlineSmall,
          children: [
            TextSpan(text: '\n', style: textTheme.bodyMedium),
            for (final submit in submits)
              TextSpan(text: '- $submit \n', style: textTheme.bodyMedium),
          ],
        ),
        confirmText: appLocalizations.goDownload,
        cancelText: isUser ? null : appLocalizations.noLongerRemind,
      );
      if (res == true) {
        launchUrl(Uri.parse('https://github.com/$repository/releases/latest'));
      } else if (!isUser && res == false) {
        _ref
            .read(appSettingProvider.notifier)
            .update((state) => state.copyWith(autoCheckUpdate: false));
      }
    } else if (isUser) {
      globalState.showMessage(
        title: appLocalizations.checkUpdate,
        message: TextSpan(text: appLocalizations.checkUpdateError),
      );
    }
  }
}

extension StateControllerExt on AppController {
  Config get config {
    return _ref.read(configProvider);
  }

  bool get isMobile {
    return _ref.read(isMobileViewProvider);
  }

  bool get isStart {
    return _ref.read(isStartProvider);
  }

  List<Group> get groups {
    return _ref.read(groupsProvider);
  }

  String get ua => _ref.read(patchClashConfigProvider).globalUa.takeFirstValid([
    globalState.packageInfo.ua,
  ]);

  Profile? get currentProfile {
    return _ref.read(currentProfileProvider);
  }

  String? getSelectedProxyName(String groupName) {
    return _ref.read(getSelectedProxyNameProvider(groupName));
  }

  Future<SetupState> getSetupState(int profileId) async {
    return await _ref.read(setupStateProvider(profileId).future);
  }

  String getRealTestUrl(String? url) {
    return _ref.read(realTestUrlProvider(url));
  }

  int getProxiesColumns() {
    return _ref.read(getProxiesColumnsProvider);
  }

  SharedState get sharedState {
    return _ref.read(sharedStateProvider);
  }

  SetupParams get setupParams {
    final selectedMap = _ref.read(selectedMapProvider);
    final testUrl = _ref.read(
      appSettingProvider.select((state) => state.testUrl),
    );
    return SetupParams(selectedMap: selectedMap, testUrl: testUrl);
  }

  List<Group> getCurrentGroups() {
    return _ref.read(currentGroupsStateProvider.select((state) => state.value));
  }

  String? getCurrentGroupName() {
    final currentGroupName = _ref.read(
      currentProfileProvider.select((state) => state?.currentGroupName),
    );
    return currentGroupName;
  }
}

extension ProfilesControllerExt on AppController {
  Future<void> deleteProfile(int id) async {
    _ref.read(profilesProvider.notifier).del(id);
    clearEffect(id);
    final currentProfileId = _ref.read(currentProfileIdProvider);
    if (currentProfileId == id) {
      final profiles = _ref.read(profilesProvider);
      if (profiles.isNotEmpty) {
        final updateId = profiles.first.id;
        _ref.read(currentProfileIdProvider.notifier).value = updateId;
      } else {
        _ref.read(currentProfileIdProvider.notifier).value = null;
        updateStatus(false);
      }
    }
  }

  Future<void> autoUpdateProfiles() async {
    for (final profile in _ref.read(profilesProvider)) {
      if (!profile.autoUpdate) continue;
      final isNotNeedUpdate = profile.lastUpdateDate
          ?.add(profile.autoUpdateDuration)
          .isBeforeNow;
      if (isNotNeedUpdate == false || profile.type == ProfileType.file) {
        continue;
      }
      try {
        await updateProfile(profile);
      } catch (e) {
        commonPrint.log(e.toString(), logLevel: LogLevel.warning);
      }
    }
  }

  void putProfile(Profile profile) {
    _ref.read(profilesProvider.notifier).put(profile);
    if (_ref.read(currentProfileIdProvider) != null) return;
    _ref.read(currentProfileIdProvider.notifier).value = profile.id;
  }

  Future<void> updateProfiles() async {
    for (final profile in _ref.read(profilesProvider)) {
      if (profile.type == ProfileType.file) {
        continue;
      }
      await updateProfile(profile);
    }
  }

  Future<void> updateProfile(
    Profile profile, {
    bool showLoading = false,
  }) async {
    var currentProfile = profile;
    while (true) {
      try {
        if (showLoading) {
          _ref.read(isUpdatingProvider(profile.updatingKey).notifier).value =
              true;
        }
        final newProfile = await currentProfile.update();
        _ref.read(profilesProvider.notifier).put(newProfile);
        if (profile.id == _ref.read(currentProfileIdProvider)) {
          applyProfileDebounce(silence: true);
        }
        return;
      } on SubscriptionEncryptedException catch (e) {
        final password = await globalState.showCommonDialog<String>(
          child: InputDialog(
            autovalidateMode: AutovalidateMode.onUnfocus,
            title: appLocalizations.subscriptionLoginPassword,
            labelText: appLocalizations.subscriptionLoginPassword,
            value: currentProfile.loginPassword ?? '',
            obscureText: true,
            validator: (value) {
              if (e.passwordWrong && (value == null || value.isEmpty)) {
                return appLocalizations.subscriptionPasswordWrongTip;
              }
              return null;
            },
          ),
        );
        if (password == null) return;
        currentProfile = currentProfile.copyWith(loginPassword: password);
        _ref.read(profilesProvider.notifier).put(currentProfile);
      } finally {
        if (showLoading) {
          _ref.read(isUpdatingProvider(profile.updatingKey).notifier).value =
              false;
        }
      }
    }
  }

  Future<void> addProfileFormURL(String url) async {
    if (globalState.navigatorKey.currentState?.canPop() ?? false) {
      globalState.navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
    toProfiles();
    var loginPassword = '';
    while (true) {
      try {
        final profile = await loadingRun(tag: LoadingTag.profiles, () async {
          return await Profile.normal(url: url, loginPassword: loginPassword.isEmpty ? null : loginPassword).update();
        }, title: appLocalizations.addProfile);
        if (profile != null) {
          putProfile(profile);
        }
        return;
      } on SubscriptionEncryptedException catch (e) {
        final password = await globalState.showCommonDialog<String>(
          child: InputDialog(
            autovalidateMode: AutovalidateMode.onUnfocus,
            title: appLocalizations.subscriptionLoginPassword,
            labelText: appLocalizations.subscriptionLoginPassword,
            value: loginPassword,
            obscureText: true,
            validator: (value) {
              if (e.passwordWrong && (value == null || value.isEmpty)) {
                return appLocalizations.subscriptionPasswordWrongTip;
              }
              return null;
            },
          ),
        );
        if (password == null) return;
        loginPassword = password;
      }
    }
  }

  void setProfileAndAutoApply(Profile profile) {
    _ref.read(profilesProvider.notifier).put(profile);
    if (profile.id == _ref.read(currentProfileIdProvider)) {
      applyProfileDebounce();
    }
  }

  Future<void> addProfileFormFile() async {
    final platformFile = await safeRun(picker.pickerFile);
    final bytes = platformFile?.bytes;
    if (bytes == null) {
      return;
    }
    if (!_context.mounted) return;
    globalState.navigatorKey.currentState?.popUntil((route) => route.isFirst);
    toProfiles();
    final profile = await loadingRun(tag: LoadingTag.profiles, () async {
      return await Profile.normal(label: platformFile?.name).saveFile(bytes);
    }, title: appLocalizations.addProfile);
    if (profile != null) {
      putProfile(profile);
    }
  }

  Future<void> addProfileFormQrCode() async {
    final url = await safeRun(picker.pickerConfigQRCode);
    if (url == null) return;
    addProfileFormURL(url);
  }

  void reorder(List<Profile> profiles) {
    _ref.read(profilesProvider.notifier).reorder(profiles);
  }

  Future<void> clearEffect(int profileId) async {
    final profilePath = await appPath.getProfilePath(profileId.toString());
    final providersDirPath = await appPath.getProvidersDirPath(
      profileId.toString(),
    );
    final profileFile = File(profilePath);
    final isExists = await profileFile.exists();
    if (isExists) {
      await profileFile.safeDelete(recursive: true);
    }
    await coreController.deleteFile(providersDirPath);
  }
}

extension LogsControllerExt on AppController {
  void addLog(Log log) {
    _ref.read(logsProvider).add(log);
  }

  Future<bool> exportLogs() async {
    final logString = await encodeLogsTask(_ref.read(logsProvider).list);
    final tempFilePath = await appPath.tempFilePath;
    final file = File(tempFilePath);
    await file.safeWriteAsString(logString);
    bool res = false;
    res = await picker.saveFileWithPath(utils.logFile, tempFilePath) != null;
    return res;
  }
}

extension ProxiesControllerExt on AppController {
  void updateGroupsDebounce([Duration? duration]) {
    debouncer.call(FunctionTag.updateGroups, updateGroups, duration: duration);
  }

  void changeProxyDebounce(String groupName, String proxyName) {
    debouncer.call(FunctionTag.changeProxy, (
      String groupName,
      String proxyName,
    ) async {
      await changeProxy(groupName: groupName, proxyName: proxyName);
      updateGroupsDebounce();
    }, args: [groupName, proxyName]);
  }

  Future<void> updateGroups() async {
    try {
      commonPrint.log('updateGroups');
      _ref.read(groupsProvider.notifier).value = await retry(
        task: () async {
          final sortType = _ref.read(
            proxiesStyleSettingProvider.select((state) => state.sortType),
          );
          final delayMap = _ref.read(delayDataSourceProvider);
          final testUrl = _ref.read(
            appSettingProvider.select((state) => state.testUrl),
          );
          final selectedMap = _ref.read(
            currentProfileProvider.select((state) => state?.selectedMap ?? {}),
          );
          return await coreController.getProxiesGroups(
            selectedMap: selectedMap,
            sortType: sortType,
            delayMap: delayMap,
            defaultTestUrl: testUrl,
          );
        },
        retryIf: (res) => res.isEmpty,
      );
    } catch (e) {
      commonPrint.log('updateGroups error: $e');
      _ref.read(groupsProvider.notifier).value = [];
    }
  }

  void updateCurrentGroupName(String groupName) {
    final profile = _ref.read(currentProfileProvider);
    if (profile == null || profile.currentGroupName == groupName) {
      return;
    }
    _ref
        .read(profilesProvider.notifier)
        .put(profile.copyWith(currentGroupName: groupName));
  }

  void updateCurrentSelectedMap(String groupName, String proxyName) {
    final currentProfile = _ref.read(currentProfileProvider);
    if (currentProfile != null &&
        currentProfile.selectedMap[groupName] != proxyName) {
      final selectedMap = Map<String, String>.from(currentProfile.selectedMap)
        ..[groupName] = proxyName;
      _ref
          .read(profilesProvider.notifier)
          .put(currentProfile.copyWith(selectedMap: selectedMap));
    }
  }

  void updateCurrentUnfoldSet(Set<String> value) {
    final currentProfile = _ref.read(currentProfileProvider);
    if (currentProfile == null) {
      return;
    }
    _ref
        .read(profilesProvider.notifier)
        .put(currentProfile.copyWith(unfoldSet: value));
  }

  void setDelay(Delay delay) {
    _ref.read(delayDataSourceProvider.notifier).setDelay(delay);
  }

  Future<void> changeProxy({
    required String groupName,
    required String proxyName,
  }) async {
    await coreController.changeProxy(
      ChangeProxyParams(groupName: groupName, proxyName: proxyName),
    );
    if (_ref.read(appSettingProvider).closeConnections) {
      coreController.closeConnections();
    } else {
      coreController.resetConnections();
    }
    addCheckIp();
  }

  void setProvider(ExternalProvider? provider) {
    _ref.read(providersProvider.notifier).setProvider(provider);
  }

  Future<void> updateProviders() async {
    _ref.read(providersProvider.notifier).value = await coreController
        .getExternalProviders();
  }

  Future<String> updateProvider(
    ExternalProvider provider, {
    bool showLoading = false,
  }) async {
    try {
      if (showLoading) {
        _ref.read(isUpdatingProvider(provider.updatingKey).notifier).value =
            true;
      }
      final message = await coreController.updateExternalProvider(
        providerName: provider.name,
      );
      if (message.isNotEmpty) return message;
      setProvider(await coreController.getExternalProvider(provider.name));
      return '';
    } finally {
      _ref.read(isUpdatingProvider(provider.updatingKey).notifier).value =
          false;
    }
  }

  int addSortNum() {
    return _ref.read(sortNumProvider.notifier).add();
  }
}

extension SetupControllerExt on AppController {
  void fullSetup() {
    if (!_ref.read(initProvider)) {
      return;
    }
    _ref.read(delayDataSourceProvider.notifier).value = {};
    applyProfile(force: true);
    _ref.read(logsProvider.notifier).value = FixedList(500);
    _ref.read(requestsProvider.notifier).value = FixedList(500);
  }

  Future<void> updateStatus(bool isStart, {bool isInit = false}) async {
    if (isStart) {
      if (!isInit) {
        final res = await tryStartCore(true);
        if (res) {
          return;
        }
        if (!_ref.read(initProvider)) {
          return;
        }
        await globalState.handleStart([updateRunTime, updateTraffic]);
        applyProfileDebounce(force: true, silence: true);
      } else {
        globalState.needInitStatus = false;
        await applyProfile(
          force: true,
          preloadInvoke: () async {
            await globalState.handleStart([updateRunTime, updateTraffic]);
          },
        );
      }
    } else {
      await globalState.handleStop();
      coreController.resetTraffic();
      _ref.read(trafficsProvider.notifier).clear();
      _ref.read(totalTrafficProvider.notifier).value = Traffic();
      _ref.read(runTimeProvider.notifier).value = null;
      addCheckIp();
    }
  }

  Future<bool> needSetup() async {
    final profileId = _ref.read(currentProfileIdProvider);
    if (profileId == null) {
      return false;
    }
    final setupState = await _ref.read(setupStateProvider(profileId).future);
    return setupState.needSetup(globalState.lastSetupState) == true;
  }

  Future<void> updateConfigDebounce() async {
    debouncer.call(FunctionTag.updateConfig, () async {
      await safeRun(() async {
        final updateParams = _ref.read(updateParamsProvider);
        final res = await _requestAdmin(updateParams.tun.enable);
        if (res.isError) {
          return;
        }
        final realTunEnable = _ref.read(realTunEnableProvider);
        final message = await coreController.updateConfig(
          updateParams.copyWith.tun(enable: realTunEnable),
        );
        if (message.isNotEmpty) throw message;
      });
    });
  }

  void addCheckIp() {
    _ref.read(checkIpNumProvider.notifier).add();
  }

  void tryCheckIp() {
    final isTimeout = _ref.read(
      networkDetectionProvider.select(
        (state) => state.ipInfo == null && state.isLoading == false,
      ),
    );
    if (!isTimeout) {
      return;
    }
    _ref.read(checkIpNumProvider.notifier).add();
  }

  void applyProfileDebounce({bool silence = false, bool force = false}) {
    debouncer.call(FunctionTag.applyProfile, (silence, force) {
      applyProfile(silence: silence, force: force);
    }, args: [silence, force]);
  }

  void changeMode(Mode mode) {
    _ref
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(mode: mode));
    if (mode == Mode.global) {
      updateCurrentGroupName(GroupName.GLOBAL.name);
    }
    addCheckIp();
  }

  void autoApplyProfile() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      applyProfile();
    });
  }

  Future<void> applyProfile({
    bool silence = false,
    bool force = false,
    VoidCallback? preloadInvoke,
  }) async {
    if (!force && !await needSetup()) {
      return;
    }
    await loadingRun(
      () async {
        await _setupConfig(preloadInvoke);
        await updateGroups();
        await updateProviders();
      },
      silence: true,
      tag: !silence ? LoadingTag.proxies : null,
    );
  }

  Future<Map<String, dynamic>> getProfile({
    required SetupState setupState,
    required ClashConfig patchConfig,
  }) async {
    final profileId = setupState.profileId;
    if (profileId == null) {
      return {};
    }
    final defaultUA = globalState.packageInfo.ua;
    final networkVM2 = _ref.read(
      networkSettingProvider.select(
        (state) => VM2(state.appendSystemDns, state.routeMode),
      ),
    );
    final overrideDns = _ref.read(overrideDnsProvider);
    final appendSystemDns = networkVM2.a;
    final routeMode = networkVM2.b;
    final configMap = await coreController.getConfig(profileId);
    String? scriptContent;
    final List<Rule> addedRules = [];
    if (setupState.overwriteType == OverwriteType.script) {
      scriptContent = await setupState.script?.content;
    } else {
      addedRules.addAll(setupState.addedRules);
    }
    final realPatchConfig = patchConfig.copyWith(
      tun: patchConfig.tun.getRealTun(routeMode),
    );
    Map<String, dynamic> rawConfig = configMap;
    if (scriptContent?.isNotEmpty == true) {
      rawConfig = await globalState.handleEvaluate(scriptContent!, rawConfig);
    }
    final directory = await appPath.profilesPath;
    final res = makeRealProfileTask(
      MakeRealProfileState(
        profilesPath: directory,
        profileId: profileId,
        rawConfig: rawConfig,
        realPatchConfig: realPatchConfig,
        overrideDns: overrideDns,
        appendSystemDns: appendSystemDns,
        addedRules: addedRules,
        defaultUA: defaultUA,
      ),
    );
    return res;
  }

  Future<Map> getProfileWithId(int profileId) async {
    var res = {};
    try {
      final setupState = await _ref.read(setupStateProvider(profileId).future);
      final patchClashConfig = _ref.read(patchClashConfigProvider);
      res = await getProfile(
        setupState: setupState,
        patchConfig: patchClashConfig,
      );
    } catch (e) {
      globalState.showNotifier(e.toString());
    }
    return res;
  }

  Future<void> _setupConfig([VoidCallback? preloadInvoke]) async {
    commonPrint.log('setup ===>');
    var profile = _ref.read(currentProfileProvider);
    final nextProfile = await profile?.checkAndUpdateAndCopy();
    if (nextProfile != null) {
      profile = nextProfile;
      _ref.read(profilesProvider.notifier).put(nextProfile);
    }
    final patchConfig = _ref.read(patchClashConfigProvider);
    final res = await _requestAdmin(patchConfig.tun.enable);
    if (res.isError) {
      return;
    }
    final realTunEnable = _ref.read(realTunEnableProvider);
    final realPatchConfig = patchConfig.copyWith.tun(enable: realTunEnable);
    final setupState = await _ref.read(setupStateProvider(profile?.id).future);
    globalState.lastSetupState = setupState;
    if (system.isAndroid) {
      globalState.lastVpnState = _ref.read(vpnStateProvider);
      preferences.saveShareState(this.sharedState);
    }
    final config = await getProfile(
      setupState: setupState,
      patchConfig: realPatchConfig,
    );
    final configFilePath = await appPath.configFilePath;
    final yamlString = await encodeYamlTask(config);
    await File(configFilePath).safeWriteAsString(yamlString);
    final message = await coreController.setupConfig(
      setupState: setupState,
      params: setupParams,
      preloadInvoke: preloadInvoke,
    );
    if (message.isNotEmpty) {
      throw message;
    }
    addCheckIp();
  }
}

extension CoreControllerExt on AppController {
  Future<void> _initCore() async {
    final isInit = await coreController.isInit;
    final version = _ref.read(versionProvider);
    if (!isInit) {
      await coreController.init(version);
    } else {
      await updateGroups();
    }
  }

  Future<void> _connectCore() async {
    _ref.read(coreStatusProvider.notifier).value = CoreStatus.connecting;
    final result = await Future.wait([
      coreController.preload(),
      Future.delayed(Duration(milliseconds: 300)),
    ]);
    final String message = result[0];
    if (message.isNotEmpty) {
      _ref.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
      if (_context.mounted) {
        _context.showNotifier(message);
      }
      return;
    }
    _ref.read(coreStatusProvider.notifier).value = CoreStatus.connected;
  }

  Future<Result<bool>> _requestAdmin(bool enableTun) async {
    final realTunEnable = _ref.read(realTunEnableProvider);
    if (enableTun != realTunEnable && realTunEnable == false) {
      final code = await system.authorizeCore();
      switch (code) {
        case AuthorizeCode.success:
          await restartCore();
          return Result.error('');
        case AuthorizeCode.none:
          break;
        case AuthorizeCode.error:
          enableTun = false;
          break;
      }
    }
    _ref.read(realTunEnableProvider.notifier).value = enableTun;
    return Result.success(enableTun);
  }

  Future<void> restartCore([bool start = false]) async {
    _ref.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    await coreController.shutdown(true);
    await _connectCore();
    await _initCore();
    if (start || _ref.read(isStartProvider)) {
      await updateStatus(true, isInit: true);
    } else {
      await applyProfile(force: true);
    }
  }

  Future<bool> tryStartCore([bool start = false]) async {
    if (coreController.isCompleted) {
      return false;
    }
    await restartCore(start);
    return true;
  }

  void handleCoreDisconnected() {
    _ref.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
  }
}

extension SystemControllerExt on AppController {
  Future<List<Package>> getPackages() async {
    if (_ref.read(isMobileViewProvider)) {
      await Future.delayed(commonDuration);
    }
    if (_ref.read(packagesProvider).isEmpty) {
      _ref.read(packagesProvider.notifier).value =
          await app?.getPackages() ?? [];
    }
    return _ref.read(packagesProvider);
  }

  Future<void> handleExit([bool needSave = false]) async {
    Future.delayed(Duration(seconds: 3), () {
      system.exit();
    });
    try {
      await Future.wait([
        if (needSave) preferences.saveConfig(config),
        if (macOS != null) macOS!.updateDns(true),
        if (proxy != null) proxy!.stopProxy(),
        if (tray != null) tray!.destroy(),
      ]);
      await coreController.destroy();
      commonPrint.log('exit');
    } finally {
      system.exit();
    }
  }

  Future<void> handleBackOrExit() async {
    if (_ref.read(backBlockProvider)) {
      return;
    }
    if (_ref.read(appSettingProvider).minimizeOnExit) {
      if (system.isDesktop) {
        await preferences.saveConfig(config);
      }
      await system.back();
    } else {
      await handleExit();
    }
  }

  Future<void> updateVisible() async {
    final visible = await window?.isVisible;
    if (visible != null && !visible) {
      window?.show();
    } else {
      window?.hide();
    }
  }

  void updateBrightness() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ref.read(systemBrightnessProvider.notifier).value =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
    });
  }

  void updateViewSize(Size size) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ref.read(viewSizeProvider.notifier).value = size;
    });
  }

  void initLink() {
    linkManager.initAppLinksListen((url) async {
      final res = await globalState.showMessage(
        title: '${appLocalizations.add}${appLocalizations.profile}',
        message: TextSpan(
          children: [
            TextSpan(text: appLocalizations.doYouWantToPass),
            TextSpan(
              text: ' $url ',
              style: TextStyle(
                color: _context.colorScheme.primary,
                decoration: TextDecoration.underline,
                decorationColor: _context.colorScheme.primary,
              ),
            ),
            TextSpan(
              text: '${appLocalizations.create}${appLocalizations.profile}',
            ),
          ],
        ),
      );

      if (res != true) {
        return;
      }
      addProfileFormURL(url);
    });
  }

  void updateTun() {
    _ref
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith.tun(enable: !state.tun.enable));
  }

  void updateSystemProxy() {
    _ref
        .read(networkSettingProvider.notifier)
        .update((state) => state.copyWith(systemProxy: !state.systemProxy));
  }

  void updateAutoLaunch() {
    _ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(autoLaunch: !state.autoLaunch));
  }

  Future<void> updateTray() async {
    tray?.update(
      trayState: _ref.read(trayStateProvider),
      traffic: _ref.read(
        trafficsProvider.select((state) => state.list.safeLast(Traffic())),
      ),
    );
  }

  Future<void> updateLocalIp() async {
    _ref.read(localIpProvider.notifier).value = null;
    await Future.delayed(commonDuration);
    _ref.read(localIpProvider.notifier).value = await utils.getLocalIpAddress();
  }
}

extension BackupControllerExt on AppController {
  Future<void> shakingStore() async {
    final profileIds = _ref.read(
      profilesProvider.select((state) => state.map((item) => item.id)),
    );
    final scriptIds = await _ref.read(
      scriptsProvider.future.select(
        (state) async => (await state).map((item) => item.id),
      ),
    );
    final pathsToDelete = await shakingProfileTask(VM2(profileIds, scriptIds));
    if (pathsToDelete.isNotEmpty) {
      final deleteFutures = pathsToDelete.map((path) async {
        try {
          final res = await coreController.deleteFile(path);
          if (res.isNotEmpty) {
            throw res;
          }
        } catch (e) {
          rethrow;
        }
      });

      await Future.wait(deleteFutures);
    }
  }

  Future<String> backup() async {
    final profileFileNames = _ref.read(
      profilesProvider.select((state) => state.map((item) => item.fileName)),
    );
    final scriptFileNames = await _ref.read(
      scriptsProvider.future.select(
        (state) async => (await state).map((item) => item.fileName),
      ),
    );
    final configMap = _ref.read(configProvider).toJson();
    configMap['version'] = await preferences.getVersion();
    return await backupTask(configMap, [
      ...profileFileNames,
      ...scriptFileNames,
    ]);
  }

  Future<void> restore(RestoreOption option) async {
    final restoreDirPath = await appPath.restoreDirPath;
    final restoreDir = Directory(restoreDirPath);
    final restoreStrategy = _ref.read(
      appSettingProvider.select((state) => state.restoreStrategy),
    );
    final isOverride = restoreStrategy == RestoreStrategy.override;
    try {
      final migrationData = await restoreTask();
      if (!await restoreDir.exists()) {
        throw appLocalizations.restoreException;
      }
      await database.restore(
        migrationData.profiles,
        migrationData.scripts,
        migrationData.rules,
        migrationData.links,
        isOverride: isOverride,
      );
      final configMap = migrationData.configMap;
      if (option == RestoreOption.onlyProfiles || configMap == null) {
        return;
      }
      final config = Config.fromJson(configMap);
      _ref.read(patchClashConfigProvider.notifier).value =
          config.patchClashConfig;
      _ref.read(appSettingProvider.notifier).value = config.appSettingProps;
      _ref.read(currentProfileIdProvider.notifier).value =
          config.currentProfileId;
      _ref.read(davSettingProvider.notifier).value = config.davProps;
      _ref.read(themeSettingProvider.notifier).value = config.themeProps;
      _ref.read(windowSettingProvider.notifier).value = config.windowProps;
      _ref.read(vpnSettingProvider.notifier).value = config.vpnProps;
      _ref.read(proxiesStyleSettingProvider.notifier).value =
          config.proxiesStyleProps;
      _ref.read(overrideDnsProvider.notifier).value = config.overrideDns;
      _ref.read(networkSettingProvider.notifier).value = config.networkProps;
      _ref.read(hotKeyActionsProvider.notifier).value = config.hotKeyActions;
      return;
    } finally {
      await restoreDir.safeDelete(recursive: true);
    }
  }
}

extension BackBlockControllExt on AppController {
  void backBlock() {
    _ref.read(backBlockProvider.notifier).value = true;
  }

  void unBackBlock() {
    _ref.read(backBlockProvider.notifier).value = false;
  }
}

extension StoreControllerExt on AppController {
  void savePreferencesDebounce() {
    debouncer.call(FunctionTag.savePreferences, () async {
      await preferences.saveConfig(config);
    });
  }

  Future handleClear() async {
    await preferences.clearPreferences();
    commonPrint.log('clear preferences');
    await database.close();
    await File(await appPath.databasePath).safeDelete(recursive: true);
    final homeDir = Directory(await appPath.profilesPath);
    await for (final file in homeDir.list(recursive: true)) {
      await coreController.deleteFile(file.path);
    }
    await preferences.clearPreferences();
    handleExit(false);
  }
}

extension CommonControllerExt on AppController {
  void toPage(PageLabel pageLabel) {
    _ref.read(currentPageLabelProvider.notifier).value = pageLabel;
  }

  void toProfiles() {
    toPage(PageLabel.profiles);
  }

  void updateStart() {
    updateStatus(!_ref.read(isStartProvider));
  }

  void updateSpeedStatistics() {
    _ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(showTrayTitle: !state.showTrayTitle));
  }

  void updateMode() {
    _ref.read(patchClashConfigProvider.notifier).update((state) {
      final index = Mode.values.indexWhere((item) => item == state.mode);
      if (index == -1) {
        return null;
      }
      final nextIndex = index + 1 > Mode.values.length - 1 ? 0 : index + 1;
      return state.copyWith(mode: Mode.values[nextIndex]);
    });
  }

  void updateRunTime() {
    final startTime = globalState.startTime;
    if (startTime != null) {
      final startTimeStamp = startTime.millisecondsSinceEpoch;
      final nowTimeStamp = DateTime.now().millisecondsSinceEpoch;
      _ref.read(runTimeProvider.notifier).value = nowTimeStamp - startTimeStamp;
    } else {
      _ref.read(runTimeProvider.notifier).value = null;
    }
  }

  Future<void> updateTraffic() async {
    final onlyStatisticsProxy = _ref.read(
      appSettingProvider.select((state) => state.onlyStatisticsProxy),
    );
    final traffic = await coreController.getTraffic(onlyStatisticsProxy);
    _ref.read(trafficsProvider.notifier).addTraffic(traffic);
    _ref.read(totalTrafficProvider.notifier).value = await coreController
        .getTotalTraffic(onlyStatisticsProxy);
  }

  Future<T?> loadingRun<T>(
    FutureOr<T> Function() futureFunction, {
    String? title,
    required LoadingTag? tag,
    bool silence = false,
  }) async {
    return safeRun(
      futureFunction,
      silence: silence,
      title: title,
      onStart: () {
        if (tag == null) {
          return;
        }
        _ref.read(loadingProvider(tag).notifier).start();
      },
      onEnd: () {
        if (tag == null) {
          return;
        }
        _ref.read(loadingProvider(tag).notifier).stop();
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
      if (onStart != null) {
        onStart();
      }
      final res = await futureFunction();
      return res;
    } catch (e, s) {
      if (e is SubscriptionEncryptedException) rethrow;
      commonPrint.log('$title ===> $e, $s', logLevel: LogLevel.warning);
      if (silence) {
        globalState.showNotifier(e.toString());
      } else {
        globalState.showMessage(
          title: title ?? appLocalizations.tip,
          message: TextSpan(text: e.toString()),
        );
      }
      return null;
    } finally {
      if (onEnd != null) {
        onEnd();
      }
    }
  }
}

final appController = AppController();
