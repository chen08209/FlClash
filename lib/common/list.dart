extension ListExtension<T> on List<T> {
  List<T> intersection(List<T> list) {
    return where((item) => list.contains(item)).toList();
  }
}