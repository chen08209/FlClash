import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/dns.dart';
import 'package:fl_clash/views/config/network.dart';
import 'package:fl_clash/views/config/ntp.dart';
import 'package:fl_clash/views/dashboard/widget_metrics.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _QuickSwitchCard extends StatelessWidget {
  const _QuickSwitchCard({
    required this.label,
    required this.glyph,
    required this.selector,
    required this.onChanged,
    required this.sheetBuilder,
  });

  final String label;
  final Glyph glyph;
  final ProviderListenable<bool> selector;
  final void Function(WidgetRef ref, bool value) onChanged;
  final WidgetBuilder sheetBuilder;

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
        onPressed: () => showSheet(context: context, builder: sheetBuilder),
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

class _NetworkSheet extends StatelessWidget {
  const _NetworkSheet({required this.title, required this.sections});

  final String title;
  final List<Widget> sections;

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: title,
      body: Builder(
        builder: (context) => ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ).copyWith(top: context.contentTopPadding, bottom: 16),
          children: sections,
        ),
      ),
    );
  }
}

class TUNButton extends StatelessWidget {
  const TUNButton({super.key});

  @override
  Widget build(BuildContext context) {
    final label = context.appLocalizations.tun;
    return _QuickSwitchCard(
      label: label,
      glyph: AppGlyphs.vpn,
      sheetBuilder: (_) => _NetworkSheet(
        title: label,
        sections: const [NetworkOptionsSection()],
      ),
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
    final label = context.appLocalizations.systemProxy;
    return _QuickSwitchCard(
      label: label,
      glyph: AppGlyphs.shuffle,
      sheetBuilder: (_) =>
          _NetworkSheet(title: label, sections: const [SystemProxySection()]),
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
      sheetBuilder: (_) => const _NetworkSheet(
        title: 'VPN',
        sections: [VpnSections(), NetworkOptionsSection()],
      ),
      selector: vpnSettingProvider.select((state) => state.enable),
      onChanged: (ref, value) {
        ref
            .read(vpnSettingProvider.notifier)
            .update((state) => state.copyWith(enable: value));
      },
    );
  }
}

class OverrideDnsButton extends StatelessWidget {
  const OverrideDnsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return _QuickSwitchCard(
      label: context.appLocalizations.overrideDns,
      glyph: AppGlyphs.dns,
      sheetBuilder: (_) => const DnsView(),
      selector: overrideDnsProvider,
      onChanged: (ref, value) {
        ref.read(overrideDnsProvider.notifier).value = value;
      },
    );
  }
}

class OverrideNtpButton extends StatelessWidget {
  const OverrideNtpButton({super.key});

  @override
  Widget build(BuildContext context) {
    return _QuickSwitchCard(
      label: context.appLocalizations.overrideNtp,
      glyph: AppGlyphs.clock,
      sheetBuilder: (_) => const NtpView(),
      selector: overrideNtpProvider,
      onChanged: (ref, value) {
        ref.read(overrideNtpProvider.notifier).value = value;
      },
    );
  }
}
