import 'package:fl_clash/views/proxies/proxies.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'refreshes proxy groups when entering proxies page with empty groups',
    () {
      expect(
        shouldRefreshGroupsOnProxiesEnter(
          isProxiesPage: true,
          hasGroups: false,
        ),
        isTrue,
      );
    },
  );

  test(
    'does not refresh proxy groups outside proxies page or when groups exist',
    () {
      expect(
        shouldRefreshGroupsOnProxiesEnter(
          isProxiesPage: false,
          hasGroups: false,
        ),
        isFalse,
      );
      expect(
        shouldRefreshGroupsOnProxiesEnter(isProxiesPage: true, hasGroups: true),
        isFalse,
      );
    },
  );

  test(
    'applies free nodes profile when entering proxies page with empty groups',
    () {
      expect(
        shouldApplyProfileOnProxiesEnter(
          isProxiesPage: true,
          hasGroups: false,
          isFreeNodesProfile: true,
        ),
        isTrue,
      );
      expect(
        shouldApplyProfileOnProxiesEnter(
          isProxiesPage: true,
          hasGroups: true,
          isFreeNodesProfile: true,
        ),
        isFalse,
      );
      expect(
        shouldApplyProfileOnProxiesEnter(
          isProxiesPage: true,
          hasGroups: false,
          isFreeNodesProfile: false,
        ),
        isFalse,
      );
    },
  );
}
