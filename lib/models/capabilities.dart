import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/foundation.dart';

// Assumed for a Core that reports no `ss-plugins` or `congestion-controllers`.
const _unsupportedSsPlugins = {'restls', 'gost-plugin', 'kcptun', 'jls'};
const _supportedTunCongestion = {'cubic', 'reno'};

/// What the running Core can do. A Core that does not answer
/// `core.capabilities` (the Go one) supports everything.
@immutable
class CoreCapabilities {
  const CoreCapabilities({
    required this.implementation,
    required this.version,
    required this.proxyTypes,
    required this.transports,
    required this.ruleTypes,
    this.ssPlugins,
    this.congestionControllers,
  }) : restricted = true;

  const CoreCapabilities.everything()
    : implementation = '',
      version = '',
      proxyTypes = const {},
      transports = const {},
      ruleTypes = const {},
      ssPlugins = null,
      congestionControllers = null,
      restricted = false;

  factory CoreCapabilities.fromJson(Map<String, dynamic> json) {
    Set<String> names(String key) => {
      for (final item in json[key] as List? ?? const []) item as String,
    };
    Set<String>? optionalNames(String key) =>
        json[key] is List ? names(key) : null;
    return CoreCapabilities(
      implementation: json['impl'] as String? ?? '',
      version: json['version'] as String? ?? '',
      proxyTypes: names('proxy-types'),
      transports: names('transports'),
      ruleTypes: names('rule-types'),
      ssPlugins: optionalNames('ss-plugins'),
      congestionControllers: optionalNames('congestion-controllers'),
    );
  }

  final String implementation;
  final String version;
  final Set<String> proxyTypes;
  final Set<String> transports;
  final Set<String> ruleTypes;

  final Set<String>? ssPlugins;
  final Set<String>? congestionControllers;

  /// False for a Core that reported nothing, which supports everything.
  final bool restricted;

  bool supportsProxyType(String type) =>
      !restricted || proxyTypes.contains(type);

  bool supportsNetwork(String network) =>
      !restricted || network == 'tcp' || transports.contains(network);

  bool supportsSsPlugin(String plugin) {
    if (!restricted) {
      return true;
    }
    final reported = ssPlugins;
    return reported == null
        ? !_unsupportedSsPlugins.contains(plugin)
        : reported.contains(plugin);
  }

  bool supportsTunCongestionController(String name) {
    if (!restricted) {
      return true;
    }
    final reported = congestionControllers;
    return (reported ?? _supportedTunCongestion).contains(name);
  }

  List<String> supportedChoices(ProxyField field, List<String> choices) {
    if (!restricted) {
      return choices;
    }
    return switch (field) {
      ProxyField.network => choices.where(supportsNetwork).toList(),
      ProxyField.plugin => choices.where(supportsSsPlugin).toList(),
      _ => choices,
    };
  }

  @override
  bool operator ==(Object other) =>
      other is CoreCapabilities &&
      other.restricted == restricted &&
      other.implementation == implementation &&
      other.version == version &&
      setEquals(other.proxyTypes, proxyTypes) &&
      setEquals(other.transports, transports) &&
      setEquals(other.ruleTypes, ruleTypes) &&
      setEquals(other.ssPlugins, ssPlugins) &&
      setEquals(other.congestionControllers, congestionControllers);

  @override
  int get hashCode => Object.hash(
    restricted,
    implementation,
    version,
    Object.hashAllUnordered(proxyTypes),
    Object.hashAllUnordered(transports),
    Object.hashAllUnordered(ruleTypes),
    ssPlugins == null ? null : Object.hashAllUnordered(ssPlugins!),
    congestionControllers == null
        ? null
        : Object.hashAllUnordered(congestionControllers!),
  );
}

enum ConfigWarningLevel { info, warning }

@immutable
class ConfigWarning {
  const ConfigWarning({
    required this.level,
    required this.path,
    required this.message,
  });

  factory ConfigWarning.fromJson(Map<String, dynamic> json) {
    return ConfigWarning(
      level: json['level'] == 'warning'
          ? ConfigWarningLevel.warning
          : ConfigWarningLevel.info,
      path: json['path'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }

  final ConfigWarningLevel level;
  final String path;
  final String message;

  @override
  bool operator ==(Object other) =>
      other is ConfigWarning &&
      other.level == level &&
      other.path == path &&
      other.message == message;

  @override
  int get hashCode => Object.hash(level, path, message);
}

extension ConfigWarningsExt on Iterable<ConfigWarning> {
  List<ConfigWarning> get warnings => [
    for (final item in this)
      if (item.level == ConfigWarningLevel.warning) item,
  ];
}
