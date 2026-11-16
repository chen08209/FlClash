import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:flutter/widgets.dart';

import 'sync.dart';

Future<void> showICloudConflict(
  BuildContext context,
  ICloudYamlSync sync,
  YamlConflict conflict,
) async {
  final l = context.appLocalizations;
  final local = await dialogs.showMessage(
    context: context,
    title: '${l.sync}: ${conflict.name}',
    message: TextSpan(text: '${l.local} ≠ ${l.remote}'),
    confirmText: '${l.local} → ${l.remote}',
    cancelText: '${l.remote} → ${l.local}',
  );
  if (local == null || !context.mounted) return;
  await sync.sync(resolve: conflict, useLocal: local);
}

class ICloudSyncSection extends StatelessWidget {
  const ICloudSyncSection({super.key, required this.sync});

  final ICloudYamlSync sync;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    return ListenableBuilder(
      listenable: sync,
      builder: (context, _) => generateSection(
        title: 'iCloud Drive · YAML',
        items: [
          ListItem(
            title: Text(l.file),
            subtitle: Text(sync.folder ?? l.disabled),
            trailing: TonalButton(
              label: l.select,
              onPressed: sync.busy ? null : sync.selectFolder,
            ),
          ),
          if (sync.folder != null) ...[
            ListItem(
              title: Text(l.sync),
              subtitle: Text('${l.autoUpdateInterval}: 30 ${l.seconds}'),
              trailing: sync.busy ? const ActivityIndicator(size: 12) : null,
              onTap: sync.busy ? null : () => sync.sync(),
            ),
            for (final conflict in sync.conflicts.values)
              ListItem(
                title: Text(conflict.name),
                subtitle: Text('${l.local} ≠ ${l.remote}'),
                onTap: sync.busy
                    ? null
                    : () => showICloudConflict(context, sync, conflict),
              ),
            for (final name in sync.missing)
              ListItem(
                title: Text(name),
                subtitle: Text('${l.local} / ${l.remote}: ${l.noInfo}'),
              ),
            ListItem(
              title: Text(l.enabled),
              trailing: Switch(
                value: true,
                semanticLabel: 'iCloud Drive · ${l.sync}',
                onChanged: sync.busy ? null : (_) => sync.disable(),
              ),
            ),
          ],
          if (sync.error != null)
            ListItem(
              title: Text(l.error),
              subtitle: Text(compactError(sync.error!)),
            ),
        ],
      ),
    );
  }
}
