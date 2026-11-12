import 'dart:convert';
import 'dart:io';

final _schema =
    jsonDecode(File('concord/schema/config-schema.json').readAsStringSync())
        as Map<String, Object?>;

final _defaults =
    jsonDecode(
          File(
            'concord/crates/config/tests/golden/empty.json',
          ).readAsStringSync(),
        )
        as Map<String, Object?>;

Set<String> concordKeys(String section) => {
  for (final tier
      in (_schema[section]! as Map<String, Object?>).values.cast<List>())
    ...tier.cast<String>(),
};

/// The keys of [section] Concord applies, leaving out the T2 ones it only
/// warns about.
Set<String> concordSupportedKeys(String section) {
  final tiers = _schema[section]! as Map<String, Object?>;
  return {
    for (final tier in ['t0', 't1']) ...(tiers[tier]! as List).cast<String>(),
  };
}

Map<String, Object?> concordDefaults(String section) =>
    _defaults[section]! as Map<String, Object?>;

Set<String> concordProxyTypes() => concordKeys('proxy-types');
