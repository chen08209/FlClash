import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/widgets/inherited.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

import 'card.dart';
import 'input.dart';
import 'open_container.dart';
import 'scaffold.dart';
import 'sheet.dart';
import 'sortable.dart';

part 'list_row_separator.dart';
part 'list_selected.dart';

sealed class _ListItemAction {
  const _ListItemAction();
}

final class _DefaultAction extends _ListItemAction {
  const _DefaultAction();
}

final class _RadioAction<T> extends _ListItemAction {
  final T value;
  final VoidCallback? onTap;

  const _RadioAction({required this.value, this.onTap});
}

final class _ToggleAction extends _ListItemAction {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _ToggleAction({required this.value, this.onChanged});
}

final class _CheckboxAction extends _ListItemAction {
  final bool value;
  final ValueChanged<bool?>? onChanged;

  const _CheckboxAction({required this.value, this.onChanged});
}

final class _OpenAction extends _ListItemAction {
  final Widget widget;
  final ValueChanged<dynamic>? onChanged;

  final bool forceFull;

  const _OpenAction({
    required this.widget,
    this.onChanged,
    required this.forceFull,
  });
}

final class _NextAction extends _ListItemAction {
  final Widget widget;

  const _NextAction({required this.widget});
}

final class _OptionsAction<T> extends _ListItemAction {
  final List<T> options;
  final String title;
  final T value;
  final String Function(T value) textBuilder;
  final ValueChanged<T?> onChanged;

  const _OptionsAction({
    required this.title,
    required this.options,
    required this.textBuilder,
    required this.value,
    required this.onChanged,
  });
}

final class _InputAction extends _ListItemAction {
  final String title;
  final String value;
  final String? suffixText;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String>? validator;
  final int? maxLength;
  final TextInputType? keyboardType;
  final String? resetValue;

  const _InputAction({
    required this.title,
    required this.value,
    this.suffixText,
    required this.onChanged,
    this.resetValue,
    this.validator,
    this.maxLength,
    this.keyboardType,
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
  final _ListItemAction _action;
  final double? horizontalTitleGap;
  final TextStyle? titleTextStyle;
  final TextStyle? subtitleTextStyle;
  final double minVerticalPadding;
  final Color? color;
  final double? minTileHeight;
  final VisualDensity? visualDensity;
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
    this.color,
    this.minTileHeight,
    this.visualDensity,
    this.minVerticalPadding = listRowVerticalPadding,
    this.tileTitleAlignment = ListTileTitleAlignment.center,
  }) : _action = const _DefaultAction();

  ListItem.open({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.trailing,
    required Widget widget,
    ValueChanged<dynamic>? onChanged,
    bool forceFull = true,
    this.horizontalTitleGap,
    this.dense,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.color,
    this.minTileHeight,
    this.visualDensity,
    this.minVerticalPadding = listRowVerticalPadding,
    this.tileTitleAlignment = ListTileTitleAlignment.center,
  }) : _action = _OpenAction(
         widget: widget,
         onChanged: onChanged,
         forceFull: forceFull,
       ),
       onTap = null;

  ListItem.next({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.trailing,
    required Widget widget,
    this.horizontalTitleGap,
    this.dense,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.color,
    this.minTileHeight,
    this.visualDensity,
    this.minVerticalPadding = listRowVerticalPadding,
    this.tileTitleAlignment = ListTileTitleAlignment.center,
  }) : _action = _NextAction(widget: widget),
       onTap = null;

  ListItem.options({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.trailing,
    required String dialogTitle,
    required List<T> options,
    required T value,
    required String Function(T value) textBuilder,
    required ValueChanged<T?> onChanged,
    this.horizontalTitleGap,
    this.dense,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.color,
    this.minTileHeight,
    this.visualDensity,
    this.minVerticalPadding = listRowVerticalPadding,
    this.tileTitleAlignment = ListTileTitleAlignment.center,
  }) : _action = _OptionsAction<T>(
         title: dialogTitle,
         options: options,
         value: value,
         textBuilder: textBuilder,
         onChanged: onChanged,
       ),
       onTap = null;

  ListItem.input({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.trailing,
    required String dialogTitle,
    required String value,
    String? suffixText,
    required ValueChanged<String?> onChanged,
    FormFieldValidator<String>? validator,
    int? maxLength,
    TextInputType? keyboardType,
    String? resetValue,
    this.horizontalTitleGap,
    this.dense,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.color,
    this.minTileHeight,
    this.visualDensity,
    this.minVerticalPadding = listRowVerticalPadding,
    this.tileTitleAlignment = ListTileTitleAlignment.center,
  }) : _action = _InputAction(
         title: dialogTitle,
         value: value,
         suffixText: suffixText,
         onChanged: onChanged,
         validator: validator,
         maxLength: maxLength,
         keyboardType: keyboardType,
         resetValue: resetValue,
       ),
       onTap = null;

  ListItem.checkbox({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.padding = const EdgeInsets.only(left: 16, right: 8),
    bool value = false,
    ValueChanged<bool?>? onChanged,
    this.horizontalTitleGap,
    this.dense,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.color,
    this.minTileHeight,
    this.visualDensity,
    this.minVerticalPadding = listRowVerticalPadding,
    this.tileTitleAlignment = ListTileTitleAlignment.center,
  }) : _action = _CheckboxAction(value: value, onChanged: onChanged),
       trailing = null,
       onTap = null;

  ListItem.toggle({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.padding = const EdgeInsets.only(left: 16, right: 8),
    required bool value,
    ValueChanged<bool>? onChanged,
    this.horizontalTitleGap,
    this.dense,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.color,
    this.minTileHeight,
    this.visualDensity,
    this.minVerticalPadding = listRowVerticalPadding,
    this.tileTitleAlignment = ListTileTitleAlignment.center,
  }) : _action = _ToggleAction(value: value, onChanged: onChanged),
       trailing = null,
       onTap = null;

  ListItem.radio({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.only(left: 12, right: 16),
    required T value,
    VoidCallback? onTap,
    this.horizontalTitleGap = 8,
    this.dense,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.color,
    this.minTileHeight,
    this.visualDensity,
    this.minVerticalPadding = listRowVerticalPadding,
    this.tileTitleAlignment = ListTileTitleAlignment.center,
  }) : _action = _RadioAction<T>(value: value, onTap: onTap),
       leading = null,
       onTap = null;

  Widget _buildListTile(
    BuildContext context, {
    required ItemPosition? position,
    required WidgetStatesController? rowStates,
    void Function()? onTap,
    Widget? trailing,
    Widget? leading,
  }) {
    if (position != null) {
      // OpenContainer reparents the closed tile out of the section's provider.
      return ItemPositionProvider(
        position: position,
        child: DecorationListItem(
          leading: leading ?? this.leading,
          title: title,
          subtitle: subtitle,
          trailing: trailing ?? this.trailing,
          contentPadding: padding,
          horizontalTitleGap: horizontalTitleGap,
          onPressed: onTap,
        ),
      );
    }
    return ListTile(
      key: key,
      dense: dense,
      visualDensity: visualDensity,
      tileColor: color,
      titleTextStyle: titleTextStyle ?? context.listTitleStyle,
      subtitleTextStyle: subtitleTextStyle ?? context.listSubtitleStyle,
      leading: leading ?? this.leading,
      horizontalTitleGap: horizontalTitleGap,
      title: rowStates == null ? title : _ListRowSeparatorStart(child: title),
      minTileHeight: minTileHeight ?? listRowMinHeight,
      minVerticalPadding: minVerticalPadding,
      subtitle: subtitle,
      titleAlignment: tileTitleAlignment,
      onTap: onTap,
      statesController: rowStates,
      trailing: trailing ?? this.trailing,
      contentPadding: padding,
    );
  }

  @override
  Widget build(BuildContext context) {
    final position = ItemPositionProvider.of(context)?.position;
    final rowStates = _SeparatedListRow.statesOf(context);
    switch (_action) {
      case final _OpenAction openDelegate:
        final child = openDelegate.widget;
        final onChanged = openDelegate.onChanged;
        if (!context.isMobileView) {
          return _buildListTile(
            context,
            position: position,
            rowStates: rowStates,
            onTap: () async {
              final result = await showExtend<dynamic>(
                context,
                props: ExtendProps(forceFull: openDelegate.forceFull),
                builder: (_) => child,
              );
              onChanged?.call(result);
            },
          );
        }
        return OpenContainer<dynamic>(
          tappable: false,
          clipBehavior: Clip.none,
          closedBuilder: (context, action) {
            return _buildListTile(
              context,
              position: position,
              rowStates: rowStates,
              onTap: action,
            );
          },
          onClosed: onChanged,
          openBuilder: (_, action) {
            return child;
          },
        );
      case final _NextAction nextDelegate:
        final child = nextDelegate.widget;

        return _buildListTile(
          context,
          position: position,
          rowStates: rowStates,
          onTap: () {
            showExtend(
              context,
              builder: (_) {
                return child;
              },
            );
          },
        );
      case final _OptionsAction options:
        final optionsDelegate = options as _OptionsAction<T>;
        return _buildListTile(
          context,
          position: position,
          rowStates: rowStates,
          onTap: () async {
            // Options are boxed so that a nullable option such as the default
            // locale stays distinct from the null a dismissed dialog returns.
            final selected = await dialogs.showCommonDialog<(T,)>(
              child: OptionsDialog<(T,)>(
                title: optionsDelegate.title,
                options: [
                  for (final option in optionsDelegate.options) (option,),
                ],
                textBuilder: (option) => optionsDelegate.textBuilder(option.$1),
                value: (optionsDelegate.value,),
              ),
            );
            if (selected == null) {
              return;
            }
            optionsDelegate.onChanged(selected.$1);
          },
        );
      case final _InputAction inputDelegate:
        return _buildListTile(
          context,
          position: position,
          rowStates: rowStates,
          onTap: () async {
            final value = await dialogs.showCommonDialog<String>(
              child: InputDialog(
                title: inputDelegate.title,
                value: inputDelegate.value,
                suffixText: inputDelegate.suffixText,
                resetValue: inputDelegate.resetValue,
                inputFormatters: inputDelegate.maxLength == null
                    ? null
                    : TextInputLimits.limit(inputDelegate.maxLength!),
                keyboardType: inputDelegate.keyboardType,
                validator: inputDelegate.validator,
              ),
            );
            inputDelegate.onChanged(value);
          },
        );
      case final _CheckboxAction checkboxDelegate:
        return _buildListTile(
          context,
          position: position,
          rowStates: rowStates,
          onTap: checkboxDelegate.onChanged == null
              ? null
              : () {
                  checkboxDelegate.onChanged!(!checkboxDelegate.value);
                },
          trailing: CommonCheckBox(
            value: checkboxDelegate.value,
            onChanged: checkboxDelegate.onChanged,
          ),
        );
      case final _ToggleAction toggleAction:
        return _buildListTile(
          context,
          position: position,
          rowStates: rowStates,
          onTap: toggleAction.onChanged == null
              ? null
              : () {
                  toggleAction.onChanged!(!toggleAction.value);
                },
          trailing: Switch(
            value: toggleAction.value,
            onChanged: toggleAction.onChanged,
          ),
        );
      case final _RadioAction radio:
        final radioDelegate = radio as _RadioAction<T>;
        return _buildListTile(
          context,
          position: position,
          rowStates: rowStates,
          onTap: radioDelegate.onTap,
          leading: ExcludeFocus(
            child: Radio<T>(
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              value: radioDelegate.value,
              toggleable: true,
            ),
          ),
          trailing: trailing,
        );
      case _DefaultAction():
        return _buildListTile(
          context,
          position: position,
          rowStates: rowStates,
          onTap: onTap,
        );
    }
  }
}

class ListHeader extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final EdgeInsets? padding;
  final double? space;

  const ListHeader({
    super.key,
    required this.title,
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
        spacing: actions.isEmpty ? 0 : 12,
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.sectionHeaderStyle,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: space ?? appBarActionSpace,
            children: [...actions],
          ),
        ],
      ),
    );
  }
}

class ListFooter extends StatelessWidget {
  final String text;

  const ListFooter({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: 16.mAp, right: 16.mAp, top: 8.mAp),
      child: Text(
        text,
        style: context.textTheme.bodySmall
            ?.adjustSize(1)
            .copyWith(
              height: 18 / 13,
              color: context.colorScheme.onSurfaceVariant,
            ),
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
  final genItems = separated ? _separatedRows(items) : items;
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

Iterable<Widget> _separatedRows(Iterable<Widget> items) {
  final last = items.length - 1;
  return items.mapIndexed(
    (index, item) => _SeparatedListRow(separated: index < last, child: item),
  );
}

Widget generateSectionV3({
  String? title,
  required Iterable<Widget> items,
  List<Widget>? actions,
  String? footer,
}) {
  final genItems = items.mapIndexed<Widget>(
    (index, item) => ItemPositionProvider(
      position: ItemPosition.get(index, items.length),
      child: item,
    ),
  );
  return Column(
    children: [
      if (items.isNotEmpty && title != null)
        ListHeader(title: title, actions: actions),
      Column(children: [...genItems]),
      if (items.isNotEmpty && footer != null) ListFooter(text: footer),
    ],
  );
}

List<Widget> generateInfoSection({
  required Info info,
  required Iterable<Widget> items,
  List<Widget>? actions,
  bool separated = true,
}) {
  final genItems = separated ? _separatedRows(items) : items;
  return [
    if (items.isNotEmpty) InfoHeader(info: info, actions: actions),
    ...genItems,
  ];
}

Widget generateListView(List<Widget> items, {double topPadding = 0}) {
  return ListView.builder(
    itemCount: items.length,
    itemBuilder: (_, index) => items[index],
    padding: EdgeInsets.only(top: topPadding, bottom: 16),
  );
}
