import 'package:fl_clash/common/common.dart';
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
          leading: const Icon(Icons.stacked_line_chart),
          title: const Text("VPN"),
          subtitle: Text(appLocalizations.vpnEnableDesc),
          delegate: SwitchDelegate(
            value: enable,
            onChanged: (bool value) async {
              final config = globalState.appController.config;
              final vpnProps = config.vpnProps;
              config.vpnProps = vpnProps.copyWith(
                enable: value,
              );
            },
          ),
        );
      },
    );
  }
}

class VPNDisabledContainer extends StatelessWidget {
  final Widget child;

  const VPNDisabledContainer(
    this.child, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<Config, bool>(
      selector: (_, config) => config.vpnProps.enable,
      builder: (_, enable, child) {
        return AbsorbPointer(
          absorbing: !enable,
          child: DisabledMask(
            status: !enable,
            child: child!,
          ),
        );
      },
      child: child,
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
          leading: const Icon(Icons.arrow_forward_outlined),
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
          leading: const Icon(Icons.settings_ethernet),
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

class VpnOptions extends StatelessWidget {
  const VpnOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return VPNDisabledContainer(
      Column(
        children: generateSection(
          title: appLocalizations.options,
          items: [
            const SystemProxySwitch(),
            const AllowBypassSwitch(),
          ],
        ),
      ),
    );
  }
}

final vpnItems = [
  const VPNSwitch(),
  const VpnOptions(),
];
