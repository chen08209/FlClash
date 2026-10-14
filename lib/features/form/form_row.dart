import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
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
          size: 20.ap,
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
                      size: 16.ap,
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
