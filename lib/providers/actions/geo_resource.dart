part of '../action.dart';

@Riverpod(keepAlive: true)
class GeoResourceAction extends _$GeoResourceAction {
  /// Whether each manual update announces a success; a failure always shows.
  final _manualUpdates = <GeoResource, bool>{};
  final _operations = <GeoResource, int>{};

  CoreController get _core => ref.read(coreHandlerProvider);

  @override
  void build() {
    ref.listen(coreStatusProvider, (_, next) {
      if (next != CoreStatus.connected) {
        _manualUpdates.clear();
        _operations.clear();
      }
    });
  }

  int _startUpdating(GeoResource geoResource) {
    return _operations.putIfAbsent(
      geoResource,
      () => ref
          .read(updatingKeysProvider.notifier)
          .start(geoResource.updatingKey, scope: UpdatingScope.core),
    );
  }

  void _stopUpdating(GeoResource geoResource, [int? operation]) {
    final current = _operations[geoResource];
    if (current == null || (operation != null && current != operation)) {
      return;
    }
    _operations.remove(geoResource);
    ref
        .read(updatingKeysProvider.notifier)
        .stop(geoResource.updatingKey, current);
  }

  /// Completes once the Core has accepted the update, not once it finishes.
  /// Completion arrives as a resource update through [handleCoreUpdate];
  /// callers that need it watch [isUpdatingProvider] for the key to clear.
  /// A request the Core turns down leaves an update already running as it
  /// was.
  Future<void> updateGeoResource(
    GeoResource geoResource, {
    bool announceSuccess = true,
  }) async {
    final running = _operations.containsKey(geoResource);
    final previous = _manualUpdates[geoResource];
    _manualUpdates[geoResource] = announceSuccess;
    final operation = _startUpdating(geoResource);
    try {
      await _core.api.updateGeo(geoResource.name);
    } catch (_) {
      if (previous != null) {
        _manualUpdates[geoResource] = previous;
      } else {
        _manualUpdates.remove(geoResource);
      }
      if (!running) {
        _stopUpdating(geoResource, operation);
      }
      rethrow;
    }
  }

  /// A fetch the Core cut short for a newer config or its shutdown ends
  /// without a banner: nothing failed that the user could act on.
  void handleCoreUpdate(String geoType, ResourcePhase phase, String error) {
    final geoResource = GeoResource.fromJson(geoType.toLowerCase());
    final updating = phase == ResourcePhase.updating;
    final announceSuccess = updating
        ? null
        : _manualUpdates.remove(geoResource);
    if (phase == ResourcePhase.failed) {
      if (announceSuccess != null && error != resourceSuperseded) {
        dialogs.showBanner(error, level: BannerLevel.error);
      }
    } else if (announceSuccess == true) {
      final l10n = currentAppLocalizations;
      final message = phase == ResourcePhase.unchanged
          ? l10n.geoSkipped(geoResource.name)
          : l10n.geoUpdated(geoResource.name);
      dialogs.showBanner(message);
    }
    if (updating) {
      _startUpdating(geoResource);
    } else {
      _stopUpdating(geoResource);
    }
  }

  /// An update whose end was among the events lost can be asked about
  /// nowhere, so its key would never clear; it is let go and may run again.
  void forgetUpdates() {
    for (final geoResource in List.of(_operations.keys)) {
      _stopUpdating(geoResource);
    }
    _manualUpdates.clear();
  }

  void updateGeoResourceUrl(GeoResource geoResource, String newUrl) {
    if (!newUrl.isUrl) {
      throw ArgumentError.value(newUrl, 'newUrl', 'Not a valid URL');
    }
    ref.read(patchClashConfigProvider.notifier).update((state) {
      return state.copyWith(geoXUrl: {...state.geoXUrl, geoResource: newUrl});
    });
  }
}
