import 'dart:async';
import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:isolate';

import 'package:animations/animations.dart';
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
import 'package:material_color_utilities/palettes/core_palette.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher.dart';

import 'common/common.dart';
import 'controller.dart';
import 'models/models.dart';

typedef UpdateTasks = List<FutureOr Function()>;

class GlobalState {
  static GlobalState? _instance;
  Map<CacheTag, FixedMap<String, double>> computeHeightMapCache = {};
  Timer? timer;
  Timer? groupsUpdateTimer;
  late Config config;
  late AppState appState;
  bool isPre = true;
  String? coreSHA256;
  late PackageInfo packageInfo;
  Function? updateCurrentDelayDebounce;
  late Measure measure;
  late CommonTheme theme;
  late Color accentColor;
  CorePalette? corePalette;
  DateTime? startTime;
  UpdateTasks tasks = [];
  final navigatorKey = GlobalKey<NavigatorState>();
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
    await window?.init(version);
    _shakingStore();
  }

  Future<void> _shakingStore() async {
    final profileIds = config.profiles.map((item) => item.id);
    final providersRootPath = await appPath.getProvidersRootPath();
    final profilesRootPath = await appPath.profilesPath;
    final entities = await Isolate.run<List<FileSystemEntity>>(() async {
      final profilesDir = Directory(profilesRootPath);
      final providersDir = Directory(providersRootPath);
      final List<FileSystemEntity> entities = [];
      if (await profilesDir.exists()) {
        entities.addAll(
          profilesDir.listSync().where(
            (item) => !item.path.contains('providers'),
          ),
        );
      }
      if (await providersDir.exists()) {
        entities.addAll(providersDir.listSync());
      }
      return entities;
    });
    final deleteFutures = entities.map((entity) async {
      if (!profileIds.contains(basenameWithoutExtension(entity.path))) {
        final res = await coreController.deleteFile(entity.path);
        if (res.isNotEmpty) {
          throw res;
        }
      }
      return true;
    });
    await Future.wait(deleteFutures);
  }

  Future<void> _initDynamicColor() async {
    try {
      corePalette = await DynamicColorPlugin.getCorePalette();
      accentColor =
          await DynamicColorPlugin.getAccentColor() ??
          Color(defaultPrimaryColor);
    } catch (_) {}
  }

  Future<void> init() async {
    packageInfo = await PackageInfo.fromPlatform();
    config =
        await preferences.getConfig() ?? Config(themeProps: defaultThemeProps);
    await globalState.migrateOldData(config);
    await AppLocalizations.load(
      utils.getLocaleForString(config.appSetting.locale) ??
          WidgetsBinding.instance.platformDispatcher.locale,
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
      accessControl: vpnProps.accessControl,
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

  Future<void> migrateOldData(Config config) async {
    final clashConfig = await preferences.getClashConfig();
    if (clashConfig != null) {
      config = config.copyWith(patchClashConfig: clashConfig);
      preferences.clearClashConfig();
      preferences.saveConfig(config);
    }
  }

  Future<SetupParams> getSetupParams() async {
    final params = SetupParams(
      selectedMap: config.currentProfile?.selectedMap ?? {},
      testUrl: config.appSetting.testUrl,
    );
    return params;
  }

  Future<Map> getConfigMap(String profileId) async {
    var res = {};
    try {
      final setupState = globalState.getSetupState(profileId);
      res = await makeRealConfig(
        setupState: setupState,
        patchConfig: config.patchClashConfig,
      );
    } catch (e) {
      globalState.showNotifier(e.toString());
      res = {};
    }
    return res;
  }

  Future<void> genValidateFile(String path, String data) async {
    final res = await Isolate.run<String>(() async {
      try {
        final file = File(path);
        if (!await file.exists()) {
          await file.create(recursive: true);
        }
        await file.writeAsString(data);
        return '';
      } catch (e) {
        return e.toString();
      }
    });
    if (res.isNotEmpty) {
      throw res;
    }
  }

  Future<void> genValidateFileFormBytes(String path, Uint8List bytes) async {
    final res = await Isolate.run<String>(() async {
      try {
        final file = File(path);
        if (!await file.exists()) {
          await file.create(recursive: true);
        }
        await file.writeAsBytes(bytes);
        return '';
      } catch (e) {
        return e.toString();
      }
    });
    if (res.isNotEmpty) {
      throw res;
    }
  }

  AndroidState getAndroidState() {
    return AndroidState(
      currentProfileName: config.currentProfile?.label ?? '',
      onlyStatisticsProxy: config.appSetting.onlyStatisticsProxy,
      stopText: appLocalizations.stop,
      crashlytics: config.appSetting.crashlytics,
    );
  }

  String getSelectedProxyName(String groupName) {
    final group = appState.groups.getGroup(groupName);
    final proxyName = config.currentProfile?.selectedMap[groupName];
    return group?.getCurrentSelectedName(proxyName ?? '') ?? '';
  }

  Future<String> setupConfig({
    required SetupState setupState,
    required ClashConfig patchConfig,
    VoidCallback? preloadInvoke,
  }) async {
    final config = await makeRealConfig(
      setupState: setupState,
      patchConfig: patchConfig,
    );
    final configFilePath = await appPath.configFilePath;
    final res = await Isolate.run<String>(() async {
      try {
        final res = yaml.encode(config);
        final file = File(configFilePath);
        if (!await file.exists()) {
          await file.create(recursive: true);
        }
        await file.writeAsString(res);
        return '';
      } catch (e) {
        return e.toString();
      }
    });
    if (res.isNotEmpty) {
      throw res;
    }
    final params = await globalState.getSetupParams();
    return await coreController.setupConfig(
      params: params,
      setupState: setupState,
      preloadInvoke: preloadInvoke,
    );
  }

  Future<Map<String, dynamic>> makeRealConfig({
    required SetupState setupState,
    required ClashConfig patchConfig,
  }) async {
    final profileId = setupState.profileId;
    if (profileId?.isNotEmpty != true) {
      return {};
    }
    final configMap = await getProfileConfig(profileId!);
    String? scriptContent;
    final List<Rule> addedRules = [];
    if (setupState.overwriteType == OverwriteType.script) {
      scriptContent = setupState.scriptContent;
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
    String getProvidersFilePathInner(String type, String url) {
      return join(directory, 'providers', profileId, type, url.toMd5());
    }

    final res = await Isolate.run<Map<String, dynamic>>(() async {
      rawConfig['external-controller'] =
          realPatchConfig.externalController.value;
      rawConfig['external-ui'] = '';
      rawConfig['interface-name'] = '';
      rawConfig['external-ui-url'] = '';
      rawConfig['tcp-concurrent'] = realPatchConfig.tcpConcurrent;
      rawConfig['unified-delay'] = realPatchConfig.unifiedDelay;
      rawConfig['ipv6'] = realPatchConfig.ipv6;
      rawConfig['log-level'] = realPatchConfig.logLevel.name;
      rawConfig['port'] = 0;
      rawConfig['socks-port'] = 0;
      rawConfig['keep-alive-interval'] = realPatchConfig.keepAliveInterval;
      rawConfig['mixed-port'] = realPatchConfig.mixedPort;
      rawConfig['port'] = realPatchConfig.port;
      rawConfig['socks-port'] = realPatchConfig.socksPort;
      rawConfig['redir-port'] = realPatchConfig.redirPort;
      rawConfig['tproxy-port'] = realPatchConfig.tproxyPort;
      rawConfig['find-process-mode'] = realPatchConfig.findProcessMode.name;
      rawConfig['allow-lan'] = realPatchConfig.allowLan;
      rawConfig['mode'] = realPatchConfig.mode.name;
      if (rawConfig['tun'] == null) {
        rawConfig['tun'] = {};
      }
      rawConfig['tun']['enable'] = realPatchConfig.tun.enable;
      rawConfig['tun']['device'] = realPatchConfig.tun.device;
      rawConfig['tun']['dns-hijack'] = realPatchConfig.tun.dnsHijack;
      rawConfig['tun']['stack'] = realPatchConfig.tun.stack.name;
      rawConfig['tun']['route-address'] = realPatchConfig.tun.routeAddress;
      rawConfig['tun']['auto-route'] = realPatchConfig.tun.autoRoute;
      rawConfig['geodata-loader'] = realPatchConfig.geodataLoader.name;
      if (rawConfig['sniffer']?['sniff'] != null) {
        for (final value in (rawConfig['sniffer']?['sniff'] as Map).values) {
          if (value['ports'] != null && value['ports'] is List) {
            value['ports'] =
                value['ports']?.map((item) => item.toString()).toList() ?? [];
          }
        }
      }
      if (rawConfig['profile'] == null) {
        rawConfig['profile'] = {};
      }
      if (rawConfig['proxy-providers'] != null) {
        final proxyProviders = rawConfig['proxy-providers'] as Map;
        for (final key in proxyProviders.keys) {
          final proxyProvider = proxyProviders[key];
          if (proxyProvider['type'] != 'http') {
            continue;
          }
          if (proxyProvider['url'] != null) {
            proxyProvider['path'] = getProvidersFilePathInner(
              'proxies',
              proxyProvider['url'],
            );
          }
        }
      }
      if (rawConfig['rule-providers'] != null) {
        final ruleProviders = rawConfig['rule-providers'] as Map;
        for (final key in ruleProviders.keys) {
          final ruleProvider = ruleProviders[key];
          if (ruleProvider['type'] != 'http') {
            continue;
          }
          if (ruleProvider['url'] != null) {
            ruleProvider['path'] = getProvidersFilePathInner(
              'rules',
              ruleProvider['url'],
            );
          }
        }
      }
      rawConfig['profile']['store-selected'] = false;
      rawConfig['geox-url'] = realPatchConfig.geoXUrl.toJson();
      rawConfig['global-ua'] = realPatchConfig.globalUa ?? defaultUA;
      if (rawConfig['hosts'] == null) {
        rawConfig['hosts'] = {};
      }
      for (final host in realPatchConfig.hosts.entries) {
        rawConfig['hosts'][host.key] = host.value.splitByMultipleSeparators;
      }
      if (rawConfig['dns'] == null) {
        rawConfig['dns'] = {};
      }
      final isEnableDns = rawConfig['dns']['enable'] == true;
      final systemDns = 'system://';
      if (overrideDns || !isEnableDns) {
        final dns = switch (!isEnableDns) {
          true => realPatchConfig.dns.copyWith(
            nameserver: [...realPatchConfig.dns.nameserver, systemDns],
          ),
          false => realPatchConfig.dns,
        };
        rawConfig['dns'] = dns.toJson();
        rawConfig['dns']['nameserver-policy'] = {};
        for (final entry in dns.nameserverPolicy.entries) {
          rawConfig['dns']['nameserver-policy'][entry.key] =
              entry.value.splitByMultipleSeparators;
        }
      }
      if (appendSystemDns) {
        final List<String> nameserver = List<String>.from(
          rawConfig['dns']['nameserver'] ?? [],
        );
        if (!nameserver.contains(systemDns)) {
          rawConfig['dns']['nameserver'] = [...nameserver, systemDns];
        }
      }
      List<String> rules = [];
      if (rawConfig['rules'] != null) {
        rules = List<String>.from(rawConfig['rules']);
      }
      rawConfig.remove('rules');
      if (addedRules.isNotEmpty) {
        final parsedNewRules = addedRules
            .map((item) => ParsedRule.parseString(item.value))
            .toList();
        final hasMatchPlaceholder = parsedNewRules.any(
          (item) => item.ruleTarget?.toUpperCase() == 'MATCH',
        );
        String? replacementTarget;

        if (hasMatchPlaceholder) {
          for (int i = rules.length - 1; i >= 0; i--) {
            final parsed = ParsedRule.parseString(rules[i]);
            if (parsed.ruleAction == RuleAction.MATCH) {
              final target = parsed.ruleTarget;
              if (target != null && target.isNotEmpty) {
                replacementTarget = target;
                break;
              }
            }
          }
        }
        final List<String> finalAddedRules;

        if (replacementTarget?.isNotEmpty == true) {
          finalAddedRules = [];
          for (int i = 0; i < parsedNewRules.length; i++) {
            final parsed = parsedNewRules[i];
            if (parsed.ruleTarget?.toUpperCase() == 'MATCH') {
              finalAddedRules.add(
                parsed.copyWith(ruleTarget: replacementTarget).value,
              );
            } else {
              finalAddedRules.add(addedRules[i].value);
            }
          }
        } else {
          finalAddedRules = addedRules.map((e) => e.value).toList();
        }
        rules = [...finalAddedRules, ...rules];
      }
      rawConfig['rules'] = rules;
      return rawConfig;
    });
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

  SetupState getSetupState(String? profileId) {
    final profile = config.profiles.getProfile(profileId);
    final profileState = VM3(
      a: profile?.id,
      b: profile?.lastUpdateDate,
      c: profile?.overwrite,
    );
    final overwrite = profileState.c;
    final scriptContent = config.scripts
        .get(overwrite?.scriptOverwrite.scriptId)
        ?.content;
    final standardOverwrite =
        overwrite?.standardOverwrite ?? StandardOverwrite();
    final rules = config.rules;
    final globalAddedRules = rules.where(
      (item) => !standardOverwrite.disabledRuleIds.contains(item.id),
    );
    final addedRules = [...standardOverwrite.addedRules, ...globalAddedRules];
    return SetupState(
      profileId: profileId,
      profileLastUpdateDate: profile?.lastUpdateDate?.millisecondsSinceEpoch,
      overwriteType: profile?.overwrite.type ?? OverwriteType.standard,
      addedRules: addedRules,
      scriptContent: scriptContent,
      overrideDns: config.overrideDns,
      dns: config.patchClashConfig.dns,
    );
  }

  Future<Map<String, dynamic>> getProfileConfig(String profileId) async {
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
