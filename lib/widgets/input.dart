import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'edit_view.dart';

typedef NamedUrl = ({String label, String url, String ageSecretKey});

/// The url below the name holds the focus, as the one field that must be filled.
/// Pops a list so a single url and a batch return through the same path.
class NamedUrlDialog extends StatefulWidget {
  final String title;
  final String label;
  final String url;
  final String? urlLabel;
  final String? batchTip;
  final FormFieldValidator<String>? labelValidator;
  final FormFieldValidator<String>? urlValidator;
  final bool batch;
  final Set<String> existingUrls;
  final bool withAgeSecretKey;

  const NamedUrlDialog({
    super.key,
    required this.title,
    this.label = '',
    this.url = '',
    this.urlLabel,
    this.batchTip,
    this.labelValidator,
    this.urlValidator,
    this.batch = false,
    this.existingUrls = const {},
    this.withAgeSecretKey = false,
  });

  @override
  State<NamedUrlDialog> createState() => _NamedUrlDialogState();
}

class _NamedUrlDialogState extends State<NamedUrlDialog> {
  final _formKey = GlobalKey<FormState>();
  final _urlFocusNode = FocusNode();
  final _ageSecretKeyFocusNode = FocusNode();
  late final TextEditingController _labelController;
  late final TextEditingController _urlController;
  final _ageSecretKeyController = TextEditingController();
  final _batchController = TextEditingController();
  bool _isBatch = false;
  ParsedInput<String>? _parsed;

  bool get _canSubmit {
    if (!_isBatch) {
      return true;
    }
    final parsed = _parsed;
    return parsed != null && parsed.isValid && parsed.entries.isNotEmpty;
  }

  String get _urlLabel => widget.urlLabel ?? context.appLocalizations.url;

  BatchInput<String> get _batchInput {
    final appLocalizations = context.appLocalizations;
    return BatchInput(
      label: _urlLabel,
      formatTip: widget.batchTip ?? appLocalizations.batchUrlInputTip,
      parse: (text) => parseUrlInput(
        text,
        isValid: (url) => _validateBatchUrl(url) == null,
        existing: widget.existingUrls,
      ),
      issueMessage: (issue) => _validateBatchUrl(issue.raw)!,
    );
  }

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.label);
    _urlController = TextEditingController(text: widget.url);
  }

  @override
  void dispose() {
    _urlFocusNode.dispose();
    _ageSecretKeyFocusNode.dispose();
    _labelController.dispose();
    _urlController.dispose();
    _ageSecretKeyController.dispose();
    _batchController.dispose();
    super.dispose();
  }

  String? _validateUrl(String? value) {
    final validator = widget.urlValidator;
    if (validator != null) {
      return validator(value);
    }
    final appLocalizations = context.appLocalizations;
    final url = value?.trim() ?? '';
    if (url.isEmpty) {
      return appLocalizations.emptyTip(_urlLabel);
    }
    if (!url.isUrl) {
      return appLocalizations.urlTip(_urlLabel);
    }
    return null;
  }

  String? _validateBatchUrl(String url) {
    if (url.length > TextInputLimits.url) {
      final appLocalizations = context.appLocalizations;
      return appLocalizations.maxLengthTip(_urlLabel, TextInputLimits.url);
    }
    return _validateUrl(url);
  }

  void _toggleBatch() {
    setState(() {
      _isBatch = !_isBatch;
      if (_isBatch && _batchController.text.isEmpty) {
        _batchController.text = _urlController.text.trim();
      }
      if (_isBatch) {
        _parsed = _batchInput.parse(_batchController.text);
      }
    });
  }

  void _handleBatchChanged(String text) {
    setState(() {
      _parsed = _batchInput.parse(text);
    });
  }

  void _handleSubmit() {
    if (!_canSubmit) {
      return;
    }
    if (_isBatch) {
      Navigator.of(context).pop<List<NamedUrl>>([
        for (final url in _parsed!.entries)
          (label: '', url: url, ageSecretKey: ''),
      ]);
      return;
    }
    if (_formKey.currentState?.validate() == false) {
      return;
    }
    Navigator.of(context).pop<List<NamedUrl>>([
      (
        label: _labelController.text.trim(),
        url: _urlController.text.trim(),
        ageSecretKey: _ageSecretKeyController.text.trim(),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: _isBatch ? appLocalizations.batchImport : widget.title,
      trailing: widget.batch
          ? _BatchToggle(
              isBatch: _isBatch,
              tooltip: _isBatch
                  ? appLocalizations.singleImport
                  : appLocalizations.batchImport,
              onPressed: _toggleBatch,
            )
          : null,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(appLocalizations.cancel),
        ),
        TextButton(
          onPressed: _canSubmit ? _handleSubmit : null,
          child: Text(appLocalizations.submit),
        ),
      ],
      child: _isBatch
          ? _BatchInputField(
              batch: _batchInput,
              controller: _batchController,
              parsed: _parsed,
              onChanged: _handleBatchChanged,
            )
          : _buildForm(appLocalizations),
    );
  }

  Widget _buildForm(AppLocalizations appLocalizations) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Wrap(
        runSpacing: 16,
        children: [
          TextFormField(
            controller: _labelController,
            validator: widget.labelValidator,
            textInputAction: TextInputAction.next,
            inputFormatters: TextInputLimits.limit(TextInputLimits.name),
            onFieldSubmitted: (_) {
              _urlFocusNode.requestFocus();
            },
            decoration: InputDecoration(
              labelText: appLocalizations.name,
              helperText: appLocalizations.optional,
            ),
          ),
          TextFormField(
            autofocus: true,
            focusNode: _urlFocusNode,
            controller: _urlController,
            validator: _validateUrl,
            keyboardType: TextInputType.url,
            minLines: 1,
            maxLines: null,
            textInputAction: widget.withAgeSecretKey
                ? TextInputAction.next
                : TextInputAction.done,
            inputFormatters: TextInputLimits.limit(TextInputLimits.url),
            onFieldSubmitted: (_) {
              if (widget.withAgeSecretKey) {
                _ageSecretKeyFocusNode.requestFocus();
              } else {
                _handleSubmit();
              }
            },
            decoration: InputDecoration(labelText: _urlLabel),
          ),
          if (widget.withAgeSecretKey)
            SecretTextFormField(
              focusNode: _ageSecretKeyFocusNode,
              controller: _ageSecretKeyController,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) {
                _handleSubmit();
              },
              decoration: InputDecoration(
                labelText: appLocalizations.ageSecretKey,
                helperText: appLocalizations.optional,
              ),
            ),
        ],
      ),
    );
  }
}

class BatchInput<T> {
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
}

/// Pops a list so a single entry and a batch return through the same path.
class EntryDialog<T> extends StatefulWidget {
  final String title;
  final Field? keyField;
  final Field valueField;
  final int? keyMaxLength;
  final int? valueMaxLength;
  final T Function(String? key, String value) toEntry;
  final BatchInput<T>? batch;

  const EntryDialog({
    super.key,
    required this.title,
    this.keyField,
    required this.valueField,
    this.keyMaxLength,
    this.valueMaxLength,
    required this.toEntry,
    this.batch,
  });

  @override
  State<EntryDialog<T>> createState() => _EntryDialogState<T>();
}

class _EntryDialogState<T> extends State<EntryDialog<T>> {
  TextEditingController? _keyController;
  late final TextEditingController _valueController;
  final _batchController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isBatch = false;
  ParsedInput<T>? _parsed;

  Field? get keyField => widget.keyField;

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
    if (keyField != null) {
      _keyController = TextEditingController(text: keyField!.value);
    }
    _valueController = TextEditingController(text: valueField.value);
  }

  void _toggleBatch() {
    setState(() {
      _isBatch = !_isBatch;
      if (_isBatch && _batchController.text.isEmpty) {
        _batchController.text = [_keyController?.text, _valueController.text]
            .nonNulls
            .map((text) => text.trim())
            .where((t) => t.isNotEmpty)
            .join(' ');
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
    Navigator.of(context).pop<List<T>>([
      widget.toEntry(_keyController?.text, _valueController.text),
    ]);
  }

  @override
  void dispose() {
    _keyController?.dispose();
    _valueController.dispose();
    _batchController.dispose();
    super.dispose();
  }

  Widget _buildForm(AppLocalizations appLocalizations) {
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: _formKey,
      child: Wrap(
        runSpacing: 16,
        children: [
          if (keyField != null)
            TextFormField(
              maxLines: null,
              minLines: 1,
              inputFormatters: widget.keyMaxLength == null
                  ? null
                  : TextInputLimits.limit(widget.keyMaxLength!),
              controller: _keyController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: keyField!.label),
              validator: (String? value) {
                String? res;
                if (keyField!.validator != null) {
                  res = keyField!.validator!(value);
                }
                if (res != null) {
                  return res;
                }
                if (value == null || value.isEmpty) {
                  return appLocalizations.emptyTip(appLocalizations.key);
                }
                return null;
              },
            ),
          TextFormField(
            maxLines: null,
            minLines: 1,
            inputFormatters: widget.valueMaxLength == null
                ? null
                : TextInputLimits.limit(widget.valueMaxLength!),
            keyboardType: TextInputType.text,
            controller: _valueController,
            decoration: InputDecoration(labelText: valueField.label),
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: _isBatch ? appLocalizations.batchAdd : widget.title,
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
  static const _maxShownIssues = 3;

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

  String? _errorText(AppLocalizations appLocalizations) {
    final parsed = this.parsed;
    if (parsed == null || parsed.isValid) {
      return null;
    }
    return parsed.issues
        .take(_maxShownIssues)
        .map(
          (issue) => appLocalizations.lineIssueTip(
            issue.line,
            batch.issueMessage(issue),
          ),
        )
        .join('\n');
  }

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
        labelText: batch.label,
        alignLabelWithHint: true,
        helperText: _helperText(appLocalizations),
        helperMaxLines: 2,
        errorText: _errorText(appLocalizations),
        errorMaxLines: _maxShownIssues + 1,
      ),
    );
  }
}
