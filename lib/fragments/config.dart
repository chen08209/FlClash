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
        context.appController.clashConfig.mixedPort = mixedPort;
        context.appController.updateClashConfigDebounce();
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
        logLevel == context.appController.clashConfig.logLevel) return;
    context.appController.clashConfig.logLevel = logLevel;
    context.appController.updateClashConfigDebounce();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [
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
                context.appController.updateClashConfigDebounce();
              },
            ),
          );
        },
      ),
      Selector<ClashConfig, int>(
        selector: (_, clashConfig) => clashConfig.mixedPort,
        builder: (_, mixedPort, __) {
          return ListItem(
            onTab: () {
              _modifyMixedPort(mixedPort);
            },
            leading: const Icon(Icons.adjust),
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
      Selector<ClashConfig, LogLevel>(
        selector: (_, clashConfig) => clashConfig.logLevel,
        builder: (_, value, __) {
          return ListItem(
            leading: const Icon(Icons.feedback),
            title: Text(appLocalizations.logLevel),
            trailing: SizedBox(
              height: 48,
              child: DropdownMenu<LogLevel>(
                width: 124,
                inputDecorationTheme: const InputDecorationTheme(
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 16,
                  ),
                ),
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
    ];
    return ListView.separated(
      itemBuilder: (_, index) {
        return Container(
          height: 84,
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
