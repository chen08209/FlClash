part of '../action.dart';

@Riverpod(keepAlive: true)
class GeoResourceAction extends _$GeoResourceAction {
  CoreController get _core => ref.read(coreHandlerProvider);

  @override
  void build() {}

  Future<void> updateGeoResource(GeoResource geoResource) async {
    await _core.updateGeoData(geoResource.name);
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
