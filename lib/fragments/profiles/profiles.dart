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

  List<GlobalObjectKey<_ProfileItemState>> profileItemKeys = [];

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
    final updateProfiles = profileItemKeys.map<Future>(
        (key) async => await key.currentState?.updateProfile(false));
    await Future.wait(updateProfiles);
  }

  _initScaffoldState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        final commonScaffoldState =
            context.findAncestorStateOfType<CommonScaffoldState>();
        if (!context.mounted) return;
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

  _changeProfile(String? id) async {
    final appController = globalState.appController;
    final config = appController.config;
    if (id == config.currentProfileId) return;
    config.currentProfileId = id;
    applyConfigDebounce ??= debounce<Function()>(() async {
      await appController.applyProfile();
      appController.appState.delayMap = {};
      appController.saveConfigPreferences();
    });
    applyConfigDebounce!();
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
            profileItemKeys = state.profiles
                .map(
                    (profile) => GlobalObjectKey<_ProfileItemState>(profile.id))
                .toList();
            final columns = _getColumns(state.viewMode);
            return Align(
              alignment: Alignment.topCenter,
              child: ScrollOverBuilder(
                builder: (isOver) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
                      bottom: 16 + (isOver ? 72 : 0),
                    ),
                    child: Grid(
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      crossAxisCount: columns,
                      children: [
                        for (int i = 0; i < state.profiles.length; i++)
                          GridItem(
                            child: ProfileItem(
                              key: profileItemKeys[i],
                              profile: state.profiles[i],
                              groupValue: state.currentProfileId,
                              onChanged: _changeProfile,
                            ),
                          ),
                      ],
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

class ProfileItem extends StatefulWidget {
  final Profile profile;
  final String? groupValue;
  final void Function(String? value) onChanged;

  const ProfileItem({
    super.key,
    required this.profile,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  State<ProfileItem> createState() => _ProfileItemState();
}

class _ProfileItemState extends State<ProfileItem> {
  final isUpdating = ValueNotifier<bool>(false);

  _handleDeleteProfile() async {
    globalState.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(
        text: appLocalizations.deleteProfileTip,
      ),
      onTab: () async {
        await globalState.appController.deleteProfile(widget.profile.id);
        if(mounted){
          Navigator.of(context).pop();
        }
      },
    );
  }

  _handleUpdateProfile() async {
    await globalState.safeRun<void>(updateProfile);
  }

  Future updateProfile([isSingle = true]) async {
    isUpdating.value = true;
    try {
      final appController = globalState.appController;
      await appController.updateProfile(widget.profile);
      if (widget.profile.id == appController.config.currentProfile?.id) {
        globalState.appController.applyProfile(isPrue: true);
      }
    } catch (e) {
      isUpdating.value = false;
      if (!isSingle) {
        return e.toString();
      } else {
        rethrow;
      }
    }
    isUpdating.value = false;
    return null;
  }

  _handleShowEditExtendPage() {
    showExtendPage(
      context,
      body: EditProfile(
        profile: widget.profile,
        context: context,
      ),
      title: "${appLocalizations.edit}${appLocalizations.profile}",
    );
  }

  _buildTitle(Profile profile) {
    final textTheme = context.textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  profile.label ?? profile.id,
                  style: textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                profile.lastUpdateDate?.lastUpdateTimeDesc ?? '',
                style: textTheme.labelMedium?.toLight,
              ),
            ],
          ),
          Builder(builder: (context) {
            final userInfo = profile.userInfo ?? const UserInfo();
            final use = userInfo.upload + userInfo.download;
            final total = userInfo.total;
            final useShow = TrafficValue(value: use).show;
            final totalShow = TrafficValue(value: total).show;
            final progress = total == 0 ? 0.0 : use / total;
            final expireShow = userInfo.expire == 0
                ? appLocalizations.infiniteTime
                : DateTime.fromMillisecondsSinceEpoch(userInfo.expire * 1000)
                    .show;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                  ),
                  child: LinearProgressIndicator(
                    minHeight: 6,
                    value: progress,
                  ),
                ),
                Text(
                  "$useShow / $totalShow",
                  style: textTheme.labelMedium?.toLight,
                ),
                const SizedBox(
                  height: 2,
                ),
                Row(
                  children: [
                    Text(
                      expireShow,
                      style: textTheme.labelMedium?.toLight,
                    ),
                  ],
                )
              ],
            );
          }),
        ],
      ),
    );
  }

  @override
  void dispose() {
    isUpdating.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final groupValue = widget.groupValue;
    final onChanged = widget.onChanged;
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
          child: ValueListenableBuilder(
            valueListenable: isUpdating,
            builder: (_, isUpdating, ___) {
              return FadeBox(
                child: isUpdating
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
                              _handleShowEditExtendPage();
                              break;
                            case ProfileActions.delete:
                              _handleDeleteProfile();
                              break;
                            case ProfileActions.update:
                              _handleUpdateProfile();
                              break;
                            case null:
                              break;
                          }
                        },
                      ),
              );
            },
          ),
        ),
        title: _buildTitle(profile),
        tileTitleAlignment: ListTileTitleAlignment.titleHeight,
      ),
    );
  }
}
