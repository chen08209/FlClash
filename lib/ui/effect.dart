import 'dart:math';
import 'dart:ui';

import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/inherited.dart';
import 'package:material_ui/material_ui.dart';

class CommonExpandIcon extends StatefulWidget {
  final bool expand;

  const CommonExpandIcon({super.key, this.expand = false});

  @override
  State<CommonExpandIcon> createState() => _CommonExpandIconState();
}

class _CommonExpandIconState extends State<CommonExpandIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _iconTurns;

  static final Animatable<double> _iconTurnTween = Tween<double>(
    begin: 0.0,
    end: 0.5,
  ).chain(CurveTween(curve: Curves.fastOutSlowIn));

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _iconTurns = _animationController.drive(_iconTurnTween);
    if (widget.expand) {
      _animationController.value = pi;
    }
  }

  @override
  void didUpdateWidget(covariant CommonExpandIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expand != widget.expand) {
      if (widget.expand) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController.view,
      builder: (_, child) {
        return RotationTransition(turns: _iconTurns, child: child!);
      },
      child: const GlyphIcon(AppGlyphs.caretDown, fill: 1),
    );
  }
}

Widget commonProxyDecorator(
  Widget child,
  int index,
  Animation<double> animation,
) {
  return AnimatedBuilder(
    animation: animation,
    builder: (_, Widget? child) {
      final double animValue = Curves.easeInOut.transform(animation.value);
      final double scale = lerpDouble(1, 1.02, animValue)!;
      return ProxyDecoratorProvider(
        isProxyDecorator: true,
        lift: animValue,
        child: Transform.scale(scale: scale, child: child),
      );
    },
    child: child,
  );
}
