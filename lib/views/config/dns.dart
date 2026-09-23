import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/overwrite/overwrite.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef _DnsUpdate<T> =
    PatchClashConfig Function(PatchClashConfig state, T value);

final _dnsOverrideKeysSelector = patchClashConfigProvider.select(
  (state) => state.dnsOverrideKeys,
);

ProviderListenable<T> _dnsSelector<T>(T Function(Dns dns) select) {
  return patchClashConfigProvider.select((state) => select(state.dns));
}

ConfigWriter<T> _dnsWriter<T>(_DnsUpdate<T> update) {
  return (ref, value) => ref
      .read(patchClashConfigProvider.notifier)
      .update((state) => update(state, value));
}

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
    DnsOverrideKey.preferH3 => 'PreferH3',
    DnsOverrideKey.cacheAlgorithm => l.cacheAlgorithm,
    DnsOverrideKey.cacheMaxSize => l.cacheMaxSize,
    DnsOverrideKey.enhancedMode => l.dnsMode,
    DnsOverrideKey.fakeIpRange => l.fakeipRange,
    DnsOverrideKey.fakeIpRange6 => l.fakeipRange6,
    DnsOverrideKey.fakeIpFilter => l.fakeipFilter,
    DnsOverrideKey.fakeIpFilterMode => l.fakeipFilterMode,
    DnsOverrideKey.fakeIpTtl => l.fakeipTtl,
    DnsOverrideKey.defaultNameserver => l.defaultNameserver,
    DnsOverrideKey.nameserverPolicy => l.nameserverPolicy,
    DnsOverrideKey.nameserver => l.nameserver,
    DnsOverrideKey.fallback => l.fallback,
    DnsOverrideKey.fallbackLazyQuery => l.fallbackLazyQuery,
    DnsOverrideKey.proxyServerNameserver => l.proxyNameserver,
    DnsOverrideKey.proxyServerNameserverPolicy => l.proxyNameserverPolicy,
    DnsOverrideKey.directNameserver => l.directNameserver,
    DnsOverrideKey.directNameserverFollowPolicy =>
      l.directNameserverFollowPolicy,
    DnsOverrideKey.fallbackFilterGeoip => 'Geoip',
    DnsOverrideKey.fallbackFilterGeoipCode => l.geoipCode,
    DnsOverrideKey.fallbackFilterGeosite => 'Geosite',
    DnsOverrideKey.fallbackFilterIpcidr => l.ipcidr,
    DnsOverrideKey.fallbackFilterDomain => l.domain,
  };

  ConfigLabel? get description => switch (this) {
    DnsOverrideKey.enable => (l) => l.statusDesc,
    DnsOverrideKey.listenRoutingMark => (l) => l.listenRoutingMarkDesc,
    DnsOverrideKey.ipv6Timeout => (l) => l.ipv6TimeoutDesc,
    DnsOverrideKey.respectRules => (l) => l.respectRulesDesc,
    DnsOverrideKey.preferH3 => (l) => l.preferH3Desc,
    DnsOverrideKey.cacheMaxSize => (l) => l.cacheMaxSizeDesc,
    DnsOverrideKey.fakeIpFilterMode => (l) => l.fakeipFilterModeDesc,
    DnsOverrideKey.fakeIpTtl => (l) => l.fakeipTtlDesc,
    DnsOverrideKey.defaultNameserver => (l) => l.defaultNameserverDesc,
    DnsOverrideKey.nameserver => (l) => l.nameserverDesc,
    DnsOverrideKey.fallback => (l) => l.fallbackDesc,
    DnsOverrideKey.fallbackLazyQuery => (l) => l.fallbackLazyQueryDesc,
    DnsOverrideKey.proxyServerNameserver => (l) => l.proxyNameserverDesc,
    DnsOverrideKey.proxyServerNameserverPolicy =>
      (l) => l.proxyNameserverPolicyDesc,
    DnsOverrideKey.directNameserver => (l) => l.directNameserverDesc,
    DnsOverrideKey.directNameserverFollowPolicy =>
      (l) => l.directNameserverFollowPolicyDesc,
    _ => null,
  };
}

// mihomo reports `hosts` in connection metadata but rejects it as an
// enhanced-mode.
const _enhancedModes = [DnsMode.normal, DnsMode.fakeIp, DnsMode.redirHost];

List<(String, List<DnsOverrideKey>)> _sectionsOf(
  AppLocalizations l,
  Iterable<DnsOverrideKey> keys,
) {
  return [
    (l.options, keys.where((key) => !key.isFallbackFilter).toList()),
    (l.fallbackFilter, keys.where((key) => key.isFallbackFilter).toList()),
  ];
}

class DnsView extends ConsumerWidget {
  const DnsView({super.key});

  Future<void> _handleAdd(BuildContext context, WidgetRef ref) async {
    final appLocalizations = context.appLocalizations;
    final added = ref.read(_dnsOverrideKeysSelector);
    final remaining = DnsOverrideKey.values.where(
      (key) => !added.contains(key),
    );
    final key = await showSheet<DnsOverrideKey>(
      context: context,
      props: const SheetProps(isScrollControlled: true),
      builder: (context) => OverwriteSelectionSheet<DnsOverrideKey>(
        title: appLocalizations.addOverrideEntry,
        sections: [
          for (final (label, keys) in _sectionsOf(appLocalizations, remaining))
            if (keys.isNotEmpty)
              OverwriteSelectionSection(
                label: label,
                items: keys,
                subtitleBuilder: (context, key) =>
                    key.description?.call(context.appLocalizations),
              ),
        ],
        labelBuilder: (key) => key.label(appLocalizations),
        selectedOf: (_) => null,
        onSelected: (key) => Navigator.of(context).pop(key),
      ),
    );
    if (key == null || !context.mounted) {
      return;
    }
    ref
        .read(patchClashConfigProvider.notifier)
        .update(
          (state) =>
              state.copyWith(dnsOverrideKeys: {...state.dnsOverrideKeys, key}),
        );
  }

  Future<void> _handleQuickEdit(BuildContext context, WidgetRef ref) {
    final config = ref.read(patchClashConfigProvider);
    final raw = config.dns.overrideYaml(config.dnsOverrideKeys);
    return BaseNavigator.push(
      context,
      EditorPage(
        title: 'DNS',
        content: raw,
        readOnly: false,
        onPop: (_, _, content) => _handleQuickEditPop(ref, content, raw),
      ),
    );
  }

  Future<bool> _handleQuickEditPop(
    WidgetRef ref,
    String content,
    String raw,
  ) async {
    if (content == raw) {
      return true;
    }
    try {
      final result = ref
          .read(patchClashConfigProvider)
          .dns
          .applyOverrideYaml(content);
      ref
          .read(patchClashConfigProvider.notifier)
          .update(
            (state) =>
                state.copyWith(dns: result.dns, dnsOverrideKeys: result.keys),
          );
      return true;
    } catch (error) {
      final res = await dialogs.showMessage(
        message: TextSpan(
          text:
              '${compactError(error)}\n\n'
              '${currentAppLocalizations.discardChanges}',
        ),
      );
      return res == true;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final canAdd = ref.watch(
      _dnsOverrideKeysSelector.select(
        (keys) => keys.length < DnsOverrideKey.values.length,
      ),
    );
    return BaseScaffold(
      title: 'DNS',
      menuItems: [
        CommonPopupMenuItem(
          glyph: AppGlyphs.add,
          label: appLocalizations.add,
          onPressed: canAdd ? () => _handleAdd(context, ref) : null,
        ),
        CommonPopupMenuItem(
          glyph: AppGlyphs.compose,
          label: appLocalizations.quickEdit,
          onPressed: () => _handleQuickEdit(context, ref),
        ),
      ],
      body: const _OverrideList(),
    );
  }
}

class _OverrideList extends ConsumerWidget {
  const _OverrideList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final keys = ref.watch(_dnsOverrideKeysSelector);
    final entries = DnsOverrideKey.values.where(keys.contains);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
            top: context.contentTopPadding,
            bottom: entries.isEmpty ? 0 : 16,
          ),
          sliver: SliverList.list(
            children: [
              generateSectionV3(
                items: [
                  ConfigToggleItem(
                    title: (l) => l.overrideDns,
                    selector: overrideDnsProvider,
                    onChanged: (ref, value) =>
                        ref.read(overrideDnsProvider.notifier).value = value,
                  ),
                ],
              ),
              for (final (title, keys) in _sectionsOf(
                appLocalizations,
                entries,
              ))
                generateSectionV3(
                  title: title,
                  items: [
                    for (final key in keys)
                      _OverrideItem(key: ValueKey(key), overrideKey: key),
                  ],
                ),
            ],
          ),
        ),
        if (entries.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: NullStatus(
              label: appLocalizations.nullTip(appLocalizations.overrideEntries),
              illustration: NullStatusIllustration.dns,
            ),
          ),
      ],
    );
  }
}

class _OverrideItem extends StatelessWidget {
  const _OverrideItem({super.key, required this.overrideKey});

  final DnsOverrideKey overrideKey;

  @override
  Widget build(BuildContext context) {
    final leading = _RemoveButton(overrideKey);
    final title = overrideKey.label;

    Widget toggle(bool Function(Dns dns) select, _DnsUpdate<bool> update) {
      return ConfigToggleItem(
        leading: leading,
        title: title,
        subtitle: overrideKey.description,
        selector: _dnsSelector(select),
        onChanged: _dnsWriter(update),
      );
    }

    Widget text(
      String Function(Dns dns) select,
      _DnsUpdate<String> update, {
      required int maxLength,
    }) {
      return ConfigTextItem(
        leading: leading,
        title: title,
        selector: _dnsSelector(select),
        onChanged: _dnsWriter(update),
        maxLength: maxLength,
      );
    }

    Widget number(int Function(Dns dns) select, _DnsUpdate<int> update) {
      return ConfigTextItem(
        leading: leading,
        title: title,
        selector: _dnsSelector((dns) => '${select(dns)}'),
        onChanged: _dnsWriter<String>(
          (state, value) => update(state, int.parse(value)),
        ),
        maxLength: TextInputLimits.number,
        keyboardType: TextInputType.number,
        normalize: (value) => value.trim(),
        validator: (value, l) => (int.tryParse(value ?? '') ?? -1) < 0
            ? l.numberTip(title(l))
            : null,
      );
    }

    Widget options<T extends Enum>(
      List<T> values,
      T Function(Dns dns) select,
      _DnsUpdate<T> update,
    ) {
      return ConfigOptionsItem<T>(
        leading: leading,
        title: title,
        options: values,
        textBuilder: (value) => value.name,
        selector: _dnsSelector(select),
        onChanged: _dnsWriter(update),
      );
    }

    Widget policy(
      Map<String, String> Function(Dns dns) select,
      _DnsUpdate<Map<String, String>> update,
    ) {
      return _PolicyItem(
        overrideKey: overrideKey,
        leading: leading,
        select: select,
        update: update,
      );
    }

    Widget list(
      List<String> Function(Dns dns) select,
      _DnsUpdate<List<String>> update, {
      required int itemMaxLength,
    }) {
      return ConfigListEditItem(
        leading: leading,
        title: title,
        subtitle: overrideKey.description,
        selector: _dnsSelector(select),
        onChanged: _dnsWriter(update),
        itemMaxLength: itemMaxLength,
      );
    }

    return switch (overrideKey) {
      DnsOverrideKey.enable => toggle(
        (dns) => dns.enable,
        (state, value) => state.copyWith.dns(enable: value),
      ),
      DnsOverrideKey.listen => text(
        (dns) => dns.listen,
        (state, value) => state.copyWith.dns(listen: value),
        maxLength: TextInputLimits.dnsListen,
      ),
      DnsOverrideKey.listenRoutingMark => number(
        (dns) => dns.listenRoutingMark,
        (state, value) => state.copyWith.dns(listenRoutingMark: value),
      ),
      DnsOverrideKey.useHosts => toggle(
        (dns) => dns.useHosts,
        (state, value) => state.copyWith.dns(useHosts: value),
      ),
      DnsOverrideKey.useSystemHosts => toggle(
        (dns) => dns.useSystemHosts,
        (state, value) => state.copyWith.dns(useSystemHosts: value),
      ),
      DnsOverrideKey.ipv6 => toggle(
        (dns) => dns.ipv6,
        (state, value) => state.copyWith.dns(ipv6: value),
      ),
      DnsOverrideKey.ipv6Timeout => number(
        (dns) => dns.ipv6Timeout,
        (state, value) => state.copyWith.dns(ipv6Timeout: value),
      ),
      DnsOverrideKey.respectRules => toggle(
        (dns) => dns.respectRules,
        (state, value) => state.copyWith.dns(respectRules: value),
      ),
      DnsOverrideKey.preferH3 => toggle(
        (dns) => dns.preferH3,
        (state, value) => state.copyWith.dns(preferH3: value),
      ),
      DnsOverrideKey.cacheAlgorithm => options(
        DnsCacheAlgorithm.values,
        (dns) => dns.cacheAlgorithm,
        (state, value) => state.copyWith.dns(cacheAlgorithm: value),
      ),
      DnsOverrideKey.cacheMaxSize => number(
        (dns) => dns.cacheMaxSize,
        (state, value) => state.copyWith.dns(cacheMaxSize: value),
      ),
      DnsOverrideKey.enhancedMode => options(
        _enhancedModes,
        (dns) => dns.enhancedMode,
        (state, value) => state.copyWith.dns(enhancedMode: value),
      ),
      DnsOverrideKey.fakeIpRange => text(
        (dns) => dns.fakeIpRange,
        (state, value) => state.copyWith.dns(fakeIpRange: value),
        maxLength: TextInputLimits.cidr,
      ),
      DnsOverrideKey.fakeIpRange6 => text(
        (dns) => dns.fakeIpRange6,
        (state, value) => state.copyWith.dns(fakeIpRange6: value),
        maxLength: TextInputLimits.cidr,
      ),
      DnsOverrideKey.fakeIpFilter => list(
        (dns) => dns.fakeIpFilter,
        (state, value) => state.copyWith.dns(fakeIpFilter: value),
        itemMaxLength: TextInputLimits.domain,
      ),
      DnsOverrideKey.fakeIpFilterMode => options(
        FakeIpFilterMode.values,
        (dns) => dns.fakeIpFilterMode,
        (state, value) => state.copyWith.dns(fakeIpFilterMode: value),
      ),
      DnsOverrideKey.fakeIpTtl => number(
        (dns) => dns.fakeIpTtl,
        (state, value) => state.copyWith.dns(fakeIpTtl: value),
      ),
      DnsOverrideKey.defaultNameserver => list(
        (dns) => dns.defaultNameserver,
        (state, value) => state.copyWith.dns(defaultNameserver: value),
        itemMaxLength: TextInputLimits.dnsServer,
      ),
      DnsOverrideKey.nameserverPolicy => policy(
        (dns) => dns.nameserverPolicy,
        (state, value) => state.copyWith.dns(nameserverPolicy: value),
      ),
      DnsOverrideKey.nameserver => list(
        (dns) => dns.nameserver,
        (state, value) => state.copyWith.dns(nameserver: value),
        itemMaxLength: TextInputLimits.dnsServer,
      ),
      DnsOverrideKey.fallback => list(
        (dns) => dns.fallback,
        (state, value) => state.copyWith.dns(fallback: value),
        itemMaxLength: TextInputLimits.dnsServer,
      ),
      DnsOverrideKey.fallbackLazyQuery => toggle(
        (dns) => dns.fallbackLazyQuery,
        (state, value) => state.copyWith.dns(fallbackLazyQuery: value),
      ),
      DnsOverrideKey.proxyServerNameserver => list(
        (dns) => dns.proxyServerNameserver,
        (state, value) => state.copyWith.dns(proxyServerNameserver: value),
        itemMaxLength: TextInputLimits.dnsServer,
      ),
      DnsOverrideKey.proxyServerNameserverPolicy => policy(
        (dns) => dns.proxyServerNameserverPolicy,
        (state, value) =>
            state.copyWith.dns(proxyServerNameserverPolicy: value),
      ),
      DnsOverrideKey.directNameserver => list(
        (dns) => dns.directNameserver,
        (state, value) => state.copyWith.dns(directNameserver: value),
        itemMaxLength: TextInputLimits.dnsServer,
      ),
      DnsOverrideKey.directNameserverFollowPolicy => toggle(
        (dns) => dns.directNameserverFollowPolicy,
        (state, value) =>
            state.copyWith.dns(directNameserverFollowPolicy: value),
      ),
      DnsOverrideKey.fallbackFilterGeoip => toggle(
        (dns) => dns.fallbackFilter.geoip,
        (state, value) => state.copyWith.dns.fallbackFilter(geoip: value),
      ),
      DnsOverrideKey.fallbackFilterGeoipCode => text(
        (dns) => dns.fallbackFilter.geoipCode,
        (state, value) => state.copyWith.dns.fallbackFilter(geoipCode: value),
        maxLength: TextInputLimits.geoIpCode,
      ),
      DnsOverrideKey.fallbackFilterGeosite => list(
        (dns) => dns.fallbackFilter.geosite,
        (state, value) => state.copyWith.dns.fallbackFilter(geosite: value),
        itemMaxLength: TextInputLimits.geoSite,
      ),
      DnsOverrideKey.fallbackFilterIpcidr => list(
        (dns) => dns.fallbackFilter.ipcidr,
        (state, value) => state.copyWith.dns.fallbackFilter(ipcidr: value),
        itemMaxLength: TextInputLimits.cidr,
      ),
      DnsOverrideKey.fallbackFilterDomain => list(
        (dns) => dns.fallbackFilter.domain,
        (state, value) => state.copyWith.dns.fallbackFilter(domain: value),
        itemMaxLength: TextInputLimits.domain,
      ),
    };
  }
}

class _PolicyItem extends ConsumerWidget {
  const _PolicyItem({
    required this.overrideKey,
    required this.leading,
    required this.select,
    required this.update,
  });

  final DnsOverrideKey overrideKey;
  final Widget leading;
  final Map<String, String> Function(Dns dns) select;
  final _DnsUpdate<Map<String, String>> update;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final title = overrideKey.label(appLocalizations);
    final description = overrideKey.description;
    final policy = ref.watch(_dnsSelector(select));
    return ListItem.open(
      leading: leading,
      title: Text(title),
      subtitle: description == null
          ? null
          : Text(description(appLocalizations)),
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
          _dnsWriter(update)(ref, Map<String, String>.from(value));
        }
      },
    );
  }
}

class _RemoveButton extends ConsumerWidget {
  const _RemoveButton(this.overrideKey);

  final DnsOverrideKey overrideKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonMinIconButtonTheme(
      child: ElasticButton(
        child: IconButton.filledTonal(
          tooltip: context.appLocalizations.remove,
          onPressed: () => ref
              .read(patchClashConfigProvider.notifier)
              .update(
                (state) => state.copyWith(
                  dnsOverrideKeys: {...state.dnsOverrideKeys}
                    ..remove(overrideKey),
                ),
              ),
          icon: const GlyphIcon(AppGlyphs.remove, size: 18, fill: 1),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
