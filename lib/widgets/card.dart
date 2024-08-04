import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
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

  const InfoHeader({
    super.key,
    required this.info,
    List<Widget>? actions,
  }) : actions = actions ?? const [];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (info.iconData != null) ...[
                  Icon(
                    info.iconData,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                ],
                Flexible(
                  child: TooltipText(
                    text: Text(
                      info.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              ],
            ),
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
    this.type = CommonCardType.plain,
    this.onPressed,
    this.info,
    this.selectWidget,
    this.radius = 12,
    required this.child,
  }) : isSelected = isSelected ?? false;

  final bool isSelected;
  final void Function()? onPressed;
  final Widget? selectWidget;
  final Widget child;
  final Info? info;
  final CommonCardType type;
  final double radius;

  BorderSide getBorderSide(BuildContext context, Set<WidgetState> states) {
    if (type == CommonCardType.filled) {
      return BorderSide.none;
    }
    final colorScheme = Theme.of(context).colorScheme;
    final hoverColor = isSelected
        ? colorScheme.primary.toLight()
        : colorScheme.primary.toLighter();
    if (states.contains(WidgetState.hovered) ||
        states.contains(WidgetState.focused) ||
        states.contains(WidgetState.pressed)) {
      return BorderSide(
        color: hoverColor,
      );
    }
    return BorderSide(
      color: isSelected ? colorScheme.primary : colorScheme.onSurface.toSoft(),
    );
  }

  Color? getBackgroundColor(BuildContext context, Set<WidgetState> states) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (type) {
      case CommonCardType.plain:
        if (isSelected) {
          return colorScheme.secondaryContainer;
        }
        if (states.isEmpty) {
          return colorScheme.secondaryContainer.toLittle();
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
        if (states.isEmpty) {
          return colorScheme.surfaceContainerLow;
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
            info: info!,
          ),
          Flexible(
            flex: 1,
            child: child,
          ),
        ],
      );
    }
    return OutlinedButton(
      clipBehavior: Clip.antiAlias,
      style: ButtonStyle(
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => getBackgroundColor(context, states),
        ),
        side: WidgetStateProperty.resolveWith(
          (states) => getBorderSide(context, states),
        ),
      ),
      onPressed: onPressed,
      child: Builder(
        builder: (_) {
          if (selectWidget == null) {
            return childWidget;
          }
          List<Widget> children = [];
          children.add(childWidget);
          if (isSelected) {
            children.add(
              Positioned.fill(
                child: selectWidget!,
              ),
            );
          }
          return Stack(
            children: children,
          );
        },
      ),
    );
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
