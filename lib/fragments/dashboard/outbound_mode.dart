import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OutboundMode extends StatelessWidget {
  const OutboundMode({super.key});

  _changeMode(BuildContext context, Mode? value) async {
    final appController = globalState.appController;
    final clashConfig = appController.clashConfig;
    if (value == null || clashConfig.mode == value) return;
    clashConfig.mode = value;
    await appController.updateClashConfig();
    appController.addCheckIpNumDebounce();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<ClashConfig, Mode>(
      selector: (_, clashConfig) => clashConfig.mode,
      builder: (_, mode, __) {
        return CommonCard(
          onPressed: () {},
          info: Info(
            label: appLocalizations.outboundMode,
            iconData: Icons.call_split,
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                for (final item in Mode.values)
                  ListItem.radio(
                    horizontalTitleGap: 4,
                    prue: true,
                    padding: const EdgeInsets.only(
                      left: 12,
                      right: 16,
                      top: 8,
                      bottom: 8,
                    ),
                    delegate: RadioDelegate(
                      value: item,
                      groupValue: mode,
                      onChanged: (value) async {
                        _changeMode(context, value);
                      },
                    ),
                    title: Text(
                      Intl.message(item.name),
                      style:
                          Theme.of(context).textTheme.titleMedium?.toSoftBold,
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
