import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/ip_quality.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/ip_quality.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'ip_quality_text.dart';
import 'labels.dart';

Future<void> showIpQualitySheet(BuildContext context, {required String ip}) {
  return showSheet<void>(
    context: context,
    builder: (_) => _IpQualitySheet(ip: ip),
  );
}

class _IpQualitySheet extends ConsumerWidget {
  const _IpQualitySheet({required this.ip});

  final String ip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = context.appLocalizations;
    final isLoading = ref.watch(
      ipQualityProvider(ip).select((result) => result.isLoading),
    );
    return CommonScaffold(
      title: localizations.outboundIp,
      actions: [
        AppBarActionButton(
          data: IconButtonData(
            glyph: AppGlyphs.refresh,
            tooltip: localizations.ipQualityRetry,
            isLoading: isLoading,
            onPressed: () => ref.invalidate(ipQualityProvider(ip)),
          ),
        ),
      ],
      body: _IpQualityDetail(ip: ip),
    );
  }
}

class _HideIpItem extends ConsumerWidget {
  const _HideIpItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hideIp = ref.watch(
      appSettingProvider.select((state) => state.hideIp),
    );
    void update(bool value) => ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(hideIp: value));
    return DecorationListItem(
      title: Text(context.appLocalizations.hideIp),
      onPressed: () => update(!hideIp),
      trailing: Switch(value: hideIp, onChanged: update),
    );
  }
}

class _IpQualityDetail extends ConsumerWidget {
  const _IpQualityDetail({required this.ip});

  /// The optical edge of the xl-radius cards, as in the memory sheet.
  static const _tipInset = 5.0;

  final String ip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = context.appLocalizations;
    final result = ref.watch(ipQualityProvider(ip));
    final quality = result.value;
    final error = result.error;
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ).copyWith(bottom: 20, top: context.sheetTopPadding),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(_tipInset, 8, _tipInset, 0),
          child: Text(
            localizations.detectionTip,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        generateSectionV3(
          title: localizations.basicInfo,
          items: [
            DetailRow(
              title: localizations.ipAddress,
              copyText: ip,
              value: IpQualityText(ip: ip),
            ),
            if (quality != null)
              ..._qualityRows(context, quality)
            else
              DetailRow(
                title: localizations.ipType,
                value: result.isLoading
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CommonCircleLoading(),
                      )
                    : Text(
                        localizations.ipQualityFailed,
                        style: TextStyle(color: context.colorScheme.error),
                      ),
              ),
          ],
        ),
        if (quality != null)
          generateSectionV3(
            title: localizations.network,
            items: _networkRows(context, quality),
          ),
        if (quality == null && error is IpQualityLookupException)
          generateSectionV3(
            title: localizations.ipQualitySources,
            items: [
              for (final failure in error.failures)
                DetailRow(
                  title: failure.source.label,
                  value: Text(failure.status.label(context)),
                ),
            ],
          ),
        generateSectionV3(
          title: localizations.other,
          items: const [_HideIpItem()],
        ),
      ],
    );
  }

  List<Widget> _qualityRows(BuildContext context, IpQuality quality) {
    final localizations = context.appLocalizations;
    final flags = [
      if (quality.isTor) localizations.ipFlagTor,
      if (quality.isAbuser) localizations.ipFlagAbuser,
      if (quality.isVpn) localizations.ipFlagVpn,
      if (quality.isProxy) localizations.ipFlagProxy,
    ];
    return [
      DetailRow(
        title: localizations.ipQualityLevel,
        value: Text(
          quality.level.label(context),
          style: TextStyle(color: quality.level.color(context)),
        ),
      ),
      DetailRow(
        title: localizations.ipType,
        value: Text(quality.type.label(context)),
      ),
      DetailRow(
        title: localizations.ipFlags,
        value: flags.isEmpty
            ? Text(localizations.none)
            : Wrap(
                spacing: 6,
                runSpacing: 4,
                alignment: WrapAlignment.end,
                children: [for (final flag in flags) MetaChip(label: flag)],
              ),
      ),
    ];
  }

  List<Widget> _networkRows(BuildContext context, IpQuality quality) {
    final localizations = context.appLocalizations;
    return [
      if (quality.organization case final organization?)
        DetailRow(
          title: localizations.ipOrganization,
          copyText: organization,
          value: Text(organization),
        ),
      if (quality.asn case final asn?)
        DetailRow(
          title: localizations.ipAsn,
          copyText: 'AS$asn',
          value: Text('AS$asn'),
        ),
      DetailRow(
        title: localizations.ipQualitySource,
        value: Text(quality.source.label),
      ),
    ];
  }
}
