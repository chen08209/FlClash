import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LogLevelMenu extends StatelessWidget {
  const LogLevelMenu({super.key});

  _showLogLevelDialog(BuildContext context, LogLevel value) {
    globalState.showCommonDialog(
      child: AlertDialog(
        title: Text(appLocalizations.logLevel),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 16,
        ),
        content: SizedBox(
          width: 250,
          child: Wrap(
            children: [
              for (final logLevel in LogLevel.values)
                ListItem.radio(
                  delegate: RadioDelegate<LogLevel>(
                    value: logLevel,
                    groupValue: value,
                    onChanged: (LogLevel? value) {
                      if (value == null) {
                        return;
                      }
                      final appController = globalState.appController;
                      appController.clashConfig.logLevel = value;
                      Navigator.of(context).pop();
                    },
                  ),
                  title: Text(logLevel.name),
                )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector<ClashConfig, LogLevel>(
      selector: (_, clashConfig) => clashConfig.logLevel,
      builder: (_, value, __) {
        return ListItem(
          leading: const Icon(Icons.info_outline),
          title: Text(appLocalizations.logLevel),
          subtitle: Text(value.name),
          onTap: () {
            _showLogLevelDialog(context, value);
          },
        );
      },
    );
  }
}

class UaMenu extends StatelessWidget {
  const UaMenu({super.key});

  _showUaDialog(BuildContext context, String? value) {
    const uas = [
      null,
      "clash-verge/v1.6.6",
      "ClashforWindows/0.19.23",
    ];
    globalState.showCommonDialog(
      child: AlertDialog(
        title: const Text("UA"),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 16,
        ),
        content: SizedBox(
          width: 250,
          child: Wrap(
            children: [
              for (final ua in uas)
                ListItem.radio(
                  delegate: RadioDelegate<String?>(
                    value: ua,
                    groupValue: value,
                    onChanged: (String? value) {
                      final appController = globalState.appController;
                      appController.clashConfig.globalRealUa = value;
                      Navigator.of(context).pop();
                    },
                  ),
                  title: Text(ua ?? appLocalizations.defaultText),
                )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector<ClashConfig, String?>(
      selector: (_, clashConfig) => clashConfig.globalRealUa,
      builder: (_, value, __) {
        return ListItem(
          leading: const Icon(Icons.computer_outlined),
          title: const Text("UA"),
          subtitle: Text(value ?? appLocalizations.defaultText),
          onTap: () {
            _showUaDialog(context, value);
          },
        );
      },
    );
  }
}

class KeepAliveIntervalInput extends StatelessWidget {
  const KeepAliveIntervalInput({super.key});

  _updateKeepAliveInterval(int keepAliveInterval) async {
    final newKeepAliveIntervalString =
        await globalState.showCommonDialog<String>(
      child: KeepAliveIntervalFormDialog(
        keepAliveInterval: keepAliveInterval,
      ),
    );
    if (newKeepAliveIntervalString != null &&
        newKeepAliveIntervalString != "$keepAliveInterval") {
      try {
        final newKeepAliveInterval = int.parse(newKeepAliveIntervalString);
        if (newKeepAliveInterval <= 0) {
          throw "Invalid keepAliveInterval";
        }
        globalState.appController.clashConfig.keepAliveInterval =
            newKeepAliveInterval;
        globalState.appController.updateClashConfigDebounce();
      } catch (e) {
        globalState.showMessage(
          title: appLocalizations.testUrl,
          message: TextSpan(
            text: e.toString(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<ClashConfig, int>(
      selector: (_, config) => config.keepAliveInterval,
      builder: (_, value, __) {
        return ListItem(
          leading: const Icon(Icons.timer_outlined),
          title: Text(appLocalizations.keepAliveIntervalDesc),
          subtitle: Text("$value ${appLocalizations.seconds}"),
          onTap: () {
            _updateKeepAliveInterval(value);
          },
        );
      },
    );
  }
}

class TestUrlInput extends StatelessWidget {
  const TestUrlInput({super.key});

  _modifyTestUrl(String testUrl) async {
    final newTestUrl = await globalState.showCommonDialog<String>(
      child: TestUrlFormDialog(
        testUrl: testUrl,
      ),
    );
    if (newTestUrl != null && newTestUrl != testUrl) {
      try {
        if (!newTestUrl.isUrl) {
          throw "Invalid url";
        }
        globalState.appController.config.testUrl = newTestUrl;
      } catch (e) {
        globalState.showMessage(
          title: appLocalizations.testUrl,
          message: TextSpan(
            text: e.toString(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<Config, String>(
      selector: (_, config) => config.testUrl,
      builder: (_, value, __) {
        return ListItem(
          leading: const Icon(Icons.timeline),
          title: Text(appLocalizations.testUrl),
          subtitle: Text(value),
          onTap: () {
            _modifyTestUrl(value);
          },
        );
      },
    );
  }
}

class MixedPortInput extends StatelessWidget {
  const MixedPortInput({super.key});

  _modifyMixedPort(num mixedPort) async {
    final port = await globalState.showCommonDialog(
      child: MixedPortFormDialog(
        mixedPort: mixedPort,
      ),
    );
    if (port != null && port != mixedPort) {
      try {
        final mixedPort = int.parse(port);
        if (mixedPort < 1024 || mixedPort > 49151) throw "Invalid port";
        globalState.appController.clashConfig.mixedPort = mixedPort;
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

  @override
  Widget build(BuildContext context) {
    return Selector<ClashConfig, int>(
      selector: (_, clashConfig) => clashConfig.mixedPort,
      builder: (_, mixedPort, __) {
        return ListItem(
          onTap: () {
            _modifyMixedPort(mixedPort);
          },
          leading: const Icon(Icons.adjust_outlined),
          title: Text(appLocalizations.proxyPort),
          subtitle: Text("$mixedPort"),
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
      subtitle: Text("编辑追加hosts"),
      delegate: OpenDelegate(
        title: "Hosts",
        widget: HostsForm(),
        extendPageWidth: 360,
      ),
    );
  }
}

class Ipv6Switch extends StatelessWidget {
  const Ipv6Switch({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ClashConfig, bool>(
      selector: (_, clashConfig) => clashConfig.ipv6,
      builder: (_, ipv6, __) {
        return ListItem.switchItem(
          leading: const Icon(Icons.water_outlined),
          title: const Text("IPv6"),
          subtitle: Text(appLocalizations.ipv6Desc),
          delegate: SwitchDelegate(
            value: ipv6,
            onChanged: (bool value) async {
              final appController = globalState.appController;
              appController.clashConfig.ipv6 = value;
            },
          ),
        );
      },
    );
  }
}

class AllowLanSwitch extends StatelessWidget {
  const AllowLanSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ClashConfig, bool>(
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
            },
          ),
        );
      },
    );
  }
}

class UnifiedDelaySwitch extends StatelessWidget {
  const UnifiedDelaySwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ClashConfig, bool>(
      selector: (_, clashConfig) => clashConfig.unifiedDelay,
      builder: (_, unifiedDelay, __) {
        return ListItem.switchItem(
          leading: const Icon(Icons.compress_outlined),
          title: Text(appLocalizations.unifiedDelay),
          subtitle: Text(appLocalizations.unifiedDelayDesc),
          delegate: SwitchDelegate(
            value: unifiedDelay,
            onChanged: (bool value) async {
              final appController = globalState.appController;
              appController.clashConfig.unifiedDelay = value;
            },
          ),
        );
      },
    );
  }
}

class FindProcessSwitch extends StatelessWidget {
  const FindProcessSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ClashConfig, bool>(
      selector: (_, clashConfig) =>
          clashConfig.findProcessMode == FindProcessMode.always,
      builder: (_, findProcess, __) {
        return ListItem.switchItem(
          leading: const Icon(Icons.polymer_outlined),
          title: Text(appLocalizations.findProcessMode),
          subtitle: Text(appLocalizations.findProcessModeDesc),
          delegate: SwitchDelegate(
            value: findProcess,
            onChanged: (bool value) async {
              final appController = globalState.appController;
              appController.clashConfig.findProcessMode =
                  value ? FindProcessMode.always : FindProcessMode.off;
            },
          ),
        );
      },
    );
  }
}

class TcpConcurrentSwitch extends StatelessWidget {
  const TcpConcurrentSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ClashConfig, bool>(
      selector: (_, clashConfig) => clashConfig.tcpConcurrent,
      builder: (_, tcpConcurrent, __) {
        return ListItem.switchItem(
          leading: const Icon(Icons.double_arrow_outlined),
          title: Text(appLocalizations.tcpConcurrent),
          subtitle: Text(appLocalizations.tcpConcurrentDesc),
          delegate: SwitchDelegate(
            value: tcpConcurrent,
            onChanged: (bool value) async {
              final appController = globalState.appController;
              appController.clashConfig.tcpConcurrent = value;
            },
          ),
        );
      },
    );
  }
}

class GeodataLoaderSwitch extends StatelessWidget {
  const GeodataLoaderSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ClashConfig, bool>(
      selector: (_, clashConfig) =>
          clashConfig.geodataLoader == geodataLoaderMemconservative,
      builder: (_, memconservative, __) {
        return ListItem.switchItem(
          leading: const Icon(Icons.memory),
          title: Text(appLocalizations.geodataLoader),
          subtitle: Text(appLocalizations.geodataLoaderDesc),
          delegate: SwitchDelegate(
            value: memconservative,
            onChanged: (bool value) async {
              final appController = globalState.appController;
              appController.clashConfig.geodataLoader =
                  value ? geodataLoaderMemconservative : geodataLoaderStandard;
            },
          ),
        );
      },
    );
  }
}

class ExternalControllerSwitch extends StatelessWidget {
  const ExternalControllerSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ClashConfig, bool>(
      selector: (_, clashConfig) => clashConfig.externalController.isNotEmpty,
      builder: (_, hasExternalController, __) {
        return ListItem.switchItem(
          leading: const Icon(Icons.api_outlined),
          title: Text(appLocalizations.externalController),
          subtitle: Text(appLocalizations.externalControllerDesc),
          delegate: SwitchDelegate(
            value: hasExternalController,
            onChanged: (bool value) async {
              final appController = globalState.appController;
              appController.clashConfig.externalController =
                  value ? defaultExternalController : '';
            },
          ),
        );
      },
    );
  }
}

const generalItems = [
  LogLevelMenu(),
  UaMenu(),
  KeepAliveIntervalInput(),
  TestUrlInput(),
  MixedPortInput(),
  HostsItem(),
  Ipv6Switch(),
  AllowLanSwitch(),
  UnifiedDelaySwitch(),
  FindProcessSwitch(),
  TcpConcurrentSwitch(),
  GeodataLoaderSwitch(),
  ExternalControllerSwitch(),
];

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

  _handleUpdate() async {
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
          onPressed: _handleUpdate,
          child: Text(appLocalizations.submit),
        )
      ],
    );
  }
}

class TestUrlFormDialog extends StatefulWidget {
  final String testUrl;

  const TestUrlFormDialog({
    super.key,
    required this.testUrl,
  });

  @override
  State<TestUrlFormDialog> createState() => _TestUrlFormDialogState();
}

class _TestUrlFormDialogState extends State<TestUrlFormDialog> {
  late TextEditingController testUrlController;

  @override
  void initState() {
    super.initState();
    testUrlController = TextEditingController(text: widget.testUrl);
  }

  _handleUpdate() async {
    final testUrl = testUrlController.value.text;
    if (testUrl.isEmpty) return;
    Navigator.of(context).pop<String>(testUrl);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(appLocalizations.testUrl),
      content: SizedBox(
        width: 300,
        child: Wrap(
          runSpacing: 16,
          children: [
            TextField(
              maxLines: 5,
              minLines: 1,
              controller: testUrlController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _handleUpdate,
          child: Text(appLocalizations.submit),
        )
      ],
    );
  }
}

class KeepAliveIntervalFormDialog extends StatefulWidget {
  final int keepAliveInterval;

  const KeepAliveIntervalFormDialog({
    super.key,
    required this.keepAliveInterval,
  });

  @override
  State<KeepAliveIntervalFormDialog> createState() =>
      _KeepAliveIntervalFormDialogState();
}

class _KeepAliveIntervalFormDialogState
    extends State<KeepAliveIntervalFormDialog> {
  late TextEditingController keepAliveIntervalController;

  @override
  void initState() {
    super.initState();
    keepAliveIntervalController = TextEditingController(
      text: "${widget.keepAliveInterval}",
    );
  }

  _handleUpdate() async {
    final keepAliveInterval = keepAliveIntervalController.value.text;
    if (keepAliveInterval.isEmpty) return;
    Navigator.of(context).pop<String>(keepAliveInterval);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(appLocalizations.keepAliveIntervalDesc),
      content: SizedBox(
        width: 300,
        child: Wrap(
          runSpacing: 16,
          children: [
            TextField(
              maxLines: 1,
              minLines: 1,
              controller: keepAliveIntervalController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                suffixText: appLocalizations.seconds,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _handleUpdate,
          child: Text(appLocalizations.submit),
        )
      ],
    );
  }
}

class HostsForm extends StatelessWidget {
  const HostsForm({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatLayout(
      floatingWidget: FloatWrapper(
        child: FloatingActionButton(
          onPressed: () async {
            final entry =
                await globalState.showCommonDialog<MapEntry<String, String>>(
              child: const AddHostDialog(),
            );
            if (entry == null) return;
            final clashConfig = globalState.appController.clashConfig;
            clashConfig.hosts = Map.from(clashConfig.hosts)
              ..addEntries([entry]);
          },
          child: const Icon(Icons.add),
        ),
      ),
      child: Selector<ClashConfig, HostsMap>(
        selector: (_, clashConfig) => clashConfig.hosts,
        builder: (_, hosts, ___) {
          final entries = hosts.entries;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (_, index) {
              final e = entries.toList()[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: CommonCard(
                  child: ListItem(
                    title: Text(e.key),
                    subtitle: Text(e.value),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        final clashConfig =
                            globalState.appController.clashConfig;
                        clashConfig.hosts = Map.from(hosts)..remove(e.key);
                      },
                    ),
                  ),
                  onPressed: () {},
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AddHostDialog extends StatefulWidget {
  const AddHostDialog({super.key});

  @override
  State<AddHostDialog> createState() => _AddHostDialogState();
}

class _AddHostDialogState extends State<AddHostDialog> {
  late TextEditingController keyController;
  late TextEditingController valueController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    keyController = TextEditingController();
    valueController = TextEditingController();
  }

  _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop<MapEntry<String, String>>(
      MapEntry(
        keyController.text,
        valueController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Hosts"),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: dialogCommonWidth,
          child: Wrap(
            runSpacing: 16,
            children: [
              TextFormField(
                maxLines: 2,
                minLines: 1,
                controller: keyController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.key),
                  border: const OutlineInputBorder(),
                  labelText: appLocalizations.key,
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return appLocalizations.keyNotEmpty;
                  }
                  return null;
                },
              ),
              TextFormField(
                maxLines: 3,
                minLines: 1,
                controller: valueController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.label),
                  border: const OutlineInputBorder(),
                  labelText: appLocalizations.value,
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return appLocalizations.valueNotEmpty;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submit,
          child: Text(appLocalizations.confirm),
        )
      ],
    );
  }
}
