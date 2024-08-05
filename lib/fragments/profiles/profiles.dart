import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/fragments/profiles/edit_profile.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'add_profile.dart';

enum PopupMenuItemEnum { delete, edit }

enum ProfileActions {
  edit,
  update,
  delete,
}

class ProfilesFragment extends StatefulWidget {
  const ProfilesFragment({super.key});

  @override
  State<ProfilesFragment> createState() => _ProfilesFragmentState();
}

class _ProfilesFragmentState extends State<ProfilesFragment> {
  Function? applyConfigDebounce;

  _handleShowAddExtendPage() {
    showExtendPage(
      globalState.navigatorKey.currentState!.context,
      body: AddProfile(
        context: globalState.navigatorKey.currentState!.context,
      ),
      title: "${appLocalizations.add}${appLocalizations.profile}",
    );
  }

  _getColumns(ViewMode viewMode) {
    switch (viewMode) {
      case ViewMode.mobile:
        return 1;
      case ViewMode.laptop:
        return 1;
      case ViewMode.desktop:
        return 2;
    }
  }

  _updateProfiles() async {
    final appController = globalState.appController;
    final config = appController.config;
    final profiles = appController.config.profiles;
    final updateProfiles = profiles.map<Future>(
      (profile) async {
        config.setProfile(
          profile.copyWith(isUpdating: true),
        );
        try {
          await appController.updateProfile(profile);
          if (profile.id == appController.config.currentProfile?.id) {
            appController.applyProfile(isPrue: true);
          }
        } catch (_) {
          config.setProfile(
            profile.copyWith(
              isUpdating: false,
            ),
          );
        }
      },
    );
    await Future.wait(updateProfiles);
  }

  _initScaffoldState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!context.mounted) return;
        final commonScaffoldState =
            context.findAncestorStateOfType<CommonScaffoldState>();
        commonScaffoldState?.actions = [
          IconButton(
            onPressed: () {
              _updateProfiles();
            },
            icon: const Icon(Icons.sync),
          ),
        ];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatLayout(
      floatingWidget: FloatWrapper(
        child: FloatingActionButton(
          heroTag: null,
          onPressed: _handleShowAddExtendPage,
          child: const Icon(
            Icons.add,
          ),
        ),
      ),
      child: Selector<AppState, bool>(
        selector: (_, appState) => appState.currentLabel == 'profiles',
        builder: (_, isCurrent, child) {
          if (isCurrent) {
            _initScaffoldState();
          }
          return child!;
        },
        child: Selector2<AppState, Config, ProfilesSelectorState>(
          selector: (_, appState, config) => ProfilesSelectorState(
            profiles: config.profiles,
            currentProfileId: config.currentProfileId,
            viewMode: appState.viewMode,
          ),
          builder: (context, state, child) {
            if (state.profiles.isEmpty) {
              return NullStatus(
                label: appLocalizations.nullProfileDesc,
              );
            }
            final columns = _getColumns(state.viewMode);
            return Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 88,
                ),
                child: Grid(
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  crossAxisCount: columns,
                  children: [
                    for (int i = 0; i < state.profiles.length; i++)
                      GridItem(
                        child: ProfileItem(
                          key: Key(state.profiles[i].id),
                          profile: state.profiles[i],
                          groupValue: state.currentProfileId,
                          onChanged:
                          globalState.appController.changeProfile,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

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
    globalState.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(
        text: appLocalizations.deleteProfileTip,
      ),
      onTab: () async {
        await globalState.appController.deleteProfile(profile.id);
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
    );
  }

  _handleUpdateProfile() async {
    await globalState.safeRun<void>(updateProfile);
  }

  Future updateProfile() async {
    final appController = globalState.appController;
    final config = appController.config;
    if (profile.type == ProfileType.file) return;
    await globalState.safeRun(() async {
      try {
        config.setProfile(
          profile.copyWith(
            isUpdating: true,
          ),
        );
        await appController.updateProfile(profile);
        if (profile.id == appController.config.currentProfile?.id) {
          appController.applyProfile(isPrue: true);
        }
      } catch (e) {
        config.setProfile(
          profile.copyWith(
            isUpdating: false,
          ),
        );
        rethrow;
      }
    });
  }

  _handleShowEditExtendPage(BuildContext context) {
    showExtendPage(
      context,
      body: EditProfile(
        profile: profile,
        context: context,
      ),
      title: "${appLocalizations.edit}${appLocalizations.profile}",
    );
  }

  List<Widget> _buildUserInfo(BuildContext context, UserInfo userInfo) {
    final use = userInfo.upload + userInfo.download;
    final total = userInfo.total;
    if (total == 0) {
      return [];
    }
    final useShow = TrafficValue(value: use).show;
    final totalShow = TrafficValue(value: total).show;
    final progress = total == 0 ? 0.0 : use / total;
    final expireShow = userInfo.expire == 0
        ? appLocalizations.infiniteTime
        : DateTime.fromMillisecondsSinceEpoch(userInfo.expire * 1000).show;
    return [
      LinearProgressIndicator(
        minHeight: 6,
        value: progress,
      ),
      const SizedBox(
        height: 8,
      ),
      Text(
        "$useShow / $totalShow · $expireShow",
        style: context.textTheme.labelMedium?.toLight,
      ),
      const SizedBox(
        height: 4,
      ),
    ];
  }

  List<Widget> _buildUrlProfileInfo(BuildContext context) {
    final userInfo = profile.userInfo;
    return [
      const SizedBox(
        height: 8,
      ),
      if (userInfo != null) ..._buildUserInfo(context, userInfo),
      Text(
        profile.lastUpdateDate?.lastUpdateTimeDesc ?? "",
        style: context.textTheme.labelMedium?.toLight,
      ),
    ];
  }

  List<Widget> _buildFileProfileInfo(BuildContext context) {
    return [
      const SizedBox(
        height: 8,
      ),
      Text(
        profile.lastUpdateDate?.lastUpdateTimeDesc ?? "",
        style: context.textTheme.labelMedium?.toLight,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      isSelected: profile.id == groupValue,
      onPressed: () {
        onChanged(profile.id);
      },
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
                : CommonPopupMenu<ProfileActions>(
                    items: [
                      CommonPopupMenuItem(
                        action: ProfileActions.edit,
                        label: appLocalizations.edit,
                        iconData: Icons.edit,
                      ),
                      if (profile.type == ProfileType.url)
                        CommonPopupMenuItem(
                          action: ProfileActions.update,
                          label: appLocalizations.update,
                          iconData: Icons.sync,
                        ),
                      CommonPopupMenuItem(
                        action: ProfileActions.delete,
                        label: appLocalizations.delete,
                        iconData: Icons.delete,
                      ),
                    ],
                    onSelected: (ProfileActions? action) async {
                      switch (action) {
                        case ProfileActions.edit:
                          _handleShowEditExtendPage(context);
                          break;
                        case ProfileActions.delete:
                          _handleDeleteProfile(context);
                          break;
                        case ProfileActions.update:
                          _handleUpdateProfile();
                          break;
                        case null:
                          break;
                      }
                    },
                  ),
          ),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
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
                children: [
                  ...switch (profile.type) {
                    ProfileType.file => _buildFileProfileInfo(context),
                    ProfileType.url => _buildUrlProfileInfo(context),
                  },
                ],
              ),
            ],
          ),
        ),
        tileTitleAlignment: ListTileTitleAlignment.titleHeight,
      ),
    );
  }
}
