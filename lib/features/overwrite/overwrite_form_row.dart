import 'package:fl_clash/common/common.dart';
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
        icon: Icon(Icons.info, size: 20.ap, color: context.colorScheme.error),
      ),
    );
  }
}

class OverwriteFormRow extends StatelessWidget {
  static const _spacing = 16.0;
  static const _titleMaxLines = 2;
  static const _titleMaxWidthFactor = 0.5;

  final String title;
  final TextStyle? titleStyle;
  final Widget? trailing;
  final bool invalid;
  final VoidCallback? onPressed;

  const OverwriteFormRow({
    super.key,
    required this.title,
    this.titleStyle,
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
                      height: globalState.measure.bodyLargeHeight + 24,
                      child: trailing,
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
