import 'package:fl_clash/features/editor/clash_schema.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/concord_config.dart';

void main() {
  final top = clashConfigSchema.fields;
  final proxy = top['proxies']!.entry!;

  Set<String> fieldsOf(String key) => top[key]!.fields.keys.toSet();

  test('completes only the top-level keys Concord applies', () {
    expect(concordSupportedKeys('keys'), containsAll(top.keys));
  });

  for (final section in ['dns', 'tun', 'sniffer', 'ntp', 'geox-url']) {
    test('completes only the $section keys Concord applies', () {
      expect(concordSupportedKeys(section), containsAll(fieldsOf(section)));
    });
  }

  test('completes only the rule types Concord applies', () {
    expect(concordSupportedKeys('rule-types'), containsAll(ruleTypes.keys));
  });

  test('completes only the proxy types Concord applies', () {
    final supported = concordSupportedKeys('proxy-types');
    expect(supported, containsAll(proxy.fields['type']!.values));
    expect(supported, containsAll(proxy.variants.keys));
  });

  test(
    'completes neither the geodata loader nor GSO, which Concord ignores',
    () {
      expect(top, isNot(contains('geodata-loader')));
      expect(fieldsOf('tun'), isNot(contains('gso')));
    },
  );
}
