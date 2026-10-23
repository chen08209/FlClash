import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/form/form.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/config/on_demand.dart';
import 'package:fl_clash/views/config/override.dart';
import 'package:fl_clash/views/config/user_agents.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'general/overrides.dart';
part 'general/port_form.dart';

class LogLevelItem extends ConsumerWidget {
  const LogLevelItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ConfigOptionsItem<LogLevel>(
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

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final globalUa = ref.watch(
      patchClashConfigProvider.select((state) => state.globalUa),
    );
    return ListItem.open(
      title: Text(appLocalizations.userAgent),
      subtitle: Text(globalUa ?? appLocalizations.defaultText),
      widget: const UserAgentsView(),
    );
  }
}

class DelayTestTimeoutItem extends ConsumerWidget {
  const DelayTestTimeoutItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ConfigOptionsItem<int>(
      title: (l) => l.delayTestTimeout,
      options: delayTestTimeoutOptions,
      textBuilder: (value) => '$value ms',
      selector: appSettingProvider.select((state) => state.delayTestTimeout),
      onChanged: (ref, value) => ref
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(delayTestTimeout: value)),
    );
  }
}

class PortItem extends ConsumerWidget {
  const PortItem({super.key});

  Future<void> handleShowPortForm(BuildContext context) async {
    await showFormSheet<void>(
      context: context,
      builder: (_) => const _PortForm(),
    );
  }

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final mixedPort = ref.watch(
      patchClashConfigProvider.select((state) => state.mixedPort),
    );
    return ListItem(
      title: Text(appLocalizations.port),
      subtitle: Text('$mixedPort'),
      onTap: () {
        handleShowPortForm(context);
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
      title: const Text('Hosts'),
      subtitle: Text(
        hosts.isEmpty
            ? appLocalizations.none
            : appLocalizations.itemsCount(hosts.length),
      ),
      widget: MapEditView(
        title: 'Hosts',
        entries: hosts,
        keyMaxLength: TextInputLimits.domain,
        valueMaxLength: TextInputLimits.hostValue,
        titleBuilder: (item) => Text(item.key),
        subtitleBuilder: (item) => Text(item.value),
      ),
      onChanged: (value) {
        if (value is! Map<String, String>) {
          return;
        }
        ref
            .read(patchClashConfigProvider.notifier)
            .update((state) => state.copyWith(hosts: value));
      },
    );
  }
}

class AuthenticationItem extends ConsumerWidget {
  const AuthenticationItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ConfigToggleItem(
      title: (l) => l.authentication,
      selector: networkSettingProvider.select(
        (state) => state.authentication.enable,
      ),
      onChanged: (ref, value) =>
          ref.read(networkSettingProvider.notifier).update((state) {
            var authentication = state.authentication.copyWith(enable: value);
            if (value && authentication.username.isEmpty) {
              authentication = authentication.copyWith(
                username: generateRandomSecret(8),
                password: generateRandomSecret(16),
              );
            }
            return state.copyWith(authentication: authentication);
          }),
    );
  }
}

class AuthenticationAccountItem extends ConsumerWidget {
  const AuthenticationAccountItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ConfigTextItem(
      title: (l) => l.account,
      maxLength: TextInputLimits.userName,
      selector: networkSettingProvider.select(
        (state) => state.authentication.username,
      ),
      // mihomo and the Dart proxy string both split user:pass on the first
      // colon, so a colon in the username breaks authentication.
      normalize: (value) => value.trim().replaceAll(':', ''),
      onChanged: (ref, value) => ref
          .read(networkSettingProvider.notifier)
          .update((state) => state.copyWith.authentication(username: value)),
    );
  }
}

class AuthenticationPasswordItem extends ConsumerWidget {
  const AuthenticationPasswordItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ConfigTextItem(
      title: (l) => l.password,
      maxLength: TextInputLimits.password,
      selector: networkSettingProvider.select(
        (state) => state.authentication.password,
      ),
      normalize: (value) => value.trim(),
      onChanged: (ref, value) => ref
          .read(networkSettingProvider.notifier)
          .update((state) => state.copyWith.authentication(password: value)),
    );
  }
}

class ExternalControllerSecretItem extends ConsumerWidget {
  const ExternalControllerSecretItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ConfigTextItem(
      title: (l) => l.externalControllerSecret,
      maxLength: TextInputLimits.password,
      selector: patchClashConfigProvider.select((state) => state.secret),
      normalize: (value) => value.trim(),
      onChanged: (ref, value) => ref
          .read(patchClashConfigProvider.notifier)
          .update((state) => state.copyWith(secret: value)),
    );
  }
}

ConfigToggleItem _clashToggle({
  required ConfigLabel title,
  required bool Function(PatchClashConfig state) select,
  required PatchClashConfig Function(PatchClashConfig state, bool value) update,
}) {
  return ConfigToggleItem(
    title: title,
    selector: patchClashConfigProvider.select(select),
    onChanged: (ref, value) => ref
        .read(patchClashConfigProvider.notifier)
        .update((state) => update(state, value)),
  );
}

ConfigToggleItem _appSettingToggle({
  required ConfigLabel title,
  required bool Function(AppSettingProps state) select,
  required AppSettingProps Function(AppSettingProps state, bool value) update,
}) {
  return ConfigToggleItem(
    title: title,
    selector: appSettingProvider.select(select),
    onChanged: (ref, value) => ref
        .read(appSettingProvider.notifier)
        .update((state) => update(state, value)),
  );
}

class GeneralView extends ConsumerWidget {
  const GeneralView({super.key});

  List<Widget> _startupItems(AppLocalizations appLocalizations) {
    return [
      if (system.isDesktop) ...[
        _appSettingToggle(
          title: (l) => l.autoLaunch,
          select: (state) => state.autoLaunch,
          update: (state, value) => state.copyWith(autoLaunch: value),
        ),
        _appSettingToggle(
          title: (l) => l.silentLaunch,
          select: (state) => state.silentLaunch,
          update: (state, value) => state.copyWith(silentLaunch: value),
        ),
      ],
      _appSettingToggle(
        title: (l) => l.autoRun,
        select: (state) => state.autoRun,
        update: (state, value) => state.copyWith(autoRun: value),
      ),
      ListItem.open(
        title: Text(appLocalizations.onDemand),
        widget: const OnDemandView(),
      ),
      _appSettingToggle(
        title: (l) => l.minimizeOnExit,
        select: (state) => state.minimizeOnExit,
        update: (state, value) => state.copyWith(minimizeOnExit: value),
      ),
      if (system.isAndroid) ...[
        _appSettingToggle(
          title: (l) => l.exclude,
          select: (state) => state.hidden,
          update: (state, value) => state.copyWith(hidden: value),
        ),
        _appSettingToggle(
          title: (l) => l.showNotificationStopAction,
          select: (state) => state.showNotificationStopAction,
          update: (state, value) =>
              state.copyWith(showNotificationStopAction: value),
        ),
      ],
    ];
  }

  List<Widget> _inboundItems({
    required bool authentication,
    required bool externalController,
  }) {
    return [
      const PortItem(),
      _clashToggle(
        title: (l) => l.allowLan,
        select: (state) => state.allowLan,
        update: (state, value) => state.copyWith(allowLan: value),
      ),
      _clashToggle(
        title: (l) => l.externalController,
        select: (state) =>
            state.externalController == ExternalControllerStatus.open,
        update: (state, value) => state
            .copyWith(
              externalController: value
                  ? ExternalControllerStatus.open
                  : ExternalControllerStatus.close,
            )
            .ensureControllerSecret(),
      ),
      if (externalController) const ExternalControllerSecretItem(),
      const AuthenticationItem(),
      if (authentication) ...const [
        AuthenticationAccountItem(),
        AuthenticationPasswordItem(),
      ],
    ];
  }

  List<Widget> _connectionItems() {
    return [
      const DelayTestTimeoutItem(),
      _clashToggle(
        title: (l) => l.findProcessMode,
        select: (state) => state.findProcessMode == FindProcessMode.always,
        update: (state, value) => state.copyWith(
          findProcessMode: value ? FindProcessMode.always : FindProcessMode.off,
        ),
      ),
      _appSettingToggle(
        title: (l) => l.autoCloseConnections,
        select: (state) => state.closeConnections,
        update: (state, value) => state.copyWith(closeConnections: value),
      ),
      _appSettingToggle(
        title: (l) => l.onlyStatisticsProxy,
        select: (state) => state.onlyStatisticsProxy,
        update: (state, value) => state.copyWith(onlyStatisticsProxy: value),
      ),
    ];
  }

  List<Widget> _requestItems() {
    return [
      const UaItem(),
      _appSettingToggle(
        title: (l) => l.checkCertificate,
        select: (state) => state.checkCertificate,
        update: (state, value) => state.copyWith(checkCertificate: value),
      ),
      _appSettingToggle(
        title: (l) => l.autoCheckUpdate,
        select: (state) => state.autoCheckUpdate,
        update: (state, value) => state.copyWith(autoCheckUpdate: value),
      ),
    ];
  }

  List<Widget> _coreItems() {
    return [
      const HostsItem(key: ValueKey(#hosts)),
      ConfigToggleItem(
        key: const ValueKey(#appendSystemDns),
        title: (l) => l.appendSystemDns,
        selector: networkSettingProvider.select(
          (state) => state.appendSystemDns,
        ),
        onChanged: (ref, value) => ref
            .read(networkSettingProvider.notifier)
            .update((state) => state.copyWith(appendSystemDns: value)),
      ),
    ];
  }

  List<Widget> _logItems() {
    return [
      const LogLevelItem(),
      _appSettingToggle(
        title: (l) => l.logcat,
        select: (state) => state.openLogs,
        update: (state, value) => state.copyWith(openLogs: value),
      ),
    ];
  }

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final authentication = ref.watch(
      networkSettingProvider.select((state) => state.authentication.enable),
    );
    final externalController = ref.watch(
      patchClashConfigProvider.select(
        (state) => state.externalController == ExternalControllerStatus.open,
      ),
    );
    return BaseScaffold(
      title: appLocalizations.general,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
          top: context.sectionsTopPadding,
          bottom: 16 + context.bottomInset,
        ),
        children: [
          generateSection(
            title: appLocalizations.startupAndBackground,
            items: _startupItems(appLocalizations),
            footer: [
              if (system.isDesktop) appLocalizations.silentLaunchDesc,
              appLocalizations.autoRunDesc,
              appLocalizations.onDemandDesc,
            ].join('\n'),
          ),
          generateSection(
            title: appLocalizations.requestsAndUpdates,
            items: _requestItems(),
            footer: appLocalizations.checkCertificateDesc,
          ),
          generateSection(
            title: appLocalizations.inbound,
            items: _inboundItems(
              authentication: authentication,
              externalController: externalController,
            ),
            footer: [
              appLocalizations.externalControllerDesc,
              appLocalizations.authenticationDesc,
            ].join('\n'),
          ),
          generateSection(
            title: appLocalizations.connection,
            items: _connectionItems(),
            footer: appLocalizations.autoCloseConnectionsDesc,
          ),
          OverrideSection(
            title: appLocalizations.core,
            spec: _generalOverrideSpec,
            items: _coreItems(),
          ),
          generateSection(
            title: appLocalizations.logsAndDiagnostics,
            items: _logItems(),
            footer: appLocalizations.logcatDesc,
          ),
        ],
      ),
    );
  }
}
