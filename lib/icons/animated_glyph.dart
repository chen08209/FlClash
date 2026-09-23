import 'dart:math' as math;

import 'package:fl_clash/icons/glyph.dart';
import 'package:fl_clash/icons/glyph_icon.dart';
import 'package:material_ui/material_ui.dart';

const _fillDuration = Duration(milliseconds: 350);
const _popScale = 0.1;

class AnimatedGlyph extends StatefulWidget {
  const AnimatedGlyph({super.key, required this.glyph, required this.filled});

  final Glyph glyph;
  final bool filled;

  @override
  State<AnimatedGlyph> createState() => _AnimatedGlyphState();
}

class _AnimatedGlyphState extends State<AnimatedGlyph>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _fillDuration,
    value: widget.filled ? 1 : 0,
  );
  late final CurvedAnimation _fill = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOutCubic,
  );
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: _fillDuration,
  );
  late final Listenable _animation = Listenable.merge([_fill, _pop]);

  @override
  void didUpdateWidget(covariant AnimatedGlyph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filled == widget.filled) {
      return;
    }
    if (widget.filled) {
      _controller.forward();
      if (!_pop.isAnimating) {
        _pop.forward(from: 0);
      }
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _fill.dispose();
    _controller.dispose();
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final pop = _pop.isAnimating
            ? math.sin(math.pi * _pop.value) * _popScale
            : 0.0;
        return Transform.scale(
          scale: 1 + pop,
          child: GlyphIcon(widget.glyph, fill: _fill.value),
        );
      },
    );
  }
}
