import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScriptsView extends ConsumerStatefulWidget {
  const ScriptsView({super.key});

  @override
  ConsumerState<ScriptsView> createState() => _ScriptsViewState();
}

class _ScriptsViewState extends ConsumerState<ScriptsView> {
  final _key = utils.id;

  Future<void> _handleDelScript(int id) async {
    final appLocalizations = context.appLocalizations;
    final res = await globalState.showMessage(
      message: TextSpan(
        text: appLocalizations.deleteTip(appLocalizations.script),
      ),
    );
    if (res != true) {
      return;
    }
    ref.read(scriptsProvider.notifier).del(id);
    ref.read(itemProvider(_key).notifier).value = null;
    _clearEffect(id);
  }

  Future<void> _clearEffect(int id) async {
    final path = await appPath.getScriptPath(id.toString());
    await File(path).safeDelete();
  }

  void _handleSelected(int id) {
    ref.read(itemProvider(_key).notifier).update((value) {
      if (value == id) {
        return null;
      }
      return id;
    });
  }

  Widget _buildContent(List<Script> scripts, int? selectedScriptId) {
    final appLocalizations = context.appLocalizations;
    if (scripts.isEmpty) {
      return NullStatus(
        illustration: const ScriptEmptyIllustration(),
        label: appLocalizations.nullTip(appLocalizations.script),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: scripts.length,
      itemBuilder: (_, index) {
        final script = scripts[index];
        return CommonSelectedListItem(
          isSelected: selectedScriptId == script.id,
          title: Text(
            script.label,
            style: context.textTheme.bodyLarge,
            maxLines: 3,
          ),
          onSelected: () {
            _handleSelected(script.id);
          },
          onPressed: () {
            _handleSelected(script.id);
          },
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
      final res = await globalState.showCommonDialog<String>(
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
        globalState.showMessage(
          message: TextSpan(
            text: appLocalizations.existsTip(appLocalizations.name),
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
    final res = await globalState.showMessage(
      message: TextSpan(text: appLocalizations.saveChanges),
    );
    if (res == true && mounted) {
      _handleEditorSave(context, title, content, script: script);
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
          return _handleEditorPop(context, title, content, raw, script: script);
        },
        languages: const [Language.javaScript],
        content: raw,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final scripts = ref.watch(scriptsProvider).value ?? [];
    final selectedScriptId = ref.watch(itemProvider(_key));
    return CommonPopScope(
      onPop: (_) {
        if (selectedScriptId != null) {
          ref.read(itemProvider(_key).notifier).value = null;
          return false;
        }
        Navigator.of(context).pop();
        return false;
      },
      child: CommonScaffold(
        actions: [
          if (selectedScriptId != null) ...[
            CommonMinIconButtonTheme(
              child: IconButton.filledTonal(
                onPressed: () {
                  _handleDelScript(selectedScriptId);
                },
                icon: const Icon(Icons.delete),
              ),
            ),
            const SizedBox(width: 2),
          ],
          CommonMinFilledButtonTheme(
            child: selectedScriptId != null
                ? FilledButton(
                    onPressed: () {
                      _handleToEditor(selectedScriptId);
                    },
                    child: Text(appLocalizations.edit),
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
        body: _buildContent(scripts, selectedScriptId),
        title: appLocalizations.script,
      ),
    );
  }
}
