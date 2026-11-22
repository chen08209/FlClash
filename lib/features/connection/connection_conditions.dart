import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';

import 'connection_condition_form.dart';
import 'connection_filters.dart';

typedef _Entry = ({
  Object source,
  String operator,
  String value,
  bool editable,
});

/// The conditions and the values picked elsewhere that narrow a list, a row
/// to each field, so that a row widens and the rows narrow.
class ConditionBlock<T extends Object> extends StatelessWidget {
  final ConditionFilterController<T, Enum> controller;

  const ConditionBlock({super.key, required this.controller});

  static bool showsFor(ConditionFilterController<Object, Enum> controller) =>
      controller.conditions.isNotEmpty || controller.filters.isNotEmpty;

  List<(String, List<_Entry>)> _rows() {
    final equals = currentAppLocalizations.conditionEquals;
    String labelOf(RecordFilter filter) =>
        controller.facetOf(filter.kind)?.label(filter.value) ?? filter.value;
    _Entry conditionEntry(RecordCondition<T> condition) => (
      source: condition,
      operator: condition.operatorLabel,
      value: condition.value,
      editable: true,
    );
    final rows = <(String, List<_Entry>)>[];
    for (final field in controller.fields) {
      final widening = <_Entry>[
        for (final filter in controller.filters)
          if (controller.fieldOf(filter.kind) == field)
            (
              source: filter,
              operator: equals,
              value: labelOf(filter),
              editable: true,
            ),
        for (final condition in controller.conditions)
          if (condition.field == field && !condition.excludes)
            conditionEntry(condition),
      ];
      if (widening.isNotEmpty) {
        rows.add((field.label, widening));
      }
      // Each excluding condition must hold on its own, so none shares a row.
      for (final condition in controller.conditions) {
        if (condition.field == field && condition.excludes) {
          rows.add((field.label, [conditionEntry(condition)]));
        }
      }
    }
    final unfielded = controller.filters
        .where((filter) => controller.fieldOf(filter.kind) == null)
        .groupListsBy((filter) => filter.kind);
    for (final MapEntry(key: kind, value: filters) in unfielded.entries) {
      rows.add((
        kind.title ?? '',
        [
          for (final filter in filters)
            (
              source: filter,
              operator: '',
              value: labelOf(filter),
              editable: false,
            ),
        ],
      ));
    }
    return rows;
  }

  void _remove(Object source) {
    switch (source) {
      case final RecordCondition<T> condition:
        controller.removeCondition(condition);
      case final RecordFilter filter:
        controller.remove(filter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final level = context.raisedSurfaceLevel;
    final rows = _rows();
    final captionStyle = AppTextStyle.caption1
        .of(context)
        .copyWith(color: colorScheme.onSurfaceVariant);
    final titleStyle = AppTextStyle.footnote
        .of(context)
        .copyWith(color: colorScheme.onSurfaceVariant);
    final measure = MeasureScope.of(context);
    var titleWidth = _titleMinWidth;
    for (final (title, _) in rows) {
      titleWidth = math.max(
        titleWidth,
        measure
            .computeTextSize(Text(title, style: titleStyle))
            .width
            .ceilToDouble(),
      );
    }
    final separator = ColoredBox(
      color: Divider.colorOf(context),
      child: const SizedBox(height: 1, width: double.infinity),
    );
    return Semantics(
      container: true,
      label: appLocalizations.condition,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: level.colorOf(colorScheme),
          shape: AppShape.all(AppCorner.lg),
        ),
        child: SurfaceScope(
          level: level,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 8, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (index, (title, entries)) in rows.indexed) ...[
                  if (index > 0) separator,
                  _ConditionRow<T>(
                    controller: controller,
                    title: title,
                    titleWidth: titleWidth,
                    titleStyle: titleStyle,
                    orStyle: captionStyle,
                    entries: entries,
                    onRemove: _remove,
                  ),
                ],
                separator,
                SizedBox(
                  height: 40,
                  child: Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: Text(
                          appLocalizations.conditionRows,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: captionStyle,
                        ),
                      ),
                      SizedBox(
                        height: _chipHeight,
                        child: PressSurface(
                          fill: const Color(0x00000000),
                          shape: AppShape.full,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          onPressed: controller.clearConditions,
                          child: Center(
                            widthFactor: 1,
                            child: Text(
                              appLocalizations.clearAll,
                              style: AppTextStyle.footnote
                                  .of(context)
                                  .copyWith(color: colorScheme.primary),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConditionRow<T extends Object> extends StatelessWidget {
  final ConditionFilterController<T, Enum> controller;
  final String title;
  final double titleWidth;
  final TextStyle titleStyle;
  final TextStyle orStyle;
  final List<_Entry> entries;
  final ValueChanged<Object> onRemove;

  const _ConditionRow({
    required this.controller,
    required this.title,
    required this.titleWidth,
    required this.titleStyle,
    required this.orStyle,
    required this.entries,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final or = context.appLocalizations.conditionOr;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          SizedBox(
            width: titleWidth,
            height: _chipHeight,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(title, maxLines: 1, style: titleStyle),
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final (index, entry) in entries.indexed)
                  _orBefore(
                    index > 0 ? Text(or, style: orStyle) : null,
                    _ConditionChip(
                      operator: entry.operator,
                      value: entry.value,
                      onPressed: !entry.editable
                          ? null
                          : () => showConditionDialog<T>(
                              context,
                              controller: controller,
                              editing: entry.source,
                            ),
                      onDeleted: () => onRemove(entry.source),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Keeps an "or" on the line of the chip it leads, never ending one alone.
Widget _orBefore(Widget? or, Widget chip) {
  if (or == null) {
    return chip;
  }
  return Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 6,
    children: [
      or,
      Flexible(child: chip),
    ],
  );
}

const _titleMinWidth = 32.0;
const _chipHeight = 32.0;

class _ConditionChip extends StatelessWidget {
  final String operator;
  final String value;
  final VoidCallback? onPressed;
  final VoidCallback onDeleted;

  const _ConditionChip({
    required this.operator,
    required this.value,
    required this.onPressed,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final style = AppTextStyle.footnote.of(context);
    final secondary = colorScheme.onSurfaceVariant;
    return SizedBox(
      height: _chipHeight,
      child: PressSurface(
        fill: context.raisedSurfaceLevel.colorOf(colorScheme),
        shape: AppShape.full,
        inert: onPressed == null,
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 12),
            Flexible(
              child: Text.rich(
                TextSpan(
                  children: [
                    if (operator.isNotEmpty)
                      TextSpan(
                        text: '$operator ',
                        style: style.copyWith(color: secondary),
                      ),
                    TextSpan(text: value),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style.copyWith(color: colorScheme.onSurface),
              ),
            ),
            const SizedBox(width: 2),
            Semantics(
              button: true,
              label: context.appLocalizations.remove,
              excludeSemantics: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onDeleted,
                child: SizedBox(
                  width: 28,
                  height: _chipHeight,
                  child: Center(
                    child: GlyphIcon(
                      AppGlyphs.close,
                      size: 16,
                      color: secondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
