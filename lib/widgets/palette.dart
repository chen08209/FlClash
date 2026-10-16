import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:flutter/foundation.dart' show clampDouble;
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:material_color_utilities/hct/hct.dart';
import 'package:material_ui/material_ui.dart';

const _trackHeight = 20.0;
const _thumbRadius = 14.0;
const _thumbRingWidth = 3.0;

// The corner follows the grid's cells, which a larger one would cut away.
const _padCorner = AppCorner.sm;

enum _PaletteMode { grid, spectrum, sliders }

/// Picks a color as iOS's color picker does: from a grid, a spectrum of hue
/// and lightness, or hue, saturation and brightness sliders.
class Palette extends StatefulWidget {
  const Palette({super.key, required this.controller});

  final ValueNotifier<Color> controller;

  @override
  State<Palette> createState() => _PaletteState();
}

class _PaletteState extends State<Palette> {
  var _mode = _PaletteMode.grid;
  late HSVColor _hsv = HSVColor.fromColor(widget.controller.value);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_syncHsv);
  }

  @override
  void didUpdateWidget(Palette oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_syncHsv);
      widget.controller.addListener(_syncHsv);
      _syncHsv();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncHsv);
    super.dispose();
  }

  // A gray drops its hue and black its saturation; the sliders keep the ones
  // they were dragged to until the color comes from elsewhere.
  void _syncHsv() {
    if (_hsv.toColor() != widget.controller.value) {
      setState(() => _hsv = HSVColor.fromColor(widget.controller.value));
    }
  }

  void _pick(Color color) => widget.controller.value = color;

  void _pickHsv(HSVColor hsv) {
    setState(() => _hsv = hsv);
    widget.controller.value = hsv.toColor();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedControl<_PaletteMode>(
          segments: [
            (_PaletteMode.grid, appLocalizations.grid),
            (_PaletteMode.spectrum, appLocalizations.spectrum),
            (_PaletteMode.sliders, appLocalizations.sliders),
          ],
          value: _mode,
          onChanged: (mode) => setState(() => _mode = mode),
        ),
        const SizedBox(height: 16),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: ValueListenableBuilder(
            valueListenable: widget.controller,
            builder: (_, color, _) => switch (_mode) {
              _PaletteMode.grid => _ColorGrid(color: color, onPicked: _pick),
              _PaletteMode.spectrum => _Spectrum(color: color, onPicked: _pick),
              _PaletteMode.sliders => _HsvSliders(
                hsv: _hsv,
                onChanged: _pickHsv,
              ),
            },
          ),
        ),
      ],
    );
  }
}

class _ColorGrid extends StatelessWidget {
  const _ColorGrid({required this.color, required this.onPicked});

  // iOS's columns run from sky blue round through red to green, skipping the
  // teals between green and sky.
  static const _hues = [
    230.0,
    262.0,
    285.0,
    310.0,
    340.0,
    20.0,
    40.0,
    60.0,
    80.0,
    100.0,
    120.0,
    145.0,
  ];
  static const _tones = [25.0, 33.0, 41.0, 49.0, 57.0, 65.0, 73.0, 81.0, 89.0];

  static final List<List<Color>> _rows = [
    [
      for (var column = 0; column < _hues.length; column++)
        Color(Hct.from(0, 0, 100 - column * 100 / (_hues.length - 1)).toInt()),
    ],
    for (final tone in _tones)
      [for (final hue in _hues) Color(Hct.from(hue, 200, tone).toInt())],
  ];

  final Color color;
  final ValueChanged<Color> onPicked;

  @override
  Widget build(BuildContext context) {
    final columns = _hues.length;
    final rows = _rows.length;
    return AspectRatio(
      aspectRatio: columns / rows,
      child: _PickArea(
        onPicked: (position, size) {
          final column = (position.dx / size.width * columns).floor();
          final row = (position.dy / size.height * rows).floor();
          onPicked(_rows[row.clamp(0, rows - 1)][column.clamp(0, columns - 1)]);
        },
        child: CustomPaint(
          painter: _GridPainter(rows: _rows, selected: color),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter({required this.rows, required this.selected});

  final List<List<Color>> rows;
  final Color selected;

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / rows.first.length;
    final cellHeight = size.height / rows.length;
    canvas.save();
    canvas.clipRSuperellipse(
      RSuperellipse.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(_padCorner),
      ),
    );
    // Without anti-aliasing the cells meet on whole pixels, with no seam of
    // the page between them.
    final paint = Paint()..isAntiAlias = false;
    Rect? selectedCell;
    for (var row = 0; row < rows.length; row++) {
      for (var column = 0; column < rows[row].length; column++) {
        final cell = Rect.fromLTWH(
          column * cellWidth,
          row * cellHeight,
          cellWidth,
          cellHeight,
        );
        final color = rows[row][column];
        canvas.drawRect(cell, paint..color = color);
        if (color == selected) {
          selectedCell = cell;
        }
      }
    }
    if (selectedCell != null) {
      final light =
          ThemeData.estimateBrightnessForColor(selected) == Brightness.dark;
      canvas.drawRSuperellipse(
        RSuperellipse.fromRectAndRadius(
          selectedCell.deflate(_thumbRingWidth / 2),
          const Radius.circular(AppCorner.xs),
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _thumbRingWidth
          ..color = light ? Colors.white : Colors.black,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) =>
      oldDelegate.selected != selected || oldDelegate.rows != rows;
}

class _Spectrum extends StatefulWidget {
  const _Spectrum({required this.color, required this.onPicked});

  final Color color;
  final ValueChanged<Color> onPicked;

  @override
  State<_Spectrum> createState() => _SpectrumState();
}

class _SpectrumState extends State<_Spectrum> {
  // White and black carry no hue, so the thumb stays where it was dragged
  // rather than jumping to the red end.
  ({Offset position, Color color})? _picked;

  Offset _positionOf(Color color) {
    final picked = _picked;
    if (picked != null && picked.color == color) {
      return picked.position;
    }
    final hsl = HSLColor.fromColor(color);
    return Offset(hsl.hue / 360, 1 - hsl.lightness);
  }

  void _handlePicked(Offset position, Size size) {
    final fraction = Offset(
      position.dx / size.width,
      position.dy / size.height,
    );
    final color = HSLColor.fromAHSL(
      1,
      clampDouble(fraction.dx * 360, 0, 359.99),
      1,
      1 - fraction.dy,
    ).toColor();
    _picked = (position: fraction, color: color);
    widget.onPicked(color);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 6 / 5,
      child: _PickArea(
        onPicked: _handlePicked,
        child: CustomPaint(
          painter: _SpectrumPainter(
            color: widget.color,
            position: _positionOf(widget.color),
          ),
        ),
      ),
    );
  }
}

class _SpectrumPainter extends CustomPainter {
  const _SpectrumPainter({required this.color, required this.position});

  static final _hues = [
    for (var hue = 0; hue <= 360; hue += 60)
      HSLColor.fromAHSL(1, hue % 360, 1, 0.5).toColor(),
  ];

  final Color color;
  final Offset position;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final shape = RSuperellipse.fromRectAndRadius(
      rect,
      const Radius.circular(_padCorner),
    );
    canvas.drawRSuperellipse(
      shape,
      Paint()..shader = LinearGradient(colors: _hues).createShader(rect),
    );
    // Mixing the pure hue with white above the middle and black below is
    // exactly HSL lightness at full saturation, which picking reads back.
    canvas.drawRSuperellipse(
      shape,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Color(0x00FFFFFF),
            Color(0x00000000),
            Colors.black,
          ],
          stops: [0, 0.5, 0.5, 1],
        ).createShader(rect),
    );
    _paintColorThumb(
      canvas,
      Offset(position.dx * size.width, position.dy * size.height),
      _thumbRadius,
      color,
    );
  }

  @override
  bool shouldRepaint(_SpectrumPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.position != position;
}

/// Claims the pointer on contact, so a drag that starts on the pad picks
/// colors instead of moving the sheet or the list around it.
class _ImmediatePanGestureRecognizer extends PanGestureRecognizer {
  _ImmediatePanGestureRecognizer({super.debugOwner});

  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }
}

class _PickArea extends StatelessWidget {
  const _PickArea({required this.onPicked, required this.child});

  final void Function(Offset position, Size size) onPicked;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final size = constraints.biggest;
        void pick(Offset position) => onPicked(
          Offset(
            clampDouble(position.dx, 0, size.width),
            clampDouble(position.dy, 0, size.height),
          ),
          size,
        );
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: RawGestureDetector(
            behavior: HitTestBehavior.opaque,
            gestures: {
              _ImmediatePanGestureRecognizer:
                  GestureRecognizerFactoryWithHandlers<
                    _ImmediatePanGestureRecognizer
                  >(
                    () => _ImmediatePanGestureRecognizer(debugOwner: this),
                    (recognizer) => recognizer
                      ..onDown = ((details) => pick(details.localPosition))
                      ..onUpdate = ((details) => pick(details.localPosition)),
                  ),
            },
            child: child,
          ),
        );
      },
    );
  }
}

class _HsvSliders extends StatelessWidget {
  const _HsvSliders({required this.hsv, required this.onChanged});

  static final _hues = [
    for (var hue = 0; hue <= 360; hue += 60)
      HSVColor.fromAHSV(1, hue % 360, 1, 1).toColor(),
  ];

  final HSVColor hsv;
  final ValueChanged<HSVColor> onChanged;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final color = hsv.toColor();
    final level = context.raisedSurfaceLevel;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: ShapeDecoration(
        color: level.colorOf(colorScheme),
        shape: AppShape.xl,
      ),
      child: SurfaceScope(
        level: level,
        child: Column(
          spacing: 20,
          children: [
            _LabeledSlider(
              label: appLocalizations.hue,
              value: '${hsv.hue.round()}°',
              slider: _GradientSlider(
                value: hsv.hue,
                max: 360,
                thumbColor: hsv.withSaturation(1).withValue(1).toColor(),
                colors: _hues,
                onChanged: (value) => onChanged(hsv.withHue(value)),
              ),
            ),
            _LabeledSlider(
              label: appLocalizations.saturation,
              value: '${(hsv.saturation * 100).round()}%',
              slider: _GradientSlider(
                value: hsv.saturation,
                max: 1,
                thumbColor: color,
                colors: [
                  hsv.withSaturation(0).toColor(),
                  hsv.withSaturation(1).toColor(),
                ],
                onChanged: (value) => onChanged(hsv.withSaturation(value)),
              ),
            ),
            _LabeledSlider(
              label: appLocalizations.brightness,
              value: '${(hsv.value * 100).round()}%',
              slider: _GradientSlider(
                value: hsv.value,
                max: 1,
                thumbColor: color,
                colors: [
                  hsv.withValue(0).toColor(),
                  hsv.withValue(1).toColor(),
                ],
                onChanged: (value) => onChanged(hsv.withValue(value)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledSlider extends StatelessWidget {
  const _LabeledSlider({
    required this.label,
    required this.value,
    required this.slider,
  });

  final String label;
  final String value;
  final Widget slider;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyle.subheadline
        .of(context)
        .copyWith(color: context.colorScheme.onSurfaceVariant);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyle.subheadline
                    .of(context, emphasized: true)
                    .copyWith(color: context.colorScheme.onSurfaceVariant),
              ),
            ),
            Text(
              value,
              style: style.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        slider,
      ],
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
    _paintColorThumb(
      context.canvas,
      center,
      _thumbRadius + activationAnimation.value * 2,
      color,
    );
  }
}

void _paintColorThumb(
  Canvas canvas,
  Offset center,
  double radius,
  Color color,
) {
  canvas.drawCircle(
    center.translate(0, 1),
    radius,
    Paint()
      ..color = Colors.black.withValues(alpha: 0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
  );
  canvas.drawCircle(center, radius, Paint()..color = Colors.white);
  canvas.drawCircle(center, radius - _thumbRingWidth, Paint()..color = color);
}

/// The six hex digits of an sRGB color, kept in step with [color] while
/// the reader is not halfway through typing one.
class HexColorField extends StatefulWidget {
  const HexColorField({
    super.key,
    required this.color,
    required this.onChanged,
  });

  final Color color;
  final ValueChanged<Color> onChanged;

  @override
  State<HexColorField> createState() => _HexColorFieldState();
}

class _HexColorFieldState extends State<HexColorField> {
  static const _length = 6;

  late final _controller = TextEditingController(text: _digitsOf(widget.color));

  static String _digitsOf(Color color) => color.hex.substring(1);

  static Color? _parse(String text) => text.length == _length
      ? Color(0xFF000000 | int.parse(text, radix: 16))
      : null;

  @override
  void didUpdateWidget(HexColorField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.color != oldWidget.color &&
        _parse(_controller.text) != widget.color) {
      final digits = _digitsOf(widget.color);
      _controller.value = TextEditingValue(
        text: digits,
        selection: TextSelection.collapsed(offset: digits.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FilledInputTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        controller: _controller,
        autocorrect: false,
        textCapitalization: TextCapitalization.characters,
        style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
        decoration: InputDecoration(
          hintText: context.appLocalizations.hex,
          prefixText: '#',
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[0-9a-fA-F]')),
          LengthLimitingTextInputFormatter(_length),
          TextInputFormatter.withFunction(
            (_, value) => value.copyWith(text: value.text.toUpperCase()),
          ),
        ],
        onChanged: (text) {
          final color = _parse(text);
          if (color != null) {
            widget.onChanged(color);
          }
        },
      ),
    );
  }
}
