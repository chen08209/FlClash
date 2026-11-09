import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:prism_ui/icons/icons.dart';
import 'package:prism_ui/prism_ui.dart';

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
  final ListRowAlignment alignment;
  final Widget? trailing;
  final _ListItemAction _action;
  final double? horizontalTitleGap;
  final double minVerticalPadding;
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
    this.minTileHeight,
    this.minVerticalPadding = listRowVerticalPadding,
    this.alignment = ListRowAlignment.center,
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
    this.minTileHeight,
    this.minVerticalPadding = listRowVerticalPadding,
    this.alignment = ListRowAlignment.center,
  }) : _action = _OpenAction(
         widget: widget,
         onChanged: onChanged,
         forceFull: forceFull,
       ),
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
    this.minTileHeight,
    this.minVerticalPadding = listRowVerticalPadding,
    this.alignment = ListRowAlignment.center,
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
    this.minTileHeight,
    this.minVerticalPadding = listRowVerticalPadding,
    this.alignment = ListRowAlignment.center,
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
    this.minTileHeight,
    this.minVerticalPadding = listRowVerticalPadding,
    this.alignment = ListRowAlignment.center,
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
    this.minTileHeight,
    this.minVerticalPadding = listRowVerticalPadding,
    this.alignment = ListRowAlignment.center,
  }) : _action = _ToggleAction(value: value, onChanged: onChanged),
       trailing = null,
       onTap = null;

  Widget _buildRow(
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
    final row = ListRow(
      leading: leading ?? this.leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing ?? this.trailing,
      padding: padding,
      horizontalTitleGap: horizontalTitleGap,
      minVerticalPadding: minVerticalPadding,
      minHeight: minTileHeight ?? listRowMinHeight,
      alignment: alignment,
    );
    if (onTap == null) {
      return row;
    }
    return PressSurface(
      fill: Colors.transparent,
      shape: AppShape.all(AppCorner.none),
      onPressed: onTap,
      child: row,
    );
  }

  Widget get _pageTrailing =>
      trailing ?? const GlyphIcon(Glyphs.chevronForward);

  @override
  Widget build(BuildContext context) {
    final position = ItemPositionProvider.of(context)?.position;
    switch (_action) {
      case final _OpenAction openDelegate:
        final child = openDelegate.widget;
        final onChanged = openDelegate.onChanged;
        if (!context.isMobileView) {
          return _buildRow(
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
          closedShape: position == null
              ? null
              : AppShape.of(listItemRadiusOf(position)),
          closedBuilder: (context, action) {
            return _buildRow(
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
      case final _OptionsAction options:
        final optionsDelegate = options as _OptionsAction<T>;
        PopupOpen? openMenu;
        return _buildRow(
          context,
          position: position,
          // As an iOS pop-up row does, a tap anywhere on the row opens the
          // menu out of its value.
          onTap: () => openMenu?.call(),
          trailing: PopupAnchor(
            targetBuilder: (open) {
              openMenu = open;
              return _OptionsValueButton(
                label: optionsDelegate.textBuilder(optionsDelegate.value),
                onPressed: open,
              );
            },
            popupBuilder: (_) => PopupMenu(
              items: [
                for (final option in optionsDelegate.options)
                  PopupMenuItem(
                    label: optionsDelegate.textBuilder(option),
                    checked: option == optionsDelegate.value,
                    onPressed: () => optionsDelegate.onChanged(option),
                  ),
              ],
            ),
          ),
        );
      case final _InputAction inputDelegate:
        return _buildRow(
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
                    : [
                        LengthLimitingTextInputFormatter(
                          inputDelegate.maxLength,
                        ),
                      ],
                keyboardType: inputDelegate.keyboardType,
                validator: inputDelegate.validator,
              ),
            );
            inputDelegate.onChanged(value);
          },
        );
      case final _CheckboxAction checkboxDelegate:
        return _buildRow(
          context,
          position: position,
          onTap: checkboxDelegate.onChanged == null
              ? null
              : () {
                  checkboxDelegate.onChanged!(!checkboxDelegate.value);
                },
          trailing: Checkbox(
            value: checkboxDelegate.value,
            onChanged: checkboxDelegate.onChanged,
          ),
        );
      case final _ToggleAction toggleAction:
        return _buildRow(
          context,
          position: position,
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
      case _DefaultAction():
        return _buildRow(context, position: position, onTap: onTap);
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
      style: ButtonStyle.from(
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
          const GlyphIcon(Glyphs.picker),
        ],
      ),
    );
  }
}
