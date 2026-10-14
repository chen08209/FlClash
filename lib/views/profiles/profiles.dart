import 'dart:async';
import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/custom/custom.dart';
import 'package:fl_clash/views/profiles/extend/extend.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'add.dart';
import 'edit.dart';
import 'preview.dart';

const _infoGap = 4.0;

double get _profileItemHeight {
  final measure = globalState.measure;
  return max(
        SourceIcon.size,
        measure.titleMediumHeight + _infoGap + measure.bodySmallHeight,
      ) +
      2 * listRowVerticalPadding;
}

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

  Future<void> _updateProfiles(List<Profile> profiles) async {
    if (_isUpdating == true) {
      return;
    }
    _isUpdating = true;
    final appLocalizations = context.appLocalizations;
    final profilesAction = ref.read(profilesActionProvider.notifier);
    final List<UpdatingMessage> messages = [];
    final updateProfiles = profiles.map<Future>((profile) async {
      if (profile.type != ProfileType.url) return;
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
    dialogs.showFailures(messages);
    _isUpdating = false;
  }

  List<IconButtonData> _buildActions(List<Profile> profiles) {
    return profiles.isNotEmpty
        ? [
            IconButtonData(
              glyph: AppGlyphs.sync,
              onPressed: () {
                _updateProfiles(profiles);
              },
              tooltip: context.appLocalizations.update,
            ),
            IconButtonData(
              glyph: AppGlyphs.sort,
              onPressed: () {
                showSheet(
                  context: context,
                  builder: (_) {
                    return ReorderableProfilesSheet(profiles: profiles);
                  },
                );
              },
              tooltip: context.appLocalizations.profilesSort,
            ),
          ]
        : [];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, _) {
        final appLocalizations = context.appLocalizations;
        final isLoading = ref.watch(loadingProvider(LoadingTag.profiles));
        final state = ref.watch(profilesStateProvider);
        final spacing = cardSpacing;
        return CommonScaffold(
          isLoading: isLoading,
          title: appLocalizations.profiles,
          primaryAction: state.profiles.isEmpty
              ? null
              : IconButtonData(
                  glyph: AppGlyphs.addCircle,
                  onPressed: () => showAddProfilePage(context),
                  tooltip: appLocalizations.addProfile,
                ),
          iconActions: _buildActions(state.profiles),
          foldPrimaryAction: true,
          body: NullStatusSwitcher(
            isEmpty: state.profiles.isEmpty,
            nullStatus: NullStatus(
              label: appLocalizations.nullTip(appLocalizations.profiles),
              description: appLocalizations.nullProfileDesc,
              illustration: NullStatusIllustration.profile,
              action: ElasticButton(
                child: FilledButton.tonalIcon(
                  onPressed: () => showAddProfilePage(context),
                  icon: const GlyphIcon(AppGlyphs.addCircle, fill: 1),
                  label: Text(appLocalizations.addProfile),
                ),
              ),
            ),
            child: _ProfilesGrid(
              profiles: state.profiles,
              currentProfileId: state.currentProfileId,
              spacing: spacing,
            ),
          ),
        );
      },
    );
  }
}

class _ProfilesGrid extends ConsumerStatefulWidget {
  const _ProfilesGrid({
    required this.profiles,
    required this.currentProfileId,
    required this.spacing,
  });

  final List<Profile> profiles;
  final int? currentProfileId;
  final double spacing;

  @override
  ConsumerState<_ProfilesGrid> createState() => _ProfilesGridState();
}

class _ProfilesGridState extends ConsumerState<_ProfilesGrid> {
  static const _horizontalPadding = 16.0;

  late final ScrollController _controller;
  var _revealed = false;

  @override
  void initState() {
    super.initState();
    _controller = sheetScrollController(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_revealed || !PageActivityScope.isActiveOf(context)) {
      return;
    }
    _revealed = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _revealSelected());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  EdgeInsets get _padding => EdgeInsets.only(
    left: _horizontalPadding,
    right: _horizontalPadding,
    top: context.contentTopPadding,
    bottom: 16 + BottomInsetScope.of(context),
  );

  int _columnsFor(double width) => getProfilesColumns(
    width - _horizontalPadding * 2,
    spacing: widget.spacing,
    minItemWidth: profileItemMinWidth.ap,
  );

  void _revealSelected() {
    if (!mounted || !_controller.hasClients) {
      return;
    }
    final index = widget.profiles.indexWhere(
      (profile) => profile.id == widget.currentProfileId,
    );
    if (index == -1) {
      return;
    }
    final position = _controller.position;
    final padding = _padding;
    final height = _profileItemHeight;
    final row = index ~/ _columnsFor(context.size!.width);
    final atTop = row * (height + widget.spacing);
    final atBottom =
        atTop + padding.vertical + height - position.viewportDimension;
    if (position.pixels >= atBottom && position.pixels <= atTop) {
      return;
    }
    _controller.jumpTo(
      ((atTop + atBottom) / 2).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profiles = widget.profiles;
    return LayoutBuilder(
      builder: (_, constraints) {
        return GridView.builder(
          key: profilesStoreKey,
          controller: _controller,
          padding: _padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _columnsFor(constraints.maxWidth),
            mainAxisSpacing: widget.spacing,
            crossAxisSpacing: widget.spacing,
            mainAxisExtent: _profileItemHeight,
          ),
          itemCount: profiles.length,
          itemBuilder: (context, index) {
            final profile = profiles[index];
            return ProfileItem(
              key: ValueKey(profile.id),
              profile: profile,
              groupValue: widget.currentProfileId,
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
    final users = await profilesAction.providerUsers(profile);
    final res = await dialogs.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(
        text: users.isEmpty
            ? appLocalizations.deleteTip(appLocalizations.profile)
            : appLocalizations.providerInUse(
                profile.realLabel,
                users.map((item) => item.realLabel).join(', '),
              ),
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
    if (profile.type != ProfileType.url) return;
    await globalState.loadingRun(() async {
      await ref
          .read(profilesActionProvider.notifier)
          .updateProfile(profile, showLoading: true);
    }, tag: LoadingTag.profiles);
  }

  void _handleShowEditExtendPage(BuildContext context) {
    showExtend(
      context,
      builder: (context) => EditProfileView(profile: profile, context: context),
    );
  }

  SubscriptionInfo? get _subscriptionInfo =>
      profile.type == ProfileType.url ? profile.subscriptionInfo : null;

  Widget? _buildTraffic(BuildContext context) {
    final info = _subscriptionInfo;
    if (info?.usage == null) {
      return null;
    }
    final used = info!.upload + info.download;
    return Text(
      '${used.traffic.show} / ${info.total.traffic.show}',
      style: context.textTheme.bodySmall?.toLighter,
    );
  }

  Widget _buildTrailing(BuildContext context, {required bool isUpdating}) {
    return AnimatedSwitcher(
      duration: context.motionDuration(commonDuration),
      layoutBuilder: (currentChild, previousChildren) => Stack(
        alignment: AlignmentDirectional.centerEnd,
        children: [...previousChildren, ?currentChild],
      ),
      child: isUpdating
          ? const SizedBox.square(
              key: ValueKey('updating'),
              dimension: 24,
              child: CommonCircleLoading(),
            )
          : LastUpdateTimeText(
              key: const ValueKey('lastUpdate'),
              lastUpdateDate: profile.lastUpdateDate,
              style: context.textTheme.bodySmall?.toLighter,
              compact: true,
            ),
    );
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
    BaseNavigator.push(context, ExtendView(profileId: id));
  }

  void _handlePushCustomProfilePage(BuildContext context, int id) {
    BaseNavigator.push(context, CustomProfileView(profileId: id));
  }

  void _handleEdit(BuildContext context) {
    if (profile.type == ProfileType.custom) {
      _handlePushCustomProfilePage(context, profile.id);
    } else {
      _handleShowEditExtendPage(context);
    }
  }

  List<CommonPopupMenuItem> _menuItems(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final isUrl = profile.type == ProfileType.url;
    final isCustom = profile.type == ProfileType.custom;
    return [
      CommonPopupMenuItem(
        glyph: AppGlyphs.edit,
        label: appLocalizations.edit,
        onPressed: () => _handleEdit(context),
      ),
      if (isCustom) ...[
        CommonPopupMenuItem(
          glyph: AppGlyphs.textShort,
          label: appLocalizations.rename,
          onPressed: () {
            renameProfile(context, ref, profile);
          },
        ),
        CommonPopupMenuItem(
          glyph: AppGlyphs.eye,
          label: appLocalizations.finalConfig,
          onPressed: () {
            _handlePreview(context);
          },
        ),
      ] else
        CommonPopupMenuItem(
          glyph: AppGlyphs.puzzle,
          label: appLocalizations.extend,
          onPressed: () {
            _handlePushGenProfilePage(context, profile.id);
          },
        ),
      if (isUrl)
        CommonPopupMenuItem(
          glyph: AppGlyphs.sync,
          label: appLocalizations.sync,
          onPressed: () {
            updateProfile(ref);
          },
        ),
      if (!isCustom)
        CommonPopupMenuItem(
          glyph: AppGlyphs.moreCircle,
          label: appLocalizations.more,
          subItems: [
            CommonPopupMenuItem(
              glyph: AppGlyphs.eye,
              label: appLocalizations.finalConfig,
              onPressed: () {
                _handlePreview(context);
              },
            ),
            if (isUrl)
              CommonPopupMenuItem(
                glyph: AppGlyphs.copy,
                label: appLocalizations.copyLink,
                onPressed: () {
                  _handleCopyLink(context);
                },
              ),
            CommonPopupMenuItem(
              glyph: AppGlyphs.export,
              label: appLocalizations.exportFile,
              onPressed: () {
                _handleExportFile(context);
              },
            ),
          ],
        ),
      CommonPopupMenuItem(
        danger: true,
        glyph: AppGlyphs.delete,
        label: appLocalizations.delete,
        onPressed: () {
          _handleDeleteProfile(context, ref);
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUpdating = ref.watch(isUpdatingProvider(profile.updatingKey));
    final subscriptionInfo = _subscriptionInfo;
    final usage = subscriptionInfo?.usage;
    return ContextMenuRegion(
      menuItems: isUpdating ? null : _menuItems(context, ref),
      child: CommonCard(
        enterActionsOnRight: true,
        radius: AppCorner.xl,
        isSelected: profile.id == groupValue,
        onPressed: () {
          onChanged(profile.id);
        },
        child: ListItem(
          key: Key(profile.id.toString()),
          horizontalTitleGap: 12,
          minTileHeight: _profileItemHeight,
          minVerticalPadding: listRowVerticalPadding,
          padding: const EdgeInsets.only(left: SourceIcon.inset, right: 16),
          leading: SourceIcon(
            kind: switch (profile.type) {
              ProfileType.url => SourceKind.remote,
              ProfileType.file => SourceKind.file,
              ProfileType.custom => SourceKind.custom,
            },
            usage: usage,
            tooltip: context.appLocalizations.subscriptionInfo,
            onPressed: usage == null
                ? null
                : () => _handleShowSubscriptionInfo(context),
          ),
          trailing: _buildTrailing(context, isUpdating: isUpdating),
          title: _ProfileCardTitle(
            profile: profile,
            expire: subscriptionInfo?.expireDate,
            info: _buildTraffic(context),
          ),
        ),
      ),
    );
  }
}

class _ProfileCardTitle extends StatelessWidget {
  const _ProfileCardTitle({
    required this.profile,
    required this.expire,
    required this.info,
  });

  final Profile profile;
  final DateTime? expire;
  final Widget? info;

  @override
  Widget build(BuildContext context) {
    final title = ChipTitle(
      title: profile.realLabel,
      expire: expire,
      style: context.textTheme.titleMedium,
    );
    final info = this.info;
    if (info == null) {
      return title;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title,
        const SizedBox(height: _infoGap),
        DefaultTextStyle.merge(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          child: info,
        ),
      ],
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
        contentPadding: const EdgeInsets.only(left: 16),
        trailing: SortHandle(index: index),
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
    return CommonScaffold(
      actions: [
        AppBarActionButton(
          data: IconButtonData(
            glyph: AppGlyphs.check,
            onPressed: _handleSave,
            tooltip: context.appLocalizations.save,
          ),
        ),
      ],
      body: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: ReorderableListView.builder(
          buildDefaultDragHandles: false,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ).copyWith(top: context.contentTopPadding),
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
