import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class VPNItem extends StatelessWidget {
  const VPNItem({super.key});

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
    return Selector<ClashConfig, bool>(
      selector: (_, clashConfig) => clashConfig.tun.enable,
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

class AllowBypassItem extends StatelessWidget {
  const AllowBypassItem({super.key});

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

class VpnSystemProxyItem extends StatelessWidget {
  const VpnSystemProxyItem({super.key});

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

class SystemProxyItem extends StatelessWidget {
  const SystemProxyItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<Config, bool>(
      selector: (_, config) => config.networkProps.systemProxy,
      builder: (_, systemProxy, __) {
        return ListItem.switchItem(
          title: Text(appLocalizations.systemProxy),
          subtitle: Text(appLocalizations.systemProxyDesc),
          delegate: SwitchDelegate(
            value: systemProxy,
            onChanged: (bool value) async {
              final config = globalState.appController.config;
              final networkProps = config.networkProps;
              config.networkProps = networkProps.copyWith(
                systemProxy: value,
              );
            },
          ),
        );
      },
    );
  }
}

class Ipv6Item extends StatelessWidget {
  const Ipv6Item({super.key});

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
                final config = globalState.appController.config;
                config.networkProps = config.networkProps.copyWith(
                  bypassDomain: defaultBypassDomain,
                );
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
    return ListItem.open(
      title: Text(appLocalizations.bypassDomain),
      subtitle: Text(appLocalizations.bypassDomainDesc),
      delegate: OpenDelegate(
        isBlur: false,
        isScaffold: true,
        title: appLocalizations.bypassDomain,
        widget: Selector<Config, List<String>>(
          selector: (_, config) => config.networkProps.bypassDomain,
          shouldRebuild: (prev, next) => !stringListEquality.equals(prev, next),
          builder: (context, bypassDomain, __) {
            _initActions(context);
            return ListPage(
              title: appLocalizations.bypassDomain,
              items: bypassDomain,
              titleBuilder: (item) => Text(item),
              onChange: (items) {
                final config = globalState.appController.config;
                config.networkProps = config.networkProps.copyWith(
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

class RouteModeItem extends StatelessWidget {
  const RouteModeItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ClashConfig, RouteMode>(
      selector: (_, clashConfig) => clashConfig.routeMode,
      builder: (_, value, __) {
        return ListItem<RouteMode>.options(
          title: Text(appLocalizations.routeMode),
          subtitle: Text(Intl.message("routeMode_${value.name}")),
          delegate: OptionsDelegate<RouteMode>(
            title: appLocalizations.routeMode,
            options: RouteMode.values,
            onChanged: (RouteMode? value) {
              if (value == null) {
                return;
              }
              final appController = globalState.appController;
              appController.clashConfig.routeMode = value;
            },
            textBuilder: (routeMode) => Intl.message(
              "routeMode_${routeMode.name}",
            ),
            value: value,
          ),
        );
      },
    );
  }
}

class RouteAddressItem extends StatelessWidget {
  const RouteAddressItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ClashConfig, bool>(
      selector: (_, clashConfig) => clashConfig.routeMode == RouteMode.config,
      builder: (_, value, child) {
        if (value) {
          return child!;
        }
        return Container();
      },
      child: ListItem.open(
        title: Text(appLocalizations.routeAddress),
        subtitle: Text(appLocalizations.routeAddressDesc),
        delegate: OpenDelegate(
          isBlur: false,
          isScaffold: true,
          title: appLocalizations.routeAddress,
          widget: Selector<ClashConfig, List<String>>(
            selector: (_, clashConfig) => clashConfig.includeRouteAddress,
            shouldRebuild: (prev, next) =>
                !stringListEquality.equals(prev, next),
            builder: (context, routeAddress, __) {
              return ListPage(
                title: appLocalizations.routeAddress,
                items: routeAddress,
                titleBuilder: (item) => Text(item),
                onChange: (items) {
                  final clashConfig = globalState.appController.clashConfig;
                  clashConfig.includeRouteAddress =
                      Set<String>.from(items).toList();
                },
              );
            },
          ),
          extendPageWidth: 360,
        ),
      ),
    );
  }
}

final networkItems = [
  if (Platform.isAndroid) const VPNItem(),
  if (Platform.isAndroid)
    ...generateSection(
      title: "VPN",
      items: [
        const SystemProxyItem(),
        const AllowBypassItem(),
        const Ipv6Item(),
      ],
    ),
  if (system.isDesktop)
    ...generateSection(
      title: appLocalizations.system,
      items: [
        SystemProxyItem(),
        BypassDomainItem(),
      ],
    ),
  ...generateSection(
    title: appLocalizations.options,
    items: [
      if (system.isDesktop) const TUNItem(),
      const TunStackItem(),
      const RouteModeItem(),
      const RouteAddressItem(),
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
