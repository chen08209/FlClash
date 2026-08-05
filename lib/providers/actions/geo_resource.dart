part of '../action.dart';

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
