import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/free_nodes.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/plugins/service.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/action.g.dart';

@visibleForTesting
Future<int> resolveAvailableMixedPort(int preferredPort) async {
  if (preferredPort <= 0) return preferredPort;
  if (await _canBindTcpPort(preferredPort)) return preferredPort;
  final socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
  final port = socket.port;
  await socket.close();
  return port;
}

@visibleForTesting
bool shouldPersistProfileBeforeRemoteUpdate(Profile profile) {
  return !profile.isFreeNodesProfile;
}

@visibleForTesting
bool shouldCheckFreeNodesAutoUpdateOnProfileSelection({
  required int? currentProfileId,
  required int selectedProfileId,
  required bool isFreeNodesProfile,
  required bool autoUpdate,
}) {
  return currentProfileId != selectedProfileId &&
      isFreeNodesProfile &&
      autoUpdate;
}

Future<bool> _canBindTcpPort(int port) async {
  ServerSocket? socket;
  try {
    socket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    return true;
  } catch (_) {
    return false;
  } finally {
    await socket?.close();
  }
}

class _TcpEndpoint {
  final String host;
  final int port;

  const _TcpEndpoint({required this.host, required this.port});
}

@visibleForTesting
Future<bool> waitForTcpEndpoint(
  String endpoint, {
  Duration timeout = const Duration(milliseconds: 1200),
  Duration interval = const Duration(milliseconds: 80),
}) async {
  final target = _parseTcpEndpoint(endpoint);
  if (target == null) return false;
  final stopwatch = Stopwatch()..start();
  while (stopwatch.elapsed < timeout) {
    Socket? socket;
    try {
      socket = await Socket.connect(
        target.host,
        target.port,
        timeout: interval,
      );
      return true;
    } catch (_) {
      await Future.delayed(interval);
    } finally {
      socket?.destroy();
    }
  }
  return false;
}

_TcpEndpoint? _parseTcpEndpoint(String endpoint) {
  var normalized = endpoint.trim();
  if (normalized.isEmpty) return null;
  if (!normalized.contains('://')) {
    normalized = 'http://$normalized';
  }
  final uri = Uri.tryParse(normalized);
  if (uri == null || uri.host.isEmpty) return null;
  final port = uri.hasPort
      ? uri.port
      : switch (uri.scheme) {
          'https' => 443,
          _ => 80,
        };
  if (port <= 0 || port > 65535) return null;
  return _TcpEndpoint(host: uri.host, port: port);
}

@visibleForTesting
enum FreeNodesAutoUpdateKind { firstFetch, dueSources, checkOnly }

@visibleForTesting
class FreeNodesAutoUpdateDecision {
  final FreeNodesAutoUpdateKind kind;

  const FreeNodesAutoUpdateDecision(this.kind);

  bool get shouldUpdate => kind != FreeNodesAutoUpdateKind.checkOnly;

  bool get shouldFetchAllSources => kind == FreeNodesAutoUpdateKind.firstFetch;

  String get operation {
    return switch (kind) {
      FreeNodesAutoUpdateKind.firstFetch => '正在首次获取节点',
      FreeNodesAutoUpdateKind.dueSources => '正在更新到期来源',
      FreeNodesAutoUpdateKind.checkOnly => '正在检查更新',
    };
  }
}

@visibleForTesting
FreeNodesAutoUpdateDecision resolveFreeNodesAutoUpdateDecision({
  required bool fileExists,
  required bool hasLastUpdateDate,
  required bool hasDueSources,
}) {
  if (!fileExists) {
    return const FreeNodesAutoUpdateDecision(
      FreeNodesAutoUpdateKind.firstFetch,
    );
  }
  if (!hasLastUpdateDate) {
    return const FreeNodesAutoUpdateDecision(
      FreeNodesAutoUpdateKind.firstFetch,
    );
  }
  return FreeNodesAutoUpdateDecision(
    hasDueSources
        ? FreeNodesAutoUpdateKind.dueSources
        : FreeNodesAutoUpdateKind.checkOnly,
  );
}

@visibleForTesting
bool shouldAutoUpdateFreeNodesProfile({
  required bool fileExists,
  required bool hasLastUpdateDate,
  required bool hasDueSources,
}) {
  return resolveFreeNodesAutoUpdateDecision(
    fileExists: fileExists,
    hasLastUpdateDate: hasLastUpdateDate,
    hasDueSources: hasDueSources,
  ).shouldUpdate;
}

@visibleForTesting
bool shouldApplyCurrentFreeNodesProfileAfterNoopAutoUpdate({
  required bool isCurrentProfile,
  required bool shouldUpdate,
  required bool hasLoadedGroups,
}) {
  return isCurrentProfile && !shouldUpdate && !hasLoadedGroups;
}

@visibleForTesting
FreeNodesProgress buildFreeNodesAutoUpdateStartProgress({
  required bool firstLaunch,
  required int proxyCount,
}) {
  return FreeNodesProgress(
    operation: firstLaunch ? '正在首次获取节点' : '正在检查更新',
    proxyCount: proxyCount,
    startedAt: DateTime.now(),
  );
}

@visibleForTesting
FreeNodesProgress buildFreeNodesAutoUpdateRunningProgress({
  required int proxyCount,
  FreeNodesProgress? currentProgress,
  DateTime? startedAt,
  bool preserveTerminalProgress = false,
}) {
  if (preserveTerminalProgress &&
      currentProgress != null &&
      (currentProgress.done || currentProgress.error)) {
    return currentProgress;
  }
  if (currentProgress != null &&
      !currentProgress.done &&
      !currentProgress.error &&
      currentProgress.startedAt != null) {
    return currentProgress.copyWith(
      proxyCount: currentProgress.proxyCount > 0
          ? currentProgress.proxyCount
          : proxyCount,
    );
  }
  return FreeNodesProgress(
    operation: '正在检查更新',
    proxyCount: proxyCount,
    startedAt: startedAt ?? DateTime.now(),
  );
}

@visibleForTesting
FreeNodesProgress buildFreeNodesAutoUpdateNoopProgress({
  required int proxyCount,
  required DateTime startedAt,
  DateTime? finishedAt,
}) {
  return FreeNodesProgress(
    operation: '已检查，无需更新',
    proxyCount: proxyCount,
    done: true,
    startedAt: startedAt,
    finishedAt: finishedAt ?? DateTime.now(),
  );
}

@visibleForTesting
FreeNodesProgress buildFreeNodesAutoUpdateFetchProgress({
  required FreeNodesProgress progress,
  required String runningOperation,
  required DateTime startedAt,
  required int proxyCount,
}) {
  if (progress.done || progress.error) {
    return progress.copyWith(
      proxyCount: progress.proxyCount > 0 ? progress.proxyCount : proxyCount,
      startedAt: startedAt,
      finishedAt: progress.finishedAt ?? DateTime.now(),
    );
  }
  return progress.copyWith(
    operation: runningOperation,
    proxyCount: progress.proxyCount > 0 ? progress.proxyCount : proxyCount,
    startedAt: startedAt,
  );
}

@visibleForTesting
Duration remainingFreeNodesAutoUpdateVisibleDelay({
  required DateTime startedAt,
  DateTime? now,
  Duration minVisibleDuration = const Duration(milliseconds: 1200),
}) {
  final elapsed = (now ?? DateTime.now()).difference(startedAt);
  if (elapsed >= minVisibleDuration) return Duration.zero;
  return minVisibleDuration - elapsed;
}

@visibleForTesting
void sanitizeRealityShortIds(Map<String, dynamic> config) {
  final proxies = config['proxies'];
  if (proxies is! List) return;
  for (final proxy in proxies.whereType<Map>()) {
    final realityOpts = proxy['reality-opts'];
    if (realityOpts is! Map) continue;
    final publicKey = realityOpts['public-key']?.toString();
    if (publicKey != null) {
      final normalizedPublicKey = _normalizeRealityPublicKey(publicKey);
      if (normalizedPublicKey == null) {
        proxy.remove('reality-opts');
        continue;
      }
      realityOpts['public-key'] = normalizedPublicKey;
    }
    final shortId = realityOpts['short-id']?.toString();
    if (shortId == null || _isValidRealityShortId(shortId)) continue;
    realityOpts.remove('short-id');
    if (realityOpts.isEmpty) {
      proxy.remove('reality-opts');
    }
  }
}

String? _normalizeRealityPublicKey(String value) {
  String normalized = value.trim();
  if (normalized.contains('%')) {
    try {
      normalized = Uri.decodeComponent(normalized);
    } catch (_) {}
  }
  try {
    return base64Url.decode(base64Url.normalize(normalized)).length == 32
        ? normalized
        : null;
  } catch (_) {
    return null;
  }
}

bool _isValidRealityShortId(String value) {
  return value.length <= 16 &&
      value.length.isEven &&
      RegExp(r'^[0-9a-fA-F]*$').hasMatch(value);
}

@Riverpod(keepAlive: true)
class CommonAction extends _$CommonAction {
  @override
  void build() {}

  void updateStart() {
    ref
        .read(setupActionProvider.notifier)
        .updateStatus(!ref.read(isStartProvider));
  }

  void updateSpeedStatistics() {
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(showTrayTitle: !state.showTrayTitle));
  }

  void updateMode() {
    ref.read(patchClashConfigProvider.notifier).update((state) {
      final index = Mode.values.indexWhere((item) => item == state.mode);
      if (index == -1) return state;
      final nextIndex = index + 1 > Mode.values.length - 1 ? 0 : index + 1;
      return state.copyWith(mode: Mode.values[nextIndex]);
    });
  }

  void updateRunTime() {
    final startTime = ref.read(setupActionProvider.notifier).startTime;
    if (startTime != null) {
      final startTimeStamp = startTime.millisecondsSinceEpoch;
      final nowTimeStamp = DateTime.now().millisecondsSinceEpoch;
      ref.read(runTimeProvider.notifier).value = nowTimeStamp - startTimeStamp;
    } else {
      ref.read(runTimeProvider.notifier).value = null;
    }
  }

  Future<void> updateTraffic() async {
    final onlyStatisticsProxy = ref.read(
      appSettingProvider.select((state) => state.onlyStatisticsProxy),
    );
    final traffic = await coreController.getTraffic(onlyStatisticsProxy);
    ref.read(trafficsProvider.notifier).addTraffic(traffic);
    ref.read(totalTrafficProvider.notifier).value = await coreController
        .getTotalTraffic(onlyStatisticsProxy);
  }
}

@Riverpod(keepAlive: true)
class SetupAction extends _$SetupAction {
  Timer? _updateTimer;
  DateTime? startTime;
  int? _activeMixedPort;

  bool get isStart => startTime != null && startTime!.isBeforeNow;

  @override
  void build() {}

  SetupParams get _setupParams {
    final selectedMap = ref.read(selectedMapProvider);
    final testUrl = ref.read(
      appSettingProvider.select((state) => state.testUrl),
    );
    return SetupParams(selectedMap: selectedMap, testUrl: testUrl);
  }

  void fullSetup() {
    if (!ref.read(initProvider)) return;
    ref.read(delayDataSourceProvider.notifier).value = {};
    applyProfile(force: true);
    ref.read(logsProvider.notifier).value = FixedList(500);
    ref.read(requestsProvider.notifier).value = FixedList(500);
  }

  Future<void> _handleStart() async {
    final previousStartTime = startTime;
    startTime ??= DateTime.now();
    //The local status must be updated when performing the run task
    ref.read(commonActionProvider.notifier).updateRunTime();
    if (!ref.read(suspendProvider)) {
      final started = await coreController.startListener();
      if (!started) {
        startTime = previousStartTime;
        ref.read(commonActionProvider.notifier).updateRunTime();
        throw '启动代理监听失败';
      }
    }
    unawaited(
      ref
          .read(commonActionProvider.notifier)
          .updateTraffic()
          .catchError(
            (e) => commonPrint.log(
              'update traffic failed: ${e.toString()}',
              logLevel: LogLevel.warning,
            ),
          ),
    );
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      ref.read(commonActionProvider.notifier).updateRunTime();
      ref.read(commonActionProvider.notifier).updateTraffic();
    });
  }

  Future<void> _waitForMixedPortListening() async {
    if (ref.read(suspendProvider)) return;
    final mixedPort = ref.read(
      patchClashConfigProvider.select((state) => state.mixedPort),
    );
    final port = _activeMixedPort ?? mixedPort;
    if (port <= 0) return;
    if (await _isMixedPortListening(port)) return;

    var externalController = ref.read(
      patchClashConfigProvider.select((state) => state.externalController),
    );
    if (externalController == ExternalControllerStatus.close) {
      ref
          .read(patchClashConfigProvider.notifier)
          .update(
            (state) => state.copyWith(
              externalController: ExternalControllerStatus.open,
            ),
          );
      externalController = ExternalControllerStatus.open;
      await updateConfigNow();
    }
    final controllerReady = await waitForTcpEndpoint(
      externalController.value,
      timeout: const Duration(seconds: 2),
      interval: const Duration(milliseconds: 100),
    );
    if (controllerReady &&
        await _patchMixedPortThroughController(
          externalController.value,
          port,
        ) &&
        await _isMixedPortListening(port)) {
      return;
    }

    throw '代理端口 $port 未启动，已取消运行状态';
  }

  Future<bool> _isMixedPortListening(int port) {
    return waitForTcpEndpoint(
      '127.0.0.1:$port',
      timeout: const Duration(seconds: 6),
      interval: const Duration(milliseconds: 120),
    );
  }

  Future<bool> _patchMixedPortThroughController(
    String controller,
    int port,
  ) async {
    if (controller.isEmpty) return false;
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 2);
    try {
      final request = await client
          .patchUrl(Uri.http(controller, '/configs'))
          .timeout(const Duration(seconds: 2));
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode({'mixed-port': port}));
      final response = await request.close().timeout(
        const Duration(seconds: 2),
      );
      await response.drain<void>();
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      commonPrint.log(
        'patch mixed-port through controller failed: ${e.toString()}',
        logLevel: LogLevel.warning,
      );
      return false;
    } finally {
      client.close(force: true);
    }
  }

  Future _updateStartTime() async {
    startTime = await service?.getRunTime();
  }

  Future handleStop() async {
    startTime = null;
    _updateTimer?.cancel();
    _updateTimer = null;
    await coreController.stopListener();
  }

  Future<void> initStatus() async {
    if (!globalState.needInitStatus) {
      commonPrint.log('init status cancel');
      return;
    }
    commonPrint.log('init status');
    if (system.isAndroid) {
      await _updateStartTime();
    }
    final status = isStart == true
        ? true
        : ref.read(appSettingProvider).autoRun;
    if (status == true) {
      await updateStatus(true, isInit: true);
    } else {
      await applyProfile(force: true);
    }
  }

  Future<void> updateStatus(bool isStart, {bool isInit = false}) async {
    if (isStart) {
      if (!isInit) {
        final res = await ref
            .read(coreActionProvider.notifier)
            .tryStartCore(true);
        if (res) {
          await _waitForMixedPortListening();
          return;
        }
        if (!ref.read(initProvider)) return;
        try {
          await _handleStart();
          await applyProfile(force: true, silence: true);
          await updateConfigNow();
          await _waitForMixedPortListening();
        } catch (_) {
          await handleStop();
          rethrow;
        }
      } else {
        globalState.needInitStatus = false;
        ref.read(runTimeProvider.notifier).value = 0;
        try {
          await applyProfile(
            force: true,
            preloadInvoke: () async {
              await _handleStart();
            },
          );
          await updateConfigNow();
          await _waitForMixedPortListening();
        } catch (_) {
          await handleStop();
          ref.read(runTimeProvider.notifier).value = null;
        }
      }
    } else {
      await handleStop();
      coreController.resetTraffic();
      ref.read(trafficsProvider.notifier).clear();
      ref.read(totalTrafficProvider.notifier).value = const Traffic();
      ref.read(runTimeProvider.notifier).value = null;
      ref.read(checkIpNumProvider.notifier).add();
    }
  }

  Future<void> updateConfigDebounce() async {
    debouncer.call(FunctionTag.updateConfig, () async {
      await globalState.safeRun(updateConfigNow);
    });
  }

  UpdateParams _buildUpdateParams() {
    final patchConfig = ref.read(patchClashConfigProvider);
    final routeMode = ref.read(
      networkSettingProvider.select((state) => state.routeMode),
    );
    return UpdateParams(
      tun: patchConfig.tun.getRealTun(routeMode),
      mixedPort: _activeMixedPort ?? patchConfig.mixedPort,
      allowLan: patchConfig.allowLan,
      findProcessMode: patchConfig.findProcessMode,
      mode: patchConfig.mode,
      logLevel: patchConfig.logLevel,
      ipv6: patchConfig.ipv6,
      tcpConcurrent: patchConfig.tcpConcurrent,
      externalController: patchConfig.externalController,
      unifiedDelay: patchConfig.unifiedDelay,
    );
  }

  Future<void> updateConfigNow() async {
    final updateParams = _buildUpdateParams();
    final res = await _requestAdmin(updateParams.tun.enable);
    if (res.isError) return;
    final realTunEnable = ref.read(realTunEnableProvider);
    final message = await coreController.updateConfig(
      updateParams.copyWith.tun(enable: realTunEnable),
    );
    ref.read(checkIpNumProvider.notifier).add();
    if (message.isNotEmpty) throw message;
  }

  void tryCheckIp() {
    final isTimeout = ref.read(
      networkDetectionProvider.select(
        (state) => state.ipInfo == null && state.isLoading == false,
      ),
    );
    if (!isTimeout) return;
    ref.read(checkIpNumProvider.notifier).add();
  }

  void applyProfileDebounce({bool silence = false, bool force = false}) {
    debouncer.call(FunctionTag.applyProfile, (silence, force) {
      applyProfile(silence: silence, force: force);
    }, args: [silence, force]);
  }

  void changeMode(Mode mode) {
    ref
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(mode: mode));
    if (mode == Mode.global) {
      ref
          .read(proxiesActionProvider.notifier)
          .updateCurrentGroupName(GroupName.GLOBAL.name);
    }
  }

  void autoApplyProfile() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      applyProfile();
    });
  }

  Future<void> applyProfile({
    bool silence = false,
    bool force = false,
    FutureOr<void> Function()? preloadInvoke,
  }) async {
    await _setupConfig(
      force: force,
      silence: silence,
      preloadInvoke: preloadInvoke,
      onUpdated: () async {
        await ref
            .read(proxiesActionProvider.notifier)
            .updateGroups(
              maxAttempts: 8,
              delay: const Duration(milliseconds: 700),
            );
        await ref.read(providersProvider.notifier).syncProviders();
      },
    );
  }

  Future<VM2<String, String>> getProfile({
    required SetupState setupState,
    required PatchClashConfig patchConfig,
  }) async {
    final profileId = setupState.profileId;
    if (profileId == null) return const VM2('', '');
    final defaultUA = globalState.packageInfo.ua;
    final networkVM2 = ref.read(
      networkSettingProvider.select(
        (state) => VM2(state.appendSystemDns, state.routeMode),
      ),
    );
    final overrideDns = ref.read(overrideDnsProvider);
    final appendSystemDns = networkVM2.a;
    final routeMode = networkVM2.b;
    final configMap = await coreController.getConfig(profileId);
    String? scriptContent;
    final List<Rule> addedRules = [];
    final List<ProxyGroup> proxyGroups = [];
    final List<Rule> rules = [];
    if (setupState.overwriteType == OverwriteType.script) {
      scriptContent = await setupState.script?.content;
    } else if (setupState.overwriteType == OverwriteType.standard) {
      addedRules.addAll(setupState.addedRules);
    } else {
      proxyGroups.addAll(setupState.proxyGroups);
      rules.addAll(setupState.rules);
    }
    final realPatchConfig = patchConfig.copyWith(
      tun: patchConfig.tun.getRealTun(routeMode),
    );
    Map<String, dynamic> rawConfig = configMap;
    sanitizeRealityShortIds(rawConfig);
    if (scriptContent?.isNotEmpty == true) {
      rawConfig = await handleEvaluate(scriptContent!, rawConfig);
      sanitizeRealityShortIds(rawConfig);
    }
    final directory = await appPath.profilesPath;
    final res = makeRealProfileTask(
      MakeRealProfileState(
        rules: rules,
        proxyGroups: proxyGroups,
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

  Future<String> getProfileWithId(int profileId) async {
    try {
      final setupState = await ref.read(setupStateProvider(profileId).future);
      final patchClashConfig = ref.read(patchClashConfigProvider);
      final res = await getProfile(
        setupState: setupState,
        patchConfig: patchClashConfig,
      );
      return res.a;
    } catch (e) {
      globalState.showNotifier(e.toString());
    }
    return '';
  }

  Future<Result<bool>> _requestAdmin(bool enableTun) async {
    final realTunEnable = ref.read(realTunEnableProvider);
    if (enableTun != realTunEnable && realTunEnable == false) {
      final code = await system.authorizeCore();
      switch (code) {
        case AuthorizeCode.success:
          await ref.read(coreActionProvider.notifier).restartCore();
          return Result.error('');
        case AuthorizeCode.none:
          break;
        case AuthorizeCode.error:
          enableTun = false;
          break;
      }
    }
    ref.read(realTunEnableProvider.notifier).value = enableTun;
    return Result.success(enableTun);
  }

  Future<void> _setupConfig({
    bool force = false,
    bool silence = false,
    FutureOr<void> Function()? preloadInvoke,
    FutureOr Function()? onUpdated,
  }) async {
    var profile = ref.read(currentProfileProvider);
    if (profile == null) {
      final profiles = ref.read(profilesProvider);
      if (profiles.isNotEmpty) {
        profile = profiles.first;
        ref.read(currentProfileIdProvider.notifier).value = profile.id;
      }
    }

    if (profile != null) {
      Profile? nextProfile;
      if (profile.isFreeNodesProfile) {
        final profileFile = File(
          await appPath.getProfilePath(profile.id.toString()),
        );
        if (!await profileFile.exists()) {
          try {
            nextProfile = await freeNodesService.updateProfile(profile);
          } catch (e) {
            commonPrint.log(
              'setup free nodes profile update failed: ${e.toString()}',
              logLevel: LogLevel.warning,
            );
          }
        }
      } else {
        nextProfile = await profile.checkAndUpdateAndCopy();
      }
      if (nextProfile != null) {
        profile = nextProfile;
        ref.read(profilesProvider.notifier).put(nextProfile);
      }
    }

    commonPrint.log('setup ===> ${profile?.id}');
    var patchConfig = ref.read(patchClashConfigProvider);
    if (startTime == null) {
      final availableMixedPort = await resolveAvailableMixedPort(
        patchConfig.mixedPort,
      );
      if (availableMixedPort != patchConfig.mixedPort) {
        commonPrint.log(
          'mixed-port ${patchConfig.mixedPort} is unavailable, '
          'using $availableMixedPort',
          logLevel: LogLevel.warning,
        );
        patchConfig = patchConfig.copyWith(mixedPort: availableMixedPort);
        ref.read(patchClashConfigProvider.notifier).value = patchConfig;
      }
    }
    final res = await _requestAdmin(patchConfig.tun.enable);
    if (res.isError) return;
    final realTunEnable = ref.read(realTunEnableProvider);
    final realPatchConfig = patchConfig.copyWith.tun(enable: realTunEnable);
    _activeMixedPort = realPatchConfig.mixedPort;
    final setupState = await ref.read(setupStateProvider(profile?.id).future);
    if (system.isAndroid) {
      globalState.lastVpnState = ref.read(vpnStateProvider);
      final sharedState = ref.read(sharedStateProvider);
      preferences.saveShareState(sharedState);
    }
    final vm2 = await getProfile(
      setupState: setupState,
      patchConfig: realPatchConfig,
    );
    final yamlString = vm2.a;
    final yamlMd5 = vm2.b;
    if (yamlMd5 == globalState.lastConfigMd5 && force == false) return;
    await globalState.loadingRun(
      () async {
        final configFilePath = await appPath.configFilePath;
        await File(configFilePath).safeWriteAsString(yamlString);
        globalState.lastConfigMd5 = yamlMd5;
        final message = await coreController.setupConfig(
          setupState: setupState,
          params: _setupParams,
          preloadInvoke: preloadInvoke,
        );
        if (message.isNotEmpty && !message.endsWith('is empty')) {
          throw message;
        }
        ref.read(checkIpNumProvider.notifier).add();
        await onUpdated?.call();
      },
      silence: true,
      tag: !silence ? LoadingTag.proxies : null,
    );
  }
}

@Riverpod(keepAlive: true)
class BackupAction extends _$BackupAction {
  @override
  void build() {}

  Future<String> backup() async {
    final res = await Future.wait([
      database.profilesDao.fileNames().get(),
      database.scriptsDao.fileNames().get(),
    ]);
    final profileFileNames = res[0];
    final scriptFileNames = res[1];
    final configMap = ref.read(configProvider).toJson();
    configMap['version'] = await preferences.getVersion();
    return backupTask(configMap, [...profileFileNames, ...scriptFileNames]);
  }

  Future<void> restore(RestoreOption option) async {
    final restoreDirPath = await appPath.restoreDirPath;
    final restoreDir = Directory(restoreDirPath);
    final restoreStrategy = ref.read(
      appSettingProvider.select((state) => state.restoreStrategy),
    );
    final isOverride = restoreStrategy == RestoreStrategy.override;
    try {
      final migrationData = await restoreTask();
      if (!await restoreDir.exists()) {
        throw currentAppLocalizations.restoreException;
      }
      await database.restore(
        migrationData.profiles,
        migrationData.scripts,
        migrationData.rules,
        migrationData.links,
        migrationData.proxyGroups,
        isOverride: isOverride,
      );
      final configMap = migrationData.configMap;
      if (option == RestoreOption.onlyProfiles || configMap == null) return;
      final config = Config.fromJson(configMap);
      ref.read(patchClashConfigProvider.notifier).value =
          config.patchClashConfig;
      ref.read(appSettingProvider.notifier).value = config.appSettingProps;
      ref.read(currentProfileIdProvider.notifier).value =
          config.currentProfileId;
      ref.read(davSettingProvider.notifier).value = config.davProps;
      ref.read(themeSettingProvider.notifier).value = config.themeProps;
      ref.read(windowSettingProvider.notifier).value = config.windowProps;
      ref.read(vpnSettingProvider.notifier).value = config.vpnProps;
      ref.read(proxiesStyleSettingProvider.notifier).value =
          config.proxiesStyleProps;
      ref.read(overrideDnsProvider.notifier).value = config.overrideDns;
      ref.read(networkSettingProvider.notifier).value = config.networkProps;
      ref.read(hotKeyActionsProvider.notifier).value = config.hotKeyActions;
      return;
    } finally {
      await restoreDir.safeDelete(recursive: true);
    }
  }
}

@Riverpod(keepAlive: true)
class CoreAction extends _$CoreAction {
  @override
  void build() {}

  Future<void> initCore() async {
    final isInit = await coreController.isInit;

    final version = ref.read(versionProvider);
    if (!isInit) {
      final res = await coreController.init(version);
      commonPrint.log('init result: $res');
    } else {
      await ref.read(proxiesActionProvider.notifier).updateGroups();
    }
  }

  Future<void> connectCore() async {
    ref.read(coreStatusProvider.notifier).value = CoreStatus.connecting;
    final result = await Future.wait([
      coreController.preload(),
      Future.delayed(const Duration(milliseconds: 300)),
    ]);
    final String message = result[0];
    if (message.isNotEmpty) {
      ref.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
      globalState.showNotifier(message);
      return;
    }
    ref.read(coreStatusProvider.notifier).value = CoreStatus.connected;
  }

  Future<Result<bool>> requestAdmin(bool enableTun) async {
    final realTunEnable = ref.read(realTunEnableProvider);
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
    ref.read(realTunEnableProvider.notifier).value = enableTun;
    return Result.success(enableTun);
  }

  Future<void> restartCore([bool start = false]) async {
    final isDisconnected =
        ref.read(coreStatusProvider) == CoreStatus.disconnected;
    ref.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    await coreController.shutdown(!isDisconnected);
    await connectCore();
    await initCore();
    if (start || ref.read(isStartProvider)) {
      await ref
          .read(setupActionProvider.notifier)
          .updateStatus(true, isInit: true);
    } else {
      await ref.read(setupActionProvider.notifier).applyProfile(force: true);
    }
  }

  Future<bool> tryStartCore([bool start = false]) async {
    if (coreController.isCompleted) return false;
    await restartCore(start);
    return true;
  }

  void handleCoreDisconnected() {
    ref.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
  }
}

@Riverpod(keepAlive: true)
class SystemAction extends _$SystemAction {
  @override
  void build() {}

  Future<List<Package>> getPackages() async {
    if (ref.read(isMobileViewProvider)) {
      await Future.delayed(commonDuration);
    }
    if (ref.read(packagesProvider).isEmpty) {
      ref.read(packagesProvider.notifier).value =
          await app?.getPackages() ?? [];
    }
    return ref.read(packagesProvider);
  }

  Future<void> handleExit([bool needSave = false]) async {
    Future.delayed(const Duration(seconds: 3), () {
      system.exit();
    });
    try {
      await Future.wait([
        if (needSave) preferences.saveConfig(ref.read(configProvider)),
        if (macOS != null) macOS!.updateDns(true),
        if (proxy != null) proxy!.stopProxy(),
        if (tray != null) tray!.destroy(),
      ]);
      await window?.close();
      await coreController.destroy();
      commonPrint.log('exit');
    } finally {
      system.exit();
    }
  }

  Future<void> handleClose([bool exit = true]) async {
    if (!system.isDesktop) {
      if (ref.read(backBlockProvider)) return;
    }
    if (ref.read(appSettingProvider).minimizeOnExit || !exit) {
      if (system.isDesktop) {
        await preferences.saveConfig(ref.read(configProvider));
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

  void updateTun() {
    ref
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith.tun(enable: !state.tun.enable));
  }

  void updateSystemProxy() {
    ref
        .read(networkSettingProvider.notifier)
        .update((state) => state.copyWith(systemProxy: !state.systemProxy));
  }

  void updateAutoLaunch() {
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(autoLaunch: !state.autoLaunch));
  }

  Future<void> updateTray() async {
    tray?.update(
      trayState: ref.read(trayStateProvider),
      traffic: ref.read(
        trafficsProvider.select(
          (state) => state.list.safeLast(const Traffic()),
        ),
      ),
    );
  }

  Future<void> updateLocalIp() async {
    ref.read(localIpProvider.notifier).value = null;
    await Future.delayed(commonDuration);
    ref.read(localIpProvider.notifier).value = await utils.getLocalIpAddress();
  }
}

@Riverpod(keepAlive: true)
class StoreAction extends _$StoreAction {
  @override
  void build() {}

  Future<void> shakingStore() async {
    final profileIds = ref.read(
      profilesProvider.select((state) => state.map((item) => item.id)),
    );
    final scriptIds = await ref.read(
      scriptsProvider.future.select(
        (state) async => (await state).map((item) => item.id),
      ),
    );
    final pathsToDelete = await shakingProfileTask(VM2(profileIds, scriptIds));
    if (pathsToDelete.isNotEmpty) {
      final deleteFutures = pathsToDelete.map((path) async {
        try {
          final res = await coreController.deleteFile(path);
          if (res.isNotEmpty) throw res;
        } catch (e) {
          rethrow;
        }
      });
      await Future.wait(deleteFutures);
    }
  }

  void savePreferencesDebounce() {
    debouncer.call(FunctionTag.savePreferences, () async {
      await preferences.saveConfig(ref.read(configProvider));
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
    ref.read(systemActionProvider.notifier).handleExit(false);
  }
}

@Riverpod(keepAlive: true)
class ThemeAction extends _$ThemeAction {
  @override
  void build() {}

  void updateBrightness() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(systemBrightnessProvider.notifier).value =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
    });
  }

  void updateViewSize(Size size) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(viewSizeProvider.notifier).value = size;
    });
  }
}

@Riverpod(keepAlive: true)
class ProxiesAction extends _$ProxiesAction {
  @override
  void build() {}

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

  Future<void> updateGroups({
    int maxAttempts = 3,
    Duration delay = midDuration,
  }) async {
    try {
      commonPrint.log('updateGroups');
      ref.read(groupsProvider.notifier).value = await retry(
        task: () async {
          final sortType = ref.read(
            proxiesStyleSettingProvider.select((state) => state.sortType),
          );
          final delayMap = ref.read(delayDataSourceProvider);
          final testUrl = ref.read(
            appSettingProvider.select((state) => state.testUrl),
          );
          final selectedMap = ref.read(
            currentProfileProvider.select((state) => state?.selectedMap ?? {}),
          );
          return coreController.getProxiesGroups(
            selectedMap: selectedMap,
            sortType: sortType,
            delayMap: delayMap,
            defaultTestUrl: testUrl,
          );
        },
        maxAttempts: maxAttempts,
        delay: delay,
        retryIf: (res) => res.isEmpty,
      );
    } catch (e) {
      commonPrint.log('updateGroups error: $e');
      ref.read(groupsProvider.notifier).value = [];
    }
  }

  void updateCurrentGroupName(String groupName) {
    final profile = ref.read(currentProfileProvider);
    if (profile == null || profile.currentGroupName == groupName) return;
    ref
        .read(profilesProvider.notifier)
        .put(profile.copyWith(currentGroupName: groupName));
  }

  void updateCurrentUnfoldSet(Set<String> value) {
    final currentProfile = ref.read(currentProfileProvider);
    if (currentProfile == null) return;
    ref
        .read(profilesProvider.notifier)
        .put(currentProfile.copyWith(unfoldSet: value));
  }

  void setDelay(Delay delay) {
    ref.read(delayDataSourceProvider.notifier).setDelay(delay);
  }

  Future<void> changeProxy({
    required String groupName,
    required String proxyName,
  }) async {
    await coreController.changeProxy(
      ChangeProxyParams(groupName: groupName, proxyName: proxyName),
    );
    if (ref.read(appSettingProvider).closeConnections) {
      await coreController.closeConnections();
    } else {
      await coreController.resetConnections();
    }
    ref.read(checkIpNumProvider.notifier).add();
  }

  Future<String> updateProvider(
    ExternalProvider provider, {
    bool showLoading = false,
  }) async {
    try {
      if (showLoading) {
        ref.read(isUpdatingProvider(provider.updatingKey).notifier).value =
            true;
      }
      final message = await coreController.updateExternalProvider(
        providerName: provider.name,
      );
      if (message.isNotEmpty) return message;
      ref
          .read(providersProvider.notifier)
          .setProvider(await coreController.getExternalProvider(provider.name));
      return '';
    } finally {
      ref.read(isUpdatingProvider(provider.updatingKey).notifier).value = false;
    }
  }
}

@Riverpod(keepAlive: true)
class ProfilesAction extends _$ProfilesAction {
  final Set<int> _freeNodesAutoUpdatingIds = {};
  final Set<int> _freeNodesAutoPreferringIds = {};

  @override
  void build() {}

  void updateCurrentSelectedMap(String groupName, String proxyName) {
    final currentProfile = ref.read(currentProfileProvider);
    if (currentProfile != null &&
        currentProfile.selectedMap[groupName] != proxyName) {
      final selectedMap = Map<String, String>.from(currentProfile.selectedMap)
        ..[groupName] = proxyName;
      ref
          .read(profilesProvider.notifier)
          .put(currentProfile.copyWith(selectedMap: selectedMap));
    }
  }

  Future<bool> selectProfile(int profileId) async {
    final currentProfileId = ref.read(currentProfileIdProvider);
    final profile = ref.read(profilesProvider).getProfile(profileId);
    if (profile == null || currentProfileId == profileId) return false;
    ref.read(currentProfileIdProvider.notifier).value = profileId;
    if (shouldCheckFreeNodesAutoUpdateOnProfileSelection(
      currentProfileId: currentProfileId,
      selectedProfileId: profileId,
      isFreeNodesProfile: profile.isFreeNodesProfile,
      autoUpdate: profile.autoUpdate,
    )) {
      try {
        await _autoUpdateFreeNodesProfile(profile);
        return true;
      } catch (e) {
        commonPrint.log(e.toString(), logLevel: LogLevel.warning);
      }
    }
    return false;
  }

  Future<bool> checkFreeNodesProfileAutoUpdateIfNeeded(int profileId) async {
    final profile = ref.read(profilesProvider).getProfile(profileId);
    if (profile == null || !profile.isFreeNodesProfile || !profile.autoUpdate) {
      return false;
    }
    await _autoUpdateFreeNodesProfile(profile);
    return true;
  }

  Future<void> deleteProfile(int id) async {
    final profile = ref.read(profilesProvider).getProfile(id);
    if (profile?.isFreeNodesProfile == true) return;
    ref.read(profilesProvider.notifier).del(id);
    clearEffect(id);
    final currentProfileId = ref.read(currentProfileIdProvider);
    if (currentProfileId == id) {
      final profiles = ref.read(profilesProvider);
      if (profiles.isNotEmpty) {
        final updateId = profiles.first.id;
        ref.read(currentProfileIdProvider.notifier).value = updateId;
      } else {
        ref.read(currentProfileIdProvider.notifier).value = null;
        ref.read(setupActionProvider.notifier).updateStatus(false);
      }
    }
  }

  Future<void> autoUpdateProfiles({bool includeFreeNodes = true}) async {
    for (final profile in ref.read(profilesProvider)) {
      if (!profile.autoUpdate) continue;
      if (profile.isFreeNodesProfile) {
        if (!includeFreeNodes) continue;
        try {
          await _autoUpdateFreeNodesProfile(profile);
        } catch (e) {
          commonPrint.log(e.toString(), logLevel: LogLevel.warning);
        }
        continue;
      }
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
    ref.read(profilesProvider.notifier).put(profile);
    if (ref.read(currentProfileIdProvider) != null) return;
    ref.read(currentProfileIdProvider.notifier).value = profile.id;
  }

  Future<void> _putProfileAndPersist(Profile profile) async {
    await ref.read(profilesProvider.notifier).putAndWait(profile);
  }

  void _setFreeNodesProgress(FreeNodesProgress progress) {
    if (!ref.mounted) return;
    ref.read(freeNodesFetchProgressProvider.notifier).value = progress;
  }

  Future<Profile> _updateFreeNodesProfile(
    Profile profile, {
    Set<String>? sourceIds,
    bool silent = false,
    String? runningOperation,
  }) async {
    final startedAt = DateTime.now();
    if (!silent) {
      _setFreeNodesProgress(
        FreeNodesProgress(
          operation: runningOperation ?? '\u5f00\u59cb\u83b7\u53d6\u8282\u70b9',
          proxyCount: profile.subscriptionInfo?.total ?? 0,
          startedAt: startedAt,
        ),
      );
    }
    try {
      return await freeNodesService.updateProfile(
        profile,
        sourceIds: sourceIds,
        onPartialProfile: silent
            ? null
            : (partialProfile) async {
                if (!ref.mounted) return;
                await _putProfileAndPersist(partialProfile);
              },
        onProgress: silent
            ? null
            : (progress) {
                _setFreeNodesProgress(
                  runningOperation == null
                      ? progress.copyWith(
                          startedAt: startedAt,
                          finishedAt: progress.done || progress.error
                              ? DateTime.now()
                              : null,
                        )
                      : buildFreeNodesAutoUpdateFetchProgress(
                          progress: progress,
                          runningOperation: runningOperation,
                          startedAt: startedAt,
                          proxyCount: profile.subscriptionInfo?.total ?? 0,
                        ),
                );
              },
      );
    } catch (e) {
      if (!silent) {
        _setFreeNodesProgress(
          FreeNodesProgress(
            operation: e.toString(),
            error: true,
            startedAt: startedAt,
            finishedAt: DateTime.now(),
          ),
        );
      }
      rethrow;
    }
  }

  Future<void> _autoUpdateFreeNodesProfile(Profile profile) async {
    if (!_freeNodesAutoUpdatingIds.add(profile.id)) {
      if (!ref.mounted) return;
      final currentProgress = ref.read(freeNodesFetchProgressProvider);
      _setFreeNodesProgress(
        buildFreeNodesAutoUpdateRunningProgress(
          proxyCount: profile.subscriptionInfo?.total ?? 0,
          currentProgress: currentProgress is FreeNodesProgress
              ? currentProgress
              : null,
          preserveTerminalProgress: true,
        ),
      );
      return;
    }
    final startedAt = DateTime.now();
    if (!ref.mounted) {
      _freeNodesAutoUpdatingIds.remove(profile.id);
      return;
    }
    ref.read(isUpdatingProvider(profile.updatingKey).notifier).value = true;
    try {
      if (!ref.mounted) return;
      final currentProgress = ref.read(freeNodesFetchProgressProvider);
      _setFreeNodesProgress(
        buildFreeNodesAutoUpdateRunningProgress(
          proxyCount: profile.subscriptionInfo?.total ?? 0,
          currentProgress: currentProgress is FreeNodesProgress
              ? currentProgress
              : null,
          startedAt: startedAt,
        ),
      );
      final file = await profile.existingFile;
      final fileExists = await file.exists();
      final dueSourceIds = await freeNodesService.getDueSourceIds();
      if (!ref.mounted) return;
      final decision = resolveFreeNodesAutoUpdateDecision(
        fileExists: fileExists,
        hasLastUpdateDate: profile.lastUpdateDate != null,
        hasDueSources: dueSourceIds.isNotEmpty,
      );
      if (!decision.shouldUpdate) {
        final visibleDelay = remainingFreeNodesAutoUpdateVisibleDelay(
          startedAt: startedAt,
        );
        if (visibleDelay > Duration.zero) {
          await Future<void>.delayed(visibleDelay);
        }
        if (!ref.mounted) return;
        _setFreeNodesProgress(
          buildFreeNodesAutoUpdateNoopProgress(
            proxyCount: profile.subscriptionInfo?.total ?? 0,
            startedAt: startedAt,
          ),
        );
        if (shouldApplyCurrentFreeNodesProfileAfterNoopAutoUpdate(
          isCurrentProfile: profile.id == ref.read(currentProfileIdProvider),
          shouldUpdate: decision.shouldUpdate,
          hasLoadedGroups: ref.read(groupsProvider).isNotEmpty,
        )) {
          await _applyFreeNodesProfileIfCurrent(profile);
        }
        return;
      }
      final runningOperation = decision.operation;
      if (!ref.mounted) return;
      _setFreeNodesProgress(
        FreeNodesProgress(
          operation: runningOperation,
          proxyCount: profile.subscriptionInfo?.total ?? 0,
          startedAt: startedAt,
        ),
      );
      await updateProfile(
        profile,
        freeNodeSourceIds: decision.kind == FreeNodesAutoUpdateKind.dueSources
            ? dueSourceIds
            : null,
        silentFreeNodes: false,
        freeNodesRunningOperation: runningOperation,
      );
    } finally {
      _freeNodesAutoUpdatingIds.remove(profile.id);
      if (ref.mounted) {
        ref.read(isUpdatingProvider(profile.updatingKey).notifier).value =
            false;
      }
    }
  }

  Future<void> _applyFreeNodesProfileIfCurrent(Profile profile) async {
    if (!ref.mounted) return;
    if (profile.id != ref.read(currentProfileIdProvider)) return;
    await ref
        .read(setupActionProvider.notifier)
        .applyProfile(silence: true, force: true);
  }

  Future<bool> _autoPreferFreeNodesAfterFetch(
    Profile profile, {
    bool silent = false,
  }) async {
    final preferenceState = await freeNodesService.getPreferenceState();
    if (!preferenceState.autoPrefer) return false;
    if (await freeNodesService.wasAutoPreferredToday()) return false;
    if (!_freeNodesAutoPreferringIds.add(profile.id)) return false;
    try {
      if (await freeNodesService.wasAutoPreferredToday()) return false;
      await preferFreeNodesProfile(
        profile,
        deleteExpiredGroups: preferenceState.deleteExpiredOnPrefer,
      );
      await freeNodesService.markAutoPreferredToday();
      return true;
    } catch (e) {
      commonPrint.log(e.toString(), logLevel: LogLevel.warning);
      if (!silent) {
        _setFreeNodesProgress(
          FreeNodesProgress(operation: e.toString(), error: true),
        );
      }
      return false;
    } finally {
      _freeNodesAutoPreferringIds.remove(profile.id);
    }
  }

  Future<bool> ensureFreeNodesProfile({bool update = true}) async {
    final current = ref
        .read(profilesProvider)
        .firstWhereOrNull((profile) => profile.isFreeNodesProfile);
    if (current == null && await preferences.getBool(freeNodesDisabledKey)) {
      await preferences.setBool(freeNodesDisabledKey, false);
    }
    var profile = current ?? freeNodesService.createProfile();
    if (current == null) {
      await _putProfileAndPersist(profile);
    } else {
      final normalizedProfile = await freeNodesService.normalizeExistingProfile(
        profile,
      );
      if (normalizedProfile != null) {
        profile = normalizedProfile;
        await _putProfileAndPersist(profile);
        await _applyFreeNodesProfileIfCurrent(profile);
      }
    }
    final currentProfileId = ref.read(currentProfileIdProvider);
    final hasCurrentProfile =
        currentProfileId != null &&
        ref.read(profilesProvider).any((item) => item.id == currentProfileId);
    if (!hasCurrentProfile) {
      ref.read(currentProfileIdProvider.notifier).value = profile.id;
    }
    if (!update || !profile.autoUpdate) {
      return false;
    }
    if (_freeNodesAutoUpdatingIds.contains(profile.id)) {
      return true;
    }
    ref.read(isUpdatingProvider(profile.updatingKey).notifier).value = true;
    _setFreeNodesProgress(
      buildFreeNodesAutoUpdateStartProgress(
        firstLaunch: current == null,
        proxyCount: profile.subscriptionInfo?.total ?? 0,
      ),
    );
    unawaited(
      _autoUpdateFreeNodesProfile(profile).catchError((e) {
        commonPrint.log(e.toString(), logLevel: LogLevel.warning);
      }),
    );
    return true;
  }

  Future<void> updateFreeNodesProfile({bool showLoading = false}) async {
    await preferences.setBool(freeNodesDisabledKey, false);
    final current = ref
        .read(profilesProvider)
        .firstWhereOrNull((profile) => profile.isFreeNodesProfile);
    final profile = current ?? freeNodesService.createProfile();
    final previousCurrentProfileId = ref.read(currentProfileIdProvider);
    ref.read(currentProfileIdProvider.notifier).value = profile.id;
    try {
      await updateProfile(profile, showLoading: showLoading);
    } catch (_) {
      if (current == null && ref.mounted) {
        ref.read(currentProfileIdProvider.notifier).value =
            previousCurrentProfileId;
      }
      rethrow;
    }
  }

  Future<void> removeFreeNodesProfile({bool update = true}) async {
    await preferences.setBool(freeNodesDisabledKey, false);
    final profile =
        ref
            .read(profilesProvider)
            .firstWhereOrNull((profile) => profile.isFreeNodesProfile) ??
        freeNodesService.createProfile();
    if (!ref.read(profilesProvider).any((item) => item.id == profile.id)) {
      await _putProfileAndPersist(profile);
    }
    ref.read(currentProfileIdProvider.notifier).value = profile.id;
    if (!update) {
      _setFreeNodesProgress(
        const FreeNodesProgress(operation: '已恢复', done: true),
      );
      return;
    }
    await updateProfile(profile, showLoading: true);
  }

  Future<FreeNodesPreferResult> preferFreeNodesProfile(
    Profile profile, {
    bool? deleteExpiredGroups,
  }) async {
    ref.read(isUpdatingProvider(profile.updatingKey).notifier).value = true;
    try {
      final result = await freeNodesService.preferProfile(
        profile,
        deleteExpiredGroups: deleteExpiredGroups,
      );
      final savedProfile = result.profile;
      if (savedProfile != null) {
        await _putProfileAndPersist(savedProfile);
        if (profile.id == ref.read(currentProfileIdProvider)) {
          await ref
              .read(setupActionProvider.notifier)
              .applyProfile(silence: true, force: true);
        }
      }
      _setFreeNodesProgress(
        FreeNodesProgress(
          operation: result.removedCount > 0
              ? '已优选，删除 ${result.removedCount} 个超时节点'
              : '已优选，已整合优选节点',
          proxyCount: result.afterCount,
          done: true,
        ),
      );
      return result;
    } finally {
      ref.read(isUpdatingProvider(profile.updatingKey).notifier).value = false;
    }
  }

  Future<FreeNodesGroupEditResult> preferFreeNodesGroup(
    Profile profile,
    String groupName,
  ) async {
    ref.read(isUpdatingProvider(profile.updatingKey).notifier).value = true;
    try {
      final result = await freeNodesService.preferGroup(profile, groupName);
      await _saveFreeNodesGroupEdit(profile, result);
      _setFreeNodesProgress(
        FreeNodesProgress(
          operation: '已优选 $groupName',
          proxyCount: result.afterCount,
          done: true,
        ),
      );
      return result;
    } finally {
      ref.read(isUpdatingProvider(profile.updatingKey).notifier).value = false;
    }
  }

  Future<FreeNodesGroupEditResult> deleteFreeNodesDateGroup(
    Profile profile,
    String groupName,
  ) async {
    ref.read(isUpdatingProvider(profile.updatingKey).notifier).value = true;
    try {
      final result = await freeNodesService.deleteDateGroup(profile, groupName);
      await _saveFreeNodesGroupEdit(profile, result);
      _setFreeNodesProgress(
        FreeNodesProgress(
          operation: '已移入优选节点 ${result.affectedCount} 个节点',
          proxyCount: result.afterCount,
          done: true,
        ),
      );
      return result;
    } finally {
      ref.read(isUpdatingProvider(profile.updatingKey).notifier).value = false;
    }
  }

  Future<void> _saveFreeNodesGroupEdit(
    Profile profile,
    FreeNodesGroupEditResult result,
  ) async {
    final savedProfile = result.profile;
    if (savedProfile == null) return;
    await _putProfileAndPersist(savedProfile);
    if (profile.id == ref.read(currentProfileIdProvider)) {
      await ref
          .read(setupActionProvider.notifier)
          .applyProfile(silence: true, force: true);
    }
  }

  Future<void> updateProfiles() async {
    for (final profile in ref.read(profilesProvider)) {
      if (profile.type == ProfileType.file) continue;
      if (profile.isFreeNodesProfile) continue;
      await updateProfile(profile);
    }
  }

  Future<void> updateProfile(
    Profile profile, {
    bool showLoading = false,
    Set<String>? freeNodeSourceIds,
    bool silentFreeNodes = false,
    String? freeNodesRunningOperation,
  }) async {
    final showUpdating =
        showLoading || (profile.isFreeNodesProfile && !silentFreeNodes);
    try {
      if (showUpdating && ref.mounted) {
        ref.read(isUpdatingProvider(profile.updatingKey).notifier).value = true;
      }
      if (shouldPersistProfileBeforeRemoteUpdate(profile)) {
        await _putProfileAndPersist(profile);
      }
      if (!ref.mounted) return;
      final newProfile = profile.isFreeNodesProfile
          ? await _updateFreeNodesProfile(
              profile,
              sourceIds: freeNodeSourceIds,
              silent: silentFreeNodes,
              runningOperation: freeNodesRunningOperation,
            )
          : await profile.update();
      if (!ref.mounted) return;
      await _putProfileAndPersist(newProfile);
      if (!ref.mounted) return;
      if (profile.isFreeNodesProfile) {
        final didAutoPrefer = await _autoPreferFreeNodesAfterFetch(
          newProfile,
          silent: silentFreeNodes,
        );
        if (!ref.mounted) return;
        if (!didAutoPrefer) {
          await _applyFreeNodesProfileIfCurrent(newProfile);
        }
      } else if (profile.id == ref.read(currentProfileIdProvider)) {
        ref
            .read(setupActionProvider.notifier)
            .applyProfileDebounce(silence: true);
      }
    } finally {
      if (showUpdating && ref.mounted) {
        ref.read(isUpdatingProvider(profile.updatingKey).notifier).value =
            false;
      }
    }
  }

  Future<void> addFreeNodesProfile() async {
    await preferences.setBool(freeNodesDisabledKey, false);
    if (globalState.navigatorKey.currentState?.canPop() ?? false) {
      globalState.navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
    ref.read(currentPageLabelProvider.notifier).value = PageLabel.profiles;
    final current = ref
        .read(profilesProvider)
        .firstWhereOrNull((profile) => profile.isFreeNodesProfile);
    final profile = await globalState.loadingRun(
      tag: LoadingTag.profiles,
      () async {
        final target = current ?? freeNodesService.createProfile();
        return _updateFreeNodesProfile(target);
      },
      title: freeNodesProfileLabel,
    );
    if (profile != null) {
      await _putProfileAndPersist(profile);
      ref.read(currentProfileIdProvider.notifier).value = profile.id;
      final didAutoPrefer = await _autoPreferFreeNodesAfterFetch(profile);
      if (!didAutoPrefer) {
        await _applyFreeNodesProfileIfCurrent(profile);
      }
    }
  }

  Future<void> addProfileFormFile() async {
    final platformFile = await globalState.safeRun(picker.pickerFile);
    if (platformFile == null) return;
    final bytes = await platformFile.readBytes();
    globalState.navigatorKey.currentState?.popUntil((route) => route.isFirst);
    ref.read(currentPageLabelProvider.notifier).toProfiles();
    final profile = await globalState.loadingRun(
      tag: LoadingTag.profiles,
      () async {
        return Profile.normal(label: platformFile.name).saveFile(bytes);
      },
      title: currentAppLocalizations.addProfile,
    );
    if (profile != null) {
      putProfile(profile);
    }
  }

  Future<void> addProfileFormURL(String url, {String sourceUrl = ''}) async {
    if (globalState.navigatorKey.currentState?.canPop() ?? false) {
      globalState.navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
    ref.read(currentPageLabelProvider.notifier).value = PageLabel.profiles;
    final profile = await globalState.loadingRun(
      tag: LoadingTag.profiles,
      () async {
        return Profile.normal(url: url).copyWith(sourceUrl: sourceUrl).update();
      },
      title: currentAppLocalizations.addProfile,
    );
    if (profile != null) {
      putProfile(profile);
    }
  }

  void setProfileAndAutoApply(Profile profile) {
    ref.read(profilesProvider.notifier).put(profile);
    if (profile.id == ref.read(currentProfileIdProvider)) {
      ref.read(setupActionProvider.notifier).applyProfileDebounce();
    }
  }

  Future<void> addProfileFormQrCode() async {
    final url = await globalState.safeRun(picker.pickerConfigQRCode);
    if (url == null) return;
    addProfileFormURL(url);
  }

  void reorder(List<Profile> profiles) {
    ref.read(profilesProvider.notifier).reorder(profiles);
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

@Riverpod(keepAlive: true)
class GeoResourceAction extends _$GeoResourceAction {
  @override
  void build() {}

  Future<void> updateGeoResource(GeoResource geoResource) async {
    await coreController.updateGeoData(geoResource.name);
  }

  void updateGeoResourceUrl(GeoResource geoResource, String newUrl) {
    if (!newUrl.isUrl) {
      throw 'Invalid url';
    }
    ref.read(patchClashConfigProvider.notifier).update((state) {
      return state.copyWith(geoXUrl: {...state.geoXUrl, geoResource: newUrl});
    });
  }
}
