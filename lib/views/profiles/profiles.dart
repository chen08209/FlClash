import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/overwrite/overwrite.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'add.dart';
import 'edit.dart';
import 'preview.dart';

class ProfilesView extends ConsumerStatefulWidget {
  const ProfilesView({super.key});

  @override
  ConsumerState<ProfilesView> createState() => _ProfilesViewState();
}

class _ProfilesViewState extends ConsumerState<ProfilesView> {
  Function? applyConfigDebounce;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
  }

  void _handleShowAddExtendPage() {
    final context = globalState.navigatorKey.currentState!.context;
    showAdaptivePage(
      context,
      title: context.appLocalizations.addProfile,
      bodyBuilder: (context) => AddProfileView(context: context),
    );
  }

  Future<void> _updateProfiles(List<Profile> profiles) async {
    if (_isUpdating == true) {
      return;
    }
    _isUpdating = true;
    final appLocalizations = context.appLocalizations;
    final profilesAction = ref.read(profilesActionProvider.notifier);
    final List<UpdatingMessage> messages = [];
    final updateProfiles = profiles.map<Future>((profile) async {
      if (profile.type == ProfileType.file) return;
      try {
        await profilesAction.updateProfile(profile, showLoading: true);
      } catch (e) {
        messages.add(
          UpdatingMessage(
            label: profile.realLabel,
            message: userFacingErrorMessage(e, appLocalizations),
          ),
        );
      }
    });
    await Future.wait(updateProfiles);
    if (messages.isNotEmpty) {
      unawaited(dialogs.showAllUpdatingMessagesDialog(messages));
    }
    _isUpdating = false;
  }

  List<Widget> _buildActions(List<Profile> profiles) {
    return profiles.isNotEmpty
        ? [
            IconButton(
              tooltip: context.appLocalizations.update,
              onPressed: () {
                _updateProfiles(profiles);
              },
              icon: const Icon(Icons.sync),
            ),
            IconButton(
              tooltip: context.appLocalizations.profilesSort,
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
          title: appLocalizations.profiles,
          floatingActionButton: _buildFAB(),
          actions: _buildActions(state.profiles),
          body: state.profiles.isEmpty
              ? NullStatus(
                  label: appLocalizations.nullProfileDesc,
                  illustration: const ProfileEmptyIllustration(),
                )
              : _ProfilesGrid(
                  profiles: state.profiles,
                  currentProfileId: state.currentProfileId,
                  spacing: spacing,
                ),
        );
      },
    );
  }
}

class _ProfilesGrid extends ConsumerWidget {
  const _ProfilesGrid({
    required this.profiles,
    required this.currentProfileId,
    required this.spacing,
  });

  static const _horizontalPadding = 16.0;

  final List<Profile> profiles;
  final int? currentProfileId;
  final double spacing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final columns = getProfilesColumns(
          constraints.maxWidth - _horizontalPadding * 2,
          spacing: spacing,
          minItemWidth: profileItemMinWidth.ap,
        );
        return MasonryGridView.count(
          key: profilesStoreKey,
          padding: EdgeInsets.only(
            left: _horizontalPadding,
            right: _horizontalPadding,
            top: 16,
            bottom: 16 + BottomInsetScope.of(context),
          ),
          crossAxisCount: columns,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          itemCount: profiles.length,
          itemBuilder: (context, index) {
            final profile = profiles[index];
            return ProfileItem(
              profile: profile,
              groupValue: currentProfileId,
              onChanged: (profileId) {
                ref.read(currentProfileIdProvider.notifier).value = profileId;
              },
            );
          },
        );
      },
    );
  }
}

class ProfileItem extends ConsumerWidget {
  final Profile profile;
  final int? groupValue;
  final void Function(int? value) onChanged;

  const ProfileItem({
    super.key,
    required this.profile,
    required this.groupValue,
    required this.onChanged,
  });

  Future<void> _handleDeleteProfile(BuildContext context, WidgetRef ref) async {
    final profilesAction = ref.read(profilesActionProvider.notifier);
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(
        text: appLocalizations.deleteTip(appLocalizations.profile),
      ),
    );
    if (res != true) {
      return;
    }
    await profilesAction.deleteProfile(profile.id);
  }

  Future<void> _handlePreview(BuildContext context) async {
    unawaited(
      BaseNavigator.push<String>(context, PreviewProfileView(profile: profile)),
    );
  }

  void _handleShowSubscriptionInfo(BuildContext context) {
    unawaited(
      dialogs.showCommonDialog<void>(
        context: context,
        child: Builder(
          builder: (context) {
            return CommonDialog(
              backgroundColor: context.colorScheme.surfaceContainerLow,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              title: context.appLocalizations.subscriptionInfo,
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(context.appLocalizations.confirm),
                ),
              ],
              child: SubscriptionInfoDetailView(
                subscriptionInfo: profile.subscriptionInfo!,
              ),
            );
          },
        ),
      ),
    );
  }

  Future updateProfile(WidgetRef ref) async {
    if (profile.type == ProfileType.file) return;
    await globalState.loadingRun(() async {
      await ref
          .read(profilesActionProvider.notifier)
          .updateProfile(profile, showLoading: true);
    }, tag: LoadingTag.profiles);
  }

  void _handleShowEditExtendPage(BuildContext context) {
    showAdaptivePage(
      context,
      title: context.appLocalizations.edit,
      bodyBuilder: (context) =>
          EditProfileView(profile: profile, context: context),
    );
  }

  List<Widget> _buildUrlProfileInfo(BuildContext context) {
    final subscriptionInfo = profile.subscriptionInfo;
    return [
      if (subscriptionInfo != null && subscriptionInfo.total > 0) ...[
        SubscriptionInfoView(subscriptionInfo: subscriptionInfo),
        const SizedBox(height: 6),
      ],
      LastUpdateTimeText(
        lastUpdateDate: profile.lastUpdateDate,
        style: context.textTheme.bodySmall?.toLighter,
      ),
    ];
  }

  List<Widget> _buildFileProfileInfo(BuildContext context) {
    return [
      LastUpdateTimeText(
        lastUpdateDate: profile.lastUpdateDate,
        style: context.textTheme.bodySmall?.toLighter,
      ),
    ];
  }

  Future<void> _handleCopyLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: profile.url));
    if (context.mounted) {
      context.showNotifier(
        context.appLocalizations.copySuccess,
        level: MessageLevel.success,
      );
    }
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
      context.showNotifier(
        appLocalizations.exportSuccess,
        level: MessageLevel.success,
      );
    }
  }

  void _handlePushGenProfilePage(BuildContext context, int id) {
    BaseNavigator.push(context, OverwriteView(profileId: id));
  }

  List<CommonPopupMenuItem> _menuItems(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final isUrl = profile.type == ProfileType.url;
    final subscriptionInfo = profile.subscriptionInfo;
    final hasSubscriptionInfo =
        isUrl && subscriptionInfo != null && subscriptionInfo.total > 0;
    return [
      CommonPopupMenuItem(
        icon: Icons.edit_outlined,
        label: appLocalizations.edit,
        onPressed: () {
          _handleShowEditExtendPage(context);
        },
      ),
      CommonPopupMenuItem(
        icon: Icons.visibility_outlined,
        label: appLocalizations.preview,
        onPressed: () {
          _handlePreview(context);
        },
      ),
      if (hasSubscriptionInfo)
        CommonPopupMenuItem(
          icon: Icons.data_usage,
          label: appLocalizations.subscriptionInfo,
          onPressed: () {
            _handleShowSubscriptionInfo(context);
          },
        ),
      if (isUrl)
        CommonPopupMenuItem(
          icon: Icons.sync_alt_sharp,
          label: appLocalizations.sync,
          onPressed: () {
            updateProfile(ref);
          },
        ),
      CommonPopupMenuItem(
        icon: Icons.emergency_outlined,
        label: appLocalizations.more,
        subItems: [
          CommonPopupMenuItem(
            icon: Icons.extension_outlined,
            label: appLocalizations.override,
            onPressed: () {
              _handlePushGenProfilePage(context, profile.id);
            },
          ),
          if (isUrl)
            CommonPopupMenuItem(
              icon: Icons.copy,
              label: appLocalizations.copyLink,
              onPressed: () {
                _handleCopyLink(context);
              },
            ),
          CommonPopupMenuItem(
            icon: Icons.file_copy_outlined,
            label: appLocalizations.exportFile,
            onPressed: () {
              _handleExportFile(context);
            },
          ),
        ],
      ),
      CommonPopupMenuItem(
        danger: true,
        icon: Icons.delete_outlined,
        label: appLocalizations.delete,
        onPressed: () {
          _handleDeleteProfile(context, ref);
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonCard(
      enterActionsOnRight: true,
      radius: AppCorner.xl,
      isSelected: profile.id == groupValue,
      onPressed: () {
        onChanged(profile.id);
      },
      child: ListItem(
        key: Key(profile.id.toString()),
        horizontalTitleGap: 8,
        minVerticalPadding: 12,
        padding: const EdgeInsets.only(left: 16, right: 6),
        trailing: SizedBox(
          height: 40,
          width: 40,
          child: Consumer(
            builder: (context, ref, _) {
              final isUpdating = ref.watch(
                isUpdatingProvider(profile.updatingKey),
              );
              return FadeThroughBox(
                alignment: Alignment.center,
                child: isUpdating
                    ? const Padding(
                        key: ValueKey('loading'),
                        padding: EdgeInsets.all(8),
                        child: CommonCircleLoading(),
                      )
                    : CommonPopupBox(
                        key: const ValueKey('menu'),
                        popupBuilder: (_) =>
                            CommonPopupMenu(items: _menuItems(context, ref)),
                        targetBuilder: (open) {
                          return IconButton(
                            style: IconButton.styleFrom(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.standard,
                            ),
                            tooltip: context.appLocalizations.more,
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
        title: _ProfileCardTitle(
          profile: profile,
          info: switch (profile.type) {
            ProfileType.file => _buildFileProfileInfo(context),
            ProfileType.url => _buildUrlProfileInfo(context),
          },
        ),
        tileTitleAlignment: ListTileTitleAlignment.top,
      ),
    );
  }
}

class _ProfileCardTitle extends StatelessWidget {
  const _ProfileCardTitle({required this.profile, required this.info});

  final Profile profile;
  final List<Widget> info;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          profile.realLabel,
          style: context.textTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        ...info,
      ],
    );
  }
}

class LastUpdateTimeText extends StatelessWidget {
  final DateTime? lastUpdateDate;
  final TextStyle? style;

  const LastUpdateTimeText({
    super.key,
    required this.lastUpdateDate,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (lastUpdateDate == null) {
      return Text('', style: style);
    }
    return TickBuilder(
      duration: const Duration(minutes: 1),
      builder: (context, _) {
        return Text(
          lastUpdateDate!.getLastUpdateTimeDesc(context),
          style: style,
        );
      },
    );
  }
}

class ReorderableProfilesSheet extends ConsumerStatefulWidget {
  final List<Profile> profiles;

  const ReorderableProfilesSheet({super.key, required this.profiles});

  @override
  ConsumerState<ReorderableProfilesSheet> createState() =>
      _ReorderableProfilesSheetState();
}

class _ReorderableProfilesSheetState
    extends ConsumerState<ReorderableProfilesSheet> {
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
    ref.read(profilesProvider.notifier).reorder(profiles);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return AdaptiveSheetScaffold(
      sheetTransparentToolBar: true,
      actions: [
        IconButtonData(
          icon: Icons.check,
          onPressed: _handleSave,
          tooltip: context.appLocalizations.save,
        ),
      ],
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
