import 'dart:async';
import 'dart:math';

import 'package:fl_clash/common/function.dart';
import 'package:test/test.dart';

void main() {
  group('Debouncer', () {
    const window = Duration(milliseconds: 20);

    test('runs the callback once the quiet window elapses', () async {
      final debouncer = Debouncer();
      var calls = 0;

      debouncer.call('tag', () => calls++, duration: window);
      expect(calls, 0);

      await Future<void>.delayed(window * 2);
      expect(calls, 1);
    });

    test('a later call replaces the pending one', () async {
      final debouncer = Debouncer();
      final seen = <String>[];

      debouncer.call('tag', () => seen.add('first'), duration: window);
      debouncer.call('tag', () => seen.add('second'), duration: window);
      await Future<void>.delayed(window * 2);

      expect(seen, ['second']);
    });

    test('separate tags do not replace each other', () async {
      final debouncer = Debouncer();
      final seen = <String>[];

      debouncer.call('a', () => seen.add('a'), duration: window);
      debouncer.call('b', () => seen.add('b'), duration: window);
      await Future<void>.delayed(window * 2);

      expect(seen..sort(), ['a', 'b']);
    });

    test('cancel stops a pending callback from ever running', () async {
      final debouncer = Debouncer();
      var calls = 0;

      debouncer.call('tag', () => calls++, duration: window);
      debouncer.cancel('tag');
      await Future<void>.delayed(window * 3);

      expect(calls, 0);
    });

    test('cancel only drops the tag it names', () async {
      final debouncer = Debouncer();
      final seen = <String>[];

      debouncer.call('keep', () => seen.add('keep'), duration: window);
      debouncer.call('drop', () => seen.add('drop'), duration: window);
      debouncer.cancel('drop');
      await Future<void>.delayed(window * 2);

      expect(seen, ['keep']);
    });

    test('a tag stays usable after being cancelled', () async {
      final debouncer = Debouncer();
      var calls = 0;

      debouncer.call('tag', () => calls++, duration: window);
      debouncer.cancel('tag');
      debouncer.call('tag', () => calls++, duration: window);
      await Future<void>.delayed(window * 2);

      expect(calls, 1);
    });

    test('a throwing callback is reported instead of escaping', () async {
      final debouncer = Debouncer();

      debouncer.call('tag', () => throw StateError('boom'), duration: window);
      await Future<void>.delayed(window * 2);
    });

    test('a rejected async callback is reported instead of escaping', () async {
      final debouncer = Debouncer();

      debouncer.call(
        'tag',
        () async => throw StateError('boom'),
        duration: window,
      );
      await Future<void>.delayed(window * 2);
    });

    test(
      'a value-returning async callback still reports its failure',
      () async {
        final debouncer = Debouncer();

        debouncer.call('tag', () async {
          await Future<void>.delayed(Duration.zero);
          throw StateError('boom');
        }, duration: window);
        await Future<void>.delayed(window * 3);
      },
    );
  });

  group('Throttler', () {
    const window = Duration(milliseconds: 20);

    test('reports whether a tag was already in flight', () {
      final throttler = Throttler();

      expect(throttler.call('tag', () {}, duration: window), isFalse);
      expect(throttler.call('tag', () {}, duration: window), isTrue);
    });

    test('runs the callback at the end of the window by default', () async {
      final throttler = Throttler();
      var calls = 0;

      throttler.call('tag', () => calls++, duration: window);
      expect(calls, 0);

      await Future<void>.delayed(window * 2);
      expect(calls, 1);
    });

    test('fire runs the callback immediately and then blocks', () async {
      final throttler = Throttler();
      var calls = 0;

      throttler.call('tag', () => calls++, duration: window, fire: true);
      expect(calls, 1);

      throttler.call('tag', () => calls++, duration: window, fire: true);
      expect(calls, 1);

      await Future<void>.delayed(window * 2);
      throttler.call('tag', () => calls++, duration: window, fire: true);
      expect(calls, 2);
    });

    test('cancel releases the tag without running the callback', () async {
      final throttler = Throttler();
      var calls = 0;

      throttler.call('tag', () => calls++, duration: window);
      throttler.cancel('tag');
      await Future<void>.delayed(window * 2);

      expect(calls, 0);
      expect(throttler.call('tag', () {}, duration: window), isFalse);
    });
  });

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
