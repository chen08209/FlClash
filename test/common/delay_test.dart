import 'package:fl_clash/models/common.dart';
import 'package:test/test.dart';

void main() {
  group('DelayStateExt.priority', () {
    test('returns 0 for positive delay', () {
      expect(const DelayState(delay: 100, group: false).priority, 0);
      expect(const DelayState(delay: 1, group: false).priority, 0);
    });

    test('returns 1 for zero delay', () {
      expect(const DelayState(delay: 0, group: false).priority, 1);
    });

    test('returns 2 for negative delay', () {
      expect(const DelayState(delay: -1, group: false).priority, 2);
    });
  });

  group('DelayStateExt.compareTo', () {
    test('positive delay comes before zero delay', () {
      const a = DelayState(delay: 100, group: false);
      const b = DelayState(delay: 0, group: false);
      expect(a.compareTo(b), lessThan(0));
      expect(b.compareTo(a), greaterThan(0));
    });

    test('zero delay comes before negative delay', () {
      const a = DelayState(delay: 0, group: false);
      const b = DelayState(delay: -1, group: false);
      expect(a.compareTo(b), lessThan(0));
      expect(b.compareTo(a), greaterThan(0));
    });

    test('positive delay comes before negative delay', () {
      const a = DelayState(delay: 100, group: false);
      const b = DelayState(delay: -1, group: false);
      expect(a.compareTo(b), lessThan(0));
    });

    test('sorts by delay within same priority', () {
      const a = DelayState(delay: 50, group: false);
      const b = DelayState(delay: 200, group: false);
      expect(a.compareTo(b), lessThan(0));
      expect(b.compareTo(a), greaterThan(0));
    });

    test(
      'group=true sorts before group=false within same priority and delay',
      () {
        const a = DelayState(delay: 100, group: true);
        const b = DelayState(delay: 100, group: false);
        expect(a.compareTo(b), lessThan(0));
      },
    );

    test(
      'group=false sorts after group=true within same priority and delay',
      () {
        const a = DelayState(delay: 100, group: false);
        const b = DelayState(delay: 100, group: true);
        expect(a.compareTo(b), greaterThan(0));
      },
    );

    test('returns 0 for equal states', () {
      const a = DelayState(delay: 100, group: true);
      const b = DelayState(delay: 100, group: true);
      expect(a.compareTo(b), 0);
    });

    test('returns 0 when both group=false and same delay', () {
      const a = DelayState(delay: 100, group: false);
      const b = DelayState(delay: 100, group: false);
      expect(a.compareTo(b), 0);
    });
  });

  group('DelayState list sort', () {
    test('sorts by priority, delay, then group', () {
      final list = [
        const DelayState(delay: -1, group: false),
        const DelayState(delay: 200, group: false),
        const DelayState(delay: 0, group: false),
        const DelayState(delay: 50, group: true),
        const DelayState(delay: 50, group: false),
        const DelayState(delay: 0, group: true),
      ];
      list.sort((a, b) => a.compareTo(b));
      expect(list, [
        const DelayState(delay: 50, group: true),
        const DelayState(delay: 50, group: false),
        const DelayState(delay: 200, group: false),
        const DelayState(delay: 0, group: true),
        const DelayState(delay: 0, group: false),
        const DelayState(delay: -1, group: false),
      ]);
    });
  });
}
