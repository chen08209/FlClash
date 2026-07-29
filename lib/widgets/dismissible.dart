import 'package:flutter/material.dart';

enum ExternalDismissibleEffect { normal, resize }

class ExternalDismissible extends StatefulWidget {
  final Widget child;
  final VoidCallback? onDismissed;
  final bool dismiss;
  final ExternalDismissibleEffect effect;

  const ExternalDismissible({
    super.key,
    required this.child,
    required this.dismiss,
    this.onDismissed,
    this.effect = ExternalDismissibleEffect.normal,
  });

  @override
  State<ExternalDismissible> createState() => _ExternalDismissibleState();
}

class _ExternalDismissibleState extends State<ExternalDismissible>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final AnimationController _controller;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _fadeAnimation;
  late Animation<double> _resizeAnimation;

  bool _isDismissing = false;

  bool get _isNormal => widget.effect == ExternalDismissibleEffect.normal;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _initAnimations();
    if (widget.dismiss) {
      _dismiss();
    }
  }

  void _initAnimations() {
    const curve = Curves.fastOutSlowIn;

    if (_isNormal) {
      _slideAnimation =
          Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(1.0, 0.0),
          ).animate(
            CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.0, 1.0, curve: curve),
            ),
          );

      _resizeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.3, 1.0, curve: curve),
        ),
      );
    } else {
      _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.6, curve: curve),
        ),
      );

      _resizeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.2, 1.0, curve: curve),
        ),
      );
    }
  }

  @override
  bool get wantKeepAlive => _isDismissing;

  @override
  void didUpdateWidget(covariant ExternalDismissible oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.dismiss && widget.dismiss) {
      _dismiss();
    }
  }

  Future<void> _dismiss() async {
    if (_isDismissing) return;
    if (!mounted) return;
    _isDismissing = true;
    updateKeepAlive();
    await _controller.forward();
    if (mounted && widget.onDismissed != null) {
      widget.onDismissed!();
    }
    _isDismissing = false;
    updateKeepAlive();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Widget content = widget.child;

    if (_slideAnimation != null) {
      content = SlideTransition(position: _slideAnimation!, child: content);
    }

    if (_fadeAnimation != null) {
      content = FadeTransition(opacity: _fadeAnimation!, child: content);
    }

    return SizeTransition(
      alignment: AlignmentGeometry.center,
      sizeFactor: _resizeAnimation,
      axis: Axis.vertical,
      child: content,
    );
  }
}
