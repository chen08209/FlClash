import 'package:fl_clash/application.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('startup free nodes ensure is not duplicated after global attach', () {
    expect(
      shouldRunStartupFreeNodesEnsure(didAttachInitializeApp: true),
      false,
      reason:
          'GlobalState attach already ensured free nodes, so Application must not start the same check again',
    );
  });

  test('startup free nodes ensure runs when app was already attached', () {
    expect(
      shouldRunStartupFreeNodesEnsure(didAttachInitializeApp: false),
      true,
      reason: 'Application must cover the already-attached startup path',
    );
  });

  test('startup free nodes ensure still runs when navigator is late', () {
    expect(
      shouldRunNavigatorFallbackFreeNodesEnsure(
        mounted: true,
        hasNavigatorContext: false,
      ),
      true,
      reason:
          'free nodes daily check must not be skipped just because navigator context was late',
    );
    expect(
      shouldRunNavigatorFallbackFreeNodesEnsure(
        mounted: false,
        hasNavigatorContext: false,
      ),
      false,
    );
    expect(
      shouldRunNavigatorFallbackFreeNodesEnsure(
        mounted: true,
        hasNavigatorContext: true,
      ),
      false,
    );
  });

  test('startup profile auto update skips free nodes after ensure started', () {
    expect(
      shouldIncludeFreeNodesInStartupProfileAutoUpdate(
        freeNodesEnsureAlreadyStarted: true,
      ),
      false,
      reason:
          'startup already started the visible free-nodes check; the generic profile updater must not trigger it again',
    );
    expect(
      shouldIncludeFreeNodesInStartupProfileAutoUpdate(
        freeNodesEnsureAlreadyStarted: false,
      ),
      true,
    );
  });
}
