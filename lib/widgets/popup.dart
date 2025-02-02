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
    return builder(
      context,
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final align = Alignment.topRight;
    final animationValue = CurvedAnimation(
      parent: animation,
      curve: Curves.easeIn,
    ).value;
    return ValueListenableBuilder(
      valueListenable: offsetNotifier,
      builder: (_, value, child) {
        return Align(
          alignment: align,
          child: CustomSingleChildLayout(
            delegate: OverflowAwareLayoutDelegate(
              offset: value.translate(
                48,
                12,
              ),
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
              scale: 0.8 + 0.2 * animationValue,
              child: Transform.translate(
                offset: Offset(0, -10) * (1 - animationValue),
                child: child!,
              ),
            ),
          );
        },
        child: builder(
          context,
        ),
      ),
    );
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 150);
}

class CommonPopupBox extends StatefulWidget {
  final Widget target;
  final Widget popup;

  const CommonPopupBox({
    super.key,
    required this.target,
    required this.popup,
  });

  @override
  State<CommonPopupBox> createState() => CommonPopupBoxState();
}

class CommonPopupBoxState extends State<CommonPopupBox> {
  final _targetOffsetValueNotifier = ValueNotifier(Offset.zero);

  _handleTargetOffset() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return;
    }
    _targetOffsetValueNotifier.value = renderBox.localToGlobal(
      Offset.zero,
    );
  }

  pop() {
    _handleTargetOffset();
    Navigator.of(context).push(
      CommonPopupRoute(
        barrierLabel: other.id,
        builder: (BuildContext context) {
          return widget.popup;
        },
        offsetNotifier: _targetOffsetValueNotifier,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.target;
  }
}

class OverflowAwareLayoutDelegate extends SingleChildLayoutDelegate {
  final Offset offset;

  OverflowAwareLayoutDelegate({
    required this.offset,
  });

  @override
  Size getSize(BoxConstraints constraints) {
    return Size(constraints.maxWidth, constraints.maxHeight);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final saveOffset = Offset(16, 16);
    double x = (offset.dx - childSize.width).clamp(
      0,
      size.width - saveOffset.dx - childSize.width,
    );
    double y = (offset.dy).clamp(
      0,
      size.height - saveOffset.dy - childSize.height,
    );
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(covariant OverflowAwareLayoutDelegate oldDelegate) {
    return oldDelegate.offset != offset;
  }
}

class CommonPopupMenu extends StatelessWidget {
  final List<ActionItemData> items;

  const CommonPopupMenu({
    super.key,
    required this.items,
  });

  Widget _popupMenuItem(
    BuildContext context, {
    required ActionItemData item,
    required int index,
  }) {
    final isDanger = item.type == ActionType.danger;
    final color = isDanger
        ? context.colorScheme.error
        : context.colorScheme.onSurfaceVariant;
    return InkWell(
      hoverColor:
          isDanger ? context.colorScheme.errorContainer.withOpacity(0.3) : null,
      splashColor:
          isDanger ? context.colorScheme.errorContainer.withOpacity(0.4) : null,
      onTap: () {
        Navigator.of(context).pop();
        item.onPressed();
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 64,
          top: 14,
          bottom: 14,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            if (item.icon != null) ...[
              Icon(
                item.icon,
                size: item.iconSize ?? 18,
                color: color,
              ),
              SizedBox(
                width: 16,
              ),
            ],
            Flexible(
              child: Text(
                item.label,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: color,
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
          elevation: 8,
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
                _popupMenuItem(
                  context,
                  item: item.value,
                  index: item.key,
                ),
                if (item.value != items.last)
                  Divider(
                    height: 0,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
