part of '../general.dart';

extension on GeneralOverrideKey {
  String label(AppLocalizations l) => switch (this) {
    GeneralOverrideKey.testUrl => l.testUrl,
    GeneralOverrideKey.unifiedDelay => l.unifiedDelay,
    GeneralOverrideKey.tcpConcurrent => l.tcpConcurrent,
    GeneralOverrideKey.ipv6 => 'IPv6',
    GeneralOverrideKey.geodataLoader => l.geodataLoader,
  };
}

typedef _GeneralState = OverrideState<GeneralOverrideKey, PatchClashConfig>;

_GeneralState _generalOverrides(PatchClashConfig config) =>
    (model: config, keys: config.generalOverrideKeys);

PatchClashConfig _setGeneralOverrides(
  PatchClashConfig config,
  _GeneralState state,
) => state.model.copyWith(generalOverrideKeys: state.keys);

String _generalOverrideDescription(AppLocalizations l) => l.generalOverrideDesc;

String? _validateTestUrl(String? value, AppLocalizations l) =>
    value?.isUrl == true ? null : l.urlTip(l.testUrl);

const _generalOverrideSpec = _GeneralOverrideSpec();

class _GeneralOverrideSpec
    extends OverrideSpec<GeneralOverrideKey, PatchClashConfig> {
  const _GeneralOverrideSpec();

  @override
  OverrideTarget<GeneralOverrideKey, PatchClashConfig> get target =>
      const PatchOverrideTarget(
        get: _generalOverrides,
        set: _setGeneralOverrides,
        description: _generalOverrideDescription,
      );

  @override
  String title(AppLocalizations l) => l.core;

  @override
  List<GeneralOverrideKey> get values => GeneralOverrideKey.values;

  @override
  NullStatusIllustration get illustration => NullStatusIllustration.data;

  @override
  PatchClashConfig get defaults => defaultClashConfig;

  @override
  String label(GeneralOverrideKey key, AppLocalizations l) => key.label(l);

  @override
  ConfigLabel? description(GeneralOverrideKey key) => switch (key) {
    GeneralOverrideKey.ipv6 => (l) => l.ipv6Desc,
    _ => null,
  };

  @override
  OverrideField<PatchClashConfig> fieldOf(GeneralOverrideKey key) =>
      switch (key) {
        GeneralOverrideKey.testUrl => TextOverrideField(
          (config) => config.testUrl,
          (config, value) => config.copyWith(testUrl: value),
          maxLength: TextInputLimits.url,
          validator: _validateTestUrl,
          allowEmpty: false,
        ),
        GeneralOverrideKey.unifiedDelay => ToggleOverrideField(
          (config) => config.unifiedDelay,
          (config, value) => config.copyWith(unifiedDelay: value),
        ),
        GeneralOverrideKey.tcpConcurrent => ToggleOverrideField(
          (config) => config.tcpConcurrent,
          (config, value) => config.copyWith(tcpConcurrent: value),
        ),
        GeneralOverrideKey.ipv6 => ToggleOverrideField(
          (config) => config.ipv6,
          (config, value) => config.copyWith(ipv6: value),
        ),
        GeneralOverrideKey.geodataLoader => ToggleOverrideField(
          (config) => config.geodataLoader == GeodataLoader.memconservative,
          (config, value) => config.copyWith(
            geodataLoader: value
                ? GeodataLoader.memconservative
                : GeodataLoader.standard,
          ),
        ),
      };
}
