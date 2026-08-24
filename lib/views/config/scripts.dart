import 'dart:async';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScriptsView extends ConsumerStatefulWidget {
  const ScriptsView({super.key});

  @override
  ConsumerState<ScriptsView> createState() => _ScriptsViewState();
}

class _ScriptsViewState extends ConsumerState<ScriptsView> {
  final _key = uniqueId;

  Future<void> _handleDelete() async {
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(
        text: appLocalizations.deleteMultipTip(appLocalizations.script),
      ),
    );
    if (res != true) {
      return;
    }
    final selectedScriptIds = ref.read(itemsProvider(_key)).cast<int>();
    ref.read(scriptsProvider.notifier).delAll(selectedScriptIds);
    ref.read(itemsProvider(_key).notifier).value = {};
    for (final id in selectedScriptIds) {
      unawaited(_clearEffect(id));
    }
  }

  Future<void> _clearEffect(int id) async {
    final path = await appPath.getScriptPath(id.toString());
    await File(path).safeDelete();
  }

  void _handleSelected(int id) {
    ref.read(itemsProvider(_key).notifier).update((selectedScriptIds) {
      return Set<int>.from(selectedScriptIds)..addOrRemove(id);
    });
  }

  void _handleSelectAll() {
    final ids =
        ref.read(scriptsProvider).value?.map((item) => item.id).toSet() ?? {};
    ref.read(itemsProvider(_key).notifier).update((selected) {
      return selected.containsAll(ids) ? {} : ids;
    });
  }

  Widget _buildContent(List<Script> scripts, Set<dynamic> selectedScriptIds) {
    final appLocalizations = context.appLocalizations;
    if (scripts.isEmpty) {
      return NullStatus(
        illustration: const ScriptEmptyIllustration(),
        label: appLocalizations.nullTip(appLocalizations.script),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      itemCount: scripts.length,
      itemBuilder: (_, index) {
        final script = scripts[index];
        return ItemPositionProvider(
          position: ItemPosition.get(index, scripts.length),
          child: SelectedDecorationListItem(
            isSelected: selectedScriptIds.contains(script.id),
            isEditing: selectedScriptIds.isNotEmpty,
            title: Text(
              script.label,
              style: context.textTheme.bodyLarge,
              maxLines: 3,
            ),
            onSelected: () {
              _handleSelected(script.id);
            },
            onPressed: () {
              _handleToEditor(script.id);
            },
          ),
        );
      },
    );
  }

  Future<void> _handleEditorSave(
    BuildContext _,
    String title,
    String content, {
    Script? script,
  }) async {
    final appLocalizations = context.appLocalizations;
    Script newScript =
        (script?.copyWith(label: title) ?? Script.create(label: title));
    newScript = await newScript.save(content);
    if (newScript.label.isEmpty) {
      final res = await dialogs.showCommonDialog<String>(
        child: InputDialog(
          title: appLocalizations.save,
          value: '',
          hintText: appLocalizations.pleaseEnterScriptName,
          inputFormatters: TextInputLimits.limit(TextInputLimits.name),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return appLocalizations.emptyTip(appLocalizations.name);
            }
            if (value != script?.label) {
              final isExits = ref.read(scriptsProvider.notifier).isExits(value);
              if (isExits) {
                return appLocalizations.existsTip(appLocalizations.name);
              }
            }
            return null;
          },
        ),
      );
      if (res == null || res.isEmpty) {
        return;
      }
      newScript = newScript.copyWith(label: res);
    }
    if (newScript.label != script?.label) {
      final isExits = ref
          .read(scriptsProvider.notifier)
          .isExits(newScript.label);
      if (isExits) {
        unawaited(
          dialogs.showMessage(
            message: TextSpan(
              text: appLocalizations.existsTip(appLocalizations.name),
            ),
          ),
        );
        return;
      }
    }
    ref.read(scriptsProvider.notifier).put(newScript);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<bool> _handleEditorPop(
    BuildContext _,
    String title,
    String content,
    String raw, {
    Script? script,
  }) async {
    final appLocalizations = context.appLocalizations;
    if (content == raw) {
      return true;
    }
    final res = await dialogs.showMessage(
      message: TextSpan(text: appLocalizations.saveChanges),
    );
    if (res == true && mounted) {
      unawaited(_handleEditorSave(context, title, content, script: script));
    } else {
      return true;
    }
    return false;
  }

  void _handleToEditor([int? id]) async {
    final script = await ref.read(scriptProvider(id).future);
    final title = script?.label ?? '';
    final raw = (await script?.content) ?? scriptTemplate;
    if (!mounted) {
      return;
    }
    unawaited(
      BaseNavigator.push(
        context,
        EditorPage(
          titleEditable: true,
          title: title,
          supportRemoteDownload: true,
          onSave: (context, title, content) {
            _handleEditorSave(context, title, content, script: script);
          },
          onPop: (context, title, content) {
            return _handleEditorPop(
              context,
              title,
              content,
              raw,
              script: script,
            );
          },
          languages: const [Language.javaScript],
          content: raw,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final scripts = ref.watch(scriptsProvider).value ?? [];
    final selectedScriptIds = ref.watch(itemsProvider(_key));
    return CommonPopScope(
      onPop: (_) {
        if (selectedScriptIds.isNotEmpty) {
          ref.read(itemsProvider(_key).notifier).value = {};
          return false;
        }
        Navigator.of(context).pop();
        return false;
      },
      child: CommonScaffold(
        actions: [
          if (selectedScriptIds.isNotEmpty) ...[
            CommonMinIconButtonTheme(
              child: IconButton.filledTonal(
                tooltip: context.appLocalizations.delete,
                onPressed: _handleDelete,
                icon: const Icon(Icons.delete),
              ),
            ),
            const SizedBox(width: 2),
          ],
          CommonMinFilledButtonTheme(
            child: selectedScriptIds.isNotEmpty
                ? FilledButton(
                    onPressed: _handleSelectAll,
                    child: Text(appLocalizations.selectAll),
                  )
                : FilledButton.tonal(
                    onPressed: () {
                      _handleToEditor();
                    },
                    child: Text(appLocalizations.add),
                  ),
          ),
          const SizedBox(width: 8),
        ],
        body: _buildContent(scripts, selectedScriptIds),
        title: appLocalizations.script,
      ),
    );
  }
}
