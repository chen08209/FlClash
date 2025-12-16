import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/overwrite.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'add.dart';
import 'edit.dart';

class ProfilesView extends StatefulWidget {
  const ProfilesView({super.key});

  @override
  State<ProfilesView> createState() => _ProfilesViewState();
}

class _ProfilesViewState extends State<ProfilesView> {
  Function? applyConfigDebounce;
  bool _isUpdating = false;

  void _handleShowAddExtendPage() {
    showExtend(
      globalState.navigatorKey.currentState!.context,
      builder: (_, type) {
        return AdaptiveSheetScaffold(
          type: type,
          body: AddProfileView(
            context: globalState.navigatorKey.currentState!.context,
          ),
          title: '${appLocalizations.add}${appLocalizations.profile}',
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
      try {
        await appController.updateProfile(profile, showLoading: true);
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
                  builder: (_, type) {
                    return ReorderableProfilesSheet(
                      type: type,
                      profiles: profiles,
                    );
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
        final isLoading = ref.watch(loadingProvider(LoadingTag.profiles));
        final state = ref.watch(profilesStateProvider);
        final spacing = 14.mAp;
        return CommonScaffold(
          isLoading: isLoading,
          title: appLocalizations.profiles,
          floatingActionButton: _buildFAB(),
          actions: _buildActions(state.profiles),
          body: state.profiles.isEmpty
              ? NullStatus(
                  label: appLocalizations.nullProfileDesc,
                  illustration: ProfileEmptyIllustration(),
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
                    child: Grid(
                      mainAxisSpacing: spacing,
                      crossAxisSpacing: spacing,
                      crossAxisCount: state.columns,
                      children: [
                        for (int i = 0; i < state.profiles.length; i++)
                          GridItem(
                            child: ProfileItem(
                              key: Key(state.profiles[i].id.toString()),
                              profile: state.profiles[i],
                              groupValue: state.currentProfileId,
                              onChanged: (profileId) {
                                ref
                                        .read(currentProfileIdProvider.notifier)
                                        .value =
                                    profileId;
                              },
                            ),
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

class ProfileItem extends StatelessWidget {
  final Profile profile;
  final int? groupValue;
  final void Function(int? value) onChanged;

  const ProfileItem({
    super.key,
    required this.profile,
    required this.groupValue,
    required this.onChanged,
  });

  Future<void> _handleDeleteProfile(BuildContext context) async {
    final res = await globalState.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(
        text: appLocalizations.deleteTip(appLocalizations.profile),
      ),
    );
    if (res != true) {
      return;
    }
    await appController.deleteProfile(profile.id);
  }

  Future<void> _handlePreview(BuildContext context) async {
    final configMap = await appController.getProfileWithId(profile.id);
    final content = await encodeYamlTask(configMap);
    if (!context.mounted) {
      return;
    }

    final previewPage = EditorPage(title: profile.realLabel, content: content);
    BaseNavigator.push<String>(context, previewPage);
  }

  Future updateProfile() async {
    if (profile.type == ProfileType.file) return;
    try {} finally {}
    await appController.loadingRun(() async {
      await appController.updateProfile(profile, showLoading: true);
    }, tag: LoadingTag.profiles);
  }

  void _handleShowEditExtendPage(BuildContext context) {
    showExtend(
      context,
      builder: (_, type) {
        return AdaptiveSheetScaffold(
          type: type,
          body: EditProfileView(profile: profile, context: context),
          title: '${appLocalizations.edit}${appLocalizations.profile}',
        );
      },
    );
  }

  List<Widget> _buildUrlProfileInfo(BuildContext context) {
    final subscriptionInfo = profile.subscriptionInfo;
    return [
      const SizedBox(height: 8),
      if (subscriptionInfo != null)
        SubscriptionInfoView(subscriptionInfo: subscriptionInfo),
      Text(
        profile.lastUpdateDate?.lastUpdateTimeDesc ?? '',
        style: context.textTheme.labelMedium?.toLighter,
      ),
    ];
  }

  List<Widget> _buildFileProfileInfo(BuildContext context) {
    return [
      const SizedBox(height: 8),
      Text(
        profile.lastUpdateDate?.lastUpdateTimeDesc ?? '',
        style: context.textTheme.labelMedium?.toLight,
      ),
    ];
  }

  Future<void> _handleCopyLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: profile.url));
    if (context.mounted) {
      context.showNotifier(appLocalizations.copySuccess);
    }
  }

  Future<void> _handleExportFile(BuildContext context) async {
    final res = await appController.safeRun<bool>(() async {
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

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      isSelected: profile.id == groupValue,
      onPressed: () {
        onChanged(profile.id);
      },
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
                        key: ValueKey('menu'),
                        popup: CommonPopupMenu(
                          items: [
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
                            if (profile.type == ProfileType.url) ...[
                              PopupMenuItemData(
                                icon: Icons.sync_alt_sharp,
                                label: appLocalizations.sync,
                                onPressed: () {
                                  updateProfile();
                                },
                              ),
                            ],
                            PopupMenuItemData(
                              icon: Icons.emergency_outlined,
                              label: appLocalizations.more,
                              subItems: [
                                PopupMenuItemData(
                                  icon: Icons.extension_outlined,
                                  label: appLocalizations.override,
                                  onPressed: () {
                                    _handlePushGenProfilePage(
                                      context,
                                      profile.id,
                                    );
                                  },
                                ),
                                // PopupMenuItemData(
                                //   icon: Icons.extension_outlined,
                                //   label: appLocalizations.override + "1",
                                //   onPressed: () {
                                //     final overrideProfileView = OverrideProfileView(
                                //       profileId: profile.id,
                                //     );
                                //     BaseNavigator.push(
                                //       context,
                                //       overrideProfileView,
                                //     );
                                //   },
                                // ),
                                if (profile.type == ProfileType.url) ...[
                                  PopupMenuItemData(
                                    icon: Icons.copy,
                                    label: appLocalizations.copyLink,
                                    onPressed: () {
                                      _handleCopyLink(context);
                                    },
                                  ),
                                ],
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
                              icon: Icons.delete_outlined,
                              label: appLocalizations.delete,
                              onPressed: () {
                                _handleDeleteProfile(context);
                              },
                            ),
                          ],
                        ),
                        targetBuilder: (open) {
                          return IconButton(
                            onPressed: () {
                              open();
                            },
                            icon: Icon(Icons.more_vert),
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

class ReorderableProfilesSheet extends StatefulWidget {
  final List<Profile> profiles;
  final SheetType type;

  const ReorderableProfilesSheet({
    super.key,
    required this.profiles,
    required this.type,
  });

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

  Widget _buildItem(int index, [bool isDecorator = false]) {
    final isLast = index == profiles.length - 1;
    final isFirst = index == 0;
    final profile = profiles[index];
    return CommonInputListItem(
      key: Key(profile.id.toString()),
      trailing: ReorderableDelayedDragStartListener(
        index: index,
        child: const Icon(Icons.drag_handle),
      ),
      title: Text(profile.realLabel),
      isFirst: isFirst,
      isLast: isLast,
      isDecorator: isDecorator,
    );
  }

  void _handleSave() {
    Navigator.of(context).pop();
    appController.reorder(profiles);
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveSheetScaffold(
      type: widget.type,
      actions: [
        if (widget.type == SheetType.bottomSheet)
          IconButton.filledTonal(
            onPressed: _handleSave,
            style: IconButton.styleFrom(
              visualDensity: VisualDensity.comfortable,
              tapTargetSize: MaterialTapTargetSize.padded,
              padding: EdgeInsets.all(8),
              iconSize: 20,
            ),
            icon: Icon(Icons.check),
          )
        else
          IconButton.filledTonal(
            icon: Icon(Icons.check),
            onPressed: _handleSave,
          ),
      ],
      body: Padding(
        padding: EdgeInsets.only(bottom: 32, top: 12),
        child: ReorderableListView.builder(
          buildDefaultDragHandles: false,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          proxyDecorator: (child, index, animation) {
            return commonProxyDecorator(
              _buildItem(index, true),
              index,
              animation,
            );
          },
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final profile = profiles.removeAt(oldIndex);
              profiles.insert(newIndex, profile);
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
