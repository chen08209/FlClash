part of '../action.dart';

@Riverpod(keepAlive: true)
class GeoResourceAction extends _$GeoResourceAction {
  final _manualUpdates = <GeoResource>{};
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

  Future<void> updateGeoResource(GeoResource geoResource) async {
    _manualUpdates.add(geoResource);
    final operation = _startUpdating(geoResource);
    try {
      final message = await _core.updateGeoData(geoResource.name);
      if (message.isNotEmpty) {
        throw MessageException(message);
      }
    } catch (_) {
      _manualUpdates.remove(geoResource);
      _stopUpdating(geoResource, operation);
      rethrow;
    }
  }

  void handleCoreUpdate(
    String geoType,
    bool updating,
    bool skipped,
    String? error,
  ) {
    final geoResource = GeoResource.fromJson(geoType.toLowerCase());
    final shouldNotify = !updating && _manualUpdates.remove(geoResource);
    if (shouldNotify && (error == null || error.isEmpty)) {
      final l10n = currentAppLocalizations;
      final message = skipped
          ? l10n.geoSkipped(geoResource.name)
          : l10n.geoUpdated(geoResource.name);
      dialogs.showNotifier(message);
    }
    if (updating) {
      _startUpdating(geoResource);
    } else {
      _stopUpdating(geoResource);
    }
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
