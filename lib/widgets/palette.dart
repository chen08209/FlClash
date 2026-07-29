import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/widgets/card.dart';
import 'package:flutter/material.dart';
import 'package:material_color_utilities/hct/hct.dart';

import 'color_scheme_box.dart';
import 'theme.dart';

@immutable
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
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (_, _, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _HueSlider(hue: _hue, onChanged: _onHueChanged),
            const SizedBox(height: 16),
            _ChromaSlider(
              hue: _hue,
              chroma: _chroma,
              onChanged: _onChromaChanged,
            ),
            const SizedBox(height: 28),
            _ToneGrid(
              hue: _hue,
              chroma: _chroma,
              selectedTone: _tone,
              onToneSelected: _onToneSelected,
            ),
            const SizedBox(height: 16),
            InfoHeader(info: Info(label: context.appLocalizations.preview)),
            PrimaryColorBox(
              primaryColor: widget.controller.value,
              child: const _ColorSchemePreview(),
            ),
          ],
        );
      },
    );
  }
}

class _HueSlider extends StatelessWidget {
  const _HueSlider({required this.hue, required this.onChanged});

  final double hue;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderDefaultsM3(context).copyWith(
        trackShape: _HueTrackShape(),
        trackHeight: 24,
        thumbSize: const WidgetStatePropertyAll(Size(6.0, 48.0)),
        thumbColor: Color(Hct.from(hue, 100, 80).toInt()),
      ),
      child: Slider(
        padding: EdgeInsets.zero,
        value: hue,
        min: 0,
        max: 360,
        onChanged: onChanged,
      ),
    );
  }
}

class _ChromaSlider extends StatelessWidget {
  const _ChromaSlider({
    required this.hue,
    required this.chroma,
    required this.onChanged,
  });

  final double hue;
  final double chroma;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderDefaultsM3(context).copyWith(
        trackShape: _ChromaTrackShape(hue: hue),
        trackHeight: 24,
        thumbSize: const WidgetStatePropertyAll(Size(6.0, 48.0)),
        thumbColor: Color(Hct.from(hue, chroma, 80).toInt()),
      ),
      child: Slider(
        padding: EdgeInsets.zero,
        value: chroma.clamp(0, 10),
        min: 0,
        max: 10,
        onChanged: onChanged,
      ),
    );
  }
}

class _HueTrackShape extends SliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 24;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    return Rect.fromLTWH(
      offset.dx,
      trackTop,
      parentBox.size.width,
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
    final rect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final colors = <Color>[];
    for (int i = 0; i <= 360; i += 10) {
      colors.add(Color(Hct.from(i.toDouble(), 100, 60).toInt()));
    }
    final shader = LinearGradient(colors: colors).createShader(rect);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));
    context.canvas.drawRRect(rrect, Paint()..shader = shader);
    _paintTrackHighlight(context.canvas, rect);
  }
}

class _ChromaTrackShape extends SliderTrackShape {
  const _ChromaTrackShape({required this.hue});

  final double hue;

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 24;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    return Rect.fromLTWH(
      offset.dx,
      trackTop,
      parentBox.size.width,
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
    final rect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final colors = <Color>[];
    for (int i = 0; i <= 49; i++) {
      colors.add(Color(Hct.from(hue, (i / 49) * 150, 60).toInt()));
    }
    final shader = LinearGradient(colors: colors).createShader(rect);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));
    context.canvas.drawRRect(rrect, Paint()..shader = shader);
    _paintTrackHighlight(context.canvas, rect);
  }
}

void _paintTrackHighlight(Canvas canvas, Rect rect) {
  final rrect = RRect.fromRectAndRadius(
    rect.deflate(1),
    const Radius.circular(12),
  );
  canvas.drawRRect(
    rrect,
    Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1,
  );
  canvas.drawLine(
    Offset(rect.left + 12, rect.bottom - 2),
    Offset(rect.right - 12, rect.bottom - 2),
    Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..strokeWidth = 1,
  );
}

class _ToneGrid extends StatelessWidget {
  const _ToneGrid({
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
  static const _spacing = 8.0;

  @override
  Widget build(BuildContext context) {
    final selectedBorderColor = Theme.of(context).colorScheme.primary;
    return LayoutBuilder(
      builder: (_, constraints) {
        final columns = min(
          max((constraints.maxWidth / 40).floor(), 1),
          _tones.length,
        );
        final itemWidth =
            (constraints.maxWidth - (columns - 1) * _spacing) / columns;
        return Wrap(
          spacing: _spacing,
          runSpacing: _spacing,
          children: _tones.map((tone) {
            final color = Color(Hct.from(hue, chroma, tone.toDouble()).toInt());
            final isSelected = tone == selectedTone.round();
            final textColor = tone <= 50 ? Colors.white : Colors.black;
            return GestureDetector(
              onTap: () => onToneSelected(tone.toDouble()),
              child: SizedBox(
                width: itemWidth,
                height: itemWidth,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$tone',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    if (isSelected)
                      Positioned.fill(
                        top: -4,
                        right: -4,
                        bottom: -4,
                        left: -4,
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selectedBorderColor,
                                width: 4,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _ColorSchemePreview extends StatelessWidget {
  const _ColorSchemePreview();

  static const _spacing = 8.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final roles = [
      (colorScheme.primary, colorScheme.onPrimary, 'Primary'),
      (colorScheme.secondary, colorScheme.onSecondary, 'Secondary'),
      (colorScheme.tertiary, colorScheme.onTertiary, 'Tertiary'),
      (colorScheme.error, colorScheme.onError, 'Error'),
      (colorScheme.surface, colorScheme.onSurface, 'Surface'),
      (
        colorScheme.primaryContainer,
        colorScheme.onPrimaryContainer,
        'Primary\nCont.',
      ),
      (
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
        'Secondary\nCont.',
      ),
      (
        colorScheme.tertiaryContainer,
        colorScheme.onTertiaryContainer,
        'Tertiary\nCont.',
      ),
    ];
    return LayoutBuilder(
      builder: (_, constraints) {
        final columns = min(
          max((constraints.maxWidth / 68).floor(), 1),
          roles.length,
        );
        final itemWidth =
            (constraints.maxWidth - (columns - 1) * _spacing) / columns;
        return Wrap(
          spacing: _spacing,
          runSpacing: _spacing,
          children: [
            for (final (bg, fg, label) in roles)
              Container(
                width: itemWidth,
                height: 44,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(color: fg, fontSize: 9),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        );
      },
    );
  }
}
