import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/views/config/override.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension on DnsOverrideKey {
  String label(AppLocalizations l) => switch (this) {
    DnsOverrideKey.enable => l.status,
    DnsOverrideKey.listen => l.listen,
    DnsOverrideKey.listenRoutingMark => l.listenRoutingMark,
    DnsOverrideKey.useHosts => l.useHosts,
    DnsOverrideKey.useSystemHosts => l.useSystemHosts,
    DnsOverrideKey.ipv6 => 'IPv6',
    DnsOverrideKey.ipv6Timeout => l.ipv6Timeout,
    DnsOverrideKey.respectRules => l.respectRules,
    DnsOverrideKey.preferH3 => 'Prefer H3',
    DnsOverrideKey.cacheAlgorithm => l.cacheAlgorithm,
    DnsOverrideKey.cacheMaxSize => l.cacheMaxSize,
    DnsOverrideKey.enhancedMode => l.dnsMode,
    DnsOverrideKey.fakeIpRange => l.fakeipRange,
    DnsOverrideKey.fakeIpRange6 => l.fakeipRange6,
    DnsOverrideKey.fakeIpFilter => l.fakeipFilter,
    DnsOverrideKey.fakeIpFilterMode => l.fakeipFilterMode,
    DnsOverrideKey.fakeIpTtl => l.fakeipTtl,
    DnsOverrideKey.defaultNameserver => 'Default Nameserver',
    DnsOverrideKey.nameserverPolicy => 'Nameserver Policy',
    DnsOverrideKey.nameserver => 'Nameserver',
    DnsOverrideKey.fallback => 'Fallback',
    DnsOverrideKey.fallbackLazyQuery => 'Fallback Lazy Query',
    DnsOverrideKey.proxyServerNameserver => 'Proxy Server Nameserver',
    DnsOverrideKey.proxyServerNameserverPolicy =>
      'Proxy Server Nameserver Policy',
    DnsOverrideKey.directNameserver => 'Direct Nameserver',
    DnsOverrideKey.directNameserverFollowPolicy =>
      'Direct Nameserver Follow Policy',
    DnsOverrideKey.fallbackFilterGeoip => 'GeoIP',
    DnsOverrideKey.fallbackFilterGeoipCode => 'GeoIP Code',
    DnsOverrideKey.fallbackFilterGeosite => 'GeoSite',
    DnsOverrideKey.fallbackFilterIpcidr => 'IP-CIDR',
    DnsOverrideKey.fallbackFilterDomain => l.domain,
  };

  ConfigLabel? get description => switch (this) {
    DnsOverrideKey.enable => (l) => l.statusDesc,
    DnsOverrideKey.listenRoutingMark => (l) => l.listenRoutingMarkDesc,
    DnsOverrideKey.respectRules => (l) => l.respectRulesDesc,
    DnsOverrideKey.fakeIpFilterMode => (l) => l.fakeipFilterModeDesc,
    _ => null,
  };

  String section(AppLocalizations l) => switch (this) {
    DnsOverrideKey.enable ||
    DnsOverrideKey.listen ||
    DnsOverrideKey.listenRoutingMark ||
    DnsOverrideKey.useHosts ||
    DnsOverrideKey.useSystemHosts ||
    DnsOverrideKey.ipv6 ||
    DnsOverrideKey.ipv6Timeout ||
    DnsOverrideKey.respectRules ||
    DnsOverrideKey.preferH3 ||
    DnsOverrideKey.cacheAlgorithm ||
    DnsOverrideKey.cacheMaxSize ||
    DnsOverrideKey.enhancedMode => l.options,
    DnsOverrideKey.fakeIpRange ||
    DnsOverrideKey.fakeIpRange6 ||
    DnsOverrideKey.fakeIpFilter ||
    DnsOverrideKey.fakeIpFilterMode ||
    DnsOverrideKey.fakeIpTtl => 'Fake-IP',
    DnsOverrideKey.defaultNameserver ||
    DnsOverrideKey.nameserverPolicy ||
    DnsOverrideKey.nameserver ||
    DnsOverrideKey.fallback ||
    DnsOverrideKey.fallbackLazyQuery ||
    DnsOverrideKey.proxyServerNameserver ||
    DnsOverrideKey.proxyServerNameserverPolicy ||
    DnsOverrideKey.directNameserver ||
    DnsOverrideKey.directNameserverFollowPolicy => 'Nameserver',
    DnsOverrideKey.fallbackFilterGeoip ||
    DnsOverrideKey.fallbackFilterGeoipCode ||
    DnsOverrideKey.fallbackFilterGeosite ||
    DnsOverrideKey.fallbackFilterIpcidr ||
    DnsOverrideKey.fallbackFilterDomain => l.fallbackFilter,
  };
}

// mihomo reports `hosts` in connection metadata but rejects it as an
// enhanced-mode.
const _enhancedModes = [DnsMode.normal, DnsMode.fakeIp, DnsMode.redirHost];

String _enhancedModeValue(DnsMode mode) => switch (mode) {
  DnsMode.normal => 'normal',
  DnsMode.fakeIp => 'fake-ip',
  DnsMode.redirHost => 'redir-host',
  DnsMode.hosts => 'hosts',
};

typedef _DnsState = OverrideState<DnsOverrideKey, Dns>;

_DnsState _patchDns(PatchClashConfig config) =>
    (model: config.dns, keys: config.dnsOverrideKeys);

PatchClashConfig _setPatchDns(PatchClashConfig config, _DnsState state) =>
    config.copyWith(dns: state.model, dnsOverrideKeys: state.keys);

_DnsState _profileDns(ProfileOverrides overrides) =>
    (model: overrides.dns, keys: overrides.dnsOverrideKeys);

ProfileOverrides _setProfileDns(ProfileOverrides overrides, _DnsState state) =>
    overrides.copyWith(dns: state.model, dnsOverrideKeys: state.keys);

String _patchDnsDescription(AppLocalizations l) => l.dnsOverrideDesc;

class DnsView extends OverrideView<DnsOverrideKey, Dns> {
  /// The keys written over the DNS of every subscription and file profile.
  const DnsView({super.key})
    : super(
        spec: const _DnsOverrideSpec(
          PatchOverrideTarget(
            get: _patchDns,
            set: _setPatchDns,
            description: _patchDnsDescription,
          ),
          keys: DnsOverrideKey.normalProfileKeys,
        ),
      );

  DnsView.profile(int profileId, {super.key})
    : super(
        spec: _ProfileDnsOverrideSpec(
          ProfileOverrideTarget(
            profileId,
            get: _profileDns,
            set: _setProfileDns,
            issues: customProfileIssuesProvider(
              profileId,
            ).select((state) => state.dns),
          ),
        ),
      );
}

class _DnsOverrideSpec extends OverrideSpec<DnsOverrideKey, Dns> {
  const _DnsOverrideSpec(this.target, {this.keys});

  @override
  final OverrideTarget<DnsOverrideKey, Dns> target;

  final Set<DnsOverrideKey>? keys;

  @override
  String title(AppLocalizations l) => 'DNS';

  @override
  List<DnsOverrideKey> get values =>
      keys == null ? DnsOverrideKey.values : [...?keys];

  @override
  NullStatusIllustration get illustration => NullStatusIllustration.dns;

  @override
  Dns get defaults => defaultDns;

  @override
  String sectionOf(DnsOverrideKey key, AppLocalizations l) => key.section(l);

  @override
  String label(DnsOverrideKey key, AppLocalizations l) => key.label(l);

  @override
  ConfigLabel? description(DnsOverrideKey key) => key.description;

  @override
  OverrideField<Dns> fieldOf(DnsOverrideKey key) => switch (key) {
    DnsOverrideKey.enable => ToggleOverrideField(
      (dns) => dns.enable,
      (dns, value) => dns.copyWith(enable: value),
    ),
    DnsOverrideKey.listen => TextOverrideField(
      (dns) => dns.listen,
      (dns, value) => dns.copyWith(listen: value),
      maxLength: TextInputLimits.dnsListen,
      validator: validateListenAddress,
    ),
    DnsOverrideKey.listenRoutingMark => NumberOverrideField(
      (dns) => dns.listenRoutingMark,
      (dns, value) => dns.copyWith(listenRoutingMark: value),
    ),
    DnsOverrideKey.useHosts => ToggleOverrideField(
      (dns) => dns.useHosts,
      (dns, value) => dns.copyWith(useHosts: value),
    ),
    DnsOverrideKey.useSystemHosts => ToggleOverrideField(
      (dns) => dns.useSystemHosts,
      (dns, value) => dns.copyWith(useSystemHosts: value),
    ),
    DnsOverrideKey.ipv6 => ToggleOverrideField(
      (dns) => dns.ipv6,
      (dns, value) => dns.copyWith(ipv6: value),
    ),
    DnsOverrideKey.ipv6Timeout => NumberOverrideField(
      (dns) => dns.ipv6Timeout,
      (dns, value) => dns.copyWith(ipv6Timeout: value),
    ),
    DnsOverrideKey.respectRules => ToggleOverrideField(
      (dns) => dns.respectRules,
      (dns, value) => dns.copyWith(respectRules: value),
    ),
    DnsOverrideKey.preferH3 => ToggleOverrideField(
      (dns) => dns.preferH3,
      (dns, value) => dns.copyWith(preferH3: value),
    ),
    DnsOverrideKey.cacheAlgorithm => OptionsOverrideField(
      DnsCacheAlgorithm.values,
      (dns) => dns.cacheAlgorithm,
      (dns, value) => dns.copyWith(cacheAlgorithm: value),
    ),
    DnsOverrideKey.cacheMaxSize => NumberOverrideField(
      (dns) => dns.cacheMaxSize,
      (dns, value) => dns.copyWith(cacheMaxSize: value),
    ),
    DnsOverrideKey.enhancedMode => OptionsOverrideField(
      _enhancedModes,
      (dns) => dns.enhancedMode,
      (dns, value) => dns.copyWith(enhancedMode: value),
      labelOf: _enhancedModeValue,
    ),
    DnsOverrideKey.fakeIpRange => TextOverrideField(
      (dns) => dns.fakeIpRange,
      (dns, value) => dns.copyWith(fakeIpRange: value),
      maxLength: TextInputLimits.cidr,
      validator: validateCidr,
    ),
    DnsOverrideKey.fakeIpRange6 => TextOverrideField(
      (dns) => dns.fakeIpRange6,
      (dns, value) => dns.copyWith(fakeIpRange6: value),
      maxLength: TextInputLimits.cidr,
      validator: validateCidr,
    ),
    DnsOverrideKey.fakeIpFilter => ListOverrideField(
      (dns) => dns.fakeIpFilter,
      (dns, value) => dns.copyWith(fakeIpFilter: value),
      itemMaxLength: TextInputLimits.domain,
    ),
    DnsOverrideKey.fakeIpFilterMode => OptionsOverrideField(
      FakeIpFilterMode.values,
      (dns) => dns.fakeIpFilterMode,
      (dns, value) => dns.copyWith(fakeIpFilterMode: value),
    ),
    DnsOverrideKey.fakeIpTtl => NumberOverrideField(
      (dns) => dns.fakeIpTtl,
      (dns, value) => dns.copyWith(fakeIpTtl: value),
    ),
    DnsOverrideKey.defaultNameserver => ListOverrideField(
      (dns) => dns.defaultNameserver,
      (dns, value) => dns.copyWith(defaultNameserver: value),
      itemMaxLength: TextInputLimits.dnsServer,
    ),
    DnsOverrideKey.nameserverPolicy => _PolicyField(
      (dns) => dns.nameserverPolicy,
      (dns, value) => dns.copyWith(nameserverPolicy: value),
    ),
    DnsOverrideKey.nameserver => ListOverrideField(
      (dns) => dns.nameserver,
      (dns, value) => dns.copyWith(nameserver: value),
      itemMaxLength: TextInputLimits.dnsServer,
    ),
    DnsOverrideKey.fallback => ListOverrideField(
      (dns) => dns.fallback,
      (dns, value) => dns.copyWith(fallback: value),
      itemMaxLength: TextInputLimits.dnsServer,
    ),
    DnsOverrideKey.fallbackLazyQuery => ToggleOverrideField(
      (dns) => dns.fallbackLazyQuery,
      (dns, value) => dns.copyWith(fallbackLazyQuery: value),
    ),
    DnsOverrideKey.proxyServerNameserver => ListOverrideField(
      (dns) => dns.proxyServerNameserver,
      (dns, value) => dns.copyWith(proxyServerNameserver: value),
      itemMaxLength: TextInputLimits.dnsServer,
    ),
    DnsOverrideKey.proxyServerNameserverPolicy => _PolicyField(
      (dns) => dns.proxyServerNameserverPolicy,
      (dns, value) => dns.copyWith(proxyServerNameserverPolicy: value),
    ),
    DnsOverrideKey.directNameserver => ListOverrideField(
      (dns) => dns.directNameserver,
      (dns, value) => dns.copyWith(directNameserver: value),
      itemMaxLength: TextInputLimits.dnsServer,
    ),
    DnsOverrideKey.directNameserverFollowPolicy => ToggleOverrideField(
      (dns) => dns.directNameserverFollowPolicy,
      (dns, value) => dns.copyWith(directNameserverFollowPolicy: value),
    ),
    DnsOverrideKey.fallbackFilterGeoip => ToggleOverrideField(
      (dns) => dns.fallbackFilter.geoip,
      (dns, value) => dns.copyWith.fallbackFilter(geoip: value),
    ),
    DnsOverrideKey.fallbackFilterGeoipCode => TextOverrideField(
      (dns) => dns.fallbackFilter.geoipCode,
      (dns, value) => dns.copyWith.fallbackFilter(geoipCode: value),
      maxLength: TextInputLimits.geoIpCode,
    ),
    DnsOverrideKey.fallbackFilterGeosite => ListOverrideField(
      (dns) => dns.fallbackFilter.geosite,
      (dns, value) => dns.copyWith.fallbackFilter(geosite: value),
      itemMaxLength: TextInputLimits.geoSite,
    ),
    DnsOverrideKey.fallbackFilterIpcidr => ListOverrideField(
      (dns) => dns.fallbackFilter.ipcidr,
      (dns, value) => dns.copyWith.fallbackFilter(ipcidr: value),
      itemMaxLength: TextInputLimits.cidr,
      itemValidator: validateCidr,
    ),
    DnsOverrideKey.fallbackFilterDomain => ListOverrideField(
      (dns) => dns.fallbackFilter.domain,
      (dns, value) => dns.copyWith.fallbackFilter(domain: value),
      itemMaxLength: TextInputLimits.domain,
    ),
  };
}

class _ProfileDnsOverrideSpec extends _DnsOverrideSpec
    with OverrideQuickEdit<DnsOverrideKey, Dns> {
  const _ProfileDnsOverrideSpec(super.target);

  @override
  String overrideYaml(Dns model, Set<DnsOverrideKey> keys) =>
      model.overrideYaml(keys);

  @override
  _DnsState applyOverrideYaml(Dns model, String content) {
    final result = model.applyOverrideYaml(content);
    return (model: result.dns, keys: result.keys);
  }

  @override
  EditorSchema get schema => EditorSchema.dns;
}

class _PolicyField extends ValueOverrideField<Dns, Map<String, String>> {
  const _PolicyField(super.select, super.update);

  @override
  Widget build(
    OverrideModel<Dns> model, {
    required ConfigLabel title,
    required Widget leading,
  }) {
    return _PolicyItem(
      model: model,
      title: title,
      leading: leading,
      select: select,
      update: update,
    );
  }
}

class _PolicyItem extends ConsumerWidget {
  const _PolicyItem({
    required this.model,
    required this.title,
    required this.leading,
    required this.select,
    required this.update,
  });

  final OverrideModel<Dns> model;
  final ConfigLabel title;
  final Widget leading;
  final Map<String, String> Function(Dns dns) select;
  final Dns Function(Dns dns, Map<String, String> value) update;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final title = this.title(appLocalizations);
    final policy = ref.watch(model.selectModel(select));
    return ListItem.open(
      leading: leading,
      title: Text(title),
      subtitle: Text(
        policy.isEmpty
            ? appLocalizations.none
            : appLocalizations.itemsCount(policy.length),
      ),
      widget: MapEditView(
        title: title,
        entries: policy,
        keyMaxLength: TextInputLimits.domain,
        valueMaxLength: TextInputLimits.dnsServer,
        titleBuilder: (item) => Text(item.key),
        subtitleBuilder: (item) => Text(item.value),
      ),
      onChanged: (value) {
        if (value is Map) {
          model.modelWriter(update)(ref, Map<String, String>.from(value));
        }
      },
    );
  }
}
