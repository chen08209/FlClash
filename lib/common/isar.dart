import 'package:isar_community/isar.dart';

extension IsarCollectionExt<T> on IsarCollection<T> {
  Future<void> setAll(
    List<T> items, {
    required Id Function(T) getId,
    required Future<List<Id>> Function(IsarCollection<T> col) getIdsInDb,
  }) async {
    final newIds = items.map(getId).toSet();
    List<Id> currentIds;
    currentIds = await getIdsInDb(this);
    final idsToDelete = currentIds.where((id) => !newIds.contains(id)).toList();
    if (idsToDelete.isNotEmpty) {
      await deleteAll(idsToDelete);
    }
    if (items.isNotEmpty) {
      await putAll(items);
    }
  }
}
