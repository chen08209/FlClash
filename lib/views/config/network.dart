import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' show dirname, join;

typedef _VpnUpdate<T> = VpnProps Function(VpnProps state, T value);

typedef _NetworkUpdate<T> = NetworkProps Function(NetworkProps state, T value);

typedef _TunUpdate<T> =
    PatchClashConfig Function(PatchClashConfig state, T value);

ConfigWriter<T> _vpnWriter<T>(_VpnUpdate<T> update) {
  return (ref, value) => ref
      .read(vpnSettingProvider.notifier)
      .update((state) => update(state, value));
}

ConfigWriter<T> _networkWriter<T>(_NetworkUpdate<T> update) {
  return (ref, value) => ref
      .read(networkSettingProvider.notifier)
      .update((state) => update(state, value));
}

ConfigWriter<T> _tunWriter<T>(_TunUpdate<T> update) {
  return (ref, value) => ref
      .read(patchClashConfigProvider.notifier)
      .update((state) => update(state, value));
}

ConfigToggleItem _vpnToggle({
  required ConfigLabel title,
  required bool Function(VpnProps state) select,
  required _VpnUpdate<bool> update,
  ConfigLabel? subtitle,
}) {
  return ConfigToggleItem(
    title: title,
    subtitle: subtitle,
    selector: vpnSettingProvider.select(select),
    onChanged: _vpnWriter(update),
  );
}

ConfigToggleItem _networkToggle({
  required ConfigLabel title,
  required bool Function(NetworkProps state) select,
  required _NetworkUpdate<bool> update,
  ConfigLabel? subtitle,
}) {
  return ConfigToggleItem(
    title: title,
    subtitle: subtitle,
    selector: networkSettingProvider.select(select),
    onChanged: _networkWriter(update),
  );
}

class VPNItem extends ConsumerWidget {
  const VPNItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return _vpnToggle(
      title: (l) => 'VPN',
      subtitle: (l) => l.vpnEnableDesc,
      select: (state) => state.enable,
      update: (state, value) => state.copyWith(enable: value),
    );
  }
}

class TUNItem extends ConsumerWidget {
  const TUNItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ConfigToggleItem(
      title: (l) => l.tun,
      subtitle: (l) => l.tunDesc,
      selector: patchClashConfigProvider.select((state) => state.tun.enable),
      onChanged: _tunWriter(
        (state, value) => state.copyWith.tun(enable: value),
      ),
    );
  }
}

class AllowBypassItem extends ConsumerWidget {
  const AllowBypassItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return _vpnToggle(
      title: (l) => l.allowBypass,
      select: (state) => state.allowBypass,
      update: (state, value) => state.copyWith(allowBypass: value),
    );
  }
}

class VpnSystemProxyItem extends ConsumerWidget {
  const VpnSystemProxyItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final authenticationEnable = ref.watch(
      networkSettingProvider.select((state) => state.authentication.enable),
    );
    return _vpnToggle(
      title: (l) => l.systemProxy,
      subtitle: authenticationEnable
          ? (l) => l.authenticationSystemProxyDesc
          : null,
      select: (state) => state.systemProxy,
      update: (state, value) => state.copyWith(systemProxy: value),
    );
  }
}

class SystemProxyItem extends ConsumerWidget {
  const SystemProxyItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return _networkToggle(
      title: (l) => l.systemProxy,
      select: (state) => state.systemProxy,
      update: (state, value) => state.copyWith(systemProxy: value),
    );
  }
}

class Ipv6Item extends ConsumerWidget {
  const Ipv6Item({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return _vpnToggle(
      title: (l) => 'IPv6',
      subtitle: (l) => l.ipv6InboundDesc,
      select: (state) => state.ipv6,
      update: (state, value) => state.copyWith(ipv6: value),
    );
  }
}

class AutoSetSystemDnsItem extends ConsumerWidget {
  const AutoSetSystemDnsItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return _networkToggle(
      title: (l) => l.autoSetSystemDns,
      select: (state) => state.autoSetSystemDns,
      update: (state, value) => state.copyWith(autoSetSystemDns: value),
    );
  }
}

class DNSHijackingItem extends ConsumerWidget {
  const DNSHijackingItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return _vpnToggle(
      title: (l) => l.dnsHijacking,
      select: (state) => state.dnsHijacking,
      update: (state, value) => state.copyWith(dnsHijacking: value),
    );
  }
}

class TunStackItem extends ConsumerWidget {
  const TunStackItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ConfigOptionsItem<TunStack>(
      title: (l) => l.stackMode,
      options: TunStack.values,
      textBuilder: (stack) => stack.name,
      selector: patchClashConfigProvider.select((state) => state.tun.stack),
      onChanged: _tunWriter((state, value) => state.copyWith.tun(stack: value)),
    );
  }
}

class InterfaceNameModeItem extends ConsumerWidget {
  const InterfaceNameModeItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    return ConfigOptionsItem<InterfaceNameMode>(
      title: (l) => l.interfaceNameMode,
      options: InterfaceNameMode.values,
      textBuilder: (mode) => switch (mode) {
        InterfaceNameMode.clear => appLocalizations.interfaceNameModeClear,
        InterfaceNameMode.follow => appLocalizations.interfaceNameModeFollow,
        InterfaceNameMode.custom => appLocalizations.interfaceNameModeCustom,
      },
      selector: patchClashConfigProvider.select(
        (state) => state.interfaceNameMode,
      ),
      onChanged: _tunWriter(
        (state, value) => state.copyWith(interfaceNameMode: value),
      ),
    );
  }
}

class InterfaceNameItem extends ConsumerWidget {
  const InterfaceNameItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ConfigTextItem(
      title: (l) => l.interfaceName,
      subtitle: (l) => l.interfaceNameDesc,
      maxLength: TextInputLimits.name,
      selector: patchClashConfigProvider.select((state) => state.interfaceName),
      onChanged: _tunWriter(
        (state, value) => state.copyWith(interfaceName: value.trim()),
      ),
    );
  }
}

class RouteModeItem extends ConsumerWidget {
  const RouteModeItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ConfigOptionsItem<RouteMode>(
      title: (l) => l.routeMode,
      options: RouteMode.values,
      textBuilder: (mode) => mode.label,
      selector: networkSettingProvider.select((state) => state.routeMode),
      onChanged: _networkWriter(
        (state, value) => state.copyWith(routeMode: value),
      ),
    );
  }
}

class BypassDomainItem extends ConsumerWidget {
  const BypassDomainItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ConfigListEditItem(
      title: (l) => l.bypassDomain,
      subtitle: (l) => l.bypassDomainDesc,
      itemMaxLength: TextInputLimits.domain,
      selector: networkSettingProvider.select((state) => state.bypassDomain),
      onChanged: _networkWriter(
        (state, value) => state.copyWith(bypassDomain: value),
      ),
    );
  }
}

class RouteAddressItem extends ConsumerWidget {
  const RouteAddressItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ConfigListEditItem(
      title: (l) => l.routeAddress,
      itemMaxLength: TextInputLimits.cidr,
      maxWidth: 360,
      selector: patchClashConfigProvider.select(
        (state) => state.tun.routeAddress,
      ),
      onChanged: _tunWriter(
        (state, value) => state.copyWith.tun(routeAddress: value),
      ),
    );
  }
}

class LoopbackItem extends StatelessWidget {
  const LoopbackItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ListItem(
      title: Text(context.appLocalizations.loopback),
      onTap: () {
        windows?.runas(
          '"${join(dirname(Platform.resolvedExecutable), "EnableLoopback.exe")}"',
          '',
        );
      },
    );
  }
}

List<Widget> networkOptionsItems({
  required bool isDesktop,
  required bool isMacOS,
  required bool isCustomInterfaceName,
  required bool isBypassPrivateRoute,
}) {
  return [
    if (isDesktop) const TUNItem(),
    if (isMacOS) const AutoSetSystemDnsItem(),
    const TunStackItem(),
    // mihomo's DefaultSocketHook ignores interface-name on Android
    // (core/lib.go installHooks, vendored dialer.go), so these rows only
    // apply on desktop.
    if (isDesktop) ...[
      const InterfaceNameModeItem(),
      if (isCustomInterfaceName) const InterfaceNameItem(),
    ],
    if (!isDesktop) ...[
      const RouteModeItem(),
      if (!isBypassPrivateRoute) const RouteAddressItem(),
    ],
  ];
}

class VpnSections extends StatelessWidget {
  const VpnSections({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        generateSectionV3(items: const [VPNItem()]),
        generateSectionV3(
          title: 'VPN',
          items: const [
            VpnSystemProxyItem(),
            BypassDomainItem(),
            AllowBypassItem(),
            Ipv6Item(),
            DNSHijackingItem(),
          ],
        ),
      ],
    );
  }
}

class SystemProxySection extends StatelessWidget {
  const SystemProxySection({super.key});

  @override
  Widget build(BuildContext context) {
    return generateSectionV3(
      title: context.appLocalizations.system,
      items: [
        const SystemProxyItem(),
        const BypassDomainItem(),
        if (system.isWindows) const LoopbackItem(),
      ],
    );
  }
}

class NetworkOptionsSection extends ConsumerWidget {
  const NetworkOptionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCustomInterfaceName = ref.watch(
      patchClashConfigProvider.select(
        (state) => state.interfaceNameMode == InterfaceNameMode.custom,
      ),
    );
    final isBypassPrivateRoute = ref.watch(
      networkSettingProvider.select(
        (state) => state.routeMode == RouteMode.bypassPrivate,
      ),
    );
    return generateSectionV3(
      title: context.appLocalizations.options,
      items: networkOptionsItems(
        isDesktop: system.isDesktop,
        isMacOS: system.isMacOS,
        isCustomInterfaceName: isCustomInterfaceName,
        isBypassPrivateRoute: isBypassPrivateRoute,
      ),
    );
  }
}

class NetworkListView extends StatelessWidget {
  const NetworkListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ).copyWith(top: context.contentTopPadding, bottom: 16),
      children: [
        if (system.isAndroid) const VpnSections(),
        if (system.isDesktop) const SystemProxySection(),
        const NetworkOptionsSection(),
      ],
    );
  }
}
