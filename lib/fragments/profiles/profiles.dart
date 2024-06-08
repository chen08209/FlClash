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
  final hasPadding = ValueNotifier<bool>(false);

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

  _initScaffoldState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        final commonScaffoldState =
            context.findAncestorStateOfType<CommonScaffoldState>();
        commonScaffoldState?.actions = [
          IconButton(
            onPressed: () {
              commonScaffoldState.loadingRun<void>(
                () async {
                  await globalState.appController.updateProfiles();
                },
              );
            },
            icon: const Icon(Icons.download),
          ),
          const SizedBox(
            width: 8,
          )
        ];
        commonScaffoldState?.floatingActionButton = FloatingActionButton(
          heroTag: null,
          onPressed: _handleShowAddExtendPage,
          child: const Icon(
            Icons.add,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector<AppState, bool>(
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
          final isMobile = state.viewMode == ViewMode.mobile;
          return Align(
            alignment: Alignment.topCenter,
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  hasPadding.value =
                      scrollNotification.metrics.maxScrollExtent > 0;
                });
                return true;
              },
              child: ValueListenableBuilder(
                valueListenable: hasPadding,
                builder: (_, hasPadding, __) {
                  return SingleChildScrollView(
                    padding: !isMobile
                        ? EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16,
                            bottom: 16 + (hasPadding ? 56 : 0),
                          )
                        : EdgeInsets.only(
                            bottom: 0 + (hasPadding ? 56 : 0),
                          ),
                    child: Grid(
                      mainAxisSpacing: isMobile ? 8 : 16,
                      crossAxisSpacing: 16,
                      crossAxisCount: columns,
                      children: [
                        for (final profile in state.profiles)
                          GridItem(
                            child: ProfileItem(
                              profile: profile,
                              groupValue: state.currentProfileId,
                              onChanged:
                                  globalState.appController.changeProfile,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
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

  _handleDeleteProfile(String id) async {
    globalState.appController.deleteProfile(id);
  }

  _handleUpdateProfile(String id) async {
    isUpdating.value = true;
    await globalState.safeRun<void>(() async {
      await globalState.appController.updateProfile(id);
    });
    isUpdating.value = false;
  }

  _handleShowEditExtendPage(
    Profile profile,
  ) {
    showExtendPage(
      context,
      body: EditProfile(
        profile: profile.copyWith(),
        context: context,
      ),
      title: "${appLocalizations.edit}${appLocalizations.profile}",
    );
  }

  _buildTitle(Profile profile) {
    final textTheme = context.textTheme;
    final userInfo = profile.userInfo ?? UserInfo();
    final use = userInfo.upload + userInfo.download;
    final total = userInfo.total;
    final useShow = TrafficValue(value: use).show;
    final totalShow = TrafficValue(value: total).show;
    final progress = total == 0 ? 0.0 : use / total;
    final expireShow = userInfo.expire == 0
        ? "长期有效"
        : DateTime.fromMillisecondsSinceEpoch(userInfo.expire * 1000).show;
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
              Text(
                profile.label ?? profile.id,
                style: textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                profile.lastUpdateDate?.lastUpdateTimeDesc ?? '',
                style: textTheme.labelMedium?.toLight(),
              ),
            ],
          ),
          Column(
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
                style: textTheme.labelMedium?.toLight(),
              ),
              const SizedBox(
                height: 2,
              ),
              Row(
                children: [
                  Text(
                    "到期时间:",
                    style: textTheme.labelMedium?.toLighter(),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    expireShow,
                    style: textTheme.labelMedium?.toLighter(),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final groupValue = widget.groupValue;
    final onChanged = widget.onChanged;
    return Selector<AppState, ViewMode>(
      selector: (_, appState) => appState.viewMode,
      builder: (_, viewMode, child) {
        if (viewMode == ViewMode.mobile) {
          return child!;
        }
        return CommonCard(
          child: child!,
        );
      },
      child: ListItem.radio(
        key: Key(profile.id),
        horizontalTitleGap: 16,
        delegate: RadioDelegate<String?>(
          value: profile.id,
          groupValue: groupValue,
          onChanged: onChanged,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        trailing: CommonPopupMenu<ProfileActions>(
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
                _handleShowEditExtendPage(profile);
                break;
              case ProfileActions.delete:
                _handleDeleteProfile(profile.id);
                break;
              case ProfileActions.update:
                _handleUpdateProfile(profile.id);
                break;
              case null:
                break;
            }
          },
        ),
        title: _buildTitle(profile),
        tileTitleAlignment: ListTileTitleAlignment.titleHeight,
      ),
    );
  }
}
