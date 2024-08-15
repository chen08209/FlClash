import 'package:fl_clash/common/app_localizations.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VPNSwitch extends StatelessWidget {
  const VPNSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return SwitchContainer(
      info: const Info(
        label: "VPN",
        iconData: Icons.stacked_line_chart,
      ),
      child: Selector<Config, bool>(
        selector: (_, config) => config.vpnProps.enable,
        builder: (_, enable, __) {
          return Switch(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            value: enable,
            onChanged: (value) {
              final config = globalState.appController.config;
              config.vpnProps = config.vpnProps.copyWith(
                enable: value,
              );
            },
          );
        },
      ),
    );
  }
}

class TUNSwitch extends StatelessWidget {
  const TUNSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return SwitchContainer(
      info: Info(
        label: appLocalizations.tun,
        iconData: Icons.stacked_line_chart,
      ),
      child: Selector<ClashConfig, bool>(
        selector: (_, clashConfig) => clashConfig.tun.enable,
        builder: (_, enable, __) {
          return Switch(
            value: enable,
            onChanged: (value) {
              final clashConfig = globalState.appController.clashConfig;
              clashConfig.tun = clashConfig.tun.copyWith(
                enable: value,
              );
            },
          );
        },
      ),
    );
  }
}

class ProxySwitch extends StatelessWidget {
  const ProxySwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return SwitchContainer(
      info: Info(
        label: appLocalizations.systemProxy,
        iconData: Icons.shuffle,
      ),
      child: Selector<Config, bool>(
        selector: (_, config) => config.desktopProps.systemProxy,
        builder: (_, systemProxy, __) {
          return Switch(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            value: systemProxy,
            onChanged: (value) {
              final config = globalState.appController.config;
              config.desktopProps =
                  config.desktopProps.copyWith(systemProxy: value);
            },
          );
        },
      ),
    );
  }
}

class SwitchContainer extends StatelessWidget {
  final Info info;
  final Widget child;

  const SwitchContainer({
    super.key,
    required this.info,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      onPressed: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoHeader(
            info: info,
            actions: [
              child,
            ],
          ),
        ],
      ),
    );
  }
}
