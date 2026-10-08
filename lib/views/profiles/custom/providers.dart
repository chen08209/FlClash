import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/form/form.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/profiles/custom/members.dart';
import 'package:fl_clash/views/profiles/custom/quick_edit.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef ReferencedProviders = ({List<String> proxy, List<String> rule});

/// A custom profile declares only the providers its groups and rules name, so
/// naming one is what lists it here.
ReferencedProviders referencedProviders(WidgetRef ref, int profileId) {
  final groups = ref.watch(proxyGroupsProvider(profileId)).value ?? const [];
  final rules = ref.watch(profileRulesProvider(profileId)).value ?? const [];
  final overrideRuleSets = ref.watch(
    profileProvider(
      profileId,
    ).select((profile) => SelectValue(profile?.overrides.ruleSets ?? const {})),
  );
  return (
    proxy: {for (final group in groups) ...?group.use}.toList(),
    rule: {
      for (final rule in rules) ...rule.ruleSets,
      ...overrideRuleSets.value,
    }.toList(),
  );
}

class CustomProvidersView extends ConsumerWidget {
  final int profileId;

  const CustomProvidersView(this.profileId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final (:proxy, :rule) = referencedProviders(ref, profileId);
    final data = ref.watch(customProfileDataProvider(profileId));
    final profiles = {
      for (final profile in ref.watch(profilesProvider))
        if (profile.type != ProfileType.custom) profile.realLabel: profile,
    };
    final ruleProviders = {
      for (final provider
          in ref.watch(clashProvidersProvider).value ?? const <ClashProvider>[])
        provider.label: provider,
    };
    return CommonScaffold(
      title: appLocalizations.providers,
      body: NullStatusSwitcher(
        isEmpty: proxy.isEmpty && rule.isEmpty,
        nullStatus: NullStatus(
          label: appLocalizations.nullTip(appLocalizations.providers),
          illustration: NullStatusIllustration.proxies,
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ).copyWith(top: context.contentTopPadding, bottom: 16),
          children: [
            generateSectionV3(
              title: appLocalizations.proxies,
              items: [
                for (final name in proxy)
                  _ProxyProviderItem(
                    profileId: profileId,
                    name: name,
                    profile: profiles[name],
                    invalid:
                        data != null && !data.proxyProviders.contains(name),
                  ),
              ],
            ),
            generateSectionV3(
              title: appLocalizations.rules,
              items: [
                for (final name in rule)
                  _RuleProviderItem(
                    name: name,
                    provider: ruleProviders[name],
                    invalid: data != null && !data.ruleProviders.contains(name),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProxyProviderItem extends ConsumerWidget {
  final int profileId;
  final String name;
  final Profile? profile;
  final bool invalid;

  const _ProxyProviderItem({
    required this.profileId,
    required this.name,
    required this.profile,
    required this.invalid,
  });

  void _handleEdit(BuildContext context, WidgetRef ref) {
    final options =
        ref.read(profileProvider(profileId))?.overrides.proxyProviders[name] ??
        const ProxyProviderOptions();
    showNestedFormSheet<ProxyProviderOptions>(
      context: context,
      profileId: profileId,
      overrides: [
        proxyProviderOptionsProvider.overrideWithBuild((_, _) => options),
      ],
      currentOf: (ref) => ref.read(proxyProviderOptionsProvider),
      formBuilder: (_) =>
          _ProxyProviderOptionsView(name: name, onSave: _handleSave),
    );
  }

  bool _handleSave(WidgetRef ref) {
    final options = ref.read(proxyProviderOptionsProvider);
    ref
        .read(profilesProvider.notifier)
        .updateProfile(
          profileId,
          (profile) => profile.copyWith.overrides(
            proxyProviders: {
              for (final MapEntry(:key, :value)
                  in profile.overrides.proxyProviders.entries)
                if (key != name) key: value,
              if (options != const ProxyProviderOptions()) name: options,
            },
          ),
        );
    return true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastUpdateDate = profile?.lastUpdateDate;
    return DecorationListItem(
      invalid: invalid,
      contentPadding: const EdgeInsets.only(left: 16, right: 8),
      onPressed: invalid ? null : () => _handleEdit(context, ref),
      title: TooltipText(
        text: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      subtitle: lastUpdateDate == null || invalid
          ? null
          : LastUpdateTimeText(lastUpdateDate: lastUpdateDate),
      trailing: invalid
          ? InfoMessageButton(
              message: context.appLocalizations.invalidProxyProvider(name),
            )
          : CommonMinIconButtonTheme(
              child: ElasticButton(
                child: IconButton.filledTonal(
                  tooltip: context.appLocalizations.edit,
                  onPressed: () => _handleEdit(context, ref),
                  icon: const GlyphIcon(AppGlyphs.edit, fill: 1),
                ),
              ),
            ),
    );
  }
}

class _RuleProviderItem extends StatefulWidget {
  final String name;
  final ClashProvider? provider;
  final bool invalid;

  const _RuleProviderItem({
    required this.name,
    required this.provider,
    required this.invalid,
  });

  @override
  State<_RuleProviderItem> createState() => _RuleProviderItemState();
}

class _RuleProviderItemState extends State<_RuleProviderItem> {
  late Future<DateTime?> _lastModified;

  @override
  void initState() {
    super.initState();
    _lastModified = _lastModifiedOf(widget.provider);
  }

  @override
  void didUpdateWidget(_RuleProviderItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.provider != widget.provider) {
      _lastModified = _lastModifiedOf(widget.provider);
    }
  }

  Future<DateTime?> _lastModifiedOf(ClashProvider? provider) async {
    if (provider == null) {
      return null;
    }
    final info = await File(await provider.path).getFileInfo();
    return info?.lastModified;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _lastModified,
      builder: (context, snapshot) {
        final lastModified = snapshot.data;
        return DecorationListItem(
          invalid: widget.invalid,
          contentPadding: const EdgeInsets.only(left: 16, right: 8),
          title: TooltipText(
            text: Text(
              widget.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          subtitle: lastModified == null
              ? null
              : LastUpdateTimeText(lastUpdateDate: lastModified),
          trailing: widget.invalid
              ? InfoMessageButton(
                  message: context.appLocalizations.invalidRuleSet(widget.name),
                )
              : null,
        );
      },
    );
  }
}

/// What a provider leaves to the core until it is added, starting from the
/// core's own default; an override starts from the value it is added to set.
enum _ProviderOption {
  url,
  interval,
  timeout,
  lazy,
  expectedStatus,
  additionalPrefix,
  additionalSuffix,
  udp,
  skipCertVerify,
  ipVersion;

  String label(AppLocalizations l) => switch (this) {
    url => l.testUrl,
    interval => l.testInterval,
    timeout => l.timeout,
    lazy => l.testWhenUsed,
    expectedStatus => l.expectedStatus,
    additionalPrefix => l.additionalPrefix,
    additionalSuffix => l.additionalSuffix,
    udp => 'UDP',
    skipCertVerify => l.skipCertVerify,
    ipVersion => l.ipVersion,
  };

  String section(AppLocalizations l) => switch (this) {
    url || interval || timeout || lazy || expectedStatus => l.healthCheck,
    additionalPrefix || additionalSuffix => l.name,
    udp || skipCertVerify || ipVersion => l.connection,
  };

  bool isSetIn(ProxyProviderOptions options) => switch (this) {
    url => options.healthCheck.url != null,
    interval => options.healthCheck.interval != null,
    timeout => options.healthCheck.timeout != null,
    lazy => options.healthCheck.lazy != null,
    expectedStatus => options.healthCheck.expectedStatus != null,
    additionalPrefix => options.proxyOverride.additionalPrefix != null,
    additionalSuffix => options.proxyOverride.additionalSuffix != null,
    udp => options.proxyOverride.udp != null,
    skipCertVerify => options.proxyOverride.skipCertVerify != null,
    ipVersion => options.proxyOverride.ipVersion != null,
  };

  ProxyProviderOptions reset(ProxyProviderOptions options) => switch (this) {
    url => options.copyWith.healthCheck(url: defaultTestUrl),
    interval => options.copyWith.healthCheck(interval: 300),
    timeout => options.copyWith.healthCheck(timeout: 5000),
    lazy => options.copyWith.healthCheck(lazy: true),
    udp => options.copyWith.proxyOverride(udp: true),
    skipCertVerify => options.copyWith.proxyOverride(skipCertVerify: true),
    ipVersion => options.copyWith.proxyOverride(ipVersion: IpVersion.dual),
    expectedStatus || additionalPrefix || additionalSuffix => clear(options),
  };

  ProxyProviderOptions clear(ProxyProviderOptions options) => switch (this) {
    url => options.copyWith.healthCheck(url: null),
    interval => options.copyWith.healthCheck(interval: null),
    timeout => options.copyWith.healthCheck(timeout: null),
    lazy => options.copyWith.healthCheck(lazy: null),
    expectedStatus => options.copyWith.healthCheck(expectedStatus: null),
    additionalPrefix => options.copyWith.proxyOverride(additionalPrefix: null),
    additionalSuffix => options.copyWith.proxyOverride(additionalSuffix: null),
    udp => options.copyWith.proxyOverride(udp: null),
    skipCertVerify => options.copyWith.proxyOverride(skipCertVerify: null),
    ipVersion => options.copyWith.proxyOverride(ipVersion: null),
  };
}

class _ProxyProviderOptionsView extends ConsumerStatefulWidget {
  final String name;
  final bool Function(WidgetRef ref) onSave;

  const _ProxyProviderOptionsView({required this.name, required this.onSave});

  @override
  ConsumerState<_ProxyProviderOptionsView> createState() =>
      _ProxyProviderOptionsViewState();
}

class _ProxyProviderOptionsViewState
    extends ConsumerState<_ProxyProviderOptionsView> {
  late Set<_ProviderOption> _shown;

  @override
  void initState() {
    super.initState();
    final options = ref.read(proxyProviderOptionsProvider);
    _shown = {
      for (final option in _ProviderOption.values)
        if (option.isSetIn(options)) option,
    };
    NestedFormSheet.bindSave(context, _handleSave);
  }

  void _handleSave() {
    if (widget.onSave(ref)) {
      context.safeNestedPop();
    }
  }

  void _update(
    ProxyProviderOptions Function(ProxyProviderOptions options) update,
  ) {
    ref.read(proxyProviderOptionsProvider.notifier).update(update);
  }

  void _handleAddOption(List<_ProviderOption> options) {
    final appLocalizations = context.appLocalizations;
    final sections = <String, List<_ProviderOption>>{};
    for (final option in options) {
      sections
          .putIfAbsent(option.section(appLocalizations), () => [])
          .add(option);
    }
    Navigator.of(context).push(
      PagedSheetRoute(
        builder: (_) => SelectionSheet<_ProviderOption>(
          title: appLocalizations.addSettingEntry,
          sections: [
            for (final MapEntry(:key, :value) in sections.entries)
              SelectionSection(label: key, items: value),
          ],
          labelBuilder: (option) => option.label(appLocalizations),
          selectedOf: (_) => null,
          removeOnSelect: true,
          onSelected: _handleAddedOption,
        ),
      ),
    );
  }

  void _handleAddedOption(_ProviderOption option) {
    if (!mounted) {
      return;
    }
    _update(option.reset);
    setState(() {
      _shown = {..._shown, option};
    });
  }

  void _handleRemoveOption(_ProviderOption option) {
    _update(option.clear);
    setState(() {
      _shown = {..._shown}..remove(option);
    });
  }

  Widget _buildTextItem({
    required _ProviderOption option,
    required Widget leading,
    required String? value,
    required int maxLength,
    required ValueChanged<String?> onChanged,
  }) {
    return FormRow(
      title: option.label(context.appLocalizations),
      leading: leading,
      trailing: TextFormField(
        textAlign: TextAlign.end,
        initialValue: value,
        inputFormatters: TextInputLimits.limit(maxLength),
        onChanged: (value) => onChanged(value.isEmpty ? null : value),
        decoration: InputDecoration.collapsed(
          border: const NoInputBorder(),
          hintText: context.appLocalizations.optional,
        ),
      ),
    );
  }

  Widget _buildNumberItem({
    required _ProviderOption option,
    required Widget leading,
    required int? value,
    required String suffix,
    required ValueChanged<int?> onChanged,
  }) {
    return FormRow(
      title: option.label(context.appLocalizations),
      leading: leading,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Flexible(
            child: TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: TextInputLimits.digitsOnly(
                TextInputLimits.number,
              ),
              textAlign: TextAlign.end,
              initialValue: value?.toString(),
              onChanged: (value) => onChanged(int.tryParse(value)),
              decoration: InputDecoration.collapsed(
                border: const NoInputBorder(),
                hintText: context.appLocalizations.optional,
              ),
            ),
          ),
          Text(suffix, style: context.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildSwitchItem({
    required _ProviderOption option,
    required Widget leading,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return FormRow(
      title: option.label(context.appLocalizations),
      leading: leading,
      onPressed: () => onChanged(!value),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  Future<void> _showIpVersionOptions() async {
    final value = await Navigator.of(context).push(
      PagedSheetRoute(
        builder: (context) => SelectionSheet<IpVersion>(
          title: context.appLocalizations.ipVersion,
          sections: const [SelectionSection(items: IpVersion.values)],
          labelBuilder: (item) => item.value,
          selectedOf: (ref) => ref.watch(
            proxyProviderOptionsProvider.select(
              (options) => options.proxyOverride.ipVersion ?? IpVersion.dual,
            ),
          ),
          onSelected: (item) => Navigator.of(context).pop(item),
        ),
      ),
    );
    if (value == null) {
      return;
    }
    _update((options) => options.copyWith.proxyOverride(ipVersion: value));
  }

  Widget _buildOption(_ProviderOption option, ProxyProviderOptions options) {
    final leading = EntryButton.remove(
      onPressed: () => _handleRemoveOption(option),
    );
    final healthCheck = options.healthCheck;
    final proxyOverride = options.proxyOverride;
    return switch (option) {
      _ProviderOption.url => _buildTextItem(
        option: option,
        leading: leading,
        value: healthCheck.url,
        maxLength: TextInputLimits.url,
        onChanged: (value) =>
            _update((options) => options.copyWith.healthCheck(url: value)),
      ),
      _ProviderOption.interval => _buildNumberItem(
        option: option,
        leading: leading,
        value: healthCheck.interval,
        suffix: 's',
        onChanged: (value) =>
            _update((options) => options.copyWith.healthCheck(interval: value)),
      ),
      _ProviderOption.timeout => _buildNumberItem(
        option: option,
        leading: leading,
        value: healthCheck.timeout,
        suffix: 'ms',
        onChanged: (value) =>
            _update((options) => options.copyWith.healthCheck(timeout: value)),
      ),
      _ProviderOption.lazy => _buildSwitchItem(
        option: option,
        leading: leading,
        value: healthCheck.lazy ?? true,
        onChanged: (value) =>
            _update((options) => options.copyWith.healthCheck(lazy: value)),
      ),
      _ProviderOption.expectedStatus => _buildTextItem(
        option: option,
        leading: leading,
        value: healthCheck.expectedStatus,
        maxLength: TextInputLimits.status,
        onChanged: (value) => _update(
          (options) => options.copyWith.healthCheck(expectedStatus: value),
        ),
      ),
      _ProviderOption.additionalPrefix => _buildTextItem(
        option: option,
        leading: leading,
        value: proxyOverride.additionalPrefix,
        maxLength: TextInputLimits.proxyName,
        onChanged: (value) => _update(
          (options) => options.copyWith.proxyOverride(additionalPrefix: value),
        ),
      ),
      _ProviderOption.additionalSuffix => _buildTextItem(
        option: option,
        leading: leading,
        value: proxyOverride.additionalSuffix,
        maxLength: TextInputLimits.proxyName,
        onChanged: (value) => _update(
          (options) => options.copyWith.proxyOverride(additionalSuffix: value),
        ),
      ),
      _ProviderOption.udp => _buildSwitchItem(
        option: option,
        leading: leading,
        value: proxyOverride.udp ?? true,
        onChanged: (value) =>
            _update((options) => options.copyWith.proxyOverride(udp: value)),
      ),
      _ProviderOption.skipCertVerify => _buildSwitchItem(
        option: option,
        leading: leading,
        value: proxyOverride.skipCertVerify ?? true,
        onChanged: (value) => _update(
          (options) => options.copyWith.proxyOverride(skipCertVerify: value),
        ),
      ),
      _ProviderOption.ipVersion => FormRow(
        title: option.label(context.appLocalizations),
        leading: leading,
        onPressed: _showIpVersionOptions,
        trailing: Row(
          spacing: 2,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                (proxyOverride.ipVersion ?? IpVersion.dual).value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const GlyphIcon(AppGlyphs.chevronForward),
          ],
        ),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final options = ref.watch(proxyProviderOptionsProvider);
    final remaining = [
      for (final option in _ProviderOption.values)
        if (!_shown.contains(option)) option,
    ];
    void handleAdd() => _handleAddOption(remaining);
    return CommonScaffold(
      title: widget.name,
      iconActions: customFormActions(context, onSave: _handleSave),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ).copyWith(top: context.contentTopPadding),
            sliver: const ProxyProviderFiltersSliver(),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ).copyWith(bottom: 20),
            sliver: SliverList.list(
              children: [
                generateAnimatedSection(
                  title: appLocalizations.options,
                  items: [
                    for (final option in _ProviderOption.values)
                      if (_shown.contains(option))
                        KeyedSubtree(
                          key: ValueKey(option),
                          child: _buildOption(option, options),
                        ),
                    if (remaining.isNotEmpty)
                      FormRow(
                        key: const ValueKey(#add),
                        leading: EntryButton.add(onPressed: handleAdd),
                        title: appLocalizations.addSettingEntry,
                        titleStyle: TextStyle(
                          color: context.colorScheme.primary,
                        ),
                        onPressed: handleAdd,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
