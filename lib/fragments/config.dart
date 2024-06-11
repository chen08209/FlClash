import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConfigFragment extends StatefulWidget {
  const ConfigFragment({super.key});

  @override
  State<ConfigFragment> createState() => _ConfigFragmentState();
}

class _ConfigFragmentState extends State<ConfigFragment> {
  _modifyMixedPort(num mixedPort) async {
    final port = await globalState.showCommonDialog(
      child: MixedPortFormDialog(
        mixedPort: mixedPort,
      ),
    );
    if (port != null && port != mixedPort && mounted) {
      try {
        final mixedPort = int.parse(port);
        if (mixedPort < 1024 || mixedPort > 49151) throw "Invalid port";
        globalState.appController.clashConfig.mixedPort = mixedPort;
        globalState.appController.updateClashConfigDebounce();
      } catch (e) {
        globalState.showMessage(
          title: appLocalizations.proxyPort,
          message: TextSpan(
            text: e.toString(),
          ),
        );
      }
    }
  }

  _updateLoglevel(LogLevel? logLevel) {
    if (logLevel == null ||
        logLevel == globalState.appController.clashConfig.logLevel) return;
    globalState.appController.clashConfig.logLevel = logLevel;
    globalState.appController.updateClashConfigDebounce();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [
      Selector<ClashConfig, int>(
        selector: (_, clashConfig) => clashConfig.mixedPort,
        builder: (_, mixedPort, __) {
          return ListItem(
            onTab: () {
              _modifyMixedPort(mixedPort);
            },
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: const Icon(Icons.adjust_outlined),
            title: Text(appLocalizations.proxyPort),
            trailing: FilledButton.tonal(
              onPressed: () {
                _modifyMixedPort(mixedPort);
              },
              child: Text(
                "$mixedPort",
              ),
            ),
          );
        },
      ),
      Selector<ClashConfig, bool>(
        selector: (_, clashConfig) => clashConfig.ipv6,
        builder: (_, ipv6, __) {
          return ListItem.switchItem(
            leading: const Icon(Icons.water_outlined),
            title: const Text("Ipv6"),
            subtitle: Text(appLocalizations.ipv6Desc),
            delegate: SwitchDelegate(
              value: ipv6,
              onChanged: (bool value) async {
                final appController = globalState.appController;
                appController.clashConfig.ipv6 = value;
                await appController.updateClashConfig(
                  isPatch: false,
                );
              },
            ),
          );
        },
      ),
      Selector<ClashConfig, bool>(
        selector: (_, clashConfig) => clashConfig.allowLan,
        builder: (_, allowLan, __) {
          return ListItem.switchItem(
            leading: const Icon(Icons.device_hub),
            title: Text(appLocalizations.allowLan),
            subtitle: Text(appLocalizations.allowLanDesc),
            delegate: SwitchDelegate(
              value: allowLan,
              onChanged: (bool value) async {
                final clashConfig = context.read<ClashConfig>();
                clashConfig.allowLan = value;
                globalState.appController.updateClashConfigDebounce();
              },
            ),
          );
        },
      ),
      // if (system.isDesktop)
      //   Selector<ClashConfig, bool>(
      //     selector: (_, clashConfig) => clashConfig.tun.enable,
      //     builder: (_, tunEnable, __) {
      //       return ListItem.switchItem(
      //         leading: const Icon(Icons.support),
      //         title: Text(appLocalizations.tun),
      //         subtitle: Text(appLocalizations.tunDesc),
      //         delegate: SwitchDelegate(
      //           value: tunEnable,
      //           onChanged: (bool value) async {
      //             final clashConfig = context.read<ClashConfig>();
      //             clashConfig.tun = Tun(enable: value);
      //             globalState.appController.updateClashConfigDebounce();
      //           },
      //         ),
      //       );
      //     },
      //   ),
      if (Platform.isAndroid)
        Selector<Config, bool>(
          selector: (_, config) => config.allowBypass,
          builder: (_, allowBypass, __) {
            return ListItem.switchItem(
              leading: const Icon(Icons.double_arrow),
              title: Text(appLocalizations.allowBypass),
              subtitle: Text(appLocalizations.allowBypassDesc),
              delegate: SwitchDelegate(
                value: allowBypass,
                onChanged: (bool value) async {
                  final appController = globalState.appController;
                  appController.config.allowBypass = value;
                },
              ),
            );
          },
        ),
      Selector<Config, bool>(
        selector: (_, config) => config.isCompatible,
        builder: (_, isCompatible, __) {
          return ListItem.switchItem(
            leading: const Icon(Icons.expand_outlined),
            title: Text(appLocalizations.compatible),
            subtitle: Text(appLocalizations.compatibleDesc),
            delegate: SwitchDelegate(
              value: isCompatible,
              onChanged: (bool value) async {
                final appController = globalState.appController;
                appController.config.isCompatible = value;
                await appController.updateClashConfig(isPatch: false);
                await appController.updateGroups();
                appController.changeProxy();
              },
            ),
          );
        },
      ),
      // Selector<ClashConfig, bool>(
      //   selector: (_, clashConfig) => clashConfig.externalController.isNotEmpty,
      //   builder: (_, hasExternalController, __) {
      //     return ListItem.switchItem(
      //       leading: const Icon(Icons.api_outlined),
      //       title: Text(appLocalizations.externalController),
      //       subtitle: Text(appLocalizations.externalControllerDesc),
      //       delegate: SwitchDelegate(
      //         value: hasExternalController,
      //         onChanged: (bool value) async {
      //           final appController = globalState.appController;
      //           appController.clashConfig.externalController =
      //               value ? defaultExternalController : '';
      //           await appController.updateClashConfig(
      //             isPatch: false,
      //           );
      //         },
      //       ),
      //     );
      //   },
      // ),
      Padding(
        padding: kMaterialListPadding,
        child: Selector<ClashConfig, LogLevel>(
          selector: (_, clashConfig) => clashConfig.logLevel,
          builder: (_, value, __) {
            return ListItem(
              leading: const Icon(Icons.info_outline),
              title: Text(appLocalizations.logLevel),
              trailing: SizedBox(
                height: 48,
                child: DropdownMenu<LogLevel>(
                  width: 124,
                  initialSelection: value,
                  dropdownMenuEntries: [
                    for (final logLevel in LogLevel.values)
                      DropdownMenuEntry<LogLevel>(
                        value: logLevel,
                        label: logLevel.name,
                      )
                  ],
                  onSelected: _updateLoglevel,
                ),
              ),
            );
          },
        ),
      ),
    ];
    return ListView.separated(
      itemBuilder: (_, index) {
        return Container(
          alignment: Alignment.center,
          child: items[index],
        );
      },
      separatorBuilder: (_, __) {
        return const Divider(
          height: 0,
        );
      },
      itemCount: items.length,
    );
  }
}

class MixedPortFormDialog extends StatefulWidget {
  final num mixedPort;

  const MixedPortFormDialog({super.key, required this.mixedPort});

  @override
  State<MixedPortFormDialog> createState() => _MixedPortFormDialogState();
}

class _MixedPortFormDialogState extends State<MixedPortFormDialog> {
  late TextEditingController portController;

  @override
  void initState() {
    super.initState();
    portController = TextEditingController(text: "${widget.mixedPort}");
  }

  _handleAddProfileFormURL() async {
    final port = portController.value.text;
    if (port.isEmpty) return;
    Navigator.of(context).pop<String>(port);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(appLocalizations.proxyPort),
      content: SizedBox(
        width: 300,
        child: Wrap(
          runSpacing: 16,
          children: [
            TextField(
              controller: portController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _handleAddProfileFormURL,
          child: Text(appLocalizations.submit),
        )
      ],
    );
  }
}
