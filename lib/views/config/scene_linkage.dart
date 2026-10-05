import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'scene_rule_edit.dart';

class SceneLinkageView extends ConsumerStatefulWidget {
  const SceneLinkageView({super.key});

  @override
  ConsumerState<SceneLinkageView> createState() => _SceneLinkageViewState();
}

class _SceneLinkageViewState extends ConsumerState<SceneLinkageView> {
  bool _hasPermission = true;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    if (app == null) return;
    final granted = await app!.hasUsageStatsPermission();
    if (mounted) {
      setState(() {
        _hasPermission = granted;
      });
    }
  }

  void _handleAddRule() {
    showSheet(
      context: context,
      props: const SheetProps(isScrollControlled: true),
      builder: (_) => const SceneRuleEditView(),
    );
  }

  void _handleEditRule(SceneRule rule) {
    showSheet(
      context: context,
      props: const SheetProps(isScrollControlled: true),
      builder: (_) => SceneRuleEditView(rule: rule),
    );
  }

  void _handleDeleteRule(String id) {
    final props = ref.read(sceneLinkageSettingProvider);
    final rules = List<SceneRule>.from(props.rules)..removeWhere((r) => r.id == id);
    ref
        .read(sceneLinkageSettingProvider.notifier)
        .update((state) => state.copyWith(rules: rules));
  }

  void _handleReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final props = ref.read(sceneLinkageSettingProvider);
    final rules = List<SceneRule>.from(props.rules);
    final item = rules.removeAt(oldIndex);
    rules.insert(newIndex, item);
    ref
        .read(sceneLinkageSettingProvider.notifier)
        .update((state) => state.copyWith(rules: rules));
  }

  Widget _buildPermissionBanner() {
    if (_hasPermission) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: MaterialBanner(
        leading: GlyphIcon(
          AppGlyphs.lockOpen,
          color: context.colorScheme.primary,
        ),
        content: const Text(
          '需使用情况访问权限：请开启“使用情况访问权限”以允许自动检测前台运行的应用。',
        ),
        actions: [
          CommonMinFilledButtonTheme(
            child: ElasticButton(
              child: FilledButton.tonal(
                onPressed: () async {
                  await app?.openUsageStatsSettings();
                  await _checkPermission();
                },
                child: const Text('去授权'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final props = ref.watch(sceneLinkageSettingProvider);
    final profiles = ref.watch(profilesProvider);

    return BaseScaffold(
      title: '应用场景联动',
      actions: [
        IconButton(
          tooltip: '新建规则',
          icon: const GlyphIcon(AppGlyphs.add),
          onPressed: _handleAddRule,
        ),
      ],
      body: ListView(
        padding: EdgeInsets.only(top: context.contentTopPadding, bottom: 32),
        children: [
          _buildPermissionBanner(),
          generateSectionV3(
            title: '功能总控',
            items: [
              ListItem.switchItem(
                leading: const GlyphIcon(AppGlyphs.sparkle),
                title: const Text('应用场景联动'),
                subtitle: const Text('前台进入目标应用时自动切换配置与节点'),
                delegate: SwitchDelegate(
                  value: props.enable,
                  onChanged: (val) {
                    ref
                        .read(sceneLinkageSettingProvider.notifier)
                        .update((state) => state.copyWith(enable: val));
                  },
                ),
              ),
              ListItem.switchItem(
                leading: const GlyphIcon(AppGlyphs.bell),
                title: const Text('切换时弹出通知'),
                subtitle: const Text('成功触发自动切换后发送系统横幅通知'),
                delegate: SwitchDelegate(
                  value: props.enableNotification,
                  onChanged: (val) {
                    ref
                        .read(sceneLinkageSettingProvider.notifier)
                        .update((state) => state.copyWith(enableNotification: val));
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '联动规则 (${props.rules.length})',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '自上而下匹配 · 按住拖拽排序',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          if (props.rules.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('暂无联动规则，点击右上角加号添加'),
              ),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: props.rules.length,
              onReorder: _handleReorder,
              itemBuilder: (context, index) {
                final rule = props.rules[index];
                final profile = profiles.firstWhere(
                  (p) => p.id.toString() == rule.profileId,
                  orElse: () => Profile(id: 0, label: '配置 #${rule.profileId}'),
                );
                final profileLabel = profile.label.isEmpty ? '未配置' : profile.label;
                final nodeLabel = rule.proxyName ?? '默认/上次选中节点';

                return ListItem(
                  key: ValueKey(rule.id),
                  leading: ReorderableDragStartListener(
                    index: index,
                    child: const GlyphIcon(AppGlyphs.sort),
                  ),
                  title: Text(rule.name),
                  subtitle: Text(
                    '${rule.packageNames.length} 个应用 -> $profileLabel · $nodeLabel',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: rule.enable,
                        onChanged: (val) {
                          final newRules = List<SceneRule>.from(props.rules);
                          newRules[index] = rule.copyWith(enable: val);
                          ref
                              .read(sceneLinkageSettingProvider.notifier)
                              .update((state) => state.copyWith(rules: newRules));
                        },
                      ),
                      IconButton(
                        icon: const GlyphIcon(AppGlyphs.edit),
                        onPressed: () => _handleEditRule(rule),
                      ),
                      IconButton(
                        icon: const GlyphIcon(AppGlyphs.delete),
                        onPressed: () => _handleDeleteRule(rule.id),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
