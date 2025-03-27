import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/widgets/fade_box.dart';
import 'package:flutter/material.dart';

import 'text.dart';

class Info {
  final String label;
  final IconData? iconData;

  const Info({
    required this.label,
    this.iconData,
  });
}

class InfoHeader extends StatelessWidget {
  final Info info;
  final List<Widget> actions;
  final EdgeInsetsGeometry? padding;

  const InfoHeader({
    super.key,
    required this.info,
    this.padding,
    List<Widget>? actions,
  }) : actions = actions ?? const [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? baseInfoEdgeInsets,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 1,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                if (info.iconData != null) ...[
                  Icon(
                    info.iconData,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                ],
                Flexible(
                  flex: 1,
                  child: TooltipText(
                    text: Text(
                      info.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ...actions,
            ],
          ),
        ],
      ),
    );
  }
}

class CommonCard extends StatelessWidget {
  const CommonCard({
    super.key,
    bool? isSelected,
    this.type = CommonCardType.filled,
    this.onPressed,
    this.selectWidget,
    this.backgroundColor,
    this.radius = 12,
    required this.child,
    this.enterAnimated = false,
    this.borderSide,
    this.info,
  }) : isSelected = isSelected ?? false;

  final bool enterAnimated;
  final bool isSelected;
  final void Function()? onPressed;
  final Widget? selectWidget;
  final Widget child;
  final Info? info;
  final CommonCardType type;
  final double radius;
  final WidgetStateProperty<Color?>? backgroundColor;
  final WidgetStateProperty<BorderSide?>? borderSide;

  BorderSide getBorderSide(BuildContext context, Set<WidgetState> states) {
    final colorScheme = context.colorScheme;
    // if (type == CommonCardType.filled) {
    //   return BorderSide.none;
    // }
    final hoverColor = isSelected
        ? colorScheme.primary.toLight
        : colorScheme.primary.toLighter;
    if (states.contains(WidgetState.hovered) ||
        states.contains(WidgetState.focused) ||
        states.contains(WidgetState.pressed)) {
      return BorderSide(
        color: hoverColor,
      );
    }
    return BorderSide(
      color: isSelected ? colorScheme.primary : colorScheme.onSurface.toSoft,
    );
  }

  Color? getBackgroundColor(BuildContext context, Set<WidgetState> states) {
    final colorScheme = context.colorScheme;
    switch (type) {
      case CommonCardType.plain:
        if (isSelected) {
          return colorScheme.secondaryContainer;
        }
        if (states.isEmpty) {
          return colorScheme.surface;
        }
        return Theme.of(context)
            .outlinedButtonTheme
            .style
            ?.backgroundColor
            ?.resolve(states);
      case CommonCardType.filled:
        if (isSelected) {
          return colorScheme.secondaryContainer;
        }
        return colorScheme.surfaceContainer;
    }
  }

  @override
  Widget build(BuildContext context) {
    var childWidget = child;

    if (info != null) {
      childWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InfoHeader(
            padding: baseInfoEdgeInsets.copyWith(
              bottom: 0,
            ),
            info: info!,
          ),
          Flexible(
            flex: 1,
            child: child,
          ),
        ],
      );
    }

    if (selectWidget != null && isSelected) {
      final List<Widget> children = [];
      children.add(childWidget);
      children.add(
        Positioned.fill(
          child: selectWidget!,
        ),
      );
      childWidget = Stack(
        children: children,
      );
    }

    final card = OutlinedButton(
      clipBehavior: Clip.antiAlias,
      style: ButtonStyle(
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        iconColor: WidgetStatePropertyAll(context.colorScheme.primary),
        iconSize: WidgetStateProperty.all(20),
        backgroundColor: backgroundColor ??
            WidgetStateProperty.resolveWith(
              (states) => getBackgroundColor(context, states),
            ),
        side: borderSide ??
            WidgetStateProperty.resolveWith(
              (states) => getBorderSide(context, states),
            ),
      ),
      onPressed: onPressed,
      child: childWidget,
    );

    return switch (enterAnimated) {
      true => FadeScaleEnterBox(
          child: card,
        ),
      false => card,
    };
  }
}

class SelectIcon extends StatelessWidget {
  const SelectIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.inversePrimary,
      shape: const CircleBorder(),
      child: Container(
        padding: const EdgeInsets.all(4),
        child: const Icon(
          Icons.check,
          size: 16,
        ),
      ),
    );
  }
}
