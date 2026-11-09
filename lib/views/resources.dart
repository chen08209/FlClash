import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/mitm/module_editor.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' hide context;

typedef _RemoteResources = ({
  List<IconSet> iconSets,
  List<ClashProvider> ruleProviders,
  List<Script> scripts,
  List<MitmModule> modules,
});

const _RemoteResources _noResources = (
  iconSets: <IconSet>[],
  ruleProviders: <ClashProvider>[],
  scripts: <Script>[],
  modules: <MitmModule>[],
);

class ResourcesView extends ConsumerStatefulWidget {
  const ResourcesView({super.key});

  @override
  ConsumerState<ResourcesView> createState() => _ResourcesViewState();
}

class _ResourcesViewState extends ConsumerState<ResourcesView> {
  _RemoteResources? _resources;
  var _fileInfos = const <String, FileInfo?>{};

  @override
  void initState() {
    super.initState();
    ref.listenManual(iconSetsProvider, (_, _) => _refreshResources());
    ref.listenManual(clashProvidersProvider, (_, _) => _refreshResources());
    ref.listenManual(scriptsProvider, (_, _) => _refreshResources());
    ref.listenManual(mitmModulesProvider, (_, _) => _refreshResources());
    unawaited(_load());
  }

  Future<void> _load() async {
    await Future.wait<Object>([
      ref.read(iconSetsProvider.future),
      ref.read(clashProvidersProvider.future),
      ref.read(scriptsProvider.future),
      ref.read(mitmModulesProvider.future),
    ]).catchError((Object _) => const <Object>[]);
    if (!mounted) {
      return;
    }
    final resources = _readResources();
    final fileInfos = await _loadFileInfos(
      resources,
    ).catchError((Object _) => const <String, FileInfo?>{});
    if (!mounted) {
      return;
    }
    setState(() {
      _resources = _readResources();
      _fileInfos = fileInfos;
    });
  }

  _RemoteResources _readResources() => (
    iconSets: [
      for (final iconSet in ref.read(iconSetsProvider).value ?? <IconSet>[])
        if (iconSet.isRemote) iconSet,
    ],
    ruleProviders: [
      for (final provider
          in ref.read(clashProvidersProvider).value ?? <ClashProvider>[])
        if (provider.isRemote) provider,
    ],
    scripts: [
      for (final script in ref.read(scriptsProvider).value ?? <Script>[])
        if (script.url != null) script,
    ],
    modules: [
      for (final module
          in ref.read(mitmModulesProvider).value ?? <MitmModule>[])
        if (mitmFeature && module.isRemote) module,
    ],
  );

  void _refreshResources() {
    if (_resources == null) {
      return;
    }
    setState(() => _resources = _readResources());
  }

  Future<void> _updateAll() async {
    final failures = await ref
        .read(resourcesActionProvider.notifier)
        .updateAll();
    dialogs.showFailures(failures);
  }

  Future<void> _updateInterval() async {
    final appLocalizations = context.appLocalizations;
    final updateInterval = ref.read(patchClashConfigProvider).geoUpdateInterval;
    final value = await dialogs.showCommonDialog<String>(
      child: InputDialog(
        title: appLocalizations.resourceUpdateInterval,
        value: updateInterval.toString(),
        suffixText: appLocalizations.hours,
        keyboardType: TextInputType.number,
        inputFormatters: TextInputLimits.digitsOnly(
          TextInputLimits.geoUpdateInterval,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return appLocalizations.emptyTip(
              appLocalizations.resourceUpdateInterval,
            );
          }
          final interval = int.tryParse(value);
          if (interval == null) {
            return appLocalizations.numberTip(
              appLocalizations.resourceUpdateInterval,
            );
          }
          if (interval <= 0) {
            return appLocalizations.resourceUpdateIntervalTip;
          }
          return null;
        },
      ),
    );
    final interval = int.tryParse(value ?? '');
    if (interval == null || interval <= 0 || !mounted) {
      return;
    }
    ref
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(geoUpdateInterval: interval));
  }

  void _updateAutoUpdate(bool value) {
    ref
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(geoAutoUpdate: value));
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final autoUpdate = ref.watch(
      patchClashConfigProvider.select((state) => state.geoAutoUpdate),
    );
    final updateInterval = ref.watch(
      patchClashConfigProvider.select((state) => state.geoUpdateInterval),
    );
    final resources = _resources;
    final (:iconSets, :ruleProviders, :scripts, :modules) =
        resources ?? _noResources;
    final resourceKeys = [
      for (final geoResource in GeoResource.values) geoResource.updatingKey,
      for (final iconSet in iconSets) iconSet.updatingKey,
      for (final provider in ruleProviders) provider.updatingKey,
      for (final script in scripts) script.updatingKey,
      for (final module in modules) module.updatingKey,
    ];
    final isUpdating = ref.watch(
      updatingKeysProvider.select((keys) => resourceKeys.any(keys.contains)),
    );

    return Scaffold(
      title: appLocalizations.resources,
      iconActions: [
        IconButtonData(
          glyph: AppGlyphs.sync,
          tooltip: appLocalizations.update,
          isLoading: isUpdating,
          onPressed: _updateAll,
        ),
      ],
      body: NullStatusSwitcher(
        isLoading: resources == null,
        loadingStatus: const NullStatus(
          illustration: NullStatusIllustration.data,
        ),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
                top: context.sectionsTopPadding,
                bottom: 16 + context.bottomInset,
              ),
              sliver: SliverMainAxisGroup(
                slivers: [
                  SliverToBoxAdapter(
                    child: generateSection(
                      items: [
                        ListItem.toggle(
                          title: Text(appLocalizations.autoUpdate),
                          value: autoUpdate,
                          onChanged: _updateAutoUpdate,
                        ),
                        if (autoUpdate)
                          ListItem(
                            title: Text(
                              appLocalizations.resourceUpdateInterval,
                            ),
                            subtitle: Text(
                              '$updateInterval ${appLocalizations.hours}',
                            ),
                            onTap: _updateInterval,
                          ),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: generateSection(
                      title: appLocalizations.geoResources,
                      items: [
                        for (final geoResource in GeoResource.values)
                          _GeoResourceItem(geoResource, preloaded: _fileInfos),
                      ],
                    ),
                  ),
                  generateSliverSection(
                    title: appLocalizations.iconSets,
                    items: iconSets,
                    itemBuilder: (iconSet) =>
                        _IconSetItem(iconSet, key: ValueKey(iconSet.id)),
                  ),
                  generateSliverSection(
                    title: appLocalizations.ruleProviders,
                    items: ruleProviders,
                    itemBuilder: (provider) => _RuleProviderItem(
                      provider,
                      preloaded: _fileInfos,
                      key: ValueKey(provider.id),
                    ),
                  ),
                  generateSliverSection(
                    title: appLocalizations.script,
                    items: scripts,
                    itemBuilder: (script) => _ScriptItem(
                      script,
                      preloaded: _fileInfos,
                      key: ValueKey(script.id),
                    ),
                  ),
                  if (mitmFeature)
                    generateSliverSection(
                      title: appLocalizations.mitmModules,
                      items: modules,
                      itemBuilder: (module) =>
                          _ModuleItem(module, key: ValueKey(module.id)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResourceItem extends StatelessWidget {
  final String title;
  final String? url;
  final String? chip;
  final DateTime? lastUpdateTime;
  final bool pending;
  final bool isUpdating;
  final Future<void> Function() onSync;
  final VoidCallback? onEdit;

  const _ResourceItem({
    required this.title,
    required this.url,
    required this.chip,
    required this.lastUpdateTime,
    this.pending = false,
    required this.isUpdating,
    required this.onSync,
    this.onEdit,
  });

  Future<void> _copyLink(BuildContext context, String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (context.mounted) {
      dialogs.showBanner(
        context.appLocalizations.copySuccess,
        level: BannerLevel.success,
      );
    }
  }

  List<PopupMenuItem> _menuItems(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final url = this.url;
    return [
      if (!isUpdating)
        PopupMenuItem(
          glyph: AppGlyphs.sync,
          label: appLocalizations.sync,
          onPressed: () {
            globalState.safeRun<void>(onSync, title: title, silence: false);
          },
        ),
      if (onEdit != null)
        PopupMenuItem(
          glyph: AppGlyphs.edit,
          label: appLocalizations.edit,
          onPressed: onEdit,
        ),
      if (url != null)
        PopupMenuItem(
          glyph: AppGlyphs.copy,
          label: appLocalizations.copyLink,
          onPressed: () {
            _copyLink(context, url);
          },
        ),
    ];
  }

  Widget _buildTrailing(BuildContext context) {
    final chip = this.chip;
    final colorScheme = context.colorScheme;
    return AnimatedSwitcher(
      duration: context.motionDuration(commonDuration),
      layoutBuilder: (currentChild, previousChildren) => Stack(
        alignment: AlignmentDirectional.centerEnd,
        children: [...previousChildren, ?currentChild],
      ),
      child: isUpdating
          ? const ActivityIndicator(key: ValueKey('updating'), size: 24)
          : chip == null
          ? const SizedBox.shrink()
          : TonalChip(
              key: const ValueKey('chip'),
              label: chip,
              color: context.raisedSurfaceLevel.colorOf(colorScheme),
              foregroundColor: colorScheme.onSurfaceVariant,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subtitleStyle = context.listCaptionStyle;
    return ContextMenuRegion(
      menuItems: _menuItems(context),
      child: DecorationListItem(
        onPressed: onEdit,
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: lastUpdateTime != null || pending
            ? LastUpdateTimeText(
                lastUpdateDate: lastUpdateTime,
                style: subtitleStyle,
              )
            : Text(context.appLocalizations.unknown, style: subtitleStyle),
        trailing: _buildTrailing(context),
      ),
    );
  }
}

/// An update can rewrite the file without changing [source], so the file is
/// read again once [updatingKey] settles.
class _FileInfoBuilder extends ConsumerStatefulWidget {
  final Object source;
  final String updatingKey;
  final Map<String, FileInfo?> preloaded;
  final Future<FileInfo?> Function() load;
  final Widget Function(BuildContext context, FileInfo? fileInfo, bool pending)
  builder;

  const _FileInfoBuilder({
    required this.source,
    required this.updatingKey,
    required this.preloaded,
    required this.load,
    required this.builder,
  });

  @override
  ConsumerState<_FileInfoBuilder> createState() => _FileInfoBuilderState();
}

class _FileInfoBuilderState extends ConsumerState<_FileInfoBuilder> {
  Future<FileInfo?>? _fileInfoFuture;

  @override
  void initState() {
    super.initState();
    if (!widget.preloaded.containsKey(widget.updatingKey)) {
      _fileInfoFuture = widget.load();
    }
  }

  @override
  void didUpdateWidget(covariant _FileInfoBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) {
      _fileInfoFuture = widget.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(isUpdatingProvider(widget.updatingKey), (previous, next) {
      if (previous == true && !next) {
        setState(() {
          _fileInfoFuture = widget.load();
        });
      }
    });
    return FutureBuilder<FileInfo?>(
      future: _fileInfoFuture,
      initialData: widget.preloaded[widget.updatingKey],
      builder: (context, snapshot) => widget.builder(
        context,
        snapshot.data,
        _fileInfoFuture != null &&
            snapshot.connectionState != ConnectionState.done &&
            !snapshot.hasData,
      ),
    );
  }
}

String _geoFileName(GeoResource type) => switch (type) {
  GeoResource.MMDB => MMDB,
  GeoResource.ASN => ASN,
  GeoResource.GEOIP => GEOIP,
  GeoResource.GEOSITE => GEOSITE,
};

Future<FileInfo?> _geoFileInfo(GeoResource type) async {
  final homePath = await appPath.homeDirPath;
  return File(join(homePath, _geoFileName(type))).getFileInfo();
}

typedef _FileInfoQuery = ({
  String homeDir,
  String providersDir,
  String scriptsDir,
  List<ClashProvider> providers,
  List<int> scriptIds,
});

/// Rule set file names are md5 hashes, so paths are built off the UI isolate
/// along with one stat per file.
Future<Map<String, FileInfo?>> _loadFileInfos(
  _RemoteResources resources,
) async {
  final query = (
    homeDir: await appPath.homeDirPath,
    providersDir: await appPath.ruleProviderCacheDirPath,
    scriptsDir: await appPath.scriptsDirPath,
    providers: resources.ruleProviders,
    scriptIds: [for (final script in resources.scripts) script.id],
  );
  final fileInfos = await _readFileInfosInIsolate(query);
  return Map.fromIterables([
    for (final type in GeoResource.values) type.updatingKey,
    for (final provider in resources.ruleProviders) provider.updatingKey,
    for (final script in resources.scripts) script.updatingKey,
  ], fileInfos);
}

Future<List<FileInfo?>> _readFileInfosInIsolate(_FileInfoQuery query) {
  return Isolate.run(() => _readFileInfos(query));
}

List<FileInfo?> _readFileInfos(_FileInfoQuery query) {
  FileInfo? read(String path) {
    try {
      return File(path).getFileInfoSync();
    } on FileSystemException {
      return null;
    }
  }

  return [
    for (final type in GeoResource.values)
      read(join(query.homeDir, _geoFileName(type))),
    for (final provider in query.providers)
      read(join(query.providersDir, provider.fileName)),
    for (final id in query.scriptIds)
      read(AppPath.scriptPathIn(query.scriptsDir, id.toString())),
  ];
}

class _GeoResourceItem extends ConsumerWidget {
  final GeoResource type;
  final Map<String, FileInfo?> preloaded;

  const _GeoResourceItem(this.type, {required this.preloaded});

  Future<void> _updateUrl(
    BuildContext context,
    WidgetRef ref,
    String url,
  ) async {
    final newUrl = await dialogs.showCommonDialog<String>(
      child: UpdateGeoUrlFormDialog(
        title: type.name,
        url: url,
        defaultValue: defaultGeoXUrl[type],
      ),
    );
    if (newUrl != null && newUrl != url && context.mounted) {
      try {
        ref
            .read(geoResourceActionProvider.notifier)
            .updateGeoResourceUrl(type, newUrl);
      } catch (e) {
        unawaited(
          dialogs.showAlert(
            title: type.name,
            message: TextSpan(text: e.toString()),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUpdating = ref.watch(isUpdatingProvider(type.updatingKey));
    final url = ref.watch(
      patchClashConfigProvider.select((state) => state.geoXUrl[type]),
    );
    return _FileInfoBuilder(
      source: type,
      updatingKey: type.updatingKey,
      preloaded: preloaded,
      load: () => _geoFileInfo(type),
      builder: (context, fileInfo, pending) => _ResourceItem(
        title: type.name,
        url: url,
        chip: fileInfo?.size.traffic.show,
        lastUpdateTime: fileInfo?.lastModified,
        pending: pending,
        isUpdating: isUpdating,
        onSync: () => ref
            .read(geoResourceActionProvider.notifier)
            .updateGeoResource(type),
        onEdit: url == null ? null : () => _updateUrl(context, ref, url),
      ),
    );
  }
}

class _IconSetItem extends ConsumerWidget {
  final IconSet iconSet;

  const _IconSetItem(this.iconSet, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ResourceItem(
      title: iconSet.name,
      url: iconSet.url,
      chip: iconSet.icons.length.compact,
      lastUpdateTime: iconSet.lastUpdateTime,
      isUpdating: ref.watch(isUpdatingProvider(iconSet.updatingKey)),
      onSync: () =>
          ref.read(resourcesActionProvider.notifier).updateIconSet(iconSet),
    );
  }
}

class _RuleProviderItem extends ConsumerWidget {
  final ClashProvider provider;
  final Map<String, FileInfo?> preloaded;

  const _RuleProviderItem(this.provider, {required this.preloaded, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUpdating = ref.watch(isUpdatingProvider(provider.updatingKey));
    return _FileInfoBuilder(
      source: provider,
      updatingKey: provider.updatingKey,
      preloaded: preloaded,
      load: () => provider.fileInfo,
      builder: (context, fileInfo, pending) => _ResourceItem(
        title: provider.label,
        url: provider.url,
        chip: fileInfo?.size.traffic.show,
        lastUpdateTime: fileInfo?.lastModified,
        pending: pending,
        isUpdating: isUpdating,
        onSync: () => ref
            .read(resourcesActionProvider.notifier)
            .updateRuleProvider(provider),
      ),
    );
  }
}

class _ScriptItem extends ConsumerWidget {
  final Script script;
  final Map<String, FileInfo?> preloaded;

  const _ScriptItem(this.script, {required this.preloaded, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUpdating = ref.watch(isUpdatingProvider(script.updatingKey));
    return _FileInfoBuilder(
      source: script,
      updatingKey: script.updatingKey,
      preloaded: preloaded,
      load: () => script.fileInfo,
      builder: (context, fileInfo, _) => _ResourceItem(
        title: script.label,
        url: script.url,
        chip: fileInfo?.size.traffic.show,
        lastUpdateTime: script.lastUpdateTime,
        isUpdating: isUpdating,
        onSync: () =>
            ref.read(resourcesActionProvider.notifier).updateScript(script),
      ),
    );
  }
}

class _ModuleItem extends ConsumerWidget {
  final MitmModule module;

  const _ModuleItem(this.module, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ResourceItem(
      title: module.name,
      url: module.url,
      chip: null,
      lastUpdateTime: module.lastUpdateTime,
      isUpdating: ref.watch(isUpdatingProvider(module.updatingKey)),
      onSync: () => updateMitmModule(ref, module),
    );
  }
}

class UpdateGeoUrlFormDialog extends StatelessWidget {
  final String title;
  final String url;
  final String? defaultValue;

  const UpdateGeoUrlFormDialog({
    super.key,
    required this.title,
    required this.url,
    this.defaultValue,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return InputDialog(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      title: title,
      value: url,
      resetValue: defaultValue,
      inputFormatters: TextInputLimits.limit(TextInputLimits.url),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return appLocalizations.emptyTip('').trim();
        }
        if (!value.isUrl) {
          return appLocalizations.urlTip('').trim();
        }
        return null;
      },
    );
  }
}
