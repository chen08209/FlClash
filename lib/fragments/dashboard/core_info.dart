import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:fl_clash/common/common.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CoreInfo extends StatelessWidget {
  const CoreInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AppState, VersionInfo?>(
      selector: (_, appState) => appState.versionInfo,
      builder: (_, versionInfo, __) {
        return CommonCard(
          onPressed: () {},
          info: Info(
            label: appLocalizations.coreInfo,
            iconData: Icons.memory,
          ),
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(16).copyWith(top: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  flex: 1,
                  child: Text(
                    versionInfo?.clashName ?? '',
                    style: context
                        .textTheme
                        .titleMedium
                        ?.toSoftBold,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Flexible(
                  flex: 1,
                  child: Text(
                    versionInfo?.version ?? '',
                    style: context
                        .textTheme
                        .titleLarge
                        ?.toSoftBold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
