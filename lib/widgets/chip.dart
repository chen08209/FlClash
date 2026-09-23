import 'package:fl_clash/common/common.dart';
import 'package:material_ui/material_ui.dart';

class CommonChip extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final VoidCallback? onDeleted;

  const CommonChip({
    super.key,
    required this.label,
    this.onPressed,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final foregroundColor = colorScheme.onSurfaceVariant;
    final content = Padding(
      padding: EdgeInsets.only(
        left: 8,
        right: onDeleted != null ? 6 : 8,
        top: 3,
        bottom: 3,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelMedium?.copyWith(
                color: foregroundColor,
              ),
            ),
          ),
          if (onDeleted != null)
            GestureDetector(
              onTap: onDeleted,
              child: Icon(Icons.close, size: 14, color: foregroundColor),
            ),
        ],
      ),
    );
    return Material(
      color: colorScheme.surfaceContainerHighest,
      shape: AppShape.sm.copyWith(
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: onPressed == null
          ? content
          : InkWell(onTap: onPressed, child: content),
    );
  }
}

class MetaChip extends StatelessWidget {
  final String label;

  const MetaChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: colorScheme.surfaceContainerHighest,
        shape: AppShape.sm.copyWith(
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
