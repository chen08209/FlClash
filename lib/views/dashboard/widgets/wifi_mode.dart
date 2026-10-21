import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/config/on_demand.dart';
import 'package:fl_clash/views/config/wifi_mode.dart';
import 'package:fl_clash/views/dashboard/layout.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'card.dart';

double wifiModeCardHeight(int rules, double scale) =>
    (128 + rules * 56) * scale + 16;

class WifiModeCard extends ConsumerWidget {
  const WifiModeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final settings = ref.watch(wifiModeSettingProvider);
    final ssid = ref.watch(currentSSIDProvider);
    final scale = DashboardDensityScope.scaleOf(context);
    Widget row(Widget child) => SizedBox(height: 56 * scale, child: child);
    return DashboardCard(
      semanticLabel: l.wifiMode,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 72 * scale,
            child: Row(
              spacing: 12,
              children: [
                IconButton(
                  tooltip: l.locationPermission,
                  icon: const GlyphIcon(AppGlyphs.wifi),
                  onPressed: () => showSheet<void>(
                    context: context,
                    props: nestedPagedSheetProps,
                    builder: (_) => NestedPagedSheet(
                      builder: (_) => const OnDemandView(wifiModeOnly: true),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.wifiMode,
                        style: AppTextStyle.callout.of(
                          context,
                          emphasized: true,
                        ),
                      ),
                      Text(
                        settings.enabled
                            ? ssid ?? l.ssidUnavailable
                            : l.disabled,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.footnote.of(context),
                      ),
                    ],
                  ),
                ),
                DashboardSwitch(
                  semanticLabel: l.wifiMode,
                  value: settings.enabled,
                  onChanged: (value) {
                    ref
                        .read(wifiModeSettingProvider.notifier)
                        .update((state) => state.copyWith(enabled: value));
                    if (value) {
                      unawaited(
                        ref
                            .read(locationPermissionsProvider.notifier)
                            .refresh(),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          row(
            Row(
              children: [
                Expanded(
                  child: ListItem<Mode>.options(
                    title: Text(l.wifiModeFallback, maxLines: 2),
                    padding: EdgeInsets.zero,
                    options: Mode.values,
                    value: settings.fallback,
                    textBuilder: (mode) => mode.label,
                    onChanged: (mode) => ref
                        .read(wifiModeSettingProvider.notifier)
                        .update((state) => state.copyWith(fallback: mode)),
                  ),
                ),
                IconButton(
                  tooltip: l.addSsid,
                  icon: const GlyphIcon(AppGlyphs.add),
                  onPressed: () => editWifiModeRule(context, ref),
                ),
              ],
            ),
          ),
          for (final entry in settings.rules.entries)
            row(
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => editWifiModeRule(context, ref, entry),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          entry.key,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => editWifiModeRule(context, ref, entry),
                    child: Text(entry.value.label),
                  ),
                  IconButton(
                    tooltip: l.delete,
                    icon: const GlyphIcon(AppGlyphs.delete),
                    onPressed: () => ref
                        .read(wifiModeSettingProvider.notifier)
                        .update(
                          (state) => state.copyWith(
                            rules: {...state.rules}..remove(entry.key),
                          ),
                        ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
