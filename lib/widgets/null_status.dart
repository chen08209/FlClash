import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/widgets/fade_box.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_new_shapes/material_new_shapes.dart';
import 'package:material_ui/material_ui.dart';

enum NullStatusIllustration {
  data,
  logs,
  proxies,
  profile,
  scripts,
  rules,
  connections,
  requests,
  wifi,
  apps,
  history,
  permission,
}

class NullStatusSwitcher extends StatelessWidget {
  static const _exitDuration = Duration(milliseconds: 150);

  final bool isEmpty;
  final NullStatus nullStatus;
  final Widget child;

  const NullStatusSwitcher({
    super.key,
    required this.isEmpty,
    required this.nullStatus,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: context.motionDuration(commonDuration),
      reverseDuration: context.motionDuration(_exitDuration),
      switchInCurve: Easing.emphasizedDecelerate,
      switchOutCurve: Curves.easeIn,
      layoutBuilder: (currentChild, previousChildren) => Align(
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: <Widget>[...previousChildren, ?currentChild],
        ),
      ),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: animation.drive(Tween(begin: 0.92, end: 1.0)),
          child: child,
        ),
      ),
      child: isEmpty
          ? KeyedSubtree(
              key: const ValueKey(_NullStatusSlot.empty),
              child: nullStatus,
            )
          : KeyedSubtree(
              key: const ValueKey(_NullStatusSlot.content),
              child: child,
            ),
    );
  }
}

enum _NullStatusSlot { empty, content }

class NullStatus extends StatelessWidget {
  final String label;
  final String? description;
  final Widget? action;
  final NullStatusIllustration illustration;

  const NullStatus({
    super.key,
    required this.label,
    this.description,
    this.action,
    this.illustration = NullStatusIllustration.data,
  });

  @override
  Widget build(BuildContext context) {
    final description = this.description;
    final action = this.action;
    return Align(
      alignment: const Alignment(0.0, -0.25),
      child: Wrap(
        direction: Axis.vertical,
        runAlignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _EnterItem(
            child: RepaintBoundary(
              child: _EmptyIllustration(type: illustration),
            ),
          ),
          const SizedBox(height: 16),
          _EnterItem(
            delay: _staggerStep,
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.toBold.toLight,
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: 8),
            _EnterItem(
              delay: _staggerStep * 2,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: 24),
            _EnterItem(
              delay: _staggerStep * (description != null ? 3 : 2),
              child: action,
            ),
          ],
        ],
      ),
    );
  }
}

const _staggerStep = Duration(milliseconds: 60);
const _enterRise = 12.0;

class _EnterItem extends StatefulWidget {
  final Duration delay;
  final Widget child;

  const _EnterItem({this.delay = Duration.zero, required this.child});

  @override
  State<_EnterItem> createState() => _EnterItemState();
}

class _EnterItemState extends State<_EnterItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool? _skipped;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: commonDuration + widget.delay,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_skipped != null) {
      return;
    }
    final route = ModalRoute.of(context);
    final routeEntering =
        route != null &&
        (route.offstage || (route.animation?.isAnimating ?? false));
    _skipped = context.disableAnimations || routeEntering;
    if (!_skipped!) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skipped = _skipped;
    if (skipped == null || skipped) {
      return widget.child;
    }
    final total = commonDuration + widget.delay;
    final start = widget.delay.inMicroseconds / total.inMicroseconds;
    final animation = start == 0
        ? _controller.view
        : _controller.drive(CurveTween(curve: Interval(start, 1)));
    return FadeSlideEnterTransition(
      animation: animation,
      distance: _enterRise,
      axis: Axis.vertical,
      child: widget.child,
    );
  }
}

class _EmptyIllustration extends StatelessWidget {
  static const _dimension = 200.0;

  final NullStatusIllustration type;

  const _EmptyIllustration({required this.type});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final (assetPath, shape, backgroundColor) = switch (type) {
      NullStatusIllustration.data => (
        'assets/images/empty/data.svg',
        MaterialShapes.square,
        colorScheme.secondaryContainer,
      ),
      NullStatusIllustration.logs => (
        'assets/images/empty/log.svg',
        MaterialShapes.softBurst,
        colorScheme.primaryContainer,
      ),
      NullStatusIllustration.proxies => (
        'assets/images/empty/proxy.svg',
        MaterialShapes.cookie12Sided,
        colorScheme.tertiaryContainer,
      ),
      NullStatusIllustration.profile => (
        'assets/images/empty/profile.svg',
        MaterialShapes.arch,
        colorScheme.primaryContainer,
      ),
      NullStatusIllustration.scripts => (
        'assets/images/empty/script.svg',
        MaterialShapes.cookie6Sided,
        colorScheme.secondaryContainer,
      ),
      NullStatusIllustration.rules => (
        'assets/images/empty/rule.svg',
        MaterialShapes.flower,
        colorScheme.tertiaryContainer,
      ),
      NullStatusIllustration.connections => (
        'assets/images/empty/connection.svg',
        MaterialShapes.puffyDiamond,
        colorScheme.secondaryContainer,
      ),
      NullStatusIllustration.requests => (
        'assets/images/empty/request.svg',
        MaterialShapes.arrow,
        colorScheme.primaryContainer,
      ),
      NullStatusIllustration.wifi => (
        'assets/images/empty/wifi.svg',
        MaterialShapes.clamShell,
        colorScheme.tertiaryContainer,
      ),
      NullStatusIllustration.apps => (
        'assets/images/empty/apps.svg',
        MaterialShapes.cookie9Sided,
        colorScheme.secondaryContainer,
      ),
      NullStatusIllustration.history => (
        'assets/images/empty/history.svg',
        MaterialShapes.softBoom,
        colorScheme.primaryContainer,
      ),
      NullStatusIllustration.permission => (
        'assets/images/empty/permission.svg',
        MaterialShapes.circle,
        colorScheme.tertiaryContainer,
      ),
    };
    return CustomPaint(
      key: ValueKey(type),
      painter: _MaterialShapePainter(shape: shape, color: backgroundColor),
      child: SvgPicture.asset(
        assetPath,
        width: _dimension,
        height: _dimension,
        colorMapper: _IllustrationColorMapper(colorScheme),
        excludeFromSemantics: true,
      ),
    );
  }
}

class _MaterialShapePainter extends CustomPainter {
  final RoundedPolygon shape;
  final Color color;

  _MaterialShapePainter({required this.shape, required this.color});

  late final Path _path = shape.toPath();

  @override
  void paint(Canvas canvas, Size size) {
    final dimension = size.shortestSide;
    final offset = Offset(
      (size.width - dimension) / 2,
      (size.height - dimension) / 2,
    );
    final paint = Paint()
      ..color = color
      ..isAntiAlias = true;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(dimension);
    canvas.drawPath(_path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MaterialShapePainter oldDelegate) =>
      oldDelegate.shape != shape || oldDelegate.color != color;
}

class _IllustrationColorMapper extends ColorMapper {
  final ColorScheme colorScheme;

  const _IllustrationColorMapper(this.colorScheme);

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) => switch (color.toARGB32()) {
    0xFFE8DEF8 => colorScheme.secondaryContainer,
    0xFF6750A4 => colorScheme.primary,
    0xFFFDF7FF => colorScheme.surface,
    0xFFC4C7C5 => colorScheme.outlineVariant,
    _ => color,
  };

  @override
  bool operator ==(Object other) =>
      other is _IllustrationColorMapper && other.colorScheme == colorScheme;

  @override
  int get hashCode => colorScheme.hashCode;
}
