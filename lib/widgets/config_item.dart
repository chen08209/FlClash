import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/misc.dart' show ProviderListenable;

import 'input.dart';
import 'list.dart';

export 'package:riverpod/misc.dart' show ProviderListenable;

typedef ConfigLabel = String Function(AppLocalizations appLocalizations);

typedef ConfigWriter<T> = void Function(WidgetRef ref, T value);

typedef ConfigValidator =
    String? Function(String? value, AppLocalizations appLocalizations);

String? validateCidr(String? value, AppLocalizations appLocalizations) {
  return isCidr(value ?? '') ? null : appLocalizations.invalidCidrContent;
}

/// The sniffer's address lists also take mihomo's geoip: and rule-set: items.
String? validateIpMatcher(String? value, AppLocalizations appLocalizations) {
  final lower = value?.toLowerCase() ?? '';
  if (lower.startsWith('geoip:') || lower.startsWith('rule-set:')) {
    return null;
  }
  return validateCidr(value, appLocalizations);
}

final _portRange = RegExp(r'^([0-9]{1,5})(?:-([0-9]{1,5}))?$');

final _domainLabel = RegExp(
  r'^[A-Za-z0-9_]([A-Za-z0-9_-]{0,61}[A-Za-z0-9_])?$',
);

final _port = RegExp(r'^[0-9]{1,5}$');

bool _isIpv6(String value) =>
    InternetAddress.tryParse(value)?.type == InternetAddressType.IPv6;

bool _isHost(String value) => value.contains(':')
    ? _isIpv6(value)
    : value.length <= 253 && value.split('.').every(_domainLabel.hasMatch);

String? validateHost(String? value, AppLocalizations appLocalizations) {
  return _isHost(value ?? '') ? null : appLocalizations.invalidHostContent;
}

/// mihomo starts no DNS server, and only logs why, for an address this refuses.
String? validateListenAddress(
  String? value,
  AppLocalizations appLocalizations,
) {
  final text = value ?? '';
  final colon = text.lastIndexOf(':');
  final host = colon < 0 ? null : text.substring(0, colon);
  final port = colon < 0 ? '' : text.substring(colon + 1);
  final validHost = switch (host) {
    null => false,
    '' => true,
    final host when host.startsWith('[') && host.endsWith(']') => _isIpv6(
      host.substring(1, host.length - 1),
    ),
    final host => !host.contains(':') && _isHost(host),
  };
  final validPort =
      _port.hasMatch(port) && int.parse(port) > 0 && int.parse(port) <= 65535;
  return validHost && validPort ? null : appLocalizations.invalidListenContent;
}

String? validatePortRange(String? value, AppLocalizations appLocalizations) {
  final match = _portRange.firstMatch(value ?? '');
  if (match == null ||
      [?match[1], ?match[2]].any((port) => int.parse(port) > 65535)) {
    return appLocalizations.invalidPortRangeContent;
  }
  return null;
}

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
    this.normalize,
    this.showValueAsSubtitle = true,
    super.subtitle,
    super.leading,
  });

  final int? maxLength;
  final TextInputType? keyboardType;
  final ConfigValidator? validator;
  final String Function(String value)? normalize;
  final bool showValueAsSubtitle;

  String? _normalize(String? value) {
    if (value == null) {
      return null;
    }
    return normalize?.call(value) ?? value;
  }

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
      subtitle: showValueAsSubtitle && value.isNotEmpty
          ? Text(value)
          : buildSubtitle(appLocalizations),
      dialogTitle: label,
      value: value,
      maxLength: maxLength,
      keyboardType: keyboardType,
      validator: (value) {
        final normalized = _normalize(value);
        if (normalized == null || normalized.isEmpty) {
          return appLocalizations.emptyTip(label);
        }
        return validator?.call(normalized, appLocalizations);
      },
      onChanged: (value) {
        final normalized = _normalize(value);
        if (normalized == null) {
          return;
        }
        onChanged(ref, normalized);
      },
    );
  }
}

class ConfigListEditItem extends _ConfigItem<List<String>> {
  const ConfigListEditItem({
    super.key,
    required super.selector,
    required super.title,
    required super.onChanged,
    this.itemMaxLength,
    this.itemValidator,
    super.subtitle,
    super.leading,
  });

  final int? itemMaxLength;
  final ConfigValidator? itemValidator;

  @override
  Widget buildItem(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations appLocalizations,
    List<String> value,
  ) {
    final label = title(appLocalizations);
    final itemValidator = this.itemValidator;
    return ListItem.open(
      leading: leading,
      title: Text(label),
      subtitle:
          buildSubtitle(appLocalizations) ??
          Text(
            value.isEmpty
                ? appLocalizations.none
                : appLocalizations.itemsCount(value.length),
          ),
      widget: ListEditView(
        title: label,
        items: value,
        itemMaxLength: itemMaxLength,
        itemValidator: itemValidator == null
            ? null
            : (item) => itemValidator(item, appLocalizations),
        titleBuilder: (item) => Text(item),
      ),
      onChanged: (items) => onChanged(ref, List<String>.from(items as List)),
    );
  }
}
