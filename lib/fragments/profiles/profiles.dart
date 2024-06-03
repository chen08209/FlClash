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
  _handleDeleteProfile(String id) async {
    globalState.appController.deleteProfile(id);
  }

  _handleUpdateProfile(String id) async {
    context.findAncestorStateOfType<CommonScaffoldState>()?.loadingRun(
          () => globalState.appController.updateProfile(id),
        );
  }

  _handleShowAddExtendPage() {
    showExtendPage(
      globalState.navigatorKey.currentState!.context,
      body: AddProfile(
        context: globalState.navigatorKey.currentState!.context,
      ),
      title: "${appLocalizations.add}${appLocalizations.profile}",
    );
  }

  _handleShowEditExtendPage(Profile profile) {
    showExtendPage(
      context,
      body: EditProfile(
        profile: profile.copyWith(),
        context: context,
      ),
      title: "${appLocalizations.edit}${appLocalizations.profile}",
    );
  }

  _buildGrid({
    required ProfilesSelectorState state,
    int crossAxisCount = 1,
  }) {
    return SingleChildScrollView(
      padding: crossAxisCount > 1
          ? const EdgeInsets.symmetric(horizontal: 16)
          : EdgeInsets.zero,
      child: Grid.baseGap(
        crossAxisCount: crossAxisCount,
        children: [
          for (final profile in state.profiles)
            GridItem(
              child: ProfileItem(
                profile: profile,
                commonPopupMenu: CommonPopupMenu<ProfileActions>(
                  items: [
                    CommonPopupMenuItem(
                      action: ProfileActions.edit,
                      label: appLocalizations.edit,
                      iconData: Icons.edit,
                    ),
                    if (profile.url != null)
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
                groupValue: state.currentProfileId,
                onChanged: globalState.appController.changeProfile,
              ),
            ),
        ],
      ),
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

  @override
  Widget build(BuildContext context) {
    return FloatLayout(
      floatingWidget: Container(
        margin: const EdgeInsets.all(kFloatingActionButtonMargin),
        child: FloatingActionButton(
          heroTag: null,
          onPressed: _handleShowAddExtendPage,
          child: const Icon(Icons.add),
        ),
      ),
      child: Selector2<AppState, Config, ProfilesSelectorState>(
        selector: (_, appState, config) => ProfilesSelectorState(
            profiles: config.profiles,
            currentProfileId: config.currentProfileId,
            viewMode: appState.viewMode),
        builder: (context, state, child) {
          if (state.profiles.isEmpty) {
            return NullStatus(
              label: appLocalizations.nullProfileDesc,
            );
          }
          return Align(
            alignment: Alignment.topCenter,
            child: _buildGrid(
              state: state,
              crossAxisCount: _getColumns(state.viewMode),
            ),
          );
        },
      ),
    );
  }
}

class ProfileItem extends StatelessWidget {
  final Profile profile;
  final String? groupValue;
  final CommonPopupMenu commonPopupMenu;
  final void Function(String? value) onChanged;

  const ProfileItem({
    super.key,
    required this.profile,
    required this.commonPopupMenu,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    String useShow;
    String totalShow;
    double progress;
    final userInfo = profile.userInfo;
    if (userInfo == null) {
      useShow = "Infinite";
      totalShow = "Infinite";
      progress = 1;
    } else {
      final use = userInfo.upload + userInfo.download;
      final total = userInfo.total;
      useShow = TrafficValue(value: use).show;
      totalShow = TrafficValue(value: total).show;
      progress = total == 0 ? 0.0 : use / total;
    }
    return ListItem.radio(
      horizontalTitleGap: 16,
      delegate: RadioDelegate<String?>(
        value: profile.id,
        groupValue: groupValue,
        onChanged: onChanged,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      trailing: commonPopupMenu,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    profile.label ?? profile.id,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Text(
                    profile.lastUpdateDate?.lastUpdateTimeDesc ?? '',
                    style: Theme.of(context).textTheme.labelMedium?.toLight(),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(
                vertical: 8,
              ),
              child: LinearProgressIndicator(
                minHeight: 6,
                value: progress,
              ),
            ),
          ),
          Flexible(
            child: Text(
              "$useShow / $totalShow",
              style: Theme.of(context).textTheme.labelMedium?.toLight(),
            ),
          ),
        ],
      ),
    );
  }
}
