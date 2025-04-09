import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/fragments/config/dns.dart';
import 'package:fl_clash/fragments/config/general.dart';
import 'package:fl_clash/fragments/config/network.dart';
import 'package:fl_clash/models/clash_config.dart';
import 'package:fl_clash/providers/config.dart' show patchClashConfigProvider;
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state.dart';

class ConfigFragment extends StatefulWidget {
  const ConfigFragment({super.key});

  @override
  State<ConfigFragment> createState() => _ConfigFragmentState();
}

class _ConfigFragmentState extends State<ConfigFragment> {
  @override
  Widget build(BuildContext context) {
    List<Widget> items = [
      ListItem.open(
        title: Text(appLocalizations.general),
        subtitle: Text(appLocalizations.generalDesc),
        leading: const Icon(Icons.build),
        delegate: OpenDelegate(
          title: appLocalizations.general,
          widget: generateListView(
            generalItems,
          ),
          blur: false,
        ),
      ),
      ListItem.open(
        title: Text(appLocalizations.network),
        subtitle: Text(appLocalizations.networkDesc),
        leading: const Icon(Icons.vpn_key),
        delegate: OpenDelegate(
          title: appLocalizations.network,
          blur: false,
          widget: const NetworkListView(),
        ),
      ),
      ListItem.open(
        title: const Text("DNS"),
        subtitle: Text(appLocalizations.dnsDesc),
        leading: const Icon(Icons.dns),
        delegate: OpenDelegate(
          title: "DNS",
          action: Consumer(builder: (_, ref, __) {
            return IconButton(
              onPressed: () async {
                final res = await globalState.showMessage(
                  title: appLocalizations.reset,
                  message: TextSpan(
                    text: appLocalizations.resetTip,
                  ),
                );
                if (res != true) {
                  return;
                }
                ref.read(patchClashConfigProvider.notifier).updateState(
                      (state) => state.copyWith(
                        dns: defaultDns,
                      ),
                    );
              },
              tooltip: appLocalizations.reset,
              icon: const Icon(
                Icons.replay,
              ),
            );
          }),
          widget: const DnsListView(),
          blur: false,
        ),
      )
    ];
    return generateListView(
      items
          .separated(
            const Divider(
              height: 0,
            ),
          )
          .toList(),
    );
  }
}
