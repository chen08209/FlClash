import 'dart:math' as math;

import 'package:fl_clash/common/common.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:material_ui/material_ui.dart';

// Geometry and timing follow Flutter's CupertinoTextMagnifier, which mirrors
// the iOS text loupe; the capsule is drawn as a superellipse instead.
const _loupeSize = Size(80, 47.5);
const _loupeGapAboveLineCenter = 26.0;
const _loupeEdgePadding = 10.0;
const _loupeDragResistance = 10.0;
const _loupeInOutDuration = Duration(milliseconds: 150);
const _loupeFollowDuration = Duration(milliseconds: 45);

/// An iOS-style text loupe for a [MagnifierBuilder]. It animates in when
/// shown and hands its animation to [controller], so
/// [MagnifierController.hide] plays it out before the overlay entry goes.
class TextLoupe extends StatefulWidget {
  final MagnifierController controller;
  final ValueListenable<MagnifierInfo> magnifierInfo;
  final Color borderColor;
  final double magnificationScale;

  const TextLoupe({
    super.key,
    required this.controller,
    required this.magnifierInfo,
    required this.borderColor,
    this.magnificationScale = 1.25,
  });

  @override
  State<TextLoupe> createState() => _TextLoupeState();
}

class _TextLoupeState extends State<TextLoupe>
    with SingleTickerProviderStateMixin {
  late final AnimationController _inOut;
  late final CurvedAnimation _inOutCurve;
  Offset _position = Offset.zero;
  double _focalAdjustment = 0;

  @override
  void initState() {
    super.initState();
    _inOut = AnimationController(vsync: this, duration: _loupeInOutDuration)
      ..forward();
    _inOutCurve = CurvedAnimation(parent: _inOut, curve: Curves.easeOut);
    widget.controller.animationController = _inOut;
    widget.magnifierInfo.addListener(_onInfoChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reposition();
  }

  @override
  void didUpdateWidget(TextLoupe oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.magnifierInfo != widget.magnifierInfo) {
      oldWidget.magnifierInfo.removeListener(_onInfoChanged);
      widget.magnifierInfo.addListener(_onInfoChanged);
      _reposition();
    }
  }

  @override
  void dispose() {
    widget.magnifierInfo.removeListener(_onInfoChanged);
    if (widget.controller.animationController == _inOut) {
      widget.controller.animationController = null;
    }
    _inOutCurve.dispose();
    _inOut.dispose();
    super.dispose();
  }

  void _onInfoChanged() {
    if (!widget.controller.shown) _inOut.forward();
    setState(_reposition);
  }

  void _reposition() {
    final info = widget.magnifierInfo.value;
    final lineCenter = info.caretRect.center.dy;
    final lensY = math.max(
      lineCenter,
      lineCenter -
          (lineCenter - info.globalGesturePosition.dy) / _loupeDragResistance,
    );
    final screenWidth = MediaQuery.sizeOf(context).width;
    final left = (info.globalGesturePosition.dx - _loupeSize.width / 2).clamp(
      _loupeEdgePadding,
      math.max(
        _loupeEdgePadding,
        screenWidth - _loupeEdgePadding - _loupeSize.width,
      ),
    );
    _position = Offset(
      left.toDouble(),
      lensY - _loupeSize.height - _loupeGapAboveLineCenter,
    );
    _focalAdjustment = lineCenter - lensY;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: _loupeFollowDuration,
      curve: Curves.easeOut,
      left: _position.dx,
      top: _position.dy,
      child: AnimatedBuilder(
        animation: _inOutCurve,
        builder: (context, _) {
          final t = _inOutCurve.value;
          return Transform.translate(
            offset: Offset(0, _loupeGapAboveLineCenter * (1 - t)),
            child: RawMagnifier(
              size: _loupeSize,
              magnificationScale: widget.magnificationScale,
              focalPointOffset: Offset(
                0,
                _loupeSize.height / 2 +
                    _loupeGapAboveLineCenter +
                    _focalAdjustment,
              ),
              decoration: MagnifierDecoration(
                opacity: t,
                shape: AppShape.full.copyWith(
                  side: BorderSide(color: widget.borderColor, width: 2),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color.fromARGB(25, 0, 0, 0),
                    blurRadius: 11,
                    spreadRadius: 0.2,
                    blurStyle: BlurStyle.outer,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
