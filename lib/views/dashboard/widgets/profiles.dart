import 'dart:math' as math;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/dashboard/layout.dart';
import 'package:fl_clash/views/dashboard/style.dart';
import 'package:fl_clash/views/profiles/add.dart';
import 'package:fl_clash/views/profiles/custom/custom.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'card.dart';
import 'profile_detail.dart';

typedef _Usage = ({int used, int total, double share});

_Usage? _usageOf(Profile? profile) {
  final info = profile?.subscriptionInfo;
  if (info == null || info.total <= 0) {
    return null;
  }
  final used = info.upload + info.download;
  return (
    used: used,
    total: info.total,
    share: (used / info.total).clamp(0.0, 1.0).toDouble(),
  );
}

DateTime? _expiryOf(Profile? profile) {
  final expire = profile?.subscriptionInfo?.expire ?? 0;
  return expire > 0 ? DateTime.fromMillisecondsSinceEpoch(expire * 1000) : null;
}

int _daysLeft(DateTime expiry) =>
    math.max(0, expiry.difference(DateTime.now()).inDays);

String _expiryText(BuildContext context, DateTime expiry) =>
    context.appLocalizations.profileExpiresIn(expiry.show, _daysLeft(expiry));

void _openProfile(BuildContext context, Profile? profile) {
  switch (profile) {
    case null:
      showAddProfilePage(context);
    case Profile(type: ProfileType.custom, :final id):
      showCustomProfileSheet(context, id);
    case _:
      showProfileDetailSheet(context);
  }
}

const _nearlyUsedShare = 0.9;

String _percentOf(double share) => '${(share * 100).round()}%';

String _sourceOf(BuildContext context, ProfileType type) => switch (type) {
  ProfileType.url => context.appLocalizations.remote,
  ProfileType.file => context.appLocalizations.local,
  ProfileType.custom => context.appLocalizations.custom,
};

class ProfilesCard extends ConsumerWidget {
  const ProfilesCard({super.key});

  static const _soonDays = 7;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final density = DashboardDensityScope.of(context);
    final mobile = !density.isDesktop;
    final compact = density.isCompact;
    final appLocalizations = context.appLocalizations;
    final profile = ref.watch(currentProfileProvider);
    final switchable = ref.watch(
      profilesProvider.select((profiles) => profiles.length > 1),
    );
    final usage = _usageOf(profile);
    final expiry = _expiryOf(profile);
    final updatedAt = profile?.lastUpdateDate;
    final label = DashboardText.label(context);
    final figure = mobile
        ? AppTextStyle.title3
        : (compact ? AppTextStyle.callout : AppTextStyle.headline);
    final name = mobile || !compact
        ? AppTextStyle.headline
        : AppTextStyle.callout;
    final endText = switch ((profile, expiry)) {
      (_, final expiry?) => appLocalizations.profileDaysLeft(_daysLeft(expiry)),
      (final profile?, null) => _sourceOf(context, profile.type),
      _ => null,
    };
    final Widget? end = switch ((endText, expiry)) {
      (final text?, final expiry?) => Tooltip(
        message: _expiryText(context, expiry),
        child: Text(
          text,
          maxLines: 1,
          style: _daysLeft(expiry) <= _soonDays
              ? label.copyWith(color: DashboardColors.of(context).warn)
              : label,
        ),
      ),
      (final text?, null) => Text(text, maxLines: 1, style: label),
      _ => null,
    };
    final sync = profile != null && profile.type == ProfileType.url
        ? _SyncButton(profile: profile)
        : null;
    final nameRow = Row(
      children: [
        Flexible(
          child: EmojiText(
            profile?.realLabel ?? appLocalizations.addProfile,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: name.of(context, emphasized: true),
          ),
        ),
        if (profile != null && switchable)
          SizedBox(
            height: name.leading,
            child: DashboardIconButton(
              glyph: AppGlyphs.swap,
              tooltip: appLocalizations.switchProfile,
              onPressed: () => showProfilesSheet(context),
            ),
          ),
      ],
    );
    return DashboardCard(
      semanticLabel: appLocalizations.profile,
      onTap: mobile || profile == null
          ? () => _openProfile(context, profile)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: mobile ? MainAxisSize.min : MainAxisSize.max,
        children: [
          DashboardCardHeader(
            glyph: AppGlyphs.profiles,
            title: appLocalizations.profile,
            chevron: mobile,
            trailing: [
              if (mobile)
                ?sync
              else
                Transform.translate(
                  offset: const Offset(8, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ?sync,
                      DashboardIconButton(
                        glyph: AppGlyphs.chevronForward,
                        tooltip: appLocalizations.details(
                          appLocalizations.profile,
                        ),
                        onPressed: () => _openProfile(context, profile),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: mobile ? 12 : 10),
          if (compact && end != null)
            DashboardCappedRow(spacing: _rowGap, start: nameRow, end: end)
          else
            nameRow,
          if (profile != null && !compact)
            LayoutBuilder(
              builder: (context, constraints) {
                final time = updatedAt?.getLastUpdateTimeDesc(context);
                final updated = time == null
                    ? null
                    : appLocalizations.profileUpdatedAt(time);
                final fits =
                    updated == null ||
                    _widthOf(updated, label) +
                            _rowGap +
                            _widthOf(endText ?? '', label) <=
                        constraints.maxWidth;
                return Row(
                  spacing: _rowGap,
                  children: [
                    Expanded(
                      child: Text(
                        (fits ? updated : time) ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: label,
                      ),
                    ),
                    ?end,
                  ],
                );
              },
            ),
          if (profile != null) ...[
            if (mobile) const SizedBox(height: 14) else const Spacer(),
            if (usage != null)
              _UsageMeter(usage: usage, figure: figure, gap: mobile ? 8 : 6)
            else
              _ConfigStats(figure: figure),
          ],
        ],
      ),
    );
  }
}

const _rowGap = 12.0;

double _widthOf(String text, TextStyle style) =>
    globalState.measure.computeTextSize(Text(text, style: style)).width;

class _SyncButton extends ConsumerWidget {
  const _SyncButton({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUpdating = ref.watch(isUpdatingProvider(profile.updatingKey));
    if (isUpdating) {
      return const SizedBox.square(
        dimension: 32,
        child: Center(child: CommonCircleLoading(size: 18)),
      );
    }
    return DashboardIconButton(
      glyph: AppGlyphs.sync,
      tooltip: context.appLocalizations.update,
      onPressed: () => syncProfile(ref, profile),
    );
  }
}

class _ConfigStats extends ConsumerStatefulWidget {
  const _ConfigStats({required this.figure});

  final AppTextStyle figure;

  @override
  ConsumerState<_ConfigStats> createState() => _ConfigStatsState();
}

class _ConfigStatsState extends ConsumerState<_ConfigStats>
    with ConfigCountsWatch<_ConfigStats> {
  @override
  Widget build(BuildContext context) {
    watchConfigCounts();
    final providers = ref.watch(providersProvider);
    final appLocalizations = context.appLocalizations;
    final stats = switch (configCounts) {
      final counts? => profileStatsOf(counts, providers),
      null => null,
    };
    final figure = DashboardText.figure(
      context,
      widget.figure,
    ).copyWith(letterSpacing: 0);
    final label = DashboardText.label(context);
    Widget item(int? value, String name) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (value != null)
          Text(dashboardCount(value), maxLines: 1, style: figure)
        else if (configCountsFailed)
          Text('—', maxLines: 1, style: figure)
        else
          SkeletonText(width: widget.figure.size * 1.5, style: figure),
        Text(name, maxLines: 1, style: label),
      ],
    );
    return LayoutBuilder(
      // The minimum width lets spaceBetween spread the row inside FittedBox.
      builder: (context, constraints) => FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 16,
            children: [
              item(stats?.groups, appLocalizations.proxyGroup),
              item(stats?.proxies, appLocalizations.proxies),
              item(stats?.rules, appLocalizations.rules),
            ],
          ),
        ),
      ),
    );
  }
}

class _UsageMeter extends StatelessWidget {
  const _UsageMeter({
    required this.usage,
    required this.figure,
    required this.gap,
  });

  final _Usage usage;
  final AppTextStyle figure;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final percent = DashboardText.figure(
              context,
              figure,
            ).copyWith(letterSpacing: 0);
            final unit = DashboardText.unit(context, AppTextStyle.footnote);
            final used = ' ${context.appLocalizations.usedShort}';
            final traffic =
                '${dashboardTraffic(usage.used)} / ${dashboardTraffic(usage.total)}';
            final trafficStyle = AppTextStyle.footnote
                .of(context)
                .toTabular
                .copyWith(color: context.colorScheme.onSurfaceVariant);
            final showUnit =
                _widthOf(_percentOf(usage.share), percent) +
                    _widthOf(used, unit) +
                    _rowGap +
                    _widthOf(traffic, trafficStyle) <=
                constraints.maxWidth;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              spacing: _rowGap,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: _percentOf(usage.share), style: percent),
                      if (showUnit) TextSpan(text: used, style: unit),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    traffic,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: trafficStyle,
                  ),
                ),
              ],
            );
          },
        ),
        SizedBox(height: gap),
        SizedBox(
          height: 12,
          child: CustomPaint(
            painter: _WavyProgressPainter(
              value: usage.share,
              active: usage.share >= _nearlyUsedShare
                  ? DashboardColors.of(context).warn
                  : context.colorScheme.primary,
              track: DashboardColors.of(context).tone2,
            ),
          ),
        ),
      ],
    );
  }
}

/// The M3 Expressive wavy linear indicator: a wave up to [value], a gap,
/// then a flat track ending in a stop dot.
class _WavyProgressPainter extends CustomPainter {
  const _WavyProgressPainter({
    required this.value,
    required this.active,
    required this.track,
  });

  static const _stroke = 4.0;
  static const _amplitude = 3.0;
  static const _wavelength = 12.0;
  static const _gap = 6.0;
  static const _stop = 4.0;

  final double value;
  final Color active;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final mid = size.height / 2;
    const start = _stroke / 2;
    final end = size.width - _stroke / 2;
    final split = start + (end - start) * value;
    final paint = Paint()
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    if (value > 0) {
      final wave = Path()..moveTo(start, mid);
      for (var x = start; x <= split; x += 1) {
        wave.lineTo(
          x,
          mid + _amplitude * math.sin((x - start) / _wavelength * 2 * math.pi),
        );
      }
      canvas.drawPath(wave, paint..color = active);
    }
    final trackStart = value > 0 ? split + _gap + _stroke : start;
    if (trackStart < end - _stop) {
      canvas.drawLine(
        Offset(trackStart, mid),
        Offset(end - _stop - _gap, mid),
        paint..color = track,
      );
    }
    if (value < 1) {
      canvas.drawCircle(
        Offset(end - _stop / 2, mid),
        _stop / 2,
        Paint()..color = active,
      );
    }
  }

  @override
  bool shouldRepaint(_WavyProgressPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.active != active ||
      oldDelegate.track != track;
}
