import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/clash_config.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/dns.dart';
import 'package:fl_clash/views/config/network.dart';
import 'package:fl_clash/views/config/scripts.dart';
import 'package:fl_clash/widgets/list.dart';
import 'package:fl_clash/widgets/scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'added_rules.dart';

class AdvancedConfigView extends StatelessWidget {
  const AdvancedConfigView({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    List<Widget> items = [
      ListItem.open(
        title: Text(appLocalizations.network),
        subtitle: Text(appLocalizations.networkDesc),
        leading: const Icon(Icons.vpn_key),
        delegate: OpenDelegate(
          blur: false,
          widget: BaseScaffold(
            title: appLocalizations.network,
            body: const NetworkListView(),
          ),
        ),
      ),
      ListItem.open(
        title: Text('DNS'),
        subtitle: Text(appLocalizations.dnsDesc),
        leading: const Icon(Icons.dns),
        delegate: OpenDelegate(
          widget: BaseScaffold(
            title: 'DNS',
            actions: [
              Consumer(
                builder: (_, ref, _) {
                  return IconButton(
                    onPressed: () async {
                      final res = await globalState.showMessage(
                        title: appLocalizations.reset,
                        message: TextSpan(text: appLocalizations.resetTip),
                      );
                      if (res != true) {
                        return;
                      }
                      ref
                          .read(patchClashConfigProvider.notifier)
                          .updateState(
                            (state) => state.copyWith(dns: defaultDns),
                          );
                    },
                    tooltip: appLocalizations.reset,
                    icon: const Icon(Icons.replay),
                  );
                },
              ),
            ],
            body: const DnsListView(),
          ),
          blur: false,
        ),
      ),
      ListItem.open(
        title: Text(appLocalizations.addedRules),
        subtitle: Text(appLocalizations.controlGlobalAddedRules),
        leading: const Icon(Icons.library_books),
        delegate: OpenDelegate(widget: const AddedRulesView(), blur: false),
      ),
      ListItem.open(
        title: Text(appLocalizations.script),
        subtitle: Text(appLocalizations.overrideScript),
        leading: const Icon(Icons.rocket, fontWeight: FontWeight.w900),
        delegate: OpenDelegate(widget: const ScriptsView(), blur: false),
      ),
    ];
    return BaseScaffold(
      title: appLocalizations.advancedConfig,
      body: generateListView(
        items.separated(const Divider(height: 0)).toList(),
      ),
    );
  }
}
