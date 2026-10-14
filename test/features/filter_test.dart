import 'package:fl_clash/features/form/filter.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('filter parts', () {
    const asia = Filter(label: 'Asia', regex: 'hk`jp');

    test('a preset is applied only once every part is there', () {
      expect(asia.isAppliedTo('mine`hk`jp'), isTrue);
      expect(asia.isAppliedTo('jp`kr'), isFalse);
      expect(asia.isAppliedTo(null), isFalse);
    });

    test('drops the empty parts mihomo would match everything with', () {
      expect(filterParts('hk``jp`'), ['hk', 'jp']);
      expect(joinFilterParts(['hk', 'jp']), 'hk`jp');
      expect(joinFilterParts(const []), isNull);
    });
  });
}
