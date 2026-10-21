part of 'liquid_glass.dart';

// A capture shrinks while a sigma of its frost still spans two of its own
// pixels; at one, where g1455 records its regular finish, text under dark glass
// shows blocks. g1455 measured no divisor past _maxDivisor.
const double _captureFrost = 2;
const int _maxDivisor = 8;
const double _maxCaptureSide = 2048;
// The blur of a downscaled capture read linearly, in its own pixels.
const double _captureSoftness = 0.5;
// How far content may paint past the bounds its layer was recorded for.
const double _overflow = 64;
// Impeller keeps the targets of layers and of their blurs by size for a few
// frames: a layer resized as content moves would miss them every frame.
const double _atlasStep = 32;
// Past this many sigmas of its frost a pane takes under 1% of what it reads, so
// one painted there does not raise it a level.
const double _levelReach = 2.5;
const double _heldFrostShare = 0.9;
// Offsets into a pane's mapping, in the order of the shader's uniforms.
const _hazeSample = 10;
const _hazeShare = 18;
const _noHaze = <double>[0, 0, 1, 1, 0, 0, 0, 0];

typedef LiquidGlassCapture = ({
  int snapshots,
  int keptBands,
  List<
    ({
      Rect pane,
      Rect slot,
      Rect place,
      double scale,
      int level,
      ui.Image atlas,
    })
  >
  panes,
});

/// Draws the panes below from one capture of what lies behind them, taken as
/// the frame is composited, in place of each pane reading the backdrop
/// (.agents/architecture.md). Only one may enclose a pane.
class LiquidGlassHost extends StatelessWidget {
  const LiquidGlassHost({
    super.key,
    required this.enabled,
    required this.child,
  });

  final bool enabled;
  final Widget child;

  @visibleForTesting
  static LiquidGlassCapture? debugLastCapture;

  @visibleForTesting
  static bool? debugCarryBandsOverride;

  /// How many panes hold a capture, under a host or not.
  @visibleForTesting
  static int get debugHeldCaptures => _LiquidGlassLayer._capturesHeld;

  @override
  Widget build(BuildContext context) {
    return _LiquidGlassHostBox(
      enabled: enabled,
      devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
      quality: LiquidGlassScope.qualityOf(context),
      child: child,
    );
  }
}

/// Fades [child] as [FadeTransition] does, but as Core Animation fades a layer:
/// the panes within still bend what lies behind it, and fade with the rest.
class LiquidGlassFade extends SingleChildRenderObjectWidget {
  const LiquidGlassFade({super.key, required this.opacity, super.child});

  final Animation<double> opacity;

  /// [PaintingContext.pushOpacity] for a render object, fading as this does.
  static void push(
    PaintingContext context,
    Offset offset,
    int alpha,
    PaintingContextCallback painter,
  ) {
    context.pushLayer(
      _LiquidGlassFadeLayer()
        ..alpha = alpha
        ..offset = offset,
      painter,
      Offset.zero,
    );
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderLiquidGlassFade(opacity);
  }

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderLiquidGlassFade).opacity = opacity;
  }
}

class _RenderLiquidGlassFade extends RenderProxyBox {
  _RenderLiquidGlassFade(this._opacity);

  final _layer = LayerHandle<_LiquidGlassFadeLayer>();

  Animation<double> _opacity;
  set opacity(Animation<double> value) {
    if (value == _opacity) {
      return;
    }
    if (attached) {
      _opacity.removeListener(markNeedsPaint);
      value.addListener(markNeedsPaint);
    }
    _opacity = value;
    markNeedsPaint();
  }

  int get _alpha =>
      ui.Color.getAlphaFromOpacity(_opacity.value.clamp(0.0, 1.0));

  @override
  bool get alwaysNeedsCompositing => child != null;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _opacity.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _opacity.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void dispose() {
    _layer.layer = null;
    super.dispose();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final alpha = _alpha;
    if (child == null || alpha == 0) {
      _layer.layer = null;
      return;
    }
    final layer = _layer.layer ??= _LiquidGlassFadeLayer();
    layer
      ..alpha = alpha
      ..offset = offset;
    context.pushLayer(layer, super.paint, Offset.zero);
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    if (_alpha != 0) {
      super.visitChildrenForSemantics(visitor);
    }
  }
}

class _LiquidGlassFadeLayer extends OpacityLayer {}

class _LiquidGlassHostBox extends SingleChildRenderObjectWidget {
  const _LiquidGlassHostBox({
    required this.enabled,
    required this.devicePixelRatio,
    required this.quality,
    super.child,
  });

  final bool enabled;
  final double devicePixelRatio;
  final LiquidGlassQuality quality;

  @override
  _RenderLiquidGlassHost createRenderObject(BuildContext context) {
    return _RenderLiquidGlassHost(
      enabled: enabled,
      devicePixelRatio: devicePixelRatio,
      quality: quality,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderLiquidGlassHost renderObject,
  ) {
    renderObject
      ..enabled = enabled
      ..devicePixelRatio = devicePixelRatio
      ..quality = quality;
  }
}

class _RenderLiquidGlassHost extends RenderProxyBox {
  _RenderLiquidGlassHost({
    required bool enabled,
    required double devicePixelRatio,
    required LiquidGlassQuality quality,
  }) : _enabled = enabled,
       _devicePixelRatio = devicePixelRatio,
       _quality = quality;

  final _layer = LayerHandle<_LiquidGlassHostLayer>();

  bool _enabled;
  set enabled(bool value) {
    if (value == _enabled) {
      return;
    }
    _enabled = value;
    markNeedsCompositingBitsUpdate();
    markNeedsPaint();
  }

  double _devicePixelRatio;
  set devicePixelRatio(double value) {
    if (value == _devicePixelRatio) {
      return;
    }
    _devicePixelRatio = value;
    markNeedsPaint();
  }

  LiquidGlassQuality _quality;
  set quality(LiquidGlassQuality value) {
    if (value == _quality) {
      return;
    }
    _quality = value;
    markNeedsPaint();
  }

  @override
  bool get alwaysNeedsCompositing => _enabled;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!_enabled) {
      _release();
      super.paint(context, offset);
      return;
    }
    final layer = _layer.layer ??= _LiquidGlassHostLayer();
    layer
      ..devicePixelRatio = _devicePixelRatio
      ..quality = _quality
      ..bounds = offset & size;
    context.pushLayer(layer, super.paint, offset);
  }

  // A pane captured on a pass still current would keep drawing from it.
  void _release() {
    if (_layer.layer != null) {
      _layer.layer = null;
      _LiquidGlassHostLayer._pass++;
    }
  }

  @override
  void dispose() {
    _release();
    super.dispose();
  }
}

class _LiquidGlassHostLayer extends ContainerLayer {
  static int _pass = 0;

  double devicePixelRatio = 1;
  LiquidGlassQuality quality = LiquidGlassQuality.ultra;
  Rect bounds = Rect.zero;

  final _atlases = <({ui.Image image, List<_Band> bands})>[];

  // A pane that leaves the tree but lives on, as under a route that covers it,
  // would hold the atlas it last drew from until it painted again.
  var _panes = <_LiquidGlassLayer>{};

  @override
  void addToScene(ui.SceneBuilder builder) {
    _capture();
    super.addToScene(builder);
  }

  @override
  void dispose() {
    for (final pane in _panes) {
      pane._dropCaptured();
    }
    _panes = {};
    for (final atlas in _atlases) {
      atlas.image.dispose();
    }
    _atlases.clear();
    super.dispose();
  }

  /// A pane over one painted before it in the same root, but for one of its
  /// own group, sits a level above it, and reads a capture with that one drawn
  /// as glass.
  void _capture() {
    _pass++;
    final found = <_Behind>[];
    _gather(this, Matrix4.identity(), this, Matrix4.identity(), [], found);
    final panes = {for (final entry in found) entry.pane};
    for (final pane in _panes.difference(panes)) {
      pane._dropCaptured();
    }
    _panes = panes;
    final placed = <_Behind>[];
    for (final entry in found) {
      if (_place(entry)) {
        placed.add(entry);
        if (entry.style.haze > 0) {
          final haze = _Behind.hazeOf(entry);
          if (_place(haze)) {
            entry.haze = haze;
          }
        }
      } else {
        entry.pane._captureNothing(_pass);
      }
    }
    var levels = 0;
    for (final (index, entry) in placed.indexed) {
      final group = entry.pane.group;
      for (final before in placed.take(index)) {
        if ((identical(entry.root, this) ||
                before.ancestors.contains(entry.root)) &&
            (group == null || !identical(before.pane.group, group)) &&
            before.device.overlaps(entry.reach)) {
          entry.level = math.max(entry.level, before.level + 1);
        }
      }
      levels = math.max(levels, entry.level + 1);
    }
    var snapshots = 0;
    var keptBands = 0;
    for (var level = 0; level < levels; level++) {
      final members = [
        for (final entry in placed)
          if (entry.level == level) entry,
      ];
      final (:atlas, :taken, :kept) = _snapshot(level, [
        for (final entry in members) ...[entry, ?entry.haze],
      ]);
      if (taken) {
        snapshots++;
        keptBands += kept;
      }
      for (final entry in members) {
        entry.atlas = atlas;
        _publish(entry, atlas);
      }
    }
    while (_atlases.length > levels) {
      _atlases.removeLast().image.dispose();
    }
    assert(() {
      LiquidGlassHost.debugLastCapture = (
        snapshots: snapshots,
        keptBands: keptBands,
        panes: [
          for (final entry in placed)
            (
              pane: entry.device,
              slot: entry.slot,
              place: entry.place,
              scale: entry.texelsPerDp,
              level: entry.level,
              atlas: entry.atlas!,
            ),
        ],
      );
      return true;
    }());
  }

  void _gather(
    ContainerLayer layer,
    Matrix4 toHost,
    ContainerLayer root,
    Matrix4 rootToHost,
    List<ContainerLayer> chain,
    List<_Behind> found,
  ) {
    chain.add(layer);
    for (Layer? child = layer.firstChild; child != null;) {
      switch (child) {
        case final _LiquidGlassLayer pane:
          found.add(
            _Behind(
              pane,
              switch (quality) {
                LiquidGlassQuality.standard => pane.style._standard,
                LiquidGlassQuality.ultra => pane.style,
              },
              toHost,
              root,
              rootToHost,
              chain.toSet(),
            ),
          );
        case final ContainerLayer container:
          final offscreen = _drawsOffscreen(container);
          _gather(
            container,
            _within(container, toHost),
            offscreen ? container : root,
            offscreen ? toHost : rootToHost,
            chain,
            found,
          );
      }
      child = child.nextSibling;
    }
    chain.removeLast();
  }

  /// Snaps the slot to the capture's pixels, so that content holding still
  /// lands on the same ones while the pane moves. A pane with a hold keeps
  /// its slot while it fits inside at no more frost, nor much less, as a
  /// spring settling past its card would need, rather than glass fading.
  bool _place(_Behind entry) {
    final pane = entry.pane;
    final style = entry.style;
    final hazed = entry.hazed;
    final blur = hazed ? style.hazeBlur : style.blur;
    final storage = entry.toHost.storage;
    final stretch = math.max(storage[0].abs(), storage[5].abs());
    final device = entry.device;
    if (stretch == 0 || device.isEmpty || !device.overlaps(bounds)) {
      pane._held = null;
      return false;
    }
    final hold = hazed ? null : pane.hold;
    final sweep = hold == null
        ? device
        : device.expandToInclude(MatrixUtils.transformRect(entry.toHost, hold));
    final bend = math.max(0.0, -style.refraction) + style.dispersion;
    final reach = (3 * (blur + style.rimBlur) + bend + 2) * stretch;
    entry.reach = sweep.inflate(
      (_levelReach * (blur + style.rimBlur) + bend) * stretch,
    );
    final needed = device.inflate(reach).intersect(bounds);
    final covered = sweep.inflate(reach).intersect(bounds);
    final longest = math.max(covered.width, covered.height) * devicePixelRatio;
    final divisor = math.max(
      math.min(
        _maxDivisor,
        math.max(
          1,
          (blur * stretch * devicePixelRatio / _captureFrost).floor(),
        ),
      ),
      (longest / _maxCaptureSide).ceil(),
    );
    final scale = devicePixelRatio / divisor;
    final frost = blur * stretch * scale;
    final softness = divisor > 1 ? _captureSoftness : 0.0;
    final blurSigma = frost > softness
        ? math.sqrt(frost * frost - softness * softness)
        : 0.0;
    final held = pane._held;
    final _Placement placement;
    if (hold != null &&
        held != null &&
        held.texelsPerDp == scale &&
        held.blurSigma >= blurSigma &&
        blurSigma >= held.blurSigma * _heldFrostShare &&
        _encloses(held.slot, needed)) {
      placement = held;
    } else {
      final left = (covered.left * scale).floorToDouble();
      final top = (covered.top * scale).floorToDouble();
      final right = (covered.right * scale).ceilToDouble();
      final bottom = (covered.bottom * scale).ceilToDouble();
      placement = (
        slot: Rect.fromLTRB(
          left / scale,
          top / scale,
          right / scale,
          bottom / scale,
        ),
        texels: Size(right - left, bottom - top),
        texelsPerDp: scale,
        heldFrost: math.max(frost, softness),
        blurSigma: blurSigma,
      );
    }
    if (!hazed) {
      pane._held = hold == null ? null : placement;
    }
    entry
      ..texelsPerDp = placement.texelsPerDp
      ..heldFrost = placement.heldFrost
      ..blurSigma = placement.blurSigma
      ..slot = placement.slot
      ..texels = placement.texels;
    return true;
  }

  ({ui.Image atlas, bool taken, int kept}) _snapshot(
    int level,
    List<_Behind> members,
  ) {
    // Slots that blur alike lie together, under one layer that blurs them;
    // one that does not blur lies alone, so it is kept or drawn on its own.
    final classes = <Object, List<_Behind>>{};
    for (final entry in members) {
      (classes[entry.blurSigma == 0 ? entry : entry.blurSigma] ??= []).add(
        entry,
      );
    }
    double step(double extent) => (extent / _atlasStep).ceil() * _atlasStep;
    final bands = <_Band>[];
    final pictures = <ui.Picture>[];
    var top = 0.0;
    for (final entries in classes.values) {
      var bottom = 0.0;
      var width = 0.0;
      for (final entry in entries) {
        entry.place = Offset(0, top + bottom) & entry.texels;
        bottom += entry.texels.height;
        width = math.max(width, entry.texels.width);
      }
      final rect = Rect.fromLTWH(0, top, step(width), step(bottom));
      final sigma = entries.first.blurSigma;
      final drawn = <Object?>[sigma, rect.size];
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      for (final entry in entries) {
        final place = entry.place.shift(-rect.topLeft);
        drawn
          ..add(place)
          ..add(entry.slot)
          ..addAll(entry.rootToHost.storage);
        canvas
          ..save()
          ..clipRect(place)
          ..translate(place.left, place.top)
          ..scale(entry.texelsPerDp)
          ..translate(-entry.slot.left, -entry.slot.top)
          ..transform(entry.rootToHost.storage);
        _Replay(canvas, drawn, entry).run();
        canvas.restore();
      }
      bands.add((rect: rect, sigma: sigma, drawn: drawn));
      pictures.add(recorder.endRecording());
      top = rect.bottom;
    }
    final size = Size(
      bands.fold(0.0, (width, band) => math.max(width, band.rect.width)),
      top,
    );
    final previous = level < _atlases.length ? _atlases[level] : null;
    final last = previous?.bands ?? const <_Band>[];
    if (previous != null &&
        previous.image.width == size.width &&
        previous.image.height == size.height &&
        last.length == bands.length &&
        bands.indexed.every(
          (band) =>
              band.$2.rect == last[band.$1].rect &&
              listEquals(band.$2.drawn, last[band.$1].drawn),
        )) {
      for (final picture in pictures) {
        picture.dispose();
      }
      return (atlas: previous.image, taken: false, kept: 0);
    }
    // Skia keeps what an image was drawn from for as long as the image lives,
    // so a capture copied from the last would hold every one before it.
    final carry =
        LiquidGlassHost.debugCarryBandsOverride ??
        ui.ImageFilter.isShaderFilterSupported;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    var kept = 0;
    for (final (index, band) in bands.indexed) {
      final picture = pictures[index];
      final old = carry
          ? last.where((old) => listEquals(old.drawn, band.drawn)).firstOrNull
          : null;
      if (old != null) {
        canvas.drawImageRect(
          previous!.image,
          old.rect,
          band.rect,
          Paint()
            ..filterQuality = FilterQuality.none
            ..blendMode = BlendMode.src,
        );
        kept++;
      } else {
        final sigma = band.sigma;
        canvas
          ..save()
          ..clipRect(band.rect);
        if (sigma > 0) {
          canvas.saveLayer(
            band.rect,
            Paint()
              ..imageFilter = ui.ImageFilter.blur(
                sigmaX: sigma,
                sigmaY: sigma,
                tileMode: TileMode.clamp,
              ),
          );
        }
        // Impeller filters a layer under the transform current at its
        // restore (flutter-upgrade.md).
        canvas
          ..save()
          ..translate(band.rect.left, band.rect.top)
          ..drawPicture(picture)
          ..restore();
        if (sigma > 0) {
          canvas.restore();
        }
        canvas.restore();
      }
      picture.dispose();
    }
    final picture = recorder.endRecording();
    final image = picture.toImageSync(size.width.toInt(), size.height.toInt());
    picture.dispose();
    if (previous == null) {
      _atlases.add((image: image, bands: bands));
    } else {
      previous.image.dispose();
      _atlases[level] = (image: image, bands: bands);
    }
    return (atlas: image, taken: true, kept: kept);
  }

  void _publish(_Behind entry, ui.Image atlas) {
    final pane = entry.pane;
    final storage = entry.toHost.storage;
    final haze = entry.haze;
    pane._captureFrom(
      _pass,
      atlas,
      [
        ..._sampling(entry),
        1 / (devicePixelRatio * math.max(storage[0].abs(), storage[5].abs())),
        entry.heldFrost,
        ...haze == null ? _noHaze : _sampling(haze),
        if (haze == null) 0 else entry.style.haze,
      ],
      identical(entry.root, this) ? BlendMode.srcOver : BlendMode.src,
      entry.style,
    );
  }

  List<double> _sampling(_Behind slot) {
    final pane = slot.pane;
    final storage = slot.toHost.storage;
    final place = slot.place;
    final scale = slot.texelsPerDp;
    final texelsPerPaneX = storage[0] * scale;
    final texelsPerPaneY = storage[5] * scale;
    final originX =
        place.left +
        (storage[0] * pane.rect.left + storage[12] - slot.slot.left) * scale;
    final originY =
        place.top +
        (storage[5] * pane.rect.top + storage[13] - slot.slot.top) * scale;
    return [
      -originX / texelsPerPaneX,
      -originY / texelsPerPaneY,
      1 / texelsPerPaneX,
      1 / texelsPerPaneY,
      place.left + 0.5,
      place.top + 0.5,
      place.right - 0.5,
      place.bottom - 0.5,
    ];
  }
}

typedef _Placement = ({
  Rect slot,
  Size texels,
  double texelsPerDp,
  double heldFrost,
  double blurSigma,
});

typedef _Band = ({Rect rect, double sigma, List<Object?> drawn});

bool _encloses(Rect outer, Rect inner) =>
    outer.left <= inner.left &&
    outer.top <= inner.top &&
    outer.right >= inner.right &&
    outer.bottom >= inner.bottom;

class _Behind {
  _Behind(
    this.pane,
    this.style,
    this.toHost,
    this.root,
    this.rootToHost,
    this.ancestors,
  ) : hazed = false;

  _Behind.hazeOf(_Behind owner)
    : pane = owner.pane,
      style = owner.style,
      toHost = owner.toHost,
      root = owner.root,
      rootToHost = owner.rootToHost,
      ancestors = owner.ancestors,
      hazed = true;

  final _LiquidGlassLayer pane;
  final LiquidGlassStyle style;
  final Matrix4 toHost;

  /// The host, or below it the nearest layer that draws offscreen: a backdrop
  /// filter there would read only that layer's texture.
  final ContainerLayer root;
  final Matrix4 rootToHost;
  final Set<ContainerLayer> ancestors;

  /// Captures the backdrop again for the pane's [LiquidGlassStyle.haze].
  final bool hazed;

  late final Rect device = MatrixUtils.transformRect(toHost, pane.rect);

  /// Where a pane painted before this one would show in what it reads.
  Rect reach = Rect.zero;
  Rect slot = Rect.zero;
  double texelsPerDp = 1;
  double heldFrost = 0;
  double blurSigma = 0;
  Size texels = Size.zero;
  Rect place = Rect.zero;
  int level = 0;
  ui.Image? atlas;
  _Behind? haze;
}

/// The transform a layer gives its children, from what it holds now:
/// [Layer.applyTransform] may answer from the frame before.
Matrix4? _geometry(ContainerLayer layer) {
  Matrix4 applied(Layer child) {
    final matrix = Matrix4.identity();
    layer.applyTransform(child, matrix);
    return matrix;
  }

  return switch (layer) {
    TransformLayer(:final transform?, :final offset) =>
      offset == Offset.zero
          ? transform
          : (Matrix4.translationValues(offset.dx, offset.dy, 0)
              ..multiply(transform)),
    OffsetLayer(:final offset) || LeaderLayer(:final offset) =>
      offset == Offset.zero
          ? null
          : Matrix4.translationValues(offset.dx, offset.dy, 0),
    FollowerLayer(:final firstChild?) => applied(firstChild),
    _ => null,
  };
}

Matrix4 _within(ContainerLayer layer, Matrix4 toHost) {
  final geometry = _geometry(layer);
  return geometry == null ? toHost : (toHost.clone()..multiply(geometry));
}

bool _drawsOffscreen(Layer layer) {
  return switch (layer) {
    _LiquidGlassFadeLayer() => false,
    ClipRectLayer(:final clipBehavior) ||
    ClipRRectLayer(:final clipBehavior) ||
    ClipRSuperellipseLayer(:final clipBehavior) ||
    ClipPathLayer(
      :final clipBehavior,
    ) => clipBehavior == Clip.antiAliasWithSaveLayer,
    OpacityLayer(:final alpha) => alpha != null && alpha < 255,
    ColorFilterLayer() ||
    ImageFilterLayer() ||
    ShaderMaskLayer() ||
    BackdropFilterLayer() => true,
    _ => false,
  };
}

/// Redraws onto a capture what a pane's root holds below the pane, as the
/// engine composites it, but for the root's own effect, which the engine
/// applies to the glass as well.
class _Replay {
  _Replay(this.canvas, this.drawn, this.entry) : _toHost = [entry.rootToHost];

  final Canvas canvas;
  final List<Object?> drawn;
  final _Behind entry;
  final List<Matrix4> _toHost;

  // A layer's effects are applied only once something under it draws.
  final _entered = <(ContainerLayer, Matrix4?, bool)>[];
  final _saves = <int>[];

  void run() => _walk(entry.root, root: true);

  bool _walk(ContainerLayer layer, {required bool root}) {
    if (!root && !entry.ancestors.contains(layer) && !_mayShow(layer)) {
      return false;
    }
    final geometry = _geometry(layer);
    final outer = _toHost.last;
    _toHost.add(geometry == null ? outer : (outer.clone()..multiply(geometry)));
    _entered.add((layer, geometry, root));
    var reached = false;
    for (Layer? child = layer.firstChild; child != null && !reached;) {
      switch (child) {
        case _ when identical(child, entry.pane):
          reached = true;
        case final _LiquidGlassLayer pane
            when pane._capturedPass == _LiquidGlassHostLayer._pass:
          if (pane._captured case final picture? when _shows(pane.rect)) {
            _draw(picture);
          }
        case final PictureLayer recorded:
          if (recorded.picture case final picture?
              when _shows(recorded.canvasBounds.inflate(_overflow))) {
            _draw(picture);
          }
        case final ContainerLayer container:
          reached = _walk(container, root: false);
      }
      child = child.nextSibling;
    }
    _leave();
    _toHost.removeLast();
    return reached;
  }

  bool _mayShow(ContainerLayer layer) {
    if (layer is OpacityLayer && layer.alpha == 0) {
      return false;
    }
    final clip = layer.describeClipBounds();
    return clip == null || _shows(clip);
  }

  bool _shows(Rect bounds) =>
      MatrixUtils.transformRect(_toHost.last, bounds).overlaps(entry.slot);

  void _draw(ui.Picture picture) {
    while (_saves.length < _entered.length) {
      _saves.add(_apply(_entered[_saves.length]));
    }
    canvas.drawPicture(picture);
    drawn.add(picture);
  }

  int _apply((ContainerLayer, Matrix4?, bool) entered) {
    final (layer, geometry, root) = entered;
    var saves = 0;
    if (geometry != null) {
      canvas
        ..save()
        ..transform(geometry.storage);
      drawn.addAll(geometry.storage);
      saves++;
    }
    final effect = root
        ? null
        : switch (layer) {
            OpacityLayer(:final alpha?) when alpha < 255 => (
              Paint()..color = Color.fromARGB(alpha, 0, 0, 0),
              alpha,
            ),
            ColorFilterLayer(:final colorFilter?) => (
              Paint()..colorFilter = colorFilter,
              colorFilter,
            ),
            ImageFilterLayer(:final imageFilter?) => (
              Paint()..imageFilter = imageFilter,
              imageFilter,
            ),
            ShaderMaskLayer(:final shader) => (Paint(), shader),
            _ => null,
          };
    if (effect case (final paint, final key)?) {
      canvas.saveLayer(null, paint);
      drawn
        ..add(layer.runtimeType)
        ..add(key);
      saves++;
    }
    if (_clip(layer)) {
      saves++;
    }
    return saves;
  }

  bool _clip(ContainerLayer layer) {
    final Object clip;
    switch (layer) {
      case ClipRectLayer(:final clipRect?, :final clipBehavior)
          when clipBehavior != Clip.none:
        canvas
          ..save()
          ..clipRect(clipRect, doAntiAlias: clipBehavior != Clip.hardEdge);
        clip = clipRect;
      case ClipRSuperellipseLayer(
            :final clipRSuperellipse?,
            :final clipBehavior,
          )
          when clipBehavior != Clip.none:
        canvas
          ..save()
          ..clipRSuperellipse(
            clipRSuperellipse,
            doAntiAlias: clipBehavior != Clip.hardEdge,
          );
        clip = clipRSuperellipse;
      case ClipPathLayer(:final clipPath?, :final clipBehavior)
          when clipBehavior != Clip.none:
        canvas
          ..save()
          ..clipPath(clipPath, doAntiAlias: clipBehavior != Clip.hardEdge);
        clip = clipPath;
      default:
        // Lib clips to no rounded rect, so one a package draws clips by its
        // bounds here.
        final bounds = layer.describeClipBounds();
        if (bounds == null) {
          return false;
        }
        canvas
          ..save()
          ..clipRect(bounds);
        clip = bounds;
    }
    drawn.add(clip);
    return true;
  }

  void _leave() {
    final (layer, _, root) = _entered.removeLast();
    if (_saves.length <= _entered.length) {
      return;
    }
    final saves = _saves.removeLast();
    if (layer case ShaderMaskLayer(
      :final shader?,
      :final maskRect?,
      :final blendMode?,
    ) when !root) {
      canvas
        ..translate(maskRect.left, maskRect.top)
        ..drawRect(
          Offset.zero & maskRect.size,
          Paint()
            ..shader = shader
            ..blendMode = blendMode,
        );
      drawn
        ..add(maskRect)
        ..add(blendMode);
    }
    for (var index = 0; index < saves; index++) {
      canvas.restore();
    }
    drawn.add(saves);
  }
}
