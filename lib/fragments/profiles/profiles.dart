import 'dart:ui';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/fragments/profiles/edit_profile.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/services/api_service.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 配置文件管理页面，展示和管理 Clash 配置文件
class ProfilesFragment extends StatefulWidget {
  const ProfilesFragment({super.key});

  @override
  State<ProfilesFragment> createState() => _ProfilesFragmentState();
}

class _ProfilesFragmentState extends State<ProfilesFragment> {
  Function? applyConfigDebounce;

  // 批量更新所有远程配置文件
  _updateProfiles() async {
    final appController = globalState.appController;
    final config = appController.config;
    final profiles = config.profiles;
    final messages = [];
    final updateProfiles = profiles.map<Future>(
      (profile) async {
        if (profile.type == ProfileType.file) return; // 本地文件无需更新
        config.setProfile(profile.copyWith(isUpdating: true));
        try {
          await appController.updateProfile(profile);
        } catch (e) {
          messages.add("${profile.label ?? profile.id}: $e \n");
          config.setProfile(profile.copyWith(isUpdating: false));
        }
      },
    );
    final titleMedium = context.textTheme.titleMedium;
    await Future.wait(updateProfiles);
    if (messages.isNotEmpty) {
      globalState.showMessage(
        title: appLocalizations.tip,
        message: TextSpan(
          children: [
            for (final message in messages)
              TextSpan(text: message, style: titleMedium)
          ],
        ),
      );
    }
  }

  // 初始化时自动添加订阅配置
  _initAutoAddProfile() async {
    final appController = globalState.appController;
    final config = Provider.of<Config>(context, listen: false);

    if (config.token == null || config.isAuthenticated != true) return; // 未登录则跳过

    try {
      final subscribeUrl = await ApiService.getUserSubscribe(
        apiBaseUrl: config.apiBaseUrl,
        token: config.token!,
      );
      // 检查是否已存在该 URL，且确保 subscribeUrl 非空
      if (subscribeUrl != null && !config.profiles.any((p) => p.url == subscribeUrl)) {
        await appController.addProfileFormURL(subscribeUrl);
      }
    } catch (e) {
      globalState.showMessage(
        title: appLocalizations.tip,
        message: TextSpan(text: "自动添加订阅配置失败: $e"),
      );
    }
  }

  // 初始化 Scaffold 的动作按钮
  _initScaffold() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!mounted) return;
        final commonScaffoldState = context.commonScaffoldState;
        commonScaffoldState?.actions = [
          IconButton(
            onPressed: () => _updateProfiles(),
            icon: const Icon(Icons.sync),
            tooltip: appLocalizations.sync, // 增加提示
          ),
          IconButton(
            onPressed: () {
              final profiles = globalState.appController.config.profiles;
              showSheet(
                title: appLocalizations.profilesSort,
                context: context,
                body: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5, // 动态高度
                  child: ReorderableProfiles(profiles: profiles),
                ),
              );
            },
            icon: const Icon(Icons.sort),
            iconSize: 26,
            tooltip: appLocalizations.sort, // 增加提示
          ),
        ];
        // 移除 FloatingActionButton，改为自动添加
        _initAutoAddProfile();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ActiveBuilder(
      label: "profiles",
      builder: (isCurrent, child) {
        if (isCurrent) {
          _initScaffold();
        }
        return child!;
      },
      child: Selector2<AppState, Config, ProfilesSelectorState>(
        selector: (_, appState, config) => ProfilesSelectorState(
          profiles: config.profiles,
          currentProfileId: config.currentProfileId,
          columns: other.getProfilesColumns(appState.viewWidth),
        ),
        builder: (context, state, child) {
          if (state.profiles.isEmpty) {
            return NullStatus(
              label: appLocalizations.nullProfileDesc,
            );
          }
          return Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 88, // 预留底部空间，尽管无 FAB
              ),
              child: Grid(
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                crossAxisCount: state.columns,
                children: [
                  for (int i = 0; i < state.profiles.length; i++)
                    GridItem(
                      child: ProfileItem(
                        key: Key(state.profiles[i].id),
                        profile: state.profiles[i],
                        groupValue: state.currentProfileId,
                        onChanged: globalState.appController.changeProfile,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// 配置文件项，展示单个配置文件信息并提供操作菜单
class ProfileItem extends StatelessWidget {
  final Profile profile;
  final String? groupValue;
  final void Function(String? value) onChanged;

  const ProfileItem({
    super.key,
    required this.profile,
    required this.groupValue,
    required this.onChanged,
  });

  _handleDeleteProfile(BuildContext context) async {
    final res = await globalState.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(
        text: appLocalizations.deleteProfileTip,
      ),
    );
    if (res != true) return;
    await globalState.appController.deleteProfile(profile.id);
  }

  _handleUpdateProfile() async {
    await globalState.safeRun<void>(updateProfile);
  }

  Future updateProfile() async {
    final appController = globalState.appController;
    final config = appController.config;
    if (profile.type == ProfileType.file) return;
    await globalState.safeRun(silence: false, () async {
      try {
        config.setProfile(profile.copyWith(isUpdating: true));
        await appController.updateProfile(profile);
      } catch (e) {
        config.setProfile(profile.copyWith(isUpdating: false));
        rethrow;
      }
    });
  }

  _handleShowEditExtendPage(BuildContext context) {
    showExtendPage(
      context,
      body: EditProfile(profile: profile, context: context),
      title: "${appLocalizations.edit}${appLocalizations.profile}",
    );
  }

  List<Widget> _buildUrlProfileInfo(BuildContext context) {
    final subscriptionInfo = profile.subscriptionInfo;
    return [
      const SizedBox(height: 8),
      if (subscriptionInfo != null)
        SubscriptionInfoView(subscriptionInfo: subscriptionInfo),
      Text(
        profile.lastUpdateDate?.lastUpdateTimeDesc ?? "",
        style: context.textTheme.labelMedium?.toLight,
      ),
    ];
  }

  List<Widget> _buildFileProfileInfo(BuildContext context) {
    return [
      const SizedBox(height: 8),
      Text(
        profile.lastUpdateDate?.lastUpdateTimeDesc ?? "",
        style: context.textTheme.labelMedium?.toLight,
      ),
    ];
  }

  _handleCopyLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: profile.url));
    if (context.mounted) {
      context.showNotifier(appLocalizations.copySuccess);
    }
  }

  _handleExportFile(BuildContext context) async {
    final commonScaffoldState = context.commonScaffoldState;
    final res = await commonScaffoldState?.loadingRun<bool>(
      () async {
        final file = await profile.getFile();
        final value = await picker.saveFile(
          profile.label ?? profile.id,
          file.readAsBytesSync(),
        );
        return value != null;
      },
      title: appLocalizations.tip,
    );
    if (res == true && context.mounted) {
      context.showNotifier(appLocalizations.exportSuccess);
    }
  }

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<CommonPopupBoxState>();
    return CommonCard(
      isSelected: profile.id == groupValue,
      onPressed: () => onChanged(profile.id),
      child: ListItem(
        key: Key(profile.id),
        horizontalTitleGap: 16,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        trailing: SizedBox(
          height: 40,
          width: 40,
          child: FadeBox(
            child: profile.isUpdating
                ? const Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(),
                  )
                : CommonPopupBox(
                    key: key,
                    popup: CommonPopupMenu(
                      items: [
                        ActionItemData(
                          icon: Icons.edit_outlined,
                          label: appLocalizations.edit,
                          onPressed: () => _handleShowEditExtendPage(context),
                        ),
                        if (profile.type == ProfileType.url) ...[
                          ActionItemData(
                            icon: Icons.sync_alt_sharp,
                            label: appLocalizations.sync,
                            onPressed: () => _handleUpdateProfile(),
                          ),
                          ActionItemData(
                            icon: Icons.copy,
                            label: appLocalizations.copyLink,
                            onPressed: () => _handleCopyLink(context),
                          ),
                        ],
                        ActionItemData(
                          icon: Icons.file_copy_outlined,
                          label: appLocalizations.exportFile,
                          onPressed: () => _handleExportFile(context),
                        ),
                        ActionItemData(
                          icon: Icons.delete_outlined,
                          iconSize: 20,
                          label: appLocalizations.delete,
                          onPressed: () => _handleDeleteProfile(context),
                          type: ActionType.danger,
                        ),
                      ],
                    ),
                    target: IconButton(
                      onPressed: () => key.currentState?.pop(),
                      icon: const Icon(Icons.more_vert),
                    ),
                  ),
          ),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                profile.label ?? profile.id,
                style: context.textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: switch (profile.type) {
                  ProfileType.file => _buildFileProfileInfo(context),
                  ProfileType.url => _buildUrlProfileInfo(context),
                },
              ),
            ],
          ),
        ),
        tileTitleAlignment: ListTileTitleAlignment.titleHeight,
      ),
    );
  }
}

// 可排序的配置文件列表，用于调整配置文件顺序
class ReorderableProfiles extends StatefulWidget {
  final List<Profile> profiles;

  const ReorderableProfiles({
    super.key,
    required this.profiles,
  });

  @override
  State<ReorderableProfiles> createState() => _ReorderableProfilesState();
}

class _ReorderableProfilesState extends State<ReorderableProfiles> {
  late List<Profile> profiles;

  @override
  void initState() {
    super.initState();
    profiles = List.from(widget.profiles);
  }

  // 拖动时的装饰器，添加缩放动画
  Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
    final profile = profiles[index];
    return AnimatedBuilder(
      animation: animation,
      builder: (_, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double scale = lerpDouble(1, 1.02, animValue)!;
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        key: Key(profile.id),
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: CommonCard(
          type: CommonCardType.filled,
          child: ListTile(
            contentPadding: const EdgeInsets.only(right: 44, left: 16),
            title: Text(profile.label ?? profile.id),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          flex: 1,
          child: ReorderableListView.builder(
            buildDefaultDragHandles: false,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            proxyDecorator: proxyDecorator,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (oldIndex < newIndex) newIndex -= 1;
                final profile = profiles.removeAt(oldIndex);
                profiles.insert(newIndex, profile);
              });
            },
            itemBuilder: (_, index) {
              final profile = profiles[index];
              return Container(
                key: Key(profile.id),
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: CommonCard(
                  type: CommonCardType.filled,
                  child: ListTile(
                    contentPadding: const EdgeInsets.only(right: 16, left: 16),
                    title: Text(profile.label ?? profile.id),
                    trailing: ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_handle),
                    ),
                  ),
                ),
              );
            },
            itemCount: profiles.length,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: FilledButton.tonal(
            onPressed: () {
              Navigator.of(context).pop();
              globalState.appController.config.profiles = profiles;
            },
            style: ButtonStyle(
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text(appLocalizations.confirm)],
            ),
          ),
        ),
      ],
    );
  }
}
