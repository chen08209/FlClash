import 'dart:ui' as ui show Image;

import 'package:fl_clash/ui/context.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

/// Switches the theme in one frame and fades the frame before it out on top,
/// instead of lerping [ThemeData] and rebuilding every dependent each frame.
class ThemeCrossFade extends StatefulWidget {
  const ThemeCrossFade({
    super.key,
    this.duration = kThemeAnimationDuration,
    required this.child,
  });

  final Duration duration;
  final Widget child;

  @override
  State<ThemeCrossFade> createState() => _ThemeCrossFadeState();
}

class _ThemeCrossFadeState extends State<ThemeCrossFade>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..addStatusListener(_handleStatus);
  final _fadeKey = GlobalKey();
  ThemeData? _theme;
  ui.Image? _snapshot;
  Size? _snapshotSize;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final theme = Theme.of(context);
    final previous = _theme;
    _theme = theme;
    if (previous != null && previous != theme) {
      _capture();
    }
  }

  void _capture() {
    if (context.disableAnimations) {
      return;
    }
    switch (WidgetsBinding.instance.lifecycleState) {
      case AppLifecycleState.hidden ||
          AppLifecycleState.paused ||
          AppLifecycleState.detached:
        return;
      case _:
    }
    final fade = _fadeKey.currentContext?.findRenderObject();
    if (fade is! _RenderThemeCrossFade) {
      return;
    }
    final image = fade.capture(MediaQuery.devicePixelRatioOf(context));
    if (image == null) {
      return;
    }
    _snapshot?.dispose();
    _snapshot = image;
    _snapshotSize = fade.size;
    _controller.forward(from: 0);
  }

  void _handleStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(_drop);
    }
  }

  void _drop() {
    _snapshot?.dispose();
    _snapshot = null;
    _snapshotSize = null;
  }

  @override
  void dispose() {
    _controller.dispose();
    _drop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ThemeCrossFadeLayer(
      key: _fadeKey,
      snapshot: _snapshot,
      snapshotSize: _snapshotSize,
      progress: _controller,
      child: RepaintBoundary(child: widget.child),
    );
  }
}

class _ThemeCrossFadeLayer extends SingleChildRenderObjectWidget {
  const _ThemeCrossFadeLayer({
    super.key,
    required this.snapshot,
    required this.snapshotSize,
    required this.progress,
    super.child,
  });

  final ui.Image? snapshot;
  final Size? snapshotSize;
  final Animation<double> progress;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderThemeCrossFade(
        snapshot: snapshot,
        snapshotSize: snapshotSize,
        progress: progress,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderThemeCrossFade renderObject,
  ) {
    renderObject
      ..snapshot = snapshot
      ..snapshotSize = snapshotSize
      ..progress = progress;
  }
}

class _RenderThemeCrossFade extends RenderProxyBox {
  _RenderThemeCrossFade({
    ui.Image? snapshot,
    Size? snapshotSize,
    required Animation<double> progress,
  }) : _snapshot = snapshot,
       _snapshotSize = snapshotSize,
       _progress = progress;

  @override
  bool get isRepaintBoundary => true;

  ui.Image? _snapshot;

  set snapshot(ui.Image? value) {
    if (identical(value, _snapshot)) {
      return;
    }
    _snapshot = value;
    markNeedsPaint();
  }

  Size? _snapshotSize;

  set snapshotSize(Size? value) {
    _snapshotSize = value;
  }

  Animation<double> _progress;

  set progress(Animation<double> value) {
    if (identical(value, _progress)) {
      return;
    }
    if (attached) {
      _progress.removeListener(markNeedsPaint);
      value.addListener(markNeedsPaint);
    }
    _progress = value;
    markNeedsPaint();
  }

  /// The frame on screen, fade included.
  ///
  /// The layer still holds it while the next frame builds; toImageSync
  /// asserts against a boundary that already needs paint.
  ui.Image? capture(double pixelRatio) {
    final layer = this.layer;
    if (!attached || !hasSize || layer is! OffsetLayer) {
      return null;
    }
    return layer.toImageSync(Offset.zero & size, pixelRatio: pixelRatio);
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _progress.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _progress.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    final image = _snapshot;
    final weight = 1 - _progress.value;
    if (image == null || weight <= 0 || _snapshotSize != size) {
      return;
    }
    final rect = offset & size;
    final fade = Color.fromRGBO(0, 0, 0, weight);
    // dstOut then plus mixes premultiplied pixels, so a translucent window
    // keeps its opacity through the fade where srcOver would raise it.
    context.canvas
      ..drawRect(
        rect,
        Paint()
          ..blendMode = BlendMode.dstOut
          ..color = fade,
      )
      ..drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        rect,
        Paint()
          ..blendMode = BlendMode.plus
          ..color = fade
          ..filterQuality = FilterQuality.low,
      );
  }
}
