import 'dart:async';
import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:fl_clash/common/theme.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/plugins/service.dart';
import 'package:fl_clash/widgets/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:isar_community/isar.dart';
import 'package:material_color_utilities/palettes/core_palette.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'common/common.dart';
import 'controller.dart';
import 'models/models.dart';

typedef UpdateTasks = List<FutureOr Function()>;

class GlobalState {
  static GlobalState? _instance;
  final navigatorKey = GlobalKey<NavigatorState>();
  Timer? timer;
  late final Isar isar;
  late Config config;
  late AppState appState;
  late RunningState runningState;
  bool isPre = true;
  late final String coreSHA256;
  late final PackageInfo packageInfo;
  Function? updateCurrentDelayDebounce;
  late Measure measure;
  late CommonTheme theme;
  late Color accentColor;
  CorePalette? corePalette;
  DateTime? startTime;
  UpdateTasks tasks = [];
  AppController? _appController;
  bool isInit = false;
  bool isUserDisconnected = false;
  bool isService = false;
  SetupState? lastSetupState;
  VpnState? lastVpnState;

  bool get isStart => startTime != null && startTime!.isBeforeNow;

  AppController get appController => _appController!;

  set appController(AppController appController) {
    _appController = appController;
    isInit = true;
  }

  GlobalState._internal();

  factory GlobalState() {
    _instance ??= GlobalState._internal();
    return _instance!;
  }

  Future<void> initApp(int version) async {
    coreSHA256 = const String.fromEnvironment('CORE_SHA256');
    isPre = const String.fromEnvironment('APP_ENV') != 'stable';
    appState = AppState(
      brightness: WidgetsBinding.instance.platformDispatcher.platformBrightness,
      version: version,
      viewSize: Size.zero,
      requests: FixedList(maxLength),
      logs: FixedList(maxLength),
      traffics: FixedList(30),
      totalTraffic: Traffic(),
      systemUiOverlayStyle: const SystemUiOverlayStyle(),
    );
    await _initDynamicColor();
    await init();
    await window?.init(version, config.windowProps);
    _shakingStore();
  }

  Future<void> _initDynamicColor() async {
    try {
      corePalette = await DynamicColorPlugin.getCorePalette();
      accentColor =
          await DynamicColorPlugin.getAccentColor() ??
          Color(defaultPrimaryColor);
    } catch (_) {}
  }

  List<Profile> get profiles {
    return runningState.profiles;
  }

  Profile? get currentProfile {
    final profileId = config.currentProfileId;
    return runningState.profiles.getProfile(profileId);
  }

  List<Script> get scripts {
    return runningState.scripts;
  }

  List<Rule> get rules {
    return runningState.rules;
  }

  Future<void> _shakingStore() async {
    final profileIds = runningState.profiles.map((item) => item.id).toList();
    final scriptIds = runningState.scripts.map((item) => item.id).toList();

    final pathsToDelete = await shakingProfileTask(
      VM2(a: profileIds, b: scriptIds),
    );
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

  Future<void> init() async {
    packageInfo = await PackageInfo.fromPlatform();
    isar = await openIsar();
    final configMap = await preferences.getConfigMap();
    final migrationData = await migration.migrationIfNeeded(configMap);
    config = migrationData.configMap != null
        ? Config.fromJson(migrationData.configMap!)
        : Config(themeProps: defaultThemeProps);
    await isar.writeTxn(() async {
      await isar.profileCollections.putAll(
        migrationData.profiles.mapIndexed((index, profile) {
          return ProfileCollection.fromProfile(profile, index);
        }).toList(),
      );
      await isar.scriptCollections.putAll(
        migrationData.scripts.map(ScriptCollection.fromScript).toList(),
      );
      await isar.ruleCollections.putAll(
        migrationData.rules.mapIndexed((index, rule) {
          return RuleCollection.fromRule(rule, index);
        }).toList(),
      );
    });
    final results = await Future.wait([
      isar.profileCollections.where().sortByOrder().findAll(),
      isar.scriptCollections.where().findAll(),
      isar.ruleCollections.where().sortByOrder().findAll(),
    ]);
    final profileCollection = results[0] as List<ProfileCollection>;
    final scriptCollection = results[1] as List<ScriptCollection>;
    final ruleCollections = results[2] as List<RuleCollection>;
    final profiles = profileCollection.map((item) => item.toProfile());
    final scripts = scriptCollection.map((item) => item.toScript());
    final rules = ruleCollections.map((item) => item.toRule());
    runningState = RunningState(
      profiles: profiles.toList(),
      rules: rules.toList(),
      scripts: scripts.toList(),
    );
    await AppLocalizations.load(
      utils.getLocaleForString(config.appSettingProps.locale) ??
          WidgetsBinding.instance.platformDispatcher.locale,
    );
  }

  Future<List<Script>> oldScriptsToScripts(List<OldScript> oldScripts) async {
    final List<Script> scripts = [];
    for (final oldScript in oldScripts) {
      final path = await appPath.getScriptPath(oldScript.id);
      final file = File(path);
      if (!await file.exists()) {
        await file.create(recursive: true);
        await file.writeAsString(oldScript.content);
        scripts.add(
          Script(
            id: snowflake.id,
            label: oldScript.label,
            lastUpdateTime: DateTime.now(),
          ),
        );
      }
    }
    return scripts;
  }

  Future<Isar> openIsar({String? directory, String? name}) async {
    return await Isar.open(
      [ProfileCollectionSchema, ScriptCollectionSchema, RuleCollectionSchema],
      directory: directory ?? await appPath.homeDirPath,
      name: name ?? 'db',
    );
  }

  String get ua => config.patchClashConfig.globalUa ?? packageInfo.ua;

  Future<void> startUpdateTasks([UpdateTasks? tasks]) async {
    if (timer != null && timer!.isActive == true) return;
    if (tasks != null) {
      this.tasks = tasks;
    }
    if (this.tasks.isEmpty) {
      return;
    }
    await executorUpdateTask();
    timer = Timer(const Duration(seconds: 1), () async {
      startUpdateTasks();
    });
  }

  Future<void> executorUpdateTask() async {
    for (final task in tasks) {
      await task();
    }
    timer = null;
  }

  void stopUpdateTasks() {
    if (timer == null || timer?.isActive == false) return;
    timer?.cancel();
    timer = null;
  }

  Future<void> handleStart([UpdateTasks? tasks]) async {
    startTime ??= DateTime.now();
    await coreController.startListener();
    await service?.start();
    startUpdateTasks(tasks);
  }

  Future updateStartTime() async {
    startTime = await service?.getRunTime();
  }

  Future<void> savePreferences() async {
    commonPrint.log('save preferences');
    await preferences.saveConfig(config);
  }

  Future handleStop() async {
    startTime = null;
    await coreController.stopListener();
    await service?.stop();
    stopUpdateTasks();
  }

  Future<bool?> showMessage({
    required InlineSpan message,
    BuildContext? context,
    String? title,
    String? confirmText,
    String? cancelText,
    bool cancelable = true,
    bool? dismissible,
  }) async {
    return await showCommonDialog<bool>(
      context: context,
      dismissible: dismissible,
      child: Builder(
        builder: (context) {
          return CommonDialog(
            title: title ?? appLocalizations.tip,
            actions: [
              if (cancelable)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(cancelText ?? appLocalizations.cancel),
                ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text(confirmText ?? appLocalizations.confirm),
              ),
            ],
            child: Container(
              width: 300,
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: SelectableText.rich(
                  TextSpan(
                    style: Theme.of(context).textTheme.labelLarge,
                    children: [message],
                  ),
                  style: const TextStyle(overflow: TextOverflow.visible),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  VpnOptions getVpnOptions() {
    final vpnProps = config.vpnProps;
    final networkProps = config.networkProps;
    final port = config.patchClashConfig.mixedPort;
    return VpnOptions(
      stack: config.patchClashConfig.tun.stack.name,
      enable: vpnProps.enable,
      systemProxy: vpnProps.systemProxy,
      port: port,
      ipv6: vpnProps.ipv6,
      dnsHijacking: vpnProps.dnsHijacking,
      accessControlProps: vpnProps.accessControlProps,
      allowBypass: vpnProps.allowBypass,
      bypassDomain: networkProps.bypassDomain,
    );
  }

  Future<T?> showCommonDialog<T>({
    required Widget child,
    BuildContext? context,
    bool? dismissible,
    bool filter = true,
  }) async {
    return await showModal<T>(
      useRootNavigator: false,
      context: context ?? globalState.navigatorKey.currentContext!,
      configuration: FadeScaleTransitionConfiguration(
        barrierColor: Colors.black38,
        barrierDismissible: dismissible ?? true,
      ),
      builder: (_) => child,
      filter: filter ? commonFilter : null,
    );
  }

  void showNotifier(String text, {MessageActionState? actionState}) {
    if (text.isEmpty) {
      return;
    }
    navigatorKey.currentContext?.showNotifier(text, actionState: actionState);
  }

  Future<void> openUrl(String url) async {
    final res = await showMessage(
      message: TextSpan(text: url),
      title: appLocalizations.externalLink,
      confirmText: appLocalizations.go,
    );
    if (res != true) {
      return;
    }
    launchUrl(Uri.parse(url));
  }

  Future<SetupParams> getSetupParams() async {
    final params = SetupParams(
      selectedMap: currentProfile?.selectedMap ?? {},
      testUrl: config.appSettingProps.testUrl,
    );
    return params;
  }

  Future<Map> getProfileMap(int profileId) async {
    var res = {};
    try {
      final setupState = globalState.getSetupState(profileId);
      res = await makeRealProfile(
        setupState: setupState,
        patchConfig: config.patchClashConfig,
      );
    } catch (e) {
      globalState.showNotifier(e.toString());
      res = {};
    }
    return res;
  }

  AndroidState getAndroidState() {
    return AndroidState(
      currentProfileName: currentProfile?.label ?? '',
      onlyStatisticsProxy: config.appSettingProps.onlyStatisticsProxy,
      stopText: appLocalizations.stop,
      crashlytics: config.appSettingProps.crashlytics,
    );
  }

  String getSelectedProxyName(String groupName) {
    final group = appState.groups.getGroup(groupName);
    final proxyName = currentProfile?.selectedMap[groupName];
    return group?.getCurrentSelectedName(proxyName ?? '') ?? '';
  }

  Future<String> setupProfile({
    required SetupState setupState,
    required ClashConfig patchConfig,
    VoidCallback? preloadInvoke,
  }) async {
    final config = await makeRealProfile(
      setupState: setupState,
      patchConfig: patchConfig,
    );
    final configFilePath = await appPath.configFilePath;
    final res = await encodeYamlTask(config);
    final file = File(configFilePath);
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    await file.writeAsString(res);
    final params = await globalState.getSetupParams();
    return await coreController.setupConfig(
      params: params,
      setupState: setupState,
      preloadInvoke: preloadInvoke,
    );
  }

  Future<String> backup() async {
    final configMap = config.toJson();
    configMap['version'] = await preferences.getVersion();
    return await backupTask(config.toJson());
  }

  Future<Map<String, dynamic>> makeRealProfile({
    required SetupState setupState,
    required ClashConfig patchConfig,
  }) async {
    final profileId = setupState.profileId;
    if (profileId == null) {
      return {};
    }
    final configMap = await getProfileConfig(profileId);
    String? scriptContent;
    final List<Rule> addedRules = [];
    if (setupState.overwriteType == OverwriteType.script) {
      final scriptId = setupState.scriptId;
      scriptContent = await scripts.get(scriptId)?.content;
    } else {
      addedRules.addAll(setupState.addedRules);
    }
    final defaultUA = packageInfo.ua;
    final appendSystemDns = config.networkProps.appendSystemDns;
    final realPatchConfig = patchConfig.copyWith(
      tun: patchConfig.tun.getRealTun(config.networkProps.routeMode),
    );
    final overrideDns = globalState.config.overrideDns;
    Map<String, dynamic> rawConfig = configMap;
    if (scriptContent?.isNotEmpty == true) {
      rawConfig = await handleEvaluate(scriptContent!, rawConfig);
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

  Future<Map<String, dynamic>> handleEvaluate(
    String scriptContent,
    Map<String, dynamic> config,
  ) async {
    if (config['proxy-providers'] == null) {
      config['proxy-providers'] = {};
    }
    final configJs = json.encode(config);
    final runtime = getJavascriptRuntime();
    final res = await runtime.evaluateAsync('''
      $scriptContent
      main($configJs)
    ''');
    if (res.isError) {
      throw res.stringResult;
    }
    final value = switch (res.rawResult is ffi.Pointer) {
      true => runtime.convertValue<Map<String, dynamic>>(res),
      false => Map<String, dynamic>.from(res.rawResult),
    };
    return value ?? config;
  }

  SetupState getSetupState(int? profileId) {
    final profile = profiles.getProfile(profileId);
    final profileState = VM3(
      a: profile?.id,
      b: profile?.lastUpdateDate,
      c: profile?.overwrite,
    );
    final overwrite = profileState.c;
    final scriptId = overwrite?.scriptOverwrite.scriptId;
    final standardOverwrite =
        overwrite?.standardOverwrite ?? StandardOverwrite();
    final mRules = rules;
    final globalAddedRules = mRules.where(
      (item) => !standardOverwrite.disabledRuleIds.contains(item.id),
    );
    final addedRules = [...standardOverwrite.addedRules, ...globalAddedRules];
    return SetupState(
      profileId: profileId,
      profileLastUpdateDate: profile?.lastUpdateDate?.millisecondsSinceEpoch,
      overwriteType: profile?.overwrite.type ?? OverwriteType.standard,
      addedRules: addedRules,
      scriptId: scriptId,
      scriptLastUpdateTime: scripts.get(scriptId)?.lastUpdateTime,
      overrideDns: config.overrideDns,
      dns: config.patchClashConfig.dns,
    );
  }

  Future<Map<String, dynamic>> getProfileConfig(int profileId) async {
    final configMap = await coreController.getConfig(profileId);
    configMap['rules'] = configMap['rule'];
    configMap.remove('rule');
    return configMap;
  }
}

final globalState = GlobalState();

class DetectionState {
  static DetectionState? _instance;
  bool? _preIsStart;
  Timer? _setTimeoutTimer;
  CancelToken? cancelToken;

  final state = ValueNotifier<NetworkDetectionState>(
    const NetworkDetectionState(isLoading: true, ipInfo: null),
  );

  DetectionState._internal();

  factory DetectionState() {
    _instance ??= DetectionState._internal();
    return _instance!;
  }

  void startCheck() {
    debouncer.call(
      FunctionTag.checkIp,
      _checkIp,
      duration: Duration(milliseconds: 1200),
    );
  }

  void tryStartCheck() {
    if (state.value.isLoading == false && state.value.ipInfo == null) {
      startCheck();
    }
  }

  Future<void> _checkIp() async {
    final appState = globalState.appState;
    final isInit = appState.isInit;
    if (!isInit) return;
    final isStart = appState.runTime != null;
    if (_preIsStart == false &&
        _preIsStart == isStart &&
        state.value.ipInfo != null) {
      return;
    }
    _clearSetTimeoutTimer();
    state.value = state.value.copyWith(isLoading: true, ipInfo: null);
    _preIsStart = isStart;
    if (cancelToken != null) {
      cancelToken!.cancel();
      cancelToken = null;
    }
    cancelToken = CancelToken();
    final res = await request.checkIp(cancelToken: cancelToken);
    if (res.isError) {
      state.value = state.value.copyWith(isLoading: true, ipInfo: null);
      return;
    }
    final ipInfo = res.data;
    if (ipInfo != null) {
      state.value = state.value.copyWith(isLoading: false, ipInfo: ipInfo);
      return;
    }
    _clearSetTimeoutTimer();
    _setTimeoutTimer = Timer(const Duration(milliseconds: 300), () {
      state.value = state.value.copyWith(isLoading: false, ipInfo: null);
    });
  }

  void _clearSetTimeoutTimer() {
    if (_setTimeoutTimer != null) {
      _setTimeoutTimer?.cancel();
      _setTimeoutTimer = null;
    }
  }
}

final detectionState = DetectionState();
