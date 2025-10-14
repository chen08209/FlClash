import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';

import 'card.dart';
import 'input.dart';
import 'open_container.dart';
import 'scaffold.dart';
import 'sheet.dart';

class Delegate {
  const Delegate();
}

class RadioDelegate<T> extends Delegate {
  final T value;
  final void Function()? onTab;

  const RadioDelegate({required this.value, this.onTab});
}

class SwitchDelegate<T> extends Delegate {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const SwitchDelegate({required this.value, this.onChanged});
}

class CheckboxDelegate<T> extends Delegate {
  final bool value;
  final ValueChanged<bool?>? onChanged;

  const CheckboxDelegate({this.value = false, this.onChanged});
}

class OpenDelegate<T> extends Delegate {
  final Widget widget;
  final double? maxWidth;
  final bool blur;
  final bool forceFull;
  final ValueChanged<T?>? onChanged;

  const OpenDelegate({
    required this.widget,
    this.maxWidth,
    this.blur = true,
    this.forceFull = true,
    this.onChanged,
  });
}

class NextDelegate extends Delegate {
  final Widget widget;
  final double? maxWidth;
  final bool blur;

  const NextDelegate({required this.widget, this.maxWidth, this.blur = true});
}

class OptionsDelegate<T> extends Delegate {
  final List<T> options;
  final String title;
  final T value;
  final String Function(T value) textBuilder;
  final Function(T? value) onChanged;

  const OptionsDelegate({
    required this.title,
    required this.options,
    required this.textBuilder,
    required this.value,
    required this.onChanged,
  });
}

class InputDelegate extends Delegate {
  final String title;
  final String value;
  final String? suffixText;
  final Function(String? value) onChanged;
  final FormFieldValidator<String>? validator;

  final String? resetValue;

  const InputDelegate({
    required this.title,
    required this.value,
    this.suffixText,
    required this.onChanged,
    this.resetValue,
    this.validator,
  });
}

class ListItem<T> extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final EdgeInsets padding;
  final ListTileTitleAlignment tileTitleAlignment;
  final bool? dense;
  final Widget? trailing;
  final Delegate delegate;
  final double? horizontalTitleGap;
  final TextStyle? titleTextStyle;
  final TextStyle? subtitleTextStyle;
  final double minVerticalPadding;
  final void Function()? onTap;

  const ListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.trailing,
    this.horizontalTitleGap,
    this.dense,
    this.onTap,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.minVerticalPadding = 12,
    this.tileTitleAlignment = ListTileTitleAlignment.center,
  }) : delegate = const Delegate();

  const ListItem.open({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.trailing,
    required OpenDelegate this.delegate,
    this.horizontalTitleGap,
    this.dense,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.minVerticalPadding = 12,
    this.tileTitleAlignment = ListTileTitleAlignment.center,
  }) : onTap = null;

  const ListItem.next({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.trailing,
    required NextDelegate this.delegate,
    this.horizontalTitleGap,
    this.dense,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.minVerticalPadding = 12,
    this.tileTitleAlignment = ListTileTitleAlignment.center,
  }) : onTap = null;

  const ListItem.options({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.trailing,
    required OptionsDelegate<T> this.delegate,
    this.horizontalTitleGap,
    this.dense,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.minVerticalPadding = 12,
    this.tileTitleAlignment = ListTileTitleAlignment.center,
  }) : onTap = null;

  const ListItem.input({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.trailing,
    required InputDelegate this.delegate,
    this.horizontalTitleGap,
    this.dense,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.minVerticalPadding = 12,
    this.tileTitleAlignment = ListTileTitleAlignment.center,
  }) : onTap = null;

  const ListItem.checkbox({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.padding = const EdgeInsets.only(left: 16, right: 8),
    required CheckboxDelegate<T> this.delegate,
    this.horizontalTitleGap,
    this.dense,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.minVerticalPadding = 12,
    this.tileTitleAlignment = ListTileTitleAlignment.center,
  }) : trailing = null,
       onTap = null;

  const ListItem.switchItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.padding = const EdgeInsets.only(left: 16, right: 8),
    required SwitchDelegate<T> this.delegate,
    this.horizontalTitleGap,
    this.dense,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.minVerticalPadding = 12,
    this.tileTitleAlignment = ListTileTitleAlignment.center,
  }) : trailing = null,
       onTap = null;

  const ListItem.radio({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.only(left: 12, right: 16),
    required RadioDelegate<T> this.delegate,
    this.horizontalTitleGap = 8,
    this.dense,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.minVerticalPadding = 12,
    this.tileTitleAlignment = ListTileTitleAlignment.center,
  }) : leading = null,
       onTap = null;

  Widget _buildListTile({
    void Function()? onTap,
    Widget? trailing,
    Widget? leading,
  }) {
    return ListTile(
      key: key,
      dense: dense,
      titleTextStyle: titleTextStyle,
      subtitleTextStyle: subtitleTextStyle,
      leading: leading ?? this.leading,
      horizontalTitleGap: horizontalTitleGap,
      title: title,
      minVerticalPadding: minVerticalPadding,
      subtitle: subtitle,
      titleAlignment: tileTitleAlignment,
      onTap: onTap,
      trailing: trailing ?? this.trailing,
      contentPadding: padding,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (delegate is OpenDelegate) {
      final openDelegate = delegate as OpenDelegate;
      final child = openDelegate.widget;
      final onChanged = openDelegate.onChanged;
      return OpenContainer<T>(
        // closedColor: context.colorScheme.surface,
        // openColor: context.colorScheme.surface,
        // closedElevation: 0,
        // openElevation: 0,
        closedBuilder: (_, action) {
          openAction() async {
            final isMobile = globalState.appState.viewMode == ViewMode.mobile;
            if (!isMobile) {
              final res = await showExtend(
                context,
                props: ExtendProps(
                  blur: openDelegate.blur,
                  maxWidth: openDelegate.maxWidth,
                  forceFull: openDelegate.forceFull,
                ),
                builder: (_, type) {
                  return child;
                },
              );
              if (onChanged != null) {
                onChanged(res);
              }
              return;
            }
            action();
          }

          return _buildListTile(onTap: openAction);
        },
        onClosed: onChanged,
        openBuilder: (_, action) {
          return child;
        },
      );
    }
    if (delegate is NextDelegate) {
      final nextDelegate = delegate as NextDelegate;
      final child = nextDelegate.widget;

      return _buildListTile(
        onTap: () {
          showExtend(
            context,
            props: ExtendProps(
              blur: nextDelegate.blur,
              maxWidth: nextDelegate.maxWidth,
            ),
            builder: (_, type) {
              return child;
            },
          );
        },
      );
    }
    if (delegate is OptionsDelegate) {
      final optionsDelegate = delegate as OptionsDelegate<T>;
      return _buildListTile(
        onTap: () async {
          final value = await globalState.showCommonDialog<T>(
            child: OptionsDialog<T>(
              title: optionsDelegate.title,
              options: optionsDelegate.options,
              textBuilder: optionsDelegate.textBuilder,
              value: optionsDelegate.value,
            ),
          );
          optionsDelegate.onChanged(value);
        },
      );
    }
    if (delegate is InputDelegate) {
      final inputDelegate = delegate as InputDelegate;
      return _buildListTile(
        onTap: () async {
          final value = await globalState.showCommonDialog<String>(
            child: InputDialog(
              title: inputDelegate.title,
              value: inputDelegate.value,
              suffixText: inputDelegate.suffixText,
              resetValue: inputDelegate.resetValue,
              validator: inputDelegate.validator,
            ),
          );
          inputDelegate.onChanged(value);
        },
      );
    }
    if (delegate is CheckboxDelegate) {
      final checkboxDelegate = delegate as CheckboxDelegate;
      return _buildListTile(
        onTap: () {
          if (checkboxDelegate.onChanged != null) {
            checkboxDelegate.onChanged!(!checkboxDelegate.value);
          }
        },
        trailing: CommonCheckBox(
          value: checkboxDelegate.value,
          onChanged: checkboxDelegate.onChanged,
        ),
      );
    }
    if (delegate is SwitchDelegate) {
      final switchDelegate = delegate as SwitchDelegate;
      return _buildListTile(
        onTap: () {
          if (switchDelegate.onChanged != null) {
            switchDelegate.onChanged!(!switchDelegate.value);
          }
        },
        trailing: Switch(
          value: switchDelegate.value,
          onChanged: switchDelegate.onChanged,
        ),
      );
    }
    if (delegate is RadioDelegate) {
      final radioDelegate = delegate as RadioDelegate<T>;
      return _buildListTile(
        onTap: radioDelegate.onTab,
        leading: Radio<T>(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          value: radioDelegate.value,
          toggleable: true,
        ),
        trailing: trailing,
      );
    }

    return _buildListTile(onTap: onTap);
  }
}

class ListHeader extends StatelessWidget {
  final String title;
  final String? subTitle;
  final List<Widget> actions;
  final EdgeInsets? padding;
  final double? space;

  const ListHeader({
    super.key,
    required this.title,
    this.subTitle,
    this.padding,
    List<Widget>? actions,
    this.space,
  }) : actions = actions ?? const [];

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: padding ?? listHeaderPadding,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: context.colorScheme.onSurfaceVariant.opacity80,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subTitle != null)
                  Text(
                    subTitle!,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.outline,
                    ),
                  ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [...genActions(actions, space: space)],
          ),
        ],
      ),
    );
  }
}

List<Widget> generateSection({
  String? title,
  required Iterable<Widget> items,
  List<Widget>? actions,
  bool isFirst = false,
  bool separated = true,
}) {
  final genItems = separated
      ? items.separated(const Divider(height: 0))
      : items;
  return [
    if (items.isNotEmpty && title != null)
      ListHeader(
        title: title,
        actions: actions,
        padding: isFirst
            ? listHeaderPadding.copyWith(top: 8.ap)
            : listHeaderPadding,
      ),
    ...genItems,
  ];
}

Widget generateSectionV2({
  String? title,
  required Iterable<Widget> items,
  List<Widget>? actions,
  bool separated = true,
}) {
  final genItems = items
      .map<Widget>((item) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: CommonCard(
            type: CommonCardType.filled,
            radius: 0,
            child: item,
          ),
        );
      })
      .separated(const Divider(height: 2, color: Colors.transparent));
  return Column(
    children: [
      if (items.isNotEmpty && title != null)
        ListHeader(title: title, actions: actions),
      ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(children: [...genItems]),
      ),
    ],
  );
}

List<Widget> generateInfoSection({
  required Info info,
  required Iterable<Widget> items,
  List<Widget>? actions,
  bool separated = true,
}) {
  final genItems = separated
      ? items.separated(const Divider(height: 0))
      : items;
  return [
    if (items.isNotEmpty) InfoHeader(info: info, actions: actions),
    ...genItems,
  ];
}

Widget generateListView(List<Widget> items) {
  return ListView.builder(
    itemCount: items.length,
    itemBuilder: (_, index) => items[index],
    padding: const EdgeInsets.only(bottom: 16),
  );
}

class CommonSelectedListItem extends StatelessWidget {
  final bool isSelected;
  final bool isEditing;
  final Widget title;
  final VoidCallback onSelected;
  final VoidCallback onPressed;

  const CommonSelectedListItem({
    super.key,
    required this.isSelected,
    required this.onSelected,
    this.isEditing = false,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        color: Colors.transparent,
        child: CommonCard(
          padding: EdgeInsets.zero,
          radius: 18,
          type: CommonCardType.filled,
          isSelected: isSelected,
          onPressed: () {
            if (isEditing) {
              onSelected();
              return;
            }
            onPressed();
          },
          child: ListTile(
            minTileHeight: 32 + globalState.measure.bodyMediumHeight,
            minVerticalPadding: 12,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            trailing: SizedBox(
              width: 24,
              height: 24,
              child: CommonCheckBox(
                value: isSelected,
                isCircle: true,
                onChanged: (_) {
                  onSelected();
                },
              ),
            ),
            title: title,
          ),
        ),
      ),
    );
  }
}

class CommonInputListItem extends StatelessWidget {
  final bool isDecorator;
  final bool isFirst;
  final bool isLast;
  final Widget? title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool? isSelected;
  final VoidCallback? onPressed;

  const CommonInputListItem({
    super.key,
    this.isDecorator = false,
    this.isFirst = false,
    this.isLast = false,
    this.title,
    this.leading,
    this.trailing,
    this.subtitle,
    this.isSelected,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: ShapeDecoration(
        shape: isDecorator == true
            ? LinearBorder.none
            : RoundedSuperellipseBorder(
                borderRadius: BorderRadius.vertical(
                  top: isFirst ? Radius.circular(24) : Radius.zero,
                  bottom: isLast ? Radius.circular(24) : Radius.zero,
                ),
              ),
      ),
      child: CommonCard(
        radius: 0,
        isSelected: isSelected,
        type: CommonCardType.filled,
        onPressed: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ListTile(
                leading: leading,
                contentPadding: const EdgeInsets.only(right: 16, left: 16),
                title: title,
                subtitle: subtitle,
                minVerticalPadding: 14,
                trailing: trailing,
              ),
            ),
            if (isDecorator != true && !isLast)
              Divider(height: 0, indent: 14, endIndent: 14),
          ],
        ),
      ),
    );
  }
}

class CommonSelectedInputListItem extends StatelessWidget {
  final bool isSelected;
  final bool isEditing;
  final Widget title;
  final Widget? subtitle;
  final VoidCallback onSelected;
  final VoidCallback onPressed;
  final bool isFirst;
  final bool isLast;
  final bool isDecorator;
  final Widget? leading;

  const CommonSelectedInputListItem({
    super.key,
    required this.isSelected,
    required this.onSelected,
    this.isEditing = false,
    required this.title,
    required this.onPressed,
    this.isFirst = false,
    this.isLast = false,
    this.isDecorator = false,
    this.subtitle,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return CommonInputListItem(
      title: title,
      isDecorator: isDecorator,
      isSelected: isSelected,
      isFirst: isFirst,
      isLast: isLast,
      leading: leading,
      onPressed: isDecorator
          ? null
          : () {
              if (isEditing) {
                onSelected();
                return;
              }
              onPressed();
            },
      subtitle: subtitle,
      trailing: SizedBox(
        width: 24,
        height: 24,
        child: CommonCheckBox(
          value: isSelected,
          isCircle: true,
          onChanged: (_) {
            onSelected();
          },
        ),
      ),
    );
  }
}
