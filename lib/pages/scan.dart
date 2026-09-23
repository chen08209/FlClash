import 'dart:async';
import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/activate_box.dart';
import 'package:fl_clash/widgets/null_status.dart';
import 'package:fl_clash/widgets/scaffold.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

const _systemUiOverlayStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
  systemNavigationBarColor: Colors.transparent,
  systemNavigationBarDividerColor: Colors.transparent,
  systemNavigationBarIconBrightness: Brightness.light,
  systemNavigationBarContrastEnforced: false,
);

const _invalidHintDuration = Duration(seconds: 2);

class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key});

  @override
  ConsumerState<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final _controller = MobileScannerController(
    autoStart: false,
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );

  late final AnimationController _effectController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4800),
  );

  final _invalidHint = ValueNotifier<bool>(false);

  StreamSubscription<BarcodeCapture>? _subscription;
  Timer? _invalidHintTimer;
  bool _disableAnimations = false;
  bool _completed = false;
  bool _picking = false;
  bool _restartAfterSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller.addListener(_syncEffect);
    _subscription = _controller.barcodes.listen(
      _handleCapture,
      onError: _handleDetectError,
    );
    unawaited(_start());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _disableAnimations = context.disableAnimations;
    _syncEffect();
  }

  void _syncEffect() {
    if (_disableAnimations || _controller.value.error != null) {
      _effectController.stop();
    } else if (!_effectController.isAnimating) {
      _effectController.repeat();
    }
  }

  // The permission dialog makes Android report `inactive` then `resumed` while
  // the first start is still pending, and a second `start` would throw.
  Future<void> _start() async {
    final state = _controller.value;
    if (_completed || state.isStarting || state.isRunning) {
      return;
    }
    try {
      await _controller.start();
    } on MobileScannerException catch (error) {
      if (mounted) {
        commonPrint.log(
          'Failed to start the scanner: ${compactError(error)}',
          logLevel: LogLevel.warning,
        );
      }
    }
  }

  void _handleCapture(BarcodeCapture capture) {
    if (_completed || !mounted || capture.barcodes.isEmpty) {
      return;
    }
    final url = profileUrlFromQrCodes(
      capture.barcodes.map((barcode) => barcode.rawValue),
    );
    if (url == null) {
      _showInvalidHint();
      return;
    }
    _complete(url);
  }

  void _handleDetectError(Object error) {
    commonPrint.log(
      'QR code detection failed: ${compactError(error)}',
      logLevel: LogLevel.warning,
    );
  }

  void _showInvalidHint() {
    _invalidHintTimer?.cancel();
    _invalidHint.value = true;
    _invalidHintTimer = Timer(_invalidHintDuration, () {
      _invalidHint.value = false;
    });
  }

  // The page stays mounted through its exit transition, so a second capture
  // arriving then would pop the route underneath it.
  void _complete(String url) {
    _completed = true;
    unawaited(_subscription?.cancel());
    _subscription = null;
    Navigator.of(context).pop<String>(url);
  }

  Future<void> _pickFromAlbum() async {
    if (_picking || _completed) {
      return;
    }
    _picking = true;
    try {
      final url = await globalState.safeRun(picker.pickerConfigQRCode);
      if (url != null && mounted && !_completed) {
        _complete(url);
      }
    } finally {
      _picking = false;
    }
  }

  void _openAppSettings() {
    _restartAfterSettings = true;
    unawaited(app?.openAppSettings());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        // Retrying a denied permission on every resume would reopen the
        // system dialog as soon as the user dismisses it.
        final denied =
            _controller.value.error?.errorCode ==
            MobileScannerErrorCode.permissionDenied;
        final restart = !denied || _restartAfterSettings;
        _restartAfterSettings = false;
        if (restart) {
          unawaited(_start());
        }
      case AppLifecycleState.inactive:
        unawaited(_controller.stop());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ref.watch(genColorSchemeProvider(Brightness.dark)),
    ).withAppShapes;
    final appLocalizations = context.appLocalizations;
    return Theme(
      data: theme,
      // `Theme` inserts no `IconTheme`, and `IconButton.filled` treats the
      // app's light one as a custom color that overrides its defaults.
      child: IconTheme(
        data: theme.iconTheme,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: _systemUiOverlayStyle,
          sized: false,
          child: Scaffold(
            body: LayoutBuilder(
              builder: (context, constraints) {
                final hintStyle = Theme.of(context).textTheme.bodyMedium!;
                final layout = _ScanLayout(
                  size: constraints.biggest,
                  padding: MediaQuery.paddingOf(context),
                  hintHeight:
                      MediaQuery.textScalerOf(
                        context,
                      ).scale(hintStyle.fontSize!) *
                      hintStyle.height! *
                      _hintMaxLines,
                );
                return Stack(
                  children: [
                    Positioned.fill(
                      child: MobileScanner(
                        controller: _controller,
                        scanWindow: layout.scanWindow,
                        errorBuilder: (_, _) => const SizedBox.shrink(),
                      ),
                    ),
                    Positioned.fill(
                      child: ValueListenableBuilder<MobileScannerState>(
                        valueListenable: _controller,
                        builder: (context, state, _) {
                          final error = state.error;
                          if (error != null) {
                            return _ScannerError(
                              errorCode: error.errorCode,
                              onRetry: _start,
                              onOpenSettings: _openAppSettings,
                            );
                          }
                          return _buildScanFrame(theme, layout, hintStyle);
                        },
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: AppBar(
                        backgroundColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                        automaticallyImplyLeading: false,
                        leading: IconButton(
                          tooltip: appLocalizations.close,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const GlyphIcon(AppGlyphs.close),
                        ),
                        actions: genActions([
                          IconButton(
                            tooltip: appLocalizations.pickFromAlbum,
                            onPressed: _pickFromAlbum,
                            icon: const GlyphIcon(AppGlyphs.photos),
                          ),
                        ], edge: AppBarActionEdge.icon),
                      ),
                    ),
                    Positioned.fromRect(
                      rect: layout.torch,
                      child: _TorchButton(controller: _controller),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScanFrame(
    ThemeData theme,
    _ScanLayout layout,
    TextStyle hintStyle,
  ) {
    final colorScheme = theme.colorScheme;
    final scanWindow = layout.scanWindow;
    final borderRadius = AppCorner.fit(scanWindow.width);
    final appLocalizations = context.appLocalizations;
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: ScannerOverlay(
              scanWindow: scanWindow,
              borderRadius: borderRadius,
              color: colorScheme.scrim.opacity60,
            ),
          ),
        ),
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _ScanEffectPainter(
                animation: _effectController,
                scanWindow: scanWindow,
                borderRadius: borderRadius,
                color: colorScheme.primary,
                highlight: colorScheme.primaryFixed,
                contrast: colorScheme.inversePrimary,
              ),
            ),
          ),
        ),
        Positioned.fromRect(
          rect: layout.hint,
          child: ValueListenableBuilder<bool>(
            valueListenable: _invalidHint,
            builder: (context, invalid, _) => Semantics(
              liveRegion: true,
              child: Text(
                invalid
                    ? appLocalizations.invalidProfileQrcode
                    : appLocalizations.qrcodeDesc,
                textAlign: TextAlign.center,
                maxLines: _hintMaxLines,
                overflow: TextOverflow.ellipsis,
                style: hintStyle.copyWith(
                  color: invalid
                      ? colorScheme.error
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // `StatefulElement.unmount` asserts that `super.dispose()` already ran by the
  // time `dispose()` returns, so nothing here may await first: the controller is
  // torn down in the background instead.
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _invalidHintTimer?.cancel();
    unawaited(_subscription?.cancel());
    _subscription = null;
    _controller.removeListener(_syncEffect);
    unawaited(_controller.dispose());
    _effectController.dispose();
    _invalidHint.dispose();
    super.dispose();
  }
}

const _scanWindowMaxSide = 400.0;
const _scanWindowShortestSideRatio = 0.67;
const _hintGap = 24.0;
const _hintInset = 32.0;
const _hintMaxLines = 2;
const _torchSize = 64.0;
const _torchBottomMargin = 48.0;
const _torchSideMargin = 24.0;
const _controlGap = 16.0;
const _edgeMargin = 16.0;

class _ScanLayout {
  const _ScanLayout._({
    required this.scanWindow,
    required this.hint,
    required this.torch,
  });

  // Short viewports, landscape or split screen, cannot stack the window, its
  // hint and the torch vertically, so the torch moves beside the window there.
  factory _ScanLayout({
    required Size size,
    required EdgeInsets padding,
    required double hintHeight,
  }) {
    final below = _ScanLayout._torchBelow(size, padding, hintHeight);
    final beside = _ScanLayout._torchBeside(size, padding, hintHeight);
    return beside.scanWindow.width > below.scanWindow.width ? beside : below;
  }

  factory _ScanLayout._torchBelow(
    Size size,
    EdgeInsets padding,
    double hintHeight,
  ) {
    final torchTop =
        size.height - max(padding.bottom, _torchBottomMargin) - _torchSize;
    final scanWindow = _fitScanWindow(
      size: size,
      top: padding.top + kToolbarHeight,
      bottom: torchTop - _controlGap - _hintGap - hintHeight,
      maxWidth: size.width,
    );
    return _ScanLayout._(
      scanWindow: scanWindow,
      hint: Rect.fromLTWH(
        padding.left + _hintInset,
        scanWindow.bottom + _hintGap,
        max(0, size.width - padding.horizontal - 2 * _hintInset),
        hintHeight,
      ),
      torch: Rect.fromLTWH(
        padding.left + (size.width - padding.horizontal - _torchSize) / 2,
        torchTop,
        _torchSize,
        _torchSize,
      ),
    );
  }

  factory _ScanLayout._torchBeside(
    Size size,
    EdgeInsets padding,
    double hintHeight,
  ) {
    final inset =
        max(padding.left, padding.right) +
        _torchSideMargin +
        _torchSize +
        _controlGap;
    final scanWindow = _fitScanWindow(
      size: size,
      top: padding.top + _edgeMargin,
      bottom:
          size.height -
          max(padding.bottom, _edgeMargin) -
          _hintGap -
          hintHeight,
      maxWidth: size.width - 2 * inset,
    );
    final torch = Rect.fromLTWH(
      size.width - padding.right - _torchSideMargin - _torchSize,
      max(padding.top + kToolbarHeight, scanWindow.center.dy - _torchSize / 2),
      _torchSize,
      _torchSize,
    );
    final hintTop = scanWindow.bottom + _hintGap;
    final hintInset = torch.bottom <= hintTop
        ? max(padding.left, padding.right) + _hintInset
        : inset;
    return _ScanLayout._(
      scanWindow: scanWindow,
      hint: Rect.fromLTWH(
        hintInset,
        hintTop,
        max(0, size.width - 2 * hintInset),
        hintHeight,
      ),
      torch: torch,
    );
  }

  final Rect scanWindow;
  final Rect hint;
  final Rect torch;

  static Rect _fitScanWindow({
    required Size size,
    required double top,
    required double bottom,
    required double maxWidth,
  }) {
    final side = max(
      0.0,
      [
        _scanWindowMaxSide,
        size.shortestSide * _scanWindowShortestSideRatio,
        bottom - top,
        maxWidth,
      ].reduce(min),
    );
    final centerY = max(
      top + side / 2,
      min(size.height / 2, bottom - side / 2),
    );
    return Rect.fromCenter(
      center: Offset(size.width / 2, centerY),
      width: side,
      height: side,
    );
  }
}

class _ScannerError extends StatelessWidget {
  const _ScannerError({
    required this.errorCode,
    required this.onRetry,
    required this.onOpenSettings,
  });

  final MobileScannerErrorCode errorCode;
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final status = switch (errorCode) {
      MobileScannerErrorCode.permissionDenied => NullStatus(
        label: appLocalizations.cameraPermissionRequired,
        description: appLocalizations.cameraPermissionDesc,
        illustration: NullStatusIllustration.permission,
        action: FilledButton.tonalIcon(
          onPressed: onOpenSettings,
          icon: const GlyphIcon(AppGlyphs.settings, fill: 1),
          label: Text(appLocalizations.settings),
        ),
      ),
      MobileScannerErrorCode.unsupported => NullStatus(
        label: appLocalizations.cameraUnavailable,
        illustration: NullStatusIllustration.camera,
      ),
      _ => NullStatus(
        label: appLocalizations.cameraUnavailable,
        illustration: NullStatusIllustration.camera,
        action: FilledButton.tonalIcon(
          onPressed: onRetry,
          icon: const GlyphIcon(AppGlyphs.refresh, fill: 1),
          label: Text(appLocalizations.retry),
        ),
      ),
    };
    final padding =
        MediaQuery.paddingOf(context) +
        const EdgeInsets.only(top: kToolbarHeight);
    // `NullStatus` wraps into a second column once its height is bounded
    // below its content, so a short viewport scrolls it instead.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: max(0, constraints.maxHeight - padding.vertical),
          ),
          child: status,
        ),
      ),
    );
  }
}

class _TorchButton extends StatelessWidget {
  const _TorchButton({required this.controller});

  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MobileScannerState>(
      valueListenable: controller,
      builder: (context, state, _) {
        final torchState = state.torchState;
        final available = torchState != TorchState.unavailable;
        final lit =
            torchState == TorchState.on || torchState == TorchState.auto;
        return ActivateBox(
          active: available,
          child: AnimatedOpacity(
            opacity: available ? 1 : 0,
            duration: kThemeAnimationDuration,
            child: IconButton.filled(
              tooltip: context.appLocalizations.torch,
              isSelected: lit,
              iconSize: 32,
              style: IconButton.styleFrom(fixedSize: const Size.square(64)),
              onPressed: controller.toggleTorch,
              icon: const GlyphIcon(AppGlyphs.torchOff, fill: 1),
              selectedIcon: GlyphIcon(
                torchState == TorchState.auto
                    ? AppGlyphs.torchAuto
                    : AppGlyphs.torch,
                fill: 1,
              ),
            ),
          ),
        );
      },
    );
  }
}

class ScannerOverlay extends CustomPainter {
  const ScannerOverlay({
    required this.scanWindow,
    required this.color,
    this.borderRadius = AppCorner.md,
  });

  final Rect scanWindow;
  final Color color;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()..addRect(Rect.largest);

    final cutoutPath = Path()
      ..addRSuperellipse(
        RSuperellipse.fromRectAndRadius(
          scanWindow,
          Radius.circular(borderRadius),
        ),
      );

    final backgroundPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    canvas.drawPath(backgroundWithCutout, backgroundPaint);
  }

  @override
  bool shouldRepaint(ScannerOverlay oldDelegate) {
    return scanWindow != oldDelegate.scanWindow ||
        color != oldDelegate.color ||
        borderRadius != oldDelegate.borderRadius;
  }
}

class _ScanEffectPainter extends CustomPainter {
  _ScanEffectPainter({
    required this.animation,
    required this.scanWindow,
    required this.borderRadius,
    required this.color,
    required this.highlight,
    required this.contrast,
  }) : super(repaint: animation);

  static const _sweepsPerCycle = 2;
  static const _gridCells = 18;

  final Animation<double> animation;
  final Rect scanWindow;
  final double borderRadius;
  final Color color;
  final Color highlight;
  final Color contrast;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final window = RSuperellipse.fromRectAndRadius(
      scanWindow,
      Radius.circular(borderRadius),
    );
    _paintBorder(canvas, window, t);
    canvas.save();
    canvas.clipRSuperellipse(window);
    _paintBeam(canvas, t);
    canvas.restore();
  }

  void _paintBorder(Canvas canvas, RSuperellipse window, double t) {
    Shader comet(Color tail, Color head) => SweepGradient(
      colors: [tail, tail, head, tail],
      stops: const [0, 0.55, 0.9, 1],
      transform: GradientRotation(2 * pi * t),
    ).createShader(scanWindow);
    canvas.drawRSuperellipse(
      window,
      Paint()
        ..shader = comet(contrast.opacity0, contrast)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawRSuperellipse(
      window,
      Paint()
        ..shader = comet(color, highlight)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  void _paintBeam(Canvas canvas, double t) {
    final sweep = (t * _sweepsPerCycle) % 1;
    final opacity = sweep < 0.1
        ? sweep / 0.1
        : sweep > 0.85
        ? (1 - sweep) / 0.15
        : 1.0;
    if (opacity <= 0) {
      return;
    }
    final y =
        scanWindow.top + scanWindow.height * Curves.easeInOut.transform(sweep);
    final trail = Rect.fromLTRB(
      scanWindow.left,
      max(scanWindow.top, y - scanWindow.height * 0.45),
      scanWindow.right,
      y,
    );
    if (trail.height > 0) {
      canvas.saveLayer(trail, Paint());
      canvas.drawRect(
        trail,
        Paint()..shader = _edgeFadeShader(trail, contrast, opacity * 0.24),
      );
      canvas.drawPath(
        _gridPath(trail),
        Paint()
          ..shader = _edgeFadeShader(trail, contrast, opacity * 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      canvas.drawRect(
        trail,
        Paint()
          ..blendMode = BlendMode.dstIn
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black],
          ).createShader(trail),
      );
      canvas.restore();
    }
    final line = Rect.fromCenter(
      center: Offset(scanWindow.center.dx, y),
      width: scanWindow.width,
      height: 3,
    );
    canvas.drawRect(
      line.inflate(4),
      Paint()
        ..shader = _edgeFadeShader(line, contrast, opacity * 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawRect(
      line,
      Paint()..shader = _edgeFadeShader(line, color, opacity),
    );
    canvas.drawRect(
      Rect.fromCenter(center: line.center, width: line.width, height: 1),
      Paint()..shader = _edgeFadeShader(line, highlight, opacity),
    );
  }

  Shader _edgeFadeShader(Rect rect, Color color, double opacity) {
    const stops = 12;
    return LinearGradient(
      colors: [
        for (var i = 0; i <= stops; i++)
          color.withValues(alpha: opacity * sin(pi * i / stops)),
      ],
    ).createShader(rect);
  }

  Path _gridPath(Rect trail) {
    final cell = scanWindow.width / _gridCells;
    final path = Path();
    for (var x = scanWindow.left; x <= scanWindow.right; x += cell) {
      path
        ..moveTo(x, trail.top)
        ..lineTo(x, trail.bottom);
    }
    final firstRow = ((trail.top - scanWindow.top) / cell).ceil();
    for (
      var y = scanWindow.top + firstRow * cell;
      y <= trail.bottom;
      y += cell
    ) {
      path
        ..moveTo(trail.left, y)
        ..lineTo(trail.right, y);
    }
    return path;
  }

  @override
  bool shouldRepaint(_ScanEffectPainter oldDelegate) {
    return animation != oldDelegate.animation ||
        scanWindow != oldDelegate.scanWindow ||
        borderRadius != oldDelegate.borderRadius ||
        color != oldDelegate.color ||
        highlight != oldDelegate.highlight;
  }
}
