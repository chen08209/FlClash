import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

void main() {
  group('GroupType', () {
    test('parses clash group type aliases case-insensitively', () {
      expect(GroupType.parse('url-test'), GroupType.URLTest);
      expect(GroupType.parse('URLTEST'), GroupType.URLTest);
      expect(GroupType.parse('selector'), GroupType.Selector);
      expect(GroupType.parse('loadbalance'), GroupType.LoadBalance);
    });

    test('throws for unsupported group type', () {
      expect(() => GroupType.parse('unknown'), throwsUnimplementedError);
    });
  });

  group('GroupTypeExtension', () {
    test('maps display names back to enum values', () {
      expect(GroupTypeExtension.getGroupType('Selector'), GroupType.Selector);
      expect(GroupTypeExtension.getGroupType('URLTest'), GroupType.URLTest);
      expect(GroupTypeExtension.getGroupType('missing'), isNull);
    });

    test('marks only computed selection types', () {
      expect(GroupType.URLTest.isComputedSelected, isTrue);
      expect(GroupType.Fallback.isComputedSelected, isTrue);
      expect(GroupType.Selector.isComputedSelected, isFalse);
    });
  });

  group('UsedProxyExtension', () {
    test('returns enum names as proxy values', () {
      expect(UsedProxy.GLOBAL.value, 'GLOBAL');
      expect(UsedProxy.DIRECT.value, 'DIRECT');
      expect(UsedProxy.REJECT.value, 'REJECT');
    });
  });

  group('KeyboardModifierExt', () {
    test('maps keyboard modifiers to hotkey modifiers', () {
      expect(KeyboardModifier.alt.toHotKeyModifier(), HotKeyModifier.alt);
      expect(
        KeyboardModifier.control.toHotKeyModifier(),
        HotKeyModifier.control,
      );
      expect(KeyboardModifier.shift.toHotKeyModifier(), HotKeyModifier.shift);
    });

    test('keeps platform key variants for paired modifiers', () {
      expect(KeyboardModifier.alt.physicalKeys, [
        PhysicalKeyboardKey.altLeft,
        PhysicalKeyboardKey.altRight,
      ]);
      expect(KeyboardModifier.meta.physicalKeys, [
        PhysicalKeyboardKey.metaLeft,
        PhysicalKeyboardKey.metaRight,
      ]);
    });
  });

  group('RuleAction', () {
    test('excludes actions that cannot be manually added', () {
      expect(RuleAction.addedRuleActions, isNot(contains(RuleAction.MATCH)));
      expect(RuleAction.addedRuleActions, isNot(contains(RuleAction.RULE_SET)));
      expect(RuleAction.addedRuleActions, isNot(contains(RuleAction.SUB_RULE)));
      expect(RuleAction.addedRuleActions, contains(RuleAction.DOMAIN));
    });

    test('identifies actions with extra params', () {
      expect(RuleAction.GEOIP.hasParams, isTrue);
      expect(RuleAction.IP_CIDR.hasParams, isTrue);
      expect(RuleAction.DOMAIN.hasParams, isFalse);
    });
  });

  group('RuleTarget', () {
    test('contains built-in target names', () {
      expect(RuleTarget.baseTargets, {'DIRECT', 'REJECT'});
    });
  });

  group('ItemPosition', () {
    test('calculates simple list positions', () {
      expect(ItemPosition.get(0, 1), ItemPosition.startAndEnd);
      expect(ItemPosition.get(0, 3), ItemPosition.start);
      expect(ItemPosition.get(1, 3), ItemPosition.middle);
      expect(ItemPosition.get(2, 3), ItemPosition.end);
    });

    test('calculates visual positions after deleted items are skipped', () {
      final items = ['a', 'b', 'c', 'd'];
      final deletedItems = {'a', 'c'};

      expect(
        ItemPosition.calculateVisualPosition(1, items, deletedItems),
        ItemPosition.start,
      );
      expect(
        ItemPosition.calculateVisualPosition(3, items, deletedItems),
        ItemPosition.end,
      );
    });

    test('deleted current item has no visual position', () {
      expect(
        ItemPosition.calculateVisualPosition(1, ['a', 'b'], {'b'}),
        ItemPosition.middle,
      );
    });
  });
}
