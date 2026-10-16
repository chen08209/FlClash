import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'edit_view.dart';

class BatchInput<T> {
  static const maxShownIssues = 3;

  final String label;
  final String formatTip;
  final ParsedInput<T> Function(String text) parse;
  final String Function(InputIssue issue) issueMessage;

  const BatchInput({
    required this.label,
    required this.formatTip,
    required this.parse,
    required this.issueMessage,
  });

  String? issuesOf(AppLocalizations appLocalizations, ParsedInput<T>? parsed) {
    if (parsed == null || parsed.isValid) {
      return null;
    }
    return parsed.issues
        .take(maxShownIssues)
        .map(
          (issue) =>
              appLocalizations.lineIssueTip(issue.line, issueMessage(issue)),
        )
        .join('\n');
  }

  /// [issuesOf], or once a save was [attempted], that nothing was entered.
  String? errorOf(
    AppLocalizations appLocalizations,
    ParsedInput<T>? parsed, {
    required bool attempted,
  }) {
    final issues = issuesOf(appLocalizations, parsed);
    if (issues != null) {
      return issues;
    }
    if (attempted && parsed?.entries.isNotEmpty != true) {
      return appLocalizations.emptyTip(label);
    }
    return null;
  }
}

/// Pops a list so a single entry and a batch return through the same path.
class EntryDialog<T> extends StatefulWidget {
  final String title;
  final Field valueField;
  final int? valueMaxLength;
  final T Function(String value) toEntry;
  final BatchInput<T>? batch;

  const EntryDialog({
    super.key,
    required this.title,
    required this.valueField,
    this.valueMaxLength,
    required this.toEntry,
    this.batch,
  });

  @override
  State<EntryDialog<T>> createState() => _EntryDialogState<T>();
}

class _EntryDialogState<T> extends State<EntryDialog<T>> {
  late final TextEditingController _valueController;
  final _batchController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isBatch = false;
  ParsedInput<T>? _parsed;

  Field get valueField => widget.valueField;

  bool get _canSubmit {
    if (!_isBatch) {
      return true;
    }
    final parsed = _parsed;
    return parsed != null && parsed.isValid && parsed.entries.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _valueController = TextEditingController(text: valueField.value);
  }

  void _toggleBatch() {
    setState(() {
      _isBatch = !_isBatch;
      if (_isBatch && _batchController.text.isEmpty) {
        _batchController.text = _valueController.text.trim();
      }
      if (_isBatch) {
        _parsed = widget.batch!.parse(_batchController.text);
      }
    });
  }

  void _handleBatchChanged(String text) {
    setState(() {
      _parsed = widget.batch!.parse(text);
    });
  }

  void _submit() {
    if (!_canSubmit) return;
    if (_isBatch) {
      Navigator.of(context).pop<List<T>>(_parsed!.entries);
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop<List<T>>([widget.toEntry(_valueController.text)]);
  }

  @override
  void dispose() {
    _valueController.dispose();
    _batchController.dispose();
    super.dispose();
  }

  Widget _buildForm(AppLocalizations appLocalizations) {
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: _formKey,
      child: TextFormField(
        maxLines: null,
        minLines: 1,
        inputFormatters: widget.valueMaxLength == null
            ? null
            : TextInputLimits.limit(widget.valueMaxLength!),
        keyboardType: TextInputType.text,
        controller: _valueController,
        decoration: InputDecoration(hintText: valueField.label),
        onFieldSubmitted: (_) {
          _submit();
        },
        validator: (String? value) {
          String? res;
          if (valueField.validator != null) {
            res = valueField.validator!(value);
          }
          if (res != null) {
            return res;
          }
          if (value == null || value.isEmpty) {
            return appLocalizations.emptyTip(appLocalizations.value);
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: _isBatch ? appLocalizations.batchAdd : widget.title,
      hasFields: true,
      trailing: widget.batch == null
          ? null
          : _BatchToggle(
              isBatch: _isBatch,
              tooltip: _isBatch
                  ? appLocalizations.singleAdd
                  : appLocalizations.batchAdd,
              onPressed: _toggleBatch,
            ),
      actions: [
        TextButton(
          onPressed: _canSubmit ? _submit : null,
          child: Text(appLocalizations.confirm),
        ),
      ],
      child: _isBatch
          ? _BatchInputField(
              batch: widget.batch!,
              controller: _batchController,
              parsed: _parsed,
              onChanged: _handleBatchChanged,
            )
          : _buildForm(appLocalizations),
    );
  }
}

class _BatchToggle extends StatelessWidget {
  final bool isBatch;
  final String tooltip;
  final VoidCallback onPressed;

  const _BatchToggle({
    required this.isBatch,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CommonMinIconButtonTheme(
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: GlyphIcon(isBatch ? AppGlyphs.textShort : AppGlyphs.listAdd),
      ),
    );
  }
}

class _BatchInputField<T> extends StatelessWidget {
  final BatchInput<T> batch;
  final TextEditingController controller;
  final ParsedInput<T>? parsed;
  final ValueChanged<String> onChanged;

  const _BatchInputField({
    required this.batch,
    required this.controller,
    required this.parsed,
    required this.onChanged,
  });

  String _helperText(AppLocalizations appLocalizations) {
    final parsed = this.parsed;
    if (parsed == null || controller.text.trim().isEmpty) {
      return batch.formatTip;
    }
    return appLocalizations.batchPreviewTip(
      parsed.entries.length,
      parsed.skippedExisting,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return TextField(
      controller: controller,
      autofocus: true,
      minLines: 4,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: batch.label,
        helperText: _helperText(appLocalizations),
        helperMaxLines: 2,
        errorText: batch.issuesOf(appLocalizations, parsed),
        errorMaxLines: BatchInput.maxShownIssues + 1,
      ),
    );
  }
}
