import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart';

enum ConnectionStatus { all, active, failed }

extension ConnectionStatusExt on ConnectionStatus {
  bool holds(TrackerInfo trackerInfo) => switch (this) {
    ConnectionStatus.all => true,
    ConnectionStatus.active => trackerInfo.isActive,
    ConnectionStatus.failed => trackerInfo.failure != null,
  };

  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      ConnectionStatus.all => appLocalizations.connectionsAll,
      ConnectionStatus.active => appLocalizations.connectionsActive,
      ConnectionStatus.failed => appLocalizations.connectionsFailed,
    };
  }
}

/// A list's filters: one of [statuses], the first keeping all, values of the
/// facets, and conditions; one field's widen each other, fields narrow.
class ConditionFilterController<T extends Object, S extends Enum>
    extends RecordFilterController<T> {
  final _counted = ValueNotifier(0);

  final List<S> statuses;
  final List<RecordField<T>> fields;
  final String Function(S status) labelOf;
  final bool Function(S status, T item) _statusHolds;
  final String Function(String count) showsText;
  final String Function(String field) valuesInText;
  final String Function() _conditionTip;
  final RecordField<T>? Function(RecordFacetKind kind)? _fieldOf;
  final Iterable<String> Function(RecordField<T> field, T item)?
  _suggestedValuesOf;
  late S _status = statuses.first;
  var _conditions = <RecordCondition<T>>[];
  var _statusCounts = <S, int>{};
  List<T> Function() _offered = () => const [];

  ConditionFilterController({
    required super.facets,
    required this.statuses,
    required this.fields,
    required this.labelOf,
    required bool Function(S status, T item) statusHolds,
    required this.showsText,
    required this.valuesInText,
    required String Function() conditionTip,
    RecordField<T>? Function(RecordFacetKind kind)? fieldOf,
    Iterable<String> Function(RecordField<T> field, T item)? suggestedValuesOf,
  }) : _statusHolds = statusHolds,
       _conditionTip = conditionTip,
       _fieldOf = fieldOf,
       _suggestedValuesOf = suggestedValuesOf;

  bool statusHolds(S status, T item) => _statusHolds(status, item);

  String get conditionTip => _conditionTip();

  /// The field a facet's value widens, as an equals condition on it would.
  RecordField<T>? fieldOf(RecordFacetKind kind) => _fieldOf?.call(kind);

  /// The values of [field] a draft suggests, which may be fewer than match.
  Iterable<String> suggestedValuesOf(RecordField<T> field, T item) =>
      _suggestedValuesOf?.call(field, item) ?? field.valuesOf(item);

  S get status => _status;

  set status(S status) {
    if (status == _status) {
      return;
    }
    _status = status;
    notifyListeners();
  }

  @override
  bool get isFiltering =>
      super.isFiltering || _status != statuses.first || _conditions.isNotEmpty;

  List<RecordCondition<T>> get conditions => _conditions;

  void addCondition(RecordCondition<T> condition) {
    if (_conditions.contains(condition)) {
      return;
    }
    _conditions = [..._conditions, condition];
    notifyListeners();
  }

  /// Lets [condition] alone through for its field, keeping what excludes.
  void onlyCondition(RecordCondition<T> condition) {
    _conditions = [
      for (final kept in _conditions)
        if (kept.excludes || kept.field != condition.field) kept,
      condition,
    ];
    notifyListeners();
  }

  void removeCondition(RecordCondition<T> condition) {
    _conditions = [..._conditions]..remove(condition);
    notifyListeners();
  }

  void replace(Object previous, RecordCondition<T> next) {
    if (previous is RecordFilter) {
      remove(previous);
      addCondition(next);
      return;
    }
    final index = _conditions.indexOf(previous as RecordCondition<T>);
    if (index < 0 || _conditions.contains(next)) {
      removeCondition(previous);
      addCondition(next);
      return;
    }
    _conditions = [..._conditions]..[index] = next;
    notifyListeners();
  }

  /// Narrows [kind] to [value], dropping the conditions that widened it.
  void only(RecordFacetKind kind, String value) {
    final field = fieldOf(kind);
    _conditions = [
      for (final condition in _conditions)
        if (condition.excludes || condition.field != field) condition,
    ];
    clear(kind);
    add(RecordFilter(kind, value));
    notifyListeners();
  }

  void clearConditions() {
    _conditions = [];
    for (final filter in [...filters]) {
      remove(filter);
    }
    notifyListeners();
  }

  /// Notifies as the counts [offer] takes change.
  Listenable get counted => _counted;

  int countOf(S status) => _statusCounts[status] ?? 0;

  List<String> selectedOf(RecordFacetKind kind) => [
    for (final filter in filters)
      if (filter.kind == kind) filter.value,
  ];

  void clear(RecordFacetKind kind) {
    for (final filter in [...filters]) {
      if (filter.kind == kind) {
        remove(filter);
      }
    }
  }

  @override
  List<T> apply(List<T> items) {
    final shows = this.shows;
    return shows == null ? items : items.where(shows).toList();
  }

  bool Function(T item)? get shows {
    final matches = _matcherOf(_conditions, filters);
    final status = _status;
    if (status == statuses.first && matches == null) {
      return null;
    }
    return (item) => statusHolds(status, item) && (matches?.call(item) ?? true);
  }

  FieldDraft<T> draftOn(RecordField<T> field, {Object? replacing}) {
    final (:excluding, :rows) = _rowsOf(
      [
        for (final condition in _conditions)
          if (condition != replacing) condition,
      ],
      [
        for (final filter in filters)
          if (filter != replacing) filter,
      ],
    );
    final row = rows.remove(field);
    final holdsOthers = conditionsMatcher(excluding, rows.values);
    final groups = <String, _DraftGroup<T>>{};
    final valueCounts = <String, int>{};
    for (final item in _offered()) {
      for (final value in suggestedValuesOf(field, item)) {
        if (value.isNotEmpty) {
          valueCounts[value] = (valueCounts[value] ?? 0) + 1;
        }
      }
      if (!statusHolds(_status, item) || !holdsOthers(item)) {
        continue;
      }
      final group = groups[field.valuesOf(item).join('\u0000')] ??= _DraftGroup(
        item,
      );
      if (row == null || row.any((holds) => holds(item))) {
        group.inRow++;
      } else {
        group.outOfRow++;
      }
    }
    return FieldDraft._(
      groups: groups.values.toList(),
      widens: row != null,
      values: [
        for (final entry in valueCounts.entries.sorted(
          (a, b) => b.value - a.value,
        ))
          (entry.key, entry.key.toLowerCase(), entry.value),
      ],
    );
  }

  bool Function(T)? _matcherOf(
    List<RecordCondition<T>> conditions,
    List<RecordFilter> filters,
  ) {
    if (conditions.isEmpty && filters.isEmpty) {
      return null;
    }
    final (:excluding, :rows) = _rowsOf(conditions, filters);
    return conditionsMatcher(excluding, rows.values);
  }

  ConditionRows<T> _rowsOf(
    List<RecordCondition<T>> conditions,
    List<RecordFilter> filters,
  ) {
    final (:excluding, :rows) = conditionRows(conditions);
    for (final filter in filters) {
      final facet = facetOf(filter.kind);
      if (facet != null) {
        (rows[fieldOf(filter.kind) ?? filter.kind] ??= []).add(
          (item) => facet.valuesOf(item).contains(filter.value),
        );
      }
    }
    return (excluding: excluding, rows: rows);
  }

  /// Counts the statuses only: a page filtered by conditions reads no facet
  /// options, which would cost a pass over every item on each refresh.
  @override
  void offer(Iterable<T> items) {
    final offered = items is List<T> ? items : items.toList();
    final statusCounts = {for (final status in statuses) status: 0};
    for (final item in offered) {
      for (final status in statuses) {
        if (statusHolds(status, item)) {
          statusCounts[status] = statusCounts[status]! + 1;
        }
      }
    }
    offerCounts(statusCounts, () => offered);
  }

  /// [items] is read only when a draft needs them.
  void offerCounts(Map<S, int> statusCounts, List<T> Function() items) {
    _offered = items;
    if (MapEquality<S, int>().equals(statusCounts, _statusCounts)) {
      return;
    }
    _statusCounts = statusCounts;
    _counted.value++;
  }

  @override
  void dispose() {
    _counted.dispose();
    super.dispose();
  }
}

typedef ConnectionFilterController =
    ConditionFilterController<TrackerInfo, ConnectionStatus>;

ConnectionFilterController connectionFilters() => ConditionFilterController(
  facets: trackerInfoFacets,
  statuses: ConnectionStatus.values,
  fields: ConnectionField.values,
  labelOf: (status) => status.label,
  statusHolds: (status, item) => status.holds(item),
  showsText: (count) => currentAppLocalizations.conditionShows(count),
  valuesInText: (field) => currentAppLocalizations.conditionValuesIn(field),
  conditionTip: () => currentAppLocalizations.conditionTip,
  fieldOf: (kind) => switch (kind) {
    RecordFacetKind.app => ConnectionField.app,
    RecordFacetKind.proxy => ConnectionField.exit,
    RecordFacetKind.rule => ConnectionField.rule,
    RecordFacetKind.network => ConnectionField.net,
    _ => null,
  },
  suggestedValuesOf: (field, item) => switch (field) {
    ConnectionField.host => [
      item.metadata.host.isNotEmpty ? item.metadata.host : item.title,
    ],
    ConnectionField.app => [item.metadata.process],
    ConnectionField.ip => [item.metadata.destinationIP],
    _ => field.valuesOf(item),
  },
);

extension ConnectionFilters on ConnectionFilterController {
  bool get mergesRepeats => status == ConnectionStatus.failed;
}

Object trackerRepeatKeyOf(TrackerInfo trackerInfo) {
  final metadata = trackerInfo.metadata;
  return (
    trackerInfo.failure?.kind,
    metadata.network,
    trackerInfo.title,
    metadata.destinationPort,
    metadata.process,
  );
}

class _DraftGroup<T> {
  final T sample;
  var inRow = 0;
  var outOfRow = 0;

  _DraftGroup(this.sample);
}

/// The items that pass all but one field's row, grouped by what they hold in
/// that field, so that a draft is matched once per distinct value.
class FieldDraft<T extends Object> {
  final List<_DraftGroup<T>> _groups;
  final bool _widens;
  final List<(String, String, int)> _values;

  FieldDraft._({
    required List<_DraftGroup<T>> groups,
    required bool widens,
    required List<(String, String, int)> values,
  }) : _groups = groups,
       _widens = widens,
       _values = values;

  int get shown => _groups.fold(0, (count, group) => count + group.inRow);

  int countWith(RecordCondition<T> draft) {
    var count = 0;
    for (final group in _groups) {
      final holds = draft.holds(group.sample);
      if (draft.excludes) {
        count += holds ? 0 : group.inRow;
      } else if (_widens) {
        count += group.inRow + (holds ? group.outOfRow : 0);
      } else {
        count += holds ? group.inRow : 0;
      }
    }
    return count;
  }

  /// The values the field holds most, those holding [text] if any.
  List<(String, int)> suggestionsOf(String text, {int limit = 4}) {
    final needle = text.trim().toLowerCase();
    final found = <(String, int)>[];
    for (final (value, lower, count) in _values) {
      if (lower.contains(needle)) {
        found.add((value, count));
        if (found.length == limit) {
          break;
        }
      }
    }
    return found;
  }
}
