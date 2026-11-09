part of 'scaffold.dart';

// iOS 27's bar search, as the simulator shows it. Opening, its button group
// gives up the search button and the field grows out of what is left, about
// 3% over at its peak 0.24 s on; closing, it shrinks back in 0.15 s, and the
// group takes the search button back with a swell. A back button takes the
// field back, the group its cancel button; the glass swells through the change
// as under a press. Each part starts as the last slows, where iOS pauses.
// A lone button takes a field at the bar's end in on a softer spring, then
// swells; past one across the bar it re-forms out of a droplet that starts a
// quarter of the way to the field at a quarter of its size and overshoots,
// or, while a back button takes the field, pinches off the field's end.
final _searchSpring = SpringDescription.withDampingRatio(
  mass: 1,
  stiffness: 390,
  ratio: 0.75,
);
final _searchCloseSpring = SpringDescription.withDampingRatio(
  mass: 1,
  stiffness: 600,
  ratio: 0.75,
);
final _searchMorphSpring = SpringDescription.withDampingRatio(
  mass: 1,
  stiffness: 241,
  ratio: 0.77,
);
final _droplet = SpringSimulation(dropletSpring, 0, 1, 0);
const double _dropletSize = 0.25;
const _searchSettleDuration = Duration(milliseconds: 450);
final _searchCurve = SpringCurve(_searchSpring, seconds: 0.45);
const double _searchFieldGap = 12;
const double _regularSearchWidth = 280;
const double _searchBlur = 6;

double _shownAt(double t) => ((t - 0.5) / 0.4).clamp(0.0, 1.0);

Rect _lifted(Rect rect, double lift) {
  final scale = 1 + lift * ElasticPress.growthOf(rect.longestSide);
  return Rect.fromCenter(
    center: rect.center,
    width: rect.width * scale,
    height: rect.height * scale,
  );
}

Widget _blurredIn(double opacity, Widget? child) {
  final sigma = _searchBlur * (1 - opacity);
  return Opacity(
    opacity: opacity,
    child: ImageFiltered(
      enabled: sigma > 0,
      imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: child,
    ),
  );
}

class _SearchFrame {
  const _SearchFrame({
    required this.fieldGrowth,
    required this.slotCollapse,
    required this.fieldOpacity,
    required this.titleOpacity,
    required this.actionsOpacity,
    required this.flankOpacity,
    required this.contentOpacity,
    required this.glyphOpacity,
    required this.groupSwell,
    required this.leadingOpacity,
    required this.towardLeading,
    required this.glassLift,
    required this.leadOpacity,
    required this.fieldGlyphOpacity,
    required this.fieldSwell,
    required this.dropletOffset,
    required this.dropletSize,
    required this.flankScale,
  });

  static const closed = _SearchFrame(
    fieldGrowth: 0,
    slotCollapse: 0,
    fieldOpacity: 0,
    titleOpacity: 1,
    actionsOpacity: 1,
    flankOpacity: 0,
    contentOpacity: 0,
    glyphOpacity: 1,
    groupSwell: 0,
    leadingOpacity: 1,
    towardLeading: 0,
    glassLift: 0,
    leadOpacity: 1,
    fieldGlyphOpacity: 0,
    fieldSwell: 0,
    dropletOffset: 0,
    dropletSize: 1,
    flankScale: 1,
  );

  static const open = _SearchFrame(
    fieldGrowth: 1,
    slotCollapse: 1,
    fieldOpacity: 1,
    titleOpacity: 0,
    actionsOpacity: 0,
    flankOpacity: 1,
    contentOpacity: 1,
    glyphOpacity: 0,
    groupSwell: 0,
    leadingOpacity: 0,
    towardLeading: 0,
    glassLift: 0,
    leadOpacity: 0,
    fieldGlyphOpacity: 0,
    fieldSwell: 0,
    dropletOffset: 0,
    dropletSize: 1,
    flankScale: 1,
  );

  final double fieldGrowth;
  final double slotCollapse;
  final double fieldOpacity;
  final double titleOpacity;
  final double actionsOpacity;
  final double flankOpacity;
  final double contentOpacity;
  final double glyphOpacity;
  final double groupSwell;
  final double leadingOpacity;
  final double towardLeading;
  final double glassLift;
  final double leadOpacity;
  final double fieldGlyphOpacity;
  final double fieldSwell;
  final double dropletOffset;
  final double dropletSize;
  final double flankScale;
}

/// How a closing bar's search gives its button back.
enum _SearchReturn { group, morph, droplet, pinch }

/// One opening or closing of a bar's search, in seconds from its start as
/// iOS 27 times each part.
class _SearchMove {
  _SearchMove({
    required this.opens,
    required this.returns,
    required this.from,
    required Simulation this.growth,
    required this.delay,
  });

  _SearchMove.settled({required this.opens})
    : returns = _SearchReturn.group,
      from = opens ? _SearchFrame.open : _SearchFrame.closed,
      growth = null,
      delay = 0;

  final bool opens;
  final _SearchReturn returns;
  final _SearchFrame from;
  final Simulation? growth;
  final double delay;

  double growthAt(double time) =>
      growth?.x(math.max(0, time - delay)) ?? (opens ? 1 : 0);

  double growthVelocityAt(double time) =>
      time < delay ? 0 : growth?.dx(time - delay) ?? 0;

  bool growthSettledAt(double time) =>
      growth?.isDone(math.max(0, time - delay)) ?? true;

  bool isDoneAt(double time) =>
      time >=
          (opens
              ? 0.29
              : switch (returns) {
                  _SearchReturn.group => 0.55,
                  _SearchReturn.morph => 0.75,
                  _SearchReturn.droplet => 0.8,
                  _SearchReturn.pinch => 0.7,
                }) &&
      growthSettledAt(time);

  _SearchFrame at(double time) {
    if (isDoneAt(time)) {
      return opens ? _SearchFrame.open : _SearchFrame.closed;
    }
    double to(
      double from,
      double target,
      double start,
      double end, [
      Curve curve = Curves.linear,
    ]) {
      final t = ((time - start) / (end - start)).clamp(0.0, 1.0);
      return lerpDouble(from, target, curve.transform(t))!;
    }

    final from = this.from;
    if (opens) {
      final actionsOpacity = to(from.actionsOpacity, 0, 0.02, 0.08);
      return _SearchFrame(
        fieldGrowth: growthAt(time),
        slotCollapse: to(from.slotCollapse, 1, 0, 0.08, Curves.easeOut),
        fieldOpacity: to(from.fieldOpacity, 1, 0, 0.05),
        titleOpacity: to(from.titleOpacity, 0, 0, 0.08),
        actionsOpacity: actionsOpacity,
        flankOpacity: to(from.flankOpacity, 1, 0.08, 0.2),
        contentOpacity: to(from.contentOpacity, 1, 0.07, 0.22),
        glyphOpacity: to(from.glyphOpacity, 0, 0, 0.03),
        groupSwell: to(from.groupSwell, 0, 0, 0.1),
        leadingOpacity: to(from.leadingOpacity, 0, 0, 0.02),
        towardLeading: to(from.towardLeading, 0, 0, 0.08),
        glassLift: to(
          to(from.glassLift, 1, 0.02, 0.12, Curves.easeOut),
          0,
          0.16,
          0.29,
          Curves.easeInOut,
        ),
        leadOpacity: to(from.leadOpacity, 0, 0.02, 0.08),
        fieldGlyphOpacity: to(from.fieldGlyphOpacity, 0, 0, 0.03),
        fieldSwell: to(from.fieldSwell, 0, 0, 0.1),
        dropletOffset: to(from.dropletOffset, 0, 0, 0.05),
        dropletSize: to(from.dropletSize, 1, 0, 0.05),
        flankScale: to(from.flankScale, 1, 0, 0.05),
      );
    }
    final returns = this.returns;
    final grouped = returns == _SearchReturn.group;
    final morphs = returns == _SearchReturn.morph;
    final drips = returns == _SearchReturn.droplet;
    final pinches = returns == _SearchReturn.pinch;
    final actionsOpacity = to(from.actionsOpacity, 1, 0.18, 0.26);
    final swell = grouped
        ? to(
            to(from.groupSwell, 1, 0.27, 0.36, Curves.easeOut),
            0,
            0.36,
            0.55,
            Curves.easeInOut,
          )
        : to(from.groupSwell, 0, 0, 0.1) +
              (morphs ? 0.8 * riseAndFall(time - 0.25, 0.26, 18) : 0);
    final droplet = _droplet.x(time);
    return _SearchFrame(
      fieldGrowth: growthAt(time),
      slotCollapse: to(from.slotCollapse, 0, 0.17, 0.33, Curves.easeInOut),
      fieldOpacity: switch (returns) {
        _SearchReturn.group ||
        _SearchReturn.pinch => to(from.fieldOpacity, 0, 0.19, 0.29),
        _SearchReturn.morph => to(from.fieldOpacity, 0, 0.62, 0.7),
        _SearchReturn.droplet => to(from.fieldOpacity, 0, 0.02, 0.12),
      },
      titleOpacity: to(from.titleOpacity, 1, 0.08, 0.19),
      actionsOpacity: actionsOpacity,
      flankOpacity: drips || pinches
          ? to(from.flankOpacity, 0, 0, 0.03)
          : to(from.flankOpacity, 0, 0.11, 0.2),
      contentOpacity: to(from.contentOpacity, 0, 0, 0.04),
      glyphOpacity: switch (returns) {
        _SearchReturn.group => to(from.glyphOpacity, 1, 0.3, 0.46),
        _SearchReturn.morph => to(from.glyphOpacity, 1, 0, 0.02),
        _SearchReturn.droplet => to(from.glyphOpacity, 1, 0.3, 0.5),
        _SearchReturn.pinch => to(from.glyphOpacity, 1, 0.14, 0.3),
      },
      groupSwell: swell,
      leadingOpacity: to(from.leadingOpacity, 1, 0.16, 0.19),
      towardLeading: to(to(from.towardLeading, 1, 0, 0.08), 0, 0.4, 0.41),
      glassLift: grouped || pinches
          ? to(
              to(from.glassLift, 1, 0.06, 0.16, Curves.easeOut),
              0,
              0.21,
              0.32,
              Curves.easeInOut,
            )
          : to(from.glassLift, 0, 0, 0.1),
      leadOpacity: switch (returns) {
        _SearchReturn.group => actionsOpacity,
        _SearchReturn.morph => to(from.leadOpacity, 1, 0.61, 0.62),
        _SearchReturn.droplet ||
        _SearchReturn.pinch => to(from.leadOpacity, 1, 0, 0.02),
      },
      fieldGlyphOpacity: morphs
          ? to(from.fieldGlyphOpacity, 1, 0.33, 0.45)
          : to(from.fieldGlyphOpacity, 0, 0, 0.03),
      fieldSwell: morphs ? swell : to(from.fieldSwell, 0, 0, 0.1),
      dropletOffset: switch (returns) {
        _SearchReturn.droplet =>
          _dropletSize * (1 - droplet - 0.71 * riseAndFall(time, 0.19, 5.7)),
        _SearchReturn.pinch => 0.46 * (1 - droplet),
        _ => to(from.dropletOffset, 0, 0, 0.05),
      },
      dropletSize: switch (returns) {
        _SearchReturn.droplet => lerpDouble(
          _dropletSize,
          1,
          _droplet.x(math.max(0, time - 0.31)),
        )!,
        _SearchReturn.pinch => droplet,
        _ => to(from.dropletSize, 1, 0, 0.05),
      },
      flankScale: drips || pinches
          ? to(from.flankScale, 0, 0, 0.05)
          : to(from.flankScale, 1, 0, 0.05),
    );
  }
}

class _SearchClock extends Simulation {
  _SearchClock(this.move);

  final _SearchMove move;

  @override
  double x(double time) => time;

  @override
  double dx(double time) => 1;

  @override
  bool isDone(double time) => move.isDoneAt(time);
}

class _SearchChannel extends Animatable<double> {
  const _SearchChannel(this.motion, this.of);

  final _SearchMotion motion;
  final double Function(_SearchFrame frame) of;

  @override
  double transform(double t) => of(motion.frame);
}

class _SearchMotion {
  _SearchMotion(TickerProvider vsync)
    : _clock = AnimationController.unbounded(vsync: vsync);

  final AnimationController _clock;
  var _move = _SearchMove.settled(opens: false);
  ({_SearchMove move, double time, _SearchFrame frame})? _last;

  Listenable get listenable => _clock;

  bool get isAnimating => _clock.isAnimating;

  _SearchFrame get frame {
    final time = _clock.value;
    final last = _last;
    if (last != null && identical(last.move, _move) && last.time == time) {
      return last.frame;
    }
    final frame = _move.at(time);
    _last = (move: _move, time: time, frame: frame);
    return frame;
  }

  Animation<double> drive(double Function(_SearchFrame frame) of) =>
      _clock.drive(_SearchChannel(this, of));

  void addStatusListener(AnimationStatusListener listener) =>
      _clock.addStatusListener(listener);

  void moveTo({
    required bool open,
    _SearchReturn returns = _SearchReturn.group,
  }) {
    final time = _clock.value;
    final last = _move;
    _move = _SearchMove(
      opens: open,
      returns: returns,
      from: last.at(time),
      growth: SpringSimulation(
        open
            ? _searchSpring
            : switch (returns) {
                _SearchReturn.group => _searchCloseSpring,
                _SearchReturn.morph => _searchMorphSpring,
                _SearchReturn.droplet => dropletSpring,
                _SearchReturn.pinch => _searchCloseSpring,
              },
        last.growthAt(time),
        open ? 1 : 0,
        last.growthVelocityAt(time),
        snapToEnd: true,
      ),
      // A field already moving turns back at once.
      delay: !last.growthSettledAt(time)
          ? 0
          : open
          ? 0.05
          : returns == _SearchReturn.group || returns == _SearchReturn.pinch
          ? 0.04
          : 0,
    );
    _clock.animateWith(_SearchClock(_move));
  }

  void jumpTo({required bool open}) {
    _move = _SearchMove.settled(opens: open);
    _clock.value = 0;
  }

  void dispose() => _clock.dispose();
}

class _SearchOrigin {
  const _SearchOrigin(
    this.group,
    this.withoutSearch,
    this.leading, {
    this.lone = false,
    this.field,
  });

  factory _SearchOrigin.of(
    Rect group, {
    required Rect? lead,
    required Rect? leading,
  }) {
    final button = TonalButtonSize.bar.button;
    final back = leading == null
        ? null
        : Rect.fromCenter(
            center: leading.center,
            width: button,
            height: button,
          );
    if (lead == null) {
      return _SearchOrigin(group, group, back, lone: true);
    }
    return lead.center.dx < group.center.dx
        ? _SearchOrigin(
            Rect.fromLTRB(
              lead.right - button,
              group.top,
              group.right,
              group.bottom,
            ),
            Rect.fromLTRB(lead.right, group.top, group.right, group.bottom),
            back,
          )
        : _SearchOrigin(
            Rect.fromLTRB(
              group.left,
              group.top,
              lead.left + button,
              group.bottom,
            ),
            Rect.fromLTRB(group.left, group.top, lead.left, group.bottom),
            back,
          );
  }

  final Rect group;
  final Rect withoutSearch;
  final Rect? leading;
  final bool lone;
  final Rect? field;

  double get toField => field == null ? 0 : field!.center.dx - group.center.dx;

  _SearchOrigin withField(Rect? field) =>
      _SearchOrigin(group, withoutSearch, leading, lone: lone, field: field);

  Rect at(double slotCollapse) =>
      Rect.lerp(group, withoutSearch, slotCollapse)!;
}

/// The search button of a bar's button group, which gives its place up while
/// the search is open.
class _SearchLead extends StatelessWidget {
  const _SearchLead({super.key, required this.motion, required this.child});

  final _SearchMotion motion;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: motion.listenable,
      builder: (_, child) {
        final frame = motion.frame;
        return ClipRect(
          clipBehavior: frame.slotCollapse > 0 ? Clip.hardEdge : Clip.none,
          child: Align(
            widthFactor: 1 - frame.slotCollapse,
            heightFactor: 1,
            child: _blurredIn(frame.glyphOpacity, child),
          ),
        );
      },
      child: child,
    );
  }
}

/// A button a bar's search grows from or into, swelling as a press does.
class _SearchSwell extends StatelessWidget {
  const _SearchSwell({
    required this.motion,
    required this.width,
    this.slotWidth = 0,
    this.droplet,
    required this.liftOf,
    required this.child,
  });

  final _SearchMotion motion;
  final double width;
  final double slotWidth;

  /// Where a lone button re-forms out of a droplet from.
  final ValueListenable<_SearchOrigin?>? droplet;
  final double Function(_SearchFrame frame) liftOf;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final droplet = this.droplet;
    return AnimatedBuilder(
      animation: Listenable.merge([motion.listenable, ?droplet]),
      builder: (_, child) {
        final frame = motion.frame;
        final width = this.width - slotWidth * frame.slotCollapse;
        final origin = droplet?.value;
        final scale =
            (1 + liftOf(frame) * ElasticPress.growthOf(width)) *
            (origin == null ? 1 : frame.dropletSize);
        final shift = origin == null
            ? 0.0
            : origin.toField * frame.dropletOffset;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.translationValues(shift, 0, 0)
            ..scaleByDouble(scale, scale, 1, 1),
          child: child,
        );
      },
      child: child,
    );
  }
}

/// The glyph of a lone search button, which fades back in as it re-forms.
class _SearchGlyph extends StatelessWidget {
  const _SearchGlyph({required this.motion, required this.child});

  final _SearchMotion motion;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: motion.listenable,
      builder: (_, child) => _blurredIn(motion.frame.glyphOpacity, child),
      child: child,
    );
  }
}

/// What a bar's search covers: faded out as the field opens over it, and out
/// of reach while it is open.
class _UnderBarSearch extends StatelessWidget {
  const _UnderBarSearch({
    required this.opacity,
    required this.searching,
    required this.child,
  });

  final Animation<double> opacity;
  final bool searching;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacity,
      child: ExcludeFocus(
        excluding: searching,
        child: ExcludeSemantics(
          excluding: searching,
          child: IgnorePointer(ignoring: searching, child: child),
        ),
      ),
    );
  }
}

/// The field a bar's search button opens into, grown out of that button on
/// [motion]: across the bar to a [cancel] button where there is one, as iOS
/// 27 opens one over a page above a tab bar, else at the bar's end, as iPadOS
/// does. The [actions] that still apply while searching lead the field. The
/// buttons beside it grow out of its ends and flow into it under a press, as
/// iOS's do.
class _BarSearch extends StatelessWidget {
  const _BarSearch({
    required this.motion,
    required this.opacity,
    required this.origin,
    required this.fieldKey,
    required this.searching,
    required this.actions,
    required this.actionsWidth,
    required this.cancel,
    required this.glass,
    required this.color,
    required this.field,
  });

  final _SearchMotion motion;
  final Animation<double> opacity;
  final ValueListenable<_SearchOrigin?> origin;
  final GlobalKey fieldKey;
  final bool searching;
  final List<Widget> actions;
  final double actionsWidth;
  final Widget? cancel;
  final LiquidGlassStyle? glass;
  final Color color;
  final Widget field;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final cancel = this.cancel;
    final inset = appBarActionInset(cancel != null);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final height = TonalButtonSize.bar.button;
    final glyph = GlyphIcon(
      Glyphs.search,
      fill: 1,
      size: TonalButtonSize.bar.icon,
      color: context.colorScheme.onSurface,
    );
    return ExcludeFocus(
      excluding: !searching,
      child: IgnorePointer(
        ignoring: !searching,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final top =
                constraints.maxHeight - (pageToolbarHeight + height) / 2;
            final start = (rtl ? padding.right : padding.left) + inset;
            final end = width - (rtl ? padding.left : padding.right) - inset;
            final actionsRoom = actionsWidth > 0
                ? actionsWidth + _searchFieldGap
                : 0.0;
            final fieldEnd = cancel == null
                ? end
                : end - height - _searchFieldGap;
            final fieldStart = cancel == null
                ? math.max(start + actionsRoom, end - _regularSearchWidth)
                : start + actionsRoom;
            final actionsStart = fieldStart - actionsRoom;
            Rect place(double from, double to) => Rect.fromLTRB(
              rtl ? width - to : from,
              top,
              rtl ? width - from : to,
              top + height,
            );
            final slot = place(fieldStart, math.max(fieldStart, fieldEnd));
            final actionsRect = place(
              actionsStart,
              actionsStart + actionsWidth,
            );
            final search = AnimatedBuilder(
              animation: Listenable.merge([motion.listenable, origin]),
              child: OverflowBox(
                alignment: AlignmentDirectional.centerStart,
                minWidth: slot.width,
                maxWidth: slot.width,
                child: field,
              ),
              builder: (_, content) {
                if (!searching && !motion.isAnimating) {
                  return const SizedBox.shrink();
                }
                final frame = motion.frame;
                final growth = frame.fieldGrowth;
                final grown = math.max(0.0, growth);
                final measured = origin.value;
                final group =
                    measured?.at(frame.slotCollapse) ??
                    place(fieldEnd - height, fieldEnd);
                final leading = cancel == null ? null : measured?.leading;
                final from = leading == null
                    ? group
                    : Rect.lerp(group, leading, frame.towardLeading)!;
                final fieldRect = _lifted(
                  Rect.lerp(from, slot, growth)!,
                  frame.glassLift + frame.fieldSwell,
                );
                Widget grow(
                  Rect rest,
                  Widget child, {
                  required bool leads,
                  Rect? home,
                }) {
                  final facesRight = leads != rtl;
                  final reach = lerpDouble(
                    height / 2,
                    -_searchFieldGap,
                    grown,
                  )!;
                  final anchor = facesRight
                      ? fieldRect.left + reach
                      : fieldRect.right - reach;
                  final size = rest.size * grown;
                  var rect = Rect.fromLTWH(
                    facesRight ? anchor - size.width : anchor,
                    rest.center.dy - size.height / 2,
                    size.width,
                    size.height,
                  );
                  if (home != null) {
                    rect = Rect.lerp(
                      rect,
                      Rect.lerp(home, rest, grown),
                      frame.towardLeading,
                    )!;
                  }
                  rect = _lifted(rect, frame.glassLift);
                  rect = Rect.fromCenter(
                    center: rect.center,
                    width: rect.width * frame.flankScale,
                    height: rect.height * frame.flankScale,
                  );
                  final scale = rect.width / rest.width;
                  return Positioned.fromRect(
                    rect: rest,
                    child: Transform(
                      transform: Matrix4.translationValues(
                        rect.left - rest.left,
                        rect.top - rest.top,
                        0,
                      )..scaleByDouble(scale, scale, 1, 1),
                      child: _blurredIn(frame.flankOpacity, child),
                    ),
                  );
                }

                return TextFieldTapRegion(
                  child: Stack(
                    children: [
                      Positioned.fromRect(
                        rect: fieldRect,
                        child: ElasticPress(
                          key: fieldKey,
                          child: GooPane(
                            child: ClipRSuperellipse(
                              borderRadius: AppRadius.full,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  _blurredIn(frame.contentOpacity, content),
                                  if (frame.fieldGlyphOpacity > 0)
                                    _blurredIn(frame.fieldGlyphOpacity, glyph),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (actions.isNotEmpty)
                        grow(
                          actionsRect,
                          Row(
                            children: [
                              ...separatedBy(
                                actions,
                                const SizedBox(width: barButtonGap),
                              ),
                            ],
                          ),
                          leads: true,
                        ),
                      if (cancel != null)
                        grow(
                          place(end - height, end),
                          cancel,
                          leads: false,
                          home: leading == null
                              ? null
                              : measured?.withoutSearch,
                        ),
                    ],
                  ),
                );
              },
            );
            return LiquidGlassFade(
              opacity: opacity,
              child: GooSurface(
                glass: glass,
                color: color,
                child: TonalButtonTheme(glass: glass != null, child: search),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Holds a body whose top stays put clear of the bar floating over it.
