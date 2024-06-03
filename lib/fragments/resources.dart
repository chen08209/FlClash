import 'dart:io';

import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/ffi.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' hide context;

@immutable
class GeoItem {
  final String label;
  final String fileName;

  const GeoItem({
    required this.label,
    required this.fileName,
  });
}

class Resources extends StatefulWidget {
  const Resources({super.key});

  @override
  State<Resources> createState() => _ResourcesState();
}

class _ResourcesState extends State<Resources> {
  _updateExternalProvider(
    String providerName,
    String providerType,
  ) async {
    final commonScaffoldState = context.commonScaffoldState;
    await commonScaffoldState?.loadingRun(() async {
      final message = await clashCore.updateExternalProvider(
        providerName: providerName,
        providerType: providerType,
      );
      if (message.isNotEmpty) throw message;
    });
    setState(() {});
  }

  Future<DateTime> _getGeoFileLastModified(String fileName) async {
    final homePath = await appPath.getHomeDirPath();
    return await File(join(homePath, fileName)).lastModified();
  }

  Widget _buildExternalProviderSection() {
    return FutureBuilder<List<ExternalProvider>>(
      future: () async {
        await Future.delayed(const Duration(milliseconds: 200));
        return await clashCore.getExternalProviders();
      }(),
      builder: (_, snapshot) {
        return Center(
          child: FadeBox(
            key: const Key("external_providers"),
            child: snapshot.data == null || snapshot.data!.isEmpty
                ? Container()
                : Section(
                    title: appLocalizations.externalResources,
                    child: Column(
                      children: [
                        for (final externalProvider in snapshot.data!)
                          ListItem(
                            title: Text(externalProvider.name),
                            subtitle: Text(
                              "${externalProvider.type} (${externalProvider.vehicleType})",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  externalProvider.updateAt.lastUpdateTimeDesc,
                                  style: context.textTheme.bodyMedium,
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(left: 12,right: 4),
                                  child: VerticalDivider(
                                    endIndent: 2,
                                    width: 4,
                                    indent: 2,
                                  ),
                                ),
                                externalProvider.vehicleType == "HTTP"
                                    ? IconButton(
                                        icon: const Icon(Icons.sync),
                                        onPressed: () {
                                          _updateExternalProvider(
                                            externalProvider.name,
                                            externalProvider.type,
                                          );
                                        },
                                      )
                                    : Container(),
                              ],
                            ),
                          )
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildGeoDataSection() {
    const geoItems = <GeoItem>[
      GeoItem(label: "GeoIp", fileName: mmdbFileName),
      GeoItem(label: "GeoSite", fileName: geoSiteFileName),
      GeoItem(label: "ASN", fileName: asnFileName),
    ];
    return Section(
      title: appLocalizations.geoData,
      child: Column(
        children: [
          for (final geoItem in geoItems)
            ListItem(
              title: Text(geoItem.label),
              subtitle: FutureBuilder<DateTime>(
                future: () async {
                  await Future.delayed(const Duration(milliseconds: 200));
                  return await _getGeoFileLastModified(geoItem.fileName);
                }(),
                builder: (_, snapshot) {
                  return Container(
                    alignment: Alignment.centerLeft,
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
                              snapshot.data!.lastUpdateTimeDesc,
                            ),
                    ),
                  );
                },
              ),
              trailing: IconButton(
                icon: const Icon(Icons.sync),
                onPressed: () {
                  _updateExternalProvider(
                    geoItem.fileName,
                    geoItem.label,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildGeoDataSection(),
        _buildExternalProviderSection(),
      ],
    );
  }
}
