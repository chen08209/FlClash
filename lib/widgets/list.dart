import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/inherited.dart';
import 'package:material_ui/material_ui.dart';

import 'card.dart';
import 'input.dart';
import 'open_container.dart';
import 'scaffold.dart';
import 'sheet.dart';
import 'switch.dart';

part 'list_selected.dart';

/// Miuix preference rows: a 17sp medium title over its summary, start icons
/// in the text color 14dp clear of the title, at least 56dp tall; sections
/// sit inside a 12dp list margin under a bold 14sp title.
abstract final class _MiuixList {
  static const minHeight = 56.0;
  static const verticalPadding = 12.0;
  static const iconGap = 14.0;
  static const margin = 12.0;
  static const chevronSize = 16.0;

  static TextStyle? title(BuildContext context) =>
      context.textTheme.bodyLarge?.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: context.colorScheme.onSurface,
      );

  static TextStyle? subtitle(BuildContext context) => context
      .textTheme
      .bodyMedium
      ?.copyWith(letterSpacing: 0, color: context.colorScheme.onSurfaceVariant);

  static TextStyle? sectionTitle(BuildContext context) {
    final colors = context.colorScheme;
    final color = context.interfaceStyle.miuixMonet
        ? colors.primary
        : switch (colors.brightness) {
            Brightness.light => const Color(0xFF8C93B0),
            Brightness.dark => const Color(0xFF787E96),
          };
    return context.textTheme.labelLarge?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      color: color,
    );
  }
}

class _MiuixChevron extends StatelessWidget {
  const _MiuixChevron();

  @override
  Widget build(BuildContext context) {
    return GlyphIcon(
      AppGlyphs.chevronForward,
      size: _MiuixList.chevronSize,
      color: context.colorScheme.onSurfaceVariant,
    );
  }
}

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
  final double? maxWidth;

  const _NextAction({required this.widget, this.maxWidth});
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
    this.minVerticalPadding = 12,
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
    this.minVerticalPadding = 12,
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
    double? maxWidth,
    this.horizontalTitleGap,
    this.dense,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.color,
    this.minTileHeight,
    this.visualDensity,
    this.minVerticalPadding = 12,
    this.tileTitleAlignment = ListTileTitleAlignment.center,
  }) : _action = _NextAction(widget: widget, maxWidth: maxWidth),
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
    this.minVerticalPadding = 12,
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
    this.minVerticalPadding = 12,
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
    this.minVerticalPadding = 12,
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
    this.minVerticalPadding = 12,
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
    this.minVerticalPadding = 12,
    this.tileTitleAlignment = ListTileTitleAlignment.center,
  }) : _action = _RadioAction<T>(value: value, onTap: onTap),
       leading = null,
       onTap = null;

  Widget _buildListTile(
    BuildContext context, {
    required ItemPosition? position,
    void Function()? onTap,
    Widget? trailing,
    Widget? leading,
    bool enabled = true,
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
          enabled: enabled,
        ),
      );
    }
    final isMiuix = context.interfaceStyle.isMiuix;
    return ListTile(
      key: key,
      enabled: enabled,
      dense: dense,
      visualDensity: visualDensity,
      tileColor: color,
      titleTextStyle:
          titleTextStyle ?? (isMiuix ? _MiuixList.title(context) : null),
      subtitleTextStyle:
          subtitleTextStyle ?? (isMiuix ? _MiuixList.subtitle(context) : null),
      iconColor: isMiuix ? context.colorScheme.onSurface : null,
      leading: leading ?? this.leading,
      horizontalTitleGap:
          horizontalTitleGap ?? (isMiuix ? _MiuixList.iconGap : null),
      title: title,
      minTileHeight: minTileHeight ?? (isMiuix ? _MiuixList.minHeight : null),
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
    final position = ItemPositionProvider.of(context)?.position;
    final chevron = context.interfaceStyle.isMiuix
        ? trailing ?? const _MiuixChevron()
        : null;
    switch (_action) {
      case final _OpenAction openDelegate:
        final child = openDelegate.widget;
        final onChanged = openDelegate.onChanged;
        if (!context.isMobileView) {
          return _buildListTile(
            context,
            position: position,
            trailing: chevron,
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
          closedBuilder: (context, action) {
            return _buildListTile(
              context,
              position: position,
              trailing: chevron,
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
          trailing: chevron,
          onTap: () {
            showExtend(
              context,
              props: ExtendProps(maxWidth: nextDelegate.maxWidth),
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
          enabled: toggleAction.onChanged != null,
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
      case final _RadioAction radio:
        final radioDelegate = radio as _RadioAction<T>;
        return _buildListTile(
          context,
          position: position,
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
        return _buildListTile(context, position: position, onTap: onTap);
    }
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
        spacing: actions.isEmpty ? 0 : 12,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.interfaceStyle.isMiuix
                      ? _MiuixList.sectionTitle(context)
                      : context.textTheme.labelLarge?.copyWith(
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
            spacing: space ?? appBarActionSpace,
            children: [...actions],
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
  final count = items.length;
  final entries = items.mapIndexed<Widget>(
    (index, item) =>
        _SectionEntry(position: ItemPosition.get(index, count), child: item),
  );
  final genItems = separated
      ? entries.separated(const _SectionDivider())
      : entries;
  return [
    if (items.isNotEmpty && title != null)
      _SectionEntry(
        child: ListHeader(
          title: title,
          actions: actions,
          padding: isFirst
              ? listHeaderPadding.copyWith(top: 8.ap)
              : listHeaderPadding,
        ),
      ),
    ...genItems,
  ];
}

/// Material runs a section edge to edge; Miuix groups its rows into a card
/// inside the list margin. A style switch moves the row between the two
/// rather than rebuilding it, so an open container keeps its tile.
class _SectionEntry extends StatefulWidget {
  const _SectionEntry({this.position, required this.child});

  final ItemPosition? position;
  final Widget child;

  @override
  State<_SectionEntry> createState() => _SectionEntryState();
}

class _SectionEntryState extends State<_SectionEntry> {
  final _childKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final child = KeyedSubtree(key: _childKey, child: widget.child);
    if (!context.interfaceStyle.isMiuix) {
      return child;
    }
    final entry = Padding(
      padding: const EdgeInsets.symmetric(horizontal: _MiuixList.margin),
      child: child,
    );
    final position = widget.position;
    return position == null
        ? entry
        : ItemPositionProvider(position: position, child: entry);
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return context.interfaceStyle.isMiuix
        ? const SizedBox.shrink()
        : const Divider(height: 0);
  }
}

Widget generateSectionV3({
  String? title,
  required Iterable<Widget> items,
  List<Widget>? actions,
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

Widget generateListView(List<Widget> items, {double topPadding = 0}) {
  return ListView.builder(
    itemCount: items.length,
    itemBuilder: (_, index) => items[index],
    padding: EdgeInsets.only(top: topPadding, bottom: 16),
  );
}
