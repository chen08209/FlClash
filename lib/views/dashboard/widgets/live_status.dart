import 'dart:async';
import 'dart:math' as math;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/mitm.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prism_ui/prism_ui.dart';

import 'live_status_deck.dart';
import 'status_badge.dart';

/// What is happening now and still needs the user: one card each in the deck,
/// in this order of importance.
sealed class LiveStatus {
  const LiveStatus({this.preview});

  /// Set on a card the developer page shows, which may share its kind with
  /// another and whose actions do nothing.
  final String? preview;

  Object get key => preview ?? runtimeType;
}

/// The core's own phase. Starting and stopped lead the deck; a running core
/// is only there to reach its restart, so it comes last.
final class CoreLiveStatus extends LiveStatus {
  const CoreLiveStatus(this.phase, {super.preview});

  final CoreStatus phase;
}

final class WarningsStatus extends LiveStatus {
  const WarningsStatus(this.items, {super.preview});

  final List<ConfigWarning> items;
}

final class UpdateStatus extends LiveStatus {
  const UpdateStatus(this.download, {super.preview});

  final UpdateDownload download;
}

final class MitmConsentStatus extends LiveStatus {
  const MitmConsentStatus(this.names, {super.preview});

  final List<String> names;
}

bool _isRunningCore(LiveStatus status) =>
    status is CoreLiveStatus && status.phase == CoreStatus.connected;

/// [separateCore] is a core in its own process, which the user can watch
/// start and restart; one inside the app only ever shows having stopped.
List<LiveStatus> watchLiveStatuses(
  WidgetRef ref, {
  required bool separateCore,
}) {
  final core = ref.watch(heldCoreStatusProvider);
  final warnings = ref.watch(liveConfigWarningsProvider);
  final download = ref.watch(updateDownloadStateProvider);
  final awaitingConsent = ref.watch(mitmModulesToAgreeProvider);
  return [
    if (core == CoreStatus.disconnected ||
        separateCore && core == CoreStatus.connecting)
      CoreLiveStatus(core),
    if (download is UpdateReady) UpdateStatus(download),
    if (download is UpdateDownloading) UpdateStatus(download),
    if (awaitingConsent.isNotEmpty)
      MitmConsentStatus([for (final module in awaitingConsent) module.name]),
    if (warnings.isNotEmpty) WarningsStatus(warnings),
    if (separateCore && core == CoreStatus.connected)
      const CoreLiveStatus(CoreStatus.connected),
  ];
}

/// Opens the deck on one card of every kind, from the developer page.
void showLiveStatusPreview(BuildContext context) {
  final navigator = Navigator.of(context);
  final overlay = navigator.overlay!.context.findRenderObject()! as RenderBox;
  final top = MediaQuery.paddingOf(context).top;
  final anchor = Rect.fromLTWH(overlay.size.width - 60, top + 8, 44, 44);
  const tag = 'v9.9.9';
  const mb = 1024 * 1024;
  const warnings = [
    ConfigWarning(
      level: ConfigWarningLevel.warning,
      path: 'proxies[12]',
      message: 'masque is not supported, the proxy was removed',
    ),
    ConfigWarning(
      level: ConfigWarningLevel.warning,
      path: 'sniffer.override',
      message: 'unknown key',
    ),
    ConfigWarning(
      level: ConfigWarningLevel.warning,
      path: 'rules[48]',
      message: 'the rule names a missing group and goes to DIRECT instead',
    ),
    ConfigWarning(
      level: ConfigWarningLevel.warning,
      path: 'tun.stack',
      message: 'mixed runs as the userspace stack',
    ),
    ConfigWarning(
      level: ConfigWarningLevel.warning,
      path: 'external-ui',
      message: 'key is not supported by this core and is ignored',
    ),
  ];
  unawaited(
    navigator.push(
      LiveStatusRoute(
        anchor: anchor,
        separateCore: true,
        barrierColor: context.colorScheme.alertScrim,
        barrierLabel: context.appLocalizations.close,
        statuses: const [
          CoreLiveStatus(CoreStatus.disconnected, preview: 'stopped'),
          CoreLiveStatus(CoreStatus.connecting, preview: 'starting'),
          UpdateStatus(UpdateReady(tag, ''), preview: 'ready'),
          UpdateStatus(
            UpdateDownloading(tag, received: 18 * mb, total: 43 * mb),
            preview: 'downloading',
          ),
          MitmConsentStatus(['Ads', 'Scripts'], preview: 'consent'),
          WarningsStatus(warnings, preview: 'warnings'),
          CoreLiveStatus(CoreStatus.connected, preview: 'running'),
        ],
      ),
    ),
  );
}

/// The dashboard's bar button: it wears the most important live status and
/// counts the rest. A running core alone shrinks it to a check, and with an
/// in-app core it is gone while nothing is happening.
class LiveStatusButton extends ConsumerWidget {
  const LiveStatusButton({super.key, this.separateCore});

  /// Whether the core runs in its own process; the build's core when null.
  final bool? separateCore;

  bool get _separateCore => separateCore ?? coreLib == null;

  void _open(BuildContext context) {
    final navigator = Navigator.of(context);
    final box = context.findRenderObject()! as RenderBox;
    final overlay = navigator.overlay!.context.findRenderObject()! as RenderBox;
    final anchor = box.localToGlobal(Offset.zero, ancestor: overlay) & box.size;
    unawaited(
      navigator.push(
        LiveStatusRoute(
          anchor: anchor,
          separateCore: _separateCore,
          barrierColor: context.colorScheme.alertScrim,
          barrierLabel: context.appLocalizations.close,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statuses = watchLiveStatuses(ref, separateCore: _separateCore);
    final top = statuses.firstOrNull;
    return FadeScaleBox(
      alignment: Alignment.centerRight,
      child: switch (top) {
        null => const SizedBox.shrink(),
        _ when _isRunningCore(top) => _RunningCoreButton(
          key: const ValueKey(CoreStatus.connected),
          onPressed: () => _open(context),
        ),
        _ => _LiveStatusPill(
          key: ValueKey(_pillKindOf(top)),
          status: top,
          count: statuses.where((it) => !_isRunningCore(it)).length,
          onPressed: () => _open(context),
        ),
      },
    );
  }
}

Object _pillKindOf(LiveStatus status) => switch (status) {
  UpdateStatus(download: UpdateReady()) => UpdateReady,
  CoreLiveStatus(:final phase) => phase,
  _ => status.key,
};

class _RunningCoreButton extends StatelessWidget {
  const _RunningCoreButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return IconButton.filled(
      tooltip: context.appLocalizations.liveStatus,
      style: statusBadgeStyle(
        context,
        background: colorScheme.successContainer,
        foreground: colorScheme.onSuccessContainer,
      ),
      onPressed: onPressed,
      icon: const GlyphIcon(AppGlyphs.check, fill: 1),
    );
  }
}

/// The most important status as its glyph and one number: an update's
/// progress, else a count of all the statuses when there are others, or of
/// the warnings when they are alone. The cards say the rest.
class _LiveStatusPill extends StatelessWidget {
  const _LiveStatusPill({
    super.key,
    required this.status,
    required this.count,
    required this.onPressed,
  });

  final LiveStatus status;
  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final (fill, content) = switch (status) {
      CoreLiveStatus(phase: CoreStatus.disconnected) => (
        colorScheme.errorContainer,
        colorScheme.onErrorContainer,
      ),
      WarningsStatus() => (
        colorScheme.warningContainer,
        colorScheme.onWarningContainer,
      ),
      UpdateStatus(download: UpdateReady()) => (
        colorScheme.successContainer,
        colorScheme.onSuccessContainer,
      ),
      MitmConsentStatus() => (
        colorScheme.warningContainer,
        colorScheme.onWarningContainer,
      ),
      _ => (null, null),
    };
    final label = switch (status) {
      CoreLiveStatus(phase: CoreStatus.disconnected) =>
        appLocalizations.coreStopped,
      CoreLiveStatus() => appLocalizations.connecting,
      WarningsStatus() => appLocalizations.configWarnings,
      UpdateStatus(download: UpdateReady()) => appLocalizations.updateReady,
      UpdateStatus() => appLocalizations.downloadingUpdate,
      MitmConsentStatus() => appLocalizations.mitmModulesTurnedOff,
    };
    final iconSize = globalState.measure.textHeight(AppTextStyle.subheadline);
    final icon = SizedBox.square(
      dimension: iconSize,
      child: switch (status) {
        CoreLiveStatus(phase: CoreStatus.disconnected) => const GlyphIcon(
          AppGlyphs.error,
          fill: 1,
        ),
        WarningsStatus() => const GlyphIcon(AppGlyphs.warning, fill: 1),
        CoreLiveStatus() => Builder(
          builder: (context) =>
              ActivityIndicator(color: IconTheme.of(context).color),
        ),
        UpdateStatus(download: UpdateReady()) => const GlyphIcon(
          AppGlyphs.checkCircle,
          fill: 1,
        ),
        UpdateStatus(
          download: UpdateDownloading(:final received, :final total),
        ) =>
          _PillProgressRing(value: total > 0 ? received / total : null),
        MitmConsentStatus() => const GlyphIcon(AppGlyphs.puzzle, fill: 1),
      },
    );
    final shown = switch (status) {
      UpdateStatus(download: UpdateReady()) => '100%',
      UpdateStatus(
        download: UpdateDownloading(:final received, :final total),
      ) =>
        total > 0 ? '${received * 100 ~/ total}%' : received.traffic.show,
      _ when count > 1 => '$count',
      WarningsStatus(:final items) => '${items.length}',
      _ => null,
    };
    final style = statusBadgeStyle(
      context,
      background: fill,
      foreground: content,
    );
    return Semantics(
      label: shown == null ? label : '$label, $shown',
      excludeSemantics: true,
      button: true,
      child: shown != null
          ? Tooltip(
              message: appLocalizations.liveStatus,
              child: FilledButton.icon(
                onPressed: onPressed,
                style: style,
                icon: icon,
                label: Text(
                  shown,
                  style: const TextStyle(
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            )
          : IconButton.filled(
              tooltip: appLocalizations.liveStatus,
              style: style,
              onPressed: onPressed,
              icon: icon,
            ),
    );
  }
}

class _PillProgressRing extends StatelessWidget {
  const _PillProgressRing({required this.value});

  final double? value;

  @override
  Widget build(BuildContext context) {
    final color = IconTheme.of(context).color ?? context.colorScheme.onPrimary;
    return CustomPaint(
      painter: _RingPainter(value: value ?? 0, color: color),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.shortestSide * 0.14;
    final rect = (Offset.zero & size).deflate(stroke / 2 + 1);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.3);
    canvas.drawOval(rect, paint);
    if (value > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * value.clamp(0, 1),
        false,
        paint..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.color != color;
}
