import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/proxies/common.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TailscaleView extends ConsumerWidget {
  const TailscaleView({super.key});

  Future<void> _applyTailscaleConfig(WidgetRef ref) async {
    // Await apply so ping / status do not race the debounced profile merge.
    await ref.read(setupActionProvider.notifier).applyProfile(silence: true);
  }

  Future<void> _handleAddOrEdit(
    BuildContext context,
    WidgetRef ref, [
    TailscaleProxy? proxy,
  ]) async {
    final existingNames = ref
        .read(tailscaleSettingProvider)
        .proxies
        .map((item) => item.name)
        .toList();
    final res = await globalState.showCommonDialog<TailscaleProxy>(
      child: TailscaleNodeDialog(proxy: proxy, existingNames: existingNames),
    );
    if (res == null) {
      return;
    }
    ref
        .read(tailscaleSettingProvider.notifier)
        .addOrUpdate(res, previousName: proxy?.name);
    await _applyTailscaleConfig(ref);
  }

  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    TailscaleProxy proxy,
  ) async {
    final appLocalizations = context.appLocalizations;
    final res = await globalState.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(
        text: appLocalizations.deleteTip(appLocalizations.tailscale),
      ),
    );
    if (res != true) {
      return;
    }
    ref.read(tailscaleSettingProvider.notifier).remove(proxy.name);
    await _applyTailscaleConfig(ref);
  }

  Future<void> _handleTest(
    BuildContext context,
    WidgetRef ref,
    TailscaleProxy proxy,
  ) async {
    final appLocalizations = context.appLocalizations;
    if (!ref.read(tailscaleSettingProvider).enable) {
      context.showNotifier(appLocalizations.tailscaleTestNeedEnable);
      return;
    }
    if (!ref.read(isStartProvider)) {
      context.showNotifier(appLocalizations.tailscaleTestNeedStart);
      return;
    }
    await _applyTailscaleConfig(ref);
    await proxyDelayTest(Proxy(name: proxy.name, type: tailscaleProxyType));
  }

  Widget _buildScenarioCard(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final isAndroid = system.isAndroid;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colorScheme.primaryContainer.opacity38,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isAndroid ? Icons.phone_android : Icons.computer,
                  size: 20,
                  color: context.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isAndroid
                        ? appLocalizations.tailscaleScenarioAndroidTitle
                        : appLocalizations.tailscaleScenarioDesktopTitle,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isAndroid
                  ? appLocalizations.tailscaleScenarioAndroidBody
                  : appLocalizations.tailscaleScenarioDesktopBody,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideStep(BuildContext context, int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(text, style: context.textTheme.bodyMedium),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuide(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final isAndroid = system.isAndroid;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHighest.opacity38,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.checklist_outlined,
                  size: 20,
                  color: context.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  appLocalizations.tailscaleGuideTitle,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isAndroid) ...[
              _buildGuideStep(
                context,
                1,
                appLocalizations.tailscaleAndroidStep1,
              ),
              _buildGuideStep(
                context,
                2,
                appLocalizations.tailscaleAndroidStep2,
              ),
              _buildGuideStep(
                context,
                3,
                appLocalizations.tailscaleAndroidStep3,
              ),
              _buildGuideStep(
                context,
                4,
                appLocalizations.tailscaleAndroidStep4,
              ),
            ] else ...[
              _buildGuideStep(
                context,
                1,
                appLocalizations.tailscaleDesktopStep1,
              ),
              _buildGuideStep(
                context,
                2,
                appLocalizations.tailscaleDesktopStep2,
              ),
              _buildGuideStep(
                context,
                3,
                appLocalizations.tailscaleDesktopStep3,
              ),
              _buildGuideStep(
                context,
                4,
                appLocalizations.tailscaleDesktopStep4,
              ),
            ],
            const SizedBox(height: 4),
            Text(
              appLocalizations.tailscaleTestTip,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner(
    BuildContext context,
    WidgetRef ref, {
    required bool enable,
    required int nodeCount,
    required int routeCount,
  }) {
    final appLocalizations = context.appLocalizations;
    final isStart = ref.watch(isStartProvider);
    final String message;
    final Color? color;
    final IconData icon;
    if (!enable) {
      message = appLocalizations.tailscaleStatusDisabled;
      color = context.colorScheme.onSurfaceVariant;
      icon = Icons.pause_circle_outline;
    } else if (nodeCount == 0) {
      message = appLocalizations.tailscaleStatusNoNodes;
      color = context.colorScheme.tertiary;
      icon = Icons.info_outline;
    } else if (routeCount == 0) {
      message = appLocalizations.tailscaleStatusNeedRoutes;
      color = context.colorScheme.tertiary;
      icon = Icons.alt_route_outlined;
    } else if (!isStart) {
      message = appLocalizations.tailscaleStatusNeedStart;
      color = context.colorScheme.tertiary;
      icon = Icons.play_circle_outline;
    } else {
      message = appLocalizations.tailscaleStatusReady(nodeCount);
      color = context.colorScheme.primary;
      icon = Icons.check_circle_outline;
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: context.textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNodeDelay(BuildContext context, WidgetRef ref, String name) {
    final appLocalizations = context.appLocalizations;
    final delay = ref.watch(delayProvider(proxyName: name));
    if (delay == null) {
      return Text(
        appLocalizations.tailscaleNotTested,
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      );
    }
    if (delay == 0) {
      return SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: context.colorScheme.primary,
        ),
      );
    }
    return Text(
      delay > 0 ? '$delay ms' : appLocalizations.timeout,
      style: context.textTheme.labelSmall?.copyWith(
        color: utils.getDelayColor(delay),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  String _buildSubtitle(BuildContext context, TailscaleProxy proxy) {
    final appLocalizations = context.appLocalizations;
    final parts = <String>[];
    if (proxy.routes.isNotEmpty) {
      parts.add(
        appLocalizations.tailscaleRoutesCount(proxy.routes.length),
      );
    } else {
      parts.add(appLocalizations.tailscaleNoRoutes);
    }
    if (proxy.exitNode.trim().isNotEmpty) {
      parts.add('${appLocalizations.tailscaleExitNode}: ${proxy.exitNode}');
    }
    return parts.join(' · ');
  }

  Widget _buildNodeTile(
    BuildContext context,
    WidgetRef ref, {
    required TailscaleProxy proxy,
  }) {
    final appLocalizations = context.appLocalizations;
    return ListItem(
      leading: const Icon(Icons.device_hub),
      title: Text(
        proxy.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        _buildSubtitle(context, proxy),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildNodeDelay(context, ref, proxy.name),
          const SizedBox(width: 4),
          IconButton(
            tooltip: appLocalizations.tailscaleTestNode,
            onPressed: () {
              _handleTest(context, ref, proxy);
            },
            icon: const Icon(Icons.network_ping),
          ),
          IconButton(
            tooltip: appLocalizations.delete,
            onPressed: () {
              _handleDelete(context, ref, proxy);
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      onTap: () {
        _handleAddOrEdit(context, ref, proxy);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final props = ref.watch(tailscaleSettingProvider);
    final enable = props.enable;
    final proxies = props.proxies;
    final routeCount = proxies.fold<int>(
      0,
      (sum, proxy) => sum + proxy.routes.length,
    );
    final bypassRecommended = system.isDesktop;
    // Header block is always index 0; nodes follow.
    final itemCount = proxies.isEmpty ? 1 : proxies.length + 1;
    return CommonScaffold(
      title: appLocalizations.tailscale,
      actions: [
        IconButton(
          tooltip: appLocalizations.addTailscaleNode,
          onPressed: () {
            _handleAddOrEdit(context, ref);
          },
          icon: const Icon(Icons.add),
        ),
        const SizedBox(width: 8),
      ],
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: itemCount,
        itemBuilder: (_, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildScenarioCard(context),
                ListItem.toggle(
                  leading: const Icon(Icons.vpn_key_outlined),
                  title: Text(appLocalizations.tailscaleEnable),
                  subtitle: Text(appLocalizations.tailscaleEnableDesc),
                  value: enable,
                  onChanged: (value) async {
                    ref
                        .read(tailscaleSettingProvider.notifier)
                        .setEnable(value);
                    if (value &&
                        bypassRecommended &&
                        !ref.read(tailscaleSettingProvider).bypassTraffic) {
                      context.showNotifier(
                        appLocalizations.tailscaleBypassNudge,
                        actionState: MessageActionState(
                          actionText:
                              appLocalizations.tailscaleEnableBypassAction,
                          action: () async {
                            ref
                                .read(tailscaleSettingProvider.notifier)
                                .setBypassTraffic(true);
                            await _applyTailscaleConfig(ref);
                          },
                        ),
                      );
                    }
                    await _applyTailscaleConfig(ref);
                  },
                ),
                ListItem.toggle(
                  leading: const Icon(Icons.alt_route_outlined),
                  title: Text(appLocalizations.tailscaleBypass),
                  subtitle: Text(
                    bypassRecommended
                        ? appLocalizations.tailscaleBypassRecommended
                        : appLocalizations.tailscaleBypassAndroidHint,
                  ),
                  value: props.bypassTraffic,
                  onChanged: (value) async {
                    ref
                        .read(tailscaleSettingProvider.notifier)
                        .setBypassTraffic(value);
                    await _applyTailscaleConfig(ref);
                  },
                ),
                _buildStatusBanner(
                  context,
                  ref,
                  enable: enable,
                  nodeCount: proxies.length,
                  routeCount: routeCount,
                ),
                const Divider(height: 16),
                if (proxies.isEmpty)
                  _buildGuide(context)
                else
                  ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                    title: Text(appLocalizations.tailscaleShowSetupGuide),
                    children: [_buildGuide(context)],
                  ),
                if (proxies.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: Column(
                      children: [
                        NullStatus(label: appLocalizations.tailscaleEmptyTip),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () {
                            _handleAddOrEdit(context, ref);
                          },
                          icon: const Icon(Icons.add),
                          label: Text(appLocalizations.addTailscaleNode),
                        ),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Text(
                      appLocalizations.tailscaleNodesTitle,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            );
          }
          return _buildNodeTile(
            context,
            ref,
            proxy: proxies[index - 1],
          );
        },
      ),
    );
  }
}

class TailscaleNodeDialog extends StatefulWidget {
  final TailscaleProxy? proxy;
  final List<String> existingNames;

  const TailscaleNodeDialog({
    super.key,
    this.proxy,
    this.existingNames = const [],
  });

  @override
  State<TailscaleNodeDialog> createState() => _TailscaleNodeDialogState();
}

class _TailscaleNodeDialogState extends State<TailscaleNodeDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _authKeyController;
  late final TextEditingController _hostnameController;
  late final TextEditingController _controlUrlController;
  late final TextEditingController _stateDirController;
  late final TextEditingController _exitNodeController;
  late final TextEditingController _routesController;
  late bool _ephemeral;
  late bool _udp;
  late bool _acceptRoutes;
  late bool _exitNodeAllowLanAccess;
  late bool _showAdvanced;
  late bool _obscureAuthKey;

  @override
  void initState() {
    super.initState();
    final proxy = widget.proxy ?? const TailscaleProxy(name: '');
    _nameController = TextEditingController(text: proxy.name);
    _authKeyController = TextEditingController(text: proxy.authKey);
    _hostnameController = TextEditingController(text: proxy.hostname);
    _controlUrlController = TextEditingController(text: proxy.controlUrl);
    _stateDirController = TextEditingController(text: proxy.stateDir);
    _exitNodeController = TextEditingController(text: proxy.exitNode);
    _routesController = TextEditingController(text: proxy.routes.join('\n'));
    _ephemeral = proxy.ephemeral;
    _udp = proxy.udp;
    _acceptRoutes = proxy.acceptRoutes;
    _exitNodeAllowLanAccess = proxy.exitNodeAllowLanAccess;
    _obscureAuthKey = true;
    _showAdvanced =
        proxy.hostname.isNotEmpty ||
        proxy.controlUrl.isNotEmpty ||
        proxy.stateDir.isNotEmpty ||
        proxy.exitNode.isNotEmpty ||
        proxy.ephemeral ||
        !proxy.udp ||
        proxy.acceptRoutes ||
        proxy.exitNodeAllowLanAccess;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _authKeyController.dispose();
    _hostnameController.dispose();
    _controlUrlController.dispose();
    _stateDirController.dispose();
    _exitNodeController.dispose();
    _routesController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    final routes = _routesController.text
        .split(RegExp(r'[\n,]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    final proxy = TailscaleProxy(
      name: _nameController.text.trim(),
      authKey: _authKeyController.text.trim(),
      hostname: _hostnameController.text.trim(),
      controlUrl: _controlUrlController.text.trim(),
      stateDir: _stateDirController.text.trim(),
      exitNode: _exitNodeController.text.trim(),
      ephemeral: _ephemeral,
      udp: _udp,
      acceptRoutes: _acceptRoutes,
      exitNodeAllowLanAccess: _exitNodeAllowLanAccess,
      routes: routes,
    );
    Navigator.of(context).pop(proxy);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? helperText,
    int maxLines = 1,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: obscureText ? 1 : maxLines,
        obscureText: obscureText,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
          helperText: helperText,
          helperMaxLines: 3,
          alignLabelWithHint: maxLines > 1,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget _buildSwitch({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: context.textTheme.bodyLarge),
      value: value,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: widget.proxy != null
          ? appLocalizations.editTailscaleNode
          : appLocalizations.addTailscaleNode,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(appLocalizations.cancel),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: _handleSubmit,
          child: Text(appLocalizations.confirm),
        ),
      ],
      child: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _nameController,
                  label: appLocalizations.name,
                  helperText: appLocalizations.tailscaleNameHelper,
                  validator: (value) {
                    final name = value?.trim() ?? '';
                    if (name.isEmpty) {
                      return appLocalizations.emptyTip(appLocalizations.name);
                    }
                    final isEditingSame = widget.proxy?.name == name;
                    if (!isEditingSame &&
                        widget.existingNames.contains(name)) {
                      return appLocalizations.tailscaleNameExistsTip;
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _authKeyController,
                  label: appLocalizations.tailscaleAuthKey,
                  helperText: appLocalizations.tailscaleAuthKeyHint,
                  obscureText: _obscureAuthKey,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() => _obscureAuthKey = !_obscureAuthKey);
                    },
                    icon: Icon(
                      _obscureAuthKey
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                  validator: (value) {
                    final key = value?.trim() ?? '';
                    if (key.isEmpty) {
                      return appLocalizations.emptyTip(
                        appLocalizations.tailscaleAuthKey,
                      );
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _routesController,
                  label: appLocalizations.tailscaleRoutes,
                  helperText: appLocalizations.tailscaleRoutesHint,
                  maxLines: 3,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() => _showAdvanced = !_showAdvanced);
                    },
                    icon: Icon(
                      _showAdvanced
                          ? Icons.expand_less
                          : Icons.expand_more,
                    ),
                    label: Text(
                      _showAdvanced
                          ? appLocalizations.hideAdvanced
                          : appLocalizations.showAdvanced,
                    ),
                  ),
                ),
                if (_showAdvanced) ...[
                  _buildTextField(
                    controller: _hostnameController,
                    label: appLocalizations.tailscaleHostname,
                    helperText: appLocalizations.tailscaleHostnameHint,
                  ),
                  _buildTextField(
                    controller: _controlUrlController,
                    label: appLocalizations.tailscaleControlUrl,
                    helperText: appLocalizations.tailscaleControlUrlHint,
                  ),
                  _buildTextField(
                    controller: _stateDirController,
                    label: appLocalizations.tailscaleStateDir,
                    helperText: appLocalizations.tailscaleStateDirHint,
                  ),
                  _buildTextField(
                    controller: _exitNodeController,
                    label: appLocalizations.tailscaleExitNode,
                    helperText: appLocalizations.tailscaleExitNodeHint,
                  ),
                  _buildSwitch(
                    label: appLocalizations.tailscaleEphemeral,
                    value: _ephemeral,
                    onChanged: (value) {
                      setState(() {
                        _ephemeral = value;
                      });
                    },
                  ),
                  _buildSwitch(
                    label: appLocalizations.tailscaleUdp,
                    value: _udp,
                    onChanged: (value) {
                      setState(() {
                        _udp = value;
                      });
                    },
                  ),
                  _buildSwitch(
                    label: appLocalizations.tailscaleAcceptRoutes,
                    value: _acceptRoutes,
                    onChanged: (value) {
                      setState(() {
                        _acceptRoutes = value;
                      });
                    },
                  ),
                  _buildSwitch(
                    label: appLocalizations.tailscaleExitNodeAllowLanAccess,
                    value: _exitNodeAllowLanAccess,
                    onChanged: (value) {
                      setState(() {
                        _exitNodeAllowLanAccess = value;
                      });
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
