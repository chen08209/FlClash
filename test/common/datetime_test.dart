import 'package:fl_clash/common/datetime.dart';
import 'package:test/test.dart';

void main() {
  group('DateTimeExtension', () {
    test('detects dates before now', () {
      expect(
        DateTime.now().subtract(const Duration(milliseconds: 1)).isBeforeNow,
        isTrue,
      );
    });

    test('isBeforeSecure keeps null as false and non-null as true', () {
      final dateTime = DateTime(2026, 5, 27);

      expect(dateTime.isBeforeSecure(null), isFalse);
      expect(dateTime.isBeforeSecure(DateTime(2026, 5, 26)), isTrue);
      expect(dateTime.isBeforeSecure(DateTime(2026, 5, 28)), isTrue);
    });

    test('formats date, full datetime, and time slices', () {
      final dateTime = DateTime(2026, 5, 27, 14, 3, 9);

      expect(dateTime.show, '2026-05-27');
      expect(dateTime.showFull, '2026-05-27 14:03:09');
      expect(dateTime.showTime, ' 14:03:09');
    });
  });
}
