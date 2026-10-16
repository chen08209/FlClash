import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

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

  group('KeyboardModifier', () {
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
      expect(RuleTarget.baseTargets, {
        'DIRECT',
        'REJECT',
        'REJECT-DROP',
        'PASS',
        'PASS-RULE',
        'COMPATIBLE',
      });
    });

    test('lets a rule name the GLOBAL the core adds', () {
      expect(RuleTarget.ruleTargets, {...RuleTarget.baseTargets, 'GLOBAL'});
    });
  });

  group('ItemPosition', () {
    test('calculates simple list positions', () {
      expect(ItemPosition.get(0, 1), ItemPosition.startAndEnd);
      expect(ItemPosition.get(0, 3), ItemPosition.start);
      expect(ItemPosition.get(1, 3), ItemPosition.middle);
      expect(ItemPosition.get(2, 3), ItemPosition.end);
    });
  });
}
