import 'package:fl_clash/providers/action.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('free node interrupted fetch decisions', () {
    test(
      'same-day interrupted session forces an update even when nothing is due',
      () {
        final decision = resolveFreeNodesAutoUpdateDecision(
          fileExists: true,
          hasLastUpdateDate: true,
          hasDueSources: false,
          hasInterruptedSession: true,
        );

        expect(decision.shouldUpdate, isTrue);
        expect(decision.kind, FreeNodesAutoUpdateKind.firstFetch);
      },
    );

    test('resume start progress is explicitly visible to the user', () {
      final progress = buildFreeNodesAutoUpdateStartProgress(
        firstLaunch: false,
        resuming: true,
        proxyCount: 3210,
      );

      expect(progress.operation, contains('继续'));
      expect(progress.proxyCount, 3210);
      expect(progress.startedAt, isNotNull);
    });

    test('deferred resume is scheduled only after startup initialization', () {
      expect(
        shouldScheduleDeferredFreeNodesResume(
          initialized: true,
          hasInterruptedSession: true,
        ),
        isTrue,
      );
      expect(
        shouldScheduleDeferredFreeNodesResume(
          initialized: false,
          hasInterruptedSession: true,
        ),
        isFalse,
      );
      expect(
        shouldScheduleDeferredFreeNodesResume(
          initialized: true,
          hasInterruptedSession: false,
        ),
        isFalse,
      );
    });
  });
}
