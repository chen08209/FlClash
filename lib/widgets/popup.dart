import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/common.dart';
import 'package:flutter/material.dart';

class CommonPopupRoute<T> extends PopupRoute<T> {
  final WidgetBuilder builder;
  ValueNotifier<Offset> offsetNotifier;

  CommonPopupRoute({
    required this.barrierLabel,
    required this.builder,
    required this.offsetNotifier,
  });

  @override
  String? barrierLabel;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final align = Alignment.topRight;
    final animationValue = CurvedAnimation(
      parent: animation,
      curve: Curves.easeIn,
    ).value;
    return SafeArea(
      child: ValueListenableBuilder(
        valueListenable: offsetNotifier,
        builder: (_, value, child) {
          return Align(
            alignment: align,
            child: CustomSingleChildLayout(
              delegate: OverflowAwareLayoutDelegate(
                offset: value.translate(48, -8),
              ),
              child: child,
            ),
          );
        },
        child: AnimatedBuilder(
          animation: animation,
          builder: (_, Widget? child) {
            return Opacity(
              opacity: 0.1 + 0.9 * animationValue,
              child: Transform.scale(
                alignment: align,
                scale: 0.7 + 0.3 * animationValue,
                child: Transform.translate(
                  offset: Offset(0, -10) * (1 - animationValue),
                  child: child!,
                ),
              ),
            );
          },
          child: builder(context),
        ),
      ),
    );
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 150);
}

class PopupController extends ValueNotifier<bool> {
  PopupController() : super(false);

  void open() {
    value = true;
  }

  void close() {
    value = false;
  }
}

typedef PopupOpen = Function({Offset offset});

class CommonPopupBox extends StatefulWidget {
  final Widget Function(PopupOpen open) targetBuilder;
  final Widget popup;

  const CommonPopupBox({
    super.key,
    required this.targetBuilder,
    required this.popup,
  });

  @override
  State<CommonPopupBox> createState() => _CommonPopupBoxState();
}

class _CommonPopupBoxState extends State<CommonPopupBox> {
  bool _isOpen = false;
  final _targetOffsetValueNotifier = ValueNotifier<Offset>(Offset.zero);
  Offset _offset = Offset.zero;

  void _open({Offset offset = Offset.zero}) {
    _offset = offset;
    _updateOffset();
    _isOpen = true;
    Navigator.of(context)
        .push(
          CommonPopupRoute(
            barrierLabel: utils.id,
            builder: (BuildContext context) {
              return widget.popup;
            },
            offsetNotifier: _targetOffsetValueNotifier,
          ),
        )
        .then((_) {
          _isOpen = false;
        });
  }

  void _updateOffset() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return;
    }
    final viewPadding = MediaQuery.of(context).viewPadding;
    _targetOffsetValueNotifier.value = renderBox
        .localToGlobal(
          Offset.zero.translate(viewPadding.right, viewPadding.top),
        )
        .translate(_offset.dx, _offset.dy);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_isOpen) {
            _updateOffset();
          }
        });
        return widget.targetBuilder(_open);
      },
    );
  }
}

class OverflowAwareLayoutDelegate extends SingleChildLayoutDelegate {
  final Offset offset;

  OverflowAwareLayoutDelegate({required this.offset});

  @override
  Size getSize(BoxConstraints constraints) {
    return Size(constraints.maxWidth, constraints.maxHeight);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final safeOffset = Offset(16, 16);
    double x = (offset.dx - childSize.width).clamp(
      0,
      size.width - safeOffset.dx - childSize.width,
    );
    double y = (offset.dy).clamp(
      0,
      size.height - safeOffset.dy - childSize.height,
    );
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(covariant OverflowAwareLayoutDelegate oldDelegate) {
    return oldDelegate.offset != offset;
  }
}

class CommonPopupMenu extends StatelessWidget {
  final List<PopupMenuItemData> items;
  final double minWidth;
  final double minItemVerticalPadding;
  final double fontSize;

  const CommonPopupMenu({
    super.key,
    required this.items,
    this.minWidth = 200,
    this.minItemVerticalPadding = 16,
    this.fontSize = 15,
  });

  Widget _popupMenuItem(
    BuildContext context, {
    required PopupMenuItemData item,
    required int index,
  }) {
    final onPressed = item.onPressed;
    final disabled = onPressed == null;
    final color = item.danger
        ? context.colorScheme.onError
        : context.colorScheme.onSurface;
    final foregroundColor = disabled ? color.opacity30 : color;
    final backgroundColor = item.danger
        ? context.colorScheme.error
        : context.colorScheme.surfaceContainer;
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: LinearBorder.none,
        foregroundColor: foregroundColor,
        backgroundColor: backgroundColor,
      ),
      onPressed: onPressed != null
          ? () {
              Navigator.of(context).pop();
              onPressed();
            }
          : null,
      child: Container(
        constraints: BoxConstraints(minWidth: minWidth),
        padding: EdgeInsets.only(
          left: 16,
          right: 64,
          top: minItemVerticalPadding,
          bottom: minItemVerticalPadding,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            if (item.icon != null) ...[
              Icon(item.icon, size: fontSize + 4, color: foregroundColor),
              SizedBox(width: 16),
            ],
            Flexible(
              child: Text(
                item.label,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: foregroundColor,
                  fontSize: fontSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: IntrinsicWidth(
        child: Card(
          elevation: 12,
          color: context.colorScheme.surfaceContainer,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final item in items.asMap().entries) ...[
                _popupMenuItem(context, item: item.value, index: item.key),
                if (item.value != items.last) Divider(height: 0),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
