import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef _DnsUpdate<T> =
    PatchClashConfig Function(PatchClashConfig state, T value);

ProviderListenable<T> _dnsSelector<T>(T Function(Dns dns) select) {
  return patchClashConfigProvider.select((state) => select(state.dns));
}

ConfigWriter<T> _dnsWriter<T>(_DnsUpdate<T> update) {
  return (ref, value) => ref
      .read(patchClashConfigProvider.notifier)
      .update((state) => update(state, value));
}

ConfigToggleItem _dnsToggle({
  required ConfigLabel title,
  required bool Function(Dns dns) select,
  required _DnsUpdate<bool> update,
  ConfigLabel? subtitle,
}) {
  return ConfigToggleItem(
    title: title,
    subtitle: subtitle,
    selector: _dnsSelector(select),
    onChanged: _dnsWriter(update),
  );
}

ConfigTextItem _dnsText({
  required ConfigLabel title,
  required String Function(Dns dns) select,
  required _DnsUpdate<String> update,
  required int maxLength,
}) {
  return ConfigTextItem(
    title: title,
    selector: _dnsSelector(select),
    onChanged: _dnsWriter(update),
    maxLength: maxLength,
  );
}

ConfigListInputItem _dnsList({
  required ConfigLabel title,
  required List<String> Function(Dns dns) select,
  required _DnsUpdate<List<String>> update,
  required int itemMaxLength,
  ConfigLabel? subtitle,
}) {
  return ConfigListInputItem(
    title: title,
    subtitle: subtitle,
    selector: _dnsSelector(select),
    onChanged: _dnsWriter(update),
    itemMaxLength: itemMaxLength,
  );
}

class OverrideItem extends ConsumerWidget {
  const OverrideItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ConfigToggleItem(
      title: (l) => l.overrideDns,
      subtitle: (l) => l.overrideDnsDesc,
      selector: overrideDnsProvider,
      onChanged: (ref, value) =>
          ref.read(overrideDnsProvider.notifier).value = value,
    );
  }
}

class StatusItem extends ConsumerWidget {
  const StatusItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return _dnsToggle(
      title: (l) => l.status,
      subtitle: (l) => l.statusDesc,
      select: (dns) => dns.enable,
      update: (state, value) => state.copyWith.dns(enable: value),
    );
  }
}

class PreferH3Item extends ConsumerWidget {
  const PreferH3Item({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return _dnsToggle(
      title: (l) => 'PreferH3',
      subtitle: (l) => l.preferH3Desc,
      select: (dns) => dns.preferH3,
      update: (state, value) => state.copyWith.dns(preferH3: value),
    );
  }
}

class IPv6Item extends ConsumerWidget {
  const IPv6Item({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return _dnsToggle(
      title: (l) => 'IPv6',
      select: (dns) => dns.ipv6,
      update: (state, value) => state.copyWith.dns(ipv6: value),
    );
  }
}

class DnsModeItem extends ConsumerWidget {
  const DnsModeItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ConfigOptionsItem<DnsMode>(
      title: (l) => l.dnsMode,
      options: DnsMode.values,
      textBuilder: (dnsMode) => dnsMode.name,
      selector: _dnsSelector((dns) => dns.enhancedMode),
      onChanged: _dnsWriter(
        (state, value) => state.copyWith.dns(enhancedMode: value),
      ),
    );
  }
}

class NameserverPolicyItem extends ConsumerWidget {
  const NameserverPolicyItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final nameserverPolicy = ref.watch(
      _dnsSelector((dns) => dns.nameserverPolicy),
    );
    return ListItem.open(
      title: Text(appLocalizations.nameserverPolicy),
      subtitle: Text(appLocalizations.nameserverPolicyDesc),
      blur: false,
      widget: MapInputPage(
        title: appLocalizations.nameserverPolicy,
        map: nameserverPolicy,
        keyMaxLength: TextInputLimits.domain,
        valueMaxLength: TextInputLimits.dnsServer,
        titleBuilder: (item) => Text(item.key),
        subtitleBuilder: (item) => Text(item.value),
      ),
      onChanged: (value) {
        ref
            .read(patchClashConfigProvider.notifier)
            .update((state) => state.copyWith.dns(nameserverPolicy: value));
      },
    );
  }
}

class DnsOptions extends StatelessWidget {
  const DnsOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: generateSection(
        title: context.appLocalizations.options,
        items: [
          const StatusItem(),
          _dnsText(
            title: (l) => l.listen,
            select: (dns) => dns.listen,
            update: (state, value) => state.copyWith.dns(listen: value),
            maxLength: TextInputLimits.dnsListen,
          ),
          _dnsToggle(
            title: (l) => l.useHosts,
            select: (dns) => dns.useHosts,
            update: (state, value) => state.copyWith.dns(useHosts: value),
          ),
          _dnsToggle(
            title: (l) => l.useSystemHosts,
            select: (dns) => dns.useSystemHosts,
            update: (state, value) => state.copyWith.dns(useSystemHosts: value),
          ),
          const IPv6Item(),
          _dnsToggle(
            title: (l) => l.respectRules,
            subtitle: (l) => l.respectRulesDesc,
            select: (dns) => dns.respectRules,
            update: (state, value) => state.copyWith.dns(respectRules: value),
          ),
          const PreferH3Item(),
          const DnsModeItem(),
          _dnsText(
            title: (l) => l.fakeipRange,
            select: (dns) => dns.fakeIpRange,
            update: (state, value) => state.copyWith.dns(fakeIpRange: value),
            maxLength: TextInputLimits.cidr,
          ),
          _dnsList(
            title: (l) => l.fakeipFilter,
            select: (dns) => dns.fakeIpFilter,
            update: (state, value) => state.copyWith.dns(fakeIpFilter: value),
            itemMaxLength: TextInputLimits.domain,
          ),
          _dnsList(
            title: (l) => l.defaultNameserver,
            subtitle: (l) => l.defaultNameserverDesc,
            select: (dns) => dns.defaultNameserver,
            update: (state, value) =>
                state.copyWith.dns(defaultNameserver: value),
            itemMaxLength: TextInputLimits.dnsServer,
          ),
          const NameserverPolicyItem(),
          _dnsList(
            title: (l) => l.nameserver,
            subtitle: (l) => l.nameserverDesc,
            select: (dns) => dns.nameserver,
            update: (state, value) => state.copyWith.dns(nameserver: value),
            itemMaxLength: TextInputLimits.dnsServer,
          ),
          _dnsList(
            title: (l) => l.fallback,
            subtitle: (l) => l.fallbackDesc,
            select: (dns) => dns.fallback,
            update: (state, value) => state.copyWith.dns(fallback: value),
            itemMaxLength: TextInputLimits.dnsServer,
          ),
          _dnsList(
            title: (l) => l.proxyNameserver,
            subtitle: (l) => l.proxyNameserverDesc,
            select: (dns) => dns.proxyServerNameserver,
            update: (state, value) =>
                state.copyWith.dns(proxyServerNameserver: value),
            itemMaxLength: TextInputLimits.dnsServer,
          ),
        ],
      ),
    );
  }
}

class FallbackFilterOptions extends StatelessWidget {
  const FallbackFilterOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: generateSection(
        title: context.appLocalizations.fallbackFilter,
        items: [
          _dnsToggle(
            title: (l) => 'Geoip',
            select: (dns) => dns.fallbackFilter.geoip,
            update: (state, value) =>
                state.copyWith.dns.fallbackFilter(geoip: value),
          ),
          _dnsText(
            title: (l) => l.geoipCode,
            select: (dns) => dns.fallbackFilter.geoipCode,
            update: (state, value) =>
                state.copyWith.dns.fallbackFilter(geoipCode: value),
            maxLength: TextInputLimits.geoIpCode,
          ),
          _dnsList(
            title: (l) => 'Geosite',
            select: (dns) => dns.fallbackFilter.geosite,
            update: (state, value) =>
                state.copyWith.dns.fallbackFilter(geosite: value),
            itemMaxLength: TextInputLimits.geoSite,
          ),
          _dnsList(
            title: (l) => l.ipcidr,
            select: (dns) => dns.fallbackFilter.ipcidr,
            update: (state, value) =>
                state.copyWith.dns.fallbackFilter(ipcidr: value),
            itemMaxLength: TextInputLimits.cidr,
          ),
          _dnsList(
            title: (l) => l.domain,
            select: (dns) => dns.fallbackFilter.domain,
            update: (state, value) =>
                state.copyWith.dns.fallbackFilter(domain: value),
            itemMaxLength: TextInputLimits.domain,
          ),
        ],
      ),
    );
  }
}

const dnsItems = <Widget>[
  OverrideItem(),
  DnsOptions(),
  FallbackFilterOptions(),
];

class DnsListView extends ConsumerWidget {
  const DnsListView({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return generateListView(dnsItems);
  }
}
