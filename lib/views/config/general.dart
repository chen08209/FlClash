import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _defaultUaValue = '';
const _customUaValue = '__custom_ua__';
const _presetUas = ['clash-verge/v2.4.2', 'ClashforWindows/0.19.23'];

class LogLevelItem extends ConsumerWidget {
  const LogLevelItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final logLevel = ref.watch(
      patchClashConfigProvider.select((state) => state.logLevel),
    );
    return ListItem<LogLevel>.options(
      leading: const Icon(Icons.info_outline),
      title: Text(appLocalizations.logLevel),
      subtitle: Text(logLevel.name),
      dialogTitle: appLocalizations.logLevel,
      options: LogLevel.values,
      onChanged: (LogLevel? value) {
        if (value == null) {
          return;
        }
        ref
            .read(patchClashConfigProvider.notifier)
            .update((state) => state.copyWith(logLevel: value));
      },
      textBuilder: (logLevel) => logLevel.name,
      value: logLevel,
    );
  }
}

class UaItem extends ConsumerWidget {
  const UaItem({super.key});

  Future<void> _handleShowUaDialog(WidgetRef ref) async {
    final result = await globalState.showCommonDialog<_UaDialogResult>(
      child: _UaDialog(
        value: ref.read(patchClashConfigProvider).globalUa,
        customValue: ref.read(appSettingProvider).customUserAgent,
      ),
    );
    if (result == null) {
      return;
    }
    final userAgent = result.value.trim();
    if (result.isCustom) {
      ref
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(customUserAgent: userAgent));
    }
    ref
        .read(patchClashConfigProvider.notifier)
        .update(
          (state) =>
              state.copyWith(globalUa: userAgent.isEmpty ? null : userAgent),
        );
  }

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final globalUa = ref.watch(
      patchClashConfigProvider.select((state) => state.globalUa),
    );
    return ListItem(
      leading: const Icon(Icons.computer_outlined),
      title: Text(appLocalizations.userAgent),
      subtitle: Text(globalUa ?? appLocalizations.defaultText),
      onTap: () => _handleShowUaDialog(ref),
    );
  }
}

class _UaDialogResult {
  final String value;
  final bool isCustom;

  const _UaDialogResult({required this.value, required this.isCustom});
}

class _UaDialog extends StatefulWidget {
  final String? value;
  final String customValue;

  const _UaDialog({this.value, required this.customValue});

  @override
  State<_UaDialog> createState() => _UaDialogState();
}

class _UaDialogState extends State<_UaDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _customController;
  late String _groupValue;

  @override
  void initState() {
    super.initState();
    final value = widget.value ?? _defaultUaValue;
    _groupValue = _presetUas.contains(value) || value.isEmpty
        ? value
        : _customUaValue;
    _customController = TextEditingController(
      text: _groupValue == _customUaValue ? value : widget.customValue,
    );
  }

  void _handleChanged(String? value) {
    if (value == null) {
      return;
    }
    if (value == _customUaValue) {
      setState(() {
        _groupValue = value;
      });
      return;
    }
    Navigator.of(context).pop(_UaDialogResult(value: value, isCustom: false));
  }

  void _handleSubmit() {
    if (_groupValue == _customUaValue &&
        _formKey.currentState?.validate() == false) {
      return;
    }
    Navigator.of(context).pop(
      _UaDialogResult(
        value: _groupValue == _customUaValue
            ? _customController.text
            : _groupValue,
        isCustom: _groupValue == _customUaValue,
      ),
    );
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: appLocalizations.userAgent,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(appLocalizations.cancel),
        ),
        TextButton(
          onPressed: _handleSubmit,
          child: Text(appLocalizations.submit),
        ),
      ],
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: RadioGroup<String>(
          groupValue: _groupValue,
          onChanged: _handleChanged,
          child: Wrap(
            runSpacing: 8,
            children: [
              ListItem.radio(
                value: _defaultUaValue,
                onTap: () {
                  Navigator.of(context).pop(
                    const _UaDialogResult(
                      value: _defaultUaValue,
                      isCustom: false,
                    ),
                  );
                },
                title: Text(appLocalizations.defaultText),
              ),
              for (final ua in _presetUas)
                ListItem.radio(
                  value: ua,
                  onTap: () {
                    Navigator.of(
                      context,
                    ).pop(_UaDialogResult(value: ua, isCustom: false));
                  },
                  title: Text(ua),
                ),
              ListItem.radio(
                value: _customUaValue,
                onTap: () {
                  setState(() {
                    _groupValue = _customUaValue;
                  });
                },
                title: Builder(
                  builder: (context) {
                    final titleStyle = DefaultTextStyle.of(context).style;
                    return TextFormField(
                      enabled: _groupValue == _customUaValue,
                      style: titleStyle,
                      maxLength: TextInputLimits.userAgent,
                      inputFormatters: TextInputLimits.limit(
                        TextInputLimits.userAgent,
                      ),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        counterText: '',
                        hintStyle: titleStyle,
                        hintText: appLocalizations.custom,
                      ),
                      keyboardType: TextInputType.url,
                      maxLines: 1,
                      controller: _customController,
                      onChanged: (value) {
                        setState(() {
                          _groupValue = _customUaValue;
                        });
                      },
                      onFieldSubmitted: (_) {
                        _handleSubmit();
                      },
                      validator: (value) {
                        if (_groupValue == _customUaValue &&
                            (value == null || value.trim().isEmpty)) {
                          return appLocalizations.emptyTip(
                            appLocalizations.userAgent,
                          );
                        }
                        return null;
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class KeepAliveIntervalItem extends ConsumerWidget {
  const KeepAliveIntervalItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final keepAliveInterval = ref.watch(
      patchClashConfigProvider.select((state) => state.keepAliveInterval),
    );
    return ListItem.input(
      leading: const Icon(Icons.timer_outlined),
      title: Text(appLocalizations.keepAliveIntervalDesc),
      subtitle: Text(appLocalizations.secondsCount(keepAliveInterval)),
      dialogTitle: appLocalizations.keepAliveIntervalDesc,
      suffixText: appLocalizations.seconds,
      resetValue: '$defaultKeepAliveInterval',
      value: '$keepAliveInterval',
      maxLength: TextInputLimits.interval,
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return appLocalizations.emptyTip(appLocalizations.interval);
        }
        final intValue = int.tryParse(value);
        if (intValue == null) {
          return appLocalizations.numberTip(appLocalizations.interval);
        }
        return null;
      },
      onChanged: (String? value) {
        if (value == null) {
          return;
        }
        final intValue = int.parse(value);
        ref
            .read(patchClashConfigProvider.notifier)
            .update((state) => state.copyWith(keepAliveInterval: intValue));
      },
    );
  }
}

class TestUrlItem extends ConsumerWidget {
  const TestUrlItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final testUrl = ref.watch(
      appSettingProvider.select((state) => state.testUrl),
    );
    return ListItem.input(
      leading: const Icon(Icons.timeline),
      title: Text(appLocalizations.testUrl),
      subtitle: Text(testUrl),
      resetValue: defaultTestUrl,
      dialogTitle: appLocalizations.testUrl,
      value: testUrl,
      maxLength: TextInputLimits.url,
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return appLocalizations.emptyTip(appLocalizations.testUrl);
        }
        if (!value.isUrl) {
          return appLocalizations.urlTip(appLocalizations.testUrl);
        }
        return null;
      },
      onChanged: (String? value) {
        if (value == null) {
          return;
        }
        ref
            .read(appSettingProvider.notifier)
            .update((state) => state.copyWith(testUrl: value));
      },
    );
  }
}

class PortItem extends ConsumerWidget {
  const PortItem({super.key});

  Future<void> handleShowPortDialog() async {
    await globalState.showCommonDialog(child: const _PortDialog());
  }

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final mixedPort = ref.watch(
      patchClashConfigProvider.select((state) => state.mixedPort),
    );
    return ListItem(
      leading: const Icon(Icons.adjust_outlined),
      title: Text(appLocalizations.port),
      subtitle: Text('$mixedPort'),
      onTap: () {
        handleShowPortDialog();
      },
    );
  }
}

class HostsItem extends ConsumerWidget {
  const HostsItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final hosts = ref.watch(
      patchClashConfigProvider.select((state) => state.hosts),
    );
    return ListItem.open(
      leading: const Icon(Icons.view_list_outlined),
      title: const Text('Hosts'),
      subtitle: Text(appLocalizations.hostsDesc),
      blur: false,
      widget: MapInputPage(
        title: 'Hosts',
        map: hosts,
        keyMaxLength: TextInputLimits.domain,
        valueMaxLength: TextInputLimits.hostValue,
        titleBuilder: (item) => Text(item.key),
        subtitleBuilder: (item) => Text(item.value),
      ),
      onChanged: (value) {
        ref
            .read(patchClashConfigProvider.notifier)
            .update((state) => state.copyWith(hosts: value));
      },
    );
  }
}

class Ipv6Item extends ConsumerWidget {
  const Ipv6Item({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final ipv6 = ref.watch(
      patchClashConfigProvider.select((state) => state.ipv6),
    );
    return ListItem.toggle(
      leading: const Icon(Icons.water_outlined),
      title: const Text('IPv6'),
      subtitle: Text(appLocalizations.ipv6Desc),
      value: ipv6,
      onChanged: (bool value) async {
        ref
            .read(patchClashConfigProvider.notifier)
            .update((state) => state.copyWith(ipv6: value));
      },
    );
  }
}

class AppendSystemDNSItem extends ConsumerWidget {
  const AppendSystemDNSItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final appendSystemDNS = ref.watch(
      networkSettingProvider.select((state) => state.appendSystemDns),
    );
    return ListItem.toggle(
      leading: const Icon(Icons.dns_outlined),
      title: Text(appLocalizations.appendSystemDns),
      subtitle: Text(appLocalizations.appendSystemDnsTip),
      value: appendSystemDNS,
      onChanged: (bool value) async {
        ref
            .read(networkSettingProvider.notifier)
            .update((state) => state.copyWith(appendSystemDns: value));
      },
    );
  }
}

class AllowLanItem extends ConsumerWidget {
  const AllowLanItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final allowLan = ref.watch(
      patchClashConfigProvider.select((state) => state.allowLan),
    );
    return ListItem.toggle(
      leading: const Icon(Icons.device_hub),
      title: Text(appLocalizations.allowLan),
      subtitle: Text(appLocalizations.allowLanDesc),
      value: allowLan,
      onChanged: (bool value) async {
        ref
            .read(patchClashConfigProvider.notifier)
            .update((state) => state.copyWith(allowLan: value));
      },
    );
  }
}

class UnifiedDelayItem extends ConsumerWidget {
  const UnifiedDelayItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final unifiedDelay = ref.watch(
      patchClashConfigProvider.select((state) => state.unifiedDelay),
    );

    return ListItem.toggle(
      leading: const Icon(Icons.compress_outlined),
      title: Text(appLocalizations.unifiedDelay),
      subtitle: Text(appLocalizations.unifiedDelayDesc),
      value: unifiedDelay,
      onChanged: (bool value) async {
        ref
            .read(patchClashConfigProvider.notifier)
            .update((state) => state.copyWith(unifiedDelay: value));
      },
    );
  }
}

class FindProcessItem extends ConsumerWidget {
  const FindProcessItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final findProcess = ref.watch(
      patchClashConfigProvider.select(
        (state) => state.findProcessMode == FindProcessMode.always,
      ),
    );

    return ListItem.toggle(
      leading: const Icon(Icons.polymer_outlined),
      title: Text(appLocalizations.findProcessMode),
      subtitle: Text(appLocalizations.findProcessModeDesc),
      value: findProcess,
      onChanged: (bool value) async {
        ref
            .read(patchClashConfigProvider.notifier)
            .update(
              (state) => state.copyWith(
                findProcessMode: value
                    ? FindProcessMode.always
                    : FindProcessMode.off,
              ),
            );
      },
    );
  }
}

class TcpConcurrentItem extends ConsumerWidget {
  const TcpConcurrentItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final tcpConcurrent = ref.watch(
      patchClashConfigProvider.select((state) => state.tcpConcurrent),
    );
    return ListItem.toggle(
      leading: const Icon(Icons.double_arrow_outlined),
      title: Text(appLocalizations.tcpConcurrent),
      subtitle: Text(appLocalizations.tcpConcurrentDesc),
      value: tcpConcurrent,
      onChanged: (value) async {
        ref
            .read(patchClashConfigProvider.notifier)
            .update((state) => state.copyWith(tcpConcurrent: value));
      },
    );
  }
}

class GeodataLoaderItem extends ConsumerWidget {
  const GeodataLoaderItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final isMemconservative = ref.watch(
      patchClashConfigProvider.select(
        (state) => state.geodataLoader == GeodataLoader.memconservative,
      ),
    );
    return ListItem.toggle(
      leading: const Icon(Icons.memory),
      title: Text(appLocalizations.geodataLoader),
      subtitle: Text(appLocalizations.geodataLoaderDesc),
      value: isMemconservative,
      onChanged: (bool value) async {
        ref
            .read(patchClashConfigProvider.notifier)
            .update(
              (state) => state.copyWith(
                geodataLoader: value
                    ? GeodataLoader.memconservative
                    : GeodataLoader.standard,
              ),
            );
      },
    );
  }
}

class ExternalControllerItem extends ConsumerWidget {
  const ExternalControllerItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final hasExternalController = ref.watch(
      patchClashConfigProvider.select(
        (state) => state.externalController == ExternalControllerStatus.open,
      ),
    );
    return ListItem.toggle(
      leading: const Icon(Icons.api_outlined),
      title: Text(appLocalizations.externalController),
      subtitle: Text(appLocalizations.externalControllerDesc),
      value: hasExternalController,
      onChanged: (bool value) async {
        ref
            .read(patchClashConfigProvider.notifier)
            .update(
              (state) => state.copyWith(
                externalController: value
                    ? ExternalControllerStatus.open
                    : ExternalControllerStatus.close,
              ),
            );
      },
    );
  }
}

final generalItems = <Widget>[
  const LogLevelItem(),
  const UaItem(),
  if (system.isDesktop) const KeepAliveIntervalItem(),
  const TestUrlItem(),
  const PortItem(),
  const HostsItem(),
  const Ipv6Item(),
  const AllowLanItem(),
  const UnifiedDelayItem(),
  const AppendSystemDNSItem(),
  const FindProcessItem(),
  const TcpConcurrentItem(),
  const GeodataLoaderItem(),
  const ExternalControllerItem(),
].separated(const Divider(height: 0)).toList();

class _PortDialog extends ConsumerStatefulWidget {
  const _PortDialog();

  @override
  ConsumerState<_PortDialog> createState() => _PortDialogState();
}

class _PortDialogState extends ConsumerState<_PortDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isMore = false;

  late final TextEditingController _mixedPortController;
  late final TextEditingController _portController;
  late final TextEditingController _socksPortController;
  late final TextEditingController _redirPortController;
  late final TextEditingController _tProxyPortController;

  @override
  void initState() {
    super.initState();
    final vm5 = ref.read(
      patchClashConfigProvider.select((state) {
        return VM5(
          state.mixedPort,
          state.port,
          state.socksPort,
          state.redirPort,
          state.tproxyPort,
        );
      }),
    );
    _mixedPortController = TextEditingController(text: vm5.a.toString());
    _portController = TextEditingController(text: vm5.b.toString());
    _socksPortController = TextEditingController(text: vm5.c.toString());
    _redirPortController = TextEditingController(text: vm5.d.toString());
    _tProxyPortController = TextEditingController(text: vm5.e.toString());
  }

  Future<void> _handleReset() async {
    final res = await globalState.showMessage(
      message: TextSpan(text: context.appLocalizations.resetTip),
    );
    if (res != true) {
      return;
    }
    ref
        .read(patchClashConfigProvider.notifier)
        .update(
          (state) => state.copyWith(
            mixedPort: 7890,
            port: 0,
            socksPort: 0,
            redirPort: 0,
            tproxyPort: 0,
          ),
        );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _handleUpdate() {
    if (_formKey.currentState?.validate() == false) return;
    ref
        .read(patchClashConfigProvider.notifier)
        .update(
          (state) => state.copyWith(
            mixedPort: int.parse(_mixedPortController.text),
            port: int.parse(_portController.text),
            socksPort: int.parse(_socksPortController.text),
            redirPort: int.parse(_redirPortController.text),
            tproxyPort: int.parse(_tProxyPortController.text),
          ),
        );
    Navigator.of(context).pop();
  }

  void _handleMore() {
    setState(() {
      _isMore = !_isMore;
    });
  }

  @override
  void dispose() {
    _mixedPortController.dispose();
    _portController.dispose();
    _socksPortController.dispose();
    _redirPortController.dispose();
    _tProxyPortController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: appLocalizations.port,
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton.filledTonal(
              onPressed: _handleMore,
              icon: CommonExpandIcon(expand: _isMore),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: _handleReset,
                  child: Text(appLocalizations.reset),
                ),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: _handleUpdate,
                  child: Text(appLocalizations.submit),
                ),
              ],
            ),
          ],
        ),
      ],
      child: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: AnimatedSize(
            duration: midDuration,
            curve: Curves.easeOutQuad,
            alignment: Alignment.topCenter,
            child: Column(
              spacing: 24,
              children: [
                TextFormField(
                  keyboardType: TextInputType.number,
                  maxLines: 1,
                  minLines: 1,
                  inputFormatters: TextInputLimits.digitsOnly(
                    TextInputLimits.port,
                  ),
                  controller: _mixedPortController,
                  onFieldSubmitted: (_) {
                    _handleUpdate();
                  },
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: appLocalizations.mixedPort,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return appLocalizations.emptyTip(
                        appLocalizations.mixedPort,
                      );
                    }
                    final port = int.tryParse(value);
                    if (port == null) {
                      return appLocalizations.numberTip(
                        appLocalizations.mixedPort,
                      );
                    }
                    if (port < 1024 || port > 49151) {
                      return appLocalizations.portTip(
                        appLocalizations.mixedPort,
                      );
                    }
                    final ports = [
                      _portController.text,
                      _socksPortController.text,
                      _tProxyPortController.text,
                      _redirPortController.text,
                    ].map((item) => item.trim());
                    if (ports.contains(value.trim())) {
                      return appLocalizations.portConflictTip;
                    }
                    return null;
                  },
                ),
                if (_isMore) ...[
                  TextFormField(
                    keyboardType: TextInputType.number,
                    maxLines: 1,
                    minLines: 1,
                    inputFormatters: TextInputLimits.digitsOnly(
                      TextInputLimits.port,
                    ),
                    controller: _portController,
                    onFieldSubmitted: (_) {
                      _handleUpdate();
                    },
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: appLocalizations.port,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return appLocalizations.emptyTip(appLocalizations.port);
                      }
                      final port = int.tryParse(value);
                      if (port == null) {
                        return appLocalizations.numberTip(
                          appLocalizations.port,
                        );
                      }
                      if (port == 0) {
                        return null;
                      }
                      if (port < 1024 || port > 49151) {
                        return appLocalizations.portTip(appLocalizations.port);
                      }
                      final ports = [
                        _mixedPortController.text,
                        _socksPortController.text,
                        _tProxyPortController.text,
                        _redirPortController.text,
                      ].map((item) => item.trim());
                      if (ports.contains(value.trim())) {
                        return appLocalizations.portConflictTip;
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    maxLines: 1,
                    minLines: 1,
                    inputFormatters: TextInputLimits.digitsOnly(
                      TextInputLimits.port,
                    ),
                    controller: _socksPortController,
                    onFieldSubmitted: (_) {
                      _handleUpdate();
                    },
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: appLocalizations.socksPort,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return appLocalizations.emptyTip(
                          appLocalizations.socksPort,
                        );
                      }
                      final port = int.tryParse(value);
                      if (port == null) {
                        return appLocalizations.numberTip(
                          appLocalizations.socksPort,
                        );
                      }
                      if (port == 0) {
                        return null;
                      }
                      if (port < 1024 || port > 49151) {
                        return appLocalizations.portTip(
                          appLocalizations.socksPort,
                        );
                      }
                      final ports = [
                        _portController.text,
                        _mixedPortController.text,
                        _tProxyPortController.text,
                        _redirPortController.text,
                      ].map((item) => item.trim());
                      if (ports.contains(value.trim())) {
                        return appLocalizations.portConflictTip;
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    maxLines: 1,
                    minLines: 1,
                    inputFormatters: TextInputLimits.digitsOnly(
                      TextInputLimits.port,
                    ),
                    controller: _redirPortController,
                    onFieldSubmitted: (_) {
                      _handleUpdate();
                    },
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: appLocalizations.redirPort,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return appLocalizations.emptyTip(
                          appLocalizations.redirPort,
                        );
                      }
                      final port = int.tryParse(value);
                      if (port == null) {
                        return appLocalizations.numberTip(
                          appLocalizations.redirPort,
                        );
                      }
                      if (port == 0) {
                        return null;
                      }
                      if (port < 1024 || port > 49151) {
                        return appLocalizations.portTip(
                          appLocalizations.redirPort,
                        );
                      }
                      final ports = [
                        _portController.text,
                        _socksPortController.text,
                        _tProxyPortController.text,
                        _mixedPortController.text,
                      ].map((item) => item.trim());
                      if (ports.contains(value.trim())) {
                        return appLocalizations.portConflictTip;
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    maxLines: 1,
                    minLines: 1,
                    inputFormatters: TextInputLimits.digitsOnly(
                      TextInputLimits.port,
                    ),
                    controller: _tProxyPortController,
                    onFieldSubmitted: (_) {
                      _handleUpdate();
                    },
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: appLocalizations.tproxyPort,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return appLocalizations.emptyTip(
                          appLocalizations.tproxyPort,
                        );
                      }
                      final port = int.tryParse(value);
                      if (port == null) {
                        return appLocalizations.numberTip(
                          appLocalizations.tproxyPort,
                        );
                      }
                      if (port == 0) {
                        return null;
                      }
                      if (port < 1024 || port > 49151) {
                        return appLocalizations.portTip(
                          appLocalizations.tproxyPort,
                        );
                      }
                      final ports = [
                        _portController.text,
                        _socksPortController.text,
                        _mixedPortController.text,
                        _redirPortController.text,
                      ].map((item) => item.trim());
                      if (ports.contains(value.trim())) {
                        return appLocalizations.portConflictTip;
                      }

                      return null;
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
