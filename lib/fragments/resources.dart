import 'dart:io';

import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' hide context;
import 'package:provider/provider.dart';

@immutable
class GeoItem {
  final String label;
  final String key;
  final String fileName;

  const GeoItem({
    required this.label,
    required this.key,
    required this.fileName,
  });
}

class Resources extends StatefulWidget {
  const Resources({super.key});

  @override
  State<Resources> createState() => _ResourcesState();
}

class _ResourcesState extends State<Resources> {
  List<ExternalProvider> externalProviders = [];

  List<GlobalObjectKey<_ProviderItemState>> providerItemKeys = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncExternalProviders();
    });
  }

  _syncExternalProviders() async {
    externalProviders = await clashCore.getExternalProviders();
    if (mounted) {
      setState(() {});
    }
  }

  _updateProviders() async {
    final updateProviders = providerItemKeys.map<Future>(
      (key) async => await key.currentState?.updateProvider(false),
    );
    await Future.wait(updateProviders);
    _syncExternalProviders();
  }

  List<Widget> _buildExternalProviderSection() {
    List<GlobalObjectKey<_ProviderItemState>> keys = [];
    final res = generateInfoSection(
      info: Info(
        iconData: Icons.source,
        label: appLocalizations.externalResources,
      ),
      actions: [
        IconButton.filledTonal(
          onPressed: () {
            _updateProviders();
          },
          padding: const EdgeInsets.all(4),
          iconSize: 20,
          icon: const Icon(
            Icons.sync,
          ),
        )
      ],
      items: externalProviders.map(
        (externalProvider) {
          final key =
              GlobalObjectKey<_ProviderItemState>(externalProvider.name);
          keys.add(key);
          return ProviderItem(
            key: key,
            provider: externalProvider,
            onUpdated: () {
              _syncExternalProviders();
            },
          );
        },
      ),
    );
    providerItemKeys = keys;
    return res;
  }

  List<Widget> _buildGeoDataSection() {
    const geoItems = <GeoItem>[
      GeoItem(
        label: "GeoIp",
        fileName: geoIpFileName,
        key: "geoip",
      ),
      GeoItem(label: "GeoSite", fileName: geoSiteFileName, key: "geosite"),
      GeoItem(
        label: "MMDB",
        fileName: mmdbFileName,
        key: "mmdb",
      ),
      GeoItem(label: "ASN", fileName: asnFileName, key: "asn"),
    ];

    return generateInfoSection(
      info: Info(
        iconData: Icons.storage,
        label: appLocalizations.geoData,
      ),
      items: geoItems.map(
        (geoItem) => GeoDataListItem(
          geoItem: geoItem,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return generateListView(
      [
        ..._buildGeoDataSection(),
        ..._buildExternalProviderSection(),
      ],
    );
  }
}

class GeoDataListItem extends StatefulWidget {
  final GeoItem geoItem;

  const GeoDataListItem({
    super.key,
    required this.geoItem,
  });

  @override
  State<GeoDataListItem> createState() => _GeoDataListItemState();
}

class _GeoDataListItemState extends State<GeoDataListItem> {
  final isUpdating = ValueNotifier<bool>(false);

  GeoItem get geoItem => widget.geoItem;

  _updateUrl(String url) async {
    final newUrl = await globalState.showCommonDialog<String>(
      child: UpdateGeoUrlFormDialog(
        title: geoItem.label,
        url: url,
      ),
    );
    if (newUrl != null && newUrl != url && mounted) {
      try {
        if (!newUrl.isUrl) {
          throw "Invalid url";
        }
        final appController = globalState.appController;
        appController.clashConfig.geoXUrl =
            Map.from(appController.clashConfig.geoXUrl)..[geoItem.key] = newUrl;
        appController.updateClashConfigDebounce();
      } catch (e) {
        globalState.showMessage(
          title: geoItem.label,
          message: TextSpan(
            text: e.toString(),
          ),
        );
      }
    }
  }

  Future<FileInfo> _getGeoFileLastModified(String fileName) async {
    final homePath = await appPath.getHomeDirPath();
    final file = File(join(homePath, fileName));
    final lastModified = await file.lastModified();
    final size = await file.length();
    return FileInfo(
      size: size,
      lastModified: lastModified,
    );
  }

  Widget _buildSubtitle(String url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 4,
        ),
        FutureBuilder<FileInfo>(
          future: _getGeoFileLastModified(geoItem.fileName),
          builder: (_, snapshot) {
            return SizedBox(
              height: 24,
              child: FadeBox(
                key: Key("fade_box_${geoItem.label}"),
                child: snapshot.data == null
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        snapshot.data!.desc,
                      ),
              ),
            );
          },
        ),
        Text(
          url,
          style: context.textTheme.bodyMedium?.toLight,
        ),
        const SizedBox(
          height: 8,
        ),
        const SizedBox(
          height: 8,
        ),
        Wrap(
          runSpacing: 6,
          spacing: 12,
          children: [
            CommonChip(
              avatar: const Icon(Icons.edit),
              label: appLocalizations.edit,
              onPressed: () {
                _updateUrl(url);
              },
            ),
            CommonChip(
              avatar: const Icon(Icons.sync),
              label: appLocalizations.sync,
              onPressed: () {
                _handleUpdateGeoDataItem();
              },
            ),
          ],
        ),
      ],
    );
  }

  _handleUpdateGeoDataItem() async {
    await globalState.safeRun<void>(updateGeoDateItem);
    setState(() {});
  }

  updateGeoDateItem() async {
    isUpdating.value = true;
    try {
      final message = await clashCore.updateExternalProvider(
        providerName: geoItem.fileName,
        providerType: geoItem.label,
      );
      if (message.isNotEmpty) throw message;
    } catch (e) {
      isUpdating.value = false;
      rethrow;
    }
    isUpdating.value = false;
    return null;
  }

  @override
  void dispose() {
    super.dispose();
    isUpdating.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListItem(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      title: Text(geoItem.label),
      subtitle: Selector<ClashConfig, String>(
        selector: (_, clashConfig) => clashConfig.geoXUrl[geoItem.key]!,
        builder: (_, value, __) {
          return _buildSubtitle(value);
        },
      ),
      trailing: SizedBox(
        height: 48,
        width: 48,
        child: ValueListenableBuilder(
          valueListenable: isUpdating,
          builder: (_, isUpdating, ___) {
            return FadeBox(
              child: isUpdating
                  ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(),
                    )
                  : const SizedBox(),
            );
          },
        ),
      ),
    );
  }
}

class ProviderItem extends StatefulWidget {
  final ExternalProvider provider;
  final Function onUpdated;

  const ProviderItem({
    super.key,
    required this.provider,
    required this.onUpdated,
  });

  @override
  State<ProviderItem> createState() => _ProviderItemState();
}

class _ProviderItemState extends State<ProviderItem> {
  final isUpdating = ValueNotifier<bool>(false);

  ExternalProvider get provider => widget.provider;

  _handleUpdateProfile() async {
    await globalState.safeRun<void>(updateProvider);
    widget.onUpdated();
  }

  updateProvider([isSingle = true]) async {
    if (provider.vehicleType != "HTTP") return;
    isUpdating.value = true;
    try {
      final message = await clashCore.updateExternalProvider(
        providerName: provider.name,
        providerType: provider.type,
      );
      if (message.isNotEmpty) throw message;
    } catch (e) {
      isUpdating.value = false;
      if (!isSingle) {
        return e.toString();
      } else {
        rethrow;
      }
    }
    isUpdating.value = false;
    return null;
  }

  String _buildProviderDesc() {
    return "${provider.type} (${provider.vehicleType})  ·  ${provider.updateAt.lastUpdateTimeDesc}";
  }

  @override
  void dispose() {
    super.dispose();
    isUpdating.dispose();
  }

  Widget _buildSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 4,
        ),
        Text(
          _buildProviderDesc(),
        ),
        if (provider.vehicleType == "HTTP") ...[
          const SizedBox(
            height: 8,
          ),
          CommonChip(
            avatar: const Icon(Icons.sync),
            label: appLocalizations.sync,
            onPressed: () {
              _handleUpdateProfile();
            },
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListItem(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      title: Text(provider.name),
      subtitle: _buildSubtitle(),
      trailing: SizedBox(
        height: 48,
        width: 48,
        child: ValueListenableBuilder(
          valueListenable: isUpdating,
          builder: (_, isUpdating, ___) {
            return FadeBox(
              child: isUpdating
                  ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(),
                    )
                  : const SizedBox(),
            );
          },
        ),
      ),
    );
  }
}

class UpdateGeoUrlFormDialog extends StatefulWidget {
  final String title;
  final String url;

  const UpdateGeoUrlFormDialog({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<UpdateGeoUrlFormDialog> createState() => _UpdateGeoUrlFormDialogState();
}

class _UpdateGeoUrlFormDialogState extends State<UpdateGeoUrlFormDialog> {
  late TextEditingController urlController;

  @override
  void initState() {
    super.initState();
    urlController = TextEditingController(text: widget.url);
  }

  _handleUpdate() async {
    final url = urlController.value.text;
    if (url.isEmpty) return;
    Navigator.of(context).pop<String>(url);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 300,
        child: Wrap(
          runSpacing: 16,
          children: [
            TextField(
              maxLines: 5,
              minLines: 1,
              controller: urlController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _handleUpdate,
          child: Text(appLocalizations.submit),
        )
      ],
    );
  }
}
