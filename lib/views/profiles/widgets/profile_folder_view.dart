import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../profiles.dart';

/// 文件夹视图：支持将订阅按文件夹分类组织，折叠/展开展示
/// 支持：
/// 1. 空白处右键新建文件夹
/// 2. 文件夹头部右键重命名、解散文件夹
/// 3. 拖拽订阅卡片（Drag & Drop）直觉归类到目标文件夹
class ProfileFolderView extends ConsumerStatefulWidget {
  const ProfileFolderView({
    super.key,
    required this.profiles,
    required this.currentProfileId,
    required this.spacing,
  });

  final List<Profile> profiles;
  final int? currentProfileId;
  final double spacing;

  @override
  ConsumerState<ProfileFolderView> createState() => _ProfileFolderViewState();
}

class _ProfileFolderViewState extends ConsumerState<ProfileFolderView> {
  // 记录每个文件夹的展开状态（默认全部展开）
  final Map<String, bool> _expandedState = {};
  // 记录用户手动新建的空文件夹
  final Set<String> _customFolders = {};

  /// 从订阅名称提取文件夹名字
  /// 支持格式：[免费] 节点A、(付费) 节点B、【常用】节点C、@游戏 节点D
  /// 未匹配到的统一归类为 "未分类"
  static String extractFolderName(Profile profile) {
    final label = profile.realLabel.trim();
    final match = RegExp(r'^[\[【\(@](.*?)[\]】\)]').firstMatch(label);
    if (match != null && match.group(1) != null) {
      final name = match.group(1)!.trim();
      if (name.isNotEmpty) return name;
    }
    return '未分类';
  }

  /// 获取纯净的订阅显示名称（去除文件夹前缀）
  static String cleanProfileLabel(Profile profile) {
    final label = profile.realLabel.trim();
    return label.replaceFirst(RegExp(r'^[\[【\(@].*?[\]】\)]\s*'), '').trim();
  }

  Map<String, List<Profile>> _getGroupedProfiles() {
    final Map<String, List<Profile>> groups = {};

    // 1. 先载入所有已知或自定义创建的文件夹
    for (final folder in _customFolders) {
      groups.putIfAbsent(folder, () => []);
    }

    // 2. 将现有订阅分配到对应的文件夹中
    for (final profile in widget.profiles) {
      final folder = extractFolderName(profile);
      groups.putIfAbsent(folder, () => []).add(profile);
    }

    // 3. 确保 "未分类" 如果存在则排在最后
    if (!groups.containsKey('未分类') &&
        widget.profiles.any((p) => extractFolderName(p) == '未分类')) {
      groups.putIfAbsent('未分类', () => []);
    }

    return groups;
  }

  int _columnsFor(BuildContext context, double width) => getProfilesColumns(
    width - 32.0,
    spacing: widget.spacing,
    minItemWidth: profileItemMinWidth.ap(context),
  );

  /// 移动订阅到目标文件夹
  void _moveProfileToFolder(Profile profile, String targetFolder) {
    final clean = cleanProfileLabel(profile);
    final newLabel = targetFolder == '未分类' ? clean : '[$targetFolder] $clean';
    if (profile.label != newLabel) {
      ref.read(profilesActionProvider.notifier).putProfile(
        profile.copyWith(label: newLabel),
      );
    }
  }

  /// 右键空白处：新建文件夹弹窗
  Future<void> _handleCreateFolder(BuildContext context) async {
    final name = await dialogs.showCommonDialog<String>(
      child: const InputDialog(
        title: '新建文件夹',
        labelText: '文件夹名称',
        value: '',
        selectAll: true,
      ),
    );
    if (name == null || name.trim().isEmpty) return;
    final folderName = name.trim();
    setState(() {
      _customFolders.add(folderName);
      _expandedState[folderName] = true;
    });
  }

  /// 文件夹右键菜单：重命名
  Future<void> _handleRenameFolder(
    BuildContext context,
    String oldName,
    List<Profile> folderProfiles,
  ) async {
    final newName = await dialogs.showCommonDialog<String>(
      child: InputDialog(
        title: '重命名文件夹',
        labelText: '新文件夹名称',
        value: oldName,
        selectAll: true,
      ),
    );
    if (newName == null ||
        newName.trim().isEmpty ||
        newName.trim() == oldName) {
      return;
    }
    final trimmed = newName.trim();

    setState(() {
      _customFolders.remove(oldName);
      _customFolders.add(trimmed);
      _expandedState[trimmed] = _expandedState.remove(oldName) ?? true;
    });

    // 批量更新文件夹下的所有订阅
    final profilesAction = ref.read(profilesActionProvider.notifier);
    for (final profile in folderProfiles) {
      final clean = cleanProfileLabel(profile);
      final updated = profile.copyWith(label: '[$trimmed] $clean');
      profilesAction.putProfile(updated);
    }
  }

  /// 文件夹右键菜单：解散文件夹（移回未分类）
  void _handleDissolveFolder(String folderName, List<Profile> folderProfiles) {
    setState(() {
      _customFolders.remove(folderName);
      _expandedState.remove(folderName);
    });

    final profilesAction = ref.read(profilesActionProvider.notifier);
    for (final profile in folderProfiles) {
      final clean = cleanProfileLabel(profile);
      final updated = profile.copyWith(label: clean);
      profilesAction.putProfile(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = _getGroupedProfiles();
    final colorScheme = Theme.of(context).colorScheme;

    return ContextMenuRegion(
      menuItems: [
        CommonPopupMenuItem(
          glyph: AppGlyphs.addCircle,
          label: '新建文件夹',
          onPressed: () => _handleCreateFolder(context),
        ),
      ],
      child: ListView.builder(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: (context.appBarInset + 8).toDouble(),
          bottom: 16.0 + context.bottomInset.toDouble(),
        ),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final folderName = groups.keys.elementAt(index);
          final folderProfiles = groups[folderName]!;
          final isExpanded = _expandedState[folderName] ?? true;

          // 当前选中的活动节点是否位于该文件夹内
          final hasActiveProfile = folderProfiles.any(
            (p) => p.id == widget.currentProfileId,
          );

          // 每个文件夹作为一个拖拽接收目标 (DragTarget)
          return DragTarget<Profile>(
            onWillAcceptWithDetails: (details) {
              return extractFolderName(details.data) != folderName;
            },
            onAcceptWithDetails: (details) {
              _moveProfileToFolder(details.data, folderName);
            },
            builder: (context, candidateData, rejectedData) {
              final isHovered = candidateData.isNotEmpty;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: isHovered
                      ? colorScheme.primaryContainer.withOpacity(0.35)
                      : colorScheme.surfaceVariant.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isHovered
                        ? colorScheme.primary
                        : hasActiveProfile
                            ? colorScheme.primary.withOpacity(0.55)
                            : colorScheme.outlineVariant.withOpacity(0.3),
                    width: isHovered ? 2.0 : hasActiveProfile ? 1.5 : 1.0,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- 文件夹头部栏（带右键菜单与点击折叠） ---
                    ContextMenuRegion(
                      menuItems: [
                        CommonPopupMenuItem(
                          glyph: AppGlyphs.edit,
                          label: '重命名文件夹',
                          onPressed: () => _handleRenameFolder(
                            context,
                            folderName,
                            folderProfiles,
                          ),
                        ),
                        if (folderName != '未分类')
                          CommonPopupMenuItem(
                            glyph: AppGlyphs.delete,
                            label: '解散文件夹 (移回未分类)',
                            danger: true,
                            onPressed: () => _handleDissolveFolder(
                              folderName,
                              folderProfiles,
                            ),
                          ),
                      ],
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _expandedState[folderName] = !isExpanded;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              GlyphIcon(
                                isExpanded
                                    ? AppGlyphs.layers
                                    : AppGlyphs.appsList,
                                color: isHovered
                                    ? colorScheme.primary
                                    : hasActiveProfile
                                        ? colorScheme.primary
                                        : colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        folderName,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: isHovered || hasActiveProfile
                                              ? colorScheme.primary
                                              : colorScheme.onSurface,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // 文件夹药丸徽章：显示数量
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isHovered || hasActiveProfile
                                            ? colorScheme.primaryContainer
                                            : colorScheme.surfaceVariant,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${folderProfiles.length}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isHovered || hasActiveProfile
                                              ? colorScheme.onPrimaryContainer
                                              : colorScheme.onSurfaceVariant,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // 折叠指示箭头
                              GlyphIcon(
                                isExpanded
                                    ? AppGlyphs.chevronUp
                                    : AppGlyphs.chevronDown,
                                color: colorScheme.onSurfaceVariant,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // --- 展开的订阅卡片（支持卡片拖拽） ---
                    if (isExpanded)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: folderProfiles.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 24,
                                ),
                                child: Center(
                                  child: Text(
                                    '文件夹为空（按住订阅卡片拖拽至此即可归类）',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: colorScheme.onSurfaceVariant
                                          .withOpacity(0.65),
                                    ),
                                  ),
                                ),
                              )
                            : WidthBuilder(
                                builder: (context, width) {
                                  final columns = _columnsFor(context, width);
                                  final delegate =
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    mainAxisSpacing: widget.spacing,
                                    crossAxisSpacing: widget.spacing,
                                    mainAxisExtent: profileItemHeight,
                                  );

                                  return GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate: delegate,
                                    itemCount: folderProfiles.length,
                                    itemBuilder: (context, pIndex) {
                                      final profile = folderProfiles[pIndex];

                                      final itemWidget = ProfileItem(
                                        key: ValueKey(profile.id),
                                        profile: profile,
                                        displayLabel:
                                            cleanProfileLabel(profile),
                                        groupValue: widget.currentProfileId,
                                        onChanged: (profileId) {
                                          ref
                                              .read(
                                                currentProfileIdProvider
                                                    .notifier,
                                              )
                                              .value = profileId;
                                        },
                                      );

                                      // 拖拽支持：按住直接拖动卡片
                                      return Draggable<Profile>(
                                        data: profile,
                                        feedback: Material(
                                          type: MaterialType.transparency,
                                          child: Container(
                                            width: 280,
                                            height: profileItemHeight,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colorScheme.surfaceVariant,
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              border: Border.all(
                                                color: colorScheme.primary,
                                                width: 2,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.25),
                                                  blurRadius: 16,
                                                  offset: const Offset(0, 6),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              children: [
                                                GlyphIcon(
                                                  AppGlyphs.profiles,
                                                  size: 20,
                                                  color: colorScheme.primary,
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    cleanProfileLabel(profile),
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          colorScheme.onSurface,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        childWhenDragging: Opacity(
                                          opacity: 0.3,
                                          child: itemWidget,
                                        ),
                                        child: itemWidget,
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
