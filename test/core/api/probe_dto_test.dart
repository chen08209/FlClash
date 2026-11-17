import 'package:fl_clash/core/api/dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a service item reads the address its service saw, if any', () {
    final item = ServiceItem.fromJson({
      'name': 'claude',
      'status': 'available',
      'region': 'US',
      'ip': '198.51.100.9',
      'checkedAt': 1,
      'epoch': 1,
      'version': 2,
    });
    expect(item.ip, '198.51.100.9');

    final older = ServiceItem.fromJson({
      'name': 'google',
      'status': 'available',
      'checkedAt': 1,
      'epoch': 1,
      'version': 2,
    });
    expect(older.ip, isEmpty);
  });
}
