import 'package:fl_clash/fragments/profiles/edit_profile.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
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

  String _getLastUpdateTimeDifference(DateTime lastDateTime) {
    final currentDateTime = DateTime.now();
    final difference = currentDateTime.difference(lastDateTime);
    final days = difference.inDays;
    if (days >= 365) {
      return "${(days / 365).floor()} ${appLocalizations.years}${appLocalizations.ago}";
    }
    if (days >= 30) {
      return "${(days / 30).floor()} ${appLocalizations.months}${appLocalizations.ago}";
    }
    if (days >= 1) {
      return "$days ${appLocalizations.days}${appLocalizations.ago}";
    }
    final hours = difference.inHours;
    if (hours >= 1) {
      return "$hours ${appLocalizations.hours}${appLocalizations.ago}";
    }
    final minutes = difference.inMinutes;
    if (minutes >= 1) {
      return "$minutes ${appLocalizations.minutes}${appLocalizations.ago}";
    }
    return appLocalizations.just;
  }

  _handleDeleteProfile(String id) async {
    context.appController.deleteProfile(id);
  }

  _handleUpdateProfile(String id) async {
    context.findAncestorStateOfType<CommonScaffoldState>()?.loadingRun(
          () => context.appController.updateProfile(id),
        );
  }

  Widget _profileItem({
    required Profile profile,
    required String? groupValue,
    required void Function(String? value) onChanged,
  }) {
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
      trailing: CommonPopupMenu<ProfileActions>(
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
                    profile.lastUpdateDate != null
                        ? _getLastUpdateTimeDifference(profile.lastUpdateDate!)
                        : '',
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

  _handleShowAddExtendPage() {
    showExtendPage(
      context,
      body: AddProfile(
        context: context,
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
              child: _profileItem(
                profile: profile,
                groupValue: state.currentProfileId,
                onChanged: context.appController.changeProfileDebounce,
              ),
            ),
        ],
      ),
    );
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
      child: Selector<Config, ProfilesSelectorState>(
        selector: (_, config) => ProfilesSelectorState(
          profiles: config.profiles,
          currentProfileId: config.currentProfileId,
        ),
        builder: (context, state, child) {
          if (state.profiles.isEmpty) {
            return NullStatus(
              label: appLocalizations.nullProfileDesc,
            );
          }
          return Align(
            alignment: Alignment.topCenter,
            child: SlotLayout(
              config: {
                Breakpoints.small: SlotLayout.from(
                  key: const Key('profiles_grid_small'),
                  builder: (_) => _buildGrid(
                    state: state,
                    crossAxisCount: 1,
                  ),
                ),
                Breakpoints.medium: SlotLayout.from(
                  key: const Key('profiles_grid_medium'),
                  builder: (_) => _buildGrid(
                    state: state,
                    crossAxisCount: 1,
                  ),
                ),
                Breakpoints.large: SlotLayout.from(
                  key: const Key('profiles_grid_large'),
                  builder: (_) => _buildGrid(
                    state: state,
                    crossAxisCount: 2,
                  ),
                ),
              },
            ),
          );
        },
      ),
    );
  }
}
