part of '../action.dart';

@Riverpod(keepAlive: true)
class ResourcesAction extends _$ResourcesAction {
  var _autoUpdating = false;

  @override
  void build() {}

  Future<void> updateIconSet(IconSet iconSet) {
    return _track(
      iconSet.updatingKey,
      () => ref.read(iconSetsActionProvider.notifier).sync(iconSet),
    );
  }

  Future<void> updateRuleProvider(ClashProvider provider) {
    return _track(
      provider.updatingKey,
      () => ref
          .read(clashProvidersActionProvider.notifier)
          .putProvider(provider, previous: provider, refresh: true),
    );
  }

  Future<void> updateScript(Script script) {
    return ref.read(scriptsActionProvider.notifier).updateScript(script);
  }

  Future<void> _track(String key, Future<Object?> Function() task) async {
    final updatingKeys = ref.read(updatingKeysProvider.notifier);
    final operation = updatingKeys.start(key);
    try {
      await task();
    } finally {
      updatingKeys.stop(key, operation);
    }
  }

  /// A geo file fails here only when the Core turns the request down; a
  /// download that fails later reaches the user from [GeoResourceAction].
  Future<List<UpdatingMessage>> updateAll() async {
    final appLocalizations = currentAppLocalizations;
    final geoResourceAction = ref.read(geoResourceActionProvider.notifier);
    final failures = <UpdatingMessage>[];
    Future<void> update(
      String key,
      String label,
      Future<void> Function() task,
    ) async {
      if (ref.read(updatingKeysProvider).contains(key)) {
        return;
      }
      try {
        await task();
      } catch (e) {
        failures.add(
          UpdatingMessage(
            label: label,
            message: userFacingErrorMessage(e, appLocalizations),
          ),
        );
      }
    }

    final (iconSets, scripts, providers) = await (
      database.iconSetsDao.query().get(),
      database.scriptsDao.query().get(),
      database.clashProvidersDao.query().get(),
    ).wait;
    await Future.wait([
      for (final geoResource in GeoResource.values)
        update(
          geoResource.updatingKey,
          geoResource.name,
          () => geoResourceAction.updateGeoResource(
            geoResource,
            announceSuccess: false,
          ),
        ),
      for (final iconSet in iconSets)
        if (iconSet.isRemote)
          update(
            iconSet.updatingKey,
            iconSet.name,
            () => updateIconSet(iconSet),
          ),
      for (final provider in providers)
        if (provider.isRemote)
          update(
            provider.updatingKey,
            provider.label,
            () => updateRuleProvider(provider),
          ),
      for (final script in scripts)
        if (script.url != null)
          update(script.updatingKey, script.label, () => updateScript(script)),
    ]);
    return failures;
  }

  /// Geo files are left to the Core, which reads the same two settings.
  Future<void> autoUpdate() async {
    final setting = ref.read(patchClashConfigProvider);
    if (!setting.geoAutoUpdate || _autoUpdating) {
      return;
    }
    _autoUpdating = true;
    try {
      final interval = Duration(hours: setting.geoUpdateInterval);
      bool isDue(DateTime? lastUpdateTime) =>
          lastUpdateTime?.add(interval).isBeforeNow ?? true;
      for (final iconSet in await database.iconSetsDao.query().get()) {
        if (iconSet.isRemote && isDue(iconSet.lastUpdateTime)) {
          await _tryUpdate(iconSet.name, () => updateIconSet(iconSet));
        }
      }
      for (final script in await database.scriptsDao.query().get()) {
        if (script.url != null && isDue(script.lastUpdateTime)) {
          await _tryUpdate(script.label, () => updateScript(script));
        }
      }
      for (final provider in await database.clashProvidersDao.query().get()) {
        if (ref.read(coreStatusProvider) != CoreStatus.connected) {
          break;
        }
        if (provider.isRemote &&
            isDue((await provider.fileInfo)?.lastModified)) {
          await _tryUpdate(provider.label, () => updateRuleProvider(provider));
        }
      }
    } finally {
      _autoUpdating = false;
    }
  }

  Future<void> _tryUpdate(String label, Future<void> Function() update) async {
    try {
      await update();
    } catch (e) {
      commonPrint.log(
        'auto update $label: ${compactError(e)}',
        logLevel: LogLevel.warning,
      );
    }
  }
}
