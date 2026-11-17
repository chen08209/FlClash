import 'dart:convert';
import 'dart:io';

import '../../tool/src/concord_schema.dart';

final _schema = ConcordSchema.load();

final _defaults =
    jsonDecode(
          File(
            'concord/crates/config/tests/golden/empty.json',
          ).readAsStringSync(),
        )
        as Map<String, Object?>;

Set<String> concordKeys(String section) => _schema.keys(section);

/// The keys of [section] Concord applies, leaving out the T2 ones it only
/// warns about and the inert ones it reads without effect.
Set<String> concordSupportedKeys(String section) =>
    _schema.keys(section, concordAppliedTiers);

Map<String, Object?> concordDefaults(String section) =>
    _defaults[section]! as Map<String, Object?>;

Set<String> concordProxyTypes() => concordKeys('proxy-types');
