import 'dart:isolate';

import 'package:fl_clash/common/common.dart';
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

  Future<void> _updateProfiles() async {
    final profiles = globalState.config.profiles;
    final messages = [];
    final updateProfiles = profiles.map<Future>((profile) async {
      if (profile.type == ProfileType.file) return;
      globalState.appController.setProfile(profile.copyWith(isUpdating: true));
      try {
        await globalState.appController.updateProfile(profile);
      } catch (e) {
        messages.add('${profile.label ?? profile.id}: $e \n');
        globalState.appController.setProfile(
          profile.copyWith(isUpdating: false),
        );
      }
    });
    final titleMedium = context.textTheme.titleMedium;
    await Future.wait(updateProfiles);
    if (messages.isNotEmpty) {
      globalState.showMessage(
        title: appLocalizations.tip,
        message: TextSpan(
          children: [
            for (final message in messages)
              TextSpan(text: message, style: titleMedium),
          ],
        ),
      );
    }
  }

  List<Widget> _buildActions(List<Profile> profiles) {
    return profiles.isNotEmpty
        ? [
            IconButton(
              onPressed: () {
                _updateProfiles();
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
    return FloatingActionButton(
      heroTag: null,
      onPressed: _handleShowAddExtendPage,
      child: const Icon(Icons.add),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, _) {
        final profilesSelectorState = ref.watch(profilesSelectorStateProvider);
        final spacing = 14.ap;
        return CommonScaffold(
          title: appLocalizations.profiles,
          floatingActionButton: _buildFAB(),
          actions: _buildActions(profilesSelectorState.profiles),
          body: profilesSelectorState.profiles.isEmpty
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
                      crossAxisCount: profilesSelectorState.columns,
                      children: [
                        for (
                          int i = 0;
                          i < profilesSelectorState.profiles.length;
                          i++
                        )
                          GridItem(
                            child: ProfileItem(
                              key: Key(profilesSelectorState.profiles[i].id),
                              profile: profilesSelectorState.profiles[i],
                              groupValue:
                                  profilesSelectorState.currentProfileId,
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
  final String? groupValue;
  final void Function(String? value) onChanged;

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
    await globalState.appController.deleteProfile(profile.id);
  }

  Future<void> _handlePreview(BuildContext context) async {
    final config = await globalState.getConfigMap(profile.id);
    final content = await Isolate.run(() {
      return yaml.encode(config);
    });
    if (!context.mounted) {
      return;
    }

    final previewPage = EditorPage(
      title: profile.label ?? profile.id,
      content: content,
    );
    BaseNavigator.push<String>(context, previewPage);
  }

  Future updateProfile() async {
    final appController = globalState.appController;
    if (profile.type == ProfileType.file) return;
    await globalState.appController.safeRun(silence: false, () async {
      try {
        appController.setProfile(profile.copyWith(isUpdating: true));
        await appController.updateProfile(profile);
      } catch (e) {
        appController.setProfile(profile.copyWith(isUpdating: false));
        rethrow;
      }
    });
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
    final res = await globalState.appController.safeRun<bool>(
      () async {
        final file = await profile.getFile();
        final value = await picker.saveFile(
          profile.label ?? profile.id,
          file.readAsBytesSync(),
        );
        if (value == null) return false;
        return true;
      },
      needLoading: true,
      title: appLocalizations.tip,
    );
    if (res == true && context.mounted) {
      context.showNotifier(appLocalizations.exportSuccess);
    }
  }

  void _handlePushGenProfilePage(BuildContext context, String id) {
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
        key: Key(profile.id),
        horizontalTitleGap: 16,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        trailing: SizedBox(
          height: 40,
          width: 40,
          child: FadeThroughBox(
            child: profile.isUpdating
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
                                _handlePushGenProfilePage(context, profile.id);
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
      key: Key(profile.id),
      trailing: ReorderableDelayedDragStartListener(
        index: index,
        child: const Icon(Icons.drag_handle),
      ),
      title: Text(profile.label ?? profile.id),
      isFirst: isFirst,
      isLast: isLast,
      isDecorator: isDecorator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveSheetScaffold(
      type: widget.type,
      actions: [
        if (widget.type == SheetType.bottomSheet)
          IconButton.filledTonal(
            onPressed: () {
              Navigator.of(context).pop();
              globalState.appController.setProfiles(profiles);
            },
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
            onPressed: () {
              Navigator.of(context).pop();
              globalState.appController.setProfiles(profiles);
            },
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
