import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/overwrite/overwrite.dart';
import 'package:fl_clash/models/clash_config.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/models/state.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

class CustomRulesView extends ConsumerStatefulWidget {
  final int profileId;

  const CustomRulesView(this.profileId, {super.key});

  @override
  ConsumerState createState() => _CustomRulesViewState();
}

class _CustomRulesViewState extends ConsumerState<CustomRulesView> {
  int get _profileId => widget.profileId;

  void _handleReorder(int oldIndex, int newIndex) {
    ref
        .read(profileCustomRulesProvider(_profileId).notifier)
        .order(oldIndex, newIndex);
  }

  Future<bool> _handleDelete(Set<dynamic> selectedRules) async {
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(
        text: appLocalizations.deleteMultipTip(appLocalizations.rule),
      ),
    );
    if (res != true) {
      return false;
    }
    if (!mounted) {
      return false;
    }
    ref
        .read(profileCustomRulesProvider(_profileId).notifier)
        .delAll(selectedRules.cast<int>());
    return true;
  }

  void _handleAddOrUpdate({Rule? rule}) {
    showOverwriteNestedSheet<Rule>(
      context: context,
      profileId: widget.profileId,
      overrides: [
        ruleProvider.overrideWithBuild((_, _) => rule ?? Rule.init()),
      ],
      currentOf: (ref) => ref.read(ruleProvider),
      save: _handleSaveRule,
      formBuilder: (_) => const _AddOrEditRuleView(),
    );
  }

  bool _handleCheckInvalid(
    Rule rule,
    Set<String> ruleTargets,
    Set<String> subRules,
  ) {
    final ruleTarget = rule.realTarget;
    if (rule.ruleAction == RuleAction.SUB_RULE) {
      return !subRules.contains(ruleTarget);
    }
    return !ruleTargets.contains(ruleTarget);
  }

  @override
  Widget build(context) {
    final appLocalizations = context.appLocalizations;
    final ruleTargets = ref.watch(
      customOverwriteDateProvider(_profileId).select(
        (state) => RuleTargetsSelectorState(
          ruleTargets: state.ruleTargets,
          subRules: state.subRules,
        ),
      ),
    );
    return OverwriteEditorPage<Rule>(
      title: appLocalizations.rule,
      selectionEnabled: true,
      dragFromRow: true,
      idOf: (rule) => rule.id,
      itemsOf: (ref) {
        return ref.watch(profileCustomRulesProvider(_profileId)).value ?? [];
      },
      itemBuilder:
          (context, ref, rule, index, isEditing, isSelected, onToggleSelected) {
            return RuleItem(
              checkInvalidHandler: (target) {
                return _handleCheckInvalid(
                  target,
                  ruleTargets.ruleTargets,
                  ruleTargets.subRules,
                );
              },
              isEditing: isEditing,
              isSelected: isSelected,
              rule: rule,
              onSelected: onToggleSelected,
              onEdit: (rule) {
                _handleAddOrUpdate(rule: rule);
              },
            );
          },
      onReorder: _handleReorder,
      onAdd: () => _handleAddOrUpdate(),
      onDelete: _handleDelete,
      emptyLabel: appLocalizations.ruleEmpty,
      itemExtent: ruleItemHeight,
    );
  }
}

class _AddOrEditRuleView extends ConsumerStatefulWidget {
  const _AddOrEditRuleView();

  @override
  ConsumerState<_AddOrEditRuleView> createState() => _AddOrEditRuleViewState();
}

class _AddOrEditRuleViewState extends ConsumerState<_AddOrEditRuleView> {
  Widget _buildItem({
    required Widget title,
    Widget? trailing,
    bool? invalid,
    final VoidCallback? onPressed,
  }) {
    return OverwriteFormRow(
      invalid: invalid ?? false,
      onPressed: onPressed,
      title: title,
      trailing: trailing,
    );
  }

  Future<void> _handleSelectedType() async {
    final res = await Navigator.of(context).push(
      PagedSheetRoute(
        builder: (context) => OverwriteSelectionSheet<RuleAction>(
          title: context.appLocalizations.proxyType,
          sections: [
            OverwriteSelectionSection(
              items: RuleAction.values,
              subtitleBuilder: (context, item) => item.getDesc(context),
            ),
          ],
          labelBuilder: (item) => item.name,
          selectedOf: (ref) =>
              ref.watch(ruleProvider.select((state) => state.ruleAction)),
          onSelected: (item) => Navigator.of(context).pop(item),
        ),
      ),
    );
    if (res == null) {
      return;
    }
    ref
        .read(ruleProvider.notifier)
        .update((state) => state.copyWith(ruleAction: res));
  }

  Widget _buildTypeItem(RuleAction action) {
    return _buildItem(
      title: Text(context.appLocalizations.proxyType),
      onPressed: () {
        _handleSelectedType();
      },
      trailing: Row(
        spacing: 4,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            action.name,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const Icon(Icons.arrow_forward_ios),
        ],
      ),
    );
  }

  Widget _buildContentItem(String? content) {
    final appLocalizations = context.appLocalizations;
    return _buildItem(
      title: Text(appLocalizations.content),
      trailing: TextFormField(
        initialValue: content,
        keyboardType: TextInputType.name,
        inputFormatters: TextInputLimits.limit(TextInputLimits.rule),
        onChanged: (value) {
          ref
              .read(ruleProvider.notifier)
              .update((state) => state.copyWith(content: value));
        },
        textAlign: TextAlign.end,
        decoration: InputDecoration.collapsed(
          border: const NoInputBorder(),
          hintText: appLocalizations.inputRuleContent,
        ),
      ),
    );
  }

  Future<void> _handleSelectedRuleProvider() async {
    final res = await Navigator.of(context).push(
      PagedSheetRoute(
        builder: (context) => Consumer(
          builder: (_, ref, _) {
            final profileId = ProfileIdProvider.of(context)!.profileId;
            final ruleProviders = ref
                .watch(
                  clashConfigProvider(profileId).select(
                    (state) => SelectValue(state.value?.ruleProviders ?? []),
                  ),
                )
                .value;
            return OverwriteSelectionSheet<String>(
              title: context.appLocalizations.ruleSet,
              sections: [OverwriteSelectionSection(items: ruleProviders)],
              labelBuilder: (item) => item,
              selectedOf: (ref) =>
                  ref.watch(ruleProvider.select((state) => state.ruleProvider)),
              onSelected: (item) => Navigator.of(context).pop(item),
              emptyLabel: context.appLocalizations.proxyProvidersEmpty,
            );
          },
        ),
      ),
    );
    if (res == null) {
      return;
    }
    ref
        .read(ruleProvider.notifier)
        .update((state) => state.copyWith(ruleProvider: res));
  }

  Widget _buildRuleProviderItem(String? ruleProvider) {
    final appLocalizations = context.appLocalizations;
    return _buildItem(
      title: Text(appLocalizations.ruleSet),
      onPressed: _handleSelectedRuleProvider,
      trailing: Row(
        spacing: 4,
        mainAxisSize: MainAxisSize.min,
        children: [
          TooltipText(
            text: Text(
              ruleProvider ?? appLocalizations.selectRuleSet,
              maxLines: 1,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const Icon(Icons.arrow_forward_ios),
        ],
      ),
    );
  }

  Future<void> _handleSelectedTarget() async {
    final res = await Navigator.of(context).push(
      PagedSheetRoute(
        builder: (context) => Consumer(
          builder: (_, ref, _) {
            final profileId = ProfileIdProvider.of(context)!.profileId;
            final proxiesAndGroups = ref.watch(
              customOverwriteDateProvider(profileId).select((state) {
                return ProxiesAndGroupsSelectorState(
                  proxies: state.proxies,
                  proxyGroups: state.proxyGroups,
                );
              }),
            );
            final groupTypes = {
              for (final item in proxiesAndGroups.proxyGroups)
                item.name: item.type.name,
            };
            final proxyTypes = {
              for (final item in proxiesAndGroups.proxies) item.name: item.type,
            };
            return OverwriteSelectionSheet<String>(
              title: context.appLocalizations.splitStrategy,
              sections: [
                OverwriteSelectionSection(
                  label: context.appLocalizations.basicStrategy,
                  items: RuleTarget.values.map((item) => item.name).toList(),
                ),
                OverwriteSelectionSection(
                  label: context.appLocalizations.ruleTarget,
                  items: groupTypes.keys.toList(),
                  subtitleBuilder: (context, name) => groupTypes[name] ?? '',
                ),
                OverwriteSelectionSection(
                  label: context.appLocalizations.proxies,
                  items: proxyTypes.keys.toList(),
                  subtitleBuilder: (context, name) => proxyTypes[name] ?? '',
                ),
              ],
              labelBuilder: (item) => item,
              selectedOf: (ref) =>
                  ref.watch(ruleProvider.select((state) => state.ruleTarget)),
              onSelected: (item) => Navigator.of(context).pop(item),
            );
          },
        ),
      ),
    );
    if (res == null) {
      return;
    }
    ref
        .read(ruleProvider.notifier)
        .update((state) => state.copyWith(ruleTarget: res));
  }

  Widget _buildTargetItem(int profileId, String? target) {
    final appLocalizations = context.appLocalizations;
    return Consumer(
      builder: (_, ref, _) {
        final invalid = !ref.watch(
          customOverwriteTargetIsValidProvider(profileId, target),
        );
        final foregroundColor = invalid
            ? context.colorScheme.error
            : context.colorScheme.onSurfaceVariant;
        return _buildItem(
          invalid: invalid,
          title: Text(appLocalizations.splitStrategy),
          onPressed: _handleSelectedTarget,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (invalid && target != null)
                CommonMinIconButtonTheme(
                  child: IconButton(
                    tooltip: appLocalizations.tip,
                    onPressed: () {
                      dialogs.showMessage(
                        message: TextSpan(
                          text: appLocalizations.invalidPolicy(target),
                        ),
                      );
                    },
                    icon: Icon(Icons.info, size: 16.ap, color: foregroundColor),
                  ),
                ),
              Flexible(
                flex: 1,
                child: TooltipText(
                  text: Text(
                    target ?? appLocalizations.selectSplitStrategy,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: foregroundColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios, color: foregroundColor),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSelectedSubRule() async {
    final res = await Navigator.of(context).push(
      PagedSheetRoute(
        builder: (context) => Consumer(
          builder: (_, ref, _) {
            final profileId = ProfileIdProvider.of(context)!.profileId;
            final subRules = ref
                .watch(
                  clashConfigProvider(
                    profileId,
                  ).select((state) => SelectValue(state.value?.subRules ?? [])),
                )
                .value;
            return OverwriteSelectionSheet<String>(
              title: context.appLocalizations.subRule,
              sections: [OverwriteSelectionSection(items: subRules)],
              labelBuilder: (item) => item,
              selectedOf: (ref) =>
                  ref.watch(ruleProvider.select((state) => state.subRule)),
              onSelected: (item) => Navigator.of(context).pop(item),
              emptyLabel: context.appLocalizations.subRuleEmpty,
            );
          },
        ),
      ),
    );
    if (res == null) {
      return;
    }
    ref
        .read(ruleProvider.notifier)
        .update((state) => state.copyWith(subRule: res));
  }

  Widget _buildSubRuleItem(String? subRule) {
    final appLocalizations = context.appLocalizations;
    return _buildItem(
      title: Text(appLocalizations.subRule),
      onPressed: _handleSelectedSubRule,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Flexible(
            flex: 1,
            child: TooltipText(
              text: Text(
                subRule ?? appLocalizations.selectSubRule,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const Icon(Icons.arrow_forward_ios),
        ],
      ),
    );
  }

  Widget _buildNoResolveItem(bool? noResolve) {
    final appLocalizations = context.appLocalizations;
    return _buildItem(
      title: Text(appLocalizations.noResolveHostname),
      trailing: Switch(value: noResolve ?? false, onChanged: (_) {}),
    );
  }

  Widget _buildSrcItem(bool? src) {
    final appLocalizations = context.appLocalizations;
    return _buildItem(
      title: Text(appLocalizations.matchSourceIp),
      trailing: Switch(value: src ?? false, onChanged: (_) {}),
    );
  }

  Future<void> _handleSave() async {
    if (_handleSaveRule(context, ref)) {
      context.safeNestedPop();
    }
  }

  void _handleDelete() {}

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final profileId = ProfileIdProvider.of(context)!.profileId;
    final rule = ref.watch(ruleProvider);
    final height = ref.sheetHeight(context, 0.60);
    return AdaptiveSheetScaffold(
      actions: [
        IconButtonData(
          icon: Icons.check,
          onPressed: _handleSave,
          tooltip: context.appLocalizations.save,
        ),
      ],
      sheetTransparentToolBar: true,
      body: Container(
        constraints: BoxConstraints(maxHeight: height),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ).copyWith(bottom: 20, top: context.sheetTopPadding),
          children: [
            generateSectionV3(
              title: appLocalizations.basicInfo,
              items: [
                _buildTypeItem(rule.ruleAction),
                if (rule.ruleAction != RuleAction.MATCH)
                  rule.ruleAction == RuleAction.RULE_SET
                      ? _buildRuleProviderItem(rule.ruleProvider)
                      : _buildContentItem(rule.content),
                rule.ruleAction != RuleAction.SUB_RULE
                    ? _buildTargetItem(profileId, rule.ruleTarget)
                    : _buildSubRuleItem(rule.subRule),
              ],
            ),
            if (rule.ruleAction.hasParams)
              generateSectionV3(
                title: appLocalizations.additionalParameters,
                items: [
                  _buildNoResolveItem(rule.noResolve),
                  _buildSrcItem(rule.src),
                ],
              ),
            generateSectionV3(
              title: appLocalizations.action,
              items: [
                if (rule.id != -1)
                  _buildItem(
                    title: Text(
                      appLocalizations.delete,
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: context.colorScheme.error,
                      ),
                    ),
                    onPressed: () {
                      _handleDelete();
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
      title: rule.id == -1
          ? appLocalizations.addRule
          : appLocalizations.editRule,
    );
  }
}

bool _handleSaveRule(BuildContext context, WidgetRef ref) {
  final rule = ref.read(ruleProvider);
  final appLocalizations = context.appLocalizations;
  if (rule.realContent?.isNotEmpty != true) {
    dialogs.showMessage(
      cancelable: false,
      message: TextSpan(
        text: rule.ruleAction == RuleAction.RULE_SET
            ? appLocalizations.proxyProvidersNotEmpty
            : appLocalizations.contentNotEmpty,
      ),
    );
    return false;
  }
  if (rule.realTarget?.isNotEmpty != true) {
    dialogs.showMessage(
      cancelable: false,
      message: TextSpan(
        text: rule.ruleAction == RuleAction.SUB_RULE
            ? appLocalizations.subRuleNotEmpty
            : appLocalizations.splitStrategyNotEmpty,
      ),
    );
    return false;
  }
  final profileId = ProfileIdProvider.of(context)!.profileId;
  Rule addedRule = rule;
  if (rule.id == -1) {
    addedRule = rule.copyWith(id: snowflake.id);
  }
  ref.read(profileCustomRulesProvider(profileId).notifier).put(addedRule);
  return true;
}
