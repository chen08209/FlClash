import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/misc.dart' show ProviderListenable;

import 'input.dart';
import 'list.dart';

export 'package:riverpod/misc.dart' show ProviderListenable;

typedef ConfigLabel = String Function(AppLocalizations appLocalizations);

typedef ConfigWriter<T> = void Function(WidgetRef ref, T value);

abstract class _ConfigItem<T> extends ConsumerWidget {
  const _ConfigItem({
    super.key,
    required this.selector,
    required this.title,
    required this.onChanged,
    this.subtitle,
    this.leading,
  });

  final ProviderListenable<T> selector;
  final ConfigLabel title;
  final ConfigLabel? subtitle;
  final ConfigWriter<T> onChanged;
  final Widget? leading;

  Widget buildItem(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations appLocalizations,
    T value,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return buildItem(context, ref, appLocalizations, ref.watch(selector));
  }

  Widget? buildSubtitle(AppLocalizations appLocalizations) {
    final subtitle = this.subtitle;
    return subtitle == null ? null : Text(subtitle(appLocalizations));
  }
}

class ConfigToggleItem extends _ConfigItem<bool> {
  const ConfigToggleItem({
    super.key,
    required super.selector,
    required super.title,
    required super.onChanged,
    super.subtitle,
    super.leading,
  });

  @override
  Widget buildItem(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations appLocalizations,
    bool value,
  ) {
    return ListItem.toggle(
      leading: leading,
      title: Text(title(appLocalizations)),
      subtitle: buildSubtitle(appLocalizations),
      value: value,
      onChanged: (value) => onChanged(ref, value),
    );
  }
}

class ConfigOptionsItem<T> extends _ConfigItem<T> {
  const ConfigOptionsItem({
    super.key,
    required super.selector,
    required super.title,
    required super.onChanged,
    required this.options,
    required this.textBuilder,
    super.subtitle,
    super.leading,
  });

  final List<T> options;
  final String Function(T value) textBuilder;

  @override
  Widget buildItem(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations appLocalizations,
    T value,
  ) {
    return ListItem<T>.options(
      leading: leading,
      title: Text(title(appLocalizations)),
      subtitle: Text(subtitle?.call(appLocalizations) ?? textBuilder(value)),
      dialogTitle: title(appLocalizations),
      options: options,
      value: value,
      textBuilder: textBuilder,
      onChanged: (value) {
        if (value == null) {
          return;
        }
        onChanged(ref, value);
      },
    );
  }
}

class ConfigTextItem extends _ConfigItem<String> {
  const ConfigTextItem({
    super.key,
    required super.selector,
    required super.title,
    required super.onChanged,
    this.maxLength,
    this.keyboardType,
    this.validator,
    this.showValueAsSubtitle = true,
    super.subtitle,
    super.leading,
  });

  final int? maxLength;
  final TextInputType? keyboardType;
  final String? Function(String? value, AppLocalizations appLocalizations)?
  validator;
  final bool showValueAsSubtitle;

  @override
  Widget buildItem(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations appLocalizations,
    String value,
  ) {
    final label = title(appLocalizations);
    final validator = this.validator;
    return ListItem.input(
      leading: leading,
      title: Text(label),
      subtitle: showValueAsSubtitle
          ? Text(value)
          : buildSubtitle(appLocalizations),
      dialogTitle: label,
      value: value,
      maxLength: maxLength,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return appLocalizations.emptyTip(label);
        }
        return validator?.call(value, appLocalizations);
      },
      onChanged: (value) {
        if (value == null) {
          return;
        }
        onChanged(ref, value);
      },
    );
  }
}

class ConfigListInputItem extends _ConfigItem<List<String>> {
  const ConfigListInputItem({
    super.key,
    required super.selector,
    required super.title,
    required super.onChanged,
    this.itemMaxLength,
    this.maxWidth,
    super.subtitle,
    super.leading,
  });

  final int? itemMaxLength;
  final double? maxWidth;

  @override
  Widget buildItem(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations appLocalizations,
    List<String> value,
  ) {
    final label = title(appLocalizations);
    return ListItem.open(
      leading: leading,
      title: Text(label),
      subtitle: buildSubtitle(appLocalizations),
      blur: false,
      maxWidth: maxWidth,
      widget: ListInputPage(
        title: label,
        items: value,
        itemMaxLength: itemMaxLength,
        titleBuilder: (item) => Text(item),
      ),
      onChanged: (items) => onChanged(ref, List<String>.from(items as List)),
    );
  }
}
