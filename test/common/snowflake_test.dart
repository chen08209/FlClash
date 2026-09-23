import 'package:fl_clash/common/snowflake.dart';
import 'package:test/test.dart';

void main() {
  group('Snowflake', () {
    test('generates positive IDs', () {
      final id = snowflake.id;
      expect(id, greaterThan(0));
    });

    test('generates unique sequential IDs', () {
      final ids = <int>{};
      for (int i = 0; i < 1000; i++) {
        ids.add(snowflake.id);
      }
      expect(ids.length, 1000);
    });

    test('IDs are monotonically increasing', () {
      final ids = List.generate(100, (_) => snowflake.id);
      for (int i = 1; i < ids.length; i++) {
        expect(ids[i], greaterThan(ids[i - 1]));
      }
    });

    test('buildId returns provided id when non-null', () {
      expect(Snowflake.buildId(42), 42);
      expect(Snowflake.buildId(0), 0);
    });

    test('buildId generates id when null', () {
      final id = Snowflake.buildId(null);
      expect(id, greaterThan(0));
    });
  });
}
