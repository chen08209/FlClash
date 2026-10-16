import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

import 'batch_section.dart';
import 'form_page.dart';
import 'form_row.dart';

typedef NamedUrl = ({String label, String url, String ageSecretKey});

Future<NamedUrl?> showNamedUrlForm(
  BuildContext context, {
  required String title,
  String label = '',
  String url = '',
  FormFieldValidator<String>? labelValidator,
  FormFieldValidator<String>? urlValidator,
}) async {
  final res = await showFormSheet<List<NamedUrl>>(
    context: context,
    builder: (_) => NamedUrlForm(
      title: title,
      label: label,
      url: url,
      labelValidator: labelValidator,
      urlValidator: urlValidator,
    ),
  );
  return res?.single;
}

/// A batch skips the urls in [existingUrls].
Future<List<NamedUrl>?> showNamedUrlsForm(
  BuildContext context, {
  required String title,
  String? urlLabel,
  String? batchTip,
  FormFieldValidator<String>? labelValidator,
  FormFieldValidator<String>? urlValidator,
  Set<String> existingUrls = const {},
  bool withAgeSecretKey = false,
}) {
  return showFormSheet<List<NamedUrl>>(
    context: context,
    builder: (_) => NamedUrlForm(
      title: title,
      urlLabel: urlLabel,
      batchTip: batchTip,
      labelValidator: labelValidator,
      urlValidator: urlValidator,
      batch: true,
      existingUrls: existingUrls,
      withAgeSecretKey: withAgeSecretKey,
    ),
  );
}

enum _NamedUrlField { label, url }

/// The url below the name holds the focus, as the one field that must be filled.
/// Pops a list so a single url and a batch return through the same path.
class NamedUrlForm extends StatefulWidget {
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

  const NamedUrlForm({
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
  State<NamedUrlForm> createState() => _NamedUrlFormState();
}

class _NamedUrlFormState extends State<NamedUrlForm> {
  final _urlFocusNode = FocusNode();
  final _ageSecretKeyFocusNode = FocusNode();
  late final TextEditingController _labelController;
  late final TextEditingController _urlController;
  final _ageSecretKeyController = TextEditingController();
  final _batchController = TextEditingController();
  bool _isBatch = false;
  bool _attempted = false;
  ParsedInput<String>? _parsed;

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

  ({_NamedUrlField field, String message})? _issue() {
    final labelError = widget.labelValidator?.call(_labelController.text);
    if (labelError != null) {
      return (field: _NamedUrlField.label, message: labelError);
    }
    final urlError = _validateUrl(_urlController.text);
    if (urlError != null) {
      return (field: _NamedUrlField.url, message: urlError);
    }
    return null;
  }

  void _toggleBatch() {
    setState(() {
      _isBatch = !_isBatch;
      _attempted = false;
      if (_isBatch && _batchController.text.isEmpty) {
        _batchController.text = _urlController.text.trim();
      }
      if (_isBatch) {
        _parsed = _batchInput.parse(_batchController.text);
      }
    });
  }

  void _handleChanged(String _) {
    if (_attempted) {
      setState(() {});
    }
  }

  void _handleBatchChanged(String text) {
    setState(() {
      _parsed = _batchInput.parse(text);
    });
  }

  void _handleSubmit() {
    if (_isBatch) {
      final parsed = _parsed;
      if (parsed == null || !parsed.isValid || parsed.entries.isEmpty) {
        setState(() {
          _attempted = true;
        });
        return;
      }
      Navigator.of(context).pop<List<NamedUrl>>([
        for (final url in parsed.entries)
          (label: '', url: url, ageSecretKey: ''),
      ]);
      return;
    }
    if (_issue() != null) {
      setState(() {
        _attempted = true;
      });
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
    final issue = _attempted && !_isBatch ? _issue() : null;
    return FormPage(
      title: _isBatch ? appLocalizations.batchImport : widget.title,
      saveLabel: appLocalizations.submit,
      onSave: _handleSubmit,
      error: _isBatch
          ? _batchInput.errorOf(
              appLocalizations,
              _parsed,
              attempted: _attempted,
            )
          : issue?.message,
      actions: [
        if (widget.batch)
          IconButtonData(
            glyph: _isBatch ? AppGlyphs.textShort : AppGlyphs.listAdd,
            tooltip: _isBatch
                ? appLocalizations.singleImport
                : appLocalizations.batchImport,
            onPressed: _toggleBatch,
          ),
      ],
      children: [
        _isBatch
            ? BatchSection(
                batch: _batchInput,
                controller: _batchController,
                parsed: _parsed,
                onChanged: _handleBatchChanged,
              )
            : _buildFields(appLocalizations, issue?.field),
      ],
    );
  }

  Widget _buildFields(
    AppLocalizations appLocalizations,
    _NamedUrlField? invalid,
  ) {
    return generateSection(
      items: [
        FormRow(
          title: appLocalizations.name,
          invalid: invalid == _NamedUrlField.label,
          trailing: FormRowTextField(
            controller: _labelController,
            hintText: appLocalizations.optional,
            textInputAction: TextInputAction.next,
            inputFormatters: TextInputLimits.limit(TextInputLimits.name),
            onChanged: _handleChanged,
            onFieldSubmitted: (_) => _urlFocusNode.requestFocus(),
          ),
        ),
        FormRow(
          title: _urlLabel,
          invalid: invalid == _NamedUrlField.url,
          trailing: FormRowTextField(
            controller: _urlController,
            focusNode: _urlFocusNode,
            autofocus: true,
            hintText: appLocalizations.required,
            keyboardType: TextInputType.url,
            textInputAction: widget.withAgeSecretKey
                ? TextInputAction.next
                : TextInputAction.done,
            autocorrect: false,
            inputFormatters: TextInputLimits.limit(TextInputLimits.url),
            onChanged: _handleChanged,
            onFieldSubmitted: (_) {
              if (widget.withAgeSecretKey) {
                _ageSecretKeyFocusNode.requestFocus();
              } else {
                _handleSubmit();
              }
            },
          ),
        ),
        if (widget.withAgeSecretKey)
          FormRow(
            title: appLocalizations.ageSecretKey,
            trailing: FormRowSecretTextField(
              controller: _ageSecretKeyController,
              focusNode: _ageSecretKeyFocusNode,
              hintText: appLocalizations.optional,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleSubmit(),
            ),
          ),
      ],
    );
  }
}
