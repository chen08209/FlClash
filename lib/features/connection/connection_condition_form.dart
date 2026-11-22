import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' show NumberFormat;

import 'connection_filters.dart';

/// A condition's match and whether it excludes, as one choice.
enum _Operator {
  contains(ConditionMatch.contains, excludes: false),
  notContains(ConditionMatch.contains, excludes: true),
  equals(ConditionMatch.equals, excludes: false),
  notEquals(ConditionMatch.equals, excludes: true);

  const _Operator(this.match, {required this.excludes});

  factory _Operator.of(RecordCondition condition) => values.firstWhere(
    (operator) =>
        operator.match == condition.match &&
        operator.excludes == condition.excludes,
  );

  final ConditionMatch match;
  final bool excludes;

  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      _Operator.contains => appLocalizations.conditionContains,
      _Operator.notContains => appLocalizations.conditionNotContains,
      _Operator.equals => appLocalizations.conditionEquals,
      _Operator.notEquals => appLocalizations.conditionNotEquals,
    };
  }
}

extension RecordConditionL10n on RecordCondition {
  String get operatorLabel => _Operator.of(this).label;
}

final _grouped = NumberFormat.decimalPattern('en');

/// Asks for a condition on [controller]'s list, in place of [editing], a
/// condition or a facet's value, if given.
Future<void> showConditionDialog<T extends Object>(
  BuildContext context, {
  required ConditionFilterController<T, Enum> controller,
  Object? editing,
}) {
  return dialogs.showCommonDialog<void>(
    context: context,
    child: _ConditionDialog<T>(controller: controller, editing: editing),
  );
}

class _ConditionDialog<T extends Object> extends StatefulWidget {
  final ConditionFilterController<T, Enum> controller;
  final Object? editing;

  const _ConditionDialog({required this.controller, this.editing});

  @override
  State<_ConditionDialog<T>> createState() => _ConditionDialogState<T>();
}

class _ConditionDialogState<T extends Object>
    extends State<_ConditionDialog<T>> {
  late final RecordCondition<T>? _initial = switch (widget.editing) {
    final RecordCondition<T> condition => condition,
    final RecordFilter filter => switch (widget.controller.fieldOf(
      filter.kind,
    )) {
      final field? => RecordCondition<T>(
        field,
        filter.value,
        match: ConditionMatch.equals,
      ),
      null => null,
    },
    _ => null,
  };
  late final _value = TextEditingController(text: _initial?.value);
  late var _field = _initial?.field ?? widget.controller.fields.first;
  late var _fieldDraft = _draftOn(_field);
  late var _operator = switch (_initial) {
    final condition? => _Operator.of(condition),
    null => _Operator.contains,
  };

  FieldDraft<T> _draftOn(RecordField<T> field) =>
      widget.controller.draftOn(field, replacing: widget.editing);

  void _setField(RecordField<T> field) {
    setState(() {
      _field = field;
      _fieldDraft = _draftOn(field);
    });
  }

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  String get _text => _value.text.trim().replaceAll('"', '');

  RecordCondition<T>? get _draft {
    final value = _text;
    if (value.isEmpty) {
      return null;
    }
    return RecordCondition<T>(
      _field,
      value,
      excludes: _operator.excludes,
      match: _operator.match,
    );
  }

  void _submit() {
    final draft = _draft;
    if (draft == null) {
      return;
    }
    final editing = widget.editing;
    if (editing == null) {
      widget.controller.addCondition(draft);
    } else if (draft != _initial) {
      widget.controller.replace(editing, draft);
    }
    Navigator.of(context).pop();
  }

  void _fill(String value) {
    _value.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return AlertDialog(
      title: widget.editing == null
          ? appLocalizations.addCondition
          : appLocalizations.editCondition,
      hasFields: true,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(appLocalizations.cancel),
        ),
        ListenableBuilder(
          listenable: _value,
          builder: (context, _) => TextButton(
            onPressed: _draft == null ? null : _submit,
            child: Text(
              widget.editing == null
                  ? appLocalizations.add
                  : appLocalizations.save,
            ),
          ),
        ),
      ],
      child: Builder(builder: _buildFields),
    );
  }

  Widget _buildFields(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final fields = widget.controller.fields;
    final colorScheme = context.colorScheme;
    final fill =
        InputDecorationTheme.of(context).fillColor ??
        context.raisedSurfaceLevel.colorOf(colorScheme);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        _Section(
          label: appLocalizations.conditionField,
          child: _ChoiceGrid(
            choices: [
              for (final field in fields)
                _Choice(
                  label: field.label,
                  selected: field == _field,
                  fill: fill,
                  onPressed: () => _setField(field),
                ),
            ],
          ),
        ),
        _Section(
          label: appLocalizations.condition,
          child: _ChoiceGrid(
            choices: [
              for (final operator in _Operator.values)
                _Choice(
                  label: operator.label,
                  selected: operator == _operator,
                  fill: fill,
                  onPressed: () => setState(() => _operator = operator),
                ),
            ],
          ),
        ),
        _Section(
          label: appLocalizations.value,
          child: TextField(
            controller: _value,
            autofocus: true,
            autocorrect: false,
            textInputAction: TextInputAction.done,
            style: AppTextStyle.body.of(context),
            onSubmitted: (_) => _submit(),
          ),
        ),
        ListenableBuilder(
          listenable: _value,
          builder: (context, _) => _buildOutcome(context, fill),
        ),
      ],
    );
  }

  Widget _buildOutcome(BuildContext context, Color fill) {
    final colorScheme = context.colorScheme;
    final draft = _draft;
    final suggestions = _fieldDraft.suggestionsOf(_text);
    final shown = draft == null
        ? _fieldDraft.shown
        : _fieldDraft.countWith(draft);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        if (suggestions.isNotEmpty)
          _Section(
            label: widget.controller.valuesInText(_field.label),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final (value, count) in suggestions)
                  _Suggestion(
                    value: value,
                    count: _grouped.format(count),
                    fill: fill,
                    onPressed: () => _fill(value),
                  ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _labelInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(
                widget.controller.showsText(_grouped.format(shown)),
                style: AppTextStyle.footnote
                    .of(context, emphasized: true)
                    .toTabular
                    .copyWith(color: colorScheme.onSurface),
              ),
              Text(
                widget.controller.conditionTip,
                style: AppTextStyle.footnote
                    .of(context)
                    .copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

const _labelInset = 14.0;

class _Section extends StatelessWidget {
  final String label;
  final Widget child;

  const _Section({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: _labelInset),
          child: Text(
            label,
            style: AppTextStyle.footnote
                .of(context)
                .copyWith(color: context.colorScheme.onSurfaceVariant),
          ),
        ),
        child,
      ],
    );
  }
}

class _ChoiceGrid extends StatelessWidget {
  final List<_Choice> choices;

  const _ChoiceGrid({required this.choices});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 6,
      children: [
        for (final row in choices.slices(choices.length > 4 ? 3 : 2))
          Row(
            spacing: 6,
            children: [for (final choice in row) Expanded(child: choice)],
          ),
      ],
    );
  }
}

/// Keeps a label that has to shrink to fit off the pill's rounded ends.
const _choiceInset = 8.0;

class _Choice extends StatelessWidget {
  final String label;
  final bool selected;
  final Color fill;
  final VoidCallback onPressed;

  const _Choice({
    required this.label,
    required this.selected,
    required this.fill,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      child: SizedBox(
        height: TonalButtonSize.section.button,
        child: PressSurface(
          fill: selected ? colorScheme.primary : fill,
          shape: AppShape.full,
          look: selected ? PressLook.none : PressLook.ink,
          selected: selected,
          childFills: true,
          onPressed: selected ? () {} : onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _choiceInset),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: AppTextStyle.subheadline
                    .of(context, emphasized: selected)
                    .copyWith(
                      color: selected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Suggestion extends StatelessWidget {
  final String value;
  final String count;
  final Color fill;
  final VoidCallback onPressed;

  const _Suggestion({
    required this.value,
    required this.count,
    required this.fill,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final style = AppTextStyle.footnote.of(context);
    return SizedBox(
      height: TonalButtonSize.compact.button,
      child: PressSurface(
        fill: fill,
        shape: AppShape.full,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style.copyWith(color: colorScheme.onSurface),
              ),
            ),
            Text(
              count,
              style: style.toTabular.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
