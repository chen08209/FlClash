import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/free_nodes.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/overwrite/overwrite.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'add.dart';
import 'edit.dart';
import 'free_node_stability.dart';
import 'preview.dart';

@visibleForTesting
Widget buildProfilesTitleBarForTesting() => const _ProfilesTitleBar();

class ProfilesView extends StatefulWidget {
  const ProfilesView({super.key});

  @override
  State<ProfilesView> createState() => _ProfilesViewState();
}

class _ProfilesViewState extends State<ProfilesView> {
  Function? applyConfigDebounce;
  bool _isUpdating = false;

  // final GlobalKey _targetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final context = _targetKey.currentContext;
    //   if (context == null) {
    //     return;
    //   }
    //   Scrollable.ensureVisible(
    //     context,
    //     duration: commonDuration,
    //     alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
    //   );
    // });
  }

  void _handleShowAddExtendPage() {
    showExtend(
      globalState.navigatorKey.currentState!.context,
      builder: (_) {
        return AdaptiveSheetScaffold(
          body: AddProfileView(
            context: globalState.navigatorKey.currentState!.context,
          ),
          title: context.appLocalizations.addProfile,
        );
      },
    );
  }

  Future<void> _updateProfiles(List<Profile> profiles) async {
    if (_isUpdating == true) {
      return;
    }
    _isUpdating = true;
    final List<UpdatingMessage> messages = [];
    final updateProfiles = profiles.map<Future>((profile) async {
      if (profile.type == ProfileType.file) return;
      if (profile.isFreeNodesProfile) return;
      try {
        final action = globalState.container.read(
          profilesActionProvider.notifier,
        );
        await action.updateProfile(profile, showLoading: true);
      } catch (e) {
        messages.add(
          UpdatingMessage(label: profile.realLabel, message: e.toString()),
        );
      }
    });
    await Future.wait(updateProfiles);
    if (messages.isNotEmpty) {
      globalState.showAllUpdatingMessagesDialog(messages);
    }
    _isUpdating = false;
  }

  List<Widget> _buildActions(List<Profile> profiles) {
    return profiles.isNotEmpty
        ? [
            IconButton(
              onPressed: () {
                _updateProfiles(profiles);
              },
              icon: const Icon(Icons.sync),
            ),
            IconButton(
              onPressed: () {
                showSheet(
                  context: context,
                  builder: (_) {
                    return ReorderableProfilesSheet(profiles: profiles);
                  },
                );
              },
              icon: const Icon(Icons.sort),
              iconSize: 26,
            ),
          ]
        : [];
  }

  Widget _buildFAB() {
    return CommonFloatingActionButton(
      onPressed: _handleShowAddExtendPage,
      icon: const Icon(Icons.add),
      label: context.appLocalizations.addProfile,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, _) {
        final appLocalizations = context.appLocalizations;
        final isLoading = ref.watch(loadingProvider(LoadingTag.profiles));
        final state = ref.watch(profilesStateProvider);
        final spacing = 14.mAp;
        return CommonScaffold(
          isLoading: isLoading,
          appBar: AppBar(
            centerTitle: false,
            titleSpacing: 24,
            toolbarHeight: 68,
            title: const _ProfilesTitleBar(),
            actions: genActions(_buildActions(state.profiles)),
          ),
          floatingActionButton: _buildFAB(),
          body: state.profiles.isEmpty
              ? NullStatus(
                  label: appLocalizations.nullProfileDesc,
                  illustration: const ProfileEmptyIllustration(),
                )
              : Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    key: profilesStoreKey,
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
                      bottom: 88,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Grid(
                          mainAxisSpacing: spacing,
                          crossAxisSpacing: spacing,
                          crossAxisCount: state.columns,
                          children: [
                            for (int i = 0; i < state.profiles.length; i++)
                              GridItem(
                                child: ProfileItem(
                                  profile: state.profiles[i],
                                  groupValue: state.currentProfileId,
                                  onChanged: (profileId) {
                                    if (profileId == null) return;
                                    unawaited(
                                      ref
                                          .read(profilesActionProvider.notifier)
                                          .selectProfile(profileId),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _ProfilesTitleBar extends StatelessWidget {
  const _ProfilesTitleBar();

  Widget _buildLink(
    BuildContext context,
    String text,
    String url, {
    required Key key,
  }) {
    return InkWell(
      key: key,
      borderRadius: BorderRadius.circular(8),
      onTap: () => globalState.openUrl(url, confirm: false),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 40),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.colorScheme.outlineVariant),
          color: context.colorScheme.surfaceContainerHighest.opacity80,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: context.textTheme.labelMedium?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 64),
                child: Text(
                  '配置',
                  key: const Key('profiles_title_label'),
                  style: context.textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildLink(
                        context,
                        '优质机场',
                        'https://jichangtuijian.com/ssr-v2ray%E4%B8%93%E7%BA%BF%E6%9C%BA%E5%9C%BA%E6%8E%A8%E8%8D%90.html',
                        key: const Key('profiles_title_quality_airport_link'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildLink(
                        context,
                        '便宜机场',
                        'https://maomeng.cc/2021/06/11/ji-chang-tui-jian-chang-qi-geng-xin/',
                        key: const Key('profiles_title_budget_airport_link'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 72, top: 12),
            child: Text(
              '不要轻易购买小于0.05元/G的机场',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.error,
                fontSize: 13,
                height: 1.15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileItem extends StatelessWidget {
  final Profile profile;
  final int? groupValue;
  final void Function(int? value) onChanged;
  final Future<void> Function(BuildContext context, String url)?
  sourceUrlOpener;

  const ProfileItem({
    super.key,
    required this.profile,
    required this.groupValue,
    required this.onChanged,
    this.sourceUrlOpener,
  });

  Future<void> _handleDeleteProfile(BuildContext context) async {
    final appLocalizations = context.appLocalizations;
    final isFreeNodesProfile = profile.isFreeNodesProfile;
    final res = await globalState.showMessage(
      title: isFreeNodesProfile ? '重置免费节点' : appLocalizations.tip,
      message: TextSpan(
        text: isFreeNodesProfile
            ? '重新获取免费节点并恢复为当前配置，入口不会被永久删除。'
            : appLocalizations.deleteTip(appLocalizations.profile),
      ),
      confirmText: isFreeNodesProfile ? '重置' : null,
    );
    if (res != true) {
      return;
    }
    final action = globalState.container.read(profilesActionProvider.notifier);
    if (isFreeNodesProfile) {
      await action.removeFreeNodesProfile();
    } else {
      await action.deleteProfile(profile.id);
    }
  }

  Future<void> _handlePreview(BuildContext context) async {
    BaseNavigator.push<String>(context, PreviewProfileView(profile: profile));
  }

  Future updateProfile() async {
    if (profile.type == ProfileType.file) return;
    await globalState.loadingRun(() async {
      final action = globalState.container.read(
        profilesActionProvider.notifier,
      );
      if (profile.isFreeNodesProfile) {
        await action.updateFreeNodesProfile(showLoading: true);
      } else {
        await action.updateProfile(profile, showLoading: true);
      }
    }, tag: LoadingTag.profiles);
  }

  void _handleShowEditExtendPage(BuildContext context) {
    showExtend(
      context,
      builder: (_) {
        return AdaptiveSheetScaffold(
          body: EditProfileView(profile: profile, context: context),
          title: context.appLocalizations.edit,
        );
      },
    );
  }

  List<Widget> _buildUrlProfileInfo(BuildContext context) {
    final subscriptionInfo = profile.subscriptionInfo;
    return [
      const SizedBox(height: 8),
      if (subscriptionInfo != null && !profile.isFreeNodesProfile)
        SubscriptionInfoView(subscriptionInfo: subscriptionInfo),
      _buildProfileTimeAndSourceLink(
        context,
        style: context.textTheme.labelMedium?.toLighter,
      ),
    ];
  }

  Widget _buildProfileTimeAndSourceLink(
    BuildContext context, {
    TextStyle? style,
  }) {
    final sourceUrl = profile.sourceUrl.trim();
    final createdAt = Snowflake.dateTimeFromId(profile.id);
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Flexible(
          child: ProfileTimeText(
            dateTime: createdAt ?? profile.lastUpdateDate,
            prefix: '添加时间：',
            style: style,
          ),
        ),
        if (!profile.isFreeNodesProfile && sourceUrl.isNotEmpty) ...[
          const SizedBox(width: 8),
          Expanded(
            child: _SourceUrlChip(
              sourceUrl: sourceUrl,
              onTap: () => _handleOpenSourceUrl(context),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFreeNodesProgressView(
    BuildContext context,
    FreeNodesProgress? progress,
  ) {
    if (progress == null) return const SizedBox.shrink();
    final colorScheme = context.colorScheme;
    final textStyle = context.textTheme.labelMedium;
    final color = progress.error
        ? colorScheme.error
        : progress.done
        ? Colors.green
        : colorScheme.primary;
    final statusText = progress.done
        ? '${progress.operation.takeFirstValid(['已完成'])} · ${progress.proxyCount} 个节点'
        : progress.error
        ? progress.operation
        : '获取中 · ${progress.proxyCount} 个节点';
    final timingText = _buildFreeNodesProgressTimingText(progress);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (progress.done)
                Icon(Icons.check_circle_outline, size: 16, color: color)
              else if (progress.error)
                Icon(Icons.error_outline, size: 16, color: color),
              if (progress.done || progress.error) const SizedBox(width: 4),
              Expanded(
                child: Text(
                  statusText,
                  style: textStyle?.copyWith(color: color),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (timingText != null) ...[
            const SizedBox(height: 4),
            Text(
              timingText,
              style: context.textTheme.labelSmall?.copyWith(
                color: progress.done || progress.error
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (!progress.done && !progress.error) ...[
            const SizedBox(height: 6),
            LinearProgressIndicator(value: progress.value),
          ],
        ],
      ),
    );
  }

  String? _buildFreeNodesProgressTimingText(FreeNodesProgress progress) {
    final startedAt = progress.startedAt;
    if (startedAt == null) return null;
    final current = DateTime.now();
    final elapsed = current.difference(startedAt);
    if (!progress.done && !progress.error) {
      final completed = progress.completed;
      final total = progress.total;
      if (completed > 0 && total > completed && elapsed > Duration.zero) {
        final remaining = Duration(
          milliseconds:
              (elapsed.inMilliseconds / completed * (total - completed))
                  .round(),
        );
        return '预计剩余 ${_formatFreeNodesProgressDuration(remaining)} · 已用 ${_formatFreeNodesProgressDuration(elapsed)}';
      }
      return '已用 ${_formatFreeNodesProgressDuration(elapsed)}';
    }
    final finishedAt = progress.finishedAt ?? current;
    final used = finishedAt.difference(startedAt);
    if (progress.error) {
      return '失败前用时 ${_formatFreeNodesProgressDuration(used)}';
    }
    return '本次用时 ${_formatFreeNodesProgressDuration(used)}';
  }

  String _formatFreeNodesProgressDuration(Duration duration) {
    final seconds = duration.inSeconds;
    if (seconds <= 0) return '<1秒';
    final minutes = seconds ~/ 60;
    final remainSeconds = seconds % 60;
    if (minutes <= 0) return '$remainSeconds秒';
    if (minutes < 60) {
      return remainSeconds == 0 ? '$minutes分' : '$minutes分$remainSeconds秒';
    }
    final hours = minutes ~/ 60;
    final remainMinutes = minutes % 60;
    return remainMinutes == 0 ? '$hours小时' : '$hours小时$remainMinutes分';
  }

  List<Widget> _buildFileProfileInfo(BuildContext context) {
    return [
      const SizedBox(height: 8),
      _buildProfileTimeAndSourceLink(
        context,
        style: context.textTheme.labelMedium?.toLight,
      ),
    ];
  }

  Future<void> _handleCopyLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: profile.url));
    if (context.mounted) {
      context.showNotifier(context.appLocalizations.copySuccess);
    }
  }

  Future<void> _handleOpenSourceUrl(BuildContext context) async {
    final sourceUrl = profile.sourceUrl.trim();
    if (sourceUrl.isEmpty) return;
    if (!context.mounted) return;
    final opener = sourceUrlOpener;
    if (opener != null) {
      await opener(context, sourceUrl);
      return;
    }
    await globalState.openUrl(sourceUrl, confirm: false);
  }

  Future<void> _handleExportFile(BuildContext context) async {
    final appLocalizations = context.appLocalizations;
    final res = await globalState.safeRun<bool>(() async {
      final mFile = await profile.file;
      final value = await picker.saveFile(
        profile.realLabel,
        mFile.readAsBytesSync(),
      );
      if (value == null) return false;
      return true;
    }, title: appLocalizations.tip);
    if (res == true && context.mounted) {
      context.showNotifier(appLocalizations.exportSuccess);
    }
  }

  void _handlePushGenProfilePage(BuildContext context, int id) {
    BaseNavigator.push(context, OverwriteView(profileId: id));
  }

  void _handleShowFreeNodeStability(BuildContext context) {
    showSheet(
      context: context,
      builder: (_) => FreeNodeStabilitySheet(profile: profile),
    );
  }

  Future<void> _handlePreferFreeNodes(BuildContext context) async {
    final res = await globalState.showMessage(
      title: '优选节点',
      message: const TextSpan(text: '整合优选节点？如已开启删除旧日期分类，会同时删除超时分类。'),
      confirmText: '优选',
    );
    if (res != true) return;
    await globalState.safeRun(() async {
      final result = await globalState.container
          .read(profilesActionProvider.notifier)
          .preferFreeNodesProfile(profile);
      globalState.showNotifier(
        result.removedCount > 0
            ? '已删除 ${result.removedCount} 个超时节点'
            : '已整合优选节点',
      );
    }, title: '优选节点');
  }

  List<PopupMenuItemData> _buildMenuItems(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return [
      PopupMenuItemData(
        icon: Icons.edit_outlined,
        label: appLocalizations.edit,
        onPressed: () {
          _handleShowEditExtendPage(context);
        },
      ),
      PopupMenuItemData(
        icon: Icons.visibility_outlined,
        label: appLocalizations.preview,
        onPressed: () {
          _handlePreview(context);
        },
      ),
      if (profile.isFreeNodesProfile)
        PopupMenuItemData(
          icon: Icons.sync_alt_sharp,
          label: '\u624b\u52a8\u66f4\u65b0',
          onPressed: () {
            updateProfile();
          },
        )
      else if (profile.type == ProfileType.url)
        PopupMenuItemData(
          icon: Icons.sync_alt_sharp,
          label: appLocalizations.sync,
          onPressed: () {
            updateProfile();
          },
        ),
      if (profile.isFreeNodesProfile)
        PopupMenuItemData(
          icon: Icons.monitor_heart_outlined,
          label: '\u7a33\u5b9a\u6027\u6d4b\u8bd5',
          onPressed: () {
            _handleShowFreeNodeStability(context);
          },
        ),
      if (!profile.isFreeNodesProfile && profile.sourceUrl.trim().isNotEmpty)
        PopupMenuItemData(
          icon: Icons.travel_explore_outlined,
          label: '源订阅网站',
          onPressed: () {
            _handleOpenSourceUrl(context);
          },
        ),
      if (profile.isFreeNodesProfile)
        PopupMenuItemData(
          icon: Icons.auto_awesome_outlined,
          label: '优选节点',
          onPressed: () {
            _handlePreferFreeNodes(context);
          },
        ),
      PopupMenuItemData(
        icon: Icons.emergency_outlined,
        label: appLocalizations.more,
        subItems: [
          PopupMenuItemData(
            icon: Icons.extension_outlined,
            label: appLocalizations.override,
            onPressed: () {
              _handlePushGenProfilePage(context, profile.id);
            },
          ),
          if (profile.type == ProfileType.url)
            PopupMenuItemData(
              icon: Icons.copy,
              label: appLocalizations.copyLink,
              onPressed: () {
                _handleCopyLink(context);
              },
            ),
          PopupMenuItemData(
            icon: Icons.file_copy_outlined,
            label: appLocalizations.exportFile,
            onPressed: () {
              _handleExportFile(context);
            },
          ),
        ],
      ),
      PopupMenuItemData(
        danger: true,
        icon: profile.isFreeNodesProfile
            ? Icons.restore_outlined
            : Icons.delete_outlined,
        label: profile.isFreeNodesProfile ? '重置节点' : appLocalizations.delete,
        onPressed: () {
          _handleDeleteProfile(context);
        },
      ),
    ];
  }

  void _handleShowProfileMenu(BuildContext context) {
    showSheet(
      context: context,
      builder: (_) => AdaptiveSheetScaffold(
        title: profile.realLabel,
        body: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CommonPopupMenu(items: _buildMenuItems(context)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasSourceUrl =
        !profile.isFreeNodesProfile && profile.sourceUrl.trim().isNotEmpty;
    final showProfileMenu = profile.isFreeNodesProfile || hasSourceUrl;
    final card = CommonCard(
      isSelected: profile.id == groupValue,
      onPressed: () {
        onChanged(profile.id);
      },
      onLongPress: showProfileMenu
          ? () {
              _handleShowProfileMenu(context);
            }
          : null,
      child: ListItem(
        key: Key(profile.id.toString()),
        horizontalTitleGap: 16,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        trailing: SizedBox(
          height: 40,
          width: 40,
          child: Consumer(
            builder: (_, ref, _) {
              final isUpdating = ref.watch(
                isUpdatingProvider(profile.updatingKey),
              );
              return FadeThroughBox(
                child: isUpdating
                    ? const Padding(
                        key: ValueKey('loading'),
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(),
                      )
                    : CommonPopupBox(
                        key: const ValueKey('menu'),
                        popup: CommonPopupMenu(items: _buildMenuItems(context)),
                        targetBuilder: (open) {
                          return IconButton(
                            onPressed: () {
                              open();
                            },
                            icon: const Icon(Icons.more_vert),
                          );
                        },
                      ),
              );
            },
          ),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                profile.realLabel,
                style: context.textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...switch (profile.type) {
                    ProfileType.file => _buildFileProfileInfo(context),
                    ProfileType.url => _buildUrlProfileInfo(context),
                  },
                  if (profile.isFreeNodesProfile)
                    Consumer(
                      builder: (_, ref, _) {
                        final progress = ref.watch(
                          itemProvider(freeNodesProgressKey),
                        );
                        final fallbackProgress =
                            profile.subscriptionInfo != null
                            ? FreeNodesProgress(
                                operation: '\u5df2\u5b8c\u6210',
                                proxyCount:
                                    profile.subscriptionInfo?.total ?? 0,
                                done: true,
                              )
                            : null;
                        return _buildFreeNodesProgressView(
                          context,
                          progress is FreeNodesProgress
                              ? progress
                              : fallbackProgress,
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
        tileTitleAlignment: ListTileTitleAlignment.titleHeight,
      ),
    );
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onSecondaryTap: hasSourceUrl
          ? () {
              _handleOpenSourceUrl(context);
            }
          : profile.isFreeNodesProfile
          ? () {
              _handleShowProfileMenu(context);
            }
          : null,
      child: card,
    );
  }
}

class _SourceUrlChip extends StatelessWidget {
  final String sourceUrl;
  final VoidCallback onTap;

  const _SourceUrlChip({required this.sourceUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Semantics(
      button: true,
      label: '打开原订阅网站 $sourceUrl',
      child: Tooltip(
        message: sourceUrl,
        child: InkWell(
          key: const Key('profile_source_url_link'),
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 24),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.opacity50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.primary.opacity60),
            ),
            child: Text(
              sourceUrl,
              style: context.textTheme.labelMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileTimeText extends StatelessWidget {
  final DateTime? dateTime;
  final String prefix;
  final TextStyle? style;

  const ProfileTimeText({
    super.key,
    required this.dateTime,
    this.prefix = '',
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (dateTime == null) {
      return Text('$prefix--', style: style);
    }
    return TickBuilder(
      duration: const Duration(minutes: 1),
      builder: (context, _) {
        return Text(
          '$prefix${dateTime!.getLastUpdateTimeDesc(context)}',
          style: style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}

class ReorderableProfilesSheet extends StatefulWidget {
  final List<Profile> profiles;

  const ReorderableProfilesSheet({super.key, required this.profiles});

  @override
  State<ReorderableProfilesSheet> createState() =>
      _ReorderableProfilesSheetState();
}

class _ReorderableProfilesSheetState extends State<ReorderableProfilesSheet> {
  late List<Profile> profiles;

  @override
  void initState() {
    super.initState();
    profiles = List.from(widget.profiles);
  }

  Widget _buildItem(int index) {
    final position = ItemPosition.get(index, profiles.length);
    final profile = profiles[index];
    return ItemPositionProvider(
      key: Key(profile.id.toString()),
      position: position,
      child: DecorationListItem(
        trailing: ReorderableDelayedDragStartListener(
          index: index,
          child: const Icon(Icons.drag_handle),
        ),
        title: Text(profile.realLabel),
      ),
    );
  }

  void _handleSave() {
    Navigator.of(context).pop();
    globalState.container.read(profilesProvider.notifier).reorder(profiles);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return AdaptiveSheetScaffold(
      sheetTransparentToolBar: true,
      actions: [IconButtonData(icon: Icons.check, onPressed: _handleSave)],
      body: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: ReorderableListView.builder(
          buildDefaultDragHandles: false,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ).copyWith(top: context.sheetTopPadding),
          proxyDecorator: (child, index, animation) {
            return commonProxyDecorator(_buildItem(index), index, animation);
          },
          onReorderItem: (oldIndex, newIndex) {
            setState(() {
              profiles = profiles.copyAndReorder(oldIndex, newIndex);
            });
          },
          itemBuilder: (_, index) {
            return _buildItem(index);
          },
          itemCount: profiles.length,
        ),
      ),
      title: appLocalizations.profilesSort,
    );
  }
}
