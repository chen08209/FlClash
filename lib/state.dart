import 'dart:async';
import 'dart:convert';
import 'dart:ffi' show Pointer;

import 'package:animations/animations.dart';
import 'package:dio/dio.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/common/theme.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/plugins/service.dart';
import 'package:fl_clash/widgets/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:material_color_utilities/palettes/core_palette.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'common/common.dart';
import 'controller.dart';
import 'models/models.dart';

typedef UpdateTasks = List<FutureOr Function()>;

class GlobalState {
  static GlobalState? _instance;
  Map<CacheTag, FixedMap<String, double>> computeHeightMapCache = {};

  // Map<CacheTag, double> computeScrollPositionCache = {};
  // final Map<String, double> scrollPositionCache = {};
  bool isService = false;
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

  // GlobalKey<CommonScaffoldState> homeScaffoldKey = GlobalKey();
  bool isInit = false;

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
  }

  Future<void> _initDynamicColor() async {
    try {
      corePalette = await DynamicColorPlugin.getCorePalette();
      accentColor = await DynamicColorPlugin.getAccentColor() ??
          Color(defaultPrimaryColor);
    } catch (_) {}
  }

  Future<void> init() async {
    packageInfo = await PackageInfo.fromPlatform();
    config = await preferences.getConfig() ??
        Config(
          themeProps: defaultThemeProps,
        );
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
    await clashCore.startListener();
    await service?.startVpn();
    startUpdateTasks(tasks);
  }

  Future updateStartTime() async {
    startTime = await clashLib?.getRunTime();
  }

  Future handleStop() async {
    startTime = null;
    await clashCore.stopListener();
    await service?.stopVpn();
    stopUpdateTasks();
  }

  Future<bool?> showMessage({
    String? title,
    required InlineSpan message,
    String? confirmText,
    bool cancelable = true,
  }) async {
    return await showCommonDialog<bool>(
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
                  child: Text(appLocalizations.cancel),
                ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text(confirmText ?? appLocalizations.confirm),
              )
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
                  style: const TextStyle(
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Future<Map<String, dynamic>> getProfileMap(String id) async {
  //   final profilePath = await appPath.getProfilePath(id);
  //   final res = await Isolate.run<Result<dynamic>>(() async {
  //     try {
  //       final file = File(profilePath);
  //       if (!await file.exists()) {
  //         return Result.error("");
  //       }
  //       final value = await file.readAsString();
  //       return Result.success(utils.convertYamlNode(loadYaml(value)));
  //     } catch (e) {
  //       return Result.error(e.toString());
  //     }
  //   });
  //   if (res.isSuccess) {
  //     return res.data as Map<String, dynamic>;
  //   } else {
  //     throw res.message;
  //   }
  // }

  Future<T?> showCommonDialog<T>({
    required Widget child,
    bool dismissible = true,
  }) async {
    return await showModal<T>(
      context: navigatorKey.currentState!.context,
      configuration: FadeScaleTransitionConfiguration(
        barrierColor: Colors.black38,
        barrierDismissible: dismissible,
      ),
      builder: (_) => child,
      filter: commonFilter,
    );
  }

  void showNotifier(String text) {
    if (text.isEmpty) {
      return;
    }
    navigatorKey.currentContext?.showNotifier(text);
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
      config = config.copyWith(
        patchClashConfig: clashConfig,
      );
      preferences.clearClashConfig();
      preferences.saveConfig(config);
    }
  }

  CoreState getCoreState() {
    final currentProfile = config.currentProfile;
    return CoreState(
      vpnProps: config.vpnProps,
      onlyStatisticsProxy: config.appSetting.onlyStatisticsProxy,
      currentProfileName: currentProfile?.label ?? currentProfile?.id ?? '',
      bypassDomain: config.networkProps.bypassDomain,
    );
  }

  Future<SetupParams> getSetupParams({
    required ClashConfig pathConfig,
  }) async {
    final clashConfig = await patchRawConfig(
      patchConfig: pathConfig,
    );
    final params = SetupParams(
      config: clashConfig,
      selectedMap: config.currentProfile?.selectedMap ?? {},
      testUrl: config.appSetting.testUrl,
    );
    return params;
  }

  Future<Map<String, dynamic>> patchRawConfig({
    required ClashConfig patchConfig,
  }) async {
    final profile = config.currentProfile;
    if (profile == null) {
      return {};
    }
    final profileId = profile.id;
    final configMap = await getProfileConfig(profileId);
    final rawConfig = await handleEvaluate(configMap);
    final realPatchConfig = patchConfig.copyWith(
      tun: patchConfig.tun.getRealTun(config.networkProps.routeMode),
    );
    rawConfig['external-controller'] = realPatchConfig.externalController.value;
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
          proxyProvider['path'] = await appPath.getProvidersFilePath(
            profile.id,
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
          ruleProvider['path'] = await appPath.getProvidersFilePath(
            profile.id,
            'rules',
            ruleProvider['url'],
          );
        }
      }
    }

    rawConfig['profile']['store-selected'] = false;
    rawConfig['geox-url'] = realPatchConfig.geoXUrl.toJson();
    rawConfig['global-ua'] = realPatchConfig.globalUa;
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
    final overrideDns = globalState.config.overrideDns;
    if (overrideDns || !isEnableDns) {
      final dns = switch (!isEnableDns) {
        true => realPatchConfig.dns.copyWith(
            nameserver: [...realPatchConfig.dns.nameserver, 'system://']),
        false => realPatchConfig.dns,
      };
      rawConfig['dns'] = dns.toJson();
      rawConfig['dns']['nameserver-policy'] = {};
      for (final entry in dns.nameserverPolicy.entries) {
        rawConfig['dns']['nameserver-policy'][entry.key] =
            entry.value.splitByMultipleSeparators;
      }
    }
    var rules = [];
    if (rawConfig['rules'] != null) {
      rules = rawConfig['rules'];
    }
    rawConfig.remove('rules');

    final overrideData = profile.overrideData;
    if (overrideData.enable && config.scriptProps.currentScript == null) {
      if (overrideData.rule.type == OverrideRuleType.override) {
        rules = overrideData.runningRule;
      } else {
        rules = [...overrideData.runningRule, ...rules];
      }
    }
    rawConfig['rule'] = rules;
    return rawConfig;
  }

  Future<Map<String, dynamic>> getProfileConfig(String profileId) async {
    final configMap = await switch (clashLibHandler != null) {
      true => clashLibHandler!.getConfig(profileId),
      false => clashCore.getConfig(profileId),
    };
    configMap['rules'] = configMap['rule'];
    configMap.remove('rule');
    return configMap;
  }

  Future<Map<String, dynamic>> handleEvaluate(
    Map<String, dynamic> config,
  ) async {
    final currentScript = globalState.config.scriptProps.currentScript;
    if (currentScript == null) {
      return config;
    }
    if (config['proxy-providers'] == null) {
      config['proxy-providers'] = {};
    }
    final configJs = json.encode(config);
    final runtime = getJavascriptRuntime();
    final res = await runtime.evaluateAsync('''
      ${currentScript.content}
      main($configJs)
    ''');
    if (res.isError) {
      throw res.stringResult;
    }
    final value = switch (res.rawResult is Pointer) {
      true => runtime.convertValue<Map<String, dynamic>>(res),
      false => Map<String, dynamic>.from(res.rawResult),
    };
    return value ?? config;
  }
}

final globalState = GlobalState();

class DetectionState {
  static DetectionState? _instance;
  bool? _preIsStart;
  Timer? _setTimeoutTimer;
  CancelToken? cancelToken;

  final state = ValueNotifier<NetworkDetectionState>(
    const NetworkDetectionState(
      isLoading: true,
      ipInfo: null,
    ),
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
      duration: Duration(
        milliseconds: 1200,
      ),
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
    state.value = state.value.copyWith(
      isLoading: true,
      ipInfo: null,
    );
    _preIsStart = isStart;
    if (cancelToken != null) {
      cancelToken!.cancel();
      cancelToken = null;
    }
    cancelToken = CancelToken();
    final res = await request.checkIp(cancelToken: cancelToken);
    if (res.isError) {
      state.value = state.value.copyWith(
        isLoading: true,
        ipInfo: null,
      );
      return;
    }
    final ipInfo = res.data;
    if (ipInfo != null) {
      state.value = state.value.copyWith(
        isLoading: false,
        ipInfo: ipInfo,
      );
      return;
    }
    _clearSetTimeoutTimer();
    _setTimeoutTimer = Timer(const Duration(milliseconds: 300), () {
      state.value = state.value.copyWith(
        isLoading: false,
        ipInfo: null,
      );
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
