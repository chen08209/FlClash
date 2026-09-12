import 'dart:async';

import 'package:fl_clash/ai_mcp/service.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/ai_mcp.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class AiMcpView extends ConsumerWidget {
  const AiMcpView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(aiMcpServiceProvider);
    final l10n = context.appLocalizations;
    return ListenableBuilder(
      listenable: service,
      builder: (context, _) => CommonScaffold(
        title: l10n.aiMcpTitle,
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListItem.toggle(
              title: Text(l10n.aiMcpEnable),
              subtitle: Text(
                service.changing
                    ? l10n.aiMcpChanging
                    : service.enabled
                    ? l10n.aiMcpRunning
                    : l10n.aiMcpStopped,
              ),
              value: service.enabled,
              onChanged: service.ready && !service.changing
                  ? service.setEnabled
                  : null,
            ),
            if (service.error != null)
              ListItem(
                leading: const Icon(Icons.error_outline),
                title: Text(
                  service.error == AiMcpError.storage
                      ? l10n.aiMcpStorageError
                      : l10n.aiMcpListenError,
                ),
              ),
            if (service.enabled || service.changing)
              ListItem(
                title: Text(l10n.aiMcpPort),
                subtitle: Text('${service.port}'),
              )
            else
              ListItem.input(
                title: Text(l10n.aiMcpPort),
                subtitle: Text('${service.port}'),
                dialogTitle: l10n.aiMcpPort,
                value: '${service.port}',
                keyboardType: TextInputType.number,
                maxLength: 5,
                validator: (value) {
                  final port = int.tryParse(value ?? '');
                  return port == null || port < 1024 || port > 65535
                      ? l10n.aiMcpPortInvalid
                      : null;
                },
                onChanged: (value) {
                  final port = int.tryParse(value ?? '');
                  if (port != null) unawaited(service.setPort(port));
                },
              ),
            ListHeader(title: l10n.aiMcpSetup),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(l10n.aiMcpSetupDescription),
            ),
            SelectableText('http://127.0.0.1:${service.port}/mcp'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  key: const Key('ai-mcp-copy'),
                  onPressed: service.ready
                      ? () async {
                          await Clipboard.setData(
                            ClipboardData(text: service.connectionConfig),
                          );
                          if (context.mounted) {
                            context.showNotifier(l10n.aiMcpCopied);
                          }
                        }
                      : null,
                  icon: const Icon(Icons.copy),
                  label: Text(l10n.aiMcpCopyConfig),
                ),
                OutlinedButton(
                  onPressed: service.ready && !service.changing
                      ? () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(l10n.aiMcpRotateToken),
                              content: Text(l10n.aiMcpRotateWarning),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text(l10n.cancel),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(l10n.confirm),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) await service.rotateToken();
                        }
                      : null,
                  child: Text(l10n.aiMcpRotateToken),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ListHeader(title: l10n.aiMcpAdvanced),
            Text(l10n.aiMcpAdvancedDescription),
            const SizedBox(height: 12),
            ListItem(
              leading: Icon(
                service.advanced ? Icons.lock_open : Icons.lock_outline,
              ),
              title: Text(
                service.advanced ? l10n.aiMcpUnlocked : l10n.aiMcpLocked,
              ),
              trailing: FilledButton(
                key: const Key('ai-mcp-gate'),
                onPressed: service.advanced
                    ? service.lock
                    : service.enabled && !service.changing
                    ? () async {
                        final revision = service.permissionRevision;
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => const AiMcpUnlockDialog(),
                        );
                        if (confirm == true &&
                            context.mounted &&
                            revision == service.permissionRevision) {
                          service.unlock();
                        }
                      }
                    : null,
                child: Text(
                  service.advanced ? l10n.aiMcpRelock : l10n.aiMcpUnlock,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AiMcpUnlockDialog extends StatefulWidget {
  const AiMcpUnlockDialog({super.key});

  @override
  State<AiMcpUnlockDialog> createState() => _AiMcpUnlockDialogState();
}

class _AiMcpUnlockDialogState extends State<AiMcpUnlockDialog> {
  late final Timer _timer;
  int _remaining = 3;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _remaining = (3 - timer.tick).clamp(0, 3));
      if (_remaining <= 0) timer.cancel();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    return AlertDialog(
      title: Text(l10n.aiMcpUnlock),
      content: Text(l10n.aiMcpUnlockWarning),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: const Key('ai-mcp-confirm-unlock'),
          onPressed: _remaining > 0 ? null : () => Navigator.pop(context, true),
          child: Text(
            _remaining > 0 ? l10n.aiMcpCountdown(_remaining) : l10n.confirm,
          ),
        ),
      ],
    );
  }
}
