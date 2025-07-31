import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/card.dart';
import 'package:fl_clash/widgets/input.dart';
import 'package:fl_clash/widgets/list.dart';
import 'package:fl_clash/widgets/null_status.dart';
import 'package:fl_clash/widgets/popup.dart';
import 'package:fl_clash/widgets/scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScriptsView extends ConsumerStatefulWidget {
  const ScriptsView({super.key});

  @override
  ConsumerState<ScriptsView> createState() => _ScriptsViewState();
}

class _ScriptsViewState extends ConsumerState<ScriptsView> {
  Future<void> _handleDelScript(String label) async {
    final res = await globalState.showMessage(
      message: TextSpan(
        text: appLocalizations.deleteTip(appLocalizations.script),
      ),
    );
    if (res != true) {
      return;
    }
    ref.read(scriptStateProvider.notifier).del(label);
  }

  Widget _buildContent() {
    return Consumer(
      builder: (_, ref, _) {
        final vm2 = ref.watch(
          scriptStateProvider.select(
            (state) => VM2(a: state.currentId, b: state.scripts),
          ),
        );
        final currentId = vm2.a;
        final scripts = vm2.b;
        if (scripts.isEmpty) {
          return NullStatus(
            label: appLocalizations.nullTip(appLocalizations.script),
          );
        }
        return RadioGroup(
          onChanged: (value) {
            if (value == null) {
              return;
            }
            ref.read(scriptStateProvider.notifier).setId(value);
          },
          groupValue: currentId,
          child: ListView.builder(
            padding: kMaterialListPadding.copyWith(bottom: 16 + 64),
            itemCount: scripts.length,
            itemBuilder: (_, index) {
              final script = scripts[index];
              return Container(
                padding: kTabLabelPadding,
                margin: EdgeInsets.symmetric(vertical: 6),
                child: CommonCard(
                  type: CommonCardType.filled,
                  radius: 16,
                  child: ListItem.radio(
                    padding: const EdgeInsets.only(left: 12, right: 12),
                    title: Text(script.label),
                    delegate: RadioDelegate(
                      value: script.id,
                      onTab: () {
                        ref.read(scriptStateProvider.notifier).setId(script.id);
                      },
                    ),
                    trailing: CommonPopupBox(
                      targetBuilder: (open) {
                        return IconButton(
                          onPressed: () {
                            open();
                          },
                          icon: Icon(Icons.more_vert),
                        );
                      },
                      popup: CommonPopupMenu(
                        items: [
                          PopupMenuItemData(
                            icon: Icons.edit,
                            label: appLocalizations.edit,
                            onPressed: () {
                              _handleToEditor(script: script);
                            },
                          ),
                          PopupMenuItemData(
                            icon: Icons.delete,
                            label: appLocalizations.delete,
                            onPressed: () {
                              _handleDelScript(script.label);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
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
    Script newScript =
        script?.copyWith(label: title, content: content) ??
        Script.create(label: title, content: content);
    if (newScript.label.isEmpty) {
      final res = await globalState.showCommonDialog<String>(
        child: InputDialog(
          title: appLocalizations.save,
          value: '',
          hintText: appLocalizations.pleaseEnterScriptName,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return appLocalizations.emptyTip(appLocalizations.name);
            }
            if (value != script?.label) {
              final isExits = ref
                  .read(scriptStateProvider.notifier)
                  .isExits(value);
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
          .read(scriptStateProvider.notifier)
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
    ref.read(scriptStateProvider.notifier).setScript(newScript);
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

  void _handleToEditor({Script? script}) {
    final title = script?.label ?? '';
    final raw = script?.content ?? scriptTemplate;
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
    return CommonScaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _handleToEditor();
        },
        child: Icon(Icons.add),
      ),
      body: _buildContent(),
      title: appLocalizations.script,
    );
  }
}
