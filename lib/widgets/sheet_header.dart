import 'package:fl_clash/common/common.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'inherited.dart';

class SheetDragHandle extends StatelessWidget {
  const SheetDragHandle({super.key});

  static const height = _topPadding + _thickness;

  static const _topPadding = 6.0;
  static const _thickness = 4.0;
  static const _width = 28.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: _topPadding),
      child: Container(
        alignment: Alignment.center,
        height: _thickness,
        width: _width,
        decoration: ShapeDecoration(
          color: context.colorScheme.onSurfaceVariant,
          shape: AppShape.all(_thickness / 2),
        ),
      ),
    );
  }
}

/// A drag handle over [appBar], together exactly [sheetAppBarHeight] tall.
class SheetToolBar extends StatelessWidget {
  const SheetToolBar({super.key, required this.appBar});

  static const _trailing =
      sheetAppBarHeight - SheetDragHandle.height - sheetToolbarHeight;

  final Widget appBar;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SheetDragHandle(),
        appBar,
        const SizedBox(height: _trailing),
      ],
    );
  }
}

/// Fades the surface behind [child] toward its foot so content reads through.
class FloatingHeader extends StatelessWidget {
  const FloatingHeader({
    super.key,
    required this.backgroundColor,
    this.fadeStart = 0.5,
    required this.child,
  });

  final Color backgroundColor;
  final double fadeStart;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0, fadeStart, 1],
          colors: [
            backgroundColor.withValues(alpha: 0.8),
            backgroundColor.withValues(alpha: 0.8),
            backgroundColor.opacity0,
          ],
        ),
      ),
      child: child,
    );
  }
}

/// Floats [header] over [body], fading it out so content reads through it
/// as it scrolls past; [footer] sits on its own surface.
class FloatingHeaderBody extends StatelessWidget {
  const FloatingHeaderBody({
    super.key,
    required this.backgroundColor,
    required this.header,
    required this.body,
    this.footer,
  });

  final Color backgroundColor;
  final Widget header;
  final Widget body;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ScrollConfiguration(
          behavior: const ShowBarScrollBehavior(
            scrollbarPadding: EdgeInsets.only(top: sheetAppBarHeight),
          ),
          child: body,
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: FloatingHeader(
            backgroundColor: backgroundColor,
            child: header,
          ),
        ),
        if (footer != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SheetOverhangLift(
              child: Material(type: MaterialType.transparency, child: footer),
            ),
          ),
      ],
    );
  }
}

/// Holds its child clear of the part of the sheet that hangs below the screen
/// while the sheet is dragged below its shortest detent.
class SheetOverhangLift extends SingleChildRenderObjectWidget {
  const SheetOverhangLift({super.key, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderSheetOverhangLift(overhang: SheetOverhangScope.of(context));
  }

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderSheetOverhangLift).overhang = SheetOverhangScope.of(
      context,
    );
  }
}

class _RenderSheetOverhangLift extends RenderTransform {
  _RenderSheetOverhangLift({required ValueListenable<double>? overhang})
    : _overhang = overhang,
      super(transform: Matrix4.identity(), transformHitTests: true) {
    _overhang?.addListener(_syncTransform);
  }

  ValueListenable<double>? _overhang;

  set overhang(ValueListenable<double>? value) {
    if (_overhang == value) {
      return;
    }
    _overhang?.removeListener(_syncTransform);
    _overhang = value;
    _overhang?.addListener(_syncTransform);
    _syncTransform();
  }

  @override
  void performLayout() {
    super.performLayout();
    _syncTransform();
  }

  @override
  void dispose() {
    _overhang?.removeListener(_syncTransform);
    super.dispose();
  }

  void _syncTransform() {
    transform = Matrix4.translationValues(0, -(_overhang?.value ?? 0), 0);
  }
}
