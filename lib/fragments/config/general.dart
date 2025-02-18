import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LogLevelItem extends StatelessWidget {
  const LogLevelItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<Config, LogLevel>(
      selector: (_, config) => config.patchClashConfig.logLevel,
      builder: (_, value, __) {
        return ListItem<LogLevel>.options(
          leading: const Icon(Icons.info_outline),
          title: Text(appLocalizations.logLevel),
          subtitle: Text(value.name),
          delegate: OptionsDelegate<LogLevel>(
            title: appLocalizations.logLevel,
            options: LogLevel.values,
            onChanged: (LogLevel? value) {
              if (value == null) {
                return;
              }
              final config = globalState.appController.config;
              config.patchClashConfig = config.patchClashConfig.copyWith(
                logLevel: value,
              );
            },
            textBuilder: (logLevel) => logLevel.name,
            value: value,
          ),
        );
      },
    );
  }
}

class UaItem extends StatelessWidget {
  const UaItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<Config, String?>(
      selector: (_, config) => config.patchClashConfig.globalUa,
      builder: (_, value, __) {
        return ListItem<String?>.options(
          leading: const Icon(Icons.computer_outlined),
          title: const Text("UA"),
          subtitle: Text(value ?? appLocalizations.defaultText),
          delegate: OptionsDelegate<String?>(
            title: "UA",
            options: [
              null,
              "clash-verge/v1.6.6",
              "ClashforWindows/0.19.23",
            ],
            value: value,
            onChanged: (ua) {
              final config = globalState.appController.config;
              config.patchClashConfig = config.patchClashConfig.copyWith(
                globalUa: ua,
              );
            },
            textBuilder: (ua) =>
                ua ?? appLocalizations.defaultText,
          ),
        );
      },
    );
  }
}

class KeepAliveIntervalItem extends StatelessWidget {
  const KeepAliveIntervalItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<Config, int>(
      selector: (_, config) => config.patchClashConfig.keepAliveInterval,
      builder: (_, value, __) {
        return ListItem.input(
          leading: const Icon(Icons.timer_outlined),
          title: Text(appLocalizations.keepAliveIntervalDesc),
          subtitle: Text("$value ${appLocalizations.seconds}"),
          delegate: InputDelegate(
            title: appLocalizations.keepAliveIntervalDesc,
            suffixText: appLocalizations.seconds,
            resetValue: "$defaultKeepAliveInterval",
            value: "$value",
            onChanged: (String? value) {
              if (value != null) {
                try {
                  final intValue = int.parse(value);
                  if (intValue <= 0) {
                    throw "Invalid keepAliveInterval";
                  }

                  final config = globalState.appController.config;
                  config.patchClashConfig = config.patchClashConfig.copyWith(
                    keepAliveInterval: intValue,
                  );
                } catch (e) {
                  globalState.showMessage(
                    title: appLocalizations.keepAliveIntervalDesc,
                    message: TextSpan(
                      text: e.toString(),
                    ),
                  );
                }
              }
            },
          ),
        );
      },
    );
  }
}

class TestUrlItem extends StatelessWidget {
  const TestUrlItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<Config, String>(
      selector: (_, config) => config.appSetting.testUrl,
      builder: (_, value, __) {
        return ListItem.input(
          leading: const Icon(Icons.timeline),
          title: Text(appLocalizations.testUrl),
          subtitle: Text(value),
          delegate: InputDelegate(
            resetValue: defaultTestUrl,
            title: appLocalizations.testUrl,
            value: value,
            onChanged: (String? value) {
              if (value != null) {
                try {
                  if (!value.isUrl) {
                    throw "Invalid url";
                  }
                  final config = globalState.appController.config;
                  config.appSetting = config.appSetting.copyWith(
                    testUrl: value,
                  );
                } catch (e) {
                  globalState.showMessage(
                    title: appLocalizations.testUrl,
                    message: TextSpan(
                      text: e.toString(),
                    ),
                  );
                }
              }
            },
          ),
        );
      },
    );
  }
}

class MixedPortItem extends StatelessWidget {
  const MixedPortItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<Config, int>(
      selector: (_, config) => config.patchClashConfig.mixedPort,
      builder: (_, value, __) {
        return ListItem.input(
          leading: const Icon(Icons.adjust_outlined),
          title: Text(appLocalizations.proxyPort),
          subtitle: Text("$value"),
          delegate: InputDelegate(
            title: appLocalizations.proxyPort,
            value: "$value",
            onChanged: (String? value) {
              if (value != null) {
                try {
                  final mixedPort = int.parse(value);
                  if (mixedPort < 1024 || mixedPort > 49151) {
                    throw "Invalid port";
                  }
                  final config = globalState.appController.config;
                  config.patchClashConfig = config.patchClashConfig.copyWith(
                    mixedPort: mixedPort,
                  );
                } catch (e) {
                  globalState.showMessage(
                    title: appLocalizations.proxyPort,
                    message: TextSpan(
                      text: e.toString(),
                    ),
                  );
                }
              }
            },
            resetValue: "$defaultMixedPort",
          ),
        );
      },
    );
  }
}

class HostsItem extends StatelessWidget {
  const HostsItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.view_list_outlined),
      title: const Text("Hosts"),
      subtitle: Text(appLocalizations.hostsDesc),
      delegate: OpenDelegate(
        isBlur: false,
        title: "Hosts",
        widget: Selector<Config, HostsMap>(
          selector: (_, config) => config.patchClashConfig.hosts,
          shouldRebuild: (prev, next) =>
              !stringAndStringMapEquality.equals(prev, next),
          builder: (_, hosts, ___) {
            final entries = hosts.entries;
            return ListPage(
              title: "Hosts",
              items: entries,
              titleBuilder: (item) => Text(item.key),
              subtitleBuilder: (item) => Text(item.value),
              onChange: (items) {
                final config = globalState.appController.config;
                config.patchClashConfig = config.patchClashConfig.copyWith(
                  hosts: Map.fromEntries(items),
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

class Ipv6Item extends StatelessWidget {
  const Ipv6Item({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<Config, bool>(
      selector: (_, config) => config.patchClashConfig.ipv6,
      builder: (_, ipv6, __) {
        return ListItem.switchItem(
          leading: const Icon(Icons.water_outlined),
          title: const Text("IPv6"),
          subtitle: Text(appLocalizations.ipv6Desc),
          delegate: SwitchDelegate(
            value: ipv6,
            onChanged: (bool value) async {
              final config = globalState.appController.config;
              config.patchClashConfig = config.patchClashConfig.copyWith(
                ipv6: value,
              );
            },
          ),
        );
      },
    );
  }
}

class AllowLanItem extends StatelessWidget {
  const AllowLanItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<Config, bool>(
      selector: (_, config) => config.patchClashConfig.allowLan,
      builder: (_, allowLan, __) {
        return ListItem.switchItem(
          leading: const Icon(Icons.device_hub),
          title: Text(appLocalizations.allowLan),
          subtitle: Text(appLocalizations.allowLanDesc),
          delegate: SwitchDelegate(
            value: allowLan,
            onChanged: (bool value) async {
              final config = globalState.appController.config;
              config.patchClashConfig = config.patchClashConfig.copyWith(
                allowLan: value,
              );
            },
          ),
        );
      },
    );
  }
}

class UnifiedDelayItem extends StatelessWidget {
  const UnifiedDelayItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<Config, bool>(
      selector: (_, config) => config.patchClashConfig.unifiedDelay,
      builder: (_, unifiedDelay, __) {
        return ListItem.switchItem(
          leading: const Icon(Icons.compress_outlined),
          title: Text(appLocalizations.unifiedDelay),
          subtitle: Text(appLocalizations.unifiedDelayDesc),
          delegate: SwitchDelegate(
            value: unifiedDelay,
            onChanged: (bool value) async {
              final config = globalState.appController.config;
              config.patchClashConfig = config.patchClashConfig.copyWith(
                unifiedDelay: value,
              );
            },
          ),
        );
      },
    );
  }
}

class FindProcessItem extends StatelessWidget {
  const FindProcessItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<Config, bool>(
      selector: (_, config) =>
          config.patchClashConfig.findProcessMode == FindProcessMode.always,
      builder: (_, findProcess, __) {
        return ListItem.switchItem(
          leading: const Icon(Icons.polymer_outlined),
          title: Text(appLocalizations.findProcessMode),
          subtitle: Text(appLocalizations.findProcessModeDesc),
          delegate: SwitchDelegate(
            value: findProcess,
            onChanged: (bool value) async {
              final config = globalState.appController.config;
              config.patchClashConfig = config.patchClashConfig.copyWith(
                findProcessMode:
                    value ? FindProcessMode.always : FindProcessMode.off,
              );
            },
          ),
        );
      },
    );
  }
}

class TcpConcurrentItem extends StatelessWidget {
  const TcpConcurrentItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<Config, bool>(
      selector: (_, config) => config.patchClashConfig.tcpConcurrent,
      builder: (_, tcpConcurrent, __) {
        return ListItem.switchItem(
          leading: const Icon(Icons.double_arrow_outlined),
          title: Text(appLocalizations.tcpConcurrent),
          subtitle: Text(appLocalizations.tcpConcurrentDesc),
          delegate: SwitchDelegate(
            value: tcpConcurrent,
            onChanged: (bool value) async {
              final config = globalState.appController.config;
              config.patchClashConfig = config.patchClashConfig.copyWith(
                tcpConcurrent: value,
              );
            },
          ),
        );
      },
    );
  }
}

class GeodataLoaderItem extends StatelessWidget {
  const GeodataLoaderItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<Config, bool>(
      selector: (_, config) =>
          config.patchClashConfig.geodataLoader == GeodataLoader.memconservative,
      builder: (_, isMemconservative, __) {
        return ListItem.switchItem(
          leading: const Icon(Icons.memory),
          title: Text(appLocalizations.geodataLoader),
          subtitle: Text(appLocalizations.geodataLoaderDesc),
          delegate: SwitchDelegate(
            value: isMemconservative,
            onChanged: (bool value) async {
              final config = globalState.appController.config;
              config.patchClashConfig = config.patchClashConfig.copyWith(
                geodataLoader: value
                    ? GeodataLoader.memconservative
                    : GeodataLoader.standard,
              );
            },
          ),
        );
      },
    );
  }
}

class ExternalControllerItem extends StatelessWidget {
  const ExternalControllerItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<Config, bool>(
      selector: (_, config) =>
          config.patchClashConfig.externalController ==
          ExternalControllerStatus.open,
      builder: (_, hasExternalController, __) {
        return ListItem.switchItem(
          leading: const Icon(Icons.api_outlined),
          title: Text(appLocalizations.externalController),
          subtitle: Text(appLocalizations.externalControllerDesc),
          delegate: SwitchDelegate(
            value: hasExternalController,
            onChanged: (bool value) async {
              final config = globalState.appController.config;
              config.patchClashConfig = config.patchClashConfig.copyWith(
                externalController: value
                    ? ExternalControllerStatus.open
                    : ExternalControllerStatus.close,
              );
            },
          ),
        );
      },
    );
  }
}

final generalItems = [
  LogLevelItem(),
  UaItem(),
  if (system.isDesktop) KeepAliveIntervalItem(),
  TestUrlItem(),
  MixedPortItem(),
  HostsItem(),
  Ipv6Item(),
  AllowLanItem(),
  UnifiedDelayItem(),
  FindProcessItem(),
  TcpConcurrentItem(),
  GeodataLoaderItem(),
  ExternalControllerItem(),
]
    .separated(
      const Divider(
        height: 0,
      ),
    )
    .toList();
