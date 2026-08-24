import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';

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
  final Widget title;
  final Widget? trailing;
  final bool invalid;
  final VoidCallback? onPressed;

  const OverwriteFormRow({
    super.key,
    required this.title,
    this.trailing,
    this.invalid = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return DecorationListItem(
      invalid: invalid,
      onPressed: onPressed,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 16,
        children: [
          title,
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
      ),
    );
  }
}
