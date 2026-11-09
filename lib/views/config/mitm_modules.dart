import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/mitm_module.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/features.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/mitm.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

MitmModule? _moduleOf(WidgetRef ref, int id) => ref.watch(
  mitmModulesProvider.select(
    (state) => state.value?.firstWhereOrNull((item) => item.id == id),
  ),
);

void _putModule(WidgetRef ref, MitmModule module) {
  ref.read(mitmModulesActionProvider.notifier).putModule(module);
}

Future<void> _setEnabled(WidgetRef ref, MitmModule module, bool enabled) async {
  if (enabled && module.scripts > 0 && !await acceptMitmScripts()) {
    return;
  }
  _putModule(ref, module.copyWith(enabled: enabled));
}

/// Runs a cron, event or generic script line now; any other line, any while
/// decryption is off, and a task still running have none.
PopupMenuItem? mitmRunScriptItem(WidgetRef ref, String line) {
  final name = mitmTaskName(line);
  if (name == null ||
      !ref.read(patchClashConfigProvider).mitm.enable ||
      ref.read(updatingKeysProvider).contains(_runKey(name))) {
    return null;
  }
  return PopupMenuItem(
    glyph: AppGlyphs.playPause(0),
    label: currentAppLocalizations.mitmRunScript,
    onPressed: () => _runScript(ref, name),
  );
}

String _runKey(String name) => 'mitm_script_$name';

class MitmTaskRunning extends ConsumerWidget {
  const MitmTaskRunning({super.key, required this.line, required this.builder});

  final String line;
  final Widget Function(bool running) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = mitmTaskName(line);
    return builder(
      name != null && ref.watch(isUpdatingProvider(_runKey(name))),
    );
  }
}

Future<void> _runScript(WidgetRef ref, String name) async {
  final updatingKeys = ref.read(updatingKeysProvider.notifier);
  final key = _runKey(name);
  final operation = updatingKeys.start(key, scope: UpdatingScope.core);
  final MitmScriptOutput? output;
  try {
    output = await globalState.safeRun(
      () => ref.read(coreHandlerProvider).runMitmScript(name),
      title: name,
      silence: false,
    );
  } finally {
    updatingKeys.stop(key, operation);
  }
  if (output == null) {
    return;
  }
  await dialogs.showAlert(
    title: name,
    message: TextSpan(text: _runOutput(output)),
  );
}

String _runOutput(MitmScriptOutput output) {
  final parts = [
    if (output.error.isNotEmpty) output.error,
    ?_resultText(output.result),
    ...output.logs,
  ];
  return parts.isEmpty
      ? currentAppLocalizations.mitmScriptNoOutput
      : parts.join('\n');
}

/// A panel script's title and content, or the value as the script gave it.
String? _resultText(String result) {
  if (result.isEmpty) {
    return null;
  }
  final Object? value;
  try {
    value = jsonDecode(result);
  } on FormatException {
    return result;
  }
  return switch (value) {
    null || '' => null,
    final String text => text,
    {'title': final Object title} => [
      title,
      if ((value as Map)['content'] case final Object content) content,
    ].join('\n'),
    final Map map when map.isEmpty => null,
    _ => result,
  };
}

Future<void> _updateModule(WidgetRef ref, MitmModule module) async {
  await globalState.safeRun<void>(
    () => updateMitmModule(ref, module),
    title: module.name,
    silence: false,
  );
}

class MitmModulesItem extends ConsumerWidget {
  const MitmModulesItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final count = ref.watch(
      mitmModulesProvider.select((state) => state.value?.length ?? 0),
    );
    return ListItem.open(
      title: Text(appLocalizations.mitmModules),
      subtitle: Text(
        count == 0 ? appLocalizations.none : appLocalizations.itemsCount(count),
      ),
      widget: const MitmModulesView(),
    );
  }
}

class MitmModulesView extends ConsumerWidget {
  const MitmModulesView({super.key});

  Future<void> _importFromUrl(BuildContext context, WidgetRef ref) async {
    final appLocalizations = context.appLocalizations;
    final input = await dialogs.showUrlInput(
      title: appLocalizations.importUrl,
      accepts: (value) => mitmModuleUrls(value).isNotEmpty,
    );
    if (input == null) {
      return;
    }
    final modules = ref.read(mitmModulesProvider).value ?? const [];
    final urls = mitmModuleUrls(
      input,
    ).where((url) => !modules.any((module) => module.url == url)).toSet();
    if (urls.isEmpty) {
      dialogs.showBanner(
        appLocalizations.existsTip(appLocalizations.mitmModule),
      );
      return;
    }
    for (final url in urls) {
      final added = await globalState.loadingRun(
        () => ref.read(mitmModulesActionProvider.notifier).addFromUrl(url),
        title: appLocalizations.importUrl,
        tag: LoadingTag.mitm,
      );
      await offerMitmScripts(ref, added);
    }
  }

  Future<void> _importFromFile(BuildContext context, WidgetRef ref) async {
    final appLocalizations = context.appLocalizations;
    final file = await globalState.safeRun(picker.pickerFile);
    if (file == null) {
      return;
    }
    final added = await globalState.loadingRun(
      () async => ref
          .read(mitmModulesActionProvider.notifier)
          .addFromFile(utf8.decode(await file.readBytes()), file.name),
      title: appLocalizations.importFile,
      tag: LoadingTag.mitm,
    );
    await offerMitmScripts(ref, added);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final state = ref.watch(mitmModulesProvider);
    final modules = state.value ?? const <MitmModule>[];
    return Scaffold(
      title: appLocalizations.mitmModules,
      canSort: modules.length > 1,
      isLoading: ref.watch(loadingProvider(LoadingTag.mitm)),
      actions: [
        PopupAnchor(
          targetBuilder: (open) => IconButton(
            tooltip: appLocalizations.add,
            onPressed: open,
            icon: const GlyphIcon(AppGlyphs.addCircle),
          ),
          popupBuilder: (_) => PopupMenu(
            items: [
              PopupMenuItem(
                glyph: AppGlyphs.compose,
                label: appLocalizations.mitmNewModule,
                onPressed: () => openMitmModuleEditor(context, ref),
              ),
              PopupMenuItem(
                glyph: AppGlyphs.cloudDownload,
                label: appLocalizations.importUrl,
                onPressed: () => _importFromUrl(context, ref),
              ),
              PopupMenuItem(
                glyph: AppGlyphs.importFile,
                label: appLocalizations.importFile,
                onPressed: () => _importFromFile(context, ref),
              ),
            ],
          ),
        ),
      ],
      body: NullStatusSwitcher(
        isLoading: state.isLoading && !state.hasValue,
        isEmpty: modules.isEmpty,
        nullStatus: NullStatus(
          illustration: NullStatusIllustration.scripts,
          label: appLocalizations.nullTip(appLocalizations.mitmModule),
        ),
        child: PrismReorderableListView(
          padding: const EdgeInsets.all(16).copyWith(
            top: context.contentTopPadding,
            bottom: 16 + context.bottomInset,
          ),
          itemCount: modules.length,
          itemBuilder: (_, index) => _MitmModuleRow(
            key: ValueKey(modules[index].id),
            module: modules[index],
            index: index,
            total: modules.length,
          ),
          proxyDecorator: (_, index, animation) => commonProxyDecorator(
            _MitmModuleRow(
              module: modules[index],
              index: index,
              total: modules.length,
            ),
            index,
            animation,
          ),
          onReorderItem: ref.read(mitmModulesProvider.notifier).order,
        ),
      ),
    );
  }
}

class _MitmModuleRow extends ConsumerWidget {
  const _MitmModuleRow({
    super.key,
    required this.module,
    required this.index,
    required this.total,
  });

  final MitmModule module;
  final int index;
  final int total;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(
        text: appLocalizations.deleteTip(appLocalizations.mitmModule),
      ),
      destructive: true,
      confirmText: appLocalizations.delete,
    );
    if (res != true) {
      return;
    }
    await ref.read(mitmModulesActionProvider.notifier).deleteModule(module);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final isUpdating = ref.watch(isUpdatingProvider(module.updatingKey));
    return SortableItem(
      index: index,
      child: ContextMenuRegion(
        menuItems: isUpdating
            ? null
            : [
                if (module.isRemote)
                  PopupMenuItem(
                    glyph: AppGlyphs.sync,
                    label: appLocalizations.update,
                    onPressed: () => _updateModule(ref, module),
                  )
                else
                  PopupMenuItem(
                    glyph: AppGlyphs.edit,
                    label: appLocalizations.edit,
                    onPressed: () =>
                        openMitmModuleEditor(context, ref, module: module),
                  ),
                PopupMenuItem(
                  danger: true,
                  glyph: AppGlyphs.delete,
                  label: appLocalizations.delete,
                  onPressed: () => _delete(context, ref),
                ),
              ],
        child: ItemPositionProvider(
          position: ItemPosition.get(index, total),
          child: DecorationListItem(
            contentPadding: const EdgeInsets.only(left: 16),
            title: Text(
              module.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              module.isRemote
                  ? appLocalizations.remote
                  : appLocalizations.local,
              style: context.listCaptionStyle,
            ),
            trailing: Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: isUpdating
                  ? const Padding(
                      padding: EdgeInsetsDirectional.only(end: 8),
                      child: ActivityIndicator(size: 24),
                    )
                  : Switch(
                      value: module.enabled,
                      onChanged: (value) => _setEnabled(ref, module, value),
                    ),
            ),
            onPressed: () =>
                BaseNavigator.push(context, MitmModuleView(id: module.id)),
          ),
        ),
      ),
    );
  }
}

class MitmModuleView extends ConsumerWidget {
  const MitmModuleView({super.key, required this.id});

  final int id;

  String _skipReason(AppLocalizations appLocalizations, MitmModuleSkip skip) {
    return switch (skip.reason) {
      MitmModuleSkipReason.section => appLocalizations.mitmSkipSection(
        skip.section,
      ),
      MitmModuleSkipReason.setting => appLocalizations.mitmSkipSetting,
      MitmModuleSkipReason.scriptType => appLocalizations.mitmSkipScriptType,
      MitmModuleSkipReason.event => appLocalizations.mitmSkipEvent,
      MitmModuleSkipReason.disabled => appLocalizations.mitmSkipDisabled,
      MitmModuleSkipReason.rule => appLocalizations.mitmSkipRule,
      MitmModuleSkipReason.policy => appLocalizations.mitmSkipPolicy,
      MitmModuleSkipReason.jq => appLocalizations.mitmSkipJq,
      MitmModuleSkipReason.jsonBody => appLocalizations.mitmSkipJsonBody,
      MitmModuleSkipReason.rawHeader => appLocalizations.mitmSkipRawHeader,
      MitmModuleSkipReason.conditional => appLocalizations.mitmSkipConditional,
      MitmModuleSkipReason.relativeData =>
        appLocalizations.mitmSkipRelativeData,
      MitmModuleSkipReason.notDownloaded =>
        appLocalizations.mitmSkipNotDownloaded,
      MitmModuleSkipReason.unreadable => appLocalizations.mitmSkipUnreadable,
    };
  }

  /// A module written for Apple systems still applies, so this only warns.
  String? _systemTip(AppLocalizations appLocalizations, String? target) {
    final current = switch (true) {
      _ when system.isMacOS => 'mac',
      _ when system.isAndroid => 'android',
      _ when system.isWindows => 'windows',
      _ => 'linux',
    };
    if (target == null || target.toLowerCase().contains(current)) {
      return null;
    }
    return appLocalizations.mitmModuleSystemTip(target);
  }

  Widget _linesItem(
    String title,
    List<String> lines, {
    Map<String, String> issues = const {},
    List<PopupMenuItem> Function(String line)? menuItemsOf,
  }) {
    return Builder(
      builder: (context) {
        final appLocalizations = context.appLocalizations;
        final invalid = lines.where(issues.containsKey).length;
        return ListItem.open(
          title: Text(title),
          subtitle: Text(
            invalid == 0
                ? appLocalizations.itemsCount(lines.length)
                : appLocalizations.invalidOfCount(invalid, lines.length),
          ),
          widget: _MitmModuleLinesView(
            title: title,
            lines: [for (final line in lines) (line, issues[line])],
            menuItemsOf: menuItemsOf,
          ),
        );
      },
    );
  }

  List<Widget> _sourceItems(
    BuildContext context,
    WidgetRef ref,
    MitmModule module,
  ) {
    final appLocalizations = context.appLocalizations;
    final url = module.url;
    return [
      ListItem(
        title: Text(appLocalizations.source),
        subtitle: Text(url ?? appLocalizations.local),
      ),
      ListItem(
        title: Text(appLocalizations.lastUpdated),
        trailing: LastUpdateTimeText(
          lastUpdateDate: module.lastUpdateTime,
          style: context.listCaptionStyle,
        ),
      ),
      if (url == null)
        ListItem(
          title: Text(appLocalizations.edit),
          onTap: () => openMitmModuleEditor(context, ref, module: module),
        ),
      if (url != null)
        Consumer(
          builder: (_, ref, _) {
            final isUpdating = ref.watch(
              isUpdatingProvider(module.updatingKey),
            );
            return ListItem(
              title: Text(appLocalizations.update),
              trailing: isUpdating ? const ActivityIndicator(size: 24) : null,
              onTap: isUpdating ? null : () => _updateModule(ref, module),
            );
          },
        ),
    ];
  }

  Future<void> _attach(WidgetRef ref, MitmModule module) async {
    final file = await globalState.safeRun(picker.pickerFile);
    if (file == null) {
      return;
    }
    await globalState.loadingRun(
      () async => ref
          .read(mitmModulesActionProvider.notifier)
          .attach(module, file.name, await file.readBytes()),
      title: currentAppLocalizations.mitmAddLocalFile,
      tag: LoadingTag.mitm,
    );
  }

  Future<void> _detach(WidgetRef ref, MitmModule module, String name) async {
    final appLocalizations = currentAppLocalizations;
    final res = await dialogs.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(text: appLocalizations.deleteTip(name)),
      destructive: true,
      confirmText: appLocalizations.delete,
    );
    if (res == true) {
      await ref.read(mitmModulesActionProvider.notifier).detach(module, name);
    }
  }

  List<Widget> _attachmentItems(
    BuildContext context,
    WidgetRef ref,
    MitmModule module,
  ) {
    final appLocalizations = context.appLocalizations;
    return [
      for (final name in mitmAttachments(module).keys)
        ContextMenuRegion(
          menuItems: [
            PopupMenuItem(
              danger: true,
              glyph: AppGlyphs.delete,
              label: appLocalizations.delete,
              onPressed: () => _detach(ref, module, name),
            ),
          ],
          child: ListItem(title: Text(name)),
        ),
      ListItem(
        title: Text(appLocalizations.mitmAddLocalFile),
        onTap: () => _attach(ref, module),
      ),
    ];
  }

  Widget _argumentItem(
    WidgetRef ref,
    MitmModule module,
    MitmModuleArgument argument,
  ) {
    final value = module.arguments[argument.name] ?? argument.defaultValue;
    Future<void> save(String next) async {
      final turnedOff = await ref
          .read(mitmModulesActionProvider.notifier)
          .setArguments(module, {...module.arguments, argument.name: next});
      await offerMitmScripts(ref, turnedOff);
    }

    return switch (argument.type) {
      MitmModuleArgumentType.toggle => ListItem.toggle(
        title: Text(argument.title),
        value: value == 'true',
        onChanged: (next) => save(next.toString()),
      ),
      MitmModuleArgumentType.select => ListItem.options(
        title: Text(argument.title),
        options: argument.options.contains(value)
            ? argument.options
            : [value, ...argument.options],
        value: value,
        textBuilder: (option) => option,
        onChanged: save,
      ),
      MitmModuleArgumentType.input => ListItem.input(
        title: Text(argument.title),
        subtitle: value.isEmpty ? null : Text(value),
        dialogTitle: argument.title,
        value: value,
        onChanged: (next) {
          if (next != null) {
            save(next);
          }
        },
      ),
    };
  }

  String? _aboutFooter(AppLocalizations appLocalizations, MitmModule module) {
    final paragraphs = [
      if (module.description.isNotEmpty) module.description,
      ?_systemTip(appLocalizations, module.system),
    ];
    return paragraphs.isEmpty ? null : paragraphs.join('\n\n');
  }

  String? _argumentsFooter(MitmModuleContent content) {
    final lines = [
      ?content.argumentsDescription,
      for (final argument in content.arguments)
        if (argument.description case final description?)
          '${argument.title}: $description',
    ];
    return lines.isEmpty ? null : lines.join('\n');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final module = _moduleOf(ref, id);
    final details = ref.watch(mitmModuleDetailsProvider(id));
    final content = details.value?.content;
    final issues = details.value?.issues ?? const {};
    return Scaffold(
      title: module?.name ?? appLocalizations.mitmModule,
      body: NullStatusSwitcher(
        isLoading: module == null || details.isLoading && !details.hasValue,
        child: module == null
            ? const SizedBox()
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
                  top: context.sectionsTopPadding,
                  bottom: 16 + context.bottomInset,
                ),
                children: [
                  generateSection(
                    items: [
                      ListItem.toggle(
                        title: Text(appLocalizations.enabled),
                        value: module.enabled,
                        onChanged: (value) => _setEnabled(ref, module, value),
                      ),
                    ],
                    footer: _aboutFooter(appLocalizations, module),
                  ),
                  generateSection(
                    title: appLocalizations.source,
                    items: _sourceItems(context, ref, module),
                  ),
                  if (!module.isRemote)
                    generateSection(
                      title: appLocalizations.mitmAttachments,
                      items: _attachmentItems(context, ref, module),
                      footer: appLocalizations.mitmAttachmentsDesc,
                    ),
                  if (content != null && content.arguments.isNotEmpty)
                    generateSection(
                      title: appLocalizations.arguments,
                      items: [
                        for (final argument in content.arguments)
                          _argumentItem(ref, module, argument),
                      ],
                      footer: _argumentsFooter(content),
                    ),
                  if (content != null)
                    generateSection(
                      title: appLocalizations.rules,
                      items: [
                        for (final list in MitmList.values)
                          if (content.mitm.linesOf(list) case final lines
                              when lines.isNotEmpty)
                            _linesItem(
                              list.label,
                              lines,
                              issues: issues[list] ?? const {},
                              menuItemsOf:
                                  list == MitmList.script && module.enabled
                                  ? (line) => [?mitmRunScriptItem(ref, line)]
                                  : null,
                            ),
                        if (content.rules.isNotEmpty)
                          _linesItem(
                            appLocalizations.mitmRoutingRules,
                            content.rules,
                          ),
                        if (content.skipped.isNotEmpty)
                          ListItem.open(
                            title: Text(appLocalizations.mitmIgnoredLines),
                            subtitle: Text(
                              appLocalizations.itemsCount(
                                content.skipped.length,
                              ),
                            ),
                            widget: _MitmModuleLinesView(
                              title: appLocalizations.mitmIgnoredLines,
                              notes: true,
                              lines: [
                                for (final skip in content.skipped)
                                  (
                                    skip.line,
                                    _skipReason(appLocalizations, skip),
                                  ),
                              ],
                            ),
                          ),
                      ],
                      footer: appLocalizations.mitmModuleRulesDesc,
                    ),
                ],
              ),
      ),
    );
  }
}

class _MitmModuleLinesView extends StatelessWidget {
  const _MitmModuleLinesView({
    required this.title,
    required this.lines,
    this.notes = false,
    this.menuItemsOf,
  });

  final String title;

  /// Each line with why the Core skips it, or with [notes] why the module's
  /// reader left it out.
  final List<(String, String?)> lines;
  final bool notes;
  final List<PopupMenuItem> Function(String line)? menuItemsOf;

  @override
  Widget build(BuildContext context) {
    final noteStyle = notes
        ? context.listCaptionStyle
        : TextStyle(color: context.colorScheme.error);
    return Scaffold(
      title: title,
      body: PrismListView(
        padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
          top: context.contentTopPadding,
          bottom: 16 + context.bottomInset,
        ),
        itemCount: lines.length,
        itemBuilder: (_, index) {
          final (line, issue) = lines[index];
          return ItemPositionProvider(
            position: ItemPosition.get(index, lines.length),
            child: MitmTaskRunning(
              line: line,
              builder: (running) => ContextMenuRegion(
                menuItems: menuItemsOf?.call(line),
                child: DecorationListItem(
                  title: Text(line),
                  subtitle: issue == null
                      ? null
                      : Text(issue, style: noteStyle),
                  invalid: !notes && issue != null,
                  trailing: running ? const ActivityIndicator(size: 24) : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
