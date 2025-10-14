// ignore_for_file: deprecated_member_use

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/features.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/scripts.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OverwriteView extends ConsumerStatefulWidget {
  final String profileId;

  const OverwriteView({super.key, required this.profileId});

  @override
  ConsumerState<OverwriteView> createState() => _OverwriteViewState();
}

class _OverwriteViewState extends ConsumerState<OverwriteView> {
  late final Overwrite _originOverwriteData;

  @override
  void initState() {
    super.initState();
    _originOverwriteData =
        ref.read(profileOverwriteProvider(widget.profileId)) ?? Overwrite();
  }

  Future<void> _handleReset() async {
    final res = await globalState.showMessage(
      message: TextSpan(text: appLocalizations.resetPageChangesTip),
    );
    if (res != true) {
      return;
    }
    ref.read(profilesProvider.notifier).updateProfile(widget.profileId, (
      state,
    ) {
      return state.copyWith(overwrite: _originOverwriteData);
    });
  }

  @override
  Widget build(BuildContext context) {
    final needReset = ref.watch(
      profileOverwriteProvider(
        widget.profileId,
      ).select((state) => state != _originOverwriteData),
    );
    return CommonScaffold(
      title: appLocalizations.override,
      actions: [
        if (needReset)
          CommonMinFilledButtonTheme(
            child: FilledButton(
              onPressed: _handleReset,
              child: Text(appLocalizations.reset),
            ),
          ),
      ],
      body: CustomScrollView(
        slivers: [_Title(widget.profileId), _Content(widget.profileId)],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      globalState.appController.checkNeedSetup();
    });
  }
}

class _Title extends ConsumerWidget {
  final String profileId;

  const _Title(this.profileId);

  String _getTitle(OverwriteType type) {
    return switch (type) {
      OverwriteType.standard => appLocalizations.standard,
      OverwriteType.script => appLocalizations.script,
    };
  }

  IconData _getIcon(OverwriteType type) {
    return switch (type) {
      OverwriteType.standard => Icons.stars,
      OverwriteType.script => Icons.rocket,
    };
  }

  String _getDesc(OverwriteType type) {
    return switch (type) {
      OverwriteType.standard => appLocalizations.standardModeDesc,
      OverwriteType.script => appLocalizations.scriptModeDesc,
    };
  }

  void _handleChange(WidgetRef ref, OverwriteType type) {
    ref.read(profilesProvider.notifier).updateProfile(profileId, (state) {
      return state.copyWith.overwrite(type: type);
    });
  }

  @override
  Widget build(context, ref) {
    final overwriteType = ref.watch(
      profileOverwriteProvider(
        profileId,
      ).select((state) => state?.type ?? OverwriteType.standard),
    );
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoHeader(info: Info(label: appLocalizations.overrideMode)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 16,
              children: [
                for (final type in OverwriteType.values)
                  CommonCard(
                    isSelected: overwriteType == type,
                    onPressed: () {
                      _handleChange(ref, type);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(_getIcon(type)),
                          const SizedBox(width: 8),
                          Flexible(child: Text(_getTitle(type))),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _getDesc(overwriteType),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant.opacity80,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Content extends ConsumerWidget {
  final String profileId;

  const _Content(this.profileId);

  @override
  Widget build(BuildContext context, ref) {
    final type = ref.watch(
      profileOverwriteProvider(
        profileId,
      ).select((state) => state?.type ?? OverwriteType.standard),
    );
    return switch (type) {
      OverwriteType.standard => _StandardContent(profileId),
      OverwriteType.script => _ScriptContent(profileId),
    };
  }
}

class _StandardContent extends ConsumerStatefulWidget {
  final String profileId;

  const _StandardContent(this.profileId);

  @override
  ConsumerState createState() => __StandardContentState();
}

class __StandardContentState extends ConsumerState<_StandardContent> {
  final _key = utils.id;

  Future<void> _handleAddOrUpdate([Rule? rule]) async {
    final res = await globalState.showCommonDialog<Rule>(
      child: AddOrEditRuleDialog(rule: rule),
    );
    if (res == null) {
      return;
    }
    ref.read(profilesProvider.notifier).updateProfile(widget.profileId, (
      state,
    ) {
      final newAddedRules = state.overwrite.standardOverwrite.addedRules
          .updateWith(res);
      return state.copyWith.overwrite.standardOverwrite(
        addedRules: newAddedRules,
      );
    });
  }

  void _handleSelected(String ruleId) {
    ref.read(selectedItemsProvider(_key).notifier).update((selectedRules) {
      final newSelectedRules = Set<String>.from(selectedRules)
        ..addOrRemove(ruleId);
      return newSelectedRules;
    });
  }

  void _handleSelectAll() {
    final ids = ref
        .read(
          profileOverwriteProvider(
            widget.profileId,
          ).select((state) => state?.standardOverwrite.addedRules ?? []),
        )
        .map((item) => item.id)
        .toSet();
    ref.read(selectedItemsProvider(_key).notifier).update((selected) {
      return selected.containsAll(ids) ? {} : ids;
    });
  }

  Future<void> _handleDelete() async {
    final res = await globalState.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(
        text: appLocalizations.deleteMultipTip(appLocalizations.rule),
      ),
    );
    if (res != true) {
      return;
    }
    final selectedRules = ref.read(selectedItemsProvider(_key));
    ref.read(profilesProvider.notifier).updateProfile(widget.profileId, (
      state,
    ) {
      final newAddedRules = state.overwrite.standardOverwrite.addedRules
          .where((item) => !selectedRules.contains(item.id))
          .toList();
      return state.copyWith.overwrite.standardOverwrite(
        addedRules: newAddedRules,
      );
    });
    ref.read(selectedItemsProvider(_key).notifier).value = {};
  }

  @override
  Widget build(BuildContext context) {
    final standardOverwrite = ref.watch(
      profileOverwriteProvider(
        widget.profileId,
      ).select((state) => state?.standardOverwrite),
    );
    final selectedRules = ref.watch(selectedItemsProvider(_key));
    final addedRules = standardOverwrite?.addedRules ?? [];
    return CommonPopScope(
      onPop: (_) {
        if (selectedRules.isNotEmpty) {
          ref.read(selectedItemsProvider(_key).notifier).value = {};
          return false;
        }
        Navigator.of(context).pop();
        return false;
      },
      child: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: 24)),
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
                          icon: Icon(Icons.delete),
                        ),
                      ),
                      SizedBox(width: 8),
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
          SliverToBoxAdapter(child: SizedBox(height: 8)),
          Consumer(
            builder: (_, ref, _) {
              return SliverReorderableList(
                itemCount: addedRules.length,
                itemBuilder: (_, index) {
                  final rule = addedRules[index];
                  return ReorderableDelayedDragStartListener(
                    key: ObjectKey(rule),
                    index: index,
                    child: RuleItem(
                      isEditing: selectedRules.isNotEmpty,
                      isSelected: selectedRules.contains(rule.id),
                      rule: rule,
                      onSelected: (id) {
                        _handleSelected(id);
                      },
                      onEdit: (rule) {
                        _handleAddOrUpdate(rule);
                      },
                    ),
                  );
                },
                onReorder: (int oldIndex, int newIndex) {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  ref.read(profilesProvider.notifier).updateProfile(
                    widget.profileId,
                    (state) {
                      final newAddRules = List<Rule>.from(
                        state.overwrite.standardOverwrite.addedRules,
                      );
                      final item = newAddRules.removeAt(oldIndex);
                      newAddRules.insert(newIndex, item);
                      return state.copyWith.overwrite.standardOverwrite(
                        addedRules: newAddRules,
                      );
                    },
                  );
                },
              );
            },
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: CommonCard(
                padding: EdgeInsets.zero,
                radius: 18,
                child: ListTile(
                  minTileHeight: 0,
                  minVerticalPadding: 0,
                  titleTextStyle: context.textTheme.bodyMedium?.toJetBrainsMono,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          appLocalizations.controlGlobalAddedRules,
                          style: context.textTheme.bodyLarge,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
                onPressed: () {
                  BaseNavigator.push(
                    context,
                    _EditGlobalAddedRules(profileId: widget.profileId),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScriptContent extends ConsumerWidget {
  final String profileId;

  const _ScriptContent(this.profileId);

  void _handleChange(WidgetRef ref, String scriptId) {
    ref.read(profilesProvider.notifier).updateProfile(profileId, (state) {
      String? newScriptId = scriptId;
      if (newScriptId == state.overwrite.scriptOverwrite.scriptId) {
        newScriptId = null;
      }
      return state.copyWith.overwrite.scriptOverwrite(scriptId: newScriptId);
    });
  }

  @override
  Widget build(BuildContext context, ref) {
    final scriptId = ref.watch(
      profileOverwriteProvider(
        profileId,
      ).select((state) => state?.scriptOverwrite.scriptId),
    );
    final scripts = ref.watch(scriptsProvider);
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(
          child: Column(
            children: [
              InfoHeader(info: Info(label: appLocalizations.overrideScript)),
            ],
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 8)),
        Consumer(
          builder: (_, ref, _) {
            return SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.builder(
                itemCount: scripts.length,
                itemBuilder: (_, index) {
                  final script = scripts[index];
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: CommonCard(
                      padding: EdgeInsets.zero,
                      type: CommonCardType.filled,
                      radius: 18,
                      child: ListTile(
                        minLeadingWidth: 0,
                        minTileHeight: 0,
                        minVerticalPadding: 16,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                        ),
                        title: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Radio(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                toggleable: true,
                                value: script.id,
                                groupValue: scriptId,
                                onChanged: (_) {
                                  _handleChange(ref, script.id);
                                },
                              ),
                            ),
                            SizedBox(width: 8),
                            Flexible(child: Text(script.label)),
                          ],
                        ),
                        onTap: () {
                          _handleChange(ref, script.id);
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: CommonCard(
              padding: EdgeInsets.zero,
              radius: 18,
              child: ListTile(
                minTileHeight: 0,
                minVerticalPadding: 0,
                titleTextStyle: context.textTheme.bodyMedium?.toJetBrainsMono,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        appLocalizations.goToConfigureScript,
                        style: context.textTheme.bodyLarge,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
              onPressed: () {
                BaseNavigator.push(context, const ScriptsView());
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _EditGlobalAddedRules extends ConsumerWidget {
  final String profileId;

  const _EditGlobalAddedRules({required this.profileId});

  void _handleChange(WidgetRef ref, String ruleId) {
    ref.read(profilesProvider.notifier).updateProfile(profileId, (state) {
      final newDisabledRuleIds = Set<String>.from(
        state.overwrite.standardOverwrite.disabledRuleIds,
      )..addOrRemove(ruleId);
      return state.copyWith.overwrite.standardOverwrite(
        disabledRuleIds: newDisabledRuleIds.toList(),
      );
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disabledRuleIds = ref.watch(
      profileOverwriteProvider(
        profileId,
      ).select((state) => state?.standardOverwrite.disabledRuleIds ?? []),
    );
    final rules = ref.watch(rulesProvider);
    return BaseScaffold(
      title: appLocalizations.editGlobalRules,
      body: rules.isEmpty
          ? NullStatus(
              label: appLocalizations.nullTip(appLocalizations.rule),
              illustration: RuleEmptyIllustration(),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final rule = rules[index];
                return RuleStatusItem(
                  status: !disabledRuleIds.contains(rule.id),
                  rule: rule,
                  onChange: (_) {
                    _handleChange(ref, rule.id);
                  },
                );
              },
              itemCount: rules.length,
            ),
    );
  }
}
