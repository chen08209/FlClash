import 'dart:io';

import 'package:fl_clash/features/editor/clash_schema.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../tool/generate_concord_tiers.dart';
import '../../tool/src/concord_schema.dart';
import '../helpers/concord_config.dart';

void main() {
  final top = clashConfigSchema.fields;
  final proxy = top['proxies']!.entry!;
  final group = top['proxy-groups']!.entry!;
  final sections = {
    'keys': clashConfigSchema,
    'dns': top['dns']!,
    'dns.fallback-filter': top['dns']!.fields['fallback-filter']!,
    'tun': top['tun']!,
    'sniffer': top['sniffer']!,
    'ntp': top['ntp']!,
    'geox-url': top['geox-url']!,
    'profile': top['profile']!,
  };

  test('the Concord tiers are generated from the core schema', () {
    expect(
      File(concordTiersOutput).readAsStringSync(),
      renderConcordTiers(ConcordSchema.load()),
      reason: 'run `dart run tool/generate_concord_tiers.dart`',
    );
  });

  for (final MapEntry(key: section, value: schema) in sections.entries) {
    test('completes only the $section keys Concord applies', () {
      expect(schema.concordSection, section);
      expect(concordSupportedKeys(section), containsAll(schema.fields.keys));
    });

    test('lists only $section keys Concord knows', () {
      expect(concordKeys(section), containsAll(schema.listedFields));
    });
  }

  test('completes only the rule types Concord applies', () {
    expect(concordSupportedKeys('rule-types'), containsAll(ruleTypes.keys));
  });

  test('completes only the proxy and group types Concord applies', () {
    final proxies = concordSupportedKeys('proxy-types');
    expect(proxies, containsAll(proxy.fields['type']!.values));
    expect(proxies, containsAll(proxy.variants.keys));
    final groups = concordSupportedKeys('group-types');
    expect(groups, containsAll(group.fields['type']!.values));
    expect(groups, containsAll(group.variants.keys));
  });

  test(
    'offers every group type Concord applies, smart with its own fields',
    () {
      expect(
        group.fields['type']!.values,
        containsAll(concordSupportedKeys('group-types')),
      );
      expect(
        group.variants['smart']!.keys,
        containsAll(['tolerance', 'policy-priority']),
      );
    },
  );
}
