import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the strip check copies neither Cargo output nor the old Go core', () {
    final script = File('tool/strip_check.sh').readAsStringSync();

    expect(script, contains('--exclude /concord/target'));
    expect(script, isNot(contains('Clash.Meta')));
  });
}
