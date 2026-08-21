import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'general/port_dialog.dart';
part 'general/ua_dialog.dart';

class LogLevelItem extends ConsumerWidget {
  const LogLevelItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ConfigOptionsItem<LogLevel>(
      leading: const Icon(Icons.info_outline),
      title: (l) => l.logLevel,
      options: LogLevel.values,
      textBuilder: (logLevel) => logLevel.name,
      selector: patchClashConfigProvider.select((state) => state.logLevel),
      onChanged: (ref, value) => ref
          .read(patchClashConfigProvider.notifier)
          .update((state) => state.copyWith(logLevel: value)),
    );
  }
}

class UaItem extends ConsumerWidget {
  const UaItem({super.key});

  Future<void> _handleShowUaDialog(WidgetRef ref) async {
    final result = await dialogs.showCommonDialog<_UaDialogResult>(
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
    await dialogs.showCommonDialog(child: const _PortDialog());
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

ConfigToggleItem _clashToggle({
  required IconData icon,
  required ConfigLabel title,
  required ConfigLabel subtitle,
  required bool Function(PatchClashConfig state) select,
  required PatchClashConfig Function(PatchClashConfig state, bool value) update,
}) {
  return ConfigToggleItem(
    leading: Icon(icon),
    title: title,
    subtitle: subtitle,
    selector: patchClashConfigProvider.select(select),
    onChanged: (ref, value) => ref
        .read(patchClashConfigProvider.notifier)
        .update((state) => update(state, value)),
  );
}

final generalItems = <Widget>[
  const LogLevelItem(),
  const UaItem(),
  if (system.isDesktop) const KeepAliveIntervalItem(),
  const TestUrlItem(),
  const PortItem(),
  const HostsItem(),
  _clashToggle(
    icon: Icons.water_outlined,
    title: (l) => 'IPv6',
    subtitle: (l) => l.ipv6Desc,
    select: (state) => state.ipv6,
    update: (state, value) => state.copyWith(ipv6: value),
  ),
  _clashToggle(
    icon: Icons.device_hub,
    title: (l) => l.allowLan,
    subtitle: (l) => l.allowLanDesc,
    select: (state) => state.allowLan,
    update: (state, value) => state.copyWith(allowLan: value),
  ),
  _clashToggle(
    icon: Icons.compress_outlined,
    title: (l) => l.unifiedDelay,
    subtitle: (l) => l.unifiedDelayDesc,
    select: (state) => state.unifiedDelay,
    update: (state, value) => state.copyWith(unifiedDelay: value),
  ),
  ConfigToggleItem(
    leading: const Icon(Icons.dns_outlined),
    title: (l) => l.appendSystemDns,
    subtitle: (l) => l.appendSystemDnsTip,
    selector: networkSettingProvider.select((state) => state.appendSystemDns),
    onChanged: (ref, value) => ref
        .read(networkSettingProvider.notifier)
        .update((state) => state.copyWith(appendSystemDns: value)),
  ),
  _clashToggle(
    icon: Icons.polymer_outlined,
    title: (l) => l.findProcessMode,
    subtitle: (l) => l.findProcessModeDesc,
    select: (state) => state.findProcessMode == FindProcessMode.always,
    update: (state, value) => state.copyWith(
      findProcessMode: value ? FindProcessMode.always : FindProcessMode.off,
    ),
  ),
  _clashToggle(
    icon: Icons.double_arrow_outlined,
    title: (l) => l.tcpConcurrent,
    subtitle: (l) => l.tcpConcurrentDesc,
    select: (state) => state.tcpConcurrent,
    update: (state, value) => state.copyWith(tcpConcurrent: value),
  ),
  _clashToggle(
    icon: Icons.memory,
    title: (l) => l.geodataLoader,
    subtitle: (l) => l.geodataLoaderDesc,
    select: (state) => state.geodataLoader == GeodataLoader.memconservative,
    update: (state, value) => state.copyWith(
      geodataLoader: value
          ? GeodataLoader.memconservative
          : GeodataLoader.standard,
    ),
  ),
  _clashToggle(
    icon: Icons.api_outlined,
    title: (l) => l.externalController,
    subtitle: (l) => l.externalControllerDesc,
    select: (state) =>
        state.externalController == ExternalControllerStatus.open,
    update: (state, value) => state.copyWith(
      externalController: value
          ? ExternalControllerStatus.open
          : ExternalControllerStatus.close,
    ),
  ),
].separated(const Divider(height: 0)).toList();
