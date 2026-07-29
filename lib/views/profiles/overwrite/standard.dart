import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/overwrite/rule.dart';
import 'package:fl_clash/models/clash_config.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StandardContent extends ConsumerStatefulWidget {
  const StandardContent({super.key});

  @override
  ConsumerState createState() => _StandardContentState();
}

class _StandardContentState extends ConsumerState<StandardContent> {
  final _key = utils.id;
  late int _profileId;

  Future<void> _handleAddOrUpdate([Rule? rule]) async {
    final res = await globalState.showCommonDialog<Rule>(
      child: AddOrEditRuleDialog(rule: rule),
    );
    if (res == null) {
      return;
    }
    ref.read(profileAddedRulesProvider(_profileId).notifier).put(res);
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
    final res = await globalState.showMessage(
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
                        child: IconButton.filledTonal(
                          onPressed: () {
                            _handleDelete();
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    CommonMinFilledButtonTheme(
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
                  ],
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          Consumer(
            builder: (_, ref, _) {
              return SliverReorderableList(
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
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
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

class _EditGlobalAddedRules extends ConsumerWidget {
  final int profileId;

  const _EditGlobalAddedRules(this.profileId);

  void _handleChange(WidgetRef ref, int profileId, bool status, int ruleId) {
    if (status) {
      ref.read(profileDisabledRuleIdsProvider(profileId).notifier).put(ruleId);
    } else {
      ref.read(profileDisabledRuleIdsProvider(profileId).notifier).del(ruleId);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final disabledRuleIds =
        ref.watch(profileDisabledRuleIdsProvider(profileId)).value ?? [];
    final rules = ref.watch(globalRulesProvider).value ?? [];
    return BaseScaffold(
      title: appLocalizations.editGlobalRules,
      body: rules.isEmpty
          ? NullStatus(
              label: appLocalizations.nullTip(appLocalizations.rule),
              illustration: const RuleEmptyIllustration(),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
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
                      _handleChange(ref, profileId, !status, rule.id);
                    },
                  ),
                );
              },
              itemCount: rules.length,
            ),
    );
  }
}
