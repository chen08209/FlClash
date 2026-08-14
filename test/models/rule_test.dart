import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/clash_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Rule.parse', () {
    test('parses a plain rule', () {
      final rule = Rule.parse('DOMAIN-SUFFIX,example.com,DIRECT', id: 1);
      expect(rule.ruleAction, RuleAction.DOMAIN_SUFFIX);
      expect(rule.content, 'example.com');
      expect(rule.ruleTarget, 'DIRECT');
      expect(rule.noResolve, isFalse);
      expect(rule.src, isFalse);
    });

    test('keeps payloads containing the param names', () {
      final rule = Rule.parse('DOMAIN-SUFFIX,imgsrc.ru,DIRECT', id: 1);
      expect(rule.content, 'imgsrc.ru');
      expect(rule.ruleTarget, 'DIRECT');
      expect(rule.src, isFalse);
      expect(rule.rawValue, 'DOMAIN-SUFFIX,imgsrc.ru,DIRECT');
    });

    test('parses trailing params, tolerating spaces after commas', () {
      final rule = Rule.parse('IP-CIDR, 10.0.0.0/8, DIRECT, no-resolve', id: 1);
      expect(rule.ruleAction, RuleAction.IP_CIDR);
      expect(rule.content, '10.0.0.0/8');
      expect(rule.ruleTarget, 'DIRECT');
      expect(rule.noResolve, isTrue);
      expect(rule.rawValue, 'IP-CIDR,10.0.0.0/8,DIRECT,no-resolve');
    });

    test('keeps logic rule payloads intact', () {
      const value = 'AND,((NETWORK,udp),(DST-PORT,443)),REJECT';
      final rule = Rule.parse(value, id: 1);
      expect(rule.ruleAction, RuleAction.AND);
      expect(rule.content, '((NETWORK,udp),(DST-PORT,443))');
      expect(rule.ruleTarget, 'REJECT');
      expect(rule.rawValue, value);
    });

    test('two segment rules have no payload', () {
      final rule = Rule.parse('MATCH,PROXY', id: 1);
      expect(rule.ruleAction, RuleAction.MATCH);
      expect(rule.content, isNull);
      expect(rule.ruleTarget, 'PROXY');
      expect(rule.rawValue, 'MATCH,PROXY');
    });

    test('single segment rules do not throw', () {
      final rule = Rule.parse('MATCH', id: 1);
      expect(rule.ruleAction, RuleAction.MATCH);
      expect(rule.content, isNull);
      expect(rule.ruleTarget, isNull);
      expect(rule.rawValue, 'MATCH');
    });

    test('empty value falls back to a direct domain rule', () {
      final rule = Rule.parse('', id: 1);
      expect(rule.ruleAction, RuleAction.DOMAIN);
      expect(rule.ruleTarget, RuleTarget.DIRECT.name);
    });

    test('rule set payload becomes the provider', () {
      final rule = Rule.parse('RULE-SET,my-set,PROXY', id: 1);
      expect(rule.ruleAction, RuleAction.RULE_SET);
      expect(rule.ruleProvider, 'my-set');
      expect(rule.content, isNull);
      expect(rule.ruleTarget, 'PROXY');
      expect(rule.rawValue, 'RULE-SET,my-set,PROXY');
    });

    test('sub rule target is stored as subRule', () {
      final rule = Rule.parse('SUB-RULE,(NETWORK,udp),my-sub', id: 1);
      expect(rule.ruleAction, RuleAction.SUB_RULE);
      expect(rule.content, '(NETWORK,udp)');
      expect(rule.subRule, 'my-sub');
      expect(rule.ruleTarget, isNull);
      expect(rule.rawValue, 'SUB-RULE,(NETWORK,udp),my-sub');
    });

    test('round trips src and no-resolve together', () {
      final rule = Rule.parse('GEOIP,CN,DIRECT,src,no-resolve', id: 1);
      expect(rule.src, isTrue);
      expect(rule.noResolve, isTrue);
      expect(rule.content, 'CN');
      expect(rule.ruleTarget, 'DIRECT');
      expect(rule.rawValue, 'GEOIP,CN,DIRECT,src,no-resolve');
    });
  });
}
