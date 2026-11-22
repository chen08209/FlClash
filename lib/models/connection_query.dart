import 'package:fl_clash/common/app_localizations.dart';
import 'package:fl_clash/common/l10n_labels.dart';
import 'package:fl_clash/common/search.dart';
import 'package:flutter/foundation.dart';

import 'common.dart';
import 'core.dart';

/// A field of a record that a condition is set on, named in a query by its
/// `name`, as in `host:github.com`.
abstract interface class RecordField<T> implements Enum {
  String get label;

  Iterable<String> valuesOf(T item);
}

enum ConnectionField implements RecordField<TrackerInfo> {
  host,
  app,
  exit,
  rule,
  net,
  ip;

  @override
  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      ConnectionField.host => appLocalizations.host,
      ConnectionField.app => appLocalizations.app,
      ConnectionField.exit => appLocalizations.outboundExit,
      ConnectionField.rule => appLocalizations.rule,
      ConnectionField.net => appLocalizations.protocol,
      ConnectionField.ip => 'IP',
    };
  }

  @override
  Iterable<String> valuesOf(TrackerInfo trackerInfo) {
    final metadata = trackerInfo.metadata;
    return switch (this) {
      ConnectionField.host => [metadata.host, trackerInfo.title],
      ConnectionField.app => [metadata.process, metadata.processPath],
      ConnectionField.exit => trackerInfo.chains,
      ConnectionField.rule => [
        trackerRuleText(currentAppLocalizations, trackerInfo),
      ],
      ConnectionField.net => [metadata.network],
      ConnectionField.ip => [metadata.destinationIP, metadata.sourceIP],
    };
  }
}

enum DnsField implements RecordField<DnsQuery> {
  domain,
  type,
  initiator,
  upstream;

  @override
  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      DnsField.domain => appLocalizations.domain,
      DnsField.type => appLocalizations.recordType,
      DnsField.initiator => appLocalizations.initiator,
      DnsField.upstream => appLocalizations.upstream,
    };
  }

  @override
  Iterable<String> valuesOf(DnsQuery dnsQuery) => switch (this) {
    DnsField.domain => [dnsQuery.domain],
    DnsField.type => [dnsQuery.type],
    DnsField.initiator => [dnsQuery.initiator?.label ?? ''],
    DnsField.upstream => [dnsQuery.upstream],
  };
}

enum HttpField implements RecordField<MitmExchangeSummary> {
  host,
  path,
  method,
  status,
  kind,
  app;

  @override
  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      HttpField.host => appLocalizations.host,
      HttpField.path => appLocalizations.requestPath,
      HttpField.method => appLocalizations.method,
      HttpField.status => appLocalizations.statusCode,
      HttpField.kind => appLocalizations.contentKind,
      HttpField.app => appLocalizations.app,
    };
  }

  @override
  Iterable<String> valuesOf(MitmExchangeSummary exchange) => switch (this) {
    HttpField.host => [exchange.host],
    HttpField.path => [exchange.path],
    HttpField.method => [exchange.method],
    HttpField.status => [if (exchange.status > 0) '${exchange.status}'],
    HttpField.kind => [exchange.kind],
    HttpField.app => [
      exchange.app?.process ?? '',
      exchange.app?.processPath ?? '',
    ],
  };
}

/// How a condition's value meets a field's: inside it, or as all of it.
enum ConditionMatch { contains, equals }

typedef ConnectionCondition = RecordCondition<TrackerInfo>;

@immutable
class RecordCondition<T extends Object> {
  final RecordField<T> field;
  final String value;
  final bool excludes;
  final ConditionMatch match;
  final String _needle;

  RecordCondition(
    this.field,
    this.value, {
    this.excludes = false,
    this.match = ConditionMatch.contains,
  }) : _needle = value.toLowerCase();

  static final _texts = <RecordField<Object?>, Expando<String>>{};

  bool holds(T item) {
    if (match == ConditionMatch.equals) {
      return field
          .valuesOf(item)
          .any((value) => value.toLowerCase() == _needle);
    }
    final text = (_texts[field] ??= Expando())[item] ??= SearchQuery.textOf(
      field.valuesOf(item),
    );
    return text.contains(_needle);
  }

  @override
  bool operator ==(Object other) =>
      other is RecordCondition &&
      other.field == field &&
      other.value == value &&
      other.excludes == excludes &&
      other.match == match;

  @override
  int get hashCode => Object.hash(field, value, excludes, match);

  @override
  String toString() {
    final quoted = value.contains(RegExp(r'\s')) ? '"$value"' : value;
    final equals = match == ConditionMatch.equals ? '=' : '';
    return '${excludes ? '-' : ''}${field.name}:$equals$quoted';
  }
}

typedef ConditionRows<T extends Object> = ({
  List<RecordCondition<T>> excluding,
  Map<Object, List<bool Function(T)>> rows,
});

ConditionRows<T> conditionRows<T extends Object>(
  Iterable<RecordCondition<T>> conditions,
) {
  final excluding = <RecordCondition<T>>[];
  final rows = <Object, List<bool Function(T)>>{};
  for (final condition in conditions) {
    if (condition.excludes) {
      excluding.add(condition);
    } else {
      (rows[condition.field] ??= []).add(condition.holds);
    }
  }
  return (excluding: excluding, rows: rows);
}

/// Conditions on one field widen each other, on different fields narrow;
/// an excluding one drops what it holds whatever else holds.
bool Function(T) conditionsMatcher<T extends Object>(
  List<RecordCondition<T>> excluding,
  Iterable<List<bool Function(T)>> rows,
) {
  final all = rows.toList();
  return (item) =>
      !excluding.any((condition) => condition.holds(item)) &&
      all.every((any) => any.any((holds) => holds(item)));
}

class ConnectionQuery {
  final List<ConnectionCondition> conditions;

  /// What is left of a search once its conditions are read out of it.
  final String text;

  const ConnectionQuery(this.conditions, {this.text = ''});

  static final _fields = ConnectionField.values
      .map((field) => field.name)
      .join('|');

  /// A value in quotes may hold spaces, and runs to the end unclosed.
  static final _pattern = RegExp(
    '(?<=^|\\s)(-?)($_fields):(=?)(?:"([^"]*)"?|([^\\s"=]\\S*))',
  );

  factory ConnectionQuery.parse(String query) {
    final conditions = <ConnectionCondition>[];
    final rest = query.replaceAllMapped(_pattern, (match) {
      final value = (match[4] ?? match[5]!).trim();
      if (value.isNotEmpty) {
        conditions.add(
          ConnectionCondition(
            ConnectionField.values.byName(match[2]!),
            value,
            excludes: match[1]!.isNotEmpty,
            match: match[3]!.isEmpty
                ? ConditionMatch.contains
                : ConditionMatch.equals,
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
    final (:excluding, :rows) = conditionRows(conditions);
    return conditionsMatcher(excluding, rows.values);
  }
}
