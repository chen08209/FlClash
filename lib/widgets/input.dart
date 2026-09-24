import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/dialog.dart';
import 'package:fl_clash/widgets/inherited.dart';
import 'package:fl_clash/widgets/null_status.dart';
import 'package:fl_clash/widgets/pop_scope.dart';
import 'package:fl_clash/widgets/scaffold.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'effect.dart';
import 'list.dart';
import 'theme.dart';
part 'edit_view.dart';

class OptionsDialog<T> extends StatelessWidget {
  final String title;
  final List<T> options;
  final T value;
  final String Function(T value) textBuilder;

  const OptionsDialog({
    super.key,
    required this.title,
    required this.options,
    required this.textBuilder,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: title,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(context.appLocalizations.cancel),
        ),
      ],
      child: RadioGroup(
        onChanged: (value) {
          Navigator.of(context).pop(value);
        },
        groupValue: value,
        child: Wrap(
          children: [
            for (final option in options)
              Builder(
                builder: (context) {
                  if (value == option) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Scrollable.ensureVisible(context);
                    });
                  }
                  return ListItem.radio(
                    value: option,
                    onTap: () {
                      Navigator.of(context).pop(option);
                    },
                    title: Text(textBuilder(option)),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class CommonCheckBox extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final bool isCircle;

  const CommonCheckBox({
    required this.value,
    required this.onChanged,
    this.isCircle = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      shape: isCircle ? AppShape.circle : null,
      value: value,
      onChanged: onChanged,
    );
  }
}

/// The url below the name holds the focus, as the one field that must be filled.
class NamedUrlDialog extends StatefulWidget {
  final String title;
  final String label;
  final String url;
  final FormFieldValidator<String>? labelValidator;
  final FormFieldValidator<String>? urlValidator;

  const NamedUrlDialog({
    super.key,
    required this.title,
    this.label = '',
    this.url = '',
    this.labelValidator,
    this.urlValidator,
  });

  @override
  State<NamedUrlDialog> createState() => _NamedUrlDialogState();
}

class _NamedUrlDialogState extends State<NamedUrlDialog> {
  final _formKey = GlobalKey<FormState>();
  final _urlFocusNode = FocusNode();
  late final TextEditingController _labelController;
  late final TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.label);
    _urlController = TextEditingController(text: widget.url);
  }

  @override
  void dispose() {
    _urlFocusNode.dispose();
    _labelController.dispose();
    _urlController.dispose();
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
      return appLocalizations.emptyTip(appLocalizations.url);
    }
    if (!url.isUrl) {
      return appLocalizations.urlTip(appLocalizations.url);
    }
    return null;
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() == false) {
      return;
    }
    Navigator.of(context).pop<({String label, String url})>((
      label: _labelController.text.trim(),
      url: _urlController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: widget.title,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(appLocalizations.cancel),
        ),
        TextButton(
          onPressed: _handleSubmit,
          child: Text(appLocalizations.submit),
        ),
      ],
      child: Form(
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
              maxLines: 5,
              textInputAction: TextInputAction.done,
              inputFormatters: TextInputLimits.limit(TextInputLimits.url),
              onFieldSubmitted: (_) {
                _handleSubmit();
              },
              decoration: InputDecoration(labelText: appLocalizations.url),
            ),
          ],
        ),
      ),
    );
  }
}

class InputDialog extends StatefulWidget {
  final String title;
  final String value;
  final String? suffixText;
  final String? labelText;
  final String? resetValue;
  final String? hintText;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final bool? obscureText;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;

  const InputDialog({
    super.key,
    required this.title,
    required this.value,
    this.suffixText,
    this.resetValue,
    this.hintText,
    this.validator,
    this.obscureText,
    this.labelText,
    this.maxLength,
    this.inputFormatters,
    this.keyboardType,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  @override
  State<InputDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _textController;

  String get value => widget.value;

  String get title => widget.title;

  String? get suffixText => widget.suffixText;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: value);
  }

  Future<void> _handleUpdate() async {
    if (_formKey.currentState?.validate() == false) return;
    final text = _textController.value.text;
    Navigator.of(context).pop<String>(text);
  }

  Future<void> _handleReset() async {
    if (widget.resetValue == null) {
      return;
    }
    Navigator.of(context).pop<String>(widget.resetValue);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: title,
      actions: [
        if (widget.resetValue != null &&
            _textController.value.text != widget.resetValue) ...[
          TextButton(
            onPressed: _handleReset,
            child: Text(appLocalizations.reset),
          ),
        ] else
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(appLocalizations.cancel),
          ),
        TextButton(
          onPressed: _handleUpdate,
          child: Text(appLocalizations.submit),
        ),
      ],
      child: Form(
        autovalidateMode: widget.autovalidateMode,
        key: _formKey,
        child: Wrap(
          runSpacing: 16,
          children: [
            TextFormField(
              maxLength: widget.maxLength,
              inputFormatters: widget.inputFormatters,
              obscureText: widget.obscureText ?? false,
              keyboardType: widget.keyboardType ?? TextInputType.url,
              maxLines: widget.obscureText == true ? 1 : 5,
              minLines: 1,
              controller: _textController,
              onFieldSubmitted: (_) {
                _handleUpdate();
              },
              decoration: InputDecoration(
                suffixText: suffixText,
                hintText: widget.hintText,
                labelText: widget.labelText,
              ),
              validator: widget.validator,
            ),
          ],
        ),
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
  static const _maxShownIssues = 3;

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

  String? _batchErrorText(AppLocalizations appLocalizations) {
    final parsed = _parsed;
    if (parsed == null || parsed.isValid) {
      return null;
    }
    return parsed.issues
        .take(_maxShownIssues)
        .map(
          (issue) => appLocalizations.lineIssueTip(
            issue.line,
            widget.batch!.issueMessage(issue),
          ),
        )
        .join('\n');
  }

  String _batchHelperText(AppLocalizations appLocalizations) {
    final parsed = _parsed;
    if (parsed == null || _batchController.text.trim().isEmpty) {
      return widget.batch!.formatTip;
    }
    return appLocalizations.batchPreviewTip(
      parsed.entries.length,
      parsed.skippedExisting,
    );
  }

  Widget _buildBatchField(AppLocalizations appLocalizations) {
    return TextField(
      controller: _batchController,
      autofocus: true,
      minLines: 4,
      maxLines: 10,
      keyboardType: TextInputType.multiline,
      onChanged: _handleBatchChanged,
      decoration: InputDecoration(
        labelText: widget.batch!.label,
        alignLabelWithHint: true,
        helperText: _batchHelperText(appLocalizations),
        helperMaxLines: 2,
        errorText: _batchErrorText(appLocalizations),
        errorMaxLines: _maxShownIssues + 1,
      ),
    );
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
              maxLines: 3,
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
            maxLines: 3,
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
          : CommonMinIconButtonTheme(
              child: IconButton(
                tooltip: _isBatch
                    ? appLocalizations.singleAdd
                    : appLocalizations.batchAdd,
                onPressed: _toggleBatch,
                icon: GlyphIcon(
                  _isBatch ? AppGlyphs.textShort : AppGlyphs.listAdd,
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: _canSubmit ? _submit : null,
          child: Text(appLocalizations.confirm),
        ),
      ],
      child: _isBatch
          ? _buildBatchField(appLocalizations)
          : _buildForm(appLocalizations),
    );
  }
}

class NoInputBorder extends InputBorder {
  const NoInputBorder() : super(borderSide: BorderSide.none);

  @override
  NoInputBorder copyWith({BorderSide? borderSide}) => const NoInputBorder();

  @override
  bool get isOutline => false;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  NoInputBorder scale(double t) => const NoInputBorder();

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRect(rect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRect(rect);
  }

  @override
  void paintInterior(
    Canvas canvas,
    Rect rect,
    Paint paint, {
    TextDirection? textDirection,
  }) {
    canvas.drawRect(rect, paint);
  }

  @override
  bool get preferPaintInterior => true;

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? gapStart,
    double gapExtent = 0.0,
    double gapPercentage = 0.0,
    TextDirection? textDirection,
  }) {}
}
