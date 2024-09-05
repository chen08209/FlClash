import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/open_container.dart';
import 'package:flutter/material.dart';

import 'card.dart';
import 'input.dart';
import 'sheet.dart';
import 'scaffold.dart';

class Delegate {
  const Delegate();
}

class RadioDelegate<T> extends Delegate {
  final T value;
  final T groupValue;
  final void Function(T?)? onChanged;

  const RadioDelegate({
    required this.value,
    required this.groupValue,
    this.onChanged,
  });
}

class SwitchDelegate<T> extends Delegate {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const SwitchDelegate({
    required this.value,
    this.onChanged,
  });
}

class CheckboxDelegate<T> extends Delegate {
  final bool value;
  final ValueChanged<bool?>? onChanged;

  const CheckboxDelegate({
    this.value = false,
    this.onChanged,
  });
}

class OpenDelegate extends Delegate {
  final Widget widget;
  final String title;
  final double? extendPageWidth;
  final bool isBlur;
  final bool isScaffold;

  const OpenDelegate({
    required this.title,
    required this.widget,
    this.extendPageWidth,
    this.isBlur = true,
    this.isScaffold = false,
  });
}

class NextDelegate extends Delegate {
  final Widget widget;
  final String title;
  final double? extendPageWidth;

  const NextDelegate({
    required this.title,
    required this.widget,
    this.extendPageWidth,
  });
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
  final String? resetValue;

  const InputDelegate({
    required this.title,
    required this.value,
    this.suffixText,
    required this.onChanged,
    this.resetValue,
  });
}

class ListItem<T> extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final EdgeInsets padding;
  final ListTileTitleAlignment tileTitleAlignment;
  final bool? prue;
  final Widget? trailing;
  final Delegate delegate;
  final double? horizontalTitleGap;
  final void Function()? onTap;

  const ListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.trailing,
    this.horizontalTitleGap,
    this.prue,
    this.onTap,
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
    this.prue,
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
    this.prue,
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
    this.prue,
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
    this.prue,
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
    this.prue,
    this.tileTitleAlignment = ListTileTitleAlignment.center,
  })  : trailing = null,
        onTap = null;

  const ListItem.switchItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.padding = const EdgeInsets.only(left: 16, right: 8),
    required SwitchDelegate<T> this.delegate,
    this.horizontalTitleGap,
    this.prue,
    this.tileTitleAlignment = ListTileTitleAlignment.center,
  })  : trailing = null,
        onTap = null;

  const ListItem.radio({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.only(left: 12, right: 16),
    required RadioDelegate<T> this.delegate,
    this.horizontalTitleGap = 8,
    this.prue,
    this.tileTitleAlignment = ListTileTitleAlignment.center,
  })  : leading = null,
        onTap = null;

  _buildListTile({
    void Function()? onTap,
    Widget? trailing,
    Widget? leading,
  }) {
    if (prue == true) {
      final List<Widget> children = [];
      if (leading != null) {
        children.add(leading);
        children.add(
          SizedBox(
            width: horizontalTitleGap,
          ),
        );
      }
      children.add(
        Expanded(
          child: title,
        ),
      );
      if (trailing != null) {
        children.add(
          SizedBox(
            width: horizontalTitleGap,
          ),
        );
        children.add(trailing);
      }
      return InkWell(
        splashFactory: NoSplash.splashFactory,
        onTap: onTap,
        child: Container(
          padding: padding,
          child: Row(
            children: children,
          ),
        ),
      );
    }
    return ListTile(
      leading: leading ?? this.leading,
      horizontalTitleGap: horizontalTitleGap,
      title: title,
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
      final child = SafeArea(
        child: openDelegate.widget,
      );
      return OpenContainer(
        closedBuilder: (_, action) {
          openAction() {
            final isMobile =
                globalState.appController.appState.viewMode == ViewMode.mobile;
            if (!isMobile) {
              showExtendPage(
                context,
                body: child,
                title: openDelegate.title,
                extendPageWidth: openDelegate.extendPageWidth,
                isBlur: openDelegate.isBlur,
                isScaffold: openDelegate.isScaffold,
              );
              return;
            }
            action();
          }

          return _buildListTile(
            onTap: openAction,
          );
        },
        openBuilder: (_, action) {
          return CommonScaffold.open(
            key: Key(openDelegate.title),
            onBack: action,
            title: openDelegate.title,
            body: child,
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
            ),
          );
          inputDelegate.onChanged(value);
        },
      );
    }
    if (delegate is NextDelegate) {
      final nextDelegate = delegate as NextDelegate;
      return _buildListTile(
        onTap: () {
          final isMobile =
              globalState.appController.appState.viewMode == ViewMode.mobile;
          if (!isMobile) {
            showExtendPage(
              context,
              body: nextDelegate.widget,
              title: nextDelegate.title,
              extendPageWidth: nextDelegate.extendPageWidth,
            );
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CommonScaffold(
                key: Key(nextDelegate.title),
                body: nextDelegate.widget,
                title: nextDelegate.title,
              ),
            ),
          );
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
        trailing: Checkbox(
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
        onTap: () {
          if (radioDelegate.onChanged != null) {
            radioDelegate.onChanged!(radioDelegate.value);
          }
        },
        leading: SizedBox(
          width: 32,
          height: 32,
          child: Radio<T>(
            value: radioDelegate.value,
            groupValue: radioDelegate.groupValue,
            onChanged: radioDelegate.onChanged,
          ),
        ),
        trailing: trailing,
      );
    }

    return _buildListTile(
      onTap: onTap,
    );
  }
}

class ListHeader extends StatelessWidget {
  final String title;
  final List<Widget> actions;

  const ListHeader({
    super.key,
    required this.title,
    List<Widget>? actions,
  }) : actions = actions ?? const [];

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ...actions,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<Widget> generateSection({
  required String title,
  required Iterable<Widget> items,
  List<Widget>? actions,
  bool separated = true,
}) {
  final genItems = separated
      ? items.separated(
          const Divider(
            height: 0,
          ),
        )
      : items;
  return [
    if (items.isNotEmpty)
      ListHeader(
        title: title,
        actions: actions,
      ),
    ...genItems,
  ];
}

List<Widget> generateInfoSection({
  required Info info,
  required Iterable<Widget> items,
  List<Widget>? actions,
  bool separated = true,
}) {
  final genItems = separated
      ? items.separated(
          const Divider(
            height: 0,
          ),
        )
      : items;
  return [
    if (items.isNotEmpty)
      InfoHeader(
        info: info,
        actions: actions,
      ),
    ...genItems,
  ];
}

Widget generateListView(List<Widget> items) {
  return ListView.builder(
    itemCount: items.length,
    itemBuilder: (_, index) => items[index],
    padding: const EdgeInsets.only(
      bottom: 16,
    ),
  );
}
