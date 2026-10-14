import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/views/config/override.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension on SnifferOverrideKey {
  String label(AppLocalizations l) => switch (this) {
    SnifferOverrideKey.enable => l.status,
    SnifferOverrideKey.overrideDest => l.overrideDestination,
    SnifferOverrideKey.forceDnsMapping => l.forceDnsMapping,
    SnifferOverrideKey.parsePureIp => l.parsePureIp,
    SnifferOverrideKey.forceDomain => l.forceDomain,
    SnifferOverrideKey.skipDomain => l.skipDomain,
    SnifferOverrideKey.skipSrcAddress => l.skipSrcAddress,
    SnifferOverrideKey.skipDstAddress => l.skipDstAddress,
    SnifferOverrideKey.sniffHttp ||
    SnifferOverrideKey.sniffTls ||
    SnifferOverrideKey.sniffQuic => field,
  };

  ConfigLabel? get description => switch (this) {
    SnifferOverrideKey.enable => (l) => l.snifferStatusDesc,
    SnifferOverrideKey.overrideDest => (l) => l.overrideDestinationDesc,
    SnifferOverrideKey.forceDnsMapping => (l) => l.forceDnsMappingDesc,
    SnifferOverrideKey.parsePureIp => (l) => l.parsePureIpDesc,
    SnifferOverrideKey.forceDomain => (l) => l.forceDomainDesc,
    SnifferOverrideKey.skipDomain => (l) => l.skipDomainDesc,
    _ => null,
  };
}

typedef _SnifferState = OverrideState<SnifferOverrideKey, Sniffer>;

_SnifferState _profileSniffer(ProfileOverrides overrides) =>
    (model: overrides.sniffer, keys: overrides.snifferOverrideKeys);

ProfileOverrides _setProfileSniffer(
  ProfileOverrides overrides,
  _SnifferState state,
) => overrides.copyWith(sniffer: state.model, snifferOverrideKeys: state.keys);

class SnifferView extends OverrideView<SnifferOverrideKey, Sniffer> {
  SnifferView(int profileId, {super.key})
    : super(
        spec: _SnifferOverrideSpec(
          ProfileOverrideTarget(
            profileId,
            get: _profileSniffer,
            set: _setProfileSniffer,
          ),
        ),
      );
}

class _SnifferOverrideSpec extends OverrideSpec<SnifferOverrideKey, Sniffer>
    with OverrideQuickEdit<SnifferOverrideKey, Sniffer> {
  const _SnifferOverrideSpec(this.target);

  @override
  final OverrideTarget<SnifferOverrideKey, Sniffer> target;

  @override
  String title(AppLocalizations l) => l.sniffer;

  @override
  List<SnifferOverrideKey> get values => SnifferOverrideKey.values;

  @override
  String overrideYaml(Sniffer model, Set<SnifferOverrideKey> keys) =>
      model.overrideYaml(keys);

  @override
  _SnifferState applyOverrideYaml(Sniffer model, String content) {
    final result = model.applyOverrideYaml(content);
    return (model: result.sniffer, keys: result.keys);
  }

  @override
  EditorSchema get schema => EditorSchema.sniffer;

  @override
  NullStatusIllustration get illustration => NullStatusIllustration.sniffer;

  @override
  Sniffer get defaults => defaultSniffer;

  @override
  String sectionOf(SnifferOverrideKey key, AppLocalizations l) =>
      key.parent == null ? l.options : l.sniffProtocols;

  @override
  String label(SnifferOverrideKey key, AppLocalizations l) => key.label(l);

  @override
  ConfigLabel? description(SnifferOverrideKey key) => key.description;

  @override
  OverrideField<Sniffer> fieldOf(SnifferOverrideKey key) => switch (key) {
    SnifferOverrideKey.enable => ToggleOverrideField(
      (sniffer) => sniffer.enable,
      (sniffer, value) => sniffer.copyWith(enable: value),
    ),
    SnifferOverrideKey.overrideDest => ToggleOverrideField(
      (sniffer) => sniffer.overrideDest,
      (sniffer, value) => sniffer.copyWith(overrideDest: value),
    ),
    SnifferOverrideKey.forceDnsMapping => ToggleOverrideField(
      (sniffer) => sniffer.forceDnsMapping,
      (sniffer, value) => sniffer.copyWith(forceDnsMapping: value),
    ),
    SnifferOverrideKey.parsePureIp => ToggleOverrideField(
      (sniffer) => sniffer.parsePureIp,
      (sniffer, value) => sniffer.copyWith(parsePureIp: value),
    ),
    SnifferOverrideKey.forceDomain => ListOverrideField(
      (sniffer) => sniffer.forceDomain,
      (sniffer, value) => sniffer.copyWith(forceDomain: value),
      itemMaxLength: TextInputLimits.domain,
    ),
    SnifferOverrideKey.skipDomain => ListOverrideField(
      (sniffer) => sniffer.skipDomain,
      (sniffer, value) => sniffer.copyWith(skipDomain: value),
      itemMaxLength: TextInputLimits.domain,
    ),
    SnifferOverrideKey.skipSrcAddress => ListOverrideField(
      (sniffer) => sniffer.skipSrcAddress,
      (sniffer, value) => sniffer.copyWith(skipSrcAddress: value),
      itemMaxLength: TextInputLimits.cidr,
      itemValidator: validateIpMatcher,
    ),
    SnifferOverrideKey.skipDstAddress => ListOverrideField(
      (sniffer) => sniffer.skipDstAddress,
      (sniffer, value) => sniffer.copyWith(skipDstAddress: value),
      itemMaxLength: TextInputLimits.cidr,
      itemValidator: validateIpMatcher,
    ),
    SnifferOverrideKey.sniffHttp ||
    SnifferOverrideKey.sniffTls ||
    SnifferOverrideKey.sniffQuic => _SniffField(key),
  };
}

class _SniffField extends OverrideField<Sniffer> {
  const _SniffField(this.overrideKey);

  final SnifferOverrideKey overrideKey;

  @override
  Widget build(
    OverrideModel<Sniffer> model, {
    required ConfigLabel title,
    required Widget leading,
  }) {
    return _SniffItem(model: model, overrideKey: overrideKey, leading: leading);
  }

  @override
  Sniffer reset(Sniffer model, Sniffer defaults) =>
      model.withSniff(overrideKey, defaults.sniffOf(overrideKey));
}

/// mihomo sniffs a protocol listed without ports on its standard port.
String _portsText(AppLocalizations l, List<String> ports) {
  return ports.isEmpty ? l.defaultText : l.itemsCount(ports.length);
}

class _SniffItem extends ConsumerWidget {
  const _SniffItem({
    required this.model,
    required this.overrideKey,
    required this.leading,
  });

  final OverrideModel<Sniffer> model;
  final SnifferOverrideKey overrideKey;
  final Widget leading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final ports = ref.watch(
      model.selectModel((sniffer) => sniffer.sniffOf(overrideKey).ports),
    );
    return ListItem.open(
      leading: leading,
      title: Text(overrideKey.label(appLocalizations)),
      subtitle: Text(
        _portsText(appLocalizations, ports),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      widget: _SniffView(model: model, overrideKey: overrideKey),
    );
  }
}

/// A protocol without its own `override-destination` follows the sniffer's.
enum _SniffDestination {
  inherit(null),
  enabled(true),
  disabled(false);

  const _SniffDestination(this.value);

  final bool? value;

  static _SniffDestination of(bool? value) =>
      values.firstWhere((item) => item.value == value);

  String label(AppLocalizations l) => switch (this) {
    _SniffDestination.inherit => l.defaultText,
    _SniffDestination.enabled => l.enabled,
    _SniffDestination.disabled => l.disabled,
  };
}

class _SniffView extends ConsumerWidget {
  const _SniffView({required this.model, required this.overrideKey});

  final OverrideModel<Sniffer> model;
  final SnifferOverrideKey overrideKey;

  ProviderListenable<T> _sniffSelector<T>(
    T Function(SnifferConfig sniff) select,
  ) {
    return model.selectModel((sniffer) => select(sniffer.sniffOf(overrideKey)));
  }

  ConfigWriter<T> _sniffWriter<T>(
    SnifferConfig Function(SnifferConfig sniff, T value) update,
  ) {
    return model.modelWriter<T>(
      (sniffer, value) => sniffer.withSniff(
        overrideKey,
        update(sniffer.sniffOf(overrideKey), value),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final ports = ref.watch(_sniffSelector((sniff) => sniff.ports));
    return BaseScaffold(
      title: overrideKey.label(appLocalizations),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ).copyWith(top: context.contentTopPadding, bottom: 16),
        children: [
          generateSectionV3(
            items: [
              ConfigListEditItem(
                title: (l) => l.ports,
                subtitle: (l) => _portsText(l, ports),
                selector: _sniffSelector((sniff) => sniff.ports),
                onChanged: _sniffWriter(
                  (sniff, value) => sniff.copyWith(ports: value),
                ),
                itemMaxLength: TextInputLimits.portRange,
                itemValidator: validatePortRange,
              ),
              ConfigOptionsItem<_SniffDestination>(
                title: (l) => l.overrideDestination,
                options: _SniffDestination.values,
                textBuilder: (value) => value.label(appLocalizations),
                selector: _sniffSelector(
                  (sniff) => _SniffDestination.of(sniff.overrideDest),
                ),
                onChanged: _sniffWriter(
                  (sniff, value) => sniff.copyWith(overrideDest: value.value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
