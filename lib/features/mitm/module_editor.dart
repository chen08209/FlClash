import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' show join;

Future<bool> acceptMitmScripts() async {
  final appLocalizations = currentAppLocalizations;
  final accepted = await dialogs.showMessage(
    title: appLocalizations.mitmScriptRiskTitle,
    message: TextSpan(text: appLocalizations.mitmScriptRisk),
    confirmText: appLocalizations.turnOn,
  );
  return accepted == true;
}

Future<void> offerMitmScripts(WidgetRef ref, MitmModule? module) async {
  if (module != null && !module.enabled && await acceptMitmScripts()) {
    ref
        .read(mitmModulesActionProvider.notifier)
        .putModule(module.copyWith(enabled: true));
  }
}

/// An update that brings new or changed scripts turned the module off, so it
/// asks to turn it back on.
Future<void> updateMitmModule(WidgetRef ref, MitmModule module) async {
  final updated = await ref
      .read(mitmModulesActionProvider.notifier)
      .updateModule(module);
  if (module.enabled && !updated.enabled) {
    await offerMitmScripts(ref, updated);
  }
}

String _moduleTemplate(String name) =>
    '#!name=$name\n#!desc=\n\n[URL Rewrite]\n\n[MITM]\nhostname = %APPEND%\n';

/// Opens [module], or a new one, with [edit] applied as a change to save;
/// [attachments] join the module once it is saved.
Future<void> openMitmModuleEditor(
  BuildContext context,
  WidgetRef ref, {
  MitmModule? module,
  String Function(String text)? edit,
  Map<String, List<int>> attachments = const {},
}) async {
  final appLocalizations = context.appLocalizations;
  final action = ref.read(mitmModulesActionProvider.notifier);
  final path = module == null
      ? null
      : join(await appPath.mitmModulesDirPath, module.fileName);
  Future<void> save(BuildContext context, EditorContent content) async {
    final text = await content.readText();
    final saved = await globalState.loadingRun(() async {
      final saved = module == null
          ? await action.create(text)
          : await action.edit(module, text);
      for (final MapEntry(key: name, value: bytes) in attachments.entries) {
        await action.attach(saved, name, bytes);
      }
      return saved;
    }, tag: LoadingTag.mitm);
    if (saved == null) {
      return;
    }
    if (context.mounted) {
      Navigator.of(context).pop();
    }
    await offerMitmScripts(ref, saved);
  }

  if (!context.mounted) {
    return;
  }
  await BaseNavigator.push(
    context,
    EditorPage(
      title: module?.name ?? appLocalizations.mitmNewModule,
      language: Language.ini,
      load: () async => path == null
          ? CodeForgeDocument.fromText(
              _moduleTemplate(appLocalizations.mitmModule),
            )
          : openEditorFile(path),
      edit: edit,
      onSave: (context, _, content) => save(context, content),
      onPop: (context, _, content) async {
        final res = await dialogs.showSaveChanges();
        if (res == true && context.mounted) {
          unawaited(save(context, content));
        }
        return res == false;
      },
    ),
  );
}
