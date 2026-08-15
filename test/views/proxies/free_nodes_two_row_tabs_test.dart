import 'package:fl_clash/views/proxies/tab.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('free node group tab layout', () {
    test('free node profile uses two rows when there are multiple groups', () {
      expect(
        shouldUseTwoRowFreeNodesGroupTabs(
          isFreeNodesProfile: true,
          groupCount: 8,
        ),
        isTrue,
      );
    });

    test('normal profiles keep the upstream single-row tab layout', () {
      expect(
        shouldUseTwoRowFreeNodesGroupTabs(
          isFreeNodesProfile: false,
          groupCount: 8,
        ),
        isFalse,
      );
    });

    test('a single free node group does not waste a second row', () {
      expect(
        shouldUseTwoRowFreeNodesGroupTabs(
          isFreeNodesProfile: true,
          groupCount: 1,
        ),
        isFalse,
      );
    });
  });
}
