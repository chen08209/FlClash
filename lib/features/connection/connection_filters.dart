import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectionStatus { all, active, failed, decrypted }

extension ConnectionStatusExt on ConnectionStatus {
  bool holds(TrackerInfo trackerInfo) => switch (this) {
    ConnectionStatus.all => true,
    ConnectionStatus.active => trackerInfo.isActive,
    ConnectionStatus.failed => trackerInfo.failure != null,
    ConnectionStatus.decrypted => trackerInfo.metadata.mitm,
  };

  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      ConnectionStatus.all => appLocalizations.connectionsAll,
      ConnectionStatus.active => appLocalizations.connectionsActive,
      ConnectionStatus.failed => appLocalizations.connectionsFailed,
      ConnectionStatus.decrypted => appLocalizations.connectionsDecrypted,
    };
  }
}

/// Offered with how many connections hold each value.
const connectionFacetKinds = [
  RecordFacetKind.app,
  RecordFacetKind.proxy,
  RecordFacetKind.rule,
  RecordFacetKind.network,
];

String connectionFacetTitle(RecordFacetKind kind) {
  final appLocalizations = currentAppLocalizations;
  return switch (kind) {
    RecordFacetKind.app => appLocalizations.app,
    RecordFacetKind.proxy => appLocalizations.outboundExit,
    RecordFacetKind.rule => appLocalizations.rule,
    _ => appLocalizations.protocol,
  };
}

/// The connections page's filters: one status, and any values of the facets,
/// which its strip offers with their counts.
class ConnectionFilterController extends RecordFilterController<TrackerInfo> {
  final _strip = ValueNotifier<List<ScaffoldKeyword>>(const []);
  final _barStrip = ValueNotifier<List<ScaffoldKeyword>>(const []);
  final _counted = ValueNotifier(0);
  var _status = ConnectionStatus.all;
  var _conditions = const <ConnectionCondition>[];

  /// Ends the strip with a chip that asks for a condition to add.
  final VoidCallback? onAskCondition;
  var _statusCounts = const <ConnectionStatus, int>{};
  var _valueCounts = const <RecordFacetKind, Map<String, int>>{};

  ConnectionFilterController({
    super.groupers,
    super.grouping,
    super.onGroupingChanged,
    this.onAskCondition,
  }) : super(facets: trackerInfoFacets) {
    _updateStrip();
    addListener(_updateStrip);
  }

  ConnectionFilterController.saved(
    WidgetRef ref,
    String pageId, {
    VoidCallback? onAskCondition,
  }) : this(
         onAskCondition: onAskCondition,
         groupers: trackerInfoGroupers,
         grouping: savedRecordGrouping(ref, pageId),
         onGroupingChanged: (grouping) =>
             saveRecordGrouping(ref, pageId, grouping),
       );

  ConnectionStatus get status => _status;

  set status(ConnectionStatus status) {
    if (status == _status) {
      return;
    }
    _status = status;
    _updateStrip();
    notifyListeners();
  }

  @override
  bool get isFiltering =>
      super.isFiltering ||
      _status != ConnectionStatus.all ||
      _conditions.isNotEmpty;

  List<ConnectionCondition> get conditions => _conditions;

  void addCondition(ConnectionCondition condition) {
    if (_conditions.contains(condition)) {
      return;
    }
    _conditions = [..._conditions, condition];
    _updateStrip();
    notifyListeners();
  }

  void removeCondition(ConnectionCondition condition) {
    _conditions = [..._conditions]..remove(condition);
    _updateStrip();
    notifyListeners();
  }

  @override
  ValueListenable<List<ScaffoldKeyword>> keywordsOf({required bool pinned}) =>
      _strip;

  ValueListenable<List<ScaffoldKeyword>> get barKeywords => _barStrip;

  Listenable get counted => _counted;

  int countOf(ConnectionStatus status) => _statusCounts[status] ?? 0;

  int countOfValue(RecordFacetKind kind, String value) =>
      _valueCounts[kind]?[value] ?? 0;

  /// The most held first, then any selected that no connection holds now.
  List<String> valuesOf(RecordFacetKind kind) {
    final counts = _valueCounts[kind] ?? const {};
    return {
      ...counts.keys.sorted((a, b) => counts[b]! - counts[a]!),
      ...selectedOf(kind),
    }.toList();
  }

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
  List<PopupMenuItem> menuItems(BuildContext context, {required bool pinned}) =>
      super.menuItems(context, pinned: true);

  @override
  List<TrackerInfo> apply(List<TrackerInfo> items) {
    final filtered = super.apply(items);
    if (_status == ConnectionStatus.all && _conditions.isEmpty) {
      return filtered;
    }
    final matches = ConnectionQuery(_conditions).matcher;
    return [
      for (final item in filtered)
        if (_status.holds(item) && matches(item)) item,
    ];
  }

  /// [apply], with the failed view's repeated dials to one target as the
  /// newest of them, counted.
  ({List<TrackerInfo> items, Map<String, int> repeats}) present(
    List<TrackerInfo> items,
  ) {
    final shown = apply(items);
    if (_status != ConnectionStatus.failed) {
      return (items: shown, repeats: const {});
    }
    final newest = <Object, TrackerInfo>{};
    final repeats = <String, int>{};
    for (final item in shown.reversed) {
      final metadata = item.metadata;
      final key = (
        item.failure?.kind,
        metadata.network,
        item.title,
        metadata.destinationPort,
        metadata.process,
      );
      final kept = newest[key];
      if (kept == null) {
        newest[key] = item;
      } else {
        repeats[kept.id] = (repeats[kept.id] ?? 1) + 1;
      }
    }
    return (items: newest.values.toList().reversed.toList(), repeats: repeats);
  }

  @override
  void offer(Iterable<TrackerInfo> items) {
    super.offer(items);
    final statusCounts = {
      for (final status in ConnectionStatus.values) status: 0,
    };
    final valueCounts = {
      for (final kind in connectionFacetKinds) kind: <String, int>{},
    };
    for (final item in items) {
      for (final status in ConnectionStatus.values) {
        if (status.holds(item)) {
          statusCounts[status] = statusCounts[status]! + 1;
        }
      }
      for (final kind in connectionFacetKinds) {
        final counts = valueCounts[kind]!;
        for (final value in facetOf(kind)!.valuesOf(item)) {
          if (value.isNotEmpty) {
            counts[value] = (counts[value] ?? 0) + 1;
          }
        }
      }
    }
    const equality = DeepCollectionEquality();
    if (equality.equals(statusCounts, _statusCounts) &&
        equality.equals(valueCounts, _valueCounts)) {
      return;
    }
    _statusCounts = statusCounts;
    _valueCounts = valueCounts;
    _updateStrip();
    _counted.value++;
  }

  List<PopupMenuItem> _menuOf(RecordFacetKind kind) {
    final facet = facetOf(kind)!;
    final selected = selectedOf(kind);
    return [
      PopupMenuItem(
        label: ConnectionStatus.all.label,
        checked: selected.isEmpty,
        onPressed: () => clear(kind),
      ),
      for (final (index, value) in valuesOf(kind).indexed)
        PopupMenuItem(
          label: facet.label(value),
          subtitle: '${countOfValue(kind, value)}',
          checked: selected.contains(value),
          keepsOpen: true,
          section: index == 0 ? const PopupMenuSection() : null,
          onPressed: () => toggle(RecordFilter(kind, value)),
        ),
    ];
  }

  void _updateStrip() {
    final strip = <ScaffoldKeyword>[
      for (final status in [
        ConnectionStatus.all,
        ConnectionStatus.active,
        ConnectionStatus.failed,
        if (rsFeature) ConnectionStatus.decrypted,
      ])
        ScaffoldKeyword(
          key: status,
          label: '${status.label} ${_statusCounts[status] ?? 0}',
          selected: _status == status,
          onPressed: () => this.status = status,
        ),
    ];
    final menus = <ScaffoldKeyword>[];
    for (final kind in connectionFacetKinds) {
      final selected = selectedOf(kind).length;
      if ((_valueCounts[kind] ?? const {}).isEmpty && selected == 0) {
        continue;
      }
      final title = connectionFacetTitle(kind);
      menus.add(
        ScaffoldKeyword(
          key: kind,
          label: selected == 0 ? title : '$title · $selected',
          selected: selected > 0,
          startsSection: menus.isEmpty,
          menuItems: () => _menuOf(kind),
        ),
      );
    }
    final onAskCondition = this.onAskCondition;
    final others = [
      for (final (index, filter)
          in filters
              .where((filter) => !connectionFacetKinds.contains(filter.kind))
              .indexed)
        ScaffoldKeyword(
          key: filter,
          label: facetOf(filter.kind)?.label(filter.value) ?? filter.value,
          onDeleted: () => remove(filter),
          startsSection: index == 0,
        ),
      for (final (index, condition) in _conditions.indexed)
        ScaffoldKeyword(
          key: condition,
          label: '$condition',
          onDeleted: () => removeCondition(condition),
          startsSection: index == 0,
        ),
      if (onAskCondition != null)
        ScaffoldKeyword(
          key: ConnectionCondition,
          label: '+ ${currentAppLocalizations.condition}',
          onPressed: onAskCondition,
          startsSection: _conditions.isEmpty,
        ),
    ];
    _strip.value = [...strip, ...menus, ...others];
    _barStrip.value = [...strip, ...others];
  }

  @override
  void dispose() {
    _strip.dispose();
    _barStrip.dispose();
    _counted.dispose();
    super.dispose();
  }
}
