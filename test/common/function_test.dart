import 'dart:async';
import 'dart:math';

import 'package:fl_clash/common/function.dart';
import 'package:test/test.dart';

void main() {
  group('SerialTaskScheduler', () {
    test('serializes tasks in submission order', () async {
      final scheduler = SerialTaskScheduler();
      final firstStarted = Completer<void>();
      final releaseFirst = Completer<void>();
      final events = <String>[];
      var runningTasks = 0;
      var maxRunningTasks = 0;

      final first = scheduler.run(() async {
        runningTasks++;
        maxRunningTasks = max(maxRunningTasks, runningTasks);
        firstStarted.complete();
        await releaseFirst.future;
        events.add('first');
        runningTasks--;
      });
      await firstStarted.future;

      final second = scheduler.run(() async {
        runningTasks++;
        maxRunningTasks = max(maxRunningTasks, runningTasks);
        events.add('second');
        runningTasks--;
      });
      await Future<void>.delayed(Duration.zero);

      expect(events, isEmpty);
      releaseFirst.complete();
      await Future.wait([first, second]);

      expect(events, ['first', 'second']);
      expect(maxRunningTasks, 1);
    });

    test('continues after a failed serialized task', () async {
      final scheduler = SerialTaskScheduler();

      await expectLater(
        scheduler.run<void>(() async {
          throw StateError('failed');
        }),
        throwsStateError,
      );

      final result = await scheduler.run(() async => 'next');
      expect(result, 'next');
    });
  });

  group('retry', () {
    test('returns immediately when first result does not need retry', () async {
      var attempts = 0;

      final result = await retry(
        task: () async {
          attempts++;
          return 'done';
        },
        retryIf: (res) => res != 'done',
        delay: Duration.zero,
      );

      expect(result, 'done');
      expect(attempts, 1);
    });

    test('retries until result no longer matches retry condition', () async {
      var attempts = 0;

      final result = await retry(
        task: () async {
          attempts++;
          return attempts < 3 ? 'pending' : 'done';
        },
        retryIf: (res) => res == 'pending',
        delay: Duration.zero,
        maxAttempts: 5,
      );

      expect(result, 'done');
      expect(attempts, 3);
    });

    test('returns last result when max attempts are exhausted', () async {
      var attempts = 0;

      final result = await retry(
        task: () async {
          attempts++;
          return false;
        },
        retryIf: (res) => res == false,
        delay: Duration.zero,
        maxAttempts: 3,
      );

      expect(result, false);
      expect(attempts, 3);
    });

    test('waits between retry attempts', () async {
      var attempts = 0;

      final future = retry(
        task: () async {
          attempts++;
          return attempts < 2 ? 'pending' : 'done';
        },
        retryIf: (res) => res == 'pending',
        delay: const Duration(milliseconds: 50),
        maxAttempts: 2,
      );

      await Future.delayed(const Duration(milliseconds: 10));
      expect(attempts, 1);

      final result = await future;

      expect(result, 'done');
      expect(attempts, 2);
    });
  });
}
