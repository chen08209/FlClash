import 'package:fl_clash/features/icloud/reconcile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'first sync imports and exports without guessing between two versions',
    () {
      expect(reconcileYaml(local: 'a'), SyncDecision.upload);
      expect(reconcileYaml(remote: 'b'), SyncDecision.download);
      expect(reconcileYaml(local: 'a', remote: 'b'), SyncDecision.conflict);
      expect(reconcileYaml(local: 'a', remote: 'a'), SyncDecision.unchanged);
    },
  );

  test('only the side changed since the last common hash wins', () {
    expect(
      reconcileYaml(base: 'a', local: 'b', remote: 'a'),
      SyncDecision.upload,
    );
    expect(
      reconcileYaml(base: 'a', local: 'a', remote: 'b'),
      SyncDecision.download,
    );
    expect(
      reconcileYaml(base: 'a', local: 'b', remote: 'c'),
      SyncDecision.conflict,
    );
    expect(
      reconcileYaml(base: 'a', local: 'b', remote: 'b'),
      SyncDecision.unchanged,
    );
  });

  test(
    'deletion and cloud eviction never delete or overwrite the other side',
    () {
      for (final hash in ['a', 'b']) {
        expect(reconcileYaml(base: 'a', local: hash), SyncDecision.missing);
        expect(reconcileYaml(base: 'a', remote: hash), SyncDecision.missing);
      }
      expect(reconcileYaml(base: 'a'), SyncDecision.unchanged);
    },
  );
}
