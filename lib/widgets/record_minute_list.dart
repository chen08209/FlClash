import 'dart:collection';

import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';

/// Each minute once, newest first, whatever order [items] come in.
List<RecordGroup<T>> recordMinuteGroups<T>(
  List<T> items,
  DateTime Function(T item) timeOf,
  DateTime now,
) {
  final byMinute = <int, List<T>>{};
  for (final item in items.reversed) {
    final minute =
        timeOf(item).microsecondsSinceEpoch ~/ Duration.microsecondsPerMinute;
    (byMinute[minute] ??= []).add(item);
  }
  final minutes = byMinute.keys.toList()..sort((a, b) => b - a);
  return [
    for (final minute in minutes)
      RecordGroup(minute, recordMinuteLabel(minute, now), byMinute[minute]!),
  ];
}

String recordMinuteLabel(int minute, DateTime now) {
  final today = now.toLocal();
  String two(int value) => value.toString().padLeft(2, '0');
  final local = DateTime.fromMicrosecondsSinceEpoch(
    minute * Duration.microsecondsPerMinute,
  );
  final time = '${two(local.hour)}:${two(local.minute)}';
  final isToday =
      local.year == today.year &&
      local.month == today.month &&
      local.day == today.day;
  return isToday ? time : '${two(local.month)}-${two(local.day)} $time';
}

sealed class MinuteRow<T> {
  const MinuteRow();
}

final class MinuteRecord<T> extends MinuteRow<T> {
  final T item;

  final ItemPosition position;

  const MinuteRecord(this.item, this.position);
}

final class MinuteHeader<T> extends MinuteRow<T> {
  final Object minute;
  final String label;
  final int count;

  const MinuteHeader(this.minute, this.label, this.count);

  ValueKey<(String, Object)> get key => ValueKey(('minute', minute));
}

/// A [RecordMinuteList]'s rows, oldest first, each minute's records ahead of
/// the header that closes them.
abstract interface class MinuteRows<T> {
  int get length;

  MinuteRow<T> rowAt(int index);

  Key keyOf(T item);

  /// Where the row built under [key] is now.
  int? indexOfKey(Key key);
}

class GroupedMinuteRows<T> implements MinuteRows<T> {
  final Key Function(T item) _keyOf;
  final List<(RecordGroup<T>, int)> _rows;
  Map<Key, int>? _indexes;

  GroupedMinuteRows(List<RecordGroup<T>> groups, this._keyOf)
    : _rows = [
        for (final group in groups.reversed) ...[
          for (var index = group.items.length - 1; index >= 0; index--)
            (group, index),
          (group, -1),
        ],
      ];

  @override
  int get length => _rows.length;

  @override
  MinuteRow<T> rowAt(int index) => switch (_rows[index]) {
    (final group, -1) => MinuteHeader(
      group.key,
      group.label,
      group.items.length,
    ),
    (final group, final item) => MinuteRecord(
      group.items[item],
      ItemPosition.get(item, group.items.length),
    ),
  };

  @override
  Key keyOf(T item) => _keyOf(item);

  @override
  int? indexOfKey(Key key) => (_indexes ??= _indexRows())[key];

  /// A key's own hash reads its runtimeType, too slow across thousands of rows.
  Map<Key, int> _indexRows() {
    final indexes = HashMap<Key, int>(hashCode: _keyHash);
    for (final (index, row) in _rows.indexed) {
      indexes[switch (row) {
            (final group, -1) => ValueKey(('minute', group.key)),
            (final group, final item) => keyOf(group.items[item]),
          }] =
          index;
    }
    return indexes;
  }
}

/// Newest at the top, each row keyed to its record so one arriving above
/// them moves the rows built rather than building them anew.
class RecordMinuteList<T> extends StatelessWidget {
  final MinuteRows<T> rows;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final Widget Function(T item) itemBuilder;
  final bool addAutomaticKeepAlives;

  const RecordMinuteList({
    super.key,
    required this.rows,
    required this.itemBuilder,
    this.controller,
    this.physics,
    this.padding,
    this.addAutomaticKeepAlives = true,
  });

  @override
  Widget build(BuildContext context) {
    return ArrivalCacheExtentBuilder(
      builder: (cacheExtent) => CustomScrollView(
        reverse: true,
        shrinkWrap: true,
        controller: controller,
        physics: physics,
        scrollCacheExtent: cacheExtent,
        slivers: [
          SliverPadding(
            padding: padding ?? EdgeInsets.zero,
            sliver: SliverPrismList(
              itemCount: rows.length,
              estimatedItemExtent: recordListEstimatedExtent,
              findChildIndexCallback: rows.indexOfKey,
              anchorAtEnd: true,
              addAutomaticKeepAlives: addAutomaticKeepAlives,
              itemBuilder: (context, index) => switch (rows.rowAt(index)) {
                MinuteHeader(:final key, :final label, :final count) =>
                  KeyedSubtree(
                    key: key,
                    child: RecordMinuteHeader(label: label, count: count),
                  ),
                MinuteRecord(:final item, :final position) => KeyedSubtree(
                  key: rows.keyOf(item),
                  child: ItemPositionProvider(
                    position: position,
                    child: itemBuilder(item),
                  ),
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// The minute a run of records opened in, and how many it holds.
class RecordMinuteHeader extends StatelessWidget {
  final String label;
  final int count;

  const RecordMinuteHeader({
    super.key,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme.onSurfaceVariant;
    TextStyle styleOf({required bool emphasized}) => AppTextStyle.footnote
        .of(context, emphasized: emphasized)
        .toTabular
        .copyWith(color: color);
    final leading = context.listInsets.leading;
    return Padding(
      padding: EdgeInsets.fromLTRB(leading, 14, leading, 6),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: label, style: styleOf(emphasized: true)),
            TextSpan(text: '  $count'),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: styleOf(emphasized: false),
      ),
    );
  }
}

int _keyHash(Key key) => switch (key) {
  ValueKey(:final value) => value.hashCode,
  ObjectKey(:final value) => identityHashCode(value),
  _ => key.hashCode,
};
