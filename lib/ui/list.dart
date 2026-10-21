import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:fl_clash/common/input_limits.dart';
import 'package:fl_clash/ui/context.dart';
import 'package:fl_clash/ui/dialog.dart';
import 'package:fl_clash/ui/focus.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/inherited.dart';
import 'package:fl_clash/ui/input.dart';
import 'package:fl_clash/ui/item_position.dart';
import 'package:fl_clash/ui/measure.dart';
import 'package:fl_clash/ui/metrics.dart';
import 'package:fl_clash/ui/models.dart';
import 'package:fl_clash/ui/shape.dart';
import 'package:fl_clash/ui/typography.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

import 'button.dart';
import 'card.dart';
import 'navigation_dock.dart';
import 'open_container.dart';
import 'popup.dart';
import 'scaffold.dart';
import 'sheet.dart';
import 'sortable.dart';
import 'switch.dart';

part 'list_row_separator.dart';
part 'list_selected.dart';

sealed class _ListItemAction {
  const _ListItemAction();
}

final class _DefaultAction extends _ListItemAction {
  const _DefaultAction();
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
  final T value;
  final String Function(T value) textBuilder;
  final ValueChanged<T> onChanged;

  const _OptionsAction({
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
  final Widget? trailing;
  final _ListItemAction _action;
  final double? horizontalTitleGap;
  final double minVerticalPadding;
  final Color? color;
  final double? minTileHeight;
  final void Function()? onTap;

  const ListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.trailing,
    this.horizontalTitleGap,
    this.onTap,
    this.color,
    this.minTileHeight,
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
    this.color,
    this.minTileHeight,
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
    this.color,
    this.minTileHeight,
    this.minVerticalPadding = listRowVerticalPadding,
    this.tileTitleAlignment = ListTileTitleAlignment.center,
  }) : _action = _NextAction(widget: widget),
       onTap = null;

  ListItem.options({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.padding = const EdgeInsets.only(left: 16, right: 8),
    required List<T> options,
    required T value,
    required String Function(T value) textBuilder,
    required ValueChanged<T> onChanged,
    this.horizontalTitleGap,
    this.color,
    this.minTileHeight,
    this.minVerticalPadding = listRowVerticalPadding,
    this.tileTitleAlignment = ListTileTitleAlignment.center,
  }) : _action = _OptionsAction<T>(
         options: options,
         value: value,
         textBuilder: textBuilder,
         onChanged: onChanged,
       ),
       trailing = null,
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
    this.color,
    this.minTileHeight,
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
    this.color,
    this.minTileHeight,
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
    this.color,
    this.minTileHeight,
    this.minVerticalPadding = listRowVerticalPadding,
    this.tileTitleAlignment = ListTileTitleAlignment.center,
  }) : _action = _ToggleAction(value: value, onChanged: onChanged),
       trailing = null,
       onTap = null;

  Widget _buildListTile(
    BuildContext context, {
    required ItemPosition? position,
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
      tileColor: color,
      titleTextStyle: context.listTitleStyle,
      subtitleTextStyle: context.listSubtitleStyle,
      leading: leading ?? this.leading,
      horizontalTitleGap: horizontalTitleGap,
      title: title,
      minTileHeight: minTileHeight ?? listRowMinHeight,
      minVerticalPadding: minVerticalPadding,
      subtitle: subtitle,
      titleAlignment: tileTitleAlignment,
      onTap: onTap,
      trailing: trailing ?? this.trailing,
      contentPadding: padding,
    );
  }

  Widget get _pageTrailing =>
      trailing ?? const GlyphIcon(AppGlyphs.chevronForward);

  @override
  Widget build(BuildContext context) {
    final position = ItemPositionProvider.of(context)?.position;
    switch (_action) {
      case final _OpenAction openDelegate:
        final child = openDelegate.widget;
        final onChanged = openDelegate.onChanged;
        if (!context.isMobileView) {
          return _buildListTile(
            context,
            position: position,
            trailing: _pageTrailing,
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
          clipBehavior: Clip.none,
          closedBuilder: (context, action) {
            return _buildListTile(
              context,
              position: position,
              trailing: _pageTrailing,
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
          trailing: _pageTrailing,
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
        PopupOpen? openMenu;
        return _buildListTile(
          context,
          position: position,
          // As an iOS pop-up row does, a tap anywhere on the row opens the
          // menu out of its value.
          onTap: () => openMenu?.call(),
          trailing: CommonPopupBox(
            targetBuilder: (open) {
              openMenu = open;
              return _OptionsValueButton(
                label: optionsDelegate.textBuilder(optionsDelegate.value),
                onPressed: open,
              );
            },
            popupBuilder: (_) => CommonPopupMenu(
              items: [
                for (final option in optionsDelegate.options)
                  CommonPopupMenuItem(
                    label: optionsDelegate.textBuilder(option),
                    checked: option == optionsDelegate.value,
                    onPressed: () => optionsDelegate.onChanged(option),
                  ),
              ],
            ),
          ),
        );
      case final _InputAction inputDelegate:
        return _buildListTile(
          context,
          position: position,
          onTap: () async {
            final value = await showFloatingDialog<String>(
              context: Navigator.of(context, rootNavigator: true).context,
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
          onTap: toggleAction.onChanged == null
              ? null
              : () {
                  toggleAction.onChanged!(!toggleAction.value);
                },
          trailing: CommonSwitch(
            value: toggleAction.value,
            onChanged: toggleAction.onChanged,
          ),
        );
      case _DefaultAction():
        return _buildListTile(context, position: position, onTap: onTap);
    }
  }
}

const _optionsValueMaxWidth = 160.0;

class _OptionsValueButton extends StatelessWidget {
  const _OptionsValueButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: context.colorScheme.onSurfaceVariant,
        textStyle: context.listTitleStyle,
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _optionsValueMaxWidth),
            child: PopupValueText(
              label,
              alignment: AlignmentDirectional.centerEnd,
            ),
          ),
          const GlyphIcon(AppGlyphs.picker),
        ],
      ),
    );
  }
}

/// A section's title, as tall as its action buttons with or without them.
class ListHeader extends StatelessWidget {
  static const _actionSize = TonalButtonSize.section;
  static const _actionsGap = 6.0;

  final String title;
  final List<IconButtonData> actions;
  final Widget? trailing;
  final EdgeInsets? padding;

  const ListHeader({
    super.key,
    required this.title,
    this.padding,
    this.actions = const [],
    this.trailing,
  });

  Widget _buildActions() {
    final grouped = actions.length > 1 ? actions.take(2) : null;
    return TonalButtonTheme(
      size: _actionSize,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: appBarActionSpace,
        children: [
          if (grouped != null)
            TonalButtonGroup(
              size: _actionSize,
              children: [
                for (final data in grouped) AppBarActionButton(data: data),
              ],
            ),
          for (final data in actions.skip(grouped?.length ?? 0))
            ElasticPress(
              enabled: !data.isLoading && data.onPressed != null,
              child: AppBarActionButton(data: data),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = this.padding ?? listHeaderPaddingOf(context);
    final lineHeight = MeasureScope.of(
      context,
    ).textHeight(AppTextStyle.headline);
    final overhang = (_actionSize.button - lineHeight) / 2;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        padding.left,
        math.max(0, padding.top - overhang),
        padding.right,
        math.max(_actionsGap, padding.bottom - overhang),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: _actionSize.button),
        child: Row(
          spacing: 12,
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.headline
                    .of(context)
                    .copyWith(color: context.colorScheme.onSurfaceVariant),
              ),
            ),
            ?trailing,
            if (actions.isNotEmpty) _buildActions(),
          ],
        ),
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
      padding:
          const EdgeInsets.only(left: 16, right: 16, top: 8) * 1.mAp(context),
      child: Text(text, style: context.listCaptionStyle),
    );
  }
}

class ListSectionGap extends StatelessWidget {
  const ListSectionGap({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: listHeaderPaddingOf(context).top);
  }
}

/// A section's rows alone, for a group under a header its caller lays out.
Widget generateGroup(Iterable<Widget> items) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ...items.mapIndexed<Widget>(
        (index, item) => ItemPositionProvider(
          position: ItemPosition.get(index, items.length),
          child: item,
        ),
      ),
    ],
  );
}

Widget generateSection({
  String? title,
  required Iterable<Widget> items,
  List<IconButtonData> actions = const [],
  String? footer,
}) {
  return Column(
    children: [
      if (items.isNotEmpty)
        title != null
            ? ListHeader(title: title, actions: actions)
            : const ListSectionGap(),
      generateGroup(items),
      if (items.isNotEmpty && footer != null) ListFooter(text: footer),
    ],
  );
}
