extension ListExtension<T> on List<T> {
  List<T> intersection(List<T> list) {
    return where((item) => list.contains(item)).toList();
  }

  List<List<T>> batch(int maxConcurrent) {
    final batches = (length / maxConcurrent).ceil();
    final List<List<T>> res = [];
    for (int i = 0; i < batches; i++) {
      if (i != batches - 1) {
        res.add(sublist(i * maxConcurrent, maxConcurrent * (i + 1)));
      } else {
        res.add(sublist(i * maxConcurrent, length));
      }
    }
    return res;
  }
}
