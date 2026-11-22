import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
class RecordFilterState {
  final List<RecordFilter> filters;

  const RecordFilterState({this.filters = const []});
}

typedef RecordFacetOptions = Map<RecordFacetKind, List<String>>;

const _optionsEquality = MapEquality<RecordFacetKind, List<String>>(
  values: ListEquality(),
);

class RecordFilterController<T> extends ValueNotifier<RecordFilterState> {
  final List<RecordFacet<T>> facets;

  final _keywords = ValueNotifier<List<ScaffoldKeyword>>(const []);

  // Apart from [value] so a list refresh, which only moves [options] when a
  // value comes or goes, leaves the bar and its chips alone.
  final options = ValueNotifier<RecordFacetOptions>(const {});

  RecordFilterController({required this.facets})
    : super(const RecordFilterState());

  List<RecordFilter> get filters => value.filters;

  bool get isFiltering => filters.isNotEmpty;

  RecordFacet<T>? facetOf(RecordFacetKind kind) =>
      facets.firstWhereOrNull((facet) => facet.kind == kind);

  void add(RecordFilter filter) {
    if (!filters.contains(filter)) {
      _setFilters([...filters, filter]);
    }
  }

  void remove(RecordFilter filter) {
    if (filters.contains(filter)) {
      _setFilters([...filters]..remove(filter));
    }
  }

  void toggle(RecordFilter filter) {
    filters.contains(filter) ? remove(filter) : add(filter);
  }

  ValueListenable<List<ScaffoldKeyword>> get keywords => _keywords;

  void _setFilters(List<RecordFilter> filters) {
    value = RecordFilterState(filters: filters);
    _updateKeywords();
  }

  void _updateKeywords() {
    _keywords.value = [
      for (final filter in filters)
        ScaffoldKeyword(
          key: filter,
          label: facetOf(filter.kind)?.label(filter.value) ?? filter.value,
          onDeleted: () => remove(filter),
        ),
    ];
  }

  /// Offers the values [items] take, read before any filter narrows them.
  void offer(Iterable<T> items) {
    final next = <RecordFacetKind, List<String>>{};
    for (final facet in facets) {
      if (!facet.offered) {
        continue;
      }
      final values = facet.optionsOf(
        items,
        selected: [
          for (final filter in filters)
            if (filter.kind == facet.kind) filter.value,
        ],
      );
      if (values.isNotEmpty) {
        next[facet.kind] = values;
      }
    }
    if (!_optionsEquality.equals(next, options.value)) {
      options.value = next;
    }
  }

  List<T> apply(List<T> items) =>
      isFiltering ? items.whereFilters(facets, filters).toList() : items;

  List<PopupMenuItem> optionMenuItems() {
    final options = this.options.value;
    return [
      for (final facet in facets)
        for (final (index, option) in (options[facet.kind] ?? []).indexed)
          PopupMenuItem(
            label: facet.label(option),
            checked: filters.contains(RecordFilter(facet.kind, option)),
            keepsOpen: true,
            section: index == 0
                ? PopupMenuSection(title: facet.kind.title)
                : null,
            onPressed: () => toggle(RecordFilter(facet.kind, option)),
          ),
    ];
  }

  @override
  void dispose() {
    _keywords.dispose();
    options.dispose();
    super.dispose();
  }
}

/// Lets a value tapped in a row narrow the list it sits in.
class RecordFilterScope extends InheritedWidget {
  final ValueChanged<RecordFilter> onFilter;

  const RecordFilterScope({
    super.key,
    required this.onFilter,
    required super.child,
  });

  static void add(BuildContext context, RecordFilter filter) {
    context.getInheritedWidgetOfExactType<RecordFilterScope>()?.onFilter(
      filter,
    );
  }

  @override
  bool updateShouldNotify(RecordFilterScope oldWidget) => false;
}
