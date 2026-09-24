import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _threeDigitHourThreshold = 100 * 60 * 60 * 1000;
const _widthAnimationDuration = Duration(milliseconds: 200);
const _buttonHeight = 56.0;
const _iconMorphDuration = Duration(milliseconds: 450);

TextStyle? _runTimeTextStyle(BuildContext context) {
  return context.textTheme.titleMedium?.toSoftBold.copyWith(
    color: context.colorScheme.onPrimaryContainer,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}

double _computeRunTimeTextWidth(
  BuildContext context, {
  required bool hasThreeDigitHours,
}) {
  final sample = hasThreeDigitHours ? '999:99:99' : '99:99:99';
  return globalState.measure
          .computeTextSize(Text(sample, style: _runTimeTextStyle(context)))
          .width +
      16;
}

class RunTimeText extends StatelessWidget {
  final int? timeStamp;

  const RunTimeText({super.key, required this.timeStamp});

  @override
  Widget build(BuildContext context) {
    return Text(
      getTimeText(timeStamp),
      maxLines: 1,
      overflow: TextOverflow.visible,
      style: _runTimeTextStyle(context),
    );
  }
}

class StartButton extends ConsumerStatefulWidget {
  const StartButton({super.key});

  @override
  ConsumerState<StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends ConsumerState<StartButton>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  late Animation<double> _animation;
  double? _twoDigitTextWidth;
  double? _threeDigitTextWidth;
  double? _suspendedTextWidth;
  int? _displayRunTime;

  @override
  void initState() {
    super.initState();
    final isStart = ref.read(isStartProvider);
    _displayRunTime = ref.read(runTimeProvider);
    _controller = AnimationController(
      vsync: this,
      value: isStart ? 1 : 0,
      duration: const Duration(milliseconds: 200),
    );
    _animation = CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeOutBack,
    );
    ref.listenManual(runTimeProvider, (_, next) {
      _updateDisplayRunTime(next);
    });
    ref.listenManual(isStartProvider, (prev, next) {
      updateController(next);
    }, fireImmediately: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _twoDigitTextWidth = null;
    _threeDigitTextWidth = null;
    _suspendedTextWidth = null;
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  void handleSwitchStart() {
    ref.read(commonActionProvider.notifier).toggleRunning();
  }

  void _updateDisplayRunTime(int? runTime) {
    if (!mounted ||
        _displayRunTime == runTime ||
        (runTime == null && !(_controller?.isDismissed ?? true))) {
      return;
    }
    setState(() {
      _displayRunTime = runTime;
    });
  }

  void updateController(bool isStart) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final controller = _controller;
      if (controller == null) {
        return;
      }
      if (isStart) {
        controller.forward();
        return;
      }
      controller.reverse().whenCompleteOrCancel(() {
        if (mounted && controller.isDismissed) {
          _updateDisplayRunTime(ref.read(runTimeProvider));
        }
      });
    });
  }

  double _getRunTimeTextWidth(
    BuildContext context, {
    required bool hasThreeDigitHours,
  }) {
    if (hasThreeDigitHours) {
      return _threeDigitTextWidth ??= _computeRunTimeTextWidth(
        context,
        hasThreeDigitHours: true,
      );
    }
    return _twoDigitTextWidth ??= _computeRunTimeTextWidth(
      context,
      hasThreeDigitHours: false,
    );
  }

  double _getSuspendedTextWidth(BuildContext context, String suspendedText) {
    return _suspendedTextWidth ??=
        globalState.measure
            .computeTextSize(
              Text(suspendedText, style: context.textTheme.titleMedium),
            )
            .width +
        24;
  }

  Widget _buildIcon(bool isStart, {required bool suspended}) {
    return AnimatedSwitcher(
      duration: context.motionDuration(commonDuration),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: animation, child: child),
      ),
      child: suspended
          ? const GlyphIcon(AppGlyphs.wifiOff, fill: 1)
          : TweenAnimationBuilder<double>(
              tween: Tween(end: isStart ? 1 : 0),
              duration: _iconMorphDuration,
              curve: Curves.easeOutBack,
              builder: (_, progress, _) =>
                  GlyphIcon(AppGlyphs.playPause(progress), fill: 1),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasProfile = ref.watch(
      profilesProvider.select((state) => state.isNotEmpty),
    );
    if (!hasProfile) {
      return Container();
    }
    final isStart = ref.watch(isStartProvider);
    final suspend = ref.watch(suspendProvider);
    final appLocalizations = context.appLocalizations;
    final suspended = isStart && suspend;
    if (NavigationDock.isDocked(context)) {
      return BreathingFill(
        active: isStart && !suspend,
        child: FloatingActionButton(
          heroTag: null,
          tooltip: suspended ? appLocalizations.suspended : null,
          onPressed: handleSwitchStart,
          child: _buildIcon(isStart, suspended: suspended),
        ),
      );
    }
    final hasThreeDigitHours =
        (_displayRunTime ?? 0) >= _threeDigitHourThreshold;
    final theme = Theme.of(context);
    final textWidth = suspend
        ? _getSuspendedTextWidth(context, appLocalizations.suspended)
        : _getRunTimeTextWidth(context, hasThreeDigitHours: hasThreeDigitHours);
    return RepaintBoundary(
      child: Theme(
        data: theme.copyWith(
          floatingActionButtonTheme: theme.floatingActionButtonTheme.copyWith(
            sizeConstraints: const BoxConstraints(
              minWidth: 56,
              maxWidth: 220,
              minHeight: _buttonHeight,
              maxHeight: _buttonHeight,
            ),
          ),
        ),
        child: ElasticButton(
          child: FloatingActionButton(
            clipBehavior: Clip.antiAlias,
            materialTapTargetSize: MaterialTapTargetSize.padded,
            heroTag: null,
            onPressed: () {
              handleSwitchStart();
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _animation,
                  builder: (_, child) {
                    return Container(
                      height: _buttonHeight,
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16 - 8 * _animation.value,
                      ),
                      alignment: Alignment.centerLeft,
                      child: child,
                    );
                  },
                  child: _buildIcon(isStart, suspended: suspended),
                ),
                SizeTransition(
                  axis: Axis.horizontal,
                  alignment: Alignment.centerLeft,
                  sizeFactor: _animation,
                  child: AnimatedContainer(
                    width: textWidth,
                    duration: _widthAnimationDuration,
                    curve: Curves.easeOut,
                    child: suspend
                        ? Text(
                            appLocalizations.suspended,
                            maxLines: 1,
                            overflow: TextOverflow.visible,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: context.colorScheme.onPrimaryContainer,
                                ),
                          )
                        : RunTimeText(timeStamp: _displayRunTime),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BreathingFill extends StatefulWidget {
  const BreathingFill({super.key, required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  State<BreathingFill> createState() => _BreathingFillState();
}

class _BreathingFillState extends State<BreathingFill> {
  static const _breathDuration = Duration(milliseconds: 1400);
  // A ticker would redraw the screen on every vsync for as long as the core runs.
  static const _breathStep = Duration(milliseconds: 66);
  static const _fadeDuration = Duration(milliseconds: 300);

  final _breath = ValueNotifier<double>(0);
  late final AppLifecycleListener _lifecycle;
  Timer? _timer;
  int _steps = 0;
  bool _canAnimate = true;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onStateChange: (_) => _sync());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _canAnimate =
        !MediaQuery.disableAnimationsOf(context) &&
        TickerMode.valuesOf(context).enabled;
    _sync();
  }

  @override
  void didUpdateWidget(BreathingFill oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  bool get _isForeground => switch (WidgetsBinding.instance.lifecycleState) {
    null || AppLifecycleState.resumed || AppLifecycleState.inactive => true,
    _ => false,
  };

  void _sync() {
    if (!widget.active || !_canAnimate || !_isForeground) {
      _timer?.cancel();
      _timer = null;
      if (widget.active) _breath.value = 1;
      return;
    }
    _timer ??= Timer.periodic(_breathStep, (_) => _step());
  }

  void _step() {
    final period = _breathDuration.inMicroseconds / _breathStep.inMicroseconds;
    final phase = ++_steps % (2 * period) / period;
    _breath.value = Curves.easeInOut.transform(phase <= 1 ? phase : 2 - phase);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _lifecycle.dispose();
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: widget.active ? 1 : 0,
              duration: _fadeDuration,
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _BreathingFillPainter(
                    breath: _breath,
                    color: theme.colorScheme.onPrimaryContainer,
                    shape:
                        theme.floatingActionButtonTheme.shape ?? AppShape.full,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BreathingFillPainter extends CustomPainter {
  _BreathingFillPainter({
    required this.breath,
    required this.color,
    required this.shape,
  }) : super(repaint: breath);

  final ValueNotifier<double> breath;
  final Color color;
  final ShapeBorder shape;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      shape.getOuterPath(Offset.zero & size),
      Paint()..color = color.withValues(alpha: 0.14 * breath.value),
    );
  }

  @override
  bool shouldRepaint(_BreathingFillPainter oldDelegate) =>
      color != oldDelegate.color || shape != oldDelegate.shape;
}
