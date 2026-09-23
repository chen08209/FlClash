import 'dart:math' as math;

import 'package:fl_clash/common/common.dart';
import 'package:material_ui/material_ui.dart';

/// Area chart of a sample stream that scrolls each new sample in from the right.
class LineChart extends StatefulWidget {
  const LineChart({
    super.key,
    required this.values,
    required this.revision,
    required this.capacity,
    required this.minScale,
    required this.color,
    this.sampleInterval = const Duration(seconds: 1),
  }) : assert(capacity > 1),
       assert(minScale > 0);

  final List<double> values;

  /// Advances by one for each sample appended to [values]. Any other change,
  /// such as a clear, redraws the chart without scrolling.
  final int revision;

  final int capacity;

  /// The least value the top stands for, so idle noise stays near the baseline.
  final double minScale;

  final Color color;

  final Duration sampleInterval;

  @override
  State<LineChart> createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> with TickerProviderStateMixin {
  static const _maxLag = 2.0;
  static const _rescaleDuration = Duration(milliseconds: 450);

  late final AnimationController _lag;
  late final AnimationController _rescale;
  late final _LogTween _scaleTween;
  late final Animation<double> _scale;
  late _Series _series;

  @override
  void initState() {
    super.initState();
    _series = _Series.of(widget.values, _seriesLength);
    _lag = AnimationController.unbounded(vsync: this);
    _rescale = AnimationController(vsync: this, value: 1);
    _scaleTween = _LogTween(_scaleTarget);
    _scale = _rescale
        .drive(CurveTween(curve: Easing.standardDecelerate))
        .drive(_scaleTween);
  }

  /// Extra samples keep the left edge covered while lagging up to [_maxLag],
  /// and keep the slope that changes when the oldest drops out off screen.
  int get _seriesLength =>
      widget.capacity + _maxLag.toInt() + 2 + _Series.radius;

  double get _scaleTarget => math.max(_series.max, widget.minScale);

  @override
  void didUpdateWidget(LineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.capacity != oldWidget.capacity) {
      _reset();
      return;
    }
    final appended = widget.revision - oldWidget.revision;
    if (appended == 0) {
      _retargetScale();
      return;
    }
    if (appended < 0 || appended > widget.values.length) {
      _reset();
      return;
    }
    _series = _series.append(
      widget.values.sublist(widget.values.length - appended),
    );
    if (_series.isFlat) {
      _lag.value = 0;
    } else {
      final lag = math.min(_lag.value + appended, _maxLag);
      _lag.value = lag;
      _lag.animateTo(
        0,
        duration: context.motionDuration(widget.sampleInterval * lag),
      );
    }
    _retargetScale();
  }

  void _reset() {
    _series = _Series.of(widget.values, _seriesLength);
    _lag.value = 0;
    _retargetScale();
  }

  void _retargetScale() {
    final target = _scaleTarget;
    if (target == _scaleTween.end) {
      return;
    }
    _scaleTween
      ..begin = _scale.value
      ..end = target;
    _rescale
      ..duration = context.motionDuration(_rescaleDuration)
      ..forward(from: 0);
  }

  @override
  void dispose() {
    _lag.dispose();
    _rescale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _LineChartPainter(
            series: _series,
            capacity: widget.capacity,
            lag: _lag,
            scale: _scale,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}

/// Log space, so a jump across orders of magnitude zooms at an even pace.
class _LogTween extends Tween<double> {
  _LogTween(double value) : super(begin: value, end: value);

  @override
  double lerp(double t) {
    final from = math.log(begin!);
    return math.exp(from + (math.log(end!) - from) * t);
  }
}

@immutable
class _Series {
  _Series._(this.values)
    : max = _blur(values, List.filled(values.length, 1.0)).reduce(math.max);

  factory _Series.of(List<double> window, int length) {
    final count = math.min(window.length, length);
    return _Series._(
      List.filled(length, 0.0)
        ..setAll(length - count, window.sublist(window.length - count)),
    );
  }

  static const _sigma = 1.5;
  static final radius = (_sigma * 2.5).ceil();
  static final _kernel = [
    for (var d = 0; d <= radius; d++) math.exp(-d * d / (2 * _sigma * _sigma)),
  ];

  final List<double> values;

  final double max;

  bool get isFlat => values.every((value) => value == values.first);

  _Series append(List<double> samples) {
    final next = [...values, ...samples];
    return _Series._(next.sublist(next.length - values.length));
  }

  /// A sample scrolling in weighs in by [presence], so it never bends the curve.
  static List<double> _blur(List<double> values, List<double> presence) {
    return [
      for (var i = 0; i < values.length; i++) _blurAt(values, presence, i),
    ];
  }

  static double _blurAt(List<double> values, List<double> presence, int i) {
    var sum = 0.0;
    var weight = 0.0;
    final from = math.max(i - radius, 0);
    final to = math.min(i + radius, values.length - 1);
    for (var j = from; j <= to; j++) {
      final w = _kernel[(j - i).abs()] * presence[j];
      sum += w * values[j];
      weight += w;
    }
    return weight == 0 ? values[i] : sum / weight;
  }

  List<double> blurred(List<double> presence) => _blur(values, presence);

  /// Catmull-Rom slopes, clamped so no control point and no curve dips below 0.
  static List<double> slopesOf(List<double> values) {
    final last = values.length - 1;
    return [
      for (var i = 0; i <= last; i++)
        i == 0 || i == last
            ? 0.0
            : ((values[i + 1] - values[i - 1]) / 2).clamp(
                -3 * values[i],
                3 * values[i],
              ),
    ];
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.series,
    required this.capacity,
    required this.lag,
    required this.scale,
    required this.color,
  }) : _strokePaint = Paint()
         ..color = color
         ..strokeWidth = _strokeWidth
         ..strokeCap = StrokeCap.round
         ..strokeJoin = StrokeJoin.round
         ..style = PaintingStyle.stroke,
       super(repaint: Listenable.merge([lag, scale]));

  static const _strokeWidth = 2.0;

  /// Keeps the zero line clear of the card's rounded bottom corners.
  static const _baselineRatio = 0.7;

  final _Series series;
  final int capacity;
  final Animation<double> lag;
  final Animation<double> scale;
  final Color color;

  final Paint _strokePaint;
  final Paint _fillPaint = Paint();
  Size? _shaderSize;

  @override
  void paint(Canvas canvas, Size size) {
    final step = size.width / (capacity - 1);
    final baseline = size.height * _baselineRatio;
    final count = series.values.length;
    final firstX = size.width + (lag.value - count + 1) * step;
    double xOf(int index) => firstX + index * step;
    final values = series.blurred([
      for (var i = 0; i < count; i++)
        ((size.width + step - xOf(i)) / step).clamp(0.0, 1.0),
    ]);
    final slopes = _Series.slopesOf(values);

    // A sample eases from a flat end into its real slope while it crosses
    // the last step, so its successor arriving never bends what is shown.
    double riseOf(int index) {
      final settled = ((size.width - xOf(index)) / step).clamp(0.0, 1.0);
      return slopes[index] * settled;
    }

    var x = firstX;
    var y = -values[0];
    var rise = riseOf(0);
    final curve = Path()..moveTo(x, y);
    for (var i = 1; i < count; i++) {
      final nextX = x + step;
      final nextY = -values[i];
      final nextRise = riseOf(i);
      curve.cubicTo(
        x + step / 3,
        y - rise / 3,
        nextX - step / 3,
        nextY + nextRise / 3,
        nextX,
        nextY,
      );
      x = nextX;
      y = nextY;
      rise = nextRise;
    }
    // Blurring without the samples still scrolling in lifts a fresh peak
    // above the series max, so the top also stands for the drawn curve.
    final top = math.max(scale.value, -curve.getBounds().top);
    final yScale = (baseline - _strokeWidth) / top;
    final line = curve.transform(
      (Matrix4.identity()
            ..translateByDouble(0, baseline, 0, 1)
            ..scaleByDouble(1, yScale, 1, 1))
          .storage,
    );
    final area = Path.from(line)
      ..lineTo(x, size.height)
      ..lineTo(firstX, size.height)
      ..close();

    if (_shaderSize != size) {
      _shaderSize = size;
      _fillPaint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.opacity38, color.opacity10],
      ).createShader(Offset.zero & size);
    }
    canvas
      ..save()
      ..clipRect(Offset.zero & size)
      ..drawPath(area, _fillPaint)
      ..drawPath(line, _strokePaint)
      ..restore();
  }

  @override
  bool shouldRepaint(_LineChartPainter oldDelegate) {
    return oldDelegate.series != series ||
        oldDelegate.capacity != capacity ||
        oldDelegate.lag != lag ||
        oldDelegate.scale != scale ||
        oldDelegate.color != color;
  }
}
