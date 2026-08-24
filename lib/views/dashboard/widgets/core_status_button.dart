import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CoreStatusButton extends ConsumerStatefulWidget {
  const CoreStatusButton({super.key});

  @override
  ConsumerState<CoreStatusButton> createState() => _CoreStatusButtonState();
}

class _CoreStatusButtonState extends ConsumerState<CoreStatusButton> {
  static const _holdDuration = Duration(milliseconds: 600);

  Timer? _holdTimer;
  CoreStatus _status = CoreStatus.disconnected;

  @override
  void initState() {
    super.initState();
    _status = ref.read(coreStatusProvider);
    ref.listenManual(coreStatusProvider, (_, next) {
      _onStatusChanged(next);
    });
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  void _onStatusChanged(CoreStatus next) {
    setState(() {
      _status = next;
      switch (next) {
        case CoreStatus.connecting:
          _holdTimer ??= Timer(_holdDuration, () {
            if (mounted) {
              setState(() {
                _holdTimer = null;
              });
            }
          });
          break;
        case CoreStatus.disconnected:
          _holdTimer?.cancel();
          _holdTimer = null;
          break;
        case CoreStatus.connected:
          break;
      }
    });
  }

  Future<void> _handleConnection() async {
    if (_holdTimer != null) {
      return;
    }
    final coreStatus = ref.read(coreStatusProvider);
    if (coreStatus == CoreStatus.connecting) {
      return;
    }
    final tip = coreStatus == CoreStatus.connected
        ? context.appLocalizations.forceRestartCoreTip
        : context.appLocalizations.restartCoreTip;
    final res = await dialogs.showMessage(message: TextSpan(text: tip));
    if (res != true) {
      return;
    }
    try {
      await ref.read(coreActionProvider.notifier).restartCore();
    } catch (error) {
      dialogs.showNotifier(error.toString(), level: MessageLevel.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final coreStatus = _holdTimer != null ? CoreStatus.connecting : _status;
    final appLocalizations = context.appLocalizations;
    return Tooltip(
      message: appLocalizations.coreStatus,
      child: FadeScaleBox(
        alignment: Alignment.centerRight,
        child: coreStatus == CoreStatus.connected
            ? IconButton.filled(
                visualDensity: VisualDensity.compact,
                iconSize: 20,
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.green.harmonizeWith(
                    context.colorScheme.primary,
                  ),
                  foregroundColor: switch (Theme.brightnessOf(context)) {
                    Brightness.light => context.colorScheme.onSurfaceVariant,
                    Brightness.dark =>
                      context.colorScheme.onPrimaryFixedVariant,
                  },
                ),
                onPressed: _handleConnection,
                icon: const Icon(Icons.check, fontWeight: FontWeight.w900),
              )
            : FilledButton.icon(
                key: ValueKey(coreStatus),
                onPressed: _handleConnection,
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  backgroundColor: switch (coreStatus) {
                    CoreStatus.connecting => null,
                    CoreStatus.connected => Colors.greenAccent,
                    CoreStatus.disconnected => context.colorScheme.error,
                  },
                  foregroundColor: switch (coreStatus) {
                    CoreStatus.connecting => null,
                    CoreStatus.connected => switch (Theme.brightnessOf(
                      context,
                    )) {
                      Brightness.light => context.colorScheme.onSurfaceVariant,
                      Brightness.dark => null,
                    },
                    CoreStatus.disconnected => context.colorScheme.onError,
                  },
                ),
                icon: SizedBox(
                  height: globalState.measure.bodyMediumHeight,
                  width: globalState.measure.bodyMediumHeight,
                  child: switch (coreStatus) {
                    CoreStatus.connecting => Padding(
                      padding: const EdgeInsets.all(2),
                      child: CommonCircleLoading(
                        color: context.colorScheme.onPrimary,
                      ),
                    ),
                    CoreStatus.connected => const Icon(
                      Icons.check_sharp,
                      fontWeight: FontWeight.w900,
                    ),
                    CoreStatus.disconnected => const Icon(
                      Icons.restart_alt_sharp,
                      fontWeight: FontWeight.w900,
                    ),
                  },
                ),
                label: Text(switch (coreStatus) {
                  CoreStatus.connecting => appLocalizations.connecting,
                  CoreStatus.connected => appLocalizations.connected,
                  CoreStatus.disconnected => appLocalizations.disconnected,
                }),
              ),
      ),
    );
  }
}
