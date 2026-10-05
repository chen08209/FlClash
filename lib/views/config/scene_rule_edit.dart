import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../access.dart';

class SceneRuleEditView extends ConsumerStatefulWidget {
  final SceneRule? rule;

  const SceneRuleEditView({super.key, this.rule});

  @override
  ConsumerState<SceneRuleEditView> createState() => _SceneRuleEditViewState();
}

class _SceneRuleEditViewState extends ConsumerState<SceneRuleEditView> {
  late TextEditingController _nameController;
  late List<String> _selectedPackageNames;
  String? _selectedProfileId;
  String? _selectedProxyName;
  late bool _enableNotification;

  @override
  void initState() {
    super.initState();
    final rule = widget.rule;
    _nameController = TextEditingController(text: rule?.name ?? '');
    _selectedPackageNames = List.from(rule?.packageNames ?? []);
    _selectedProfileId = rule?.profileId;
    _selectedProxyName = rule?.proxyName;
    _enableNotification = rule?.enableNotification ?? true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(systemActionProvider.notifier).getPackages();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final name = _nameController.text.trim();
    if (_selectedPackageNames.isEmpty) {
      dialogs.showNotifier('请至少选择一个目标应用', level: MessageLevel.warning);
      return;
    }
    if (_selectedProfileId == null || _selectedProfileId!.isEmpty) {
      dialogs.showNotifier('请选择目标配置', level: MessageLevel.warning);
      return;
    }

    final newRule = SceneRule(
      id: widget.rule?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.isEmpty ? '联动规则' : name,
      packageNames: _selectedPackageNames,
      profileId: _selectedProfileId,
      proxyName: _selectedProxyName,
      enable: widget.rule?.enable ?? true,
      enableNotification: _enableNotification,
    );

    final currentProps = ref.read(sceneLinkageSettingProvider);
    final rules = List<SceneRule>.from(currentProps.rules);
    final index = rules.indexWhere((r) => r.id == newRule.id);
    if (index != -1) {
      rules[index] = newRule;
    } else {
      rules.add(newRule);
    }

    ref
        .read(sceneLinkageSettingProvider.notifier)
        .update((state) => state.copyWith(rules: rules));

    Navigator.of(context).pop();
  }

  void _showAppSelector() {
    showSheet(
      context: context,
      props: const SheetProps(isScrollControlled: true),
      builder: (sheetContext) {
        return _AppMultiSelectorSheet(
          initialSelected: _selectedPackageNames,
          onConfirm: (selected) {
            setState(() {
              _selectedPackageNames = selected;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(profilesProvider);
    final selectedProfile = profiles.firstWhere(
      (p) => p.id.toString() == _selectedProfileId,
      orElse: () => profiles.isNotEmpty ? profiles.first : Profile(id: 0, label: ''),
    );

    return BaseScaffold(
      title: widget.rule == null ? '新建联动规则' : '编辑联动规则',
      actions: [
        IconButton(
          tooltip: '保存',
          icon: const GlyphIcon(AppGlyphs.check),
          onPressed: _handleSave,
        ),
      ],
      body: ListView(
        padding: EdgeInsets.only(top: context.contentTopPadding, bottom: 32),
        children: [
          generateSectionV3(
            title: '基本信息',
            items: [
              ListItem.input(
                leading: const GlyphIcon(AppGlyphs.edit),
                title: const Text('规则名称'),
                controller: _nameController,
                hintText: '如：游戏加速模式',
              ),
              ListItem.open(
                leading: const GlyphIcon(AppGlyphs.apps),
                title: const Text('目标应用'),
                subtitle: Text(
                  _selectedPackageNames.isEmpty
                      ? '未选择应用'
                      : '已选择 ${_selectedPackageNames.length} 个应用',
                ),
                widget: const SizedBox.shrink(),
                onTap: _showAppSelector,
              ),
            ],
          ),
          generateSectionV3(
            title: '联动目标',
            items: [
              ListItem.open(
                leading: const GlyphIcon(AppGlyphs.profile),
                title: const Text('目标配置'),
                subtitle: Text(
                  selectedProfile.label.isEmpty
                      ? '请选择配置'
                      : selectedProfile.label,
                ),
                widget: const SizedBox.shrink(),
                onTap: () {
                  showSheet(
                    context: context,
                    builder: (_) => CommonScaffold(
                      title: '选择目标配置',
                      body: ListView(
                        children: [
                          for (final profile in profiles)
                            ListItem.radio(
                              title: Text(profile.label),
                              value: profile.id.toString(),
                              groupValue: _selectedProfileId,
                              onChanged: (val) {
                                setState(() {
                                  _selectedProfileId = val;
                                  _selectedProxyName = null;
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              ListItem.open(
                leading: const GlyphIcon(AppGlyphs.proxies),
                title: const Text('目标节点'),
                subtitle: Text(
                  _selectedProxyName == null || _selectedProxyName!.isEmpty
                      ? '保持目标配置默认/上次选中节点'
                      : _selectedProxyName!,
                ),
                widget: const SizedBox.shrink(),
                onTap: () {
                  showSheet(
                    context: context,
                    builder: (_) => CommonScaffold(
                      title: '选择目标节点',
                      body: ListView(
                        children: [
                          ListItem.radio(
                            title: const Text('保持目标配置默认/上次选中节点'),
                            value: '',
                            groupValue: _selectedProxyName ?? '',
                            onChanged: (_) {
                              setState(() {
                                _selectedProxyName = null;
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                          for (final group in selectedProfile.selectedMap.entries)
                            ListItem(
                              title: Text(group.key),
                              subtitle: Text(group.value),
                              onTap: () {
                                setState(() {
                                  _selectedProxyName = group.value;
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          generateSectionV3(
            title: '通知选项',
            items: [
              ListItem.switchItem(
                leading: const GlyphIcon(AppGlyphs.bell),
                title: const Text('启用此规则触发通知'),
                subtitle: const Text('触发本规则自动切换时推送系统横幅通知'),
                delegate: SwitchDelegate(
                  value: _enableNotification,
                  onChanged: (val) {
                    setState(() {
                      _enableNotification = val;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AppMultiSelectorSheet extends ConsumerStatefulWidget {
  final List<String> initialSelected;
  final ValueChanged<List<String>> onConfirm;

  const _AppMultiSelectorSheet({
    required this.initialSelected,
    required this.onConfirm,
  });

  @override
  ConsumerState<_AppMultiSelectorSheet> createState() =>
      __AppMultiSelectorSheetState();
}

class __AppMultiSelectorSheetState
    extends ConsumerState<_AppMultiSelectorSheet> {
  late Set<String> _selected;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.initialSelected);
  }

  @override
  Widget build(BuildContext context) {
    final packages = ref.watch(packagesProvider);
    final query = SearchQuery(_searchQuery);
    final filteredPackages = packages
        .whereMatches(query, (p) => [p.label, p.packageName])
        .toList();

    return CommonScaffold(
      title: '选择目标应用 (${_selected.length})',
      searchState: AppBarSearchState(
        onSearch: (q) {
          setState(() {
            _searchQuery = q;
          });
        },
      ),
      actions: [
        IconButton(
          tooltip: '完成',
          icon: const GlyphIcon(AppGlyphs.check),
          onPressed: () {
            widget.onConfirm(_selected.toList());
            Navigator.of(context).pop();
          },
        ),
      ],
      body: ListView.builder(
        itemCount: filteredPackages.length,
        itemExtent: 72,
        itemBuilder: (_, index) {
          final package = filteredPackages[index];
          final isSelected = _selected.contains(package.packageName);
          return PackageListItem(
            package: package,
            value: isSelected,
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  _selected.add(package.packageName);
                } else {
                  _selected.remove(package.packageName);
                }
              });
            },
          );
        },
      ),
    );
  }
}
