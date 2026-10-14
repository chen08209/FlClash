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

  group('Rule.payloadError', () {
    test('accepts the payloads mihomo parses', () {
      for (final value in [
        'NETWORK,tcp,DIRECT',
        'NETWORK,UDP,DIRECT',
        'DST-PORT,80,DIRECT',
        'SRC-PORT,8000-9000,DIRECT',
        'IN-PORT,80/443,DIRECT',
        'IN-PORT,80,443,DIRECT',
        'UID,1000-1010,DIRECT',
        'DSCP,4,DIRECT',
        'DSCP,0-63,DIRECT',
        'DOMAIN-SUFFIX,example.com,DIRECT',
      ]) {
        expect(Rule.parse(value).payloadError, isNull, reason: value);
      }
    });

    test('rejects the payloads mihomo refuses', () {
      expect(
        Rule.parse('NETWORK,icmp,DIRECT').payloadError,
        RulePayloadError.network,
      );
      expect(
        Rule.parse('DST-PORT,http,DIRECT').payloadError,
        RulePayloadError.numberRange,
      );
      expect(
        Rule.parse('SRC-PORT,80..90,DIRECT').payloadError,
        RulePayloadError.numberRange,
      );
      expect(
        Rule.parse('UID,*,DIRECT').payloadError,
        RulePayloadError.numberRange,
      );
      expect(
        Rule.parse('DSCP,64,DIRECT').payloadError,
        RulePayloadError.dscpRange,
      );
    });

    test('leaves an empty payload to the not-empty check', () {
      expect(Rule.parse('NETWORK').payloadError, isNull);
      expect(Rule.parse('MATCH,DIRECT').payloadError, isNull);
    });
  });

  group('rule list text', () {
    test('reads back what it writes, quoting only what YAML would misread', () {
      final rules = [
        Rule.parse('DOMAIN-SUFFIX,example.com,PROXY'),
        Rule.parse(r'DOMAIN-REGEX,^a: b$,DIRECT'),
        Rule.parse("DOMAIN-KEYWORD,it's #1,DIRECT"),
        Rule.parse('MATCH,DIRECT'),
      ];
      final text = encodeRuleList(rules);

      expect(text.split('\n').first, '- DOMAIN-SUFFIX,example.com,PROXY');
      expect(
        decodeRuleList(text).map((entry) => entry.rule.rawValue),
        rules.map((rule) => rule.rawValue),
      );
    });

    test('takes a whole rules section and bare lines too', () {
      for (final content in [
        'rules:\n  - DOMAIN,example.com,DIRECT\n  - MATCH,PROXY\n',
        'DOMAIN,example.com,DIRECT\n\nMATCH,PROXY\n',
        '- DOMAIN,example.com,DIRECT\nMATCH,PROXY',
        '  - DOMAIN,example.com,DIRECT # mine\n-MATCH,PROXY\r\n',
        "rules:\n- 'DOMAIN,example.com,DIRECT'\n    - MATCH,PROXY\n",
      ]) {
        expect(decodeRuleList(content).map((entry) => entry.rule.rawValue), [
          'DOMAIN,example.com,DIRECT',
          'MATCH,PROXY',
        ], reason: content);
      }
      expect(decodeRuleList(''), isEmpty);
      expect(decodeRuleList('rules:'), isEmpty);
    });

    test('reports the line of an entry with no rule type', () {
      for (final (content, line) in [
        ('- DOMAIN,example.com,DIRECT\n\n- example.com,DIRECT', 3),
        ('- MATCH,DIRECT\n- {DOMAIN: example.com}', 2),
        ('DOMAIN,example.com,DIRECT\nexample.com', 2),
        ('name: rule', 1),
        ('42', 1),
        ('rules: {a: 1}', 1),
      ]) {
        expect(
          () => decodeRuleList(content),
          throwsA(
            isA<RuleLineException>().having(
              (error) => error.line,
              'line',
              line,
            ),
          ),
          reason: content,
        );
      }
    });

    test('keeps the id of each rule whose text is unchanged', () {
      final ids = decodeRuleList(
        [
          '- domain,a.com,DIRECT',
          '- DOMAIN,c.com,DIRECT',
          '- DOMAIN,a.com,DIRECT',
          '- DOMAIN,a.com,DIRECT',
        ].join('\n'),
        previous: [
          Rule.parse('DOMAIN,a.com,DIRECT', id: 1),
          Rule.parse('DOMAIN,b.com,DIRECT', id: 2),
          Rule.parse('DOMAIN,a.com,DIRECT', id: 3),
        ],
      ).map((entry) => entry.rule.id).toList();

      expect([ids[0], ids[2]], [1, 3]);
      expect({ids[1], ids[3]}.intersection({1, 2, 3}), isEmpty);
      expect(ids[1], isNot(ids[3]));
    });
  });

  group('rule sets', () {
    test('reads the sets a logic rule nests at any depth', () {
      expect(Rule.parse('RULE-SET,Ads,REJECT').ruleSets, ['Ads']);
      expect(
        Rule.parse(
          'OR,((rule-set, Ads ,no-resolve),(AND,((RULE-SET,CN),(NETWORK,UDP)))),DIRECT',
        ).ruleSets,
        ['Ads', 'CN'],
      );
      expect(Rule.parse('SUB-RULE,(RULE-SET,Ads),nested').ruleSets, ['Ads']);
      expect(
        Rule.parse(r'DOMAIN-REGEX,^\(RULE-SET,x\),DIRECT').ruleSets,
        isEmpty,
      );
    });

    test('renames each set it names', () {
      const names = {'Ads': 'Ad block'};

      expect(
        Rule.parse('RULE-SET,Ads,REJECT').renamedRuleSets(names).rawValue,
        'RULE-SET,Ad block,REJECT',
      );
      expect(
        Rule.parse(
          'AND,((RULE-SET,Ads),(RULE-SET,Ads-old),(NETWORK,UDP)),REJECT',
        ).renamedRuleSets(names).rawValue,
        'AND,((RULE-SET,Ad block),(RULE-SET,Ads-old),(NETWORK,UDP)),REJECT',
      );
    });
  });
}
