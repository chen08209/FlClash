import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:test/test.dart';

typedef _Item = ({String id, String network, String app});

final _facets = <RecordFacet<_Item>>[
  RecordFacet(
    RecordFacetKind.network,
    (item) => [item.network],
    offered: true,
    order: const ['tcp', 'udp'],
  ),
  RecordFacet(RecordFacetKind.app, (item) => [item.app]),
];

_Item _item(String id, {String network = 'tcp', String app = 'curl'}) =>
    (id: id, network: network, app: app);

List<String> _ids(Iterable<_Item> items) => [for (final item in items) item.id];

void main() {
  group('whereFilters', () {
    final items = [
      _item('a'),
      _item('b', network: 'udp'),
      _item('c', app: 'chrome'),
      _item('d', network: 'udp', app: 'chrome'),
    ];

    test('widens within a facet and narrows across facets', () {
      expect(
        _ids(
          items.whereFilters(_facets, const [
            RecordFilter(RecordFacetKind.network, 'tcp'),
            RecordFilter(RecordFacetKind.network, 'udp'),
          ]),
        ),
        ['a', 'b', 'c', 'd'],
      );
      expect(
        _ids(
          items.whereFilters(_facets, const [
            RecordFilter(RecordFacetKind.network, 'udp'),
            RecordFilter(RecordFacetKind.app, 'chrome'),
          ]),
        ),
        ['d'],
      );
    });

    test('ignores a filter on a facet the list lacks', () {
      expect(
        _ids(
          items.whereFilters(_facets, const [
            RecordFilter(RecordFacetKind.level, 'error'),
          ]),
        ),
        ['a', 'b', 'c', 'd'],
      );
    });
  });

  group('RecordFacet.optionsOf', () {
    test('lists the values present in their order', () {
      final options = _facets.first.optionsOf([
        _item('a', network: 'udp'),
        _item('b'),
      ]);
      expect(options, ['tcp', 'udp']);
    });

    test('keeps the most frequent values and every selected one', () {
      final facet = RecordFacet<_Item>(
        RecordFacetKind.app,
        (item) => [item.app],
      );
      final items = [
        for (var i = 0; i < 30; i++)
          for (var j = 0; j <= i; j++) _item('$i-$j', app: 'app$i'),
      ];
      final options = facet.optionsOf(items, selected: ['gone']);
      expect(options, hasLength(recordFacetMaxOptions + 1));
      expect(options, contains('gone'));
      expect(options, contains('app29'));
      expect(options, isNot(contains('app0')));
    });

    test('leaves out empty values', () {
      expect(_facets.last.optionsOf([_item('a', app: '')]), isEmpty);
    });
  });
}
