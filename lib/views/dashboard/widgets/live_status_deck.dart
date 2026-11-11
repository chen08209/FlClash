import 'dart:async';
import 'dart:math' as math;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
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
const _listTop = 8.0;
const _actionBottom = 4.0;
const _bottomHeight = _cardHeight - _cardInset * 2 - _heroHeight;
const _openBottomHeight = _listTop + _actionHeight + _actionBottom;
const _maxCardHeight = 460.0;
const _growMargin = 24.0;
const _anchorGap = 8.0;
const _windowEdge = 16.0;
// Room above the front card for the cards behind it to show.
const _stackRise = 48.0;
const _dotsWidth = 24.0;
const _dotSize = 6.0;
const _dotPitch = 14.0;
const _dragExtent = 220.0;
const _flipDistance = 60.0;
const _flipVelocity = 700.0;
const _overscroll = 0.3;
const _settleDuration = Duration(milliseconds: 460);
const _settleCurve = Cubic(0.2, 0.9, 0.25, 1);
const _wheelInterval = Duration(milliseconds: 350);
const _expandDuration = Duration(milliseconds: 320);

typedef _Pose = ({
  double x,
  double y,
  double z,
  double tilt,
  double turn,
  double opacity,
});

// Positions -1 (swiped away) to 3, in the design's CSS frame: z points at the
// viewer and a positive tilt leans the top away.
const List<_Pose> _poses = [
  (x: 0, y: 110, z: 80, tilt: -14, turn: 0, opacity: 0),
  (x: 0, y: 0, z: 0, tilt: 0, turn: 0, opacity: 1),
  (x: -10, y: -44, z: -70, tilt: 14, turn: 8, opacity: 1),
  (x: 10, y: -92, z: -140, tilt: 24, turn: -8, opacity: 0.85),
  (x: 0, y: -120, z: -220, tilt: 32, turn: 0, opacity: 0),
];

_Pose _poseAt(double position) {
  final t = position.clamp(-1.0, 3.0) + 1;
  final i = math.min(t.floor(), _poses.length - 2);
  final f = t - i;
  final a = _poses[i];
  final b = _poses[i + 1];
  double mix(double from, double to) => from + (to - from) * f;
  return (
    x: mix(a.x, b.x),
    y: mix(a.y, b.y),
    z: mix(a.z, b.z),
    tilt: mix(a.tilt, b.tilt),
    turn: mix(a.turn, b.turn),
    opacity: mix(a.opacity, b.opacity),
  );
}

// A negative perspective entry keeps the CSS frame of [_poses].
Matrix4 _transformOf(_Pose pose) => Matrix4.identity()
  ..setEntry(3, 2, -0.001)
  ..multiply(Matrix4.translationValues(pose.x, pose.y, pose.z))
  ..rotateX(pose.tilt * math.pi / 180)
  ..rotateY(pose.turn * math.pi / 180);

/// Where the front card sits at rest and how far an opened list may grow it:
/// about its center where a phone's alert sits, downward from under the bar
/// on a desktop.
typedef DeckPlacement = ({Rect front, bool growDown, double maxHeight});

DeckPlacement _placementOf(
  BuildContext context,
  Size size, {
  required Rect anchor,
}) {
  final padding = MediaQuery.paddingOf(context);
  final width = _cardSize.width;
  final height = _cardSize.height;
  if (ViewScope.isMobileOf(context)) {
    final safe = padding.deflateRect(Offset.zero & size);
    final left = math.min(
      safe.center.dx - width / 2,
      safe.right - width - _dotsWidth,
    );
    return (
      front: Rect.fromLTWH(
        math.max(0, left),
        safe.center.dy - height / 2,
        width,
        height,
      ),
      growDown: false,
      maxHeight: (safe.height - _growMargin * 2).clamp(height, _maxCardHeight),
    );
  }
  final bottom = size.height - padding.bottom - _windowEdge;
  final top = math.min(
    anchor.bottom + _anchorGap + _stackRise,
    bottom - height,
  );
  return (
    front: Rect.fromLTWH(
      math.max(0, size.width - _windowEdge - _dotsWidth - width),
      math.max(0, top),
      width,
      height,
    ),
    growDown: true,
    maxHeight: (bottom - top).clamp(height, _maxCardHeight),
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
  });

  /// The bar button, in the navigator's coordinates.
  final Rect anchor;

  final bool separateCore;

  @override
  final Color barrierColor;

  @override
  final String barrierLabel;

  @override
  bool get barrierDismissible => true;

  @override
  AlertScaleOrigin get scaleOrigin => (context, size) {
    final center = _placementOf(context, size, anchor: anchor).front.center;
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
        placement: _placementOf(context, constraints.biggest, anchor: anchor),
      ),
    );
  }
}

/// The live statuses as a stack of cards, the next ones leaning back above the
/// front one. A drag down brings the next card forward and a drag up takes it
/// back; the deck keeps the card it shows while the statuses change under it.
/// A card with a list opens it in place, the rest of the deck stepping away
/// until it closes.
class LiveStatusDeck extends ConsumerStatefulWidget {
  const LiveStatusDeck({
    super.key,
    required this.separateCore,
    required this.placement,
  });

  final bool separateCore;

  final DeckPlacement placement;

  @override
  ConsumerState<LiveStatusDeck> createState() => _LiveStatusDeckState();
}

class _LiveStatusDeckState extends ConsumerState<LiveStatusDeck>
    with TickerProviderStateMixin {
  late final AnimationController _position = AnimationController.unbounded(
    vsync: this,
  );
  late final AnimationController _opening = AnimationController(
    vsync: this,
    duration: _expandDuration,
  )..addStatusListener(_onOpeningStatus);
  late final Animation<double> _expansion = CurvedAnimation(
    parent: _opening,
    curve: _settleCurve,
  );
  List<LiveStatus> _statuses = const [];
  Object? _shownKey;
  Object? _openKey;
  int _target = 0;
  double _dragOrigin = 0;
  double _dragDistance = 0;
  bool _dragging = false;
  bool _closing = false;
  Duration? _lastWheel;

  int get _last => _statuses.length - 1;

  bool get _open => _openKey != null;

  @override
  void dispose() {
    _position.dispose();
    _opening.dispose();
    super.dispose();
  }

  void _follow(List<LiveStatus> statuses) {
    _statuses = statuses;
    if (statuses.isEmpty) {
      _close();
      return;
    }
    if (_open && !statuses.any((status) => status.key == _openKey)) {
      _openKey = null;
      _opening.value = 0;
    }
    final kept = statuses.indexWhere((status) => status.key == _shownKey);
    final shown = kept >= 0 ? kept : _target.clamp(0, _last);
    _shownKey = statuses[shown].key;
    if (_dragging || shown == _target) return;
    _target = shown;
    _position.value = shown.toDouble();
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

  void _onOpeningStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && _open) {
      setState(() => _openKey = null);
    }
  }

  void _toggle(Object key) {
    final opening = !_opening.status.isForwardOrCompleted;
    setState(() {
      if (opening) _openKey = key;
    });
    if (context.disableAnimations) {
      _opening.value = opening ? 1 : 0;
    } else if (opening) {
      unawaited(_opening.forward().orCancel.catchError((_) {}));
    } else {
      unawaited(_opening.reverse().orCancel.catchError((_) {}));
    }
  }

  void _settle(int index) {
    if (_statuses.isEmpty) return;
    final target = index.clamp(0, _last);
    _target = target;
    _shownKey = _statuses[target].key;
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

  double _resist(double value) {
    if (value < 0) return value * _overscroll;
    if (value > _last) return _last + (value - _last) * _overscroll;
    return value;
  }

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
    if (event is! PointerScrollEvent || _open) return;
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
    if (_open || event is! KeyDownEvent && event is! KeyRepeatEvent) {
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

  @override
  Widget build(BuildContext context) {
    final statuses = watchLiveStatuses(ref, separateCore: widget.separateCore);
    _follow(statuses);
    final colorScheme = context.colorScheme;
    final appLocalizations = context.appLocalizations;
    final fill = SurfaceLevel.floatingOf(colorScheme).colorOf(colorScheme);
    final front = widget.placement.front;
    final open = _open;
    final cards = [
      for (final status in statuses)
        RepaintBoundary(
          key: ValueKey(status.key),
          child: _StatusCard(
            status: status,
            expansion: status.key == _openKey
                ? _expansion
                : kAlwaysDismissedAnimation,
            listed: status.key == _openKey,
            open:
                status.key == _openKey && _opening.status.isForwardOrCompleted,
            onToggle: () => _toggle(status.key),
          ),
        ),
    ];
    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      child: Listener(
        onPointerSignal: _onPointerSignal,
        child: GestureDetector(
          onVerticalDragStart: open ? null : _onDragStart,
          onVerticalDragUpdate: open ? null : _onDragUpdate,
          onVerticalDragEnd: open ? null : _onDragEnd,
          onVerticalDragCancel: open
              ? null
              : () => _onDragEnd(DragEndDetails()),
          child: AnimatedBuilder(
            animation: Listenable.merge([_position, _expansion]),
            builder: (context, _) {
              final position = _position.value;
              final rest = 1 - _expansion.value;
              final placed = [
                for (var i = 0; i < cards.length; i++) (i, i - position),
              ]..sort((a, b) => b.$2.compareTo(a.$2));
              final active = position.round().clamp(0, math.max(0, _last));
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  for (final (index, offset) in placed)
                    if (offset > -1 && offset < 3)
                      _placeCard(
                        card: cards[index],
                        offset: offset,
                        fill: fill,
                        fade: statuses[index].key == _openKey ? 1 : rest,
                        shadows: offset < 0.5
                            ? _frontShadows(colorScheme)
                            : _backShadows(colorScheme),
                      ),
                  if (statuses.length > 1 && rest > 0)
                    Positioned(
                      left: front.right,
                      top: front.center.dy - statuses.length * _dotPitch / 2,
                      width: _dotsWidth,
                      child: IgnorePointer(
                        ignoring: open,
                        child: Opacity(
                          opacity: rest,
                          child: Column(
                            children: [
                              for (var i = 0; i < statuses.length; i++)
                                _Dot(
                                  active: i == active,
                                  label: appLocalizations.liveStatusPosition(
                                    i + 1,
                                    statuses.length,
                                  ),
                                  onTap: () => _settle(i),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _placeCard({
    required Widget card,
    required double offset,
    required Color fill,
    required double fade,
    required List<BoxShadow> shadows,
  }) {
    final pose = _poseAt(offset);
    final front = offset.abs() < 0.5;
    return Positioned.fill(
      key: card.key,
      child: CustomSingleChildLayout(
        delegate: _CardSlot(widget.placement),
        child: IgnorePointer(
          ignoring: !front,
          child: Opacity(
            opacity: (pose.opacity * fade).clamp(0, 1),
            child: Transform(
              alignment: Alignment.center,
              transform: _transformOf(pose),
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  color: fill,
                  shape: AppShape.all(AppCorner.alert),
                  shadows: shadows,
                ),
                child: card,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Lays a card out at its resting place; an opened one grows as tall as the
/// placement allows, about its center or down from its top.
class _CardSlot extends SingleChildLayoutDelegate {
  const _CardSlot(this.placement);

  final DeckPlacement placement;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints(
        minWidth: placement.front.width,
        maxWidth: placement.front.width,
        maxHeight: placement.maxHeight,
      );

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final front = placement.front;
    return Offset(
      front.left,
      placement.growDown ? front.top : front.center.dy - childSize.height / 2,
    );
  }

  @override
  bool shouldRelayout(_CardSlot oldDelegate) =>
      oldDelegate.placement != placement;
}

/// A card [progress] of the way from its resting height to the height its
/// content asks for, which only an opened card measures.
class _ExpandingBox extends SingleChildRenderObjectWidget {
  const _ExpandingBox({required this.progress, super.child});

  final double progress;

  @override
  _RenderExpandingBox createRenderObject(BuildContext context) =>
      _RenderExpandingBox(progress);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderExpandingBox renderObject,
  ) {
    renderObject.progress = progress;
  }
}

class _RenderExpandingBox extends RenderProxyBox {
  _RenderExpandingBox(this._progress);

  double _progress;
  set progress(double value) {
    if (value == _progress) return;
    _progress = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    final child = this.child!;
    final width = constraints.maxWidth;
    var height = _cardHeight;
    if (_progress > 0) {
      final ceiling = math.max(_cardHeight, constraints.maxHeight);
      final full = child
          .getMaxIntrinsicHeight(width)
          .clamp(_cardHeight, ceiling);
      height = _cardHeight + (full - _cardHeight) * _progress;
    }
    child.layout(
      BoxConstraints.tight(constraints.constrain(Size(width, height))),
      parentUsesSize: true,
    );
    size = child.size;
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

class _Dot extends StatelessWidget {
  const _Dot({required this.active, required this.label, required this.onTap});

  final bool active;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Semantics(
      button: true,
      selected: active,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: _dotsWidth,
          height: _dotPitch,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _dotSize,
              height: _dotSize,
              decoration: ShapeDecoration(
                color: active
                    ? colorScheme.onSurface
                    : colorScheme.outlineVariant,
                shape: AppShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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

class _StatusCard extends ConsumerWidget {
  const _StatusCard({
    required this.status,
    required this.expansion,
    required this.listed,
    required this.open,
    required this.onToggle,
  });

  final LiveStatus status;

  final Animation<double> expansion;

  /// Whether the card shows its whole list, as it does until it has closed.
  final bool listed;

  /// Whether the card is opening or open, which its button closes.
  final bool open;

  final VoidCallback onToggle;

  Future<void> _restartCore(CoreAction core, {bool confirm = false}) async {
    if (confirm) {
      final confirmed = await dialogs.showMessage(
        message: TextSpan(text: currentAppLocalizations.forceRestartCoreTip),
      );
      if (confirmed != true) return;
    }
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    final appLocalizations = context.appLocalizations;
    final action = ref.read(commonActionProvider.notifier);
    final level = SurfaceLevel.floatingOf(colorScheme);
    final neutral = level.next.colorOf(colorScheme);
    final core = ref.read(coreActionProvider.notifier);
    final toggleLabel = open
        ? appLocalizations.showLess
        : appLocalizations.viewAll;
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
        appLocalizations.coreStoppedDesc,
        appLocalizations.restartCore,
        () => unawaited(_restartCore(core)),
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
        () => unawaited(_restartCore(core, confirm: true)),
        (neutral, colorScheme.onSurface),
      ),
      UpdateStatus(download: final UpdateDownloading download) => (
        colorScheme.primaryContainer,
        _DownloadHero(download: download),
        appLocalizations.downloadingUpdate,
        _progressText(download),
        appLocalizations.cancel,
        action.cancelUpdateDownload,
        (neutral, colorScheme.onSurface),
      ),
      UpdateStatus(download: final UpdateReady download) => (
        colorScheme.successContainer,
        _ReadyHero(
          tag: download.tag,
          onDiscard: () => unawaited(action.discardUpdate()),
        ),
        appLocalizations.updateReady,
        _readyTip(appLocalizations),
        appLocalizations.installUpdate,
        () => _install(context, ref),
        (colorScheme.success, colorScheme.successContainer),
      ),
      ResourcesStatus(:final items) when items.length > _HeroRows.shown => (
        neutral,
        listed ? _ResourcesList(items: items) : _ResourcesHero(items: items),
        appLocalizations.updatingResources,
        appLocalizations.updatingResourcesCount(items.length),
        toggleLabel,
        onToggle,
        (neutral, colorScheme.onSurface),
      ),
      ResourcesStatus(:final items) => (
        neutral,
        _ResourcesHero(items: items),
        appLocalizations.updatingResources,
        appLocalizations.updatingResourcesCount(items.length),
        null,
        null,
        null,
      ),
    };
    final heroBox = DecoratedBox(
      decoration: ShapeDecoration(
        color: tint,
        shape: AppShape.all(_heroCorner),
      ),
      child: listed
          ? ClipRSuperellipse(
              borderRadius: const BorderRadius.all(
                Radius.circular(_heroCorner),
              ),
              child: hero,
            )
          : hero,
    );
    final text = Column(
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
    final button = actionLabel != null && actionColors != null
        ? FilledButton(
            onPressed: onAction,
            style: ButtonStyle.from(
              backgroundColor: actionColors.$1,
              foregroundColor: actionColors.$2,
              minimumSize: const Size.fromHeight(_actionHeight),
              tapTargetSize: TapTargetSize.shrinkWrap,
              shape: AppShape.full,
            ),
            child: Text(actionLabel),
          )
        : null;
    return SurfaceScope(
      level: level,
      child: AnimatedBuilder(
        animation: expansion,
        builder: (context, _) {
          final t = expansion.value;
          double toward(double from, double to) => from + (to - from) * t;
          return _ExpandingBox(
            progress: t,
            child: Padding(
              padding: const EdgeInsets.all(_cardInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: heroBox),
                  SizedBox(
                    height: toward(_bottomHeight, _openBottomHeight),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        8,
                        toward(_textTop, _listTop),
                        8,
                        _actionBottom,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRect(
                              child: Opacity(
                                opacity: 1 - t,
                                child: OverflowBox(
                                  alignment: AlignmentDirectional.topStart,
                                  maxHeight: double.infinity,
                                  child: text,
                                ),
                              ),
                            ),
                          ),
                          ?button,
                        ],
                      ),
                    ),
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
        colorScheme.successContainer,
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

class _ReadyHero extends StatelessWidget {
  const _ReadyHero({required this.tag, required this.onDiscard});

  final String tag;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final chipFill = SurfaceLevel.floatingOf(colorScheme).colorOf(colorScheme);
    Widget chip(String text, {Color? color, bool emphasized = false}) =>
        DecoratedBox(
          decoration: ShapeDecoration(color: chipFill, shape: AppShape.full),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            child: Text(
              text,
              style: AppTextStyle.footnote
                  .of(context, emphasized: emphasized)
                  .copyWith(
                    color: color,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
            ),
          ),
        );
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 14,
            children: [
              SizedBox.square(
                dimension: 60,
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    color: colorScheme.success,
                    shape: AppShape.circle,
                  ),
                  child: Center(
                    child: GlyphIcon(
                      AppGlyphs.check,
                      size: 28,
                      color: colorScheme.successContainer,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  chip(
                    globalState.packageInfo.version,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  GlyphIcon(
                    AppGlyphs.chevronForward,
                    size: 16,
                    color: colorScheme.onSuccessContainer,
                  ),
                  chip(
                    tag.replaceFirst(RegExp('^v'), ''),
                    color: colorScheme.success,
                    emphasized: true,
                  ),
                ],
              ),
            ],
          ),
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

class _ResourcesHero extends StatelessWidget {
  const _ResourcesHero({required this.items});

  final List<UpdatingResource> items;

  @override
  Widget build(BuildContext context) {
    return _HeroRows(
      children: [
        for (final item in items.take(_HeroRows.shown)) _ResourceRow(item),
      ],
    );
  }
}

class _ResourcesList extends StatelessWidget {
  const _ResourcesList({required this.items});

  final List<UpdatingResource> items;

  @override
  Widget build(BuildContext context) {
    return _HeroList(children: [for (final item in items) _ResourceRow(item)]);
  }
}

class _ResourceRow extends StatelessWidget {
  const _ResourceRow(this.item);

  final UpdatingResource item;

  @override
  Widget build(BuildContext context) {
    return _HeroRow(
      leading: GlyphIcon(
        item.isProfile ? AppGlyphs.profiles : AppGlyphs.resources,
        size: 18,
        color: context.colorScheme.onSurfaceVariant,
      ),
      label: item.name,
      trailing: const ActivityIndicator(size: 16),
    );
  }
}

/// The whole of an opened card's list, scrolling once the card can grow no
/// taller.
class _HeroList extends StatelessWidget {
  const _HeroList({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 6,
        children: children,
      ),
    );
  }
}

class _HeroRows extends StatelessWidget {
  const _HeroRows({required this.children});

  static const shown = 3;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 264,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: children,
        ),
      ),
    );
  }
}

class _HeroRow extends StatelessWidget {
  const _HeroRow({required this.leading, required this.label, this.trailing});

  final Widget leading;
  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final trailing = this.trailing;
    return SizedBox(
      height: 36,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: SurfaceLevel.floatingOf(colorScheme).colorOf(colorScheme),
          shape: AppShape.sm,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            spacing: 10,
            children: [
              leading,
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.subheadline.of(context),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
