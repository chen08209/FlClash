import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/overwrite/rule.dart';
import 'package:fl_clash/models/clash_config.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/models/state.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/overwrite/custom/widgets.dart';
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

class _CustomRulesViewState extends ConsumerState<CustomRulesView>
    with UniqueKeyStateMixin {
  int get _profileId => widget.profileId;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  void _handleReorder(int oldIndex, int newIndex) {
    ref
        .read(profileCustomRulesProvider(_profileId).notifier)
        .order(oldIndex, newIndex);
  }

  void _handleSelected(int ruleId) {
    ref.read(itemsProvider(key).notifier).update((selectedRules) {
      final newSelectedRules = Set<int>.from(selectedRules)
        ..addOrRemove(ruleId);
      return newSelectedRules;
    });
  }

  void _handleSelectAll() {
    final ids =
        ref
            .read(profileCustomRulesProvider(_profileId))
            .value
            ?.map((item) => item.id)
            .toSet() ??
        {};
    ref.read(itemsProvider(key).notifier).update((selected) {
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
    final selectedRules = ref.read(itemsProvider(key));
    ref
        .read(profileCustomRulesProvider(_profileId).notifier)
        .delAll(selectedRules.cast<int>());
    ref.read(itemsProvider(key).notifier).value = {};
  }

  void _handleAddOrUpdate({Rule? rule}) {
    showSheet(
      context: context,
      props: const SheetProps(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        maxWidth: double.maxFinite,
      ),
      builder: (context) {
        return ProfileIdProvider(
          profileId: widget.profileId,
          child: ProviderScope(
            overrides: [
              ruleProvider.overrideWithBuild((_, _) => rule ?? Rule.init()),
            ],
            child: const _AddOrEditRuleNestedSheet(),
          ),
        );
      },
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

  Widget _buildItem({
    required Rule rule,
    required bool isEditing,
    required bool isSelected,
    required int index,
    required int total,
    required Function() onSelected,
    required Function(Rule rule) onEdit,
    required bool Function(Rule rule) checkInvalidHandler,
  }) {
    final position = ItemPosition.get(index, total);
    return ReorderableDelayedDragStartListener(
      key: ValueKey(rule),
      index: index,
      child: ItemPositionProvider(
        position: position,
        child: RuleItem(
          checkInvalidHandler: checkInvalidHandler,
          isEditing: isEditing,
          isSelected: isSelected,
          rule: rule,
          onSelected: () {
            _handleSelected(rule.id);
          },
          onEdit: (rule) {
            _handleAddOrUpdate(rule: rule);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    final appLocalizations = context.appLocalizations;
    final rules = ref.watch(profileCustomRulesProvider(_profileId)).value ?? [];
    final selectedRules = ref.watch(itemsProvider(key));
    final vm2 = ref.watch(
      customOverwriteDateProvider(
        widget.profileId,
      ).select((state) => VM2(state.ruleTargets, state.subRules)),
    );
    final ruleTargets = vm2.a;
    final subRules = vm2.b;
    return CommonScaffold(
      title: appLocalizations.rule,
      actions: [
        if (selectedRules.isNotEmpty) ...[
          CommonMinIconButtonTheme(
            child: IconButton.filledTonal(
              onPressed: _handleDelete,
              icon: const Icon(Icons.delete),
            ),
          ),
          const SizedBox(width: 2),
        ],
        CommonMinFilledButtonTheme(
          child: selectedRules.isNotEmpty
              ? FilledButton(
                  onPressed: _handleSelectAll,
                  child: Text(appLocalizations.selectAll),
                )
              : FilledButton.tonal(
                  onPressed: _handleAddOrUpdate,
                  child: Text(appLocalizations.add),
                ),
        ),
        const SizedBox(width: 8),
      ],
      body: rules.isEmpty
          ? NullStatus(label: appLocalizations.ruleEmpty)
          : CommonScrollBar(
              controller: _scrollController,
              child: ReorderableListView.builder(
                scrollController: _scrollController,
                buildDefaultDragHandles: false,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ).copyWith(bottom: 24),
                itemBuilder: (_, index) {
                  final rule = rules[index];
                  return _buildItem(
                    index: index,
                    checkInvalidHandler: (rule) {
                      return _handleCheckInvalid(rule, ruleTargets, subRules);
                    },
                    total: rules.length,
                    isEditing: selectedRules.isNotEmpty,
                    isSelected: selectedRules.contains(rule.id),
                    rule: rule,
                    onSelected: () {
                      _handleSelected(rule.id);
                    },
                    onEdit: (rule) {
                      _handleAddOrUpdate(rule: rule);
                    },
                  );
                },
                itemExtent: ruleItemHeight,
                itemCount: rules.length,
                proxyDecorator: (child, index, animation) {
                  final rule = rules[index];
                  return commonProxyDecorator(
                    _buildItem(
                      index: index,
                      checkInvalidHandler: (target) {
                        return _handleCheckInvalid(
                          target,
                          ruleTargets,
                          subRules,
                        );
                      },
                      total: rules.length,
                      isEditing: selectedRules.isNotEmpty,
                      isSelected: selectedRules.contains(rule.id),
                      rule: rule,
                      onSelected: () {
                        _handleSelected(rule.id);
                      },
                      onEdit: (rule) {
                        _handleAddOrUpdate(rule: rule);
                      },
                    ),
                    index,
                    animation,
                  );
                },
                onReorderItem: _handleReorder,
              ),
            ),
    );
  }
}

class _AddOrEditRuleNestedSheet extends ConsumerStatefulWidget {
  const _AddOrEditRuleNestedSheet();

  @override
  ConsumerState<_AddOrEditRuleNestedSheet> createState() =>
      _AddOrEditRuleNestedSheetState();
}

class _AddOrEditRuleNestedSheetState
    extends ConsumerState<_AddOrEditRuleNestedSheet> {
  final GlobalKey<NavigatorState> _nestedNavigatorKey = GlobalKey();
  late final Rule _originRule;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _originRule = ref.read(ruleProvider);
    });
  }

  Future<void> _handleClose() async {
    final state = _nestedNavigatorKey.currentState;
    if (state != null && state.canPop()) {
      final res = await globalState.showMessage(
        message: TextSpan(text: context.appLocalizations.confirmExitWindow),
      );
      if (res != true) {
        return;
      }
    }
    if (context.mounted) {
      _handleExit();
    }
  }

  Future<void> _handleExit() async {
    final rule = ref.read(ruleProvider);
    if (_originRule == rule) {
      Navigator.of(context).pop();
      return;
    }
    final res = await globalState.showMessage(
      message: TextSpan(text: context.appLocalizations.dataChangedSave),
    );
    if (!mounted) {
      return;
    }
    if (res != true) {
      Navigator.of(context).pop();
      return;
    }
    if (_handleSaveRule(context, ref)) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handlePop() async {
    final state = _nestedNavigatorKey.currentState;
    if (state != null && state.canPop()) {
      state.pop();
    } else {
      _handleExit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final nestedNavigator = Navigator(
      key: _nestedNavigatorKey,
      onGenerateInitialRoutes: (navigator, initialRoute) {
        return [
          PagedSheetRoute(
            builder: (context) {
              return const _AddOrEditRuleView();
            },
          ),
        ];
      },
    );
    final sheetProvider = SheetProvider.of(context);
    final fillColor = sheetProvider?.type == SheetType.bottomSheet
        ? context.colorScheme.surfaceContainerLow
        : context.colorScheme.surface;
    return CommonPopScope(
      onPop: (_) async {
        _handlePop();
        return false;
      },
      child: sheetProvider!.copyWith(
        nestedNavigatorPop: ([_]) {
          Navigator.of(context).pop();
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () async {
                  _handleClose();
                },
              ),
            ),
            SizedBox(
              width: sheetProvider.type == SheetType.sideSheet ? 400 : null,
              child: SheetViewport(
                child: PagedSheetRouteTheme(
                  data: const PagedSheetRouteThemeData(
                    transitionsBuilder: fadeAndSlideTransition,
                    transitionDuration: Duration(milliseconds: 300),
                  ),
                  child: PagedSheet(
                    decoration: MaterialSheetDecoration(
                      animationDuration: Duration.zero,
                      size: SheetSize.stretch,
                      color: fillColor,
                      borderRadius: sheetProvider.type == SheetType.bottomSheet
                          ? const BorderRadius.vertical(
                              top: Radius.circular(28),
                            )
                          : BorderRadius.zero,
                      clipBehavior: Clip.antiAlias,
                    ),
                    navigator: nestedNavigator,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
    return DecorationListItem(
      invalid: invalid ?? false,
      onPressed: onPressed,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 16,
        children: [
          title,
          if (trailing != null)
            Flexible(
              child: IconTheme(
                data: IconThemeData(
                  size: 16,
                  color: context.colorScheme.onSurface.opacity60,
                ),
                child: Container(
                  alignment: Alignment.centerRight,
                  height: globalState.measure.bodyLargeHeight + 24,
                  child: trailing,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleSelectedType() async {
    final res = await Navigator.of(context).push(
      PagedSheetRoute(builder: (context) => const _RuleTypeSelectedView()),
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
      PagedSheetRoute(builder: (context) => const _RuleProviderSelectedView()),
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
      PagedSheetRoute(builder: (context) => const _RuleTargetSelectedView()),
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
              if (invalid)
                CommonMinIconButtonTheme(
                  child: IconButton(
                    onPressed: () {
                      globalState.showMessage(
                        message: TextSpan(
                          text: appLocalizations.invalidPolicy(target!),
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
    final res = await Navigator.of(
      context,
    ).push(PagedSheetRoute(builder: (context) => const _SubRuleSelectedView()));
    if (res == null) {
      return;
    }
    ref
        .read(ruleProvider.notifier)
        .update((state) => state.copyWith(subRule: res));
  }

  Widget _buildSubRuleItem(int profileId, String? subRule) {
    final appLocalizations = context.appLocalizations;
    return Consumer(
      builder: (_, ref, _) {
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
      },
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
    final isBottomSheet =
        SheetProvider.of(context)?.type == SheetType.bottomSheet;
    final rule = ref.watch(ruleProvider);
    final height = isBottomSheet
        ? globalState.container.read(viewSizeProvider).height * 0.60
        : double.maxFinite;
    return AdaptiveSheetScaffold(
      actions: [IconButtonData(icon: Icons.check, onPressed: _handleSave)],
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
                    : _buildSubRuleItem(profileId, rule.subRule),
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

class _RuleTypeSelectedView extends ConsumerWidget {
  const _RuleTypeSelectedView();

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final isBottomSheet =
        SheetProvider.of(context)?.type == SheetType.bottomSheet;
    final height = isBottomSheet
        ? globalState.container.read(viewSizeProvider).height * 0.70
        : double.maxFinite;
    final currentRuleAction = ref.watch(
      ruleProvider.select((state) => state.ruleAction),
    );
    return AdaptiveSheetScaffold(
      sheetTransparentToolBar: true,
      body: SizedBox(
        height: height,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ).copyWith(bottom: 20, top: context.sheetTopPadding),
          itemCount: RuleAction.values.length,
          itemBuilder: (_, index) {
            final ruleAction = RuleAction.values[index];
            final position = ItemPosition.get(index, RuleAction.values.length);
            return ItemPositionProvider(
              position: position,
              child: DecorationListItem(
                onPressed: () {
                  Navigator.of(context).pop(ruleAction);
                },
                isSelected: ruleAction == currentRuleAction,
                subtitle: Text(ruleAction.getDesc(context)),
                title: Text(ruleAction.name),
                trailing: ruleAction == currentRuleAction
                    ? const Icon(Icons.check)
                    : null,
              ),
            );
          },
        ),
      ),
      title: appLocalizations.proxyType,
    );
  }
}

class _RuleTargetSelectedView extends ConsumerWidget {
  const _RuleTargetSelectedView();

  Widget _buildItem({
    required String title,
    String? subtitle,
    required ItemPosition position,
    bool isSelected = true,
    final VoidCallback? onPressed,
  }) {
    return ItemPositionProvider(
      position: position,
      child: DecorationListItem(
        onPressed: onPressed,
        subtitle: subtitle != null ? Text(subtitle) : null,
        title: TooltipText(
          text: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        isSelected: isSelected,
        trailing: isSelected ? const Icon(Icons.check) : null,
      ),
    );
  }

  void _handleSelected(BuildContext context, String target) {
    Navigator.of(context).pop(target);
  }

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final isBottomSheet =
        SheetProvider.of(context)?.type == SheetType.bottomSheet;
    final profileId = ProfileIdProvider.of(context)!.profileId;
    final height = isBottomSheet
        ? globalState.container.read(viewSizeProvider).height * 0.70
        : double.maxFinite;
    final vm2 = ref.watch(
      customOverwriteDateProvider(profileId).select((state) {
        return VM2(state.proxies, state.proxyGroups);
      }),
    );
    final proxies = vm2.a;
    final proxyGroups = vm2.b;
    final currentRuleTarget = ref.watch(
      ruleProvider.select((state) => state.ruleTarget),
    );
    return AdaptiveSheetScaffold(
      sheetTransparentToolBar: true,
      body: SizedBox(
        height: height,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(height: context.sheetTopPadding),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: InfoHeader(
                  info: Info(label: appLocalizations.basicStrategy),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.builder(
                itemBuilder: (_, index) {
                  final target = RuleTarget.values[index];
                  final position = ItemPosition.get(
                    index,
                    RuleTarget.values.length,
                  );
                  return _buildItem(
                    title: target.name,
                    position: position,
                    onPressed: () {
                      _handleSelected(context, target.name);
                    },
                    isSelected: currentRuleTarget == target.name,
                  );
                },
                itemCount: RuleTarget.values.length,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: InfoHeader(
                  info: Info(label: appLocalizations.ruleTarget),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.builder(
                itemBuilder: (_, index) {
                  final proxyGroup = proxyGroups[index];
                  final position = ItemPosition.get(index, proxyGroups.length);
                  return _buildItem(
                    title: proxyGroup.name,
                    subtitle: proxyGroup.type.name,
                    position: position,
                    onPressed: () {
                      _handleSelected(context, proxyGroup.name);
                    },
                    isSelected: currentRuleTarget == proxyGroup.name,
                  );
                },
                itemCount: proxyGroups.length,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: InfoHeader(info: Info(label: appLocalizations.proxies)),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.builder(
                itemBuilder: (_, index) {
                  final proxy = proxies[index];
                  final position = ItemPosition.get(index, proxies.length);
                  return _buildItem(
                    title: proxy.name,
                    subtitle: proxy.type,
                    position: position,
                    onPressed: () {
                      _handleSelected(context, proxy.name);
                    },
                    isSelected: currentRuleTarget == proxy.name,
                  );
                },
                itemCount: proxies.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
      title: appLocalizations.splitStrategy,
    );
  }
}

class _RuleProviderSelectedView extends ConsumerWidget {
  const _RuleProviderSelectedView();

  Widget _buildItem({
    required Widget title,
    final VoidCallback? onPressed,
    bool isSelected = false,
  }) {
    return DecorationListItem(
      onPressed: onPressed,
      isSelected: isSelected,
      trailing: isSelected ? const Icon(Icons.check) : null,
      title: title,
    );
  }

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final isBottomSheet =
        SheetProvider.of(context)?.type == SheetType.bottomSheet;
    final profileId = ProfileIdProvider.of(context)!.profileId;
    final height = isBottomSheet
        ? globalState.container.read(viewSizeProvider).height * 0.70
        : double.maxFinite;
    final ruleProviders = ref
        .watch(
          clashConfigProvider(
            profileId,
          ).select((state) => VM(state.value?.ruleProviders ?? [])),
        )
        .a;
    final currentRuleProvider = ref.watch(
      ruleProvider.select((state) => state.ruleProvider),
    );
    return AdaptiveSheetScaffold(
      sheetTransparentToolBar: true,
      body: SizedBox(
        height: height,
        child: ruleProviders.isEmpty
            ? NullStatus(label: appLocalizations.proxyProvidersEmpty)
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ).copyWith(bottom: 20, top: context.sheetTopPadding),
                itemCount: ruleProviders.length,
                itemBuilder: (_, index) {
                  final ruleProvider = ruleProviders[index];
                  final position = ItemPosition.get(
                    index,
                    ruleProviders.length,
                  );
                  return ItemPositionProvider(
                    position: position,
                    child: _buildItem(
                      onPressed: () {
                        Navigator.of(context).pop(ruleProvider);
                      },
                      title: Text(ruleProvider),
                      isSelected: currentRuleProvider == ruleProvider,
                    ),
                  );
                },
              ),
      ),
      title: appLocalizations.ruleSet,
    );
  }
}

class _SubRuleSelectedView extends ConsumerWidget {
  const _SubRuleSelectedView();

  Widget _buildItem({
    required Widget title,
    final VoidCallback? onPressed,
    bool isSelected = false,
  }) {
    return DecorationListItem(
      isSelected: isSelected,
      onPressed: onPressed,
      title: title,
      trailing: isSelected ? const Icon(Icons.check) : null,
    );
  }

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final isBottomSheet =
        SheetProvider.of(context)?.type == SheetType.bottomSheet;
    final profileId = ProfileIdProvider.of(context)!.profileId;
    final height = isBottomSheet
        ? globalState.container.read(viewSizeProvider).height * 0.70
        : double.maxFinite;

    final subRules = ref
        .watch(
          clashConfigProvider(
            profileId,
          ).select((state) => VM(state.value?.subRules ?? [])),
        )
        .a;
    final currentSubRule = ref.watch(
      ruleProvider.select((state) => state.subRule),
    );
    return AdaptiveSheetScaffold(
      sheetTransparentToolBar: true,
      body: SizedBox(
        height: height,
        child: subRules.isEmpty
            ? NullStatus(label: appLocalizations.subRuleEmpty)
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ).copyWith(bottom: 20, top: context.sheetTopPadding),
                itemCount: subRules.length,
                itemBuilder: (_, index) {
                  final subRule = subRules[index];
                  final position = ItemPosition.get(index, subRules.length);
                  return ItemPositionProvider(
                    position: position,
                    child: _buildItem(
                      onPressed: () {
                        Navigator.of(context).pop(subRule);
                      },
                      title: Text(subRule),
                      isSelected: currentSubRule == subRule,
                    ),
                  );
                },
              ),
      ),
      title: appLocalizations.subRule,
    );
  }
}

bool _handleSaveRule(BuildContext context, WidgetRef ref) {
  final rule = ref.read(ruleProvider);
  final appLocalizations = context.appLocalizations;
  if (rule.realContent?.isNotEmpty != true) {
    globalState.showMessage(
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
    globalState.showMessage(
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
