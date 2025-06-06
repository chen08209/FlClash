import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OverrideProfileView extends StatefulWidget {
  final String profileId;

  const OverrideProfileView({
    super.key,
    required this.profileId,
  });

  @override
  State<OverrideProfileView> createState() => _OverrideProfileViewState();
}

class _OverrideProfileViewState extends State<OverrideProfileView> {
  final _controller = ScrollController();
  double _currentMaxWidth = 0;

  void _initState(WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 300), () async {
        final rawConfig = await globalState.getProfileConfig(widget.profileId);
        final snippet = ClashConfigSnippet.fromJson(rawConfig);
        final overrideData = ref.read(
          getProfileOverrideDataProvider(widget.profileId),
        );
        ref.read(profileOverrideStateProvider.notifier).updateState(
              (state) => state.copyWith(
                snippet: snippet,
                overrideData: overrideData,
              ),
            );
      });
    });
  }

  void _handleSave(WidgetRef ref, OverrideData overrideData) {
    ref.read(profilesProvider.notifier).updateProfile(
          widget.profileId,
          (state) => state.copyWith(
            overrideData: overrideData,
          ),
        );
    globalState.appController.setupClashConfigDebounce();
  }

  Future<void> _handleDelete(WidgetRef ref) async {
    final res = await globalState.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(
        text: appLocalizations.deleteMultipTip(
          appLocalizations.rule,
        ),
      ),
    );
    if (res != true) {
      return;
    }
    final selectedRules = ref.read(
      profileOverrideStateProvider.select(
        (state) => state.selectedRules,
      ),
    );
    ref.read(profileOverrideStateProvider.notifier).updateState(
      (state) {
        final overrideRule = state.overrideData!.rule.updateRules(
          (rules) => List.from(
            rules.where(
              (item) => !selectedRules.contains(item.id),
            ),
          ),
        );
        return state.copyWith.overrideData!(
          rule: overrideRule,
        );
      },
    );
    ref.read(profileOverrideStateProvider.notifier).updateState(
          (state) => state.copyWith(
            selectedRules: {},
          ),
        );
  }

  Widget _buildContent() {
    return Consumer(
      builder: (_, ref, child) {
        final isInit = ref.watch(
          profileOverrideStateProvider.select(
            (state) => state.snippet != null && state.overrideData != null,
          ),
        );
        if (!isInit) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return FadeBox(
          child: !isInit
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : child!,
        );
      },
      child: LayoutBuilder(
        builder: (_, constraints) {
          _currentMaxWidth = constraints.maxWidth - 104;
          return CommonScrollBar(
            controller: _controller,
            child: CustomScrollView(
              controller: _controller,
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 8,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Consumer(
                    builder: (_, ref, child) {
                      final scriptMode = ref.watch(scriptStateProvider
                          .select((state) => state.realId != null));
                      if (!scriptMode) {
                        return SizedBox();
                      }
                      return child!;
                    },
                    child: ListItem(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 0,
                      ),
                      title: Row(
                        spacing: 8,
                        children: [
                          Icon(Icons.info),
                          Text(
                            appLocalizations.overrideInvalidTip,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 8,
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: OverrideSwitch(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 8,
                      right: 8,
                    ),
                    child: RuleTitle(
                      profileId: widget.profileId,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                  sliver: RuleContent(
                    maxWidth: _currentMaxWidth,
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 16,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        profileOverrideStateProvider.overrideWith(() => ProfileOverrideState()),
      ],
      child: Consumer(
        builder: (_, ref, child) {
          _initState(ref);
          return child!;
        },
        child: Consumer(
          builder: (_, ref, ___) {
            final editCount = ref.watch(
              profileOverrideStateProvider.select(
                (state) => state.selectedRules.length,
              ),
            );
            final isEdit = editCount != 0;
            return CommonScaffold(
              title: appLocalizations.override,
              body: _buildContent(),
              actions: [
                if (!isEdit)
                  Consumer(
                    builder: (_, ref, child) {
                      final overrideData = ref.watch(
                          getProfileOverrideDataProvider(widget.profileId));
                      final newOverrideData = ref.watch(
                        profileOverrideStateProvider.select(
                          (state) => state.overrideData,
                        ),
                      );
                      final equals = overrideData == newOverrideData;
                      if (equals || newOverrideData == null) {
                        return SizedBox();
                      }
                      return CommonPopScope(
                        onPop: () async {
                          if (equals) {
                            return true;
                          }
                          final res = await globalState.showMessage(
                            message: TextSpan(
                              text: appLocalizations.saveChanges,
                            ),
                            confirmText: appLocalizations.save,
                          );
                          if (!context.mounted || res != true) {
                            return true;
                          }
                          _handleSave(ref, newOverrideData);
                          return true;
                        },
                        child: IconButton(
                          onPressed: () async {
                            final res = await globalState.showMessage(
                              message: TextSpan(
                                text: appLocalizations.saveTip,
                              ),
                              confirmText: appLocalizations.save,
                            );
                            if (res != true) {
                              return;
                            }
                            _handleSave(ref, newOverrideData);
                          },
                          icon: Icon(
                            Icons.save,
                          ),
                        ),
                      );
                    },
                  ),
                if (editCount == 1)
                  IconButton(
                    onPressed: () {
                      final rule = ref.read(profileOverrideStateProvider.select(
                        (state) {
                          return state.overrideData?.rule.rules.firstWhere(
                            (item) => item.id == state.selectedRules.first,
                          );
                        },
                      ));
                      if (rule == null) {
                        return;
                      }
                      globalState.appController.handleAddOrUpdate(
                        ref,
                        rule,
                      );
                    },
                    icon: Icon(
                      Icons.edit,
                    ),
                  ),
                if (editCount > 0)
                  IconButton(
                    onPressed: () {
                      _handleDelete(ref);
                    },
                    icon: Icon(
                      Icons.delete,
                    ),
                  )
              ],
              editState: AppBarEditState(
                editCount: editCount,
                onExit: () {
                  ref.read(profileOverrideStateProvider.notifier).updateState(
                        (state) => state.copyWith(
                          selectedRules: {},
                        ),
                      );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class OverrideSwitch extends ConsumerWidget {
  const OverrideSwitch({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enable = ref.watch(
      profileOverrideStateProvider.select(
        (state) => state.overrideData?.enable,
      ),
    );
    return CommonCard(
      onPressed: () {},
      type: CommonCardType.filled,
      radius: 18,
      child: ListItem.switchItem(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
        ),
        title: Text(appLocalizations.enableOverride),
        delegate: SwitchDelegate(
          value: enable ?? false,
          onChanged: (value) {
            ref.read(profileOverrideStateProvider.notifier).updateState(
                  (state) => state.copyWith.overrideData!(
                    enable: value,
                  ),
                );
          },
        ),
      ),
    );
  }
}

class RuleTitle extends ConsumerWidget {
  final String profileId;

  const RuleTitle({
    super.key,
    required this.profileId,
  });

  void _handleChangeType(WidgetRef ref, isOverrideRule) {
    ref.read(profileOverrideStateProvider.notifier).updateState(
          (state) => state.copyWith.overrideData!.rule(
            type: isOverrideRule
                ? OverrideRuleType.added
                : OverrideRuleType.override,
          ),
        );
  }

  @override
  Widget build(BuildContext context, ref) {
    final vm3 = ref.watch(
      profileOverrideStateProvider.select(
        (state) {
          final overrideRule = state.overrideData?.rule;
          return VM3(
            a: state.selectedRules.isNotEmpty,
            b: state.selectedRules.containsAll(
              overrideRule?.rules.map((item) => item.id).toSet() ?? {},
            ),
            c: overrideRule?.type == OverrideRuleType.override,
          );
        },
      ),
    );
    final isEdit = vm3.a;
    final isSelectAll = vm3.b;
    final isOverrideRule = vm3.c;
    return FilledButtonTheme(
      data: FilledButtonThemeData(
        style: ButtonStyle(
          padding: WidgetStatePropertyAll(EdgeInsets.symmetric(
            horizontal: 8,
          )),
          visualDensity: VisualDensity.compact,
        ),
      ),
      child: IconButtonTheme(
        data: IconButtonThemeData(
          style: ButtonStyle(
            padding: WidgetStatePropertyAll(EdgeInsets.zero),
            visualDensity: VisualDensity.compact,
            iconSize: WidgetStatePropertyAll(20),
          ),
        ),
        child: ListHeader(
          title: appLocalizations.rule,
          subTitle: isOverrideRule
              ? appLocalizations.overrideOriginRules
              : appLocalizations.addedOriginRules,
          space: 8,
          actions: [
            if (!isEdit)
              IconButton.filledTonal(
                icon: Icon(
                  isOverrideRule ? Icons.edit_document : Icons.note_add,
                ),
                onPressed: () {
                  _handleChangeType(
                    ref,
                    isOverrideRule,
                  );
                },
              ),
            !isEdit
                ? FilledButton.tonal(
                    onPressed: () {
                      globalState.appController.handleAddOrUpdate(ref);
                    },
                    child: Text(appLocalizations.add),
                  )
                : isSelectAll
                    ? FilledButton(
                        onPressed: () {
                          ref
                              .read(profileOverrideStateProvider.notifier)
                              .updateState(
                                (state) => state.copyWith(
                                  selectedRules: {},
                                ),
                              );
                        },
                        child: Text(appLocalizations.selectAll),
                      )
                    : FilledButton.tonal(
                        onPressed: () {
                          ref
                              .read(profileOverrideStateProvider.notifier)
                              .updateState(
                                (state) => state.copyWith(
                                  selectedRules: state.overrideData?.rule.rules
                                          .map((item) => item.id)
                                          .toSet() ??
                                      {},
                                ),
                              );
                        },
                        child: Text(appLocalizations.selectAll),
                      ),
          ],
        ),
      ),
    );
  }
}

class RuleContent extends ConsumerWidget {
  final double maxWidth;

  const RuleContent({
    super.key,
    required this.maxWidth,
  });

  Widget _buildItem({
    required Rule rule,
    required bool isSelected,
    required VoidCallback onTab,
    required BuildContext context,
  }) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: 4,
        ),
        child: CommonCard(
          padding: EdgeInsets.zero,
          radius: 18,
          type: CommonCardType.filled,
          isSelected: isSelected,
          // decoration: BoxDecoration(
          //   color: isSelected
          //       ? context.colorScheme.secondaryContainer.opacity80
          //       : context.colorScheme.surfaceContainer,
          //   borderRadius: BorderRadius.circular(18),
          // ),
          onPressed: () {
            onTab();
          },
          child: ListTile(
            minTileHeight: 0,
            minVerticalPadding: 0,
            titleTextStyle: context.textTheme.bodyMedium?.toJetBrainsMono,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            trailing: SizedBox(
              width: 24,
              height: 24,
              child: CommonCheckBox(
                value: isSelected,
                isCircle: true,
                onChanged: (_) {
                  onTab();
                },
              ),
            ),
            title: Text(rule.value),
          ),
        ),
      ),
    );
  }

  void _handleSelect(WidgetRef ref, String ruleId) {
    ref.read(profileOverrideStateProvider.notifier).updateState(
      (state) {
        final newSelectedRules = Set<String>.from(state.selectedRules);
        if (newSelectedRules.contains(ruleId)) {
          newSelectedRules.remove(ruleId);
        } else {
          newSelectedRules.add(ruleId);
        }
        return state.copyWith(
          selectedRules: newSelectedRules,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, ref) {
    final vm3 = ref.watch(
      profileOverrideStateProvider.select(
        (state) {
          final overrideRule = state.overrideData?.rule;
          return VM3(
            a: overrideRule?.rules ?? [],
            b: overrideRule?.type ?? OverrideRuleType.added,
            c: state.selectedRules,
          );
        },
      ),
    );
    final rules = vm3.a;
    final type = vm3.b;
    final selectedRules = vm3.c;
    if (rules.isEmpty) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 300,
          child: Center(
            child: type == OverrideRuleType.added
                ? Text(
                    appLocalizations.noData,
                  )
                : FilledButton(
                    onPressed: () {
                      final rules = ref.read(
                        profileOverrideStateProvider.select(
                          (state) => state.snippet?.rule ?? [],
                        ),
                      );
                      ref
                          .read(profileOverrideStateProvider.notifier)
                          .updateState(
                        (state) {
                          return state.copyWith.overrideData!.rule(
                            overrideRules: rules,
                          );
                        },
                      );
                    },
                    child: Text(appLocalizations.getOriginRules),
                  ),
          ),
        ),
      );
    }
    return CacheItemExtentSliverReorderableList(
      tag: CacheTag.rules,
      itemBuilder: (context, index) {
        final rule = rules[index];
        return ReorderableDelayedDragStartListener(
          key: ObjectKey(rule),
          index: index,
          child: _buildItem(
            rule: rule,
            isSelected: selectedRules.contains(rule.id),
            onTab: () {
              _handleSelect(ref, rule.id);
            },
            context: context,
          ),
        );
      },
      proxyDecorator: proxyDecorator,
      itemCount: rules.length,
      onReorder: (oldIndex, newIndex) {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        final newRules = List<Rule>.from(rules);
        final item = newRules.removeAt(oldIndex);
        newRules.insert(newIndex, item);
        ref.read(profileOverrideStateProvider.notifier).updateState(
              (state) => state.copyWith.overrideData!(
                rule: state.overrideData!.rule.updateRules((_) => newRules),
              ),
            );
      },
      keyBuilder: (int index) {
        return rules[index].value;
      },
      itemExtentBuilder: (index) {
        final rule = rules[index];
        return 40 +
            globalState.measure
                .computeTextSize(
                  Text(
                    rule.value,
                    style: context.textTheme.bodyMedium?.toJetBrainsMono,
                  ),
                  maxWidth: maxWidth,
                )
                .height;
      },
    );
  }
}

class AddRuleDialog extends StatefulWidget {
  final ClashConfigSnippet snippet;
  final Rule? rule;

  const AddRuleDialog({
    super.key,
    required this.snippet,
    this.rule,
  });

  @override
  State<AddRuleDialog> createState() => _AddRuleDialogState();
}

class _AddRuleDialogState extends State<AddRuleDialog> {
  late RuleAction _ruleAction;
  final _ruleTargetController = TextEditingController();
  final _contentController = TextEditingController();
  final _ruleProviderController = TextEditingController();
  final _subRuleController = TextEditingController();
  bool _noResolve = false;
  bool _src = false;
  List<DropdownMenuEntry> _targetItems = [];
  List<DropdownMenuEntry> _ruleProviderItems = [];
  List<DropdownMenuEntry> _subRuleItems = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _initState();
    super.initState();
  }

  void _initState() {
    _targetItems = [
      ...widget.snippet.proxyGroups.map(
        (item) => DropdownMenuEntry(
          value: item.name,
          label: item.name,
        ),
      ),
      ...RuleTarget.values.map(
        (item) => DropdownMenuEntry(
          value: item.name,
          label: item.name,
        ),
      ),
    ];
    _ruleProviderItems = [
      ...widget.snippet.ruleProvider.map(
        (item) => DropdownMenuEntry(
          value: item.name,
          label: item.name,
        ),
      ),
    ];
    _subRuleItems = [
      ...widget.snippet.subRules.map(
        (item) => DropdownMenuEntry(
          value: item.name,
          label: item.name,
        ),
      ),
    ];
    if (widget.rule != null) {
      final parsedRule = ParsedRule.parseString(widget.rule!.value);
      _ruleAction = parsedRule.ruleAction;
      _contentController.text = parsedRule.content ?? '';
      _ruleTargetController.text = parsedRule.ruleTarget ?? '';
      _ruleProviderController.text = parsedRule.ruleProvider ?? '';
      _subRuleController.text = parsedRule.subRule ?? '';
      _noResolve = parsedRule.noResolve;
      _src = parsedRule.src;
      return;
    }
    _ruleAction = RuleAction.values.first;
    if (_targetItems.isNotEmpty) {
      _ruleTargetController.text = _targetItems.first.value;
    }
    if (_ruleProviderItems.isNotEmpty) {
      _ruleProviderController.text = _ruleProviderItems.first.value;
    }
    if (_subRuleItems.isNotEmpty) {
      _subRuleController.text = _subRuleItems.first.value;
    }
  }

  @override
  void didUpdateWidget(AddRuleDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rule != widget.rule) {
      _initState();
    }
  }

  void _handleSubmit() {
    final res = _formKey.currentState?.validate();
    if (res == false) {
      return;
    }
    final parsedRule = ParsedRule(
      ruleAction: _ruleAction,
      content: _contentController.text,
      ruleProvider: _ruleProviderController.text,
      ruleTarget: _ruleTargetController.text,
      subRule: _subRuleController.text,
      noResolve: _noResolve,
      src: _src,
    );
    final rule = widget.rule != null
        ? widget.rule!.copyWith(value: parsedRule.value)
        : Rule.value(
            parsedRule.value,
          );
    Navigator.of(context).pop(rule);
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: appLocalizations.addRule,
      actions: [
        TextButton(
          onPressed: _handleSubmit,
          child: Text(
            appLocalizations.confirm,
          ),
        ),
      ],
      child: DropdownMenuTheme(
        data: DropdownMenuThemeData(
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(),
            labelStyle: context.textTheme.bodyLarge
                ?.copyWith(overflow: TextOverflow.ellipsis),
          ),
        ),
        child: Form(
          key: _formKey,
          child: LayoutBuilder(
            builder: (_, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FilledButton.tonal(
                    onPressed: () async {
                      _ruleAction =
                          await globalState.showCommonDialog<RuleAction>(
                                child: OptionsDialog<RuleAction>(
                                  title: appLocalizations.ruleName,
                                  options: RuleAction.values,
                                  textBuilder: (item) => item.value,
                                  value: _ruleAction,
                                ),
                              ) ??
                              _ruleAction;
                      setState(() {});
                    },
                    child: Text(_ruleAction.name),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  _ruleAction == RuleAction.RULE_SET
                      ? FormField(
                          validator: (_) {
                            if (_ruleProviderController.text.isEmpty) {
                              return appLocalizations
                                  .emptyTip(appLocalizations.ruleProviders);
                            }
                            return null;
                          },
                          builder: (field) {
                            return DropdownMenu(
                              expandedInsets: EdgeInsets.zero,
                              controller: _ruleProviderController,
                              label: Text(appLocalizations.ruleProviders),
                              menuHeight: 250,
                              errorText: field.errorText,
                              dropdownMenuEntries: _ruleProviderItems,
                            );
                          },
                        )
                      : TextFormField(
                          controller: _contentController,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: appLocalizations.content,
                          ),
                          validator: (_) {
                            if (_contentController.text.isEmpty) {
                              return appLocalizations
                                  .emptyTip(appLocalizations.content);
                            }
                            return null;
                          },
                        ),
                  SizedBox(
                    height: 24,
                  ),
                  _ruleAction == RuleAction.SUB_RULE
                      ? FormField(
                          validator: (_) {
                            if (_subRuleController.text.isEmpty) {
                              return appLocalizations
                                  .emptyTip(appLocalizations.subRule);
                            }
                            return null;
                          },
                          builder: (filed) {
                            return DropdownMenu(
                              width: 200,
                              enableFilter: false,
                              enableSearch: false,
                              controller: _subRuleController,
                              label: Text(appLocalizations.subRule),
                              menuHeight: 250,
                              dropdownMenuEntries: _subRuleItems,
                            );
                          },
                        )
                      : FormField<String>(
                          validator: (_) {
                            if (_ruleTargetController.text.isEmpty) {
                              return appLocalizations.emptyTip(
                                appLocalizations.ruleTarget,
                              );
                            }
                            return null;
                          },
                          builder: (filed) {
                            return DropdownMenu(
                              controller: _ruleTargetController,
                              label: Text(appLocalizations.ruleTarget),
                              width: 200,
                              menuHeight: 250,
                              enableFilter: false,
                              enableSearch: false,
                              dropdownMenuEntries: _targetItems,
                              errorText: filed.errorText,
                            );
                          },
                        ),
                  if (_ruleAction.hasParams) ...[
                    SizedBox(
                      height: 20,
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        CommonCard(
                          radius: 8,
                          isSelected: _src,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            child: Text(
                              appLocalizations.sourceIp,
                              style: context.textTheme.bodyMedium,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _src = !_src;
                            });
                          },
                        ),
                        CommonCard(
                          radius: 8,
                          isSelected: _noResolve,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            child: Text(
                              appLocalizations.noResolve,
                              style: context.textTheme.bodyMedium,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _noResolve = !_noResolve;
                            });
                          },
                        )
                      ],
                    ),
                  ],
                  SizedBox(
                    height: 20,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
