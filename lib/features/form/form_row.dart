import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

class InfoMessageButton extends StatelessWidget {
  final String message;

  const InfoMessageButton({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return CommonMinIconButtonTheme(
      child: IconButton(
        tooltip: context.appLocalizations.tip,
        onPressed: () {
          dialogs.showMessage(message: TextSpan(text: message));
        },
        icon: GlyphIcon(
          AppGlyphs.info,
          fill: 1,
          size: 20.ap(context),
          color: context.colorScheme.error,
        ),
      ),
    );
  }
}

class EntryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool _add;

  const EntryButton.add({super.key, required this.onPressed}) : _add = true;

  const EntryButton.remove({super.key, required this.onPressed}) : _add = false;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonMinIconButtonTheme(
      child: ElasticButton(
        child: IconButton(
          tooltip: _add ? appLocalizations.add : appLocalizations.remove,
          onPressed: onPressed,
          icon: GlyphIcon(
            _add ? AppGlyphs.addCircle : AppGlyphs.removeCircle,
            size: 24,
          ),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class FormRow extends StatelessWidget {
  static const _spacing = 16.0;
  static const _titleMaxLines = 2;
  static const _titleMaxWidthFactor = 0.5;

  final String title;
  final TextStyle? titleStyle;
  final Widget? leading;
  final Widget? trailing;
  final bool invalid;
  final VoidCallback? onPressed;

  const FormRow({
    super.key,
    required this.title,
    this.titleStyle,
    this.leading,
    this.trailing,
    this.invalid = false,
    this.onPressed,
  });

  Widget _buildTitle(double maxWidth) {
    final text = TooltipLabel(
      title,
      style: titleStyle,
      maxLines: _titleMaxLines,
    );
    if (trailing == null) {
      return Flexible(child: text);
    }
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: (maxWidth - _spacing) * _titleMaxWidthFactor,
      ),
      child: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecorationListItem(
      invalid: invalid,
      onPressed: onPressed,
      minVerticalPadding: trailing == null ? null : 0,
      leading: leading,
      title: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: _spacing,
            children: [
              _buildTitle(constraints.maxWidth),
              if (trailing != null)
                Flexible(
                  child: IconTheme(
                    data: IconThemeData(
                      size: 16.ap(context),
                      color: context.colorScheme.onSurface.opacity60,
                    ),
                    child: Container(
                      alignment: Alignment.centerRight,
                      height: globalState.measure.listRowHeight,
                      child: DefaultTextStyle.merge(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        child: trailing!,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// A bare text field set against the end of a [FormRow], as iOS and macOS set
/// one in a grouped form; the row's focus ring is the only outline it gets.
class FormRowTextField extends StatelessWidget {
  static const _cursorWidth = 2.0;

  // RenderEditable's caret gap plus cursor, which it keeps clear past the text.
  static const _caretMargin = 1 + _cursorWidth;

  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final String? hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool autofocus;
  final bool autocorrect;
  final bool enableSuggestions;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  const FormRowTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.obscureText = false,
    this.autofocus = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.onChanged,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final towardEnd = switch (Directionality.of(context)) {
      TextDirection.ltr => 1.0,
      TextDirection.rtl => -1.0,
    };
    return InputDecorationTheme(
      data: InputDecorationTheme.of(
        context,
      ).copyWith(floatingLabelBehavior: FloatingLabelBehavior.never),
      child: Transform.translate(
        offset: Offset(_caretMargin * towardEnd, 0),
        child: _buildField(context),
      ),
    );
  }

  Widget _buildField(BuildContext context) {
    final hintText = this.hintText;
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      autofocus: autofocus,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      textAlign: TextAlign.end,
      cursorWidth: _cursorWidth,
      decoration: InputDecoration.collapsed(
        border: const NoInputBorder(),
        hintText: null,
        hint: hintText == null
            ? null
            : Padding(
                padding: const EdgeInsetsDirectional.only(end: _caretMargin),
                child: Text(
                  hintText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: AppTextStyle.body
                      .of(context)
                      .copyWith(color: context.colorScheme.onSurfaceVariant),
                ),
              ),
      ),
    );
  }
}

/// A [FormRowTextField] for a secret, with the button that shows it.
class FormRowSecretTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? hintText;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  const FormRowSecretTextField({
    super.key,
    required this.controller,
    this.focusNode,
    this.hintText,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onFieldSubmitted,
  });

  @override
  State<FormRowSecretTextField> createState() => _FormRowSecretTextFieldState();
}

class _FormRowSecretTextFieldState extends State<FormRowSecretTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: FormRowTextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            hintText: widget.hintText,
            obscureText: _obscure,
            textInputAction: widget.textInputAction,
            autocorrect: false,
            enableSuggestions: false,
            inputFormatters: widget.inputFormatters,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onFieldSubmitted,
          ),
        ),
        CommonMinIconButtonTheme(
          child: IconButton(
            tooltip: _obscure
                ? appLocalizations.showPassword
                : appLocalizations.hidePassword,
            icon: GlyphIcon(_obscure ? AppGlyphs.eye : AppGlyphs.eyeOff),
            onPressed: () {
              setState(() {
                _obscure = !_obscure;
              });
            },
          ),
        ),
      ],
    );
  }
}
