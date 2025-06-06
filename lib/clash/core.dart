import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/clash/interface.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

class ClashCore {
  static ClashCore? _instance;
  late ClashHandlerInterface clashInterface;

  ClashCore._internal() {
    if (system.isAndroid) {
      clashInterface = clashLib!;
    } else {
      clashInterface = clashService!;
    }
  }

  factory ClashCore() {
    _instance ??= ClashCore._internal();
    return _instance!;
  }

  Future<bool> preload() {
    return clashInterface.preload();
  }

  static Future<void> initGeo() async {
    final homePath = await appPath.homeDirPath;
    final homeDir = Directory(homePath);
    final isExists = await homeDir.exists();
    if (!isExists) {
      await homeDir.create(recursive: true);
    }
    const geoFileNameList = [
      mmdbFileName,
      geoIpFileName,
      geoSiteFileName,
      asnFileName,
    ];
    try {
      for (final geoFileName in geoFileNameList) {
        final geoFile = File(
          join(homePath, geoFileName),
        );
        final isExists = await geoFile.exists();
        if (isExists) {
          continue;
        }
        final data = await rootBundle.load('assets/data/$geoFileName');
        List<int> bytes = data.buffer.asUint8List();
        await geoFile.writeAsBytes(bytes, flush: true);
      }
    } catch (e) {
      exit(0);
    }
  }

  Future<bool> init() async {
    await initGeo();
    if (globalState.config.appSetting.openLogs) {
      clashCore.startLog();
    } else {
      clashCore.stopLog();
    }
    final homeDirPath = await appPath.homeDirPath;
    return await clashInterface.init(
      InitParams(
        homeDir: homeDirPath,
        version: globalState.appState.version,
      ),
    );
  }

  Future<bool> setState(CoreState state) async {
    return await clashInterface.setState(state);
  }

  Future<void> shutdown() async {
    await clashInterface.shutdown();
  }

  FutureOr<bool> get isInit => clashInterface.isInit;

  FutureOr<String> validateConfig(String data) {
    return clashInterface.validateConfig(data);
  }

  Future<String> updateConfig(UpdateParams updateParams) async {
    return await clashInterface.updateConfig(updateParams);
  }

  Future<String> setupConfig(SetupParams setupParams) async {
    return await clashInterface.setupConfig(setupParams);
  }

  Future<List<Group>> getProxiesGroups() async {
    final proxies = await clashInterface.getProxies();
    if (proxies.isEmpty) return [];
    final groupNames = [
      UsedProxy.GLOBAL.name,
      ...(proxies[UsedProxy.GLOBAL.name]['all'] as List).where((e) {
        final proxy = proxies[e] ?? {};
        return GroupTypeExtension.valueList.contains(proxy['type']);
      })
    ];
    final groupsRaw = groupNames.map((groupName) {
      final group = proxies[groupName];
      group['all'] = ((group['all'] ?? []) as List)
          .map(
            (name) => proxies[name],
          )
          .where((proxy) => proxy != null)
          .toList();
      return group;
    }).toList();
    return groupsRaw
        .map(
          (e) => Group.fromJson(e),
        )
        .toList();
  }

  FutureOr<String> changeProxy(ChangeProxyParams changeProxyParams) async {
    return await clashInterface.changeProxy(changeProxyParams);
  }

  Future<List<TrackerInfo>> getConnections() async {
    final res = await clashInterface.getConnections();
    final connectionsData = json.decode(res) as Map;
    final connectionsRaw = connectionsData['connections'] as List? ?? [];
    return connectionsRaw.map((e) => TrackerInfo.fromJson(e)).toList();
  }

  void closeConnection(String id) {
    clashInterface.closeConnection(id);
  }

  void closeConnections() {
    clashInterface.closeConnections();
  }

  void resetConnections() {
    clashInterface.resetConnections();
  }

  Future<List<ExternalProvider>> getExternalProviders() async {
    final externalProvidersRawString =
        await clashInterface.getExternalProviders();
    if (externalProvidersRawString.isEmpty) {
      return [];
    }
    return Isolate.run<List<ExternalProvider>>(
      () {
        final externalProviders =
            (json.decode(externalProvidersRawString) as List<dynamic>)
                .map(
                  (item) => ExternalProvider.fromJson(item),
                )
                .toList();
        return externalProviders;
      },
    );
  }

  Future<ExternalProvider?> getExternalProvider(
      String externalProviderName) async {
    final externalProvidersRawString =
        await clashInterface.getExternalProvider(externalProviderName);
    if (externalProvidersRawString.isEmpty) {
      return null;
    }
    if (externalProvidersRawString.isEmpty) {
      return null;
    }
    return ExternalProvider.fromJson(json.decode(externalProvidersRawString));
  }

  Future<String> updateGeoData(UpdateGeoDataParams params) {
    return clashInterface.updateGeoData(params);
  }

  Future<String> sideLoadExternalProvider({
    required String providerName,
    required String data,
  }) {
    return clashInterface.sideLoadExternalProvider(
        providerName: providerName, data: data);
  }

  Future<String> updateExternalProvider({
    required String providerName,
  }) async {
    return clashInterface.updateExternalProvider(providerName);
  }

  Future<void> startListener() async {
    await clashInterface.startListener();
  }

  Future<void> stopListener() async {
    await clashInterface.stopListener();
  }

  Future<Delay> getDelay(String url, String proxyName) async {
    final data = await clashInterface.asyncTestDelay(url, proxyName);
    return Delay.fromJson(json.decode(data));
  }

  Future<Map<String, dynamic>> getConfig(String id) async {
    final profilePath = await appPath.getProfilePath(id);
    final res = await clashInterface.getConfig(profilePath);
    if (res.isSuccess) {
      return res.data as Map<String, dynamic>;
    } else {
      throw res.message;
    }
  }

  Future<Traffic> getTraffic() async {
    final trafficString = await clashInterface.getTraffic();
    if (trafficString.isEmpty) {
      return Traffic();
    }
    return Traffic.fromMap(json.decode(trafficString));
  }

  Future<IpInfo?> getCountryCode(String ip) async {
    final countryCode = await clashInterface.getCountryCode(ip);
    if (countryCode.isEmpty) {
      return null;
    }
    return IpInfo(
      ip: ip,
      countryCode: countryCode,
    );
  }

  Future<Traffic> getTotalTraffic() async {
    final totalTrafficString = await clashInterface.getTotalTraffic();
    if (totalTrafficString.isEmpty) {
      return Traffic();
    }
    return Traffic.fromMap(json.decode(totalTrafficString));
  }

  Future<int> getMemory() async {
    final value = await clashInterface.getMemory();
    if (value.isEmpty) {
      return 0;
    }
    return int.parse(value);
  }

  void resetTraffic() {
    clashInterface.resetTraffic();
  }

  void startLog() {
    clashInterface.startLog();
  }

  void stopLog() {
    clashInterface.stopLog();
  }

  Future<void> requestGc() async {
    await clashInterface.forceGc();
  }

  Future<void> destroy() async {
    await clashInterface.destroy();
  }
}

final clashCore = ClashCore();
