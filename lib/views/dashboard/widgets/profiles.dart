import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/widget_metrics.dart';
import 'package:fl_clash/views/profiles/add.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'row_card.dart';

const _columnGap = 8.0;
const _barWidth = 6.0;

class ProfilesCard extends ConsumerStatefulWidget {
  const ProfilesCard({super.key});

  @override
  ConsumerState<ProfilesCard> createState() => _ProfilesCardState();
}

class _ProfilesCardState extends ConsumerState<ProfilesCard> {
  final _controller = ScrollController();
  var _revealedCurrent = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _revealCurrent(List<Profile> profiles, double itemExtent) {
    if (_revealedCurrent) {
      return;
    }
    _revealedCurrent = true;
    final currentId = ref.read(currentProfileIdProvider);
    final index = profiles.indexWhere((profile) => profile.id == currentId);
    if (index <= 0) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_controller.hasClients) {
        return;
      }
      _controller.jumpTo(
        min(index * itemExtent, _controller.position.maxScrollExtent),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(profilesProvider);
    final currentId = ref.watch(currentProfileIdProvider);
    final appLocalizations = context.appLocalizations;
    return RowCardFrame(
      child: RowCardPane(
        header: InfoHeader(
          padding: DashboardWidgetMetrics.paddingOf(
            context,
          ).copyWith(bottom: 0),
          info: Info(
            label: appLocalizations.profiles,
            glyph: AppGlyphs.profiles,
          ),
        ),
        body: profiles.isEmpty
            ? RowCardEmpty(
                illustration: NullStatusIllustration.profile,
                action: FilledButton.tonalIcon(
                  onPressed: showAddProfilePage,
                  icon: const GlyphIcon(AppGlyphs.add, fill: 1),
                  label: Text(appLocalizations.addProfile),
                ),
              )
            : RowCardSlots(
                rowExtent: rowCardLineExtentOf(context),
                builder: (_, rowHeight, spacing) {
                  final itemExtent = rowHeight + spacing;
                  _revealCurrent(profiles, itemExtent);
                  return ListView.builder(
                    controller: _controller,
                    padding: EdgeInsets.zero,
                    itemExtent: itemExtent,
                    itemCount: profiles.length,
                    itemBuilder: (_, index) {
                      final profile = profiles[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: spacing),
                        child: _ProfileRow(
                          profile: profile,
                          isSelected: profile.id == currentId,
                          onTap: () {
                            ref.read(currentProfileIdProvider.notifier).value =
                                profile.id;
                          },
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.profile,
    required this.isSelected,
    required this.onTap,
  });

  final Profile profile;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final foreground = isSelected
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurface;
    final info = profile.subscriptionInfo;
    final traffic = info != null && info.total > 0 ? info : null;
    return RowCardPill(
      color: isSelected ? colorScheme.secondaryContainer : null,
      edge: _UsageBar(info: traffic),
      trailingGlyph: false,
      onTap: onTap,
      child: _Line(
        leading: profile.realLabel,
        leadingStyle: textTheme.bodyMedium?.copyWith(color: foreground),
        trailing: traffic != null ? _expireOf(context, traffic) : null,
        trailingStyle: textTheme.labelSmall?.copyWith(
          color: foreground.opacity60,
        ),
      ),
    );
  }
}

class _UsageBar extends StatelessWidget {
  const _UsageBar({required this.info});

  final SubscriptionInfo? info;

  @override
  Widget build(BuildContext context) {
    final info = this.info;
    final colorScheme = context.colorScheme;
    final used = info == null ? 0 : info.upload + info.download;
    final progress = info == null
        ? 0.0
        : (used / info.total).clamp(0.0, 1.0).toDouble();
    final bar = Container(
      width: _barWidth.mAp,
      alignment: Alignment.bottomCenter,
      color: colorScheme.primary.opacity15,
      child: FractionallySizedBox(
        heightFactor: progress,
        widthFactor: 1,
        child: ColoredBox(color: colorScheme.primary),
      ),
    );
    if (info == null) {
      return bar;
    }
    return Tooltip(
      message:
          '${used.traffic.show} / ${info.total.traffic.show}'
          ' (${(progress * 100).round()}%)',
      child: bar,
    );
  }
}

String _expireOf(BuildContext context, SubscriptionInfo info) {
  if (info.expire == 0) {
    return context.appLocalizations.infiniteTime;
  }
  return DateTime.fromMillisecondsSinceEpoch(info.expire * 1000).show;
}

/// Shows [trailing] only when it fits beside the whole of [leading].
class _Line extends StatelessWidget {
  const _Line({
    required this.leading,
    this.leadingStyle,
    this.trailing,
    this.trailingStyle,
  });

  final String leading;
  final TextStyle? leadingStyle;
  final String? trailing;
  final TextStyle? trailingStyle;

  @override
  Widget build(BuildContext context) {
    final trailing = this.trailing;
    return LayoutBuilder(
      builder: (_, constraints) {
        final measure = globalState.measure;
        final fits =
            trailing != null &&
            measure.computeTextSize(Text(leading, style: leadingStyle)).width +
                    _columnGap +
                    measure
                        .computeTextSize(Text(trailing, style: trailingStyle))
                        .width <=
                constraints.maxWidth;
        return Row(
          spacing: _columnGap,
          children: [
            Expanded(
              child: OverflowTooltipText(text: leading, style: leadingStyle),
            ),
            if (fits) Text(trailing, maxLines: 1, style: trailingStyle),
          ],
        );
      },
    );
  }
}
