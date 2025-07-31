import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

typedef CloseContainerActionCallback<S> = void Function({S? returnValue});
typedef OpenContainerBuilder<S> =
    Widget Function(
      BuildContext context,
      CloseContainerActionCallback<S> action,
    );
typedef CloseContainerBuilder =
    Widget Function(BuildContext context, VoidCallback action);

enum ContainerTransitionType { fade, fadeThrough }

typedef ClosedCallback<S> = void Function(S data);

@optionalTypeArgs
class OpenContainer<T extends Object?> extends StatefulWidget {
  const OpenContainer({
    super.key,
    this.middleColor,
    this.onClosed,
    required this.closedBuilder,
    required this.openBuilder,
    this.tappable = true,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.transitionType = ContainerTransitionType.fade,
    this.useRootNavigator = false,
    this.routeSettings,
    this.clipBehavior = Clip.antiAlias,
  });

  final Color? middleColor;
  final ClosedCallback<T?>? onClosed;
  final CloseContainerBuilder closedBuilder;
  final OpenContainerBuilder<T> openBuilder;
  final bool tappable;
  final Duration transitionDuration;
  final ContainerTransitionType transitionType;
  final bool useRootNavigator;
  final RouteSettings? routeSettings;
  final Clip clipBehavior;

  @override
  State<OpenContainer<T?>> createState() => _OpenContainerState<T>();
}

class _OpenContainerState<T> extends State<OpenContainer<T?>> {
  final GlobalKey<_HideableState> _hideableKey = GlobalKey<_HideableState>();
  final GlobalKey _closedBuilderKey = GlobalKey();

  Future<void> openContainer() async {
    final Color middleColor =
        widget.middleColor ?? Theme.of(context).canvasColor;
    final T? data =
        await Navigator.of(
          context,
          rootNavigator: widget.useRootNavigator,
        ).push(
          _OpenContainerRoute<T>(
            middleColor: middleColor,
            closedBuilder: widget.closedBuilder,
            openBuilder: widget.openBuilder,
            hideableKey: _hideableKey,
            closedBuilderKey: _closedBuilderKey,
            transitionDuration: widget.transitionDuration,
            transitionType: widget.transitionType,
            useRootNavigator: widget.useRootNavigator,
            routeSettings: widget.routeSettings,
          ),
        );
    if (widget.onClosed != null) {
      widget.onClosed!(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Hideable(
      key: _hideableKey,
      child: GestureDetector(
        onTap: widget.tappable ? openContainer : null,
        child: Material(
          color: Colors.transparent,
          clipBehavior: widget.clipBehavior,
          child: Builder(
            key: _closedBuilderKey,
            builder: (BuildContext context) {
              return widget.closedBuilder(context, openContainer);
            },
          ),
        ),
      ),
    );
  }
}

class _Hideable extends StatefulWidget {
  const _Hideable({super.key, required this.child});

  final Widget child;

  @override
  State<_Hideable> createState() => _HideableState();
}

class _HideableState extends State<_Hideable> {
  Size? get placeholderSize => _placeholderSize;
  Size? _placeholderSize;

  set placeholderSize(Size? value) {
    if (_placeholderSize == value) {
      return;
    }
    setState(() {
      _placeholderSize = value;
    });
  }

  bool get isVisible => _visible;
  bool _visible = true;

  set isVisible(bool value) {
    if (_visible == value) {
      return;
    }
    setState(() {
      _visible = value;
    });
  }

  bool get isInTree => _placeholderSize == null;

  @override
  Widget build(BuildContext context) {
    if (_placeholderSize != null) {
      return SizedBox.fromSize(size: _placeholderSize);
    }
    return Visibility(
      visible: _visible,
      maintainSize: true,
      maintainState: true,
      maintainAnimation: true,
      child: widget.child,
    );
  }
}

class _OpenContainerRoute<T> extends ModalRoute<T> {
  _OpenContainerRoute({
    required this.middleColor,
    required this.closedBuilder,
    required this.openBuilder,
    required this.hideableKey,
    required this.closedBuilderKey,
    required this.transitionDuration,
    required this.transitionType,
    required this.useRootNavigator,
    required RouteSettings? routeSettings,
  }) : _closedOpacityTween = _getClosedOpacityTween(transitionType),
       _openOpacityTween = _getOpenOpacityTween(transitionType),
       super(settings: routeSettings);

  static _FlippableTweenSequence<Color?> _getColorTween({
    required ContainerTransitionType transitionType,
    required Color closedColor,
    required Color openColor,
    required Color middleColor,
  }) {
    switch (transitionType) {
      case ContainerTransitionType.fade:
        return _FlippableTweenSequence<Color?>(<TweenSequenceItem<Color?>>[
          TweenSequenceItem<Color>(
            tween: ConstantTween<Color>(closedColor),
            weight: 1 / 5,
          ),
          TweenSequenceItem<Color?>(
            tween: ColorTween(begin: closedColor, end: openColor),
            weight: 1 / 5,
          ),
          TweenSequenceItem<Color>(
            tween: ConstantTween<Color>(openColor),
            weight: 3 / 5,
          ),
        ]);
      case ContainerTransitionType.fadeThrough:
        return _FlippableTweenSequence<Color?>(<TweenSequenceItem<Color?>>[
          TweenSequenceItem<Color?>(
            tween: ColorTween(begin: closedColor, end: middleColor),
            weight: 1 / 5,
          ),
          TweenSequenceItem<Color?>(
            tween: ColorTween(begin: middleColor, end: openColor),
            weight: 4 / 5,
          ),
        ]);
    }
  }

  static _FlippableTweenSequence<double> _getClosedOpacityTween(
    ContainerTransitionType transitionType,
  ) {
    switch (transitionType) {
      case ContainerTransitionType.fade:
        return _FlippableTweenSequence<double>(<TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: ConstantTween<double>(1.0),
            weight: 1,
          ),
        ]);
      case ContainerTransitionType.fadeThrough:
        return _FlippableTweenSequence<double>(<TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 1.0, end: 0.0),
            weight: 1 / 5,
          ),
          TweenSequenceItem<double>(
            tween: ConstantTween<double>(0.0),
            weight: 4 / 5,
          ),
        ]);
    }
  }

  static _FlippableTweenSequence<double> _getOpenOpacityTween(
    ContainerTransitionType transitionType,
  ) {
    switch (transitionType) {
      case ContainerTransitionType.fade:
        return _FlippableTweenSequence<double>(<TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: ConstantTween<double>(0.0),
            weight: 1 / 5,
          ),
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            weight: 1 / 5,
          ),
          TweenSequenceItem<double>(
            tween: ConstantTween<double>(1.0),
            weight: 3 / 5,
          ),
        ]);
      case ContainerTransitionType.fadeThrough:
        return _FlippableTweenSequence<double>(<TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: ConstantTween<double>(0.0),
            weight: 1 / 5,
          ),
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            weight: 4 / 5,
          ),
        ]);
    }
  }

  final Color middleColor;
  final CloseContainerBuilder closedBuilder;
  final OpenContainerBuilder<T> openBuilder;
  final GlobalKey<_HideableState> hideableKey;
  final GlobalKey closedBuilderKey;

  @override
  final Duration transitionDuration;
  final ContainerTransitionType transitionType;

  final bool useRootNavigator;

  final _FlippableTweenSequence<double> _closedOpacityTween;
  final _FlippableTweenSequence<double> _openOpacityTween;
  late _FlippableTweenSequence<Color?> _colorTween;
  final GlobalKey _openBuilderKey = GlobalKey();
  final RectTween _rectTween = RectTween();

  AnimationStatus? _lastAnimationStatus;
  AnimationStatus? _currentAnimationStatus;

  @override
  TickerFuture didPush() {
    _takeMeasurements(navigatorContext: hideableKey.currentContext!);

    animation!.addStatusListener((AnimationStatus status) {
      _lastAnimationStatus = _currentAnimationStatus;
      _currentAnimationStatus = status;
      switch (status) {
        case AnimationStatus.dismissed:
          _toggleHideable(hide: false);
          break;
        case AnimationStatus.completed:
          _toggleHideable(hide: true);
          break;
        case AnimationStatus.forward:
        case AnimationStatus.reverse:
          break;
      }
    });

    return super.didPush();
  }

  @override
  bool didPop(T? result) {
    _takeMeasurements(
      navigatorContext: subtreeContext!,
      delayForSourceRoute: true,
    );
    return super.didPop(result);
  }

  @override
  void dispose() {
    if (hideableKey.currentState?.isVisible == false) {
      SchedulerBinding.instance.addPostFrameCallback(
        (Duration d) => _toggleHideable(hide: false),
      );
    }
    super.dispose();
  }

  void _toggleHideable({required bool hide}) {
    if (hideableKey.currentState != null) {
      hideableKey.currentState!
        ..placeholderSize = null
        ..isVisible = !hide;
    }
  }

  void _takeMeasurements({
    required BuildContext navigatorContext,
    bool delayForSourceRoute = false,
  }) {
    final RenderBox navigator =
        Navigator.of(
              navigatorContext,
              rootNavigator: useRootNavigator,
            ).context.findRenderObject()!
            as RenderBox;
    final Size navSize = _getSize(navigator);
    _rectTween.end = Offset.zero & navSize;

    void takeMeasurementsInSourceRoute([Duration? _]) {
      if (!navigator.attached || hideableKey.currentContext == null) {
        return;
      }
      _rectTween.begin = _getRect(hideableKey, navigator);
      hideableKey.currentState!.placeholderSize = _rectTween.begin!.size;
    }

    if (delayForSourceRoute) {
      SchedulerBinding.instance.addPostFrameCallback(
        takeMeasurementsInSourceRoute,
      );
    } else {
      takeMeasurementsInSourceRoute();
    }
  }

  Size _getSize(RenderBox render) {
    assert(render.hasSize);
    return render.size;
  }

  Rect _getRect(GlobalKey key, RenderBox ancestor) {
    assert(key.currentContext != null);
    assert(ancestor.hasSize);
    final RenderBox render =
        key.currentContext!.findRenderObject()! as RenderBox;
    assert(render.hasSize);
    return MatrixUtils.transformRect(
      render.getTransformTo(ancestor),
      Offset.zero & render.size,
    );
  }

  bool get _transitionWasInterrupted {
    bool wasInProgress = false;
    bool isInProgress = false;

    switch (_currentAnimationStatus) {
      case AnimationStatus.completed:
      case AnimationStatus.dismissed:
        isInProgress = false;
        break;
      case AnimationStatus.forward:
      case AnimationStatus.reverse:
        isInProgress = true;
        break;
      case null:
        break;
    }
    switch (_lastAnimationStatus) {
      case AnimationStatus.completed:
      case AnimationStatus.dismissed:
        wasInProgress = false;
        break;
      case AnimationStatus.forward:
      case AnimationStatus.reverse:
        wasInProgress = true;
        break;
      case null:
        break;
    }
    return wasInProgress && isInProgress;
  }

  void closeContainer({T? returnValue}) {
    Navigator.of(subtreeContext!).pop(returnValue);
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    _colorTween = _getColorTween(
      transitionType: transitionType,
      closedColor: Theme.of(context).colorScheme.surface,
      openColor: Theme.of(context).colorScheme.surface,
      middleColor: middleColor,
    );
    return Align(
      alignment: Alignment.topLeft,
      child: AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          if (animation.isCompleted) {
            return SizedBox.expand(
              child: Material(
                child: Builder(
                  key: _openBuilderKey,
                  builder: (BuildContext context) {
                    return openBuilder(context, closeContainer);
                  },
                ),
              ),
            );
          }

          final Animation<double> curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.fastOutSlowIn,
            reverseCurve: _transitionWasInterrupted
                ? null
                : Curves.fastOutSlowIn.flipped,
          );
          TweenSequence<Color?>? colorTween;
          TweenSequence<double>? closedOpacityTween, openOpacityTween;
          switch (animation.status) {
            case AnimationStatus.dismissed:
            case AnimationStatus.forward:
              closedOpacityTween = _closedOpacityTween;
              openOpacityTween = _openOpacityTween;
              colorTween = _colorTween;
              break;
            case AnimationStatus.reverse:
              if (_transitionWasInterrupted) {
                closedOpacityTween = _closedOpacityTween;
                openOpacityTween = _openOpacityTween;
                colorTween = _colorTween;
                break;
              }
              closedOpacityTween = _closedOpacityTween.flipped;
              openOpacityTween = _openOpacityTween.flipped;
              colorTween = _colorTween.flipped;
              break;
            case AnimationStatus.completed:
              assert(false); // Unreachable.
              break;
          }
          assert(colorTween != null);
          assert(closedOpacityTween != null);
          assert(openOpacityTween != null);

          final Rect rect = _rectTween.evaluate(curvedAnimation)!;
          return SizedBox.expand(
            child: Align(
              alignment: Alignment.topLeft,
              child: Transform.translate(
                offset: Offset(rect.left, rect.top),
                child: SizedBox(
                  width: rect.width,
                  height: rect.height,
                  child: Material(
                    clipBehavior: Clip.antiAlias,
                    animationDuration: Duration.zero,
                    color: colorTween!.evaluate(animation),
                    child: Stack(
                      fit: StackFit.passthrough,
                      children: <Widget>[
                        // Closed child fading out.
                        FittedBox(
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.topLeft,
                          child: SizedBox(
                            width: _rectTween.begin!.width,
                            height: _rectTween.begin!.height,
                            child: (hideableKey.currentState?.isInTree ?? false)
                                ? null
                                : FadeTransition(
                                    opacity: closedOpacityTween!.animate(
                                      animation,
                                    ),
                                    child: Builder(
                                      key: closedBuilderKey,
                                      builder: (BuildContext context) {
                                        // Use dummy "open container" callback
                                        // since we are in the process of opening.
                                        return closedBuilder(context, () {});
                                      },
                                    ),
                                  ),
                          ),
                        ),
                        // Open child fading in.
                        OverflowBox(
                          maxWidth: _rectTween.end!.width,
                          maxHeight: _rectTween.end!.height,
                          alignment: Alignment.topLeft,
                          child: FadeTransition(
                            opacity: openOpacityTween!.animate(animation),
                            child: Builder(
                              key: _openBuilderKey,
                              builder: (BuildContext context) {
                                return openBuilder(context, closeContainer);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  bool get maintainState => true;

  @override
  Color? get barrierColor => null;

  @override
  bool get opaque => true;

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => null;
}

class _FlippableTweenSequence<T> extends TweenSequence<T> {
  _FlippableTweenSequence(this._items) : super(_items);

  final List<TweenSequenceItem<T>> _items;
  _FlippableTweenSequence<T>? _flipped;

  _FlippableTweenSequence<T>? get flipped {
    if (_flipped == null) {
      final List<TweenSequenceItem<T>> newItems = <TweenSequenceItem<T>>[];
      for (int i = 0; i < _items.length; i++) {
        newItems.add(
          TweenSequenceItem<T>(
            tween: _items[i].tween,
            weight: _items[_items.length - 1 - i].weight,
          ),
        );
      }
      _flipped = _FlippableTweenSequence<T>(newItems);
    }
    return _flipped;
  }
}
