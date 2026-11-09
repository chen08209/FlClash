import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'record.dart';

@immutable
class RecordFilterState {
  final List<RecordFilter> filters;
  final RecordGrouping? grouping;

  const RecordFilterState({this.filters = const [], this.grouping});
}

typedef RecordFacetOptions = Map<RecordFacetKind, List<String>>;

const _optionsEquality = MapEquality<RecordFacetKind, List<String>>(
  values: ListEquality(),
);

class RecordFilterController<T> extends ValueNotifier<RecordFilterState> {
  final List<RecordFacet<T>> facets;
  final List<RecordGrouper<T>> groupers;
  final ValueChanged<RecordGrouping?>? onGroupingChanged;

  // Apart from [value] so a list refresh, which only moves [options] when a
  // value comes or goes, leaves the bar and its chips alone.
  final _keywords = ValueNotifier<List<ScaffoldKeyword>>(const []);
  final _pinnedKeywords = ValueNotifier<List<ScaffoldKeyword>>(const []);
  final options = ValueNotifier<RecordFacetOptions>(const {});

  RecordFilterController({
    required this.facets,
    this.groupers = const [],
    RecordGrouping? grouping,
    this.onGroupingChanged,
  }) : super(
         RecordFilterState(
           grouping: groupers.any((grouper) => grouper.grouping == grouping)
               ? grouping
               : null,
         ),
       );

  List<RecordFilter> get filters => value.filters;

  bool get isFiltering => filters.isNotEmpty;

  RecordGrouper<T>? get grouper => groupers.firstWhereOrNull(
    (grouper) => grouper.grouping == value.grouping,
  );

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

  /// [pinned] keeps every offered value in the strip as a toggle.
  ValueListenable<List<ScaffoldKeyword>> keywordsOf({required bool pinned}) =>
      pinned ? _pinnedKeywords : _keywords;

  void _setFilters(List<RecordFilter> filters) {
    value = RecordFilterState(filters: filters, grouping: value.grouping);
    _updateKeywords();
  }

  ScaffoldKeyword _removable(
    RecordFilter filter, {
    bool startsSection = false,
  }) {
    return ScaffoldKeyword(
      key: filter,
      label: facetOf(filter.kind)?.label(filter.value) ?? filter.value,
      onDeleted: () => remove(filter),
      startsSection: startsSection,
    );
  }

  void _updateKeywords() {
    _keywords.value = [for (final filter in filters) _removable(filter)];
    final options = this.options.value;
    final pinned = <ScaffoldKeyword>[];
    for (final facet in facets) {
      for (final (index, option) in (options[facet.kind] ?? []).indexed) {
        final filter = RecordFilter(facet.kind, option);
        pinned.add(
          ScaffoldKeyword(
            key: filter,
            label: facet.label(option),
            selected: filters.contains(filter),
            onPressed: () => toggle(filter),
            startsSection: index == 0 && pinned.isNotEmpty,
          ),
        );
      }
    }
    final unpinned = filters.where(
      (filter) => !(options[filter.kind]?.contains(filter.value) ?? false),
    );
    for (final (index, filter) in unpinned.indexed) {
      pinned.add(
        _removable(filter, startsSection: index == 0 && pinned.isNotEmpty),
      );
    }
    _pinnedKeywords.value = pinned;
  }

  void setGrouping(RecordGrouping? grouping) {
    if (grouping == value.grouping) {
      return;
    }
    value = RecordFilterState(filters: filters, grouping: grouping);
    onGroupingChanged?.call(grouping);
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
      _updateKeywords();
    }
  }

  List<T> apply(List<T> items) =>
      isFiltering ? items.whereFilters(facets, filters).toList() : items;

  List<RecordGroup<T>>? groupsOf(List<T> items, {bool reverse = false}) {
    final keyOf = grouper?.keyOf;
    return keyOf == null ? null : groupRecords(items, keyOf, reverse: reverse);
  }

  List<PopupMenuItem> menuItems(BuildContext context, {required bool pinned}) {
    final appLocalizations = context.appLocalizations;
    final options = this.options.value;
    final grouping = value.grouping;
    return [
      if (!pinned && options.isNotEmpty)
        PopupMenuItem(
          glyph: AppGlyphs.filter,
          label: appLocalizations.filter,
          subItems: [
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
          ],
        ),
      if (groupers.isNotEmpty)
        PopupMenuItem(
          glyph: AppGlyphs.layers,
          label: appLocalizations.groupBy,
          subItems: [
            PopupMenuItem(
              label: appLocalizations.none,
              checked: grouping == null,
              onPressed: () => setGrouping(null),
            ),
            for (final grouper in groupers)
              PopupMenuItem(
                label: grouper.grouping.label,
                checked: grouping == grouper.grouping,
                onPressed: () => setGrouping(grouper.grouping),
              ),
          ],
        ),
    ];
  }

  @override
  void dispose() {
    _keywords.dispose();
    _pinnedKeywords.dispose();
    options.dispose();
    super.dispose();
  }
}

RecordGrouping? savedRecordGrouping(WidgetRef ref, String pageId) {
  final name = ref.read(appSettingProvider).recordGroupings[pageId];
  return RecordGrouping.values.asNameMap()[name];
}

void saveRecordGrouping(
  WidgetRef ref,
  String pageId,
  RecordGrouping? grouping,
) {
  ref.read(appSettingProvider.notifier).update((state) {
    final groupings = {...state.recordGroupings}..remove(pageId);
    if (grouping != null) {
      groupings[pageId] = grouping.name;
    }
    return state.copyWith(recordGroupings: groupings);
  });
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

/// Lays [groups] out folded under their headers, newest first whatever way
/// the list reads ungrouped.
class RecordGroupedList<T> extends StatelessWidget {
  final List<RecordGroup<T>> groups;
  final RecordGrouping grouping;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final double estimatedItemExtent;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? Function(RecordGroup<T> group)? leadingOf;
  final Widget? Function(RecordGroup<T> group)? trailingOf;

  const RecordGroupedList({
    super.key,
    required this.groups,
    required this.grouping,
    this.controller,
    this.padding,
    this.estimatedItemExtent = recordListEstimatedExtent,
    required this.itemBuilder,
    this.leadingOf,
    this.trailingOf,
  });

  @override
  Widget build(BuildContext context) {
    final other = context.appLocalizations.other;
    return ArrivalCacheExtentBuilder(
      builder: (cacheExtent) => CustomScrollView(
        controller: controller,
        scrollCacheExtent: cacheExtent,
        slivers: [
          SliverPadding(
            padding: padding ?? EdgeInsets.zero,
            sliver: SliverCollapsibleGroups(
              key: ValueKey(grouping),
              estimatedItemExtent: estimatedItemExtent,
              groups: [
                for (final group in groups)
                  CollapsibleGroup(
                    key: group.key,
                    label: group.key.isEmpty ? other : group.key,
                    itemCount: group.items.length,
                    leading: leadingOf?.call(group),
                    trailing: trailingOf?.call(group),
                  ),
              ],
              itemBuilder: (context, group, index) =>
                  itemBuilder(context, groups[group].items[index], index),
            ),
          ),
        ],
      ),
    );
  }
}
