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
  final updated = await globalState.safeRun(
    () => ref.read(mitmModulesActionProvider.notifier).updateModule(module),
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
      MitmModuleSkipReason.httpRulePolicy =>
        appLocalizations.mitmSkipHttpRulePolicy,
      MitmModuleSkipReason.finalRule => appLocalizations.mitmSkipFinalRule,
      MitmModuleSkipReason.deviceRule => appLocalizations.mitmSkipDeviceRule,
      MitmModuleSkipReason.requirement => appLocalizations.mitmSkipRequirement,
      MitmModuleSkipReason.managedCa => appLocalizations.mitmSkipManagedCa,
      MitmModuleSkipReason.proxies => appLocalizations.mitmSkipProxies,
      MitmModuleSkipReason.appOnly => appLocalizations.mitmSkipAppOnly,
      MitmModuleSkipReason.reflect => appLocalizations.mitmSkipReflect,
      MitmModuleSkipReason.conditional => appLocalizations.mitmSkipConditional,
      MitmModuleSkipReason.skipVerifyAll =>
        appLocalizations.mitmSkipSkipVerifyAll,
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
    Map<String, MitmLineView> views = const {},
    String? note,
    bool rules = false,
    Map<String, Map<String, Object?>> ruleSets = const {},
    List<PopupMenuItem> Function(String line)? menuItemsOf,
  }) {
    return Builder(
      builder: (context) {
        final appLocalizations = context.appLocalizations;
        final invalid = lines.where(issues.containsKey).length;
        final count = invalid == 0
            ? appLocalizations.itemsCount(lines.length)
            : appLocalizations.invalidOfCount(invalid, lines.length);
        return ListItem.open(
          title: Text(title),
          subtitle: Text([count, ?note].join('\n')),
          builder: (_) => _MitmModuleLinesView(
            title: title,
            lines: [for (final line in lines) (line, issues[line])],
            views: views,
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

  String? _aboutFooter(
    AppLocalizations appLocalizations,
    MitmModule module,
    MitmModuleContent? content,
  ) {
    final paragraphs = [
      if (module.description.isNotEmpty) module.description,
      ?_systemTip(appLocalizations, module.system),
      if (content?.requirement case final requirement?
          when content?.requirementMet != true)
        appLocalizations.mitmModuleRequirementTip(requirement),
    ];
    return paragraphs.isEmpty ? null : paragraphs.join('\n\n');
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
    final views = details.value?.views ?? const {};
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
                    footer: _aboutFooter(appLocalizations, module, content),
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
                  if (content != null && content.arguments.isNotEmpty)
                    generateSection(
                      title: appLocalizations.arguments,
                      items: [
                        for (final argument in content.arguments)
                          _argumentItem(ref, module, argument),
                      ],
                      footer: _argumentsFooter(content),
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
                          if (content.mitm.linesOf(list) case final lines
                              when lines.isNotEmpty)
                            _linesItem(
                              list.label,
                              lines,
                              issues: issues[list] ?? const {},
                              views: views[list] ?? const {},
                              note: list == MitmList.clientSourceAddress
                                  ? appLocalizations.mitmClientSourceTunTip
                                  : null,
                              menuItemsOf:
                                  list == MitmList.script && module.enabled
                                  ? (line) => [?mitmRunScriptItem(ref, line)]
                                  : null,
                            ),
                        if (content.rules.isNotEmpty)
                          _linesItem(
                            appLocalizations.mitmRoutingRules,
                            content.rules,
                            issues: {
                              for (final line in content.rules)
                                if (_moduleRule(line) == null)
                                  line: appLocalizations.mitmSkipRule,
                            },
                            rules: true,
                            ruleSets: content.ruleProviders,
                          ),
                        if (content.skipped.isNotEmpty)
                          ListItem.open(
                            title: Text(appLocalizations.mitmIgnoredLines),
                            subtitle: Text(
                              appLocalizations.itemsCount(
                                content.skipped.length,
                              ),
                            ),
                            builder: (_) => _MitmModuleLinesView(
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
                      footer: [
                        appLocalizations.mitmModuleRulesDesc,
                        if (content.requestRules > 0)
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
    this.views = const {},
    this.notes = false,
    this.rules = false,
    this.ruleSets = const {},
    this.menuItemsOf,
  });

  final String title;

  /// Each line with why the Core skips it, or with [notes] why the module's
  /// reader left it out.
  final List<(String, String?)> lines;

  /// How the Core reads each line it applies, in whole or in part.
  final Map<String, MitmLineView> views;
  final bool notes;
  final bool rules;
  final Map<String, Map<String, Object?>> ruleSets;
  final List<PopupMenuItem> Function(String line)? menuItemsOf;

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
    final message = issue ?? context.appLocalizations.mitmSkipRule;
    return DecorationListItem(
      minVerticalPadding: 0,
      invalid: true,
      title: Text(
        line,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: DefaultTextStyle.of(context).style.toJetBrainsMono,
      ),
      subtitle: Text(
        message,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: context.colorScheme.error),
      ),
      onPressed: () => _showLine(context, line, message),
    );
  }

  Widget _lineRow(BuildContext context, String line, String? issue) {
    return MitmTaskRunning(
      line: line,
      builder: (running) => ContextMenuRegion(
        menuItems: menuItemsOf?.call(line),
        child: switch (views[line]) {
          final view? => _viewRow(context, line, view, issue, running),
          null => _rawRow(context, line, issue, running),
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
          final (line, issue) = lines[index];
          return ItemPositionProvider(
            position: ItemPosition.get(index, lines.length),
            child: rules
                ? ContextMenuRegion(
                    menuItems: menuItemsOf?.call(line),
                    child: _ruleRow(context, line, issue),
                  )
                : _lineRow(context, line, issue),
          );
        },
      ),
    );
  }
}

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
          ...heads(view.requestHead, null),
        ],
        tag: view.status?.toString() ?? view.dataType,
      ),
      final MitmScriptView view => _MitmLineParts(
        primary: view.name,
        code: false,
        details: [?(view.pattern ?? view.cronexp ?? view.event)],
        tag: switch (view.kind) {
          'httpRequest' => appLocalizations.request,
          'httpResponse' => appLocalizations.response,
          'cron' => appLocalizations.mitmScriptCron,
          'event' => appLocalizations.mitmScriptEvent,
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
