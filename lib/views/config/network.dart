import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class VPNItem extends ConsumerWidget {
  const VPNItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final enable = ref.watch(
      vpnSettingProvider.select((state) => state.enable),
    );
    return ListItem.switchItem(
      title: const Text('VPN'),
      subtitle: Text(appLocalizations.vpnEnableDesc),
      delegate: SwitchDelegate(
        value: enable,
        onChanged: (value) async {
          ref
              .read(vpnSettingProvider.notifier)
              .updateState((state) => state.copyWith(enable: value));
        },
      ),
    );
  }
}

class TUNItem extends ConsumerWidget {
  const TUNItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final enable = ref.watch(
      patchClashConfigProvider.select((state) => state.tun.enable),
    );

    return ListItem.switchItem(
      title: Text(appLocalizations.tun),
      subtitle: Text(appLocalizations.tunDesc),
      delegate: SwitchDelegate(
        value: enable,
        onChanged: (value) async {
          ref
              .read(patchClashConfigProvider.notifier)
              .updateState((state) => state.copyWith.tun(enable: value));
        },
      ),
    );
  }
}

class AllowBypassItem extends ConsumerWidget {
  const AllowBypassItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final allowBypass = ref.watch(
      vpnSettingProvider.select((state) => state.allowBypass),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.allowBypass),
      subtitle: Text(appLocalizations.allowBypassDesc),
      delegate: SwitchDelegate(
        value: allowBypass,
        onChanged: (bool value) async {
          ref
              .read(vpnSettingProvider.notifier)
              .updateState((state) => state.copyWith(allowBypass: value));
        },
      ),
    );
  }
}

class VpnSystemProxyItem extends ConsumerWidget {
  const VpnSystemProxyItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final systemProxy = ref.watch(
      vpnSettingProvider.select((state) => state.systemProxy),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.systemProxy),
      subtitle: Text(appLocalizations.systemProxyDesc),
      delegate: SwitchDelegate(
        value: systemProxy,
        onChanged: (bool value) async {
          ref
              .read(vpnSettingProvider.notifier)
              .updateState((state) => state.copyWith(systemProxy: value));
        },
      ),
    );
  }
}

class SystemProxyItem extends ConsumerWidget {
  const SystemProxyItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final systemProxy = ref.watch(
      networkSettingProvider.select((state) => state.systemProxy),
    );

    return ListItem.switchItem(
      title: Text(appLocalizations.systemProxy),
      subtitle: Text(appLocalizations.systemProxyDesc),
      delegate: SwitchDelegate(
        value: systemProxy,
        onChanged: (bool value) async {
          ref
              .read(networkSettingProvider.notifier)
              .updateState((state) => state.copyWith(systemProxy: value));
        },
      ),
    );
  }
}

class Ipv6Item extends ConsumerWidget {
  const Ipv6Item({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final ipv6 = ref.watch(vpnSettingProvider.select((state) => state.ipv6));
    return ListItem.switchItem(
      title: const Text('IPv6'),
      subtitle: Text(appLocalizations.ipv6InboundDesc),
      delegate: SwitchDelegate(
        value: ipv6,
        onChanged: (bool value) async {
          ref
              .read(vpnSettingProvider.notifier)
              .updateState((state) => state.copyWith(ipv6: value));
        },
      ),
    );
  }
}

class AutoSetSystemDnsItem extends ConsumerWidget {
  const AutoSetSystemDnsItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final autoSetSystemDns = ref.watch(
      networkSettingProvider.select((state) => state.autoSetSystemDns),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.autoSetSystemDns),
      delegate: SwitchDelegate(
        value: autoSetSystemDns,
        onChanged: (bool value) async {
          ref
              .read(networkSettingProvider.notifier)
              .updateState((state) => state.copyWith(autoSetSystemDns: value));
        },
      ),
    );
  }
}

class TunStackItem extends ConsumerWidget {
  const TunStackItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final stack = ref.watch(
      patchClashConfigProvider.select((state) => state.tun.stack),
    );

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
          ref
              .read(patchClashConfigProvider.notifier)
              .updateState((state) => state.copyWith.tun(stack: value));
        },
        title: appLocalizations.stackMode,
      ),
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
        blur: false,
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
                      .read(networkSettingProvider.notifier)
                      .updateState(
                        (state) =>
                            state.copyWith(bypassDomain: defaultBypassDomain),
                      );
                },
                tooltip: appLocalizations.reset,
                icon: const Icon(Icons.replay),
              );
            },
          ),
        ],
        title: appLocalizations.bypassDomain,
        widget: Consumer(
          builder: (_, ref, _) {
            final bypassDomain = ref.watch(
              networkSettingProvider.select((state) => state.bypassDomain),
            );
            return ListInputPage(
              title: appLocalizations.bypassDomain,
              items: bypassDomain,
              titleBuilder: (item) => Text(item),
              onChange: (items) {
                ref
                    .read(networkSettingProvider.notifier)
                    .updateState(
                      (state) => state.copyWith(bypassDomain: List.from(items)),
                    );
              },
            );
          },
        ),
      ),
    );
  }
}

class DNSHijackingItem extends ConsumerWidget {
  const DNSHijackingItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final dnsHijacking = ref.watch(
      vpnSettingProvider.select((state) => state.dnsHijacking),
    );
    return ListItem<RouteMode>.switchItem(
      title: Text(appLocalizations.dnsHijacking),
      delegate: SwitchDelegate(
        value: dnsHijacking,
        onChanged: (value) async {
          ref
              .read(vpnSettingProvider.notifier)
              .updateState((state) => state.copyWith(dnsHijacking: value));
        },
      ),
    );
  }
}

class RouteModeItem extends ConsumerWidget {
  const RouteModeItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final routeMode = ref.watch(
      networkSettingProvider.select((state) => state.routeMode),
    );
    return ListItem<RouteMode>.options(
      title: Text(appLocalizations.routeMode),
      subtitle: Text(Intl.message('routeMode_${routeMode.name}')),
      delegate: OptionsDelegate<RouteMode>(
        title: appLocalizations.routeMode,
        options: RouteMode.values,
        onChanged: (RouteMode? value) {
          if (value == null) {
            return;
          }
          ref
              .read(networkSettingProvider.notifier)
              .updateState((state) => state.copyWith(routeMode: value));
        },
        textBuilder: (routeMode) => Intl.message('routeMode_${routeMode.name}'),
        value: routeMode,
      ),
    );
  }
}

class RouteAddressItem extends ConsumerWidget {
  const RouteAddressItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final bypassPrivate = ref.watch(
      networkSettingProvider.select(
        (state) => state.routeMode == RouteMode.bypassPrivate,
      ),
    );
    if (bypassPrivate) {
      return Container();
    }
    return ListItem.open(
      title: Text(appLocalizations.routeAddress),
      subtitle: Text(appLocalizations.routeAddressDesc),
      delegate: OpenDelegate(
        blur: false,
        maxWidth: 360,
        title: appLocalizations.routeAddress,
        widget: Consumer(
          builder: (_, ref, _) {
            final routeAddress = ref.watch(
              patchClashConfigProvider.select(
                (state) => state.tun.routeAddress,
              ),
            );
            return ListInputPage(
              title: appLocalizations.routeAddress,
              items: routeAddress,
              titleBuilder: (item) => Text(item),
              onChange: (items) {
                ref
                    .read(patchClashConfigProvider.notifier)
                    .updateState(
                      (state) =>
                          state.copyWith.tun(routeAddress: List.from(items)),
                    );
              },
            );
          },
        ),
      ),
    );
  }
}

final networkItems = [
  if (system.isAndroid) const VPNItem(),
  if (system.isAndroid)
    ...generateSection(
      title: 'VPN',
      items: [
        const VpnSystemProxyItem(),
        const BypassDomainItem(),
        const AllowBypassItem(),
        const Ipv6Item(),
        const DNSHijackingItem(),
      ],
    ),
  if (system.isDesktop)
    ...generateSection(
      title: appLocalizations.system,
      items: [SystemProxyItem(), BypassDomainItem()],
    ),
  ...generateSection(
    title: appLocalizations.options,
    items: [
      if (system.isDesktop) const TUNItem(),
      if (system.isMacOS) const AutoSetSystemDnsItem(),
      const TunStackItem(),
      if (!system.isDesktop) ...[
        const RouteModeItem(),
        const RouteAddressItem(),
      ],
    ],
  ),
];

class NetworkListView extends StatelessWidget {
  const NetworkListView({super.key});

  @override
  Widget build(BuildContext context) {
    return generateListView(networkItems);
  }
}
