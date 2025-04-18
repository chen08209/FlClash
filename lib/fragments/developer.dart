import 'package:fl_clash/clash/core.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeveloperView extends ConsumerWidget {
  const DeveloperView({super.key});

  Widget _getDeveloperList(BuildContext context) {
    return generateSectionV2(
      title: appLocalizations.options,
      items: [
        ListItem(
          leading: Icon(Icons.ac_unit),
          title: Text(appLocalizations.messageTest),
          onTap: () {
            context.showNotifier(
              appLocalizations.messageTestTip,
            );
          },
        ),
        ListItem(
          leading: Icon(Icons.heart_broken),
          title: Text(appLocalizations.crashTest),
          onTap: () {
            clashCore.clashInterface.crash();
          },
        ),
        ListItem(
          leading: Icon(Icons.delete_forever),
          title: Text(appLocalizations.clearData),
          onTap: () async {
            await globalState.appController.handleClear();
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context, ref) {
    final enable = ref.watch(
      appSettingProvider.select(
        (state) => state.developerMode,
      ),
    );
    return SingleChildScrollView(
      padding: baseInfoEdgeInsets,
      child: Column(
        children: [
          CommonCard(
            type: CommonCardType.filled,
            radius: 18,
            child: ListItem.switchItem(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 4,
                bottom: 4,
              ),
              title: Text(appLocalizations.developerMode),
              delegate: SwitchDelegate(
                value: enable,
                onChanged: (value) {
                  ref.read(appSettingProvider.notifier).updateState(
                        (state) => state.copyWith(
                          developerMode: value,
                        ),
                      );
                },
              ),
            ),
          ),
          SizedBox(
            height: 16,
          ),
          _getDeveloperList(context)
        ],
      ),
    );
  }
}
