import 'dart:async';
import 'dart:math' as math;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prism_ui/prism_ui.dart';

import 'live_status_deck.dart';

/// What is happening now and still needs the user: one card each in the deck,
/// in this order of importance.
sealed class LiveStatus {
  const LiveStatus();

  Object get key;
}

/// The core's own phase. Starting and stopped lead the deck; a running core
/// is only there to reach its restart, so it comes last.
final class CoreLiveStatus extends LiveStatus {
  const CoreLiveStatus(this.phase);

  final CoreStatus phase;

  @override
  Object get key => CoreLiveStatus;
}

final class UpdateStatus extends LiveStatus {
  const UpdateStatus(this.download);

  final UpdateDownload download;

  @override
  Object get key => UpdateStatus;
}

final class ResourcesStatus extends LiveStatus {
  const ResourcesStatus(this.items);

  final List<UpdatingResource> items;

  @override
  Object get key => ResourcesStatus;
}

typedef UpdatingResource = ({String name, bool isProfile});

bool _isRunningCore(LiveStatus status) =>
    status is CoreLiveStatus && status.phase == CoreStatus.connected;

List<UpdatingResource> _updatingResources(
  Set<String> keys,
  List<Profile> profiles,
) {
  final profileNames = {
    for (final profile in profiles) profile.updatingKey: profile.realLabel,
  };
  final geoNames = {
    for (final resource in GeoResource.values) resource.updatingKey: resource,
  };
  return [
    for (final key in keys)
      if (profileNames[key] case final name?)
        (name: name, isProfile: true)
      else if (geoNames[key] case final resource?)
        (name: resource.name, isProfile: false)
      else if (key.startsWith('provider_'))
        (name: key.substring('provider_'.length), isProfile: false),
  ];
}

/// [separateCore] is a core in its own process, which the user can watch
/// start and restart; one inside the app only ever shows having stopped.
List<LiveStatus> watchLiveStatuses(
  WidgetRef ref, {
  required bool separateCore,
  bool holdStarting = false,
}) {
  var core = ref.watch(coreStatusProvider);
  if (holdStarting && core == CoreStatus.connected) {
    core = CoreStatus.connecting;
  }
  final download = ref.watch(updateDownloadStateProvider);
  final keys = ref.watch(updatingKeysProvider);
  final resources = keys.isEmpty
      ? const <UpdatingResource>[]
      : _updatingResources(keys, ref.watch(profilesProvider));
  return [
    if (core == CoreStatus.disconnected ||
        separateCore && core == CoreStatus.connecting)
      CoreLiveStatus(core),
    if (download is UpdateReady) UpdateStatus(download),
    if (download is UpdateDownloading) UpdateStatus(download),
    if (resources.isNotEmpty) ResourcesStatus(resources),
    if (separateCore && core == CoreStatus.connected)
      const CoreLiveStatus(CoreStatus.connected),
  ];
}

/// The dashboard's bar button: it wears the most important live status and
/// counts the rest. A running core alone shrinks it to a check, and with an
/// in-app core it is gone while nothing is happening.
class LiveStatusButton extends ConsumerStatefulWidget {
  const LiveStatusButton({super.key, this.separateCore});

  /// Whether the core runs in its own process; the build's core when null.
  final bool? separateCore;

  @override
  ConsumerState<LiveStatusButton> createState() => _LiveStatusButtonState();
}

class _LiveStatusButtonState extends ConsumerState<LiveStatusButton> {
  // A fast restart would otherwise flash the spinner for a frame or two.
  static const _holdDuration = Duration(milliseconds: 600);

  Timer? _hold;

  bool get _separateCore => widget.separateCore ?? coreLib == null;

  @override
  void initState() {
    super.initState();
    ref.listenManual(coreStatusProvider, (_, next) {
      switch (next) {
        case CoreStatus.connecting:
          _hold ??= Timer(_holdDuration, () {
            if (mounted) setState(() => _hold = null);
          });
        case CoreStatus.disconnected:
          _hold?.cancel();
          _hold = null;
        case CoreStatus.connected:
          break;
      }
    });
  }

  @override
  void dispose() {
    _hold?.cancel();
    super.dispose();
  }

  void _open() {
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
  Widget build(BuildContext context) {
    final statuses = watchLiveStatuses(
      ref,
      separateCore: _separateCore,
      holdStarting: _hold != null,
    );
    final top = statuses.firstOrNull;
    return FadeScaleBox(
      alignment: Alignment.centerRight,
      child: switch (top) {
        null => const SizedBox.shrink(),
        _ when _isRunningCore(top) => _RunningCoreButton(
          key: const ValueKey(CoreStatus.connected),
          onPressed: _open,
        ),
        _ => _LiveStatusPill(
          key: ValueKey(_pillKindOf(top)),
          status: top,
          more: statuses.where((it) => !_isRunningCore(it)).length - 1,
          onPressed: _open,
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
    final fill = colorScheme.successContainer;
    final pane = TonalButtonTheme.glassOf(context)
        ? LiquidGlassStyle.tinted(colorScheme, fill)
        : null;
    return IconButton.filled(
      tooltip: context.appLocalizations.liveStatus,
      style: ButtonStyle.from(
        backgroundColor: pane == null ? fill : Colors.transparent,
        foregroundColor: colorScheme.onSuccessContainer,
        backgroundBuilder: pane == null
            ? null
            : LiquidGlass.buttonBackground((_) => pane),
        pressLook: PressLook.none,
      ),
      onPressed: onPressed,
      icon: const GlyphIcon(AppGlyphs.check, fill: 1),
    );
  }
}

class _LiveStatusPill extends StatelessWidget {
  const _LiveStatusPill({
    super.key,
    required this.status,
    required this.more,
    required this.onPressed,
  });

  final LiveStatus status;
  final int more;
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
      UpdateStatus(download: UpdateReady()) => (
        colorScheme.successContainer,
        colorScheme.onSuccessContainer,
      ),
      _ => (null, null),
    };
    final pane = TonalButtonTheme.glassOf(context) && fill != null
        ? LiquidGlassStyle.tinted(colorScheme, fill)
        : null;
    final iconSize = globalState.measure.textHeight(AppTextStyle.subheadline);
    final label = switch (status) {
      CoreLiveStatus(phase: CoreStatus.disconnected) =>
        appLocalizations.coreStopped,
      CoreLiveStatus() => appLocalizations.connecting,
      UpdateStatus(download: UpdateReady()) => appLocalizations.updateReady,
      UpdateStatus(
        download: UpdateDownloading(:final received, :final total),
      ) =>
        total > 0 ? '${received * 100 ~/ total}%' : received.traffic.show,
      ResourcesStatus() => appLocalizations.updatingResources,
    };
    return Tooltip(
      message: appLocalizations.liveStatus,
      child: FilledButton.icon(
        onPressed: onPressed,
        style: ButtonStyle.from(
          backgroundColor: pane == null ? fill : Colors.transparent,
          foregroundColor: content,
          backgroundBuilder: pane == null
              ? null
              : LiquidGlass.buttonBackground((_) => pane),
          pressLook: PressLook.none,
        ),
        icon: SizedBox.square(
          dimension: iconSize,
          child: switch (status) {
            CoreLiveStatus(phase: CoreStatus.disconnected) => const GlyphIcon(
              AppGlyphs.error,
              fill: 1,
            ),
            CoreLiveStatus() || ResourcesStatus() => ActivityIndicator(
              color: colorScheme.onPrimary,
            ),
            UpdateStatus(download: UpdateReady()) => const GlyphIcon(
              AppGlyphs.checkCircle,
              fill: 1,
            ),
            UpdateStatus(
              download: UpdateDownloading(:final received, :final total),
            ) =>
              _PillProgressRing(value: total > 0 ? received / total : null),
          },
        ),
        label: more > 0
            ? Builder(
                builder: (context) {
                  final color = DefaultTextStyle.of(context).style.color;
                  return Text.rich(
                    TextSpan(
                      text: label,
                      children: [
                        TextSpan(
                          text: ' +$more',
                          style: TextStyle(
                            color: color?.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            : Text(label),
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
