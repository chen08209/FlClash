import 'package:fl_clash/manager/app_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resume free nodes check runs only after app initialization', () {
    expect(shouldCheckFreeNodesOnResume(initialized: false), false);
    expect(shouldCheckFreeNodesOnResume(initialized: true), true);
  });
}
