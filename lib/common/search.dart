final _termSeparator = RegExp(r'\s+');

class SearchQuery {
  final List<String> terms;

  SearchQuery(String text)
    : terms = text
          .toLowerCase()
          .split(_termSeparator)
          .where((term) => term.isNotEmpty)
          .toList(growable: false);

  bool get isEmpty => terms.isEmpty;

  bool get isNotEmpty => terms.isNotEmpty;

  // Terms hold no whitespace, so the newline keeps one from spanning fields.
  static String textOf(Iterable<String?> fields) {
    return fields.nonNulls.join('\n').toLowerCase();
  }

  bool matches(Iterable<String?> fields) {
    if (terms.isEmpty) {
      return true;
    }
    return matchesText(textOf(fields));
  }

  bool matchesText(String text) => terms.every(text.contains);
}

extension SearchIterableExt<T> on Iterable<T> {
  /// [texts] caches each item's text by identity, so it serves one [fieldsOf].
  Iterable<T> whereMatches(
    SearchQuery query,
    Iterable<String?> Function(T item) fieldsOf, {
    Expando<String>? texts,
  }) {
    if (query.isEmpty) {
      return this;
    }
    return where((item) {
      if (texts == null || !_isExpandoKey(item)) {
        return query.matches(fieldsOf(item));
      }
      return query.matchesText(
        texts[item as Object] ??= SearchQuery.textOf(fieldsOf(item)),
      );
    });
  }
}

bool _isExpandoKey(Object? item) {
  return item != null &&
      item is! String &&
      item is! num &&
      item is! bool &&
      item is! Record;
}
