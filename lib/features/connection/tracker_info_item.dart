import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrackerInfoItem extends ConsumerWidget {
  final TrackerInfo trackerInfo;
  final Function(String)? onClickKeyword;
  final Widget? trailing;
  final String detailTitle;

  const TrackerInfoItem({
    super.key,
    required this.trackerInfo,
    this.onClickKeyword,
    this.trailing,
    required this.detailTitle,
  });

  Widget _buildMeta(BuildContext context) {
    final traffic = Traffic(up: trackerInfo.upload, down: trackerInfo.download);
    final chains = trackerInfo.chains;
    final metaText =
        '${trackerInfo.start.getLastUpdateTimeDesc(context)} · ${traffic.desc}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            metaText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        if (chains.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 0),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final chain in chains)
                  CommonChip(
                    label: chain,
                    onPressed: () => onClickKeyword?.call(chain),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, ref) {
    final showIcon = ref.watch(
      patchClashConfigProvider.select(
        (state) =>
            state.findProcessMode == FindProcessMode.always && system.isAndroid,
      ),
    );
    final process = trackerInfo.metadata.process;
    final icon = showIcon
        ? GestureDetector(
            onTap: () {
              if (process.isEmpty) return;
              onClickKeyword?.call(process);
            },
            child: Padding(
              padding: const EdgeInsetsGeometry.only(top: 6),
              child: PackageIcon(packageName: process, size: 44),
            ),
          )
        : null;
    return ListItem(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ).copyWith(bottom: 12),
      minVerticalPadding: 0,
      horizontalTitleGap: 12,
      tileTitleAlignment: ListTileTitleAlignment.top,
      onTap: () {
        showExtend(
          context,
          builder: (_) {
            return AdaptiveSheetScaffold(
              sheetTransparentToolBar: true,
              body: TrackerInfoDetailView(trackerInfo: trackerInfo),
              title: detailTitle,
            );
          },
        );
      },
      leading: icon,
      title: Text(
        trackerInfo.desc,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textTheme.bodyLarge,
      ),
      subtitle: _buildMeta(context),
      trailing: trailing,
    );
  }
}

class TrackerInfoDetailView extends StatelessWidget {
  final TrackerInfo trackerInfo;

  const TrackerInfoDetailView({super.key, required this.trackerInfo});

  String _getRuleText() {
    final rule = trackerInfo.rule;
    final rulePayload = trackerInfo.rulePayload;
    if (rulePayload.isNotEmpty) {
      return '$rule($rulePayload)';
    }
    return rule;
  }

  String _getProcessText() {
    final process = trackerInfo.metadata.process;
    final uid = trackerInfo.metadata.uid;
    if (uid != 0) {
      return '$process($uid)';
    }
    return process;
  }

  String _getEndpointText(String ip, String port) {
    if (ip.isEmpty) {
      return '';
    }
    if (port.isNotEmpty) {
      return '$ip:$port';
    }
    return ip;
  }

  Widget _buildChains(BuildContext context) {
    return DecorationListItem(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Text(context.appLocalizations.proxyChains),
          Flexible(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              alignment: WrapAlignment.end,
              children: [
                for (final chain in trackerInfo.chains) MetaChip(label: chain),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRows(List<(String, String)> entries) {
    return [
      for (final (title, value) in entries)
        if (value.isNotEmpty) _DetailRow(title: title, value: value),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final metadata = trackerInfo.metadata;
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ).copyWith(bottom: 20, top: context.sheetTopPadding),
      children: [
        generateSectionV3(
          title: appLocalizations.basicInfo,
          items: _buildRows([
            (appLocalizations.creationTime, trackerInfo.start.showFull),
            (appLocalizations.networkType, metadata.network),
            (appLocalizations.process, _getProcessText()),
            (appLocalizations.rule, _getRuleText()),
            (appLocalizations.upload, trackerInfo.upload.traffic.show),
            (appLocalizations.download, trackerInfo.download.traffic.show),
          ]),
        ),
        generateSectionV3(
          title: appLocalizations.address,
          items: _buildRows([
            (appLocalizations.host, metadata.host),
            (
              appLocalizations.source,
              _getEndpointText(metadata.sourceIP, metadata.sourcePort),
            ),
            (
              appLocalizations.destination,
              _getEndpointText(
                metadata.destinationIP,
                metadata.destinationPort,
              ),
            ),
            (
              appLocalizations.destinationGeoIP,
              metadata.destinationGeoIP.join(' '),
            ),
            (appLocalizations.destinationIPASN, metadata.destinationIPASN),
            (appLocalizations.remoteDestination, metadata.remoteDestination),
          ]),
        ),
        generateSectionV3(
          title: appLocalizations.proxies,
          items: [
            ..._buildRows([
              (appLocalizations.specialProxy, metadata.specialProxy),
              (appLocalizations.specialRules, metadata.specialRules),
              (appLocalizations.dnsMode, metadata.dnsMode?.name ?? ''),
            ]),
            _buildChains(context),
          ],
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String title;
  final String value;

  const _DetailRow({required this.title, required this.value});

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    context.showNotifier(context.appLocalizations.copySuccess);
  }

  @override
  Widget build(BuildContext context) {
    return DecorationListItem(
      onPressed: () => _copy(context),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Text(title),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
