import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/widget_metrics.dart';
import 'package:fl_clash/views/profiles/add.dart';
import 'package:fl_clash/views/profiles/custom/custom.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'profile_detail.dart';
import 'row_card.dart';

const _usageGap = 8.0;

class ProfilesCard extends ConsumerWidget {
  const ProfilesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final profile = ref.watch(currentProfileProvider);
    final canSwitch = ref.watch(
      profilesProvider.select((profiles) => profiles.length > 1),
    );
    final colorScheme = context.colorScheme;
    final textScale = DashboardWidgetMetrics.textScaleOf(context);
    final padding = DashboardWidgetMetrics.paddingOf(context);
    return SizedBox(
      height: DashboardWidgetMetrics.heightOf(context, 1),
      child: CommonCard(
        radius: DashboardWidgetMetrics.radiusOf(context),
        onPressed: switch (profile) {
          null => () => showAddProfilePage(context),
          Profile(type: ProfileType.custom, :final id) =>
            () => showCustomProfileSheet(context, id),
          _ => () => showProfileDetailSheet(context),
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: globalState.measure.titleMediumHeight * textScale + 16,
              padding: padding.copyWith(bottom: 0),
              child: Row(
                children: [
                  GlyphIcon(
                    AppGlyphs.profiles,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TooltipText(
                      text: Text(
                        appLocalizations.profiles,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.sectionHeaderStyle,
                      ),
                    ),
                  ),
                  if (canSwitch) ...[
                    const SizedBox(width: 2),
                    AspectRatio(
                      aspectRatio: 1,
                      child: IconButton.filledTonal(
                        tooltip: appLocalizations.switchProfile,
                        padding: EdgeInsets.zero,
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          foregroundColor: colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () => _showPicker(context),
                        icon: GlyphIcon(AppGlyphs.picker, size: 16.ap, fill: 1),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: padding.copyWith(top: 0),
              height:
                  globalState.measure.bodyMediumHeight * textScale +
                  2 +
                  padding.bottom,
              alignment: AlignmentDirectional.centerStart,
              child: profile == null
                  ? Text(
                      appLocalizations.addProfile,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodyMedium?.toLight.adjustSize(
                        1,
                      ),
                    )
                  : _ProfileLine(profile: profile),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileLine extends StatelessWidget {
  const _ProfileLine({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final info = profile.subscriptionInfo;
    return Row(
      spacing: _usageGap,
      children: [
        Expanded(
          child: OverflowTooltipText(
            text: profile.realLabel,
            style: context.textTheme.bodyMedium?.adjustSize(1),
          ),
        ),
        if (info != null && info.total > 0) _UsageText(info: info),
      ],
    );
  }
}

class _UsageText extends StatelessWidget {
  const _UsageText({required this.info});

  final SubscriptionInfo info;

  @override
  Widget build(BuildContext context) {
    final used = info.upload + info.download;
    final percent = (used * 100 / info.total).clamp(0, 100).round();
    return Tooltip(
      message: '${used.traffic.show} / ${info.total.traffic.show}',
      child: Text(
        '$percent%',
        maxLines: 1,
        style: context.textTheme.labelMedium?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

void _showPicker(BuildContext context) {
  showSheet<void>(
    context: context,
    builder: (_) => const _ProfilePickerSheet(),
  );
}

class _ProfilePickerSheet extends ConsumerWidget {
  const _ProfilePickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(profilesProvider);
    final currentId = ref.watch(currentProfileIdProvider);
    void select(int? profileId) {
      if (profileId != null) {
        ref.read(currentProfileIdProvider.notifier).value = profileId;
      }
      Navigator.of(context).pop();
    }

    return CommonScaffold(
      title: context.appLocalizations.switchProfile,
      body: RadioGroup<int>(
        groupValue: currentId,
        onChanged: select,
        child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.fromLTRB(16, context.contentTopPadding, 16, 16),
          itemCount: profiles.length,
          itemBuilder: (context, index) {
            final profile = profiles[index];
            return ItemPositionProvider(
              position: ItemPosition.get(index, profiles.length),
              child: ListItem.radio(
                value: profile.id,
                onTap: () => select(profile.id),
                title: EmojiText(
                  profile.realLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
