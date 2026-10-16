import 'package:fl_clash/ui/context.dart';
import 'package:fl_clash/ui/dialog.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/l10n.dart';
import 'package:fl_clash/ui/shape.dart';
import 'package:fl_clash/ui/surface.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

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

/// Single-line while hidden: Flutter cannot obscure more than one line.
class SecretTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final InputDecoration decoration;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldValidator<String>? validator;
  final bool autofocus;

  const SecretTextFormField({
    super.key,
    required this.controller,
    this.focusNode,
    this.decoration = const InputDecoration(),
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.textInputAction,
    this.onFieldSubmitted,
    this.validator,
    this.autofocus = false,
  });

  @override
  State<SecretTextFormField> createState() => _SecretTextFormFieldState();
}

class _SecretTextFormFieldState extends State<SecretTextFormField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final localizations = UiLocalizations.of(context);
    return TextFormField(
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      controller: widget.controller,
      obscureText: _obscure,
      keyboardType: TextInputType.visiblePassword,
      maxLines: _obscure ? 1 : widget.maxLines,
      minLines: 1,
      inputFormatters: _limited(widget.inputFormatters, widget.maxLength),
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      validator: widget.validator,
      decoration: widget.decoration.copyWith(
        suffixIcon: IconButton(
          tooltip: _obscure
              ? localizations.showPassword
              : localizations.hidePassword,
          icon: GlyphIcon(_obscure ? AppGlyphs.eye : AppGlyphs.eyeOff),
          onPressed: () {
            setState(() {
              _obscure = !_obscure;
            });
          },
        ),
      ),
    );
  }
}

// A limit holds as iOS and macOS hold one, without a counter under the field.
List<TextInputFormatter>? _limited(
  List<TextInputFormatter>? formatters,
  int? maxLength,
) {
  if (maxLength == null) {
    return formatters;
  }
  return [...?formatters, LengthLimitingTextInputFormatter(maxLength)];
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
  final bool selectAll;

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
    this.selectAll = false,
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
    if (widget.selectAll) {
      _textController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: value.length,
      );
    }
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
    final localizations = UiLocalizations.of(context);
    final decoration = InputDecoration(
      suffixText: suffixText,
      hintText: widget.hintText ?? widget.labelText,
    );
    return CommonDialog(
      title: title,
      hasFields: true,
      actions: [
        ValueListenableBuilder(
          valueListenable: _textController,
          builder: (context, value, _) {
            if (widget.resetValue != null && value.text != widget.resetValue) {
              return TextButton(
                onPressed: _handleReset,
                child: Text(localizations.reset),
              );
            }
            return TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(localizations.cancel),
            );
          },
        ),
        TextButton(onPressed: _handleUpdate, child: Text(localizations.submit)),
      ],
      child: Form(
        autovalidateMode: widget.autovalidateMode,
        key: _formKey,
        child: Wrap(
          runSpacing: 16,
          children: [
            if (widget.obscureText == true)
              SecretTextFormField(
                autofocus: widget.selectAll,
                maxLength: widget.maxLength,
                inputFormatters: widget.inputFormatters,
                maxLines: null,
                controller: _textController,
                onFieldSubmitted: (_) {
                  _handleUpdate();
                },
                decoration: decoration,
                validator: widget.validator,
              )
            else
              TextFormField(
                autofocus: widget.selectAll,
                inputFormatters: _limited(
                  widget.inputFormatters,
                  widget.maxLength,
                ),
                keyboardType: widget.keyboardType ?? TextInputType.url,
                maxLines: null,
                minLines: 1,
                controller: _textController,
                onFieldSubmitted: (_) {
                  _handleUpdate();
                },
                decoration: decoration,
                validator: widget.validator,
              ),
          ],
        ),
      ),
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

/// For a field with no grouped row to sit in; `.agents/surfaces.md` has why.
class FilledInputTheme extends StatelessWidget {
  const FilledInputTheme({
    super.key,
    this.borderRadius = AppRadius.full,
    this.contentPadding,
    this.fillColor,
    required this.child,
  });

  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? contentPadding;

  /// In place of the raised surface's.
  final Color? fillColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final shape = AppShape.input.copyWith(borderRadius: borderRadius);
    final none = shape.copyWith(borderSide: BorderSide.none);
    return InputDecorationTheme(
      data: InputDecorationTheme.of(context).copyWith(
        filled: true,
        fillColor: fillColor ?? context.raisedSurfaceLevel.colorOf(colorScheme),
        hoverColor: Colors.transparent,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        contentPadding: contentPadding,
        border: none,
        enabledBorder: none,
        disabledBorder: none,
        errorBorder: none,
        focusedBorder: shape.copyWith(
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        focusedErrorBorder: shape.copyWith(
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
      child: child,
    );
  }
}
