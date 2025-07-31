import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' hide context;

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

class ResourcesView extends StatelessWidget {
  const ResourcesView({super.key});

  @override
  Widget build(BuildContext context) {
    const geoItems = <GeoItem>[
      GeoItem(label: 'GEOIP', fileName: GEOIP, key: 'geoip'),
      GeoItem(label: 'GEOSITE', fileName: GEOSITE, key: 'geosite'),
      GeoItem(label: 'MMDB', fileName: MMDB, key: 'mmdb'),
      GeoItem(label: 'ASN', fileName: ASN, key: 'asn'),
    ];

    return CommonScaffold(
      title: appLocalizations.resources,
      body: ListView.separated(
        itemBuilder: (_, index) {
          final geoItem = geoItems[index];
          return GeoDataListItem(geoItem: geoItem);
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider(height: 0);
        },
        itemCount: geoItems.length,
      ),
    );
  }
}

class GeoDataListItem extends StatefulWidget {
  final GeoItem geoItem;

  const GeoDataListItem({super.key, required this.geoItem});

  @override
  State<GeoDataListItem> createState() => _GeoDataListItemState();
}

class _GeoDataListItemState extends State<GeoDataListItem> {
  final isUpdating = ValueNotifier<bool>(false);

  GeoItem get geoItem => widget.geoItem;

  Future<void> _updateUrl(String url, WidgetRef ref) async {
    final defaultMap = defaultGeoXUrl.toJson();
    final newUrl = await globalState.showCommonDialog<String>(
      child: UpdateGeoUrlFormDialog(
        title: geoItem.label,
        url: url,
        defaultValue: defaultMap[geoItem.key],
      ),
    );
    if (newUrl != null && newUrl != url && mounted) {
      try {
        if (!newUrl.isUrl) {
          throw 'Invalid url';
        }
        ref.read(patchClashConfigProvider.notifier).updateState((state) {
          final map = state.geoXUrl.toJson();
          map[geoItem.key] = newUrl;
          return state.copyWith(geoXUrl: GeoXUrl.fromJson(map));
        });
      } catch (e) {
        globalState.showMessage(
          title: geoItem.label,
          message: TextSpan(text: e.toString()),
        );
      }
    }
  }

  Future<FileInfo> _getGeoFileLastModified(String fileName) async {
    final homePath = await appPath.homeDirPath;
    final file = File(join(homePath, fileName));
    final lastModified = await file.lastModified();
    final size = await file.length();
    return FileInfo(size: size, lastModified: lastModified);
  }

  Widget _buildSubtitle() {
    return Consumer(
      builder: (_, ref, _) {
        final url = ref.watch(
          patchClashConfigProvider.select(
            (state) => state.geoXUrl.toJson()[geoItem.key],
          ),
        );
        if (url == null) {
          return SizedBox();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            FutureBuilder<FileInfo>(
              future: _getGeoFileLastModified(geoItem.fileName),
              builder: (_, snapshot) {
                final height = globalState.measure.bodyMediumHeight;
                return SizedBox(
                  height: height,
                  child: snapshot.data == null
                      ? SizedBox(width: height, height: height)
                      : Text(
                          snapshot.data!.desc,
                          style: context.textTheme.bodyMedium,
                        ),
                );
              },
            ),
            const SizedBox(height: 4),
            Text(url, style: context.textTheme.bodyMedium?.toLight),
            const SizedBox(height: 12),
            Wrap(
              runSpacing: 6,
              spacing: 12,
              runAlignment: WrapAlignment.center,
              children: [
                CommonChip(
                  avatar: const Icon(Icons.edit),
                  label: appLocalizations.edit,
                  onPressed: () {
                    _updateUrl(url, ref);
                  },
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      child: ValueListenableBuilder(
                        valueListenable: isUpdating,
                        builder: (_, isUpdating, _) {
                          return isUpdating
                              ? SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: const Padding(
                                    padding: EdgeInsets.all(2),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : CommonChip(
                                  avatar: const Icon(Icons.sync),
                                  label: appLocalizations.sync,
                                  onPressed: () {
                                    _handleUpdateGeoDataItem();
                                  },
                                );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
        );
      },
    );
  }

  Future<void> _handleUpdateGeoDataItem() async {
    await globalState.appController.safeRun<void>(
      () async {
        await updateGeoDateItem();
      },
      silence: false,
      needLoading: false,
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> updateGeoDateItem() async {
    isUpdating.value = true;
    try {
      final message = await coreController.updateGeoData(
        UpdateGeoDataParams(geoName: geoItem.fileName, geoType: geoItem.label),
      );
      if (message.isNotEmpty) throw message;
    } catch (e) {
      isUpdating.value = false;
      rethrow;
    }
    isUpdating.value = false;
    return;
  }

  @override
  void dispose() {
    super.dispose();
    isUpdating.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListItem(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(geoItem.label),
      subtitle: _buildSubtitle(),
    );
  }
}

class UpdateGeoUrlFormDialog extends StatefulWidget {
  final String title;
  final String url;
  final String? defaultValue;

  const UpdateGeoUrlFormDialog({
    super.key,
    required this.title,
    required this.url,
    this.defaultValue,
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

  Future<void> _handleReset() async {
    if (widget.defaultValue == null) {
      return;
    }
    Navigator.of(context).pop<String>(widget.defaultValue);
  }

  Future<void> _handleUpdate() async {
    final url = urlController.value.text;
    if (url.isEmpty) return;
    Navigator.of(context).pop<String>(url);
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: widget.title,
      actions: [
        if (widget.defaultValue != null &&
            urlController.value.text != widget.defaultValue) ...[
          TextButton(
            onPressed: _handleReset,
            child: Text(appLocalizations.reset),
          ),
          const SizedBox(width: 4),
        ],
        TextButton(
          onPressed: _handleUpdate,
          child: Text(appLocalizations.submit),
        ),
      ],
      child: Wrap(
        runSpacing: 16,
        children: [
          TextField(
            maxLines: 5,
            minLines: 1,
            controller: urlController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }
}
