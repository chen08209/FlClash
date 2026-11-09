import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'form_page.dart';
import 'form_row.dart';
import 'list_edit_view.dart';
import 'quick_edit.dart';

typedef _Entry = MapEntry<String, String>;

class MapEditView extends ConsumerStatefulWidget {
  final String title;
  final String? description;
  final Map<String, String> entries;
  final Widget Function(MapEntry<String, String> item) titleBuilder;
  final Widget Function(MapEntry<String, String> item)? subtitleBuilder;
  final int? keyMaxLength;
  final int? valueMaxLength;

  const MapEditView({
    super.key,
    required this.title,
    this.description,
    required this.entries,
    required this.titleBuilder,
    this.subtitleBuilder,
    this.keyMaxLength,
    this.valueMaxLength,
  });

  @override
  ConsumerState<MapEditView> createState() => _MapEditViewState();
}

class _MapEditViewState extends EditViewState<MapEditView, _Entry> {
  @override
  String get title => widget.title;

  @override
  String? get description => widget.description;

  @override
  List<_Entry> get initialEntries => widget.entries.entries.toList();

  @override
  String idOf(_Entry entry) => entry.key;

  @override
  Widget buildTitle(_Entry entry) => widget.titleBuilder(entry);

  @override
  Widget? buildSubtitle(_Entry entry) => widget.subtitleBuilder?.call(entry);

  @override
  bool sameEntries(List<_Entry> a, List<_Entry> b) =>
      stringAndStringMapEntryListEquality.equals(a, b);

  @override
  Object popResult(List<_Entry> entries) =>
      Map<String, String>.fromEntries(entries);

  @override
  Future<_Entry?> showEntryEditor(_Entry? entry) {
    return showMapEntryForm(
      context,
      entry: entry,
      existingKeys: entries.map(idOf).toSet(),
      keyMaxLength: widget.keyMaxLength,
      valueMaxLength: widget.valueMaxLength,
    );
  }

  @override
  Future<void> showQuickEdit(
    List<_Entry> entries,
    ValueChanged<List<_Entry>> onChanged,
  ) {
    return showMapQuickEdit(
      context,
      title: widget.title,
      entries: entries,
      keyMaxLength: widget.keyMaxLength,
      valueMaxLength: widget.valueMaxLength,
      onChanged: onChanged,
    );
  }
}

/// Adds when [entry] is null and edits it otherwise.
Future<MapEntry<String, String>?> showMapEntryForm(
  BuildContext context, {
  MapEntry<String, String>? entry,
  required Set<String> existingKeys,
  int? keyMaxLength,
  int? valueMaxLength,
  bool ignoreKeyCase = false,
}) {
  return showFormSheet<_Entry>(
    context: context,
    builder: (_) => _MapEntryForm(
      entry: entry,
      existingKeys: existingKeys,
      keyMaxLength: keyMaxLength,
      valueMaxLength: valueMaxLength,
      ignoreKeyCase: ignoreKeyCase,
    ),
  );
}

enum _MapEntryField { key, value }

class _MapEntryForm extends StatefulWidget {
  final _Entry? entry;
  final Set<String> existingKeys;
  final int? keyMaxLength;
  final int? valueMaxLength;
  final bool ignoreKeyCase;

  const _MapEntryForm({
    required this.entry,
    required this.existingKeys,
    required this.keyMaxLength,
    required this.valueMaxLength,
    required this.ignoreKeyCase,
  });

  @override
  State<_MapEntryForm> createState() => _MapEntryFormState();
}

class _MapEntryFormState extends State<_MapEntryForm> {
  final _valueFocusNode = FocusNode();
  late final TextEditingController _keyController;
  late final TextEditingController _valueController;
  bool _attempted = false;

  String get _keyLabel => context.appLocalizations.key;

  String get _valueLabel => context.appLocalizations.value;

  @override
  void initState() {
    super.initState();
    _keyController = TextEditingController(text: widget.entry?.key);
    _valueController = TextEditingController(text: widget.entry?.value);
  }

  @override
  void dispose() {
    _valueFocusNode.dispose();
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  bool _isTakenKey(String key) {
    String fold(String value) =>
        widget.ignoreKeyCase ? value.toLowerCase() : value;
    final ownKey = widget.entry?.key;
    return widget.existingKeys.any(
      (existing) => existing != ownKey && fold(existing) == fold(key),
    );
  }

  ({_MapEntryField field, String message})? _issue() {
    final appLocalizations = context.appLocalizations;
    final key = _keyController.text.trim();
    if (key.isEmpty) {
      return (
        field: _MapEntryField.key,
        message: appLocalizations.emptyTip(_keyLabel),
      );
    }
    if (_isTakenKey(key)) {
      return (
        field: _MapEntryField.key,
        message: appLocalizations.existsTip(_keyLabel),
      );
    }
    if (_valueController.text.trim().isEmpty) {
      return (
        field: _MapEntryField.value,
        message: appLocalizations.emptyTip(_valueLabel),
      );
    }
    return null;
  }

  void _handleChanged(String _) {
    if (_attempted) {
      setState(() {});
    }
  }

  void _handleSubmit() {
    if (_issue() != null) {
      setState(() {
        _attempted = true;
      });
      return;
    }
    Navigator.of(context).pop<_Entry>(
      MapEntry(_keyController.text.trim(), _valueController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final issue = _attempted ? _issue() : null;
    return FormPage(
      title: widget.entry == null
          ? appLocalizations.add
          : appLocalizations.edit,
      saveLabel: appLocalizations.confirm,
      onSave: _handleSubmit,
      error: issue?.message,
      children: [_buildFields(appLocalizations, issue?.field)],
    );
  }

  Widget _buildFields(
    AppLocalizations appLocalizations,
    _MapEntryField? invalid,
  ) {
    final keyMaxLength = widget.keyMaxLength;
    final valueMaxLength = widget.valueMaxLength;
    return generateSection(
      items: [
        FormRow(
          title: _keyLabel,
          invalid: invalid == _MapEntryField.key,
          trailing: FormRowTextField(
            controller: _keyController,
            autofocus: true,
            hintText: appLocalizations.required,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            inputFormatters: keyMaxLength == null
                ? null
                : TextInputLimits.limit(keyMaxLength),
            onChanged: _handleChanged,
            onFieldSubmitted: (_) => _valueFocusNode.requestFocus(),
          ),
        ),
        FormRow(
          title: _valueLabel,
          invalid: invalid == _MapEntryField.value,
          trailing: FormRowTextField(
            controller: _valueController,
            focusNode: _valueFocusNode,
            hintText: appLocalizations.required,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            inputFormatters: valueMaxLength == null
                ? null
                : TextInputLimits.limit(valueMaxLength),
            onChanged: _handleChanged,
            onFieldSubmitted: (_) => _handleSubmit(),
          ),
        ),
      ],
    );
  }
}
