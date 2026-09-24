import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/overwrite/overwrite.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/clash_config.dart';
import 'package:fl_clash/models/state.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StandardContent extends ConsumerStatefulWidget {
  const StandardContent({super.key});

  @override
  ConsumerState createState() => _StandardContentState();
}

class _StandardContentState extends ConsumerState<StandardContent> {
  final _key = uniqueId;
  late int _profileId;

  Future<void> _handleAddOrUpdate([Rule? rule]) async {
    final res = await dialogs.showCommonDialog<Rule>(
      child: AddOrEditRuleDialog(rule: rule),
    );
    if (res == null) {
      return;
    }
    ref.read(profileAddedRulesProvider(_profileId).notifier).put(res);
  }

  void _handleQuickAdd() {
    showSheet<void>(
      context: context,
      props: const SheetProps(isScrollControlled: true),
      builder: (_) => RulePresetSheet(
        onAdd: ref.read(profileAddedRulesProvider(_profileId).notifier).putAll,
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
            .read(profileAddedRulesProvider(_profileId))
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
    );
    if (res != true) {
      return;
    }
    final selectedRules = ref.read(itemsProvider(_key));
    ref
        .read(profileAddedRulesProvider(_profileId).notifier)
        .delAll(selectedRules.cast<int>());
    ref.read(itemsProvider(_key).notifier).value = {};
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _profileId = ProfileIdProvider.of(context)!.profileId;
  }

  void _handleToEditGlobalAddedRules() {
    BaseNavigator.push(context, _EditGlobalAddedRules(_profileId));
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    _profileId = ProfileIdProvider.of(context)!.profileId;
    final addedRules =
        ref.watch(profileAddedRulesProvider(_profileId)).value ?? [];
    final selectedRules = ref.watch(itemsProvider(_key));
    return CommonPopScope(
      onPop: (_) {
        if (selectedRules.isNotEmpty) {
          ref.read(itemsProvider(_key).notifier).value = {};
          return false;
        }
        Navigator.of(context).pop();
        return false;
      },
      child: SliverMainAxisGroup(
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: Column(
              children: [
                InfoHeader(
                  info: Info(label: appLocalizations.addedRules),
                  actions: [
                    if (selectedRules.isNotEmpty) ...[
                      CommonMinIconButtonTheme(
                        child: ElasticButton(
                          child: IconButton.filledTonal(
                            tooltip: context.appLocalizations.delete,
                            onPressed: () {
                              _handleDelete();
                            },
                            icon: const GlyphIcon(AppGlyphs.delete, fill: 1),
                          ),
                        ),
                      ),
                    ],
                    if (selectedRules.isEmpty)
                      CommonMinIconButtonTheme(
                        child: ElasticButton(
                          child: IconButton.filledTonal(
                            tooltip: appLocalizations.quickAdd,
                            onPressed: _handleQuickAdd,
                            icon: const GlyphIcon(AppGlyphs.bolt, fill: 1),
                          ),
                        ),
                      ),
                    CommonMinFilledButtonTheme(
                      child: ElasticButton(
                        child: selectedRules.isNotEmpty
                            ? FilledButton(
                                onPressed: () {
                                  _handleSelectAll();
                                },
                                child: Text(appLocalizations.selectAll),
                              )
                            : FilledButton.tonal(
                                onPressed: () {
                                  _handleAddOrUpdate();
                                },
                                child: Text(appLocalizations.add),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverReorderableList(
            itemCount: addedRules.length,
            itemBuilder: (_, index) {
              final rule = addedRules[index];
              final position = ItemPosition.get(index, addedRules.length);
              return ReorderableDelayedDragStartListener(
                key: ObjectKey(rule),
                index: index,
                child: ItemPositionProvider(
                  position: position,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: RuleItem(
                      hasMatch: true,
                      isEditing: selectedRules.isNotEmpty,
                      isSelected: selectedRules.contains(rule.id),
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
            },
            itemExtent: ruleItemHeight,
            onReorderItem: ref
                .read(profileAddedRulesProvider(_profileId).notifier)
                .order,
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(child: _MatchTargetItem(_profileId)),
          SliverToBoxAdapter(
            child: MoreActionButton(
              label: appLocalizations.controlGlobalAddedRules,
              onPressed: _handleToEditGlobalAddedRules,
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchTargetItem extends ConsumerWidget {
  final int profileId;

  const _MatchTargetItem(this.profileId);

  Future<void> _handleSelect(BuildContext context, WidgetRef ref) async {
    final res = await showSheet<String>(
      context: context,
      props: const SheetProps(isScrollControlled: true),
      builder: (context) => Consumer(
        builder: (_, ref, _) {
          final appLocalizations = context.appLocalizations;
          final clashConfig = ref.watch(clashConfigProvider(profileId)).value;
          final groups = clashConfig?.proxyGroups ?? const [];
          final proxies = clashConfig?.proxies ?? const [];
          final groupTypes = {
            for (final item in groups) item.name: item.type.name,
          };
          final proxyTypes = {for (final item in proxies) item.name: item.type};
          return OverwriteSelectionSheet<String>(
            title: appLocalizations.matchTarget,
            sections: [
              const OverwriteSelectionSection(items: ['']),
              OverwriteSelectionSection(
                label: appLocalizations.basicStrategy,
                items: RuleTarget.baseTargetNames,
              ),
              OverwriteSelectionSection(
                label: appLocalizations.ruleTarget,
                items: groupTypes.keys.toList(),
                subtitleBuilder: (_, name) => groupTypes[name] ?? '',
              ),
              OverwriteSelectionSection(
                label: appLocalizations.proxies,
                items: proxyTypes.keys.toList(),
                subtitleBuilder: (_, name) => proxyTypes[name] ?? '',
              ),
            ],
            labelBuilder: (item) =>
                item.isEmpty ? appLocalizations.followProfile : item,
            selectedOf: (ref) => ref.watch(
              profileProvider(
                profileId,
              ).select((state) => state?.matchTarget ?? ''),
            ),
            onSelected: (item) => Navigator.of(context).pop(item),
          );
        },
      ),
    );
    if (res == null) {
      return;
    }
    ref.read(profilesProvider.notifier).updateProfile(profileId, (state) {
      return state.copyWith(matchTarget: res.isEmpty ? null : res);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final matchTarget = ref.watch(
      profileProvider(profileId).select((state) => state?.matchTarget),
    );
    final clashConfig = ref.watch(clashConfigProvider(profileId)).value;
    final invalid =
        matchTarget != null &&
        clashConfig != null &&
        !RuleTarget.baseTargets.contains(matchTarget) &&
        !clashConfig.proxyGroups.any((item) => item.name == matchTarget) &&
        !clashConfig.proxies.any((item) => item.name == matchTarget);
    return MoreActionButton(
      label: appLocalizations.matchTarget,
      trailing: Text(
        matchTarget ?? appLocalizations.followProfile,
        style: context.textTheme.bodyMedium?.toJetBrainsMono.copyWith(
          color: invalid
              ? context.colorScheme.error
              : context.colorScheme.tertiary,
        ),
      ),
      onPressed: () {
        _handleSelect(context, ref);
      },
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
    return CommonScaffold(
      title: appLocalizations.editGlobalRules,
      searchState: AppBarSearchState(onSearch: _handleSearch),
      body: NullStatusSwitcher(
        isLoading: rulesState.isLoading || disabledRuleIdsState.isLoading,
        isEmpty: rules.isEmpty,
        isSearching: _query.isNotEmpty,
        nullStatus: NullStatus(
          label: appLocalizations.nullTip(appLocalizations.rule),
          illustration: NullStatusIllustration.rules,
        ),
        child: ScrollConfiguration(
          behavior: const ShowBarScrollBehavior(),
          child: ListView.builder(
            padding: const EdgeInsets.all(
              16,
            ).copyWith(top: context.contentTopPadding),
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
      ),
    );
  }
}
