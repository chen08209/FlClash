import 'package:collection/collection.dart';
import 'package:fl_clash/common/search.dart';
import 'package:flutter/foundation.dart';

import 'common.dart';

/// Named in a query as the field's `name`, as in `host:github.com`.
enum ConnectionField { host, app, exit, rule, net, ip }

extension ConnectionFieldExt on ConnectionField {
  Iterable<String> valuesOf(TrackerInfo trackerInfo) {
    final metadata = trackerInfo.metadata;
    return switch (this) {
      ConnectionField.host => [metadata.host, trackerInfo.title],
      ConnectionField.app => [metadata.process, metadata.processPath],
      ConnectionField.exit => trackerInfo.chains,
      ConnectionField.rule => [trackerInfo.ruleText],
      ConnectionField.net => [metadata.network],
      ConnectionField.ip => [metadata.destinationIP, metadata.sourceIP],
    };
  }
}

final _fieldTexts = {
  for (final field in ConnectionField.values) field: Expando<String>(),
};

@immutable
class ConnectionCondition {
  final ConnectionField field;
  final String value;
  final bool excludes;
  final String _needle;

  ConnectionCondition(this.field, this.value, {this.excludes = false})
    : _needle = value.toLowerCase();

  static final _fields = ConnectionField.values
      .map((field) => field.name)
      .join('|');

  /// A value in quotes may hold spaces, and runs to the end unclosed.
  static final _pattern = RegExp(
    '(?<=^|\\s)(-?)($_fields):(?:"([^"]*)"?|([^\\s"]\\S*))',
  );

  bool holds(TrackerInfo trackerInfo) {
    final text = _fieldTexts[field]![trackerInfo] ??= SearchQuery.textOf(
      field.valuesOf(trackerInfo),
    );
    return text.contains(_needle);
  }

  @override
  bool operator ==(Object other) =>
      other is ConnectionCondition &&
      other.field == field &&
      other.value == value &&
      other.excludes == excludes;

  @override
  int get hashCode => Object.hash(field, value, excludes);

  @override
  String toString() {
    final quoted = value.contains(RegExp(r'\s')) ? '"$value"' : value;
    return '${excludes ? '-' : ''}${field.name}:$quoted';
  }
}

/// Conditions on one field widen each other, on different fields narrow;
/// an excluding one drops what it holds whatever else holds.
class ConnectionQuery {
  final List<ConnectionCondition> conditions;

  /// What is left of a search once its conditions are read out of it.
  final String text;

  const ConnectionQuery(this.conditions, {this.text = ''});

  factory ConnectionQuery.parse(String query) {
    final conditions = <ConnectionCondition>[];
    final rest = query.replaceAllMapped(ConnectionCondition._pattern, (match) {
      final value = (match[3] ?? match[4]!).trim();
      if (value.isNotEmpty) {
        conditions.add(
          ConnectionCondition(
            ConnectionField.values.byName(match[2]!),
            value,
            excludes: match[1]!.isNotEmpty,
          ),
        );
      }
      return ' ';
    });
    return ConnectionQuery(
      conditions,
      text: rest.trim().split(RegExp(r'\s+')).join(' '),
    );
  }

  bool get isEmpty => conditions.isEmpty;

  bool Function(TrackerInfo) get matcher {
    final excluding = conditions.where((condition) => condition.excludes);
    final byField = groupBy(
      conditions.where((condition) => !condition.excludes),
      (condition) => condition.field,
    ).values.toList();
    return (trackerInfo) =>
        !excluding.any((condition) => condition.holds(trackerInfo)) &&
        byField.every(
          (any) => any.any((condition) => condition.holds(trackerInfo)),
        );
  }
}
