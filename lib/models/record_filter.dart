import 'package:collection/collection.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/foundation.dart';

const recordFacetMaxOptions = 12;

@immutable
class RecordFilter {
  final RecordFacetKind kind;
  final String value;

  const RecordFilter(this.kind, this.value);

  @override
  bool operator ==(Object other) =>
      other is RecordFilter && other.kind == kind && other.value == value;

  @override
  int get hashCode => Object.hash(kind, value);

  @override
  String toString() => 'RecordFilter(${kind.name}: $value)';
}

/// Filters on one facet widen each other, on different facets narrow.
class RecordFacet<T> {
  final RecordFacetKind kind;
  final Iterable<String> Function(T item) valuesOf;

  /// Only a facet whose values come from a fixed set is offered in the menu;
  /// one growing with the user's apps or profiles is filtered from a row.
  final bool offered;

  final List<String> order;
  final String Function(String value)? labelOf;

  const RecordFacet(
    this.kind,
    this.valuesOf, {
    this.offered = false,
    this.order = const [],
    this.labelOf,
  });

  String label(String value) => labelOf?.call(value) ?? value;

  List<String> optionsOf(
    Iterable<T> items, {
    Iterable<String> selected = const [],
    int max = recordFacetMaxOptions,
  }) {
    final counts = <String, int>{};
    for (final item in items) {
      for (final value in valuesOf(item)) {
        if (value.isNotEmpty) {
          counts[value] = (counts[value] ?? 0) + 1;
        }
      }
    }
    final frequent = counts.keys.sorted((a, b) => counts[b]! - counts[a]!);
    final options = {...frequent.take(max), ...selected}.toList();
    int rank(String value) {
      final index = order.indexOf(value);
      return index < 0 ? order.length : index;
    }

    return options..sort((a, b) {
      final ranked = rank(a) - rank(b);
      return ranked != 0 ? ranked : a.toLowerCase().compareTo(b.toLowerCase());
    });
  }
}

class RecordGroup<T> {
  final Object key;
  final String label;

  /// Top first.
  final List<T> items;

  const RecordGroup(this.key, this.label, this.items);
}

extension RecordFilterIterableExt<T> on Iterable<T> {
  Iterable<T> whereFilters(
    List<RecordFacet<T>> facets,
    List<RecordFilter> filters,
  ) {
    if (filters.isEmpty) {
      return this;
    }
    final selected = <RecordFacet<T>, Set<String>>{};
    for (final filter in filters) {
      final facet = facets.firstWhereOrNull(
        (facet) => facet.kind == filter.kind,
      );
      if (facet != null) {
        (selected[facet] ??= {}).add(filter.value);
      }
    }
    return where(
      (item) => selected.entries.every(
        (entry) => entry.key.valuesOf(item).any(entry.value.contains),
      ),
    );
  }
}
