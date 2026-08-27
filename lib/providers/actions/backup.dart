part of '../action.dart';

@Riverpod(keepAlive: true)
class BackupAction extends _$BackupAction {
  @override
  void build() {}

  Future<bool> consumeBackup(Future<bool> Function(String path) send) async {
    final path = await backup();
    if (path.isEmpty) {
      return false;
    }
    try {
      return await send(path);
    } finally {
      await File(path).safeDelete();
    }
  }

  @visibleForTesting
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
    try {
      final migrationData = await restoreTask();
      if (!await restoreDir.exists()) {
        throw MessageException(currentAppLocalizations.restoreException);
      }
      await applyRestore(migrationData, option);
    } finally {
      await restoreDir.safeDelete(recursive: true);
    }
  }

  @visibleForTesting
  Future<void> applyRestore(MigrationData data, RestoreOption option) async {
    final restoreStrategy = ref.read(
      appSettingProvider.select((state) => state.restoreStrategy),
    );
    final isOverride = restoreStrategy == RestoreStrategy.override;
    final configMap = data.configMap;
    final config = option == RestoreOption.onlyProfiles || configMap == null
        ? null
        : Config.fromJson(configMap);
    await database.restore(
      data.profiles,
      data.scripts,
      data.rules,
      data.links,
      data.proxyGroups,
      isOverride: isOverride,
    );
    if (config == null) {
      return;
    }
    ref.read(davSettingProvider.notifier).update((_) => config.davProps);
    ref.read(patchClashConfigProvider.notifier).value = config.patchClashConfig;
    ref.read(appSettingProvider.notifier).value = config.appSettingProps;
    ref.read(currentProfileIdProvider.notifier).value = config.currentProfileId;
    ref.read(themeSettingProvider.notifier).value = config.themeProps;
    ref.read(windowSettingProvider.notifier).value = config.windowProps;
    ref.read(vpnSettingProvider.notifier).value = config.vpnProps;
    ref.read(proxiesStyleSettingProvider.notifier).value =
        config.proxiesStyleProps;
    ref.read(overrideDnsProvider.notifier).value = config.overrideDns;
    ref.read(networkSettingProvider.notifier).value = config.networkProps;
    ref.read(hotKeyActionsProvider.notifier).value = config.hotKeyActions;
  }
}
