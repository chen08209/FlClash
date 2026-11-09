import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/dashboard/style.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'card.dart';
import 'package:prism_ui/prism_ui.dart';

String _progressText(UpdateDownloading download) {
  final received = download.received.traffic.show;
  if (download.total <= 0) {
    return received;
  }
  return '$received / ${download.total.traffic.show}';
}

String _readyTip(AppLocalizations appLocalizations) => system.isWindows
    ? '${appLocalizations.updateReadyTip}\n${appLocalizations.updateRestartTip}'
    : appLocalizations.updateReadyTip;

/// The phone dashboard's top card while an update downloads or waits. It keeps
/// the last download on screen as it leaves, and takes its own gap so the cards
/// below close up with it.
class UpdateStatusSlot extends ConsumerStatefulWidget {
  const UpdateStatusSlot({super.key, required this.gap});

  final double gap;

  @override
  ConsumerState<UpdateStatusSlot> createState() => _UpdateStatusSlotState();
}

class _UpdateStatusSlotState extends ConsumerState<UpdateStatusSlot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _curve;
  UpdateDownload? _download;

  @override
  void initState() {
    super.initState();
    _download = ref.read(updateDownloadStateProvider);
    _controller = AnimationController(
      vsync: this,
      duration: commonDuration,
      value: _download == null ? 0 : 1,
    );
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    ref.listenManual(updateDownloadStateProvider, (_, next) => _follow(next));
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _follow(UpdateDownload? next) async {
    if (next != null) {
      setState(() => _download = next);
      if (context.disableAnimations) {
        _controller.value = 1;
      } else {
        unawaited(_controller.forward());
      }
      return;
    }
    if (context.disableAnimations) {
      _controller.value = 0;
    } else {
      await _controller.reverse().orCancel.catchError((_) {});
    }
    if (mounted && _controller.isDismissed) {
      setState(() => _download = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final download = _download;
    if (download == null) {
      return const SizedBox.shrink();
    }
    // Not SizeTransition: its clip would cut the card's shadow at rest.
    return AnimatedBuilder(
      animation: _curve,
      builder: (_, child) => Align(
        alignment: Alignment.topCenter,
        heightFactor: _curve.value,
        child: child,
      ),
      child: FadeTransition(
        opacity: _curve,
        child: Padding(
          padding: EdgeInsets.only(bottom: widget.gap),
          child: RepaintBoundary(child: _UpdateStatusCard(download)),
        ),
      ),
    );
  }
}

class _UpdateStatusCard extends ConsumerWidget {
  const _UpdateStatusCard(this.download);

  final UpdateDownload download;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final action = ref.read(commonActionProvider.notifier);
    final ready = download is UpdateReady;
    return DashboardCard(
      onTap: ready ? () => unawaited(action.installUpdate()) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          DashboardCardHeader(
            glyph: ready ? AppGlyphs.checkCircle : AppGlyphs.cloudDownload,
            title: ready
                ? appLocalizations.updateReady
                : appLocalizations.downloadingUpdate,
            leading: [DashboardChip(label: download.tag)],
            trailing: [
              Transform.translate(
                offset: const Offset(8, 0),
                child: DashboardIconButton(
                  glyph: AppGlyphs.close,
                  tooltip: appLocalizations.cancel,
                  onPressed: ready
                      ? () => unawaited(action.discardUpdate())
                      : action.cancelUpdateDownload,
                ),
              ),
            ],
          ),
          switch (download) {
            final UpdateDownloading progress => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                LinearProgressIndicator(
                  minHeight: 4,
                  value: progress.total > 0
                      ? progress.received / progress.total
                      : null,
                ),
                Text(
                  _progressText(progress),
                  style: DashboardText.label(context),
                ),
              ],
            ),
            UpdateReady() => Text(
              _readyTip(appLocalizations),
              style: DashboardText.label(context),
            ),
          },
        ],
      ),
    );
  }
}

/// The desktop dashboard's bar button while an update downloads or waits.
class UpdateStatusButton extends ConsumerWidget {
  const UpdateStatusButton({super.key});

  Future<void> _handlePressed(UpdateDownload download, WidgetRef ref) async {
    final appLocalizations = currentAppLocalizations;
    final action = ref.read(commonActionProvider.notifier);
    final res = await dialogs.showMessage(
      title: download is UpdateReady
          ? appLocalizations.updateReady
          : appLocalizations.downloadingUpdate,
      message: TextSpan(
        text: download is UpdateReady
            ? _readyTip(appLocalizations)
            : appLocalizations.stopUpdateDownloadTip,
      ),
      confirmText: download is UpdateReady ? appLocalizations.update : null,
      destructive: download is UpdateDownloading,
    );
    if (res != true) return;
    switch (download) {
      case UpdateReady():
        await action.installUpdate();
      case UpdateDownloading():
        action.cancelUpdateDownload();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final download = ref.watch(updateDownloadStateProvider);
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final ready = download is UpdateReady;
    final statusColor = ready ? colorScheme.successContainer : null;
    final pane = TonalButtonTheme.glassOf(context) && statusColor != null
        ? LiquidGlassStyle.tinted(colorScheme, statusColor)
        : null;
    final label = switch (download) {
      null => '',
      UpdateReady() => appLocalizations.updateReady,
      UpdateDownloading(:final received, :final total) =>
        total > 0 ? '${received * 100 ~/ total}%' : received.traffic.show,
    };
    return FadeScaleBox(
      alignment: Alignment.centerRight,
      child: download == null
          ? const SizedBox.shrink()
          : Tooltip(
              key: ValueKey(ready),
              message: ready
                  ? appLocalizations.updateReady
                  : appLocalizations.downloadingUpdate,
              child: FilledButton.icon(
                onPressed: () => unawaited(_handlePressed(download, ref)),
                style: ButtonStyle.from(
                  backgroundColor: pane == null
                      ? statusColor
                      : Colors.transparent,
                  foregroundColor: ready
                      ? colorScheme.onSuccessContainer
                      : null,
                  backgroundBuilder: pane == null
                      ? null
                      : LiquidGlass.buttonBackground((_) => pane),
                  pressLook: PressLook.none,
                ),
                icon: GlyphIcon(
                  ready ? AppGlyphs.checkCircle : AppGlyphs.cloudDownload,
                  fill: 1,
                  size: globalState.measure.textHeight(
                    AppTextStyle.subheadline,
                  ),
                ),
                label: Text(label),
              ),
            ),
    );
  }
}
