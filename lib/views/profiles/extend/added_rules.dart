import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/form/form.dart';
import 'package:fl_clash/models/clash_config.dart';
import 'package:fl_clash/models/profile.dart';
import 'package:fl_clash/providers/mitm.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/config/rules.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddedRulesContent extends ConsumerStatefulWidget {
  const AddedRulesContent({super.key});

  @override
  ConsumerState createState() => _AddedRulesContentState();
}

class _AddedRulesContentState extends ConsumerState<AddedRulesContent> {
  final _key = uniqueId;
  late int _profileId;

  Future<void> _handleAddOrUpdate([Rule? rule]) async {
    final exits = customExitsOf([
      ...?ref.read(profileRulesProvider(_profileId)).value,
      ...?ref.read(globalRulesProvider).value,
    ]);
    final res = await showFormSheet<Rule>(
      context: context,
      builder: (_) => RuleForm(rule: rule, exits: exits),
    );
    if (res == null) {
      return;
    }
    ref.read(profileRulesProvider(_profileId).notifier).put(res);
  }

  void _handleQuickActions() {
    showNestedSheet<void>(
      context,
      builder: (_) => RulePresetSheet(
        onAdd: ref.read(profileRulesProvider(_profileId).notifier).putAll,
      ),
    );
  }

  void _handleSelected(int ruleId) {
    ref.read(itemsProvider(_key).notifier).update((selectedRules) {
      final newSelectedRules = Set<int>.from(selectedRules)
        ..addOrRemove(ruleId);
      return newSelectedRules;
    });
  }

  void _handleSelectAll() {
    final ids =
        ref
            .read(profileRulesProvider(_profileId))
            .value
            ?.map((item) => item.id)
            .toSet() ??
        {};
    ref.read(itemsProvider(_key).notifier).update((selected) {
      return selected.containsAll(ids) ? {} : ids;
    });
  }

  Future<void> _handleDelete() async {
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(
        text: appLocalizations.deleteMultipTip(appLocalizations.rule),
      ),
      destructive: true,
      confirmText: appLocalizations.delete,
    );
    if (res != true) {
      return;
    }
    final selectedRules = ref.read(itemsProvider(_key));
    ref
        .read(profileRulesProvider(_profileId).notifier)
        .delAll(selectedRules.cast<int>());
    ref.read(itemsProvider(_key).notifier).value = {};
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _profileId = ProfileIdProvider.of(context)!.profileId;
  }

  Widget _buildRuleItem(List<Rule> rules, int index, Set<dynamic> selected) {
    final rule = rules[index];
    return ReorderDragStartListener(
      key: ObjectKey(rule),
      index: index,
      child: ItemPositionProvider(
        position: ItemPosition.get(index, rules.length),
        child: Container(
          margin: context.listInsets.page(),
          child: RuleItem(
            isEditing: selected.isNotEmpty,
            isSelected: selected.contains(rule.id),
            rule: rule,
            onSelected: () {
              _handleSelected(rule.id);
            },
            onEdit: (rule) {
              _handleAddOrUpdate(rule);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    _profileId = ProfileIdProvider.of(context)!.profileId;
    final addedRules = ref.watch(profileRulesProvider(_profileId)).value ?? [];
    final selectedRules = ref.watch(itemsProvider(_key));
    return PopGuard(
      onPop: selectedRules.isEmpty
          ? null
          : (_) {
              ref.read(itemsProvider(_key).notifier).value = {};
              return false;
            },
      child: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: context.listInsets.page(),
              child: ListHeader(
                title: appLocalizations.addedRules,
                caption: appLocalizations.addedRulesAfterScript,
                actions: [
                  if (selectedRules.isNotEmpty) ...[
                    IconButtonData(
                      glyph: AppGlyphs.delete,
                      tooltip: appLocalizations.delete,
                      onPressed: _handleDelete,
                    ),
                    IconButtonData(
                      glyph: AppGlyphs.selectAll,
                      tooltip: appLocalizations.selectAll,
                      onPressed: _handleSelectAll,
                    ),
                  ] else ...[
                    IconButtonData(
                      glyph: AppGlyphs.rulePresets,
                      tooltip: appLocalizations.quickActions,
                      onPressed: _handleQuickActions,
                    ),
                    IconButtonData(
                      glyph: AppGlyphs.addCircle,
                      tooltip: appLocalizations.add,
                      onPressed: _handleAddOrUpdate,
                    ),
                  ],
                ],
              ),
            ),
          ),
          SliverPrismReorderableList(
            itemCount: addedRules.length,
            itemBuilder: (_, index) =>
                _buildRuleItem(addedRules, index, selectedRules),
            proxyDecorator: (child, index, animation) => commonProxyDecorator(
              _buildRuleItem(addedRules, index, selectedRules),
              index,
              animation,
            ),
            itemExtent: ruleItemHeight,
            onReorderItem: ref
                .read(profileRulesProvider(_profileId).notifier)
                .order,
          ),
          if (addedRules.isNotEmpty)
            const SliverToBoxAdapter(child: ListSectionGap()),
          SliverPadding(
            padding: context.listInsets.page(),
            sliver: SliverToBoxAdapter(
              child: generateGroup([_GlobalAddedRulesItem(_profileId)]),
            ),
          ),
          SliverPadding(
            padding: context.listInsets.page(),
            sliver: SliverToBoxAdapter(child: ExitsSection(_profileId)),
          ),
        ],
      ),
    );
  }
}

bool _runsScript(Profile? profile) =>
    profile?.type != ProfileType.custom && profile?.scriptId != null;

/// A custom profile has no profile file: its own groups, the app's proxies
/// and its own rules stand in.
ClashConfig? _watchOutbounds(WidgetRef ref, int profileId) {
  if (ref.watch(
    profileProvider(
      profileId,
    ).select((state) => state?.type == ProfileType.custom),
  )) {
    final groups = ref.watch(proxyGroupsProvider(profileId)).value;
    final proxies = ref.watch(customProxiesProvider).value;
    final rules = ref.watch(profileRulesProvider(profileId)).value;
    if (groups == null || proxies == null || rules == null) {
      return null;
    }
    return ClashConfig(
      proxyGroups: groups,
      rules: rules,
      proxies: [
        for (final proxy in proxies)
          if (proxy.definition case {
            'name': final String name,
            'type': final String type,
          })
            Proxy(name: name, type: type),
      ],
    );
  }
  final scripted = ref.watch(profileProvider(profileId).select(_runsScript))
      ? ref.watch(scriptOutboundsProvider(profileId))
      : const AsyncData<ClashConfig?>(null);
  return switch (scripted) {
    AsyncData(value: final config?) => config,
    AsyncData() => ref.watch(clashConfigProvider(profileId)).value,
    _ => null,
  };
}

String? _watchFallback(WidgetRef ref, int profileId) =>
    ref.watch(
      profileProvider(
        profileId,
      ).select((state) => state?.type == ProfileType.custom),
    )
    ? matchTargetOf(_watchOutbounds(ref, profileId)?.rules ?? const [])
    : ref.watch(profileMatchTargetProvider(profileId)).value;

Set<String> _namesOf(ClashConfig config) => {
  for (final item in config.proxyGroups) item.name,
  for (final item in config.proxies) item.name,
};

/// The exits a profile's added rules and the enabled MITM modules name; a
/// custom profile has only the modules'.
class ExitsSection extends ConsumerWidget {
  final int profileId;
  final bool modulesOnly;

  const ExitsSection(this.profileId, {super.key, this.modulesOnly = false});

  List<String> _watchExits(WidgetRef ref, Map<String, List<String>> modules) {
    if (modulesOnly) {
      return modules.keys.toList();
    }
    final own = ref.watch(profileRulesProvider(profileId)).value ?? const [];
    final global = ref.watch(globalRulesProvider).value ?? const [];
    final disabled =
        ref.watch(profileDisabledRuleIdsProvider(profileId)).value ?? const [];
    return {
      ...customExitsOf([
        ...own,
        ...global.where((rule) => !disabled.contains(rule.id)),
      ]),
      ...modules.keys,
    }.toList();
  }

  Future<void> _handleSelect(
    BuildContext context,
    WidgetRef ref,
    String exit,
  ) async {
    final res = await showNestedSheet<String>(
      context,
      builder: (context) => Consumer(
        builder: (_, ref, _) {
          final appLocalizations = context.appLocalizations;
          final scripted =
              ref.watch(profileProvider(profileId).select(_runsScript))
              ? ref.watch(scriptOutboundsProvider(profileId))
              : const AsyncData<ClashConfig?>(null);
          if (scripted case AsyncError(:final error)) {
            return Scaffold(
              title: exit,
              body: NullStatus(
                label: appLocalizations.scriptFailed,
                description: '$error',
                illustration: NullStatusIllustration.error,
                action: TonalButton(
                  size: TonalButtonSize.bar,
                  label: appLocalizations.exitDefault,
                  onPressed: () => Navigator.of(context).pop(''),
                ),
              ),
            );
          }
          final clashConfig = _watchOutbounds(ref, profileId);
          final fallback = _watchFallback(ref, profileId);
          final groups = clashConfig?.proxyGroups ?? const [];
          final proxies = clashConfig?.proxies ?? const [];
          final groupTypes = {
            for (final item in groups) item.name: item.type.name,
          };
          final proxyTypes = {for (final item in proxies) item.name: item.type};
          final defaultTarget =
              groupTypes.containsKey(exit) || proxyTypes.containsKey(exit)
              ? exit
              : fallback;
          return SelectionSheet<String>(
            title: exit,
            sections: [
              SelectionSection(
                items: const [''],
                subtitleBuilder: (_, _) => defaultTarget,
              ),
              SelectionSection(
                label: appLocalizations.basicStrategy,
                items: [
                  for (final name in RuleTarget.ruleTargetNames)
                    if (!groupTypes.containsKey(name)) name,
                ],
              ),
              SelectionSection(
                label: appLocalizations.ruleTarget,
                items: groupTypes.keys.toList(),
                subtitleBuilder: (_, name) => groupTypes[name] ?? '',
              ),
              SelectionSection(
                label: appLocalizations.proxies,
                items: proxyTypes.keys.toList(),
                subtitleBuilder: (_, name) => proxyTypes[name] ?? '',
              ),
            ],
            labelBuilder: (item) =>
                item.isEmpty ? appLocalizations.exitDefault : item,
            selectedOf: (ref) => ref.watch(
              profileProvider(
                profileId,
              ).select((state) => state?.exitTargets[exit] ?? ''),
            ),
            onSelected: (item) => Navigator.of(context).pop(item),
            loadingStatus: scripted is AsyncLoading
                ? const NullStatus(illustration: NullStatusIllustration.proxies)
                : null,
          );
        },
      ),
    );
    if (res == null) {
      return;
    }
    ref.read(profilesProvider.notifier).updateProfile(profileId, (state) {
      final exitTargets = {...state.exitTargets}..remove(exit);
      return state.copyWith(
        exitTargets: res.isEmpty ? exitTargets : {...exitTargets, exit: res},
      );
    });
  }

  Widget _buildExit(
    BuildContext context,
    WidgetRef ref, {
    required String exit,
    required String? target,
    required Set<String>? names,
    required String? fallback,
    required List<String>? modules,
  }) {
    bool usable(String? name) =>
        name != null &&
        (RuleTarget.ruleTargets.contains(name) || names!.contains(name));
    final invalid = names != null && target != null && !usable(target);
    final actual = names == null || (target != null && !invalid)
        ? null
        : names.contains(exit)
        ? exit
        : usable(fallback)
        ? fallback
        : null;
    final lines = [
      ?actual,
      if (modules != null)
        context.appLocalizations.mitmExitModules(modules.join(', ')),
    ];
    return ListItem(
      title: Text(exit),
      subtitle: lines.isEmpty ? null : Text(lines.join('\n')),
      trailing: Text(
        target ?? context.appLocalizations.exitDefault,
        style: AppTextStyle.subheadline
            .of(context)
            .toJetBrainsMono
            .copyWith(
              color: invalid
                  ? context.colorScheme.error
                  : context.colorScheme.tertiary,
            ),
      ),
      onTap: () {
        _handleSelect(context, ref, exit);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = ref.watch(mitmModuleExitsProvider).value ?? const {};
    final exits = _watchExits(ref, modules);
    if (exits.isEmpty) {
      return const SizedBox.shrink();
    }
    final exitTargets = ref.watch(
      profileProvider(profileId).select((state) => state?.exitTargets),
    );
    final outbounds = _watchOutbounds(ref, profileId);
    final names = outbounds == null ? null : _namesOf(outbounds);
    final fallback = _watchFallback(ref, profileId);
    return generateSection(
      title: context.appLocalizations.outboundExit,
      items: [
        for (final exit in exits)
          _buildExit(
            context,
            ref,
            exit: exit,
            target: exitTargets?[exit],
            names: names,
            fallback: fallback,
            modules: modules[exit],
          ),
      ],
    );
  }
}

class _GlobalAddedRulesItem extends ConsumerWidget {
  final int profileId;

  const _GlobalAddedRulesItem(this.profileId);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rules = ref.watch(globalRulesProvider).value ?? const <Rule>[];
    final disabled =
        ref.watch(profileDisabledRuleIdsProvider(profileId)).value ??
        const <int>[];
    final enabled = rules.where((rule) => !disabled.contains(rule.id)).length;
    return ListItem.open(
      title: Text(context.appLocalizations.controlGlobalAddedRules),
      trailing: rules.isEmpty
          ? null
          : Row(
              spacing: 2,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$enabled/${rules.length}'),
                const GlyphIcon(AppGlyphs.chevronForward),
              ],
            ),
      widget: _EditGlobalAddedRules(profileId),
    );
  }
}

class _EditGlobalAddedRules extends ConsumerStatefulWidget {
  final int profileId;

  const _EditGlobalAddedRules(this.profileId);

  @override
  ConsumerState<_EditGlobalAddedRules> createState() =>
      _EditGlobalAddedRulesState();
}

class _EditGlobalAddedRulesState extends ConsumerState<_EditGlobalAddedRules> {
  var _query = SearchQuery('');
  final _searchTexts = Expando<String>();

  int get profileId => widget.profileId;

  void _handleChange(bool status, int ruleId) {
    if (status) {
      ref.read(profileDisabledRuleIdsProvider(profileId).notifier).put(ruleId);
    } else {
      ref.read(profileDisabledRuleIdsProvider(profileId).notifier).del(ruleId);
    }
  }

  void _handleSearch(String query) {
    setState(() {
      _query = SearchQuery(query);
    });
  }

  void _handleToAddedRules() {
    showNestedSheet<void>(context, builder: (_) => const AddedRulesView());
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final disabledRuleIdsState = ref.watch(
      profileDisabledRuleIdsProvider(profileId),
    );
    final disabledRuleIds = (disabledRuleIdsState.value ?? const <int>[])
        .toSet();
    final rulesState = ref.watch(globalRulesProvider);
    final rules = (rulesState.value ?? [])
        .whereMatches(_query, (rule) => rule.searchFields, texts: _searchTexts)
        .toList();
    return Scaffold(
      title: appLocalizations.editGlobalRules,
      searchState: AppBarSearchState(onSearch: _handleSearch),
      body: NullStatusSwitcher(
        isLoading: rulesState.isLoading || disabledRuleIdsState.isLoading,
        isEmpty: rules.isEmpty,
        isSearching: _query.isNotEmpty,
        nullStatus: NullStatus(
          label: appLocalizations.nullTip(appLocalizations.rule),
          illustration: NullStatusIllustration.rules,
          action: TonalButton(
            size: TonalButtonSize.bar,
            label: appLocalizations.goToConfigureAddedRules,
            onPressed: _handleToAddedRules,
          ),
        ),
        child: ScrollConfiguration(
          behavior: const ShowBarScrollBehavior(),
          child: Builder(
            builder: (context) => CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(height: context.contentTopPadding),
                ),
                if (_query.isEmpty) ...[
                  SliverPadding(
                    padding: context.listInsets.page(),
                    sliver: SliverToBoxAdapter(
                      child: generateGroup([
                        ListItem.open(
                          title: Text(appLocalizations.goToConfigureAddedRules),
                          widget: const AddedRulesView(),
                        ),
                      ]),
                    ),
                  ),
                  const SliverToBoxAdapter(child: ListSectionGap()),
                ],
                SliverPadding(
                  padding: context.listInsets.page(),
                  sliver: SliverFixedExtentList.builder(
                    itemExtent: ruleItemHeight,
                    itemBuilder: (context, index) {
                      final rule = rules[index];
                      final position = ItemPosition.get(index, rules.length);
                      return ItemPositionProvider(
                        position: position,
                        child: RuleStatusItem(
                          status: !disabledRuleIds.contains(rule.id),
                          rule: rule,
                          onChange: (status) {
                            _handleChange(!status, rule.id);
                          },
                        ),
                      );
                    },
                    itemCount: rules.length,
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: 16 + context.bottomInset),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
