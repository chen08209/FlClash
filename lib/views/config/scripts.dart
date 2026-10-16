import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
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
      destructive: true,
      confirmText: appLocalizations.delete,
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
        ).copyWith(top: context.contentTopPadding),
        buildDefaultDragHandles: false,
        itemCount: scripts.length,
        itemBuilder: (_, index) => _buildItem(scripts, index),
        proxyDecorator: (_, index, animation) {
          return commonProxyDecorator(
            _buildItem(scripts, index),
            index,
            animation,
          );
        },
        onReorderItem: ref.read(scriptsProvider.notifier).order,
      ),
    );
  }

  List<CommonPopupMenuItem> _buildMenuItems(Script script) {
    final appLocalizations = context.appLocalizations;
    return [
      CommonPopupMenuItem(
        glyph: AppGlyphs.edit,
        label: appLocalizations.edit,
        onPressed: () {
          _handleToEditor(script);
        },
      ),
      if (script.url != null) ...[
        CommonPopupMenuItem(
          glyph: AppGlyphs.link,
          label: appLocalizations.url,
          onPressed: () {
            _handleEditUrl(script);
          },
        ),
        CommonPopupMenuItem(
          glyph: AppGlyphs.sync,
          label: appLocalizations.sync,
          onPressed: () {
            _handleUpdate(script);
          },
        ),
      ],
      CommonPopupMenuItem(
        danger: true,
        glyph: AppGlyphs.delete,
        label: appLocalizations.delete,
        onPressed: () {
          _handleDelete(script);
        },
      ),
    ];
  }

  Widget _buildItem(List<Script> scripts, int index) {
    final script = scripts[index];
    return SortableItem(
      key: ValueKey(script.id),
      index: index,
      child: Consumer(
        builder: (_, ref, child) => ContextMenuRegion(
          menuItems: ref.watch(isUpdatingProvider(script.updatingKey))
              ? null
              : _buildMenuItems(script),
          child: child!,
        ),
        child: ItemPositionProvider(
          position: ItemPosition.get(index, scripts.length),
          child: DecorationListItem(
            contentPadding: const EdgeInsets.only(left: 16),
            title: Text(
              script.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              script.url != null
                  ? context.appLocalizations.remote
                  : context.appLocalizations.local,
              style: context.listCaptionStyle,
            ),
            trailing: _ScriptTrailing(script: script),
            onPressed: () {
              _handleToEditor(script);
            },
          ),
        ),
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
    if (content == raw && title == (script?.label ?? '')) {
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

  void _handleToEditor([Script? script]) {
    late final String raw;
    unawaited(
      BaseNavigator.push(
        context,
        EditorPage(
          titleEditable: true,
          title: script?.label ?? '',
          onSave: (context, title, content) =>
              _handleEditorSave(context, title, content, script: script),
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
          load: () async => raw = (await script?.content) ?? scriptTemplate,
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
      canSort: scripts.length > 1,
      isLoading: isLoading,
      actions: [
        CommonPopupBox(
          targetBuilder: (open) {
            return IconButton(
              tooltip: appLocalizations.add,
              onPressed: open,
              icon: const GlyphIcon(AppGlyphs.addCircle),
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

class _ScriptTrailing extends ConsumerWidget {
  const _ScriptTrailing({required this.script});

  final Script script;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUpdating = ref.watch(isUpdatingProvider(script.updatingKey));
    // Inset here, not in the row, so the sort handle that replaces it sits flush.
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 16),
      child: AnimatedSwitcher(
        duration: context.motionDuration(commonDuration),
        layoutBuilder: (current, previous) => Stack(
          alignment: AlignmentDirectional.centerEnd,
          children: [...previous, ?current],
        ),
        child: isUpdating
            ? const CommonCircleLoading(key: ValueKey('loading'), size: 24)
            : LastUpdateTimeText(
                key: const ValueKey('time'),
                lastUpdateDate: script.lastUpdateTime,
                compact: true,
                style: context.listCaptionStyle,
              ),
      ),
    );
  }
}
