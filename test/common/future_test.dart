import 'dart:async';

import 'package:fl_clash/common/future.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FutureExt.withTimeout', () {
    test('returns the value when it completes before the timeout', () async {
      final result = await Future<int>.value(
        7,
      ).withTimeout(timeout: const Duration(seconds: 1));

      expect(result, 7);
    });

    test('throws TimeoutException tagged with the supplied tag', () async {
      final pending = Completer<int>();
      addTearDown(() => pending.complete(0));

      await expectLater(
        pending.future.withTimeout(
          timeout: const Duration(milliseconds: 10),
          tag: 'fetchProfile',
        ),
        throwsA(
          isA<TimeoutException>().having(
            (error) => error.message,
            'message',
            'fetchProfile timeout',
          ),
        ),
      );
    });

    test('prefers onTimeout over throwing', () async {
      final pending = Completer<int>();
      addTearDown(() => pending.complete(0));

      final result = await pending.future.withTimeout(
        timeout: const Duration(milliseconds: 10),
        onTimeout: () => -1,
      );

      expect(result, -1);
    });

    test('cancels the onLast timer when the value arrives in time', () async {
      var lastCalls = 0;

      await Future<int>.value(1).withTimeout(
        timeout: const Duration(milliseconds: 50),
        onLast: () => lastCalls++,
      );
      await Future<void>.delayed(const Duration(milliseconds: 450));

      expect(lastCalls, 0);
    });

    test(
      'runs onLast after the timeout when the future never settles',
      () async {
        var lastCalls = 0;
        final pending = Completer<int>();
        addTearDown(() => pending.complete(0));

        await pending.future.withTimeout(
          timeout: const Duration(milliseconds: 50),
          onLast: () => lastCalls++,
          onTimeout: () => 0,
        );

        expect(lastCalls, 0);
        await Future<void>.delayed(const Duration(milliseconds: 400));
        expect(lastCalls, 1);
      },
    );

    test('cancels the onLast timer when the future fails', () async {
      var lastCalls = 0;

      await expectLater(
        Future<int>.error(StateError('boom')).withTimeout(
          timeout: const Duration(milliseconds: 50),
          onLast: () => lastCalls++,
        ),
        throwsStateError,
      );
      await Future<void>.delayed(const Duration(milliseconds: 450));

      expect(lastCalls, 0);
    });
  });

  group('CompleterExt.safeCompleter', () {
    test('completes a pending completer', () async {
      final completer = Completer<String>();

      completer.safeCompleter('value');

      expect(await completer.future, 'value');
    });

    test('ignores a second completion instead of throwing', () async {
      final completer = Completer<String>()..complete('first');

      expect(() => completer.safeCompleter('second'), returnsNormally);
      expect(await completer.future, 'first');
    });
  });
}
