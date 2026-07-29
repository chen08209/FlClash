import 'package:test/test.dart';

import '../setup.dart' as setup;

void main() {
  group('setup.dart', () {
    test('parses -v as verbose mode', () {
      final results = setup.createSetupArgParser().parse(['android', '-v']);

      expect(results['verbose'], isTrue);
      expect(results.rest, ['android']);
    });

    test('omits verbose from flutter build args by default', () {
      final args = setup.createFlutterBuildArgs(
        platform: 'android',
        rootDir: '.',
        verbose: false,
      );

      expect(args, [
        'dart-define-from-file=env.json',
        'obfuscate',
        'split-debug-info=build/symbols/android',
        'tree-shake-icons',
        'split-per-abi',
      ]);
    });

    test('adds verbose to flutter build args with -v', () {
      final args = setup.createFlutterBuildArgs(
        platform: 'android',
        rootDir: '.',
        verbose: true,
      );

      expect(args, [
        'verbose',
        'dart-define-from-file=env.json',
        'obfuscate',
        'split-debug-info=build/symbols/android',
        'tree-shake-icons',
        'split-per-abi',
      ]);
    });
  });
}
