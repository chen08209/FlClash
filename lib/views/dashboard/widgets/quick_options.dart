import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/network.dart';
import 'package:fl_clash/views/dashboard/widget_metrics.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _QuickSwitchCard extends StatelessWidget {
  const _QuickSwitchCard({
    required this.label,
    required this.glyph,
    required this.items,
    required this.selector,
    required this.onChanged,
  });

  final String label;
  final Glyph glyph;
  final List<Widget> items;
  final ProviderListenable<bool> selector;
  final void Function(WidgetRef ref, bool value) onChanged;

  /// A shrink-wrapped Switch still lays out 4 above and below its track, so
  /// the row may poke into the header's box while the track stays under it.
  static const _switchHeight = kMinInteractiveDimension - 8;

  @override
  Widget build(BuildContext context) {
    final inset = DashboardWidgetMetrics.insetOf(context);
    final lineHeight =
        globalState.measure.bodyMediumHeight *
            DashboardWidgetMetrics.textScaleOf(context) +
        2;
    final overhang = max(0.0, (_switchHeight - lineHeight) / 2);
    return SizedBox(
      height: DashboardWidgetMetrics.heightOf(context, 1),
      child: CommonCard(
        radius: DashboardWidgetMetrics.radiusOf(context),
        infoPadding: DashboardWidgetMetrics.paddingOf(
          context,
        ).copyWith(bottom: 0),
        onPressed: () {
          showSheet(
            context: context,
            builder: (_) {
              return CommonScaffold(
                body: Builder(
                  builder: (context) => generateListView(
                    generateSection(items: items),
                    topPadding: context.sheetTopPadding,
                  ),
                ),
                title: label,
              );
            },
          );
        },
        info: Info(label: label, glyph: glyph),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            inset,
            0,
            inset,
            DashboardWidgetMetrics.verticalInsetOf(context) - overhang,
          ),
          child: OverflowBox(
            alignment: Alignment.bottomCenter,
            maxHeight: double.infinity,
            child: Consumer(
              builder: (_, ref, _) {
                final value = ref.watch(selector);
                return Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 1,
                      child: TooltipText(
                        text: Text(
                          value
                              ? context.appLocalizations.enabled
                              : context.appLocalizations.disabled,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.titleSmall
                              ?.adjustSize(-2)
                              .toLight,
                        ),
                      ),
                    ),
                    Switch(
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: value,
                      onChanged: (value) => onChanged(ref, value),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class TUNButton extends StatelessWidget {
  const TUNButton({super.key});

  @override
  Widget build(BuildContext context) {
    return _QuickSwitchCard(
      label: context.appLocalizations.tun,
      glyph: AppGlyphs.vpn,
      items: [
        if (system.isDesktop) const TUNItem(),
        if (system.isMacOS) const AutoSetSystemDnsItem(),
        const TunStackItem(),
      ],
      selector: patchClashConfigProvider.select((state) => state.tun.enable),
      onChanged: (ref, value) {
        ref
            .read(patchClashConfigProvider.notifier)
            .update((state) => state.copyWith.tun(enable: value));
      },
    );
  }
}

class SystemProxyButton extends StatelessWidget {
  const SystemProxyButton({super.key});

  @override
  Widget build(BuildContext context) {
    return _QuickSwitchCard(
      label: context.appLocalizations.systemProxy,
      glyph: AppGlyphs.shuffle,
      items: const [SystemProxyItem(), BypassDomainItem()],
      selector: networkSettingProvider.select((state) => state.systemProxy),
      onChanged: (ref, value) {
        ref
            .read(networkSettingProvider.notifier)
            .update((state) => state.copyWith(systemProxy: value));
      },
    );
  }
}

class VpnButton extends StatelessWidget {
  const VpnButton({super.key});

  @override
  Widget build(BuildContext context) {
    return _QuickSwitchCard(
      label: 'VPN',
      glyph: AppGlyphs.vpn,
      items: const [VPNItem(), VpnSystemProxyItem(), TunStackItem()],
      selector: vpnSettingProvider.select((state) => state.enable),
      onChanged: (ref, value) {
        ref
            .read(vpnSettingProvider.notifier)
            .update((state) => state.copyWith(enable: value));
      },
    );
  }
}
