import 'package:fl_clash/common/window.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_desktop_window.dart';

void main() {
  test('a hide or show the platform refuses leaves the window as it was, '
      'taking focus or not', () async {
    final refused = <String>{};
    FakeDesktopWindow((call) {
      if (refused.contains(call.method)) {
        throw StateError('${call.method} refused');
      }
      return null;
    }).install();
    final window = Window();

    await window.show();
    expect(window.shown.value, isTrue);

    refused.add('hide');
    await expectLater(window.hide(), throwsStateError);
    expect(window.shown.value, isTrue);

    refused.clear();
    await window.hide();
    expect(window.shown.value, isFalse);

    refused.add('show');
    await expectLater(window.show(), throwsStateError);
    expect(window.shown.value, isFalse);

    refused
      ..clear()
      ..add('focus');
    await expectLater(window.show(), throwsStateError);
    expect(window.shown.value, isTrue);
  });
}
