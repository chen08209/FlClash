import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/fragments/config/app.dart';
import 'package:fl_clash/fragments/config/dns.dart';
import 'package:fl_clash/fragments/config/general.dart';
import 'package:fl_clash/fragments/config/vpn.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';

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
        title: Text(appLocalizations.app),
        subtitle: Text(appLocalizations.appDesc),
        leading: const Icon(Icons.settings_applications),
        delegate: OpenDelegate(
          title: appLocalizations.app,
          isBlur: false,
          widget: generateListView(
            appItems
                .separated(
                  const Divider(
                    height: 0,
                  ),
                )
                .toList(),
          ),
        ),
      ),
      if (Platform.isAndroid)
        ListItem.open(
          title: const Text("VPN"),
          subtitle: Text(appLocalizations.vpnDesc),
          leading: const Icon(Icons.vpn_key),
          delegate: OpenDelegate(
            title: "VPN",
            isBlur: false,
            widget: generateListView(
              vpnItems,
            ),
          ),
        ),
      ListItem.open(
        title: Text(appLocalizations.general),
        subtitle: Text(appLocalizations.generalDesc),
        leading: const Icon(Icons.build),
        delegate: OpenDelegate(
          title: appLocalizations.general,
          widget: generateListView(
            generalItems,
          ),
          isBlur: false,
          extendPageWidth: 360,
        ),
      ),
      ListItem.open(
        title: const Text("DNS"),
        subtitle: Text(appLocalizations.dnsDesc),
        leading: const Icon(Icons.dns),
        delegate: OpenDelegate(
          title: "DNS",
          widget: generateListView(
            dnsItems,
          ),
          isScaffold: true,
          isBlur: false,
          extendPageWidth: 360,
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
