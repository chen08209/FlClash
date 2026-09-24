import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_color_utilities/hct/hct.dart';

import 'color_scheme_box.dart';
import 'theme.dart';

const _trackHeight = 20.0;
const _thumbRadius = 14.0;
const _trackTone = 60.0;
const _previewInset = 8.0;

class Palette extends StatefulWidget {
  const Palette({super.key, required this.controller});

  final ValueNotifier<Color> controller;

  @override
  State<Palette> createState() => _PaletteState();
}

class _PaletteState extends State<Palette> {
  double _hue = 0;
  double _chroma = 0;
  double _tone = 0;

  @override
  void initState() {
    super.initState();
    _initFromColor(widget.controller.value);
  }

  void _initFromColor(Color color) {
    final hct = Hct.fromInt(color.toARGB32());
    _hue = hct.hue;
    _chroma = hct.chroma;
    _tone = hct.tone;
  }

  Color _toColor() => Color(Hct.from(_hue, _chroma, _tone).toInt());

  void _onHueChanged(double value) {
    setState(() => _hue = value);
    widget.controller.value = _toColor();
  }

  void _onChromaChanged(double value) {
    setState(() => _chroma = value);
    widget.controller.value = _toColor();
  }

  void _onToneSelected(double tone) {
    setState(() => _tone = tone);
    widget.controller.value = _toColor();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxChroma = Hct.from(_hue, 200, _trackTone).chroma;
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (_, _, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _GradientSlider(
                value: _hue,
                max: 360,
                thumbColor: Color(Hct.from(_hue, 100, _trackTone).toInt()),
                colors: [
                  for (var hue = 0; hue <= 360; hue += 10)
                    Color(Hct.from(hue.toDouble(), 100, _trackTone).toInt()),
                ],
                onChanged: _onHueChanged,
              ),
              const SizedBox(height: 8),
              _GradientSlider(
                value: _chroma.clamp(0, maxChroma),
                max: maxChroma,
                thumbColor: Color(Hct.from(_hue, _chroma, _trackTone).toInt()),
                colors: [
                  for (var i = 0; i <= 24; i++)
                    Color(
                      Hct.from(_hue, maxChroma * i / 24, _trackTone).toInt(),
                    ),
                ],
                onChanged: _onChromaChanged,
              ),
              const SizedBox(height: 16),
              _ToneStrip(
                hue: _hue,
                chroma: _chroma,
                selectedTone: _tone,
                onToneSelected: _onToneSelected,
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  context.appLocalizations.preview,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              PrimaryColorBox(
                primaryColor: widget.controller.value,
                child: const _ColorSchemePreview(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GradientSlider extends StatelessWidget {
  const _GradientSlider({
    required this.value,
    required this.max,
    required this.thumbColor,
    required this.colors,
    required this.onChanged,
  });

  final double value;
  final double max;
  final Color thumbColor;
  final List<Color> colors;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderDefaultsM3(context).copyWith(
        trackShape: _GradientTrackShape(
          colors: colors,
          outlineColor: Theme.of(context).colorScheme.outlineVariant,
        ),
        trackHeight: _trackHeight,
        thumbShape: _ColorThumbShape(color: thumbColor),
        overlayShape: SliderComponentShape.noOverlay,
      ),
      child: Slider(
        padding: EdgeInsets.zero,
        value: value,
        min: 0,
        max: max,
        onChanged: onChanged,
      ),
    );
  }
}

class _GradientTrackShape extends SliderTrackShape {
  const _GradientTrackShape({required this.colors, required this.outlineColor});

  final List<Color> colors;
  final Color outlineColor;

  // The thumb travels between the pill's end caps so it never overhangs them.
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? _trackHeight;
    return Rect.fromLTWH(
      offset.dx + _thumbRadius,
      offset.dy + (parentBox.size.height - trackHeight) / 2,
      parentBox.size.width - _thumbRadius * 2,
      trackHeight,
    );
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
  }) {
    final valueRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
    );
    final rect = Rect.fromLTRB(
      valueRect.left - _thumbRadius,
      valueRect.top,
      valueRect.right + _thumbRadius,
      valueRect.bottom,
    );
    final shape = RSuperellipse.fromRectAndRadius(
      rect,
      const Radius.circular(AppCorner.full),
    );
    final canvas = context.canvas;
    canvas.drawRSuperellipse(
      shape,
      Paint()..shader = LinearGradient(colors: colors).createShader(valueRect),
    );
    canvas.drawRSuperellipse(
      shape,
      Paint()
        ..color = outlineColor.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }
}

class _ColorThumbShape extends SliderComponentShape {
  const _ColorThumbShape({required this.color});

  final Color color;

  static const _ringWidth = 3.0;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.fromRadius(_thumbRadius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final radius = _thumbRadius + activationAnimation.value * 2;
    canvas.drawCircle(
      center.translate(0, 1),
      radius,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );
    canvas.drawCircle(center, radius, Paint()..color = Colors.white);
    canvas.drawCircle(center, radius - _ringWidth, Paint()..color = color);
  }
}

class _ToneStrip extends StatelessWidget {
  const _ToneStrip({
    required this.hue,
    required this.chroma,
    required this.selectedTone,
    required this.onToneSelected,
  });

  final double hue;
  final double chroma;
  final double selectedTone;
  final ValueChanged<double> onToneSelected;

  static const _tones = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      clipBehavior: Clip.antiAlias,
      decoration: const ShapeDecoration(shape: AppShape.md),
      foregroundDecoration: ShapeDecoration(
        shape: AppShape.md.copyWith(
          side: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
      ),
      child: Row(
        children: [
          for (final tone in _tones)
            Expanded(
              child: _ToneCell(
                tone: tone,
                color: Color(Hct.from(hue, chroma, tone.toDouble()).toInt()),
                isSelected: tone == selectedTone.round(),
                onSelected: () => onToneSelected(tone.toDouble()),
              ),
            ),
        ],
      ),
    );
  }
}

class _ToneCell extends StatefulWidget {
  const _ToneCell({
    required this.tone,
    required this.color,
    required this.isSelected,
    required this.onSelected,
  });

  final int tone;
  final Color color;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  State<_ToneCell> createState() => _ToneCellState();
}

class _ToneCellState extends State<_ToneCell> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = widget.tone <= 50 ? Colors.white : Colors.black;
    final showRing = widget.isSelected || _isFocused;
    return Material(
      color: widget.color,
      child: InkWell(
        onTap: widget.onSelected,
        onFocusChange: (value) => setState(() => _isFocused = value),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (showRing)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    shape: AppShape.full.copyWith(
                      side: BorderSide(
                        color: foregroundColor.withValues(
                          alpha: widget.isSelected ? 0.9 : 0.5,
                        ),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${widget.tone}',
                  style: TextStyle(
                    color: foregroundColor.withValues(
                      alpha: widget.isSelected ? 1 : 0.72,
                    ),
                    fontSize: 11,
                    fontWeight: widget.isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorSchemePreview extends StatelessWidget {
  const _ColorSchemePreview();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final roles = [
      (
        colorScheme.primary,
        colorScheme.onPrimary,
        colorScheme.primaryContainer,
        'Primary',
      ),
      (
        colorScheme.secondary,
        colorScheme.onSecondary,
        colorScheme.secondaryContainer,
        'Secondary',
      ),
      (
        colorScheme.tertiary,
        colorScheme.onTertiary,
        colorScheme.tertiaryContainer,
        'Tertiary',
      ),
    ];
    return Container(
      padding: const EdgeInsets.all(_previewInset),
      decoration: ShapeDecoration(
        color: colorScheme.surfaceContainer,
        shape: AppShape.lg.copyWith(
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: LayoutBuilder(
        builder: (_, constraints) => Row(
          spacing: min(_previewInset, constraints.maxWidth / 8),
          children: [
            for (final (color, onColor, container, label) in roles)
              Expanded(
                child: ClipRSuperellipse(
                  borderRadius: AppRadius.all(AppCorner.lg - _previewInset),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 44,
                        color: color,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          label,
                          style: TextStyle(
                            color: onColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(height: 24, color: container),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
