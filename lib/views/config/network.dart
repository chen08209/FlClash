import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

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
      subtitle: (l) => l.allowBypassDesc,
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
      subtitle: (l) => authenticationEnable
          ? l.authenticationSystemProxyDesc
          : l.systemProxyDesc,
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
      subtitle: (l) => l.systemProxyDesc,
      select: (state) => state.systemProxy,
      update: (state, value) => state.copyWith(systemProxy: value),
    );
  }
}

class AllowLanItem extends ConsumerWidget {
  const AllowLanItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ConfigToggleItem(
      title: (l) => l.allowLan,
      subtitle: (l) => l.allowLanDesc,
      selector: patchClashConfigProvider.select((state) => state.allowLan),
      onChanged: _tunWriter((state, value) => state.copyWith(allowLan: value)),
    );
  }
}

class ProxyPortItem extends ConsumerStatefulWidget {
  const ProxyPortItem({super.key});

  @override
  ConsumerState<ProxyPortItem> createState() => _ProxyPortItemState();
}

class _ProxyPortItemState extends ConsumerState<ProxyPortItem> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  int get _port =>
      ref.read(patchClashConfigProvider.select((state) => state.mixedPort));

  @override
  void initState() {
    super.initState();
    _controller.text = '$_port';
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus || !mounted) {
      return;
    }
    final appLocalizations = context.appLocalizations;
    final value = _controller.text;
    final port = int.tryParse(value);
    if (port == null || !isValidProxyPort(port)) {
      _controller.text = '$_port';
      context.showNotifier(
        value.isEmpty
            ? appLocalizations.emptyTip(appLocalizations.port)
            : appLocalizations.portTip(appLocalizations.port),
        level: MessageLevel.error,
      );
      return;
    }
    if (port == _port) {
      return;
    }
    ref
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(mixedPort: port));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(patchClashConfigProvider.select((state) => state.mixedPort), (
      _,
      next,
    ) {
      if (!_focusNode.hasFocus) {
        _controller.text = '$next';
      }
    });
    return ListItem(
      title: Text(context.appLocalizations.port),
      trailing: SizedBox(
        width: 96,
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          keyboardType: TextInputType.number,
          inputFormatters: TextInputLimits.digitsOnly(TextInputLimits.port),
          textAlign: TextAlign.end,
          onSubmitted: (_) => _focusNode.unfocus(),
          decoration: const InputDecoration.collapsed(
            hintText: '',
            border: NoInputBorder(),
          ),
        ),
      ),
    );
  }
}

class CopyProxyCommandItem extends ConsumerStatefulWidget {
  const CopyProxyCommandItem({super.key});

  @override
  ConsumerState<CopyProxyCommandItem> createState() =>
      _CopyProxyCommandItemState();
}

class _CopyProxyCommandItemState extends ConsumerState<CopyProxyCommandItem> {
  late ProxyCommandOs _selectedOs;

  @override
  void initState() {
    super.initState();
    _selectedOs = proxyCommandOsForPlatform(
      isWindows: system.isWindows,
      isMacOS: system.isMacOS,
    );
  }

  Future<void> _copy(int port) async {
    final allowLan = ref.read(
      patchClashConfigProvider.select((state) => state.allowLan),
    );
    final localIp = ref.read(localIpProvider);
    await Clipboard.setData(
      ClipboardData(
        text: buildProxyEnvCommand(
          port: port,
          os: _selectedOs,
          host: proxyHostForCommand(allowLan: allowLan, localIp: localIp),
        ),
      ),
    );
    if (mounted) {
      context.showNotifier(context.appLocalizations.copySuccess);
    }
  }

  @override
  Widget build(BuildContext context) {
    final port = ref.watch(
      patchClashConfigProvider.select((state) => state.mixedPort),
    );
    return ListItem(
      title: Text(context.appLocalizations.copyEnvVar),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 96,
            child: DropdownButton<ProxyCommandOs>(
              value: _selectedOs,
              isDense: true,
              isExpanded: true,
              focusColor: Colors.transparent,
              underline: const SizedBox.shrink(),
              items: [
                for (final os in ProxyCommandOs.values)
                  DropdownMenuItem(value: os, child: Text(os.label)),
              ],
              onChanged: (os) {
                if (os != null) {
                  setState(() => _selectedOs = os);
                }
              },
            ),
          ),
          IconButton(
            tooltip: context.appLocalizations.copyEnvVar,
            onPressed: () => _copy(port),
            icon: const Icon(Icons.copy),
          ),
        ],
      ),
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
    final isCustom = ref.watch(
      patchClashConfigProvider.select(
        (state) => state.interfaceNameMode == InterfaceNameMode.custom,
      ),
    );
    if (!isCustom) {
      return Container();
    }
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
    return ConfigListInputItem(
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
    final bypassPrivate = ref.watch(
      networkSettingProvider.select(
        (state) => state.routeMode == RouteMode.bypassPrivate,
      ),
    );
    if (bypassPrivate) {
      return Container();
    }
    return ConfigListInputItem(
      title: (l) => l.routeAddress,
      subtitle: (l) => l.routeAddressDesc,
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

List<Widget> networkOptionsItems({
  required bool isDesktop,
  required bool isMacOS,
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
      const InterfaceNameItem(),
    ],
    if (!isDesktop) ...[const RouteModeItem(), const RouteAddressItem()],
  ];
}

class NetworkListView extends StatelessWidget {
  const NetworkListView({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return generateListView([
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
          items: [const SystemProxyItem(), const BypassDomainItem()],
        ),
      ...generateSection(
        title: appLocalizations.options,
        items: networkOptionsItems(
          isDesktop: system.isDesktop,
          isMacOS: system.isMacOS,
        ),
      ),
    ]);
  }
}
