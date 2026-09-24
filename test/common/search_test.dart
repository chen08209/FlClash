import 'package:fl_clash/common/search.dart';
import 'package:test/test.dart';

void main() {
  group('SearchQuery', () {
    test('blank text is an empty query that matches everything', () {
      final query = SearchQuery('  \t ');
      expect(query.isEmpty, isTrue);
      expect(query.matches(const []), isTrue);
    });

    test('splits on whitespace and lowers the case', () {
      expect(SearchQuery('  HK   Node\t1 ').terms, ['hk', 'node', '1']);
    });

    test('matches a field regardless of case', () {
      expect(SearchQuery('google').matches(['www.Google.com']), isTrue);
      expect(SearchQuery('GOOGLE').matches(['www.google.com']), isTrue);
    });

    test('every term has to match, each in any field', () {
      final fields = ['example.com', 'DIRECT', 'chrome'];
      expect(SearchQuery('example chrome').matches(fields), isTrue);
      expect(SearchQuery('chrome direct').matches(fields), isTrue);
      expect(SearchQuery('example firefox').matches(fields), isFalse);
    });

    test('a term does not span two fields', () {
      expect(SearchQuery('comdirect').matches(['a.com', 'direct']), isFalse);
    });

    test('ignores null fields', () {
      expect(SearchQuery('tcp').matches([null, 'tcp']), isTrue);
      expect(SearchQuery('tcp').matches([null]), isFalse);
    });
  });

  group('whereMatches', () {
    final items = ['Alpha', 'Beta', 'Gamma'];

    test('keeps every item for an empty query', () {
      expect(items.whereMatches(SearchQuery(''), (item) => [item]), items);
    });

    test('keeps the order of the items that match', () {
      expect(
        items.whereMatches(SearchQuery('a'), (item) => [item]).toList(),
        items,
      );
      expect(items.whereMatches(SearchQuery('MA'), (item) => [item]).toList(), [
        'Gamma',
      ]);
    });

    test('builds an object\'s text once across searches', () {
      final objects = [for (final item in items) _Named(item)];
      final texts = Expando<String>();
      var built = 0;
      List<String> search(String text) => objects
          .whereMatches(SearchQuery(text), (object) {
            built++;
            return [object.name];
          }, texts: texts)
          .map((object) => object.name)
          .toList();

      expect(search('a'), items);
      expect(search('ma'), ['Gamma']);
      expect(built, objects.length);
    });

    test('searches values an expando cannot hold without caching', () {
      final texts = Expando<String>();
      expect(
        items
            .whereMatches(SearchQuery('beta'), (item) => [item], texts: texts)
            .toList(),
        ['Beta'],
      );
    });
  });
}

class _Named {
  final String name;

  _Named(this.name);
}
