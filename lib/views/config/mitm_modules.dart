import 'dart:async';

import 'package:fl_clash/core/core.dart';

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/mitm_module_file.dart';
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
import 'package:path/path.dart' as p;

MitmModule? _moduleOf(WidgetRef ref, int id) => ref.watch(
  mitmModulesProvider.select(
    (state) => state.value?.firstWhereOrNull((item) => item.id == id),
  ),
);

Future<void> _setEnabled(WidgetRef ref, MitmModule module, bool enabled) async {
  if (enabled) {
    await answerMitmModule(ref, module);
  } else {
    await ref.read(mitmModulesActionProvider.notifier).turnOff(module.id);
  }
}

/// The name the Core runs a cron, event or generic script line by; null for
/// any other line.
String? _taskName(MitmLineView? view) => switch (view) {
  MitmScriptView(:final name, kind: 'cron' || 'event' || 'generic') => name,
  _ => null,
};

/// Runs a cron, event or generic script line now; any other line, any while
/// decryption is off, and a task still running have none.
PopupMenuItem? mitmRunScriptItem(WidgetRef ref, MitmLineView? view) {
  final name = _taskName(view);
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
  const MitmTaskRunning({super.key, required this.view, required this.builder});

  final MitmLineView? view;
  final Widget Function(bool running) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = _taskName(view);
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
      () => ref.read(coreHandlerProvider).api.runMitmModule(name),
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
  final updated = await globalState.safeRun(
    () => ref.read(mitmModulesActionProvider.notifier).updateModule(module),
    title: module.name,
    silence: false,
  );
  await offerMitmModule(ref, updated);
}

Future<void> _editModuleUrl(WidgetRef ref, MitmModule module) async {
  final appLocalizations = currentAppLocalizations;
  final url = await dialogs.showUrlInput(
    title: appLocalizations.url,
    value: module.url ?? '',
  );
  if (url == null || url == module.url) {
    return;
  }
  final modules = ref.read(mitmModulesProvider).value ?? const [];
  if (modules.any((other) => other.id != module.id && other.url == url)) {
    dialogs.showBanner(appLocalizations.existsTip(appLocalizations.mitmModule));
    return;
  }
  final updated = await globalState.safeRun(
    () => ref.read(mitmModulesActionProvider.notifier).changeUrl(module, url),
    title: module.name,
    silence: false,
  );
  await offerMitmModule(ref, updated);
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
      leading: const GlyphIcon(AppGlyphs.puzzle),
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
      await offerMitmModule(ref, added);
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
    await offerMitmModule(ref, added);
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
          padding: context.listInsets
              .page(top: 16, bottom: 16)
              .copyWith(
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
                if (module.isRemote) ...[
                  PopupMenuItem(
                    glyph: AppGlyphs.sync,
                    label: appLocalizations.update,
                    onPressed: () => _updateModule(ref, module),
                  ),
                  PopupMenuItem(
                    glyph: AppGlyphs.link,
                    label: appLocalizations.url,
                    onPressed: () => _editModuleUrl(ref, module),
                  ),
                ] else
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
            contentPadding: EdgeInsetsDirectional.only(
              start: context.listInsets.leading,
              end: isUpdating
                  ? context.listInsets.trailing
                  : context.listInsets.trailing - Switch.edgeInset,
            ),
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
            trailing: isUpdating
                ? const ActivityIndicator(size: 24)
                : Switch(
                    value: module.enabled,
                    onChanged: (value) => _setEnabled(ref, module, value),
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

  String _skipReason(
    AppLocalizations appLocalizations,
    MitmModuleIgnoredLine skip,
  ) {
    final reason = switch (skip.reason) {
      'section' when skip.detail != null => appLocalizations.mitmSkipSection(
        skip.detail!,
      ),
      'section' => appLocalizations.mitmSkipNoSection,
      'appOnly' => appLocalizations.mitmSkipAppOnly,
      'proxies' => appLocalizations.mitmSkipProxies,
      'setting' => appLocalizations.mitmSkipSetting,
      'managedCa' => appLocalizations.mitmSkipManagedCa,
      'requirement' => appLocalizations.mitmSkipRequirement,
      'requirementUnreadable' => appLocalizations.mitmSkipRequirementUnreadable,
      'scriptType' => appLocalizations.mitmSkipScriptType,
      'event' => appLocalizations.mitmSkipEvent,
      'disabled' => appLocalizations.mitmSkipDisabled,
      'finalRule' => appLocalizations.mitmSkipFinalRule,
      'deviceRule' => appLocalizations.mitmSkipDeviceRule,
      'ruleType' => appLocalizations.mitmSkipRule,
      'policy' => appLocalizations.mitmSkipPolicy,
      'nestedRuleSet' => appLocalizations.mitmSkipNestedRuleSet,
      'reflect' => appLocalizations.mitmSkipReflect,
      'skipVerifyAll' => appLocalizations.mitmSkipSkipVerifyAll,
      'noAttachment' => appLocalizations.mitmSkipRelativeData,
      'condition' => appLocalizations.mitmSkipCondition,
      'runtimeValue' => appLocalizations.mitmSkipRuntimeValue,
      _ => appLocalizations.mitmSkipUnreadable,
    };
    return switch (skip.detail) {
      final detail? when skip.reason != 'section' => '$reason\n$detail',
      _ => reason,
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
    List<_ShownLine> lines, {
    String? note,
    bool rules = false,
    Map<String, Map<String, Object?>> ruleSets = const {},
    List<PopupMenuItem> Function(_ShownLine line)? menuItemsOf,
  }) {
    return Builder(
      builder: (context) {
        final appLocalizations = context.appLocalizations;
        final invalid = lines.where((line) => line.issue != null).length;
        final count = invalid == 0
            ? appLocalizations.itemsCount(lines.length)
            : appLocalizations.invalidOfCount(invalid, lines.length);
        return ListItem.open(
          title: Text(title),
          subtitle: Text([count, ?note].join('\n')),
          widget: _MitmModuleLinesView(
            title: title,
            lines: lines,
            rules: rules,
            ruleSets: ruleSets,
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
        onTap: url == null ? null : () => _editModuleUrl(ref, module),
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
    MitmModuleArgumentView argument,
  ) {
    final title = argument.label ?? argument.name;
    final value = module.arguments[argument.name] ?? argument.defaultValue;
    Future<void> save(String next) async {
      final changed = await globalState.safeRun(
        () => ref.read(mitmModulesActionProvider.notifier).setArguments(
          module,
          {...module.arguments, argument.name: next},
        ),
        title: module.name,
        silence: false,
      );
      await offerMitmModule(ref, changed);
    }

    return switch (argument.type) {
      MitmArgumentType.switcher => ListItem.toggle(
        title: Text(title),
        value: value == 'true',
        onChanged: (next) => save(next.toString()),
      ),
      MitmArgumentType.select => ListItem.options(
        title: Text(title),
        options: argument.options.contains(value)
            ? argument.options
            : [value, ...argument.options],
        value: value,
        textBuilder: (option) => option,
        onChanged: save,
      ),
      MitmArgumentType.text => ListItem.input(
        title: Text(title),
        subtitle: value.isEmpty ? null : Text(value),
        dialogTitle: title,
        value: value,
        onChanged: (next) {
          if (next != null) {
            save(next);
          }
        },
      ),
    };
  }

  String? _aboutFooter(
    AppLocalizations appLocalizations,
    MitmModule module,
    MitmModuleDetails? content, {
    Object? readError,
  }) {
    final paragraphs = [
      if (module.description.isNotEmpty) module.description,
      if (readError != null)
        userFacingErrorMessage(readError, appLocalizations),
      ?_systemTip(appLocalizations, module.system),
      if (content?.read.meta.requirement case final requirement?
          when content?.read.off != null)
        appLocalizations.mitmModuleRequirementTip(requirement),
    ];
    return paragraphs.isEmpty ? null : paragraphs.join('\n\n');
  }

  String _resourceState(
    AppLocalizations appLocalizations,
    MitmModuleResourceStatus resource,
  ) => switch ((resource.state, resource.error)) {
    (MitmResourceState.ok, _) => appLocalizations.mitmResourceOk,
    (MitmResourceState.fetching, _) => appLocalizations.mitmResourceFetching,
    (MitmResourceState.missing, _) => appLocalizations.mitmResourceMissing,
    (_, MitmFetchFailure(reason: 'http', :final status?)) =>
      appLocalizations.mitmFetchHttp(status),
    (_, MitmFetchFailure(reason: 'dns')) => appLocalizations.mitmFetchDns,
    (_, MitmFetchFailure(reason: 'tls')) => appLocalizations.mitmFetchTls,
    (_, MitmFetchFailure(reason: 'timeout')) =>
      appLocalizations.mitmFetchTimeout,
    (_, MitmFetchFailure(reason: 'connection')) =>
      appLocalizations.mitmFetchConnection,
    _ => appLocalizations.mitmFetchOther,
  };

  List<Widget> _resourceItems(
    BuildContext context,
    WidgetRef ref,
    MitmModule module,
    MitmModuleStatus status,
  ) {
    final appLocalizations = context.appLocalizations;
    return [
      for (final resource in status.resources)
        ListItem(
          title: Text(
            resource.url,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            _resourceState(appLocalizations, resource),
            style: resource.state == MitmResourceState.failed
                ? TextStyle(color: context.colorScheme.error)
                : null,
          ),
          trailing: resource.state == MitmResourceState.fetching
              ? const ActivityIndicator(size: 24)
              : null,
        ),
      ListItem(
        title: Text(appLocalizations.mitmResourcesFetch),
        onTap: () => globalState.safeRun(
          () => ref
              .read(mitmModulesActionProvider.notifier)
              .fetchResources(module),
          title: module.name,
          silence: false,
        ),
      ),
    ];
  }

  Widget _networkItem(BuildContext context, MitmNetworkChangeState state) {
    final appLocalizations = context.appLocalizations;
    return ListItem(
      title: Text(mitmNetworkChangeTitle(appLocalizations, state.change)),
      subtitle: Text(
        [
          mitmNetworkChangeValue(appLocalizations, state.change),
          if (state.replacedBy case final module?)
            appLocalizations.mitmChangeReplacedBy(module)
          else if (state.overridesYours)
            appLocalizations.mitmChangeOverridesYours,
        ].join('\n'),
      ),
    );
  }

  String? _argumentsFooter(MitmModuleDetails content) {
    final lines = [
      ?content.read.meta.argumentsDesc,
      for (final argument in content.read.arguments)
        if (argument.desc case final description?)
          '${argument.label ?? argument.name}: $description',
    ];
    return lines.isEmpty ? null : lines.join('\n');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final module = _moduleOf(ref, id);
    final details = ref.watch(mitmModuleContentProvider(id));
    final content = details.value;
    final status = ref.watch(mitmModuleStatusProvider).value?['$id'];
    final refused = {
      for (final rule in status?.refusedRules ?? const <MitmRefusedRule>[])
        rule.line: rule.detail,
    };
    final networkChanges =
        ref.watch(mitmModuleNetworkChangesProvider(id)).value ?? const [];
    return Scaffold(
      title: module?.name ?? appLocalizations.mitmModule,
      body: NullStatusSwitcher(
        isLoading: module == null || details.isLoading && !details.hasValue,
        child: module == null
            ? const SizedBox()
            : ListView(
                padding: context.listInsets.page().copyWith(
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
                    footer: _aboutFooter(
                      appLocalizations,
                      module,
                      content,
                      readError: details.hasValue ? null : details.error,
                    ),
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
                      last: content == null && networkChanges.isEmpty,
                    ),
                  if (content != null && content.read.arguments.isNotEmpty)
                    generateSection(
                      title: appLocalizations.arguments,
                      items: [
                        for (final argument in content.read.arguments)
                          _argumentItem(ref, module, argument),
                      ],
                      footer: _argumentsFooter(content),
                    ),
                  if (status != null && status.resources.isNotEmpty)
                    generateSection(
                      title: appLocalizations.mitmResources,
                      items: _resourceItems(context, ref, module, status),
                    ),
                  if (networkChanges.isNotEmpty)
                    generateSection(
                      title: appLocalizations.mitmNetworkChanges,
                      items: [
                        for (final state in networkChanges)
                          _networkItem(context, state),
                      ],
                      footer: appLocalizations.mitmNetworkRisk,
                      last: content == null,
                    ),
                  if (content != null)
                    generateSection(
                      title: appLocalizations.rules,
                      items: [
                        for (final list in MitmList.values)
                          if (content.lists[list] case final lines?
                              when lines.isNotEmpty)
                            _linesItem(
                              list.label,
                              [
                                for (final line in lines)
                                  (
                                    text: line.text,
                                    issue: line.issue,
                                    view: line.view,
                                  ),
                              ],
                              note: list == MitmList.clientSourceAddress
                                  ? appLocalizations.mitmClientSourceTunTip
                                  : null,
                              menuItemsOf:
                                  list == MitmList.script && module.enabled
                                  ? (line) => [
                                      ?mitmRunScriptItem(ref, line.view),
                                    ]
                                  : null,
                            ),
                        if (content.read.rules.isNotEmpty)
                          _linesItem(
                            appLocalizations.mitmRoutingRules,
                            [
                              for (final rule in content.read.rules)
                                _ruleLine(
                                  rule,
                                  refused[rule.line],
                                  appLocalizations,
                                ),
                            ],
                            note: switch (content.read.rules
                                .where((rule) => rule.extendedMatching)
                                .length) {
                              0 => null,
                              final count =>
                                appLocalizations.mitmExtendedMatchingNote(
                                  count,
                                ),
                            },
                            rules: true,
                            ruleSets: {
                              for (final set in content.read.ruleSets)
                                set.name: {'url': ?set.url, 'path': ?set.file},
                            },
                          ),
                        if (content.read.ignored.isNotEmpty)
                          ListItem.open(
                            title: Text(appLocalizations.mitmIgnoredLines),
                            subtitle: Text(
                              appLocalizations.itemsCount(
                                content.read.ignored.length,
                              ),
                            ),
                            widget: _MitmModuleLinesView(
                              title: appLocalizations.mitmIgnoredLines,
                              notes: true,
                              lines: [
                                for (final skip in content.read.ignored)
                                  (
                                    text: skip.text,
                                    issue: _skipReason(appLocalizations, skip),
                                    view: null,
                                  ),
                              ],
                            ),
                          ),
                      ],
                      footer: [
                        appLocalizations.mitmModuleRulesDesc,
                        if (content.read.rules.any(_isRequestRule))
                          appLocalizations.mitmRequestRulesDesc,
                      ].join(' '),
                      last: true,
                    ),
                ],
              ),
      ),
    );
  }
}

typedef _ShownLine = ({String text, String? issue, MitmLineView? view});

_ShownLine _ruleLine(
  MitmModuleRule rule,
  String? refused,
  AppLocalizations appLocalizations,
) {
  final text = _ruleText(rule);
  return (
    text: text,
    issue:
        refused ??
        (_moduleRule(text) == null && !_isScriptRule(text)
            ? appLocalizations.mitmSkipRule
            : null),
    view: null,
  );
}

String _ruleText(MitmModuleRule rule) => [
  rule.rule,
  rule.policy.name,
  if (rule.noResolve) 'no-resolve',
  if (rule.requiresResolve) 'requires-resolve',
].join(',');

/// A `SCRIPT` rule, which the Core runs but the rule editor has no type for.
bool _isScriptRule(String line) => line.startsWith('SCRIPT,');

/// A rule decided by the request a session decrypts.
bool _isRequestRule(MitmModuleRule rule) =>
    RegExp(r'(^|\()\s*(URL-REGEX|USER-AGENT),').hasMatch(rule.rule);

/// A routing rule as the module's reader wrote it, or null for a line whose
/// type, payload or target [Rule.parse] would have to guess.
Rule? _moduleRule(String line) {
  final type = line.split(',').first.trim().toUpperCase();
  if (!RuleAction.values.any((action) => action.value == type)) {
    return null;
  }
  final rule = Rule.parse(line, id: 0);
  if (rule.realTarget == null ||
      rule.ruleAction != RuleAction.MATCH && rule.realContent == null) {
    return null;
  }
  return rule;
}

class _MitmModuleLinesView extends StatelessWidget {
  const _MitmModuleLinesView({
    required this.title,
    required this.lines,
    this.notes = false,
    this.rules = false,
    this.ruleSets = const {},
    this.menuItemsOf,
  });

  final String title;

  /// Each line with why the Core skips it, or with [notes] why the module's
  /// reader left it out, and how the Core reads one it applies.
  final List<_ShownLine> lines;
  final bool notes;
  final bool rules;
  final Map<String, Map<String, Object?>> ruleSets;
  final List<PopupMenuItem> Function(_ShownLine line)? menuItemsOf;

  Color? _issueColor(BuildContext context) =>
      notes ? null : context.colorScheme.error;

  void _showLine(BuildContext context, String line, String? issue) {
    dialogs.showAlert(
      title: title,
      message: TextSpan(
        children: [
          TextSpan(text: line, style: const TextStyle().toJetBrainsMono),
          if (issue != null)
            TextSpan(
              text: '\n\n$issue',
              style: TextStyle(color: _issueColor(context)),
            ),
        ],
      ),
    );
  }

  /// A rule set the module's reader named after a hash shows where it reads
  /// from instead.
  Rule _shownRule(Rule rule) {
    if (rule.ruleAction != RuleAction.RULE_SET) {
      return rule;
    }
    final source = switch (ruleSets[rule.ruleProvider]) {
      {'url': final String url} => url,
      {'path': final String path} => p.basename(path),
      _ => null,
    };
    return source == null ? rule : rule.copyWith(ruleProvider: source);
  }

  Widget _ruleRow(BuildContext context, String line, String? issue) {
    if (_moduleRule(line) case final rule?) {
      return RuleItem(
        rule: _shownRule(rule),
        invalidMessageOf: (_) => issue,
        onEdit: (_) => _showLine(context, line, issue),
      );
    }
    final message =
        issue ??
        (_isScriptRule(line) ? null : context.appLocalizations.mitmSkipRule);
    return DecorationListItem(
      minVerticalPadding: 0,
      invalid: message != null,
      title: Text(
        line,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: DefaultTextStyle.of(context).style.toJetBrainsMono,
      ),
      subtitle: switch (message) {
        final message? => Text(
          message,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: context.colorScheme.error),
        ),
        null => null,
      },
      onPressed: () => _showLine(context, line, message),
    );
  }

  Widget _lineRow(BuildContext context, _ShownLine line) {
    return MitmTaskRunning(
      view: line.view,
      builder: (running) => ContextMenuRegion(
        menuItems: menuItemsOf?.call(line),
        child: switch (line.view) {
          final view? => _viewRow(
            context,
            line.text,
            view,
            line.issue,
            running,
          ),
          null => _rawRow(context, line.text, line.issue, running),
        },
      ),
    );
  }

  Widget _viewRow(
    BuildContext context,
    String line,
    MitmLineView view,
    String? issue,
    bool running,
  ) {
    final parts = _MitmLineParts.of(context, view);
    final codeStyle = AppTextStyle.subheadline.of(context).toJetBrainsMono;
    return DecorationListItem(
      title: Text(
        parts.primary,
        maxLines: _primaryLines,
        overflow: TextOverflow.ellipsis,
        style: parts.code ? codeStyle : null,
      ),
      subtitle: parts.details.isEmpty && issue == null
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final detail in parts.details)
                  Text(
                    detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.listCaptionStyle.toJetBrainsMono,
                  ),
                if (issue != null)
                  Text(issue, style: TextStyle(color: _issueColor(context))),
              ],
            ),
      trailing: running
          ? const ActivityIndicator(size: 24)
          : parts.tag == null
          ? null
          : Text(parts.tag!, style: codeStyle.copyWith(color: parts.tagColor)),
      onPressed: () => _showLine(context, line, issue),
    );
  }

  Widget _rawRow(
    BuildContext context,
    String line,
    String? issue,
    bool running,
  ) {
    return DecorationListItem(
      title: Text(
        line,
        maxLines: _shownLines,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyle.subheadline.of(context).toJetBrainsMono,
      ),
      subtitle: issue == null
          ? null
          : Text(
              issue,
              style: notes
                  ? context.listCaptionStyle
                  : TextStyle(color: _issueColor(context)),
            ),
      invalid: !notes && issue != null,
      trailing: running ? const ActivityIndicator(size: 24) : null,
      onPressed: () => _showLine(context, line, issue),
    );
  }

  static const _shownLines = 3;
  static const _primaryLines = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      title: title,
      body: PrismListView(
        padding: context.listInsets.page().copyWith(
          top: context.contentTopPadding,
          bottom: 16 + context.bottomInset,
        ),
        itemCount: lines.length,
        itemExtent: rules ? ruleItemHeight : null,
        itemBuilder: (context, index) {
          final line = lines[index];
          return ItemPositionProvider(
            position: ItemPosition.get(index, lines.length),
            child: rules
                ? ContextMenuRegion(
                    menuItems: menuItemsOf?.call(line),
                    child: _ruleRow(context, line.text, line.issue),
                  )
                : _lineRow(context, line),
          );
        },
      ),
    );
  }
}

const _requiresBodyKey = 'requires-body';
const _timeoutKey = 'timeout';
const _contentTypeHeader = 'Content-Type';

String _seconds(int ms) => ms % 1000 == 0 ? '${ms ~/ 1000}s' : '${ms / 1000}s';

/// A line the Core reads, laid out as a rule row is: what it matches on top,
/// what it does below, and the kind of action at the trailing edge.
class _MitmLineParts {
  const _MitmLineParts({
    required this.primary,
    this.code = true,
    this.details = const [],
    this.tag,
    this.tagColor,
  });

  final String primary;
  final bool code;
  final List<String> details;
  final String? tag;
  final Color? tagColor;

  factory _MitmLineParts.of(BuildContext context, MitmLineView view) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    String phase(String phase) => phase == 'response'
        ? appLocalizations.response
        : appLocalizations.request;
    List<String> heads(String? request, String? response) => [
      if (request != null) 'request-head $request',
      if (response != null) 'response-head $response',
    ];
    return switch (view) {
      MitmUrlRewriteView(
        :final pattern,
        :final action,
        :final replacement,
        :final requestHead,
      ) =>
        _MitmLineParts(
          primary: pattern,
          details: [
            if (replacement != null) '→ $replacement',
            ...heads(requestHead, null),
          ],
          tag: action,
          tagColor: action.startsWith('reject')
              ? colorScheme.warning
              : colorScheme.tertiary,
        ),
      final MitmHeaderRewriteView view => _MitmLineParts(
        primary: view.pattern,
        details: [
          [
            view.action,
            if (view.name case final name?)
              view.value != null || view.regex != null ? '$name:' : name,
            ?view.value,
            if (view.regex case final regex?) '$regex → ${view.replacement}',
          ].join(' '),
          ...heads(view.requestHead, view.responseHead),
        ],
        tag: phase(view.phase),
      ),
      final MitmBodyRewriteView view => _MitmLineParts(
        primary: view.pattern,
        details: [
          if (view.jq case final jq?)
            'jq $jq'
          else if (view.replacements case [final first, ...final rest])
            [
              '${first.regex} → ${first.replacement}',
              if (rest.isNotEmpty) '+${rest.length}',
            ].join('  '),
          ...heads(view.requestHead, view.responseHead),
        ],
        tag: phase(view.phase),
      ),
      final MitmMapLocalView view => _MitmLineParts(
        primary: view.pattern,
        details: [
          switch (view.dataType) {
            'text' || 'file' when view.data.isNotEmpty => view.data,
            final dataType => dataType,
          },
          if (view.contentType.isNotEmpty)
            '$_contentTypeHeader: ${view.contentType}',
          if (view.headers case [final first, ...final rest])
            [
              '${first.name}: ${first.value}',
              if (rest.isNotEmpty) '+${rest.length}',
            ].join('  '),
          ...heads(view.requestHead, null),
        ],
        tag: view.status?.toString() ?? view.dataType,
      ),
      final MitmScriptView view => _MitmLineParts(
        primary: view.name,
        code: false,
        details: [
          ?(view.pattern ?? view.cronexp ?? view.event),
          if (view.path.isNotEmpty) view.path,
          if ([
                if (view.requiresBody) _requiresBodyKey,
                if (view.timeoutMs case final ms?)
                  '$_timeoutKey ${_seconds(ms)}',
              ]
              case final flags when flags.isNotEmpty)
            flags.join('  '),
        ],
        tag: switch (view.kind) {
          'httpRequest' => appLocalizations.request,
          'httpResponse' => appLocalizations.response,
          'cron' => appLocalizations.mitmScriptCron,
          'event' => appLocalizations.mitmScriptEvent,
          'rule' => appLocalizations.rule,
          'dns' => appLocalizations.mitmScriptDns,
          _ => appLocalizations.mitmScriptGeneric,
        },
      ),
      MitmHostsView(:final entries) =>
        _MitmLineParts._entries(appLocalizations, colorScheme, [
          for (final entry in entries)
            (
              switch (entry.port) {
                final port? when entry.host.contains(':') =>
                  '[${entry.host}]:$port',
                final port? => '${entry.host}:$port',
                null => entry.host,
              },
              entry.exclude,
            ),
        ]),
      MitmSourcesView(:final entries) => _MitmLineParts._entries(
        appLocalizations,
        colorScheme,
        [for (final entry in entries) (entry.network, entry.exclude)],
      ),
    };
  }

  /// One entry carries its exclusion as the tag; several keep the `-` they
  /// are written with.
  factory _MitmLineParts._entries(
    AppLocalizations appLocalizations,
    ColorScheme colorScheme,
    List<(String, bool)> entries,
  ) {
    if (entries case [(final entry, final exclude)]) {
      return _MitmLineParts(
        primary: entry,
        tag: exclude ? appLocalizations.mitmExcluded : null,
        tagColor: colorScheme.warning,
      );
    }
    return _MitmLineParts(
      primary: [
        for (final (entry, exclude) in entries) exclude ? '-$entry' : entry,
      ].join(', '),
    );
  }
}
