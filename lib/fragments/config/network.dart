import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VPNSwitch extends StatelessWidget {
  const VPNSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<Config, bool>(
      selector: (_, config) => config.vpnProps.enable,
      builder: (_, enable, __) {
        return ListItem.switchItem(
          title: const Text("VPN"),
          subtitle: Text(appLocalizations.vpnEnableDesc),
          delegate: SwitchDelegate(
            value: enable,
            onChanged: (value) async {
              final config = globalState.appController.config;
              config.vpnProps = config.vpnProps.copyWith(
                enable: value,
              );
            },
          ),
        );
      },
    );
  }
}

class TUNItem extends StatelessWidget {
  const TUNItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<Config, bool>(
      selector: (_, config) => config.vpnProps.enable,
      builder: (_, enable, __) {
        return ListItem.switchItem(
          title: Text(appLocalizations.tun),
          subtitle: Text(appLocalizations.tunDesc),
          delegate: SwitchDelegate(
            value: enable,
            onChanged: (value) async {
              final clashConfig = globalState.appController.clashConfig;
              clashConfig.tun = clashConfig.tun.copyWith(
                enable: value,
              );
            },
          ),
        );
      },
    );
  }
}

class AllowBypassSwitch extends StatelessWidget {
  const AllowBypassSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<Config, bool>(
      selector: (_, config) => config.vpnProps.allowBypass,
      builder: (_, allowBypass, __) {
        return ListItem.switchItem(
          title: Text(appLocalizations.allowBypass),
          subtitle: Text(appLocalizations.allowBypassDesc),
          delegate: SwitchDelegate(
            value: allowBypass,
            onChanged: (bool value) async {
              final config = globalState.appController.config;
              final vpnProps = config.vpnProps;
              config.vpnProps = vpnProps.copyWith(
                allowBypass: value,
              );
            },
          ),
        );
      },
    );
  }
}

class SystemProxySwitch extends StatelessWidget {
  const SystemProxySwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<Config, bool>(
      selector: (_, config) => config.vpnProps.systemProxy,
      builder: (_, systemProxy, __) {
        return ListItem.switchItem(
          title: Text(appLocalizations.systemProxy),
          subtitle: Text(appLocalizations.systemProxyDesc),
          delegate: SwitchDelegate(
            value: systemProxy,
            onChanged: (bool value) async {
              final config = globalState.appController.config;
              final vpnProps = config.vpnProps;
              config.vpnProps = vpnProps.copyWith(
                systemProxy: value,
              );
            },
          ),
        );
      },
    );
  }
}

class Ipv6Switch extends StatelessWidget {
  const Ipv6Switch({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<Config, bool>(
      selector: (_, config) => config.vpnProps.ipv6,
      builder: (_, ipv6, __) {
        return ListItem.switchItem(
          title: const Text("IPv6"),
          subtitle: Text(appLocalizations.ipv6InboundDesc),
          delegate: SwitchDelegate(
            value: ipv6,
            onChanged: (bool value) async {
              final config = globalState.appController.config;
              final vpnProps = config.vpnProps;
              config.vpnProps = vpnProps.copyWith(
                ipv6: value,
              );
            },
          ),
        );
      },
    );
  }
}

class TunStackItem extends StatelessWidget {
  const TunStackItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ClashConfig, TunStack>(
      selector: (_, clashConfig) => clashConfig.tun.stack,
      builder: (_, stack, __) {
        return ListItem.options(
          title: Text(appLocalizations.stackMode),
          subtitle: Text(stack.name),
          delegate: OptionsDelegate<TunStack>(
            value: stack,
            options: TunStack.values,
            textBuilder: (value) => value.name,
            onChanged: (value) {
              if (value == null) {
                return;
              }
              final clashConfig = globalState.appController.clashConfig;
              clashConfig.tun = clashConfig.tun.copyWith(
                stack: value,
              );
            },
            title: appLocalizations.stackMode,
          ),
        );
      },
    );
  }
}

class BypassDomainItem extends StatelessWidget {
  const BypassDomainItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      title: Text(appLocalizations.bypassDomain),
      subtitle: Text(appLocalizations.bypassDomainDesc),
      delegate: OpenDelegate(
        isBlur: false,
        title: appLocalizations.bypassDomain,
        widget: Selector<Config, List<String>>(
          selector: (_, config) => config.vpnProps.bypassDomain,
          shouldRebuild: (prev, next) =>
              !stringListEquality.equals(prev, next),
          builder: (_, bypassDomain, __) {
            return ListPage(
              title: appLocalizations.bypassDomain,
              items: bypassDomain,
              titleBuilder: (item) => Text(item),
              onChange: (items){
                final config = globalState.appController.config;
                config.vpnProps = config.vpnProps.copyWith(
                  bypassDomain: List.from(items),
                );
              },
            );
          },
        ),
        extendPageWidth: 360,
      ),
    );
  }
}

final networkItems = [
  Platform.isAndroid ? const VPNSwitch() : const TUNItem(),
  if (Platform.isAndroid)
    ...generateSection(
      title: "VPN",
      items: [
        const SystemProxySwitch(),
        const AllowBypassSwitch(),
        const Ipv6Switch(),
        const BypassDomainItem(),
      ],
    ),
  ...generateSection(
    title: appLocalizations.options,
    items: [
      const TunStackItem(),
    ],
  ),
];

class NetworkListView extends StatelessWidget {
  const NetworkListView({super.key});

  _initActions(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final commonScaffoldState =
          context.findAncestorStateOfType<CommonScaffoldState>();
      commonScaffoldState?.actions = [
        IconButton(
          onPressed: () {
            globalState.showMessage(
              title: appLocalizations.reset,
              message: TextSpan(
                text: appLocalizations.resetTip,
              ),
              onTab: () {
                final appController = globalState.appController;
                appController.config.vpnProps = defaultVpnProps;
                appController.clashConfig.tun = defaultTun;
                Navigator.of(context).pop();
              },
            );
          },
          tooltip: appLocalizations.reset,
          icon: const Icon(
            Icons.replay,
          ),
        )
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    _initActions(context);
    return generateListView(
      networkItems,
    );
  }
}
