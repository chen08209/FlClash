import 'package:fl_clash/ui/context.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/shape.dart';
import 'package:material_ui/material_ui.dart';

class SelectionCheck extends StatelessWidget {
  const SelectionCheck({super.key});

  static const size = 24.0;

  @override
  Widget build(BuildContext context) {
    return GlyphIcon(
      AppGlyphs.check,
      size: size,
      fill: 1,
      color: context.colorScheme.primary,
    );
  }
}

class SelectionBadge extends StatelessWidget {
  const SelectionBadge({super.key, this.size = 22})
    : glyph = AppGlyphs.check,
      tonal = false;

  /// The proxy a URLTest or Fallback group prefers, mihomo's `fixed`.
  const SelectionBadge.preferred({
    super.key,
    this.size = 22,
    bool inUse = false,
  }) : glyph = AppGlyphs.pin,
       tonal = !inUse;

  final double size;
  final Glyph glyph;
  final bool tonal;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          shape: AppShape.circle,
          color: tonal
              ? colorScheme.primary.withValues(alpha: 0.14)
              : colorScheme.primary,
        ),
        child: Center(
          child: GlyphIcon(
            glyph,
            size: size - 6,
            fill: 1,
            color: tonal ? colorScheme.primary : colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
