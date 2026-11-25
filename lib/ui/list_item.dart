import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:prism_ui/icons/icons.dart';
import 'package:prism_ui/prism_ui.dart';

import 'nested_sheet.dart';

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
  final Widget? widget;
  final WidgetBuilder? builder;
  final ValueChanged<dynamic>? onChanged;

  final bool forceFull;
  final bool enabled;

  const _OpenAction({
    this.widget,
    this.builder,
    this.onChanged,
    required this.forceFull,
    required this.enabled,
  }) : assert((widget == null) != (builder == null));

  Widget buildPage(BuildContext context) => widget ?? builder!(context);
}

final class _OptionsAction<T> extends _ListItemAction {
  final List<T> options;
  final T value;
  final String Function(T value) textBuilder;
  final ValueChanged<T> onChanged;
  final Set<T> sectionStarts;

  const _OptionsAction({
    required this.options,
    required this.textBuilder,
    required this.value,
    required this.onChanged,
    required this.sectionStarts,
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
  final EdgeInsetsGeometry? padding;
  final ListRowAlignment alignment;
  final Widget? trailing;
  final _ListItemAction _action;
  final double? horizontalTitleGap;
  final double? minVerticalPadding;
  final double? minTileHeight;
  final void Function()? onTap;

  const ListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.padding,
    this.trailing,
    this.horizontalTitleGap,
    this.onTap,
    this.minTileHeight,
    this.minVerticalPadding,
    this.alignment = ListRowAlignment.center,
  }) : _action = const _DefaultAction();

  ListItem.open({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.padding,
    this.trailing,
    Widget? widget,
    WidgetBuilder? builder,
    ValueChanged<dynamic>? onChanged,
    bool forceFull = true,
    bool enabled = true,
    this.horizontalTitleGap,
    this.minTileHeight,
    this.minVerticalPadding,
    this.alignment = ListRowAlignment.center,
  }) : assert((widget == null) != (builder == null)),
       _action = _OpenAction(
         widget: widget,
         builder: builder,
         onChanged: onChanged,
         forceFull: forceFull,
         enabled: enabled,
       ),
       onTap = null;

  ListItem.options({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.padding,
    required List<T> options,
    required T value,
    required String Function(T value) textBuilder,
    required ValueChanged<T> onChanged,
    Set<T> sectionStarts = const {},
    this.horizontalTitleGap,
    this.minTileHeight,
    this.minVerticalPadding,
    this.alignment = ListRowAlignment.center,
  }) : _action = _OptionsAction<T>(
         options: options,
         value: value,
         textBuilder: textBuilder,
         onChanged: onChanged,
         sectionStarts: sectionStarts,
       ),
       trailing = null,
       onTap = null;

  ListItem.input({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.padding,
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
    this.minVerticalPadding,
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
    this.padding,
    bool value = false,
    ValueChanged<bool?>? onChanged,
    this.horizontalTitleGap,
    this.minTileHeight,
    this.minVerticalPadding,
    this.alignment = ListRowAlignment.center,
  }) : _action = _CheckboxAction(value: value, onChanged: onChanged),
       trailing = null,
       onTap = null;

  ListItem.toggle({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.padding,
    required bool value,
    ValueChanged<bool>? onChanged,
    this.horizontalTitleGap,
    this.minTileHeight,
    this.minVerticalPadding,
    this.alignment = ListRowAlignment.center,
  }) : _action = _ToggleAction(value: value, onChanged: onChanged),
       trailing = null,
       onTap = null;

  Widget _buildRow(
    BuildContext context, {
    required ItemPosition? position,
    void Function()? onTap,
    Widget? trailing,
    double trailingInset = 0,
  }) {
    trailing ??= this.trailing;
    final insets = context.listInsets;
    final padding =
        this.padding ??
        EdgeInsetsDirectional.only(
          start: insets.leading,
          end: trailing == null
              ? insets.leading
              : insets.trailing - trailingInset,
        );
    if (position != null) {
      // OpenContainer reparents the closed tile out of the section's provider.
      return ItemPositionProvider(
        position: position,
        child: DecorationListItem(
          leading: leading,
          title: title,
          subtitle: subtitle,
          trailing: trailing,
          contentPadding: padding,
          horizontalTitleGap: horizontalTitleGap,
          minVerticalPadding: minVerticalPadding,
          alignment: alignment,
          minHeight: minTileHeight,
          onPressed: onTap,
        ),
      );
    }
    final row = ListRow(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      padding: padding,
      horizontalTitleGap: horizontalTitleGap,
      minVerticalPadding: minVerticalPadding,
      minHeight: minTileHeight,
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

  // The glyph's stroke ends 6.7 inside its box; iOS's ends 0.7 inside its own.
  /// What the chevron glyph leaves beside its stroke.
  static const chevronInset = 6.0;

  /// A row's padding when it ends in a chevron, whose stroke then meets the
  /// margin the row's other ends keep.
  static EdgeInsetsDirectional chevronPaddingOf(BuildContext context) {
    final insets = context.listInsets;
    return EdgeInsetsDirectional.only(
      start: insets.leading,
      end: insets.trailing - chevronInset,
    );
  }

  @override
  Widget build(BuildContext context) {
    final position = ItemPositionProvider.of(context)?.position;
    switch (_action) {
      case final _OpenAction openDelegate:
        final onChanged = openDelegate.onChanged;
        if (!openDelegate.enabled) {
          // Dimmed as a disabled Switch draws its thumb; the row's text stays as it is.
          return _buildRow(
            context,
            position: position,
            trailingInset: chevronInset,
            trailing:
                trailing ??
                GlyphIcon(
                  Glyphs.chevronForward,
                  color: context.colorScheme.onSurface.opacity38,
                ),
          );
        }
        if (!context.isMobileView) {
          return _buildRow(
            context,
            position: position,
            trailing: _pageTrailing,
            trailingInset: chevronInset,
            onTap: () async {
              final result = await showNestedExtend<dynamic>(
                context,
                props: ExtendProps(forceFull: openDelegate.forceFull),
                builder: openDelegate.buildPage,
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
              trailingInset: chevronInset,
              onTap: action,
            );
          },
          onClosed: onChanged,
          openBuilder: (context, action) {
            return openDelegate.buildPage(context);
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
          trailingInset: _OptionsValueButton.endInset,
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
                    section: optionsDelegate.sectionStarts.contains(option)
                        ? const PopupMenuSection()
                        : null,
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
          trailingInset: Checkbox.edgeInset,
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
          trailingInset: Switch.edgeInset,
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

  static const _padding = 8.0;

  static const endInset = _padding + 5.7;

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle.from(
        foregroundColor: context.colorScheme.onSurfaceVariant,
        textStyle: context.listTitleStyle,
        padding: const EdgeInsets.symmetric(horizontal: _padding),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: _optionsValueMaxWidth,
              ),
              child: PopupValueText(
                label,
                alignment: AlignmentDirectional.centerEnd,
              ),
            ),
          ),
          const GlyphIcon(Glyphs.picker),
        ],
      ),
    );
  }
}
