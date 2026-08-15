import 'package:fl_clash/state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('crash test availability', () {
    test('is enabled for debug builds', () {
      expect(
        GlobalState.canCrashCoreFor(isDebug: true, appEnv: 'stable'),
        isTrue,
      );
    });

    test('is enabled for dev builds', () {
      expect(
        GlobalState.canCrashCoreFor(isDebug: false, appEnv: 'dev'),
        isTrue,
      );
    });

    test('is disabled for pre and stable release builds', () {
      expect(
        GlobalState.canCrashCoreFor(isDebug: false, appEnv: 'pre'),
        isFalse,
      );
      expect(
        GlobalState.canCrashCoreFor(isDebug: false, appEnv: 'stable'),
        isFalse,
      );
    });
  });
}
