import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:test/test.dart';

void main() {
  group('Rule.parse', () {
    test('reads MATCH as a target-only rule', () {
      final rule = Rule.parse('MATCH,DIRECT');

      expect(rule.ruleAction, RuleAction.MATCH);
      expect(rule.content, isNull);
      expect(rule.ruleTarget, 'DIRECT');
    });

    test('keeps content and target apart for a payload rule', () {
      final rule = Rule.parse('DOMAIN-SUFFIX,example.com,PROXY');

      expect(rule.ruleAction, RuleAction.DOMAIN_SUFFIX);
      expect(rule.content, 'example.com');
      expect(rule.ruleTarget, 'PROXY');
    });

    test('reads RULE-SET payloads as a rule provider', () {
      final rule = Rule.parse('RULE-SET,my-set,PROXY');

      expect(rule.ruleProvider, 'my-set');
      expect(rule.content, isNull);
      expect(rule.ruleTarget, 'PROXY');
    });

    test('reads SUB-RULE payloads as a sub rule target', () {
      final rule = Rule.parse('SUB-RULE,payload,my-sub-rule');

      expect(rule.content, 'payload');
      expect(rule.subRule, 'my-sub-rule');
      expect(rule.ruleTarget, isNull);
    });

    test('reads a lone comma-payload field as the target like mihomo', () {
      final subRule = Rule.parse('SUB-RULE,my-sub-rule');

      expect(subRule.content, isNull);
      expect(subRule.subRule, 'my-sub-rule');

      final regex = Rule.parse('DOMAIN-REGEX,PROXY');

      expect(regex.content, isNull);
      expect(regex.ruleTarget, 'PROXY');
    });

    test('reads the no-resolve flag', () {
      final rule = Rule.parse('IP-CIDR,1.1.1.1/32,DIRECT,no-resolve');

      expect(rule.content, '1.1.1.1/32');
      expect(rule.ruleTarget, 'DIRECT');
      expect(rule.noResolve, isTrue);
    });

    test('tolerates a rule without a target', () {
      final rule = Rule.parse('MATCH');

      expect(rule.ruleAction, RuleAction.MATCH);
      expect(rule.content, isNull);
      expect(rule.ruleTarget, isNull);
    });

    test('keeps a target-less payload rule as content only', () {
      final rule = Rule.parse('DOMAIN-SUFFIX,example.com');

      expect(rule.ruleAction, RuleAction.DOMAIN_SUFFIX);
      expect(rule.content, 'example.com');
      expect(rule.ruleTarget, isNull);
      expect(rule.rawValue, 'DOMAIN-SUFFIX,example.com');
    });

    test('falls back to a default rule for a payload with no fields', () {
      final rule = Rule.parse(',,');

      expect(rule.ruleAction, RuleAction.DOMAIN);
      expect(rule.ruleTarget, RuleTarget.DIRECT.name);
    });

    test('keeps commas inside a logic rule payload', () {
      final rule = Rule.parse('AND,((DOMAIN,baidu.com),(NETWORK,UDP)),DIRECT');

      expect(rule.ruleAction, RuleAction.AND);
      expect(rule.content, '((DOMAIN,baidu.com),(NETWORK,UDP))');
      expect(rule.ruleTarget, 'DIRECT');
    });

    test('keeps commas inside a regex payload', () {
      final rule = Rule.parse(r'DOMAIN-REGEX,^a{1,3}\.example\.com$,PROXY');

      expect(rule.content, r'^a{1,3}\.example\.com$');
      expect(rule.ruleTarget, 'PROXY');
    });

    test('reads the src flag only from a whole params field', () {
      final rule = Rule.parse('IP-CIDR,10.0.0.0/8,DIRECT,src');

      expect(rule.src, isTrue);
      expect(rule.noResolve, isFalse);

      final domain = Rule.parse('DOMAIN-SUFFIX,src.example.com,PROXY');

      expect(domain.content, 'src.example.com');
      expect(domain.src, isFalse);
    });

    test('reads the rule type case-insensitively like mihomo', () {
      final rule = Rule.parse('domain-suffix,example.com,PROXY');

      expect(rule.ruleAction, RuleAction.DOMAIN_SUFFIX);
      expect(rule.content, 'example.com');
    });

    test('recognises the wildcard and rematch rule types', () {
      for (final entry in const {
        'DOMAIN-WILDCARD': RuleAction.DOMAIN_WILDCARD,
        'PROCESS-NAME-WILDCARD': RuleAction.PROCESS_NAME_WILDCARD,
        'PROCESS-PATH-WILDCARD': RuleAction.PROCESS_PATH_WILDCARD,
        'REMATCH-NAME': RuleAction.REMATCH_NAME,
      }.entries) {
        final rule = Rule.parse('${entry.key},payload,DIRECT');

        expect(rule.ruleAction, entry.value, reason: entry.key);
        expect(rule.content, 'payload');
        expect(rule.ruleTarget, 'DIRECT');
      }
    });
  });

  group('Rule.rawValue', () {
    test('serializes MATCH without an empty content field', () {
      const rule = Rule(ruleAction: RuleAction.MATCH, ruleTarget: 'DIRECT');

      expect(rule.rawValue, 'MATCH,DIRECT');
    });

    test('drops content stored on a MATCH rule by an older build', () {
      const rule = Rule(
        ruleAction: RuleAction.MATCH,
        content: 'DIRECT',
        ruleTarget: 'DIRECT',
      );

      expect(rule.rawValue, 'MATCH,DIRECT');
    });

    test('round-trips the payload rules mihomo accepts', () {
      for (final value in const [
        'MATCH,DIRECT',
        'DOMAIN-SUFFIX,example.com,PROXY',
        'RULE-SET,my-set,PROXY',
        'SUB-RULE,payload,my-sub-rule',
        'IP-CIDR,1.1.1.1/32,DIRECT,no-resolve',
        'IP-CIDR,10.0.0.0/8,DIRECT,src,no-resolve',
        'GEOIP,CN,DIRECT,no-resolve',
        'RULE-SET,my-set,PROXY,src',
        'AND,((DOMAIN,baidu.com),(NETWORK,UDP)),DIRECT',
        'OR,((DOMAIN,a.com),(DOMAIN,b.com)),PROXY',
        'NOT,((DOMAIN,example.com)),PROXY',
        r'DOMAIN-REGEX,^a{1,3}\.example\.com$,PROXY',
        'DOMAIN-WILDCARD,*.example.com,PROXY',
      ]) {
        expect(Rule.parse(value).rawValue, value, reason: value);
      }
    });

    test('drops params from a SRC-IP-ASN rule as mihomo ignores them', () {
      final rule = Rule.parse('SRC-IP-ASN,13335,DIRECT,no-resolve');

      expect(rule.rawValue, 'SRC-IP-ASN,13335,DIRECT');
    });
  });
}
