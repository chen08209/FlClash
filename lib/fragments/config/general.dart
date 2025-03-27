import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LogLevelItem extends ConsumerWidget {
  const LogLevelItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final logLevel =
        ref.watch(patchClashConfigProvider.select((state) => state.logLevel));
    return ListItem<LogLevel>.options(
      leading: const Icon(Icons.info_outline),
      title: Text(appLocalizations.logLevel),
      subtitle: Text(logLevel.name),
      delegate: OptionsDelegate<LogLevel>(
        title: appLocalizations.logLevel,
        options: LogLevel.values,
        onChanged: (LogLevel? value) {
          if (value == null) {
            return;
          }
          ref.read(patchClashConfigProvider.notifier).updateState(
                (state) => state.copyWith(
                  logLevel: value,
                ),
              );
        },
        textBuilder: (logLevel) => logLevel.name,
        value: logLevel,
      ),
    );
  }
}

class UaItem extends ConsumerWidget {
  const UaItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final globalUa =
        ref.watch(patchClashConfigProvider.select((state) => state.globalUa));
    return ListItem<String?>.options(
      leading: const Icon(Icons.computer_outlined),
      title: const Text("UA"),
      subtitle: Text(globalUa ?? appLocalizations.defaultText),
      delegate: OptionsDelegate<String?>(
        title: "UA",
        options: [
          null,
          "clash-verge/v1.6.6",
          "ClashforWindows/0.19.23",
        ],
        value: globalUa,
        onChanged: (value) {
          ref.read(patchClashConfigProvider.notifier).updateState(
                (state) => state.copyWith(
                  globalUa: value,
                ),
              );
        },
        textBuilder: (ua) => ua ?? appLocalizations.defaultText,
      ),
    );
  }
}

class KeepAliveIntervalItem extends ConsumerWidget {
  const KeepAliveIntervalItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final keepAliveInterval = ref.watch(
        patchClashConfigProvider.select((state) => state.keepAliveInterval));
    return ListItem.input(
      leading: const Icon(Icons.timer_outlined),
      title: Text(appLocalizations.keepAliveIntervalDesc),
      subtitle: Text("$keepAliveInterval ${appLocalizations.seconds}"),
      delegate: InputDelegate(
        title: appLocalizations.keepAliveIntervalDesc,
        suffixText: appLocalizations.seconds,
        resetValue: "$defaultKeepAliveInterval",
        value: "$keepAliveInterval",
        onChanged: (String? value) {
          if (value == null) {
            return;
          }
          globalState.safeRun(
            () {
              final intValue = int.parse(value);
              if (intValue <= 0) {
                throw "Invalid keepAliveInterval";
              }
              ref.read(patchClashConfigProvider.notifier).updateState(
                    (state) => state.copyWith(
                      keepAliveInterval: intValue,
                    ),
                  );
            },
            silence: false,
            title: appLocalizations.keepAliveIntervalDesc,
          );
        },
      ),
    );
  }
}

class TestUrlItem extends ConsumerWidget {
  const TestUrlItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final testUrl =
        ref.watch(appSettingProvider.select((state) => state.testUrl));
    return ListItem.input(
      leading: const Icon(Icons.timeline),
      title: Text(appLocalizations.testUrl),
      subtitle: Text(testUrl),
      delegate: InputDelegate(
          resetValue: defaultTestUrl,
          title: appLocalizations.testUrl,
          value: testUrl,
          onChanged: (String? value) {
            if (value == null) {
              return;
            }
            globalState.safeRun(
              () {
                if (!value.isUrl) {
                  throw "Invalid url";
                }
                ref.read(appSettingProvider.notifier).updateState(
                      (state) => state.copyWith(
                        testUrl: value,
                      ),
                    );
              },
              silence: false,
              title: appLocalizations.testUrl,
            );
          }),
    );
  }
}

class MixedPortItem extends ConsumerWidget {
  const MixedPortItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final mixedPort =
        ref.watch(patchClashConfigProvider.select((state) => state.mixedPort));
    return ListItem.input(
      leading: const Icon(Icons.adjust_outlined),
      title: Text(appLocalizations.proxyPort),
      subtitle: Text("$mixedPort"),
      delegate: InputDelegate(
        title: appLocalizations.proxyPort,
        value: "$mixedPort",
        onChanged: (String? value) {
          if (value == null) {
            return;
          }
          globalState.safeRun(
            () {
              final mixedPort = int.parse(value);
              if (mixedPort < 1024 || mixedPort > 49151) {
                throw "Invalid port";
              }
              ref.read(patchClashConfigProvider.notifier).updateState(
                    (state) => state.copyWith(
                      mixedPort: mixedPort,
                    ),
                  );
            },
            silence: false,
            title: appLocalizations.proxyPort,
          );
        },
        resetValue: "$defaultMixedPort",
      ),
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
        widget: Consumer(
          builder: (_, ref, __) {
            final hosts = ref
                .watch(patchClashConfigProvider.select((state) => state.hosts));
            return ListPage(
              title: "Hosts",
              items: hosts.entries,
              titleBuilder: (item) => Text(item.key),
              subtitleBuilder: (item) => Text(item.value),
              onChange: (items) {
                ref.read(patchClashConfigProvider.notifier).updateState(
                      (state) => state.copyWith(
                        hosts: Map.fromEntries(items),
                      ),
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

class Ipv6Item extends ConsumerWidget {
  const Ipv6Item({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final ipv6 =
        ref.watch(patchClashConfigProvider.select((state) => state.ipv6));
    return ListItem.switchItem(
      leading: const Icon(Icons.water_outlined),
      title: const Text("IPv6"),
      subtitle: Text(appLocalizations.ipv6Desc),
      delegate: SwitchDelegate(
        value: ipv6,
        onChanged: (bool value) async {
          ref.read(patchClashConfigProvider.notifier).updateState(
                (state) => state.copyWith(
                  ipv6: value,
                ),
              );
        },
      ),
    );
  }
}

class AllowLanItem extends ConsumerWidget {
  const AllowLanItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final allowLan =
        ref.watch(patchClashConfigProvider.select((state) => state.allowLan));
    return ListItem.switchItem(
      leading: const Icon(Icons.device_hub),
      title: Text(appLocalizations.allowLan),
      subtitle: Text(appLocalizations.allowLanDesc),
      delegate: SwitchDelegate(
        value: allowLan,
        onChanged: (bool value) async {
          ref.read(patchClashConfigProvider.notifier).updateState(
                (state) => state.copyWith(
                  allowLan: value,
                ),
              );
        },
      ),
    );
  }
}

class UnifiedDelayItem extends ConsumerWidget {
  const UnifiedDelayItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final unifiedDelay = ref
        .watch(patchClashConfigProvider.select((state) => state.unifiedDelay));

    return ListItem.switchItem(
      leading: const Icon(Icons.compress_outlined),
      title: Text(appLocalizations.unifiedDelay),
      subtitle: Text(appLocalizations.unifiedDelayDesc),
      delegate: SwitchDelegate(
        value: unifiedDelay,
        onChanged: (bool value) async {
          ref.read(patchClashConfigProvider.notifier).updateState(
                (state) => state.copyWith(
                  unifiedDelay: value,
                ),
              );
        },
      ),
    );
  }
}

class FindProcessItem extends ConsumerWidget {
  const FindProcessItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final findProcess = ref.watch(patchClashConfigProvider
        .select((state) => state.findProcessMode == FindProcessMode.always));

    return ListItem.switchItem(
      leading: const Icon(Icons.polymer_outlined),
      title: Text(appLocalizations.findProcessMode),
      subtitle: Text(appLocalizations.findProcessModeDesc),
      delegate: SwitchDelegate(
        value: findProcess,
        onChanged: (bool value) async {
          ref.read(patchClashConfigProvider.notifier).updateState(
                (state) => state.copyWith(
                  findProcessMode:
                      value ? FindProcessMode.always : FindProcessMode.off,
                ),
              );
        },
      ),
    );
  }
}

class TcpConcurrentItem extends ConsumerWidget {
  const TcpConcurrentItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final tcpConcurrent = ref
        .watch(patchClashConfigProvider.select((state) => state.tcpConcurrent));
    return ListItem.switchItem(
      leading: const Icon(Icons.double_arrow_outlined),
      title: Text(appLocalizations.tcpConcurrent),
      subtitle: Text(appLocalizations.tcpConcurrentDesc),
      delegate: SwitchDelegate(
        value: tcpConcurrent,
        onChanged: (value) async {
          ref.read(patchClashConfigProvider.notifier).updateState(
                (state) => state.copyWith(
                  tcpConcurrent: value,
                ),
              );
        },
      ),
    );
  }
}

class GeodataLoaderItem extends ConsumerWidget {
  const GeodataLoaderItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final isMemconservative = ref.watch(patchClashConfigProvider.select(
        (state) => state.geodataLoader == GeodataLoader.memconservative));
    return ListItem.switchItem(
      leading: const Icon(Icons.memory),
      title: Text(appLocalizations.geodataLoader),
      subtitle: Text(appLocalizations.geodataLoaderDesc),
      delegate: SwitchDelegate(
        value: isMemconservative,
        onChanged: (bool value) async {
          ref.read(patchClashConfigProvider.notifier).updateState(
                (state) => state.copyWith(
                  geodataLoader: value
                      ? GeodataLoader.memconservative
                      : GeodataLoader.standard,
                ),
              );
        },
      ),
    );
  }
}

class ExternalControllerItem extends ConsumerWidget {
  const ExternalControllerItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final hasExternalController = ref.watch(patchClashConfigProvider.select(
        (state) => state.externalController == ExternalControllerStatus.open));
    return ListItem.switchItem(
      leading: const Icon(Icons.api_outlined),
      title: Text(appLocalizations.externalController),
      subtitle: Text(appLocalizations.externalControllerDesc),
      delegate: SwitchDelegate(
        value: hasExternalController,
        onChanged: (bool value) async {
          ref.read(patchClashConfigProvider.notifier).updateState(
                (state) => state.copyWith(
                  externalController: value
                      ? ExternalControllerStatus.open
                      : ExternalControllerStatus.close,
                ),
              );
        },
      ),
    );
  }
}

final generalItems = <Widget>[
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
