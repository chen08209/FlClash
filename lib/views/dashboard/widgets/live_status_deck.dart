import 'dart:async';
import 'dart:math' as math;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/features.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/mitm.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prism_ui/prism_ui.dart';

import 'card.dart';
import 'live_status.dart';

const _cardHeight = 300.0;
const _cardSize = Size(320, _cardHeight);
const _cardInset = 8.0;
const _heroHeight = 156.0;
const _heroCorner = AppCorner.alert - _cardInset;
const _actionHeight = 44.0;
const _textTop = 12.0;
const _actionBottom = 4.0;
const _bottomHeight = _cardHeight - _cardInset * 2 - _heroHeight;
const _anchorGap = 8.0;
const _windowEdge = 16.0;
// Room above the front card for the cards behind it to show.
const _stackRise = 48.0;
const _rightGutter = 24.0;
const _dragExtent = 220.0;
const _flipDistance = 60.0;
const _flipVelocity = 700.0;
const _overscroll = 0.3;
const _settleDuration = Duration(milliseconds: 460);
const _settleCurve = Cubic(0.2, 0.9, 0.25, 1);
const _wheelInterval = Duration(milliseconds: 350);
const _labelFade = Duration(milliseconds: 160);
const _askDuration = Duration(milliseconds: 200);
const _askGap = 8.0;

typedef _Pose = ({
  double x,
  double y,
  double z,
  double tilt,
  double turn,
  double opacity,
});

typedef _Slot = ({_Pose pose, double depth});

// Positions -1 (swiped away) to 3, in the design's CSS frame: z points at the
// viewer and a positive tilt leans the top away.
const List<_Pose> _poses = [
  (x: 0, y: 110, z: 80, tilt: -14, turn: 0, opacity: 0),
  (x: 0, y: 0, z: 0, tilt: 0, turn: 0, opacity: 1),
  (x: -10, y: -44, z: -70, tilt: 14, turn: 8, opacity: 1),
  (x: 10, y: -92, z: -140, tilt: 24, turn: -8, opacity: 0.85),
  (x: 0, y: -120, z: -220, tilt: 32, turn: 0, opacity: 0),
];

_Pose _lerpPose(_Pose a, _Pose b, double t) {
  double mix(double from, double to) => from + (to - from) * t;
  return (
    x: mix(a.x, b.x),
    y: mix(a.y, b.y),
    z: mix(a.z, b.z),
    tilt: mix(a.tilt, b.tilt),
    turn: mix(a.turn, b.turn),
    opacity: mix(a.opacity, b.opacity),
  );
}

_Pose _faded(_Pose pose) => (
  x: pose.x,
  y: pose.y,
  z: pose.z,
  tilt: pose.tilt,
  turn: pose.turn,
  opacity: 0,
);

_Pose _poseAt(double position) {
  final t = position.clamp(-1.0, 3.0) + 1;
  final i = math.min(t.floor(), _poses.length - 2);
  return _lerpPose(_poses[i], _poses[i + 1], t - i);
}

_Slot _lerpSlot(_Slot a, _Slot b, double t) => (
  pose: _lerpPose(a.pose, b.pose, t),
  depth: a.depth + (b.depth - a.depth) * t,
);

/// A front card leaves as a swipe takes it; one behind fades in place.
_Slot _exitOf(_Slot slot) => slot.depth < 0.5
    ? (pose: _poseAt(-1), depth: -1)
    : (pose: _faded(slot.pose), depth: slot.depth);

bool _isFlat(_Pose pose) =>
    pose.x == 0 &&
    pose.y == 0 &&
    pose.z == 0 &&
    pose.tilt == 0 &&
    pose.turn == 0;

// A negative perspective entry keeps the CSS frame of [_poses].
Matrix4 _transformOf(_Pose pose) => _isFlat(pose)
    ? Matrix4.identity()
    : (Matrix4.identity()
        ..setEntry(3, 2, -0.001)
        ..multiply(Matrix4.translationValues(pose.x, pose.y, pose.z))
        ..rotateX(pose.tilt * math.pi / 180)
        ..rotateY(pose.turn * math.pi / 180));

Rect _frontOf(BuildContext context, Size size, {required Rect anchor}) {
  final padding = MediaQuery.paddingOf(context);
  final width = _cardSize.width;
  final height = _cardSize.height;
  if (ViewScope.isMobileOf(context)) {
    final safe = padding.deflateRect(Offset.zero & size);
    final left = math.min(
      safe.center.dx - width / 2,
      safe.right - width - _rightGutter,
    );
    return Rect.fromLTWH(
      math.max(0, left),
      safe.center.dy - height / 2,
      width,
      height,
    );
  }
  final bottom = size.height - padding.bottom - _windowEdge;
  final top = math.min(
    anchor.bottom + _anchorGap + _stackRise,
    bottom - height,
  );
  return Rect.fromLTWH(
    math.max(0, size.width - _windowEdge - _rightGutter - width),
    math.max(0, top),
    width,
    height,
  );
}

/// Opens the deck with an alert's scrim and motion, grown from its front card.
class LiveStatusRoute extends PopupRoute<void>
    with AlertMotionRouteMixin<void> {
  LiveStatusRoute({
    required this.anchor,
    required this.separateCore,
    required this.barrierColor,
    required this.barrierLabel,
    this.statuses,
  });

  /// The bar button, in the navigator's coordinates.
  final Rect anchor;

  final bool separateCore;

  /// What the deck shows in place of the live statuses.
  final List<LiveStatus>? statuses;

  @override
  final Color barrierColor;

  @override
  final String barrierLabel;

  @override
  bool get barrierDismissible => true;

  @override
  AlertScaleOrigin get scaleOrigin => (context, size) {
    final center = _frontOf(context, size, anchor: anchor).center;
    return Alignment(
      center.dx / size.width * 2 - 1,
      center.dy / size.height * 2 - 1,
    );
  };

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) => LiveStatusDeck(
        separateCore: separateCore,
        statuses: statuses,
        front: _frontOf(context, constraints.biggest, anchor: anchor),
      ),
    );
  }
}

typedef _Placed = ({LiveStatus status, _Slot slot, bool leaving});

/// The live statuses as a stack of cards, the next ones leaning back above the
/// front one. A drag down brings the next card forward and a drag up takes it
/// back; the deck keeps the card it shows while the statuses change under it.
class LiveStatusDeck extends ConsumerStatefulWidget {
  const LiveStatusDeck({
    super.key,
    required this.separateCore,
    required this.front,
    this.statuses,
  });

  final bool separateCore;

  final Rect front;

  final List<LiveStatus>? statuses;

  @override
  ConsumerState<LiveStatusDeck> createState() => _LiveStatusDeckState();
}

class _LiveStatusDeckState extends ConsumerState<LiveStatusDeck>
    with TickerProviderStateMixin {
  late final AnimationController _position = AnimationController.unbounded(
    vsync: this,
  );
  late final AnimationController _reflow = AnimationController(
    vsync: this,
    duration: _settleDuration,
  )..addStatusListener(_onReflowStatus);
  late final Animation<double> _reflowProgress = CurvedAnimation(
    parent: _reflow,
    curve: _settleCurve,
  );
  late final AnimationController _asking = AnimationController(
    vsync: this,
    duration: _askDuration,
  )..addStatusListener(_onAskingStatus);
  late final Animation<double> _askProgress = CurvedAnimation(
    parent: _asking,
    curve: Curves.easeOut,
  );
  List<LiveStatus> _statuses = const [];
  int _count = 0;
  Object? _shownKey;
  Object? _askKey;
  int _target = 0;
  double _dragOrigin = 0;
  double _dragDistance = 0;
  bool _dragging = false;
  bool _closing = false;
  Duration? _lastWheel;

  Map<Object, _Slot>? _reflowFrom;
  List<({LiveStatus status, _Slot from})> _leaving = const [];

  bool get _cycles => _statuses.length > 1;

  bool get _held => _askKey != null;

  int _indexOf(int target) => target % _statuses.length;

  @override
  void dispose() {
    _position.dispose();
    _reflow.dispose();
    _asking.dispose();
    super.dispose();
  }

  void _follow(List<LiveStatus> statuses) {
    if (_statuses.isNotEmpty &&
        statuses.isNotEmpty &&
        !_sameKeys(_statuses, statuses) &&
        !context.disableAnimations) {
      _startReflow(statuses);
    }
    _statuses = statuses;
    if (statuses.isEmpty) {
      _close();
      return;
    }
    if (_askKey != null &&
        !statuses.any((it) => it.key == _askKey && _confirmOf(it) != null)) {
      _askKey = null;
      _asking.value = 0;
    }
    final kept = statuses.indexWhere((status) => status.key == _shownKey);
    final shown = kept >= 0 ? kept : _indexOf(_target);
    _shownKey = statuses[shown].key;
    final recounted = statuses.length != _count;
    _count = statuses.length;
    if (_dragging || shown == _indexOf(_target) && !recounted) return;
    _target = shown;
    _position.value = shown.toDouble();
  }

  static bool _sameKeys(List<LiveStatus> a, List<LiveStatus> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].key != b[i].key) return false;
    }
    return true;
  }

  /// Moves every card on from where it is drawn now, the ones that go too.
  void _startReflow(List<LiveStatus> next) {
    final drawn = _layout();
    final keys = {for (final status in next) status.key};
    _reflowFrom = {for (final it in drawn) it.status.key: it.slot};
    _leaving = [
      for (final it in drawn)
        if (!keys.contains(it.status.key)) (status: it.status, from: it.slot),
    ];
    unawaited(_reflow.forward(from: 0).orCancel.catchError((_) {}));
  }

  void _onReflowStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    setState(() {
      _reflowFrom = null;
      _leaving = const [];
    });
  }

  List<_Placed> _layout() {
    final from = _reflowFrom;
    final t = _reflowProgress.value;
    final position = _position.value;
    _Slot slotAt(int index) {
      final slot = _slotOf(index - position);
      if (from == null) return slot;
      final start =
          from[_statuses[index].key] ??
          (pose: _faded(slot.pose), depth: slot.depth);
      return _lerpSlot(start, slot, t);
    }

    return [
      for (var i = 0; i < _statuses.length; i++)
        (status: _statuses[i], slot: slotAt(i), leaving: false),
      for (final (:status, from: start) in _leaving)
        (
          status: status,
          slot: _lerpSlot(start, _exitOf(start), t),
          leaving: true,
        ),
    ];
  }

  void _close() {
    if (_closing) return;
    _closing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final route = ModalRoute.of(context);
      if (route == null || !route.isActive) return;
      if (route.isCurrent) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).removeRoute(route);
      }
    });
  }

  void _onAskingStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && _askKey != null) {
      setState(() => _askKey = null);
    }
  }

  void _runAsking({required bool forward}) {
    if (context.disableAnimations) {
      _asking.value = forward ? 1 : 0;
    } else if (forward) {
      unawaited(_asking.forward().orCancel.catchError((_) {}));
    } else {
      unawaited(_asking.reverse().orCancel.catchError((_) {}));
    }
  }

  void _ask(Object key) {
    setState(() => _askKey = key);
    _runAsking(forward: true);
  }

  void _unask() {
    setState(() {});
    _runAsking(forward: false);
  }

  void _settle(int index) {
    if (_statuses.isEmpty) return;
    final target = _cycles ? index : 0;
    _target = target;
    _shownKey = _statuses[_indexOf(target)].key;
    if (context.disableAnimations) {
      _position.value = target.toDouble();
      return;
    }
    unawaited(
      _position
          .animateTo(
            target.toDouble(),
            duration: _settleDuration,
            curve: _settleCurve,
          )
          .orCancel
          .catchError((_) {}),
    );
  }

  void _step(int delta) => _settle(_target + delta);

  double _resist(double value) => _cycles ? value : value * _overscroll;

  void _onDragStart(DragStartDetails details) {
    _position.stop();
    _dragging = true;
    _dragOrigin = _target.toDouble();
    _dragDistance = 0;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _dragDistance += details.delta.dy;
    _position.value = _resist(_dragOrigin + _dragDistance / _dragExtent);
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_dragging) return;
    _dragging = false;
    final velocity = details.primaryVelocity ?? 0;
    var target = _dragOrigin.round();
    if (_dragDistance > _flipDistance || velocity > _flipVelocity) {
      target += 1;
    } else if (_dragDistance < -_flipDistance || velocity < -_flipVelocity) {
      target -= 1;
    }
    _settle(target);
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || _held) return;
    GestureBinding.instance.pointerSignalResolver.register(event, (event) {
      final scroll = event as PointerScrollEvent;
      final last = _lastWheel;
      if (last != null && scroll.timeStamp - last < _wheelInterval) return;
      if (scroll.scrollDelta.dy.abs() < 1) return;
      _lastWheel = scroll.timeStamp;
      _step(scroll.scrollDelta.dy > 0 ? 1 : -1);
    });
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (_held || event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _step(1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _step(-1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// Where a card [offset] places from the front sits in the stack. Once the
  /// deck cycles, the card that passes the front leaves forward over the
  /// first half of the step and over the second drops in from one layer
  /// behind the rear, fading in as it settles there.
  _Slot _slotOf(double offset) {
    final count = _statuses.length;
    if (!_cycles) return (pose: _poseAt(offset), depth: offset);
    var wrapped = offset % count;
    if (wrapped > count - 1) wrapped -= count;
    if (wrapped >= 0) return (pose: _poseAt(wrapped), depth: wrapped);
    final passed = -wrapped;
    if (passed <= 0.5) {
      final forward = -passed * 2;
      return (pose: _poseAt(forward), depth: forward);
    }
    final arrived = passed * 2 - 1;
    final depth = count - arrived;
    final pose = _poseAt(depth);
    return (pose: _lerpPose(_faded(pose), pose, arrived), depth: depth);
  }

  @override
  Widget build(BuildContext context) {
    final statuses =
        widget.statuses ??
        watchLiveStatuses(ref, separateCore: widget.separateCore);
    _follow(statuses);
    final colorScheme = context.colorScheme;
    final appLocalizations = context.appLocalizations;
    final fill = SurfaceLevel.floatingOf(colorScheme).colorOf(colorScheme);
    final held = _held;
    final asking = _asking.status.isForwardOrCompleted;
    final cards = <Object, Widget>{
      for (final status in statuses)
        status.key: RepaintBoundary(
          key: ValueKey(status.key),
          child: _StatusCard(
            status: status,
            asking: status.key == _askKey
                ? _askProgress
                : kAlwaysDismissedAnimation,
            confirming: status.key == _askKey && asking,
            onAsk: () => _ask(status.key),
            onUnask: _unask,
          ),
        ),
      for (final (:status, from: _) in _leaving)
        status.key: RepaintBoundary(
          key: ValueKey(status.key),
          child: _StatusCard(
            status: status,
            asking: kAlwaysDismissedAnimation,
            confirming: false,
            onAsk: _inert,
            onUnask: _inert,
          ),
        ),
    };
    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      child: Semantics(
        container: true,
        value: statuses.length > 1
            ? appLocalizations.liveStatusPosition(
                _indexOf(_target) + 1,
                statuses.length,
              )
            : null,
        child: Listener(
          onPointerSignal: _onPointerSignal,
          child: GestureDetector(
            onVerticalDragStart: held ? null : _onDragStart,
            onVerticalDragUpdate: held ? null : _onDragUpdate,
            onVerticalDragEnd: held ? null : _onDragEnd,
            onVerticalDragCancel: held
                ? null
                : () => _onDragEnd(DragEndDetails()),
            child: AnimatedBuilder(
              animation: Listenable.merge([_position, _reflow]),
              builder: (context, _) {
                final placed = _layout()
                  ..sort((a, b) => b.slot.depth.compareTo(a.slot.depth));
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (final (:status, :slot, :leaving) in placed)
                      if (slot.depth > -1 && slot.depth < 3)
                        _placeCard(
                          card: cards[status.key]!,
                          status: status,
                          pose: slot.pose,
                          front: !leaving && slot.depth.abs() < 0.5,
                          fill: fill,
                          shadows: slot.depth < 0.5
                              ? _frontShadows(colorScheme)
                              : _backShadows(colorScheme),
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

  Widget _placeCard({
    required Widget card,
    required LiveStatus status,
    required _Pose pose,
    required bool front,
    required Color fill,
    required List<BoxShadow> shadows,
  }) {
    return Positioned.fromRect(
      key: card.key,
      rect: widget.front,
      child: IgnorePointer(
        ignoring: !front,
        child: Opacity(
          opacity: pose.opacity.clamp(0, 1),
          child: Transform(
            alignment: Alignment.center,
            transform: _transformOf(pose),
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: fill,
                shape: AppShape.all(AppCorner.alert),
                shadows: shadows,
              ),
              child: _LeaningRaster(
                leaning: !_isFlat(pose),
                content: status,
                child: card,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Draws a card that leans from a snapshot, so its text is neither
/// rasterized at a new scale on every frame of a flip nor drawn under a
/// perspective transform, where Impeller has logged glyphs missing from its
/// atlas. A new [content] retakes it.
class _LeaningRaster extends StatefulWidget {
  const _LeaningRaster({
    required this.leaning,
    required this.content,
    required this.child,
  });

  final bool leaning;
  final Object content;
  final Widget child;

  @override
  State<_LeaningRaster> createState() => _LeaningRasterState();
}

class _LeaningRasterState extends State<_LeaningRaster> {
  late final _controller = SnapshotController(
    allowSnapshotting: widget.leaning,
  );

  @override
  void didUpdateWidget(_LeaningRaster oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.content, widget.content)) {
      _controller.allowSnapshotting = false;
    }
    _controller.allowSnapshotting = widget.leaning;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SnapshotWidget(
      controller: _controller,
      mode: SnapshotMode.permissive,
      child: widget.child,
    );
  }
}

List<BoxShadow> _frontShadows(ColorScheme colorScheme) => [
  BoxShadow(
    color: colorScheme.shadow.withValues(alpha: 0.16),
    blurRadius: 40,
    offset: const Offset(0, 16),
  ),
  BoxShadow(
    color: colorScheme.shadow.withValues(alpha: 0.06),
    blurRadius: 6,
    offset: const Offset(0, 2),
  ),
];

List<BoxShadow> _backShadows(ColorScheme colorScheme) => [
  BoxShadow(
    color: colorScheme.shadow.withValues(alpha: 0.08),
    blurRadius: 18,
    offset: const Offset(0, 6),
  ),
];

String _progressText(UpdateDownloading download) {
  final received = download.received.traffic.show;
  if (download.total <= 0) {
    return received;
  }
  return '$received / ${download.total.traffic.show}';
}

String _readyTip(AppLocalizations appLocalizations) => system.isWindows
    ? '${appLocalizations.updateReadyTip}\n${appLocalizations.updateRestartTip}'
    : appLocalizations.updateReadyTip;

/// An action the card asks about in place before it runs.
enum _Confirm { forceRestart, stopDownload }

_Confirm? _confirmOf(LiveStatus status) => switch (status) {
  CoreLiveStatus(phase: CoreStatus.connected) => _Confirm.forceRestart,
  UpdateStatus(download: UpdateDownloading()) => _Confirm.stopDownload,
  _ => null,
};

void _inert() {}

class _StatusCard extends ConsumerWidget {
  const _StatusCard({
    required this.status,
    required this.asking,
    required this.confirming,
    required this.onAsk,
    required this.onUnask,
  });

  final LiveStatus status;

  /// How far the card has turned into asking to confirm its action.
  final Animation<double> asking;

  /// Whether the card is asking or about to, which its button confirms.
  final bool confirming;

  final VoidCallback onAsk;

  final VoidCallback onUnask;

  Future<void> _restartCore(CoreAction core) async {
    try {
      await core.restartCore();
    } catch (error) {
      dialogs.showBanner(error.toString(), level: BannerLevel.error);
    }
  }

  void _install(BuildContext context, WidgetRef ref) {
    final action = ref.read(commonActionProvider.notifier);
    Navigator.of(context).pop();
    unawaited(action.installUpdate());
  }

  /// Asks module by module, each as it stands when its turn comes, until the
  /// card goes or a prompt is dismissed.
  Future<void> _reviewModules(BuildContext context, WidgetRef ref) async {
    final ids = [
      for (final module in ref.read(mitmModulesToAgreeProvider)) module.id,
    ];
    for (final id in ids) {
      if (!context.mounted) {
        return;
      }
      final module = ref
          .read(mitmModulesToAgreeProvider)
          .where((item) => item.id == id)
          .firstOrNull;
      if (module != null && !await answerMitmModule(ref, module)) {
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    final appLocalizations = context.appLocalizations;
    final action = ref.read(commonActionProvider.notifier);
    final level = SurfaceLevel.floatingOf(colorScheme);
    final neutral = level.next.colorOf(colorScheme);
    final core = ref.read(coreActionProvider.notifier);
    final effects = status.preview == null
        ? (
            restartCore: () => unawaited(_restartCore(core)),
            stopDownload: action.cancelUpdateDownload,
            install: () => _install(context, ref),
            discard: () => unawaited(action.discardUpdate()),
            reviewModules: () => unawaited(_reviewModules(context, ref)),
          )
        : (
            restartCore: _inert,
            stopDownload: _inert,
            install: _inert,
            discard: _inert,
            reviewModules: _inert,
          );
    final (
      tint,
      hero,
      title,
      body,
      actionLabel,
      onAction,
      actionColors,
    ) = switch (status) {
      CoreLiveStatus(phase: CoreStatus.disconnected) => (
        colorScheme.errorContainer,
        const _CoreHero(CoreStatus.disconnected),
        appLocalizations.coreStopped,
        (status.preview == null ? ref.watch(coreStopReasonProvider) : null) ??
            appLocalizations.coreStoppedDesc,
        appLocalizations.restartCore,
        effects.restartCore,
        (colorScheme.error, colorScheme.onError),
      ),
      CoreLiveStatus(phase: CoreStatus.connecting) => (
        colorScheme.primaryContainer,
        const _CoreHero(CoreStatus.connecting),
        appLocalizations.coreStarting,
        appLocalizations.coreStartingDesc,
        null,
        null,
        null,
      ),
      CoreLiveStatus() => (
        neutral,
        const _CoreHero(CoreStatus.connected),
        appLocalizations.coreRunning,
        appLocalizations.coreRunningDesc,
        appLocalizations.forceRestartCore,
        onAsk,
        (neutral, colorScheme.onSurface),
      ),
      UpdateStatus(download: final UpdateDownloading download) => (
        colorScheme.primaryContainer,
        _DownloadHero(download: download),
        appLocalizations.downloadingUpdate,
        _progressText(download),
        appLocalizations.cancel,
        onAsk,
        (neutral, colorScheme.onSurface),
      ),
      UpdateStatus(download: final UpdateReady download) => (
        colorScheme.successContainer,
        _ReadyHero(tag: download.tag, onDiscard: effects.discard),
        appLocalizations.updateReady,
        _readyTip(appLocalizations),
        appLocalizations.installUpdate,
        effects.install,
        (colorScheme.success, colorScheme.onSuccess),
      ),
      MitmConsentStatus(:final names) => (
        colorScheme.warningContainer,
        _ConsentHero(names: names),
        appLocalizations.mitmModulesTurnedOff,
        names.length == 1
            ? appLocalizations.mitmModuleTurnedOffDesc(names.single)
            : appLocalizations.mitmModulesTurnedOffDesc(names.length),
        appLocalizations.view,
        effects.reviewModules,
        (colorScheme.warning, colorScheme.onWarning),
      ),
    };
    final ask = switch (_confirmOf(status)) {
      _Confirm.forceRestart => (
        title: appLocalizations.forceRestartCoreAsk,
        body: appLocalizations.forceRestartCoreAskDesc,
        label: appLocalizations.restart,
        run: effects.restartCore,
      ),
      _Confirm.stopDownload => (
        title: appLocalizations.stopUpdateDownloadTip,
        body: appLocalizations.stopUpdateDownloadDesc,
        label: appLocalizations.stopDownload,
        run: effects.stopDownload,
      ),
      null => null,
    };
    final heroBox = DecoratedBox(
      decoration: ShapeDecoration(
        color: tint,
        shape: AppShape.all(_heroCorner),
      ),
      child: hero,
    );
    Widget lines(String title, String body) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.headline.of(context),
        ),
        const SizedBox(height: 2),
        Text(
          body,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.footnote
              .of(context)
              .copyWith(
                color: colorScheme.onSurfaceVariant,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
        ),
      ],
    );
    final restText = lines(title, body);
    final askText = ask == null ? null : lines(ask.title, ask.body);
    ButtonStyle buttonStyle(Color background, Color foreground) =>
        ButtonStyle.from(
          backgroundColor: background,
          foregroundColor: foreground,
          minimumSize: const Size.fromHeight(_actionHeight),
          tapTargetSize: TapTargetSize.shrinkWrap,
          shape: AppShape.full,
        );
    final button = actionLabel != null && actionColors != null
        ? FilledButton(
            onPressed: onAction,
            style: buttonStyle(actionColors.$1, actionColors.$2),
            child: AnimatedSwitcher(
              duration: _labelFade,
              child: Text(actionLabel, key: ValueKey(actionLabel)),
            ),
          )
        : null;
    final askButtons = ask == null
        ? null
        : Row(
            spacing: _askGap,
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onUnask,
                  style: buttonStyle(neutral, colorScheme.onSurface),
                  child: Text(appLocalizations.cancel),
                ),
              ),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    ask.run();
                    onUnask();
                  },
                  style: buttonStyle(colorScheme.error, colorScheme.onError),
                  child: Text(ask.label),
                ),
              ),
            ],
          );
    Widget fade(double asked, Widget rest, Widget? question) {
      if (question == null || asked == 0) return rest;
      return Stack(
        children: [
          IgnorePointer(
            ignoring: confirming,
            child: Opacity(opacity: 1 - asked, child: rest),
          ),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !confirming,
              child: Opacity(opacity: asked, child: question),
            ),
          ),
        ],
      );
    }

    return SurfaceScope(
      level: level,
      child: Padding(
        padding: const EdgeInsets.all(_cardInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: heroBox),
            SizedBox(
              height: _bottomHeight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  8,
                  _textTop,
                  8,
                  _actionBottom,
                ),
                child: AnimatedBuilder(
                  animation: asking,
                  builder: (context, _) {
                    final a = asking.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRect(
                            child: OverflowBox(
                              alignment: AlignmentDirectional.topStart,
                              maxHeight: double.infinity,
                              child: fade(a, restText, askText),
                            ),
                          ),
                        ),
                        if (button != null) fade(a, button, askButtons),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The app and the core, joined by what lies between them now: a broken line
/// when the core stopped, a spinner while it starts, a line once it runs.
class _CoreHero extends StatelessWidget {
  const _CoreHero(this.phase);

  static const _linkWidth = 32.0;

  final CoreStatus phase;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final appLocalizations = context.appLocalizations;
    final nodeFill = SurfaceLevel.floatingOf(colorScheme).colorOf(colorScheme);
    final (labelColor, coreFill, coreColor, coreLabel) = switch (phase) {
      CoreStatus.disconnected => (
        colorScheme.onErrorContainer,
        colorScheme.error,
        colorScheme.onError,
        colorScheme.error,
      ),
      CoreStatus.connecting => (
        colorScheme.onPrimaryContainer,
        nodeFill,
        colorScheme.primary,
        colorScheme.onPrimaryContainer,
      ),
      CoreStatus.connected => (
        colorScheme.onSurfaceVariant,
        colorScheme.success,
        colorScheme.onSuccess,
        colorScheme.success,
      ),
    };
    final link = switch (phase) {
      CoreStatus.disconnected => SizedBox(
        width: _linkWidth,
        height: 2,
        child: CustomPaint(painter: _DashPainter(colorScheme.error)),
      ),
      CoreStatus.connecting => const SizedBox(
        width: _linkWidth,
        child: Center(child: ActivityIndicator(size: 16)),
      ),
      CoreStatus.connected => SizedBox(
        width: _linkWidth,
        height: 2,
        child: ColoredBox(color: colorScheme.success),
      ),
    };
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Node(
            glyph: AppGlyphs.devices,
            label: appLocalizations.app,
            fill: nodeFill,
            color: colorScheme.onSurfaceVariant,
            labelColor: labelColor,
          ),
          Padding(
            padding: EdgeInsets.only(bottom: _Node.labelRoom),
            child: link,
          ),
          _Node(
            glyph: AppGlyphs.cpu,
            label: appLocalizations.core,
            fill: coreFill,
            color: coreColor,
            labelColor: coreLabel,
            emphasized: phase != CoreStatus.connecting,
          ),
        ],
      ),
    );
  }
}

class _Node extends StatelessWidget {
  const _Node({
    required this.glyph,
    required this.label,
    required this.fill,
    required this.color,
    required this.labelColor,
    this.emphasized = false,
  });

  static const size = 44.0;
  static const _labelGap = 6.0;
  static final labelRoom = _labelGap + AppTextStyle.caption1.leading;

  final Glyph glyph;
  final String label;
  final Color fill;
  final Color color;
  final Color labelColor;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: _labelGap,
        children: [
          SizedBox.square(
            dimension: size,
            child: DecoratedBox(
              decoration: ShapeDecoration(color: fill, shape: AppShape.circle),
              child: Center(child: GlyphIcon(glyph, size: 22, color: color)),
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.caption1
                .of(context, emphasized: emphasized)
                .copyWith(color: labelColor),
          ),
        ],
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  const _DashPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const dash = 4.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.height
      ..strokeCap = StrokeCap.round;
    final y = size.height / 2;
    for (var x = dash / 2; x < size.width; x += dash * 2) {
      canvas.drawLine(Offset(x, y), Offset(x + dash / 2, y), paint);
    }
  }

  @override
  bool shouldRepaint(_DashPainter oldDelegate) => oldDelegate.color != color;
}

class _DownloadHero extends StatelessWidget {
  const _DownloadHero({required this.download});

  final UpdateDownloading download;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final total = download.total;
    final value = total > 0 ? download.received / total : null;
    const tabular = [FontFeature.tabularFigures()];
    return Center(
      child: SizedBox.square(
        dimension: 132,
        child: CustomPaint(
          painter: _TicksPainter(
            value: value ?? 0,
            on: colorScheme.primary,
            off: colorScheme.primary.withValues(alpha: 0.22),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value == null
                      ? download.received.traffic.show
                      : '${(value * 100).floor()}%',
                  style: AppTextStyle.title1
                      .of(context, emphasized: true)
                      .copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontFeatures: tabular,
                      ),
                ),
                Text(
                  download.tag,
                  style: AppTextStyle.caption1
                      .of(context)
                      .copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontFeatures: tabular,
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

class _TicksPainter extends CustomPainter {
  const _TicksPainter({
    required this.value,
    required this.on,
    required this.off,
  });

  static const _count = 60;

  final double value;
  final Color on;
  final Color off;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outer = size.shortestSide / 2 - 4;
    final lit = (value.clamp(0.0, 1.0) * _count).round();
    final paint = Paint()
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < _count; i++) {
      final angle = i / _count * math.pi * 2 - math.pi / 2;
      final inner = outer - (i % 5 == 0 ? 13 : 8);
      final direction = Offset(math.cos(angle), math.sin(angle));
      paint.color = i < lit ? on : off;
      canvas.drawLine(
        center + direction * outer,
        center + direction * inner,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_TicksPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.on != on ||
      oldDelegate.off != off;
}

class _BadgeHero extends StatelessWidget {
  const _BadgeHero({
    required this.color,
    required this.glyph,
    required this.glyphColor,
    required this.chips,
    this.fill,
  });

  final Color color;
  final Glyph glyph;
  final Color glyphColor;
  final double? fill;
  final List<Widget> chips;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 14,
          children: [
            SizedBox.square(
              dimension: 60,
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  color: color,
                  shape: AppShape.circle,
                ),
                child: Center(
                  child: GlyphIcon(
                    glyph,
                    size: 28,
                    fill: fill,
                    color: glyphColor,
                  ),
                ),
              ),
            ),
            Row(mainAxisSize: MainAxisSize.min, spacing: 8, children: chips),
          ],
        ),
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip(this.text, {required this.color, this.emphasized = false});

  final String text;
  final Color color;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: SurfaceLevel.floatingOf(colorScheme).colorOf(colorScheme),
        shape: AppShape.full,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.footnote
              .of(context, emphasized: emphasized)
              .copyWith(
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
        ),
      ),
    );
  }
}

class _ReadyHero extends StatelessWidget {
  const _ReadyHero({required this.tag, required this.onDiscard});

  final String tag;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Stack(
      children: [
        _BadgeHero(
          color: colorScheme.success,
          glyph: AppGlyphs.check,
          glyphColor: colorScheme.onSuccess,
          chips: [
            _HeroChip(
              globalState.packageInfo.version,
              color: colorScheme.onSurfaceVariant,
            ),
            GlyphIcon(
              AppGlyphs.chevronForward,
              size: 16,
              color: colorScheme.onSuccessContainer,
            ),
            _HeroChip(
              tag.replaceFirst(RegExp('^v'), ''),
              color: colorScheme.success,
              emphasized: true,
            ),
          ],
        ),
        PositionedDirectional(
          top: 8,
          end: 8,
          child: DashboardIconButton(
            glyph: AppGlyphs.close,
            tooltip: context.appLocalizations.cancel,
            onPressed: onDiscard,
          ),
        ),
      ],
    );
  }
}

class _ConsentHero extends StatelessWidget {
  const _ConsentHero({required this.names});

  static const _shownNames = 2;

  final List<String> names;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final rest = names.length - _shownNames;
    return _BadgeHero(
      color: colorScheme.warning,
      glyph: AppGlyphs.puzzle,
      glyphColor: colorScheme.onWarning,
      fill: 1,
      chips: [
        for (final text in [...names.take(_shownNames), if (rest > 0) '+$rest'])
          Flexible(child: _HeroChip(text, color: colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
