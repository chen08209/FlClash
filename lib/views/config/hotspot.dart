import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/windows_hotspot.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/hotspot.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String hotspotStatusLabel(
  AppLocalizations l,
  HotspotSnapshot state, {
  required bool safeMode,
  required bool ready,
}) {
  if (safeMode) return l.hotspotSafeMode;
  if (state.busy) return l.hotspotWorking;
  if (state.error.isNotEmpty) {
    return switch (state.error) {
      'tun_required' => l.hotspotRequiresTun,
      'existing_hotspot' => l.hotspotExisting,
      'ownership_changed' => l.hotspotOwnershipChanged,
      'sharing_bypass' => l.hotspotBypass,
      'stop_failed' => l.hotspotStopFailed,
      _ => l.hotspotFailed,
    };
  }
  if (state.managed && state.on && state.throughTun) {
    return l.hotspotConnected(state.ssid, state.clients);
  }
  return ready ? l.hotspotOff : l.hotspotRequiresTun;
}

class HotspotSharingSection extends ConsumerWidget {
  const HotspotSharingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final state = ref.watch(hotspotControllerProvider);
    final safeMode = ref.watch(safeModeProvider);
    final ready = ref.watch(hotspotReadyProvider);
    final supported = ref.watch(hotspotSupportedProvider);
    return generateSection(
      title: l.hotspotSharing,
      items: [
        ListItem.toggle(
          title: Text(l.hotspotSharing),
          subtitle: Text(
            hotspotStatusLabel(l, state, safeMode: safeMode, ready: ready),
          ),
          value: state.managed,
          onChanged: state.busy || safeMode || !supported
              ? null
              : (value) {
                  unawaited(
                    ref
                        .read(hotspotControllerProvider.notifier)
                        .setEnabled(value),
                  );
                },
        ),
      ],
      footer: l.hotspotSharingDescription,
    );
  }
}
