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
      // 检查是否已存在该 URL，避免重复添加
      if (!config.profiles.any((p) => p.url == subscribeUrl)) {
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

// ProfileItem 和 ReorderableProfiles 类保持不变，略去以节省空间
