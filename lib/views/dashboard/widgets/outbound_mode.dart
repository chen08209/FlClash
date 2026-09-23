import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/dashboard/widget_metrics.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_color_utilities/palettes/tonal_palette.dart';
import 'package:material_color_utilities/hct/hct.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _maxTonalChroma = 36.0;
const _rowGap = 8.0;
const _rowSpacing = 4.0;
const _pillInset = 8.0;
const _rowGlyphSize = 18.0;
// Matches the gap InfoHeader leaves between its glyph and its label, so the
// rows share the header's icon column and text column.
const _headerGlyphGap = 8.0;
const _selectDuration = Duration(milliseconds: 320);
const _selectCurve = Curves.easeInOutCubic;

class OutboundMode extends ConsumerWidget {
  const OutboundMode({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(
      patchClashConfigProvider.select((state) => state.mode),
    );
    final inset = DashboardWidgetMetrics.insetOf(context);
    final radius = DashboardWidgetMetrics.radiusOf(context);
    final pillInset = min(_pillInset.mAp, inset);
    return SizedBox(
      height: DashboardWidgetMetrics.heightOf(context, 2),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: CommonCard(
          radius: radius,
          infoPadding: DashboardWidgetMetrics.paddingOf(
            context,
          ).copyWith(bottom: 0),
          onPressed: () {},
          skipTraversal: true,
          info: Info(
            label: context.appLocalizations.outboundMode,
            glyph: AppGlyphs.split,
          ),
          child: Padding(
            padding: EdgeInsets.only(top: _rowGap.mAp, bottom: pillInset),
            child: _ModeRows(
              mode: mode,
              inset: inset,
              pillInset: pillInset,
              shape: AppShape.all(max(radius - pillInset, 0)),
              onSelect: (item) {
                ref.read(setupActionProvider.notifier).changeMode(item);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeRows extends StatelessWidget {
  const _ModeRows({
    required this.mode,
    required this.inset,
    required this.pillInset,
    required this.shape,
    required this.onSelect,
  });

  final Mode mode;
  final double inset;
  final double pillInset;

  /// Concentric with the card: same superellipse, radius shrunk by the inset.
  final ShapeBorder shape;
  final void Function(Mode mode) onSelect;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final count = Mode.values.length;
        final spacing = _rowSpacing.mAp;
        final rowHeight = max(
          (constraints.maxHeight - spacing * (count - 1)) / count,
          0.0,
        );
        final contentInset = inset - pillInset;
        final leading = IconTheme.of(context).size ?? Glyph.size;
        final colors = [
          for (final item in Mode.values) _ModeColors.of(context, item),
        ];
        return TweenAnimationBuilder<double>(
          tween: Tween(end: Mode.values.indexOf(mode).toDouble()),
          duration: _selectDuration,
          curve: _selectCurve,
          builder: (context, position, _) {
            final from = position.floor().clamp(0, count - 1);
            final to = position.ceil().clamp(0, count - 1);
            final highlight = _ModeColors.lerp(
              colors[from],
              colors[to],
              position - from,
            );
            return Stack(
              children: [
                Positioned(
                  key: const ValueKey('outbound-mode-highlight'),
                  left: pillInset,
                  right: pillInset,
                  top: position * (rowHeight + spacing),
                  height: rowHeight,
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      color: highlight.container,
                      shape: shape,
                    ),
                  ),
                ),
                for (final (index, item) in Mode.values.indexed)
                  Positioned(
                    left: pillInset,
                    right: pillInset,
                    top: index * (rowHeight + spacing),
                    height: rowHeight,
                    child: _ModeRow(
                      title: item.label,
                      glyph: _glyphOf(item),
                      selected: item == mode,
                      foreground: Color.lerp(
                        context.colorScheme.onSurfaceVariant,
                        colors[index].onContainer,
                        (1 - (index - position).abs()).clamp(0.0, 1.0),
                      )!,
                      leading: contentInset,
                      glyphWidth: leading,
                      trailing: contentInset,
                      shape: shape,
                      onTap: () {
                        onSelect(item);
                      },
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

Glyph _glyphOf(Mode mode) {
  return switch (mode) {
    Mode.rule => AppGlyphs.rules,
    Mode.global => AppGlyphs.language,
    Mode.direct => AppGlyphs.target,
  };
}

class _ModeColors {
  const _ModeColors(this.container, this.onContainer);

  factory _ModeColors.of(BuildContext context, Mode mode) {
    final colorScheme = context.colorScheme;
    return switch (mode) {
      Mode.rule => _ModeColors(
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
      ),
      Mode.global => _ModeColors.tonal(colorScheme.warning, colorScheme),
      Mode.direct => _ModeColors.tonal(colorScheme.success, colorScheme),
    };
  }

  /// Material 3 container tones, with chroma capped to match the scheme's own.
  factory _ModeColors.tonal(Color seed, ColorScheme colorScheme) {
    final hct = Hct.fromInt(seed.toARGB32());
    final palette = TonalPalette.of(hct.hue, min(hct.chroma, _maxTonalChroma));
    final dark = colorScheme.brightness == Brightness.dark;
    return _ModeColors(
      Color(palette.get(dark ? 30 : 90)),
      Color(palette.get(dark ? 90 : 10)),
    );
  }

  factory _ModeColors.lerp(_ModeColors a, _ModeColors b, double t) {
    return _ModeColors(
      Color.lerp(a.container, b.container, t)!,
      Color.lerp(a.onContainer, b.onContainer, t)!,
    );
  }

  final Color container;
  final Color onContainer;
}

class _ModeRow extends StatelessWidget {
  const _ModeRow({
    required this.title,
    required this.glyph,
    required this.selected,
    required this.foreground,
    required this.leading,
    required this.glyphWidth,
    required this.trailing,
    required this.shape,
    required this.onTap,
  });

  final String title;
  final Glyph glyph;
  final bool selected;
  final Color foreground;
  final double leading;
  final double glyphWidth;
  final double trailing;
  final ShapeBorder shape;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: InkWell(
        customBorder: shape,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.only(left: leading, right: trailing),
          child: Row(
            children: [
              SizedBox(
                width: glyphWidth,
                child: GlyphIcon(glyph, size: _rowGlyphSize, color: foreground),
              ),
              const SizedBox(width: _headerGlyphGap),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(color: foreground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
