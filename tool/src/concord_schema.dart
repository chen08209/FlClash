import 'dart:convert';
import 'dart:io';

const concordSchemaPath = 'concord/schema/config-schema.json';

const concordTiers = ['t0', 't1', 't2', 'inert'];

const concordAppliedTiers = ['t0', 't1'];

/// The tier of every key, proxy type and rule type Concord knows, by section.
class ConcordSchema {
  final Map<String, Map<String, String>> sections;
  final Map<String, Map<String, Object?>> defaults;

  final Map<String, Map<String, List<String>>> values;

  const ConcordSchema(this.sections, this.defaults, this.values);

  factory ConcordSchema.load([String path = concordSchemaPath]) =>
      ConcordSchema.parse(File(path).readAsStringSync());

  factory ConcordSchema.parse(String source) {
    final json = jsonDecode(source) as Map<String, Object?>;
    final sections = <String, Map<String, String>>{};
    final defaults = <String, Map<String, Object?>>{};
    final values = <String, Map<String, List<String>>>{};
    Map<String, List<String>> lists(Map<String, Object?> source) => {
      for (final MapEntry(:key, :value) in source.entries)
        key: [for (final name in value! as List<Object?>) name! as String],
    };
    for (final MapEntry(:key, :value) in json.entries) {
      if (key == 'proxy-values') {
        values['proxy'] = lists(value! as Map<String, Object?>);
        continue;
      }
      switch (value) {
        // A bare list, as group-types is, names only what Concord applies.
        case final List<Object?> applied:
          sections[key] = {for (final name in applied) name! as String: 't0'};
        case final Map<String, Object?> tiers:
          sections[key] = {
            for (final tier in concordTiers)
              for (final name in (tiers[tier] as List<Object?>?) ?? const [])
                name! as String: tier,
          };
          if (tiers['defaults'] case final Map<String, Object?> found) {
            defaults[key] = found;
          }
          if (tiers['values'] case final Map<String, Object?> found) {
            values[key] = lists(found);
          }
      }
    }
    return ConcordSchema(sections, defaults, values);
  }

  String? tierOf(String section, String key) => sections[section]?[key];

  Set<String> keys(String section, [List<String> tiers = concordTiers]) => {
    for (final MapEntry(:key, :value) in sections[section]!.entries)
      if (tiers.contains(value)) key,
  };
}
