import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScriptsView extends ConsumerStatefulWidget {
  const ScriptsView({super.key});

  @override
  ConsumerState<ScriptsView> createState() => _ScriptsViewState();
}

class _ScriptsViewState extends ConsumerState<ScriptsView> {
  late final ScriptsAction _scriptsAction;

  @override
  void initState() {
    super.initState();
    _scriptsAction = ref.read(scriptsActionProvider.notifier);
  }

  Future<void> _handleDelete(Script script) async {
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(
        text: appLocalizations.deleteTip(appLocalizations.script),
      ),
    );
    if (res != true || !mounted) {
      return;
    }
    ref.read(scriptsProvider.notifier).del(script.id);
    unawaited(_clearEffect(script.id));
  }

  Future<void> _clearEffect(int id) async {
    final path = await appPath.getScriptPath(id.toString());
    await File(path).safeDelete();
  }

  Widget _buildContent(List<Script> scripts, {required bool isLoading}) {
    final appLocalizations = context.appLocalizations;
    return NullStatusSwitcher(
      isLoading: isLoading,
      isEmpty: scripts.isEmpty,
      nullStatus: NullStatus(
        illustration: NullStatusIllustration.scripts,
        label: appLocalizations.nullTip(appLocalizations.script),
      ),
      child: ReorderableListView.builder(
        padding: const EdgeInsets.all(
          16,
        ).copyWith(top: context.appBarInset + 16),
        buildDefaultDragHandles: false,
        itemCount: scripts.length,
        itemBuilder: (_, index) {
          final script = scripts[index];
          return ReorderableDelayedDragStartListener(
            key: ValueKey(script.id),
            index: index,
            child: _buildItem(script, index, scripts.length),
          );
        },
        proxyDecorator: (_, index, animation) {
          return commonProxyDecorator(
            _buildItem(scripts[index], index, scripts.length),
            index,
            animation,
          );
        },
        onReorderItem: ref.read(scriptsProvider.notifier).order,
      ),
    );
  }

  Widget _buildItem(Script script, int index, int length) {
    return ItemPositionProvider(
      position: ItemPosition.get(index, length),
      child: DecorationListItem(
        minVerticalPadding: 0,
        contentPadding: const EdgeInsets.only(left: 16, right: 6),
        title: _ScriptItemTitle(script: script),
        trailing: _ScriptItemMenu(
          script: script,
          onEdit: () {
            _handleToEditor(script);
          },
          onEditUrl: () {
            _handleEditUrl(script);
          },
          onUpdate: () {
            _handleUpdate(script);
          },
          onDelete: () {
            _handleDelete(script);
          },
        ),
        onPressed: () {
          _handleToEditor(script);
        },
      ),
    );
  }

  Future<void> _handleEditUrl(Script script) async {
    final url = await dialogs.showUrlInput(
      title: context.appLocalizations.url,
      value: script.url ?? '',
    );
    if (url == null || url == script.url) {
      return;
    }
    await _handleUpdate(script.copyWith(url: url));
  }

  Future<void> _handleUpdate(Script script) async {
    await globalState.safeRun(
      () => _scriptsAction.updateScript(script),
      title: script.label,
    );
  }

  List<Script> get _scripts => ref.read(scriptsProvider).value ?? [];

  String? _validateName(String? value, {Script? script}) {
    final appLocalizations = context.appLocalizations;
    final label = value?.trim() ?? '';
    if (label.isEmpty) {
      return appLocalizations.emptyTip(appLocalizations.name);
    }
    if (_scripts.hasLabel(label, except: script)) {
      return appLocalizations.existsTip(appLocalizations.name);
    }
    return null;
  }

  Future<String?> _showNameDialog({Script? script}) async {
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showCommonDialog<String>(
      child: InputDialog(
        title: appLocalizations.save,
        value: '',
        hintText: appLocalizations.pleaseEnterScriptName,
        inputFormatters: TextInputLimits.limit(TextInputLimits.name),
        validator: (value) => _validateName(value, script: script),
      ),
    );
    return res?.trim().value;
  }

  Future<void> _handleEditorSave(
    BuildContext _,
    String title,
    String content, {
    Script? script,
  }) async {
    final appLocalizations = context.appLocalizations;
    var label = title.trim();
    if (label.isEmpty) {
      final res = await _showNameDialog(script: script);
      if (res == null) {
        return;
      }
      label = res;
    }
    if (_scripts.hasLabel(label, except: script)) {
      unawaited(
        dialogs.showMessage(
          message: TextSpan(
            text: appLocalizations.existsTip(appLocalizations.name),
          ),
        ),
      );
      return;
    }
    final newScript =
        await (script?.copyWith(label: label) ?? Script.create(label: label))
            .save(content);
    _scriptsAction.putScript(newScript);
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
    if (res == null) {
      return false;
    }
    if (res && mounted) {
      unawaited(_handleEditorSave(context, title, content, script: script));
    } else {
      return true;
    }
    return false;
  }

  Future<void> _handleToEditor([Script? script]) async {
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
          language: Language.javaScript,
          content: raw,
        ),
      ),
    );
  }

  Future<void> _handleImport(
    String content, {
    String? url,
    required String fileName,
  }) async {
    final label = _scripts.uniqueLabel(
      fileName.fileStem,
      fallback: context.appLocalizations.script,
    );
    final script = await Script.create(label: label, url: url).save(content);
    _scriptsAction.putScript(script);
  }

  Future<void> _handleImportFromUrl() async {
    final appLocalizations = context.appLocalizations;
    final url = await dialogs.showUrlInput(title: appLocalizations.importUrl);
    if (url == null) {
      return;
    }
    final res = await globalState.loadingRun(
      () => request.getTextResponseForUrl(url),
      title: appLocalizations.importUrl,
      tag: LoadingTag.scripts,
    );
    if (res == null || !mounted) {
      return;
    }
    final fileName =
        Uri.tryParse(
          url,
        )?.pathSegments.lastWhereOrNull((it) => it.isNotEmpty) ??
        '';
    await _handleImport(res.data ?? '', url: url, fileName: fileName);
  }

  Future<void> _handleImportFromFile() async {
    final file = await globalState.safeRun(picker.pickerFile);
    if (file == null) {
      return;
    }
    final content = await globalState.safeRun(
      () async => utf8.decode(await file.readBytes()),
    );
    if (content == null || !mounted) {
      return;
    }
    await _handleImport(content, fileName: file.name);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final scriptsState = ref.watch(scriptsProvider);
    final scripts = scriptsState.value ?? [];
    final isLoading = ref.watch(loadingProvider(LoadingTag.scripts));
    return CommonScaffold(
      isLoading: isLoading,
      actions: [
        CommonPopupBox(
          targetBuilder: (open) {
            return FilledButton.tonal(
              onPressed: () {
                final isMobile = ref.read(isMobileViewProvider);
                open(offset: Offset(0, isMobile ? 0 : 20));
              },
              child: Text(appLocalizations.add),
            );
          },
          popupBuilder: (_) => CommonPopupMenu(
            items: [
              CommonPopupMenuItem(
                glyph: AppGlyphs.compose,
                label: appLocalizations.startFromScratch,
                onPressed: _handleToEditor,
              ),
              CommonPopupMenuItem(
                glyph: AppGlyphs.cloudDownload,
                label: appLocalizations.importUrl,
                onPressed: _handleImportFromUrl,
              ),
              CommonPopupMenuItem(
                glyph: AppGlyphs.importFile,
                label: appLocalizations.importFile,
                onPressed: _handleImportFromFile,
              ),
            ],
          ),
        ),
      ],
      body: _buildContent(scripts, isLoading: scriptsState.isLoading),
      title: appLocalizations.script,
    );
  }
}

class _ScriptItemTitle extends StatelessWidget {
  const _ScriptItemTitle({required this.script});

  final Script script;

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            script.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style.copyWith(
              fontSize: context.textTheme.bodyLarge?.fontSize,
            ),
          ),
          if (script.url != null)
            LastUpdateTimeText(
              lastUpdateDate: script.lastUpdateTime,
              style: style.copyWith(
                fontSize: context.textTheme.bodySmall?.fontSize,
                color: style.color?.opacity60,
              ),
            ),
        ],
      ),
    );
  }
}

class _ScriptItemMenu extends ConsumerWidget {
  const _ScriptItemMenu({
    required this.script,
    required this.onEdit,
    required this.onEditUrl,
    required this.onUpdate,
    required this.onDelete,
  });

  final Script script;
  final VoidCallback onEdit;
  final VoidCallback onEditUrl;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final isUpdating = ref.watch(isUpdatingProvider(script.updatingKey));
    return SizedBox.square(
      dimension: 40,
      child: FadeThroughBox(
        alignment: Alignment.center,
        child: isUpdating
            ? const Padding(
                key: ValueKey('loading'),
                padding: EdgeInsets.all(8),
                child: CommonCircleLoading(),
              )
            : CommonPopupBox(
                key: const ValueKey('menu'),
                popupBuilder: (_) => CommonPopupMenu(
                  items: [
                    CommonPopupMenuItem(
                      glyph: AppGlyphs.edit,
                      label: appLocalizations.edit,
                      onPressed: onEdit,
                    ),
                    if (script.url != null) ...[
                      CommonPopupMenuItem(
                        glyph: AppGlyphs.link,
                        label: appLocalizations.url,
                        onPressed: onEditUrl,
                      ),
                      CommonPopupMenuItem(
                        glyph: AppGlyphs.sync,
                        label: appLocalizations.sync,
                        onPressed: onUpdate,
                      ),
                    ],
                    CommonPopupMenuItem(
                      danger: true,
                      glyph: AppGlyphs.delete,
                      label: appLocalizations.delete,
                      onPressed: onDelete,
                    ),
                  ],
                ),
                targetBuilder: (open) {
                  return IconButton(
                    style: IconButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.standard,
                    ),
                    tooltip: appLocalizations.more,
                    onPressed: () {
                      open();
                    },
                    icon: const GlyphIcon(AppGlyphs.more),
                  );
                },
              ),
      ),
    );
  }
}
