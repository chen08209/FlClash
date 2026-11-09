import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

class SettingTextCard extends StatelessWidget {
  final String text;
  final bool? isSelected;
  final VoidCallback onPressed;

  const SettingTextCard(
    this.text, {
    super.key,
    this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      onPressed: onPressed,
      isSelected: isSelected,
      fillsSelection: true,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          text,
          style: AppTextStyle.subheadline
              .of(context)
              .copyWith(
                color: isSelected == true
                    ? context.colorScheme.onPrimary
                    : null,
              ),
        ),
      ),
    );
  }
}
