import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/mitm_module.dart';
import 'package:fl_clash/common/mitm_network.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/mitm.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' show join;

String mitmNetworkChangeTitle(
  AppLocalizations appLocalizations,
  MitmNetworkChange change,
) => switch (change.key) {
  MitmNetworkKey.nameserver => 'Nameserver',
  MitmNetworkKey.defaultNameserver => 'Default Nameserver',
  MitmNetworkKey.fakeIpFilter => appLocalizations.fakeipFilter,
  MitmNetworkKey.nameserverPolicy => 'Nameserver Policy',
  MitmNetworkKey.hosts => 'Hosts',
  MitmNetworkKey.routeAddress => appLocalizations.routeAddress,
  MitmNetworkKey.routeExcludeAddress => appLocalizations.routeExcludeAddress,
  MitmNetworkKey.bypassDomain => appLocalizations.bypassDomain,
};

String mitmNetworkChangeValue(
  AppLocalizations appLocalizations,
  MitmNetworkChange change,
) {
  if (change.entry case final entry?) {
    return '$entry → ${change.values.join(', ')}';
  }
  final edit = change.edit;
  if (edit == null) {
    return appLocalizations.mitmChangeAppend(change.values.join(', '));
  }
  if (edit.replace) {
    return appLocalizations.mitmChangeReplace(edit.values.join(', '));
  }
  return [
    if (edit.before.isNotEmpty)
      appLocalizations.mitmChangeInsert(edit.before.join(', ')),
    if (edit.after.isNotEmpty)
      appLocalizations.mitmChangeAppend(edit.after.join(', ')),
  ].join('\n');
}

/// Scripts and network changes reach past the module's own hosts, so either
/// asks before the module turns on; declining records the answer.
Future<MitmModule> acceptMitmModule(WidgetRef ref, MitmModule module) async {
  if (!module.asksBeforeTurningOn) {
    return module.copyWith(enabled: true);
  }
  final content = ref.listenManual(
    mitmModuleContentProvider(module.id).future,
    (_, _) {},
  );
  final MitmModuleContent? read;
  try {
    read = await content.read();
  } finally {
    content.close();
  }
  final changes = read?.network.changes ?? const <MitmNetworkChange>[];
  final unverified = read?.skipVerifyHostname ?? const <String>[];
  final sources = read?.clientSourceAddress ?? const <String>[];
  final scripts = module.scripts > 0;
  final appLocalizations = currentAppLocalizations;
  final overrides = ref.read(
    profileOverridesProvider(ref.read(currentProfileIdProvider)),
  );
  final hosts = ref.read(patchClashConfigProvider).hosts;
  String line(MitmNetworkChange change) {
    final title = mitmNetworkChangeTitle(appLocalizations, change);
    final value = mitmNetworkChangeValue(appLocalizations, change);
    return [
      '• $title: $value',
      if (mitmChangeOverridesUser(change, overrides: overrides, hosts: hosts))
        '  ${appLocalizations.mitmChangeOverridesYours}',
    ].join('\n');
  }

  final accepted = await dialogs.showMessage(
    title: read?.asksConsent == true
        ? appLocalizations.mitmModuleRiskTitle
        : appLocalizations.mitmScriptRiskTitle,
    message: TextSpan(
      children: [
        if (unverified.isNotEmpty)
          TextSpan(
            text:
                '${appLocalizations.mitmSkipVerifyRisk(unverified.join(', '))}'
                '\n\n',
            style: AppTextStyle.emphasis,
          ),
        TextSpan(
          text: [
            if (scripts) appLocalizations.mitmScriptRisk,
            if (sources.isNotEmpty)
              appLocalizations.mitmClientSourceRisk(sources.join(', ')),
            if (changes.isNotEmpty)
              [
                appLocalizations.mitmNetworkRisk,
                for (final change in changes) line(change),
              ].join('\n'),
          ].join('\n\n'),
        ),
      ],
    ),
    confirmText: appLocalizations.turnOn,
  );
  return accepted == true
      ? module.copyWith(enabled: true, accepted: true)
      : module.copyWith(accepted: false);
}

Future<void> offerMitmModule(WidgetRef ref, MitmModule? module) async {
  if (module == null || !module.awaitsConsent) {
    return;
  }
  ref
      .read(mitmModulesActionProvider.notifier)
      .putModule(await acceptMitmModule(ref, module));
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
    await offerMitmModule(ref, saved);
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
