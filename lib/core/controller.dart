import 'dart:async';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';
import 'package:path/path.dart';

/// The lifecycle of the Core and its [api], with the few operations that
/// compose several calls or turn app models into API arguments.
extension type CoreController._(CoreBackend _backend) implements CoreBackend {
  static CoreController? _instance;

  factory CoreController() {
    return _instance ??= CoreController._(
      system.isAndroid ? coreLib! : coreService!,
    );
  }

  @visibleForTesting
  factory CoreController.test(CoreBackend backend) {
    return _instance = CoreController._(backend);
  }

  @visibleForTesting
  CoreController.scoped(this._backend);

  @visibleForTesting
  static void resetInstance() {
    _instance = null;
  }

  static Future<void> ensureHomeDir() async {
    final homePath = await appPath.homeDirPath;
    final homeDir = Directory(homePath);
    final isExists = await homeDir.exists();
    if (!isExists) {
      await homeDir.create(recursive: true);
    }
    await system.grantHomeDirAccess(homePath);
  }

  static Future<void> initGeo() async {
    final homePath = await appPath.homeDirPath;
    const geoFileNameList = [MMDB, GEOSITE];
    try {
      for (final geoFileName in geoFileNameList) {
        final geoFile = File(join(homePath, geoFileName));
        final isExists = await geoFile.exists();
        if (isExists) {
          continue;
        }
        final asset = 'assets/data/$geoFileName';
        // rootBundle inflates the asset on the platform thread, which Android
        // shares with the UI: the files stall frames for over 100 ms.
        if (app case final app?) {
          await app.extractAsset(asset, geoFile.path);
          continue;
        }
        final data = await rootBundle.load(asset);
        final List<int> bytes = data.buffer.asUint8List();
        await geoFile.writeAsBytes(bytes, flush: true);
      }
    } catch (e) {
      commonPrint.log(
        'Failed to initialize geo data: $e',
        logLevel: LogLevel.error,
      );
      rethrow;
    }
  }

  Future<void> init(int version) async {
    await ensureHomeDir();
    await initGeo();
    await api.init(home: await appPath.homeDirPath, sdkInt: version);
  }

  /// An age-encrypted config is rewritten in place into its plaintext, and a
  /// share-link list into a config of its proxies.
  Future<String?> validateProfile(
    String path, [
    String ageSecretKey = '',
  ]) async {
    final file = File(path);
    if (await file.isAgeEncrypted) {
      if (ageSecretKey.isEmpty) {
        throw const AgeSecretKeyRequiredException();
      }
      final plain = await api.decryptConfig(path, ageSecretKey);
      await file.safeWriteAsString(plain.text ?? '');
    }
    final issue = await _firstIssue(path);
    if (issue == null) {
      return null;
    }
    final List<Map<String, dynamic>> proxies;
    try {
      proxies = await api.convertSubscription(path);
    } on Exception {
      return issue;
    }
    if (proxies.isEmpty) {
      return issue;
    }
    await file.safeWriteAsString(await encodeYamlTask({'proxies': proxies}));
    return _firstIssue(path);
  }

  Future<String?> _firstIssue(String path) async {
    final issues = await api.validateConfig(path);
    return issues.firstOrNull?.message;
  }

  Future<String?> validateConfig(String path) => _firstIssue(path);

  Future<Map<int, String>> validateProxies(List<Map<String, dynamic>> proxies) {
    if (proxies.isEmpty) {
      return Future.value(const {});
    }
    return api.validateProxies(proxies);
  }

  Future<Map<int, String>> validateFilters(List<String> filters) {
    if (filters.isEmpty) {
      return Future.value(const {});
    }
    return api.validateFilters(filters);
  }

  Future<List<String>> encodeShareLinks(List<Map<String, dynamic>> proxies) {
    if (proxies.isEmpty) {
      return Future.value(const []);
    }
    return api.encodeLinks(proxies);
  }

  Future<List<List<Map<String, dynamic>>>> decodeShareLinks(
    List<String> lines,
  ) {
    if (lines.isEmpty) {
      return Future.value(const []);
    }
    return api.decodeLinks(lines);
  }

  Future<String?> validateConfigWithData(List<int> data) async {
    final path = await appPath.tempFilePath;
    final file = File(path);
    await file.safeWriteAsBytes(data);
    try {
      return await _firstIssue(path);
    } finally {
      await file.safeDelete();
    }
  }

  Future<List<ConfigWarning>> getConfigWarnings() async {
    final warnings = await api.lastWarnings();
    return warnings.map(warningOf).toList();
  }

  Future<void> setupConfig({
    required SetupParams params,
    Future<void> Function()? preloadInvoke,
  }) async {
    final base = params.base;
    final apply = api.applyConfig(
      profilePath: base?.path,
      overlay: base?.overlay,
      selection: params.selectedMap,
      options: coreOptionsArgOf(params.options),
      host: params.host,
    );
    if (preloadInvoke == null) {
      await apply;
      return;
    }
    await (apply, preloadInvoke()).wait;
  }

  Future<int> updateConfig(ConfigPatch patch) => api.patchConfig(patch);

  Future<List<Group>> getProxiesGroups({
    required ProxiesSortType sortType,
    required DelayMap delayMap,
    required Map<String, String> selectedMap,
    required String defaultTestUrl,
  }) async {
    final proxyGroups = await api.proxyGroups();
    return toGroupsTask(
      ComputeGroupsState(
        proxyGroups: proxyGroups,
        sortType: sortType,
        delayMap: delayMap,
        selectedMap: selectedMap,
        defaultTestUrl: defaultTestUrl,
      ),
    );
  }

  Future<Map<String, dynamic>> readConfig(int id) async {
    final path = await appPath.getProfilePath(id.toString());
    final read = await api.readConfig(path);
    return read.config ?? {};
  }

  Future<Map<String, dynamic>> getProfileOutbounds(int id) async {
    final outbounds = await api.profileOutbounds(
      await appPath.getProfilePath(id.toString()),
    );
    return {
      'proxies': [
        for (final item in outbounds.proxies)
          {'name': item.name, 'type': item.type},
      ],
      'proxy-groups': [
        for (final item in outbounds.proxyGroups)
          {'name': item.name, 'type': item.type},
      ],
    };
  }

  Future<String> buildProfile(SetupBase base) async {
    final built = await api.buildProfile(base.path, base.overlay);
    return built.text ?? '';
  }

  Future<String?> getProfileMatchTarget(int id) async {
    final path = await appPath.getProfilePath(id.toString());
    return lastMatchTarget((await api.inspectProfile(path)).matchRules);
  }

  Future<({ProfileBase base, String path})> getProfileBase(int id) async {
    final path = await appPath.getProfilePath(id.toString());
    final inspect = await api.inspectProfile(path);
    final base = profileBaseOf(inspect);
    final config = Map<String, dynamic>.from(base.config)..remove('rule');
    return (base: base.copyWith(config: config), path: path);
  }
}

final coreController = CoreController();
