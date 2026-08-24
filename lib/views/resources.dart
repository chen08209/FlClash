import 'dart:async';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' hide context;

class ResourcesView extends ConsumerWidget {
  const ResourcesView({super.key});

  Future<void> _updateInterval(
    BuildContext context,
    WidgetRef ref,
    int updateInterval,
  ) async {
    final appLocalizations = context.appLocalizations;
    final value = await dialogs.showCommonDialog<String>(
      child: InputDialog(
        title: appLocalizations.geoAutoUpdateInterval,
        value: updateInterval.toString(),
        suffixText: appLocalizations.hours,
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return appLocalizations.emptyTip(
              appLocalizations.geoAutoUpdateInterval,
            );
          }
          final interval = int.tryParse(value);
          if (interval == null) {
            return appLocalizations.numberTip(
              appLocalizations.geoAutoUpdateInterval,
            );
          }
          if (interval <= 0) {
            return appLocalizations.geoAutoUpdateIntervalTip;
          }
          return null;
        },
      ),
    );
    final interval = int.tryParse(value ?? '');
    if (interval == null || interval <= 0) {
      return;
    }
    ref
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(geoUpdateInterval: interval));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const geoResources = GeoResource.values;
    final appLocalizations = context.appLocalizations;
    final geoSetting = ref.watch(
      patchClashConfigProvider.select(
        (state) => (
          autoUpdate: state.geoAutoUpdate,
          updateInterval: state.geoUpdateInterval,
        ),
      ),
    );

    void updateAutoUpdate(bool value) {
      ref
          .read(patchClashConfigProvider.notifier)
          .update((state) => state.copyWith(geoAutoUpdate: value));
    }

    return CommonScaffold(
      title: context.appLocalizations.resources,
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ).copyWith(bottom: 16),
        children: [
          generateSectionV3(
            title: appLocalizations.geoOptions,
            items: [
              DecorationListItem(
                minVerticalPadding: 8,
                contentPadding: const EdgeInsets.only(left: 16, right: 8),
                title: Text(appLocalizations.geoAutoUpdate),
                onPressed: () {
                  updateAutoUpdate(!geoSetting.autoUpdate);
                },
                trailing: Switch(
                  value: geoSetting.autoUpdate,
                  onChanged: updateAutoUpdate,
                ),
              ),
              DecorationListItem(
                minVerticalPadding: 8,
                title: Text(appLocalizations.geoAutoUpdateInterval),
                onPressed: () {
                  _updateInterval(context, ref, geoSetting.updateInterval);
                },
                trailing: Text(
                  appLocalizations.hoursCount(geoSetting.updateInterval),
                  style: context.textTheme.bodyMedium?.toSoftBold,
                ),
              ),
            ],
          ),
          generateSectionV3(
            title: appLocalizations.geoResources,
            items: [
              for (final geoResource in geoResources)
                _GeoResourceListItem(geoResource),
            ],
          ),
        ],
      ),
    );
  }
}

class _GeoResourceListItem extends ConsumerStatefulWidget {
  final GeoResource type;

  const _GeoResourceListItem(this.type);

  @override
  ConsumerState<_GeoResourceListItem> createState() =>
      _GeoResourceListItemState();
}

class _GeoResourceListItemState extends ConsumerState<_GeoResourceListItem> {
  late Future<FileInfo?> _fileInfoFuture;

  String get fileName {
    return switch (widget.type) {
      GeoResource.MMDB => MMDB,
      GeoResource.ASN => ASN,
      GeoResource.GEOIP => GEOIP,
      GeoResource.GEOSITE => GEOSITE,
    };
  }

  @override
  void initState() {
    super.initState();
    _fileInfoFuture = _getGeoFileInfo(fileName);
  }

  @override
  void didUpdateWidget(covariant _GeoResourceListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type != widget.type) {
      _fileInfoFuture = _getGeoFileInfo(fileName);
    }
  }

  Future<void> _updateUrl(String url) async {
    final newUrl = await dialogs.showCommonDialog<String>(
      child: UpdateGeoUrlFormDialog(
        title: widget.type.name,
        url: url,
        defaultValue: defaultGeoXUrl[widget.type],
      ),
    );
    if (newUrl != null && newUrl != url && mounted) {
      try {
        ref
            .read(geoResourceActionProvider.notifier)
            .updateGeoResourceUrl(widget.type, newUrl);
      } catch (e) {
        unawaited(
          dialogs.showMessage(
            title: widget.type.name,
            message: TextSpan(text: e.toString()),
          ),
        );
      }
    }
  }

  Future<FileInfo?> _getGeoFileInfo(String fileName) async {
    final homePath = await appPath.homeDirPath;
    final file = File(join(homePath, fileName));
    return file.getFileInfo();
  }

  Future<void> _handleUpdateGeoDataItem() async {
    await globalState.safeRun<void>(() async {
      await ref
          .read(geoResourceActionProvider.notifier)
          .updateGeoResource(widget.type);
    }, silence: false);
    if (!mounted) {
      return;
    }
    setState(() {
      _fileInfoFuture = _getGeoFileInfo(fileName);
    });
  }

  List<CommonPopupMenuItem> _menuItems(BuildContext context, String url) {
    final appLocalizations = context.appLocalizations;
    return [
      CommonPopupMenuItem(
        icon: Icons.edit_outlined,
        label: appLocalizations.edit,
        onPressed: () {
          _updateUrl(url);
        },
      ),
      CommonPopupMenuItem(
        icon: Icons.sync,
        label: appLocalizations.sync,
        onPressed: _handleUpdateGeoDataItem,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isUpdating = ref.watch(isUpdatingProvider(widget.type.updatingKey));
    final url = ref.watch(
      patchClashConfigProvider.select((state) => state.geoXUrl[widget.type]),
    );
    return FutureBuilder<FileInfo?>(
      future: _fileInfoFuture,
      builder: (context, snapshot) {
        final fileInfo = snapshot.data;
        return DecorationListItem(
          minVerticalPadding: 8,
          contentPadding: const EdgeInsets.only(left: 16, right: 0),
          title: Text(widget.type.name),
          subtitle: fileInfo == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 4),
                  child: Row(
                    spacing: 4,
                    children: [
                      ListItemMetaChip(
                        label: fileInfo.size.traffic.show,
                        tone: ListItemMetaChipTone.primary,
                      ),
                      ListItemMetaChip(
                        label:
                            fileInfo.lastModified?.getLastUpdateTimeDesc(
                              context,
                            ) ??
                            context.appLocalizations.unknown,
                        tone: ListItemMetaChipTone.tertiary,
                      ),
                    ],
                  ),
                ),
          trailing: url == null
              ? null
              : SizedBox.square(
                  dimension: kMinInteractiveDimension,
                  child: FadeThroughBox(
                    alignment: Alignment.center,
                    child: isUpdating
                        ? const SizedBox.square(
                            key: ValueKey('loading'),
                            dimension: kMinInteractiveDimension,
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: CommonCircleLoading(),
                            ),
                          )
                        : CommonPopupBox(
                            key: const ValueKey('menu'),
                            popupBuilder: (_) => CommonPopupMenu(
                              items: _menuItems(context, url),
                            ),
                            targetBuilder: (open) {
                              return IconButton(
                                tooltip: context.appLocalizations.more,
                                onPressed: open,
                                icon: const Icon(Icons.more_vert),
                              );
                            },
                          ),
                  ),
                ),
        );
      },
    );
  }
}

class UpdateGeoUrlFormDialog extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return InputDialog(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      title: title,
      value: url,
      resetValue: defaultValue,
      inputFormatters: TextInputLimits.limit(TextInputLimits.url),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return appLocalizations.emptyTip('').trim();
        }
        if (!value.isUrl) {
          return appLocalizations.urlTip('').trim();
        }
        return null;
      },
    );
  }
}
