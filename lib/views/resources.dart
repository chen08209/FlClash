import 'dart:async';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' hide context;

typedef _RemoteResources = ({
  List<IconSet> iconSets,
  List<ClashProvider> ruleProviders,
  List<Script> scripts,
});

const _RemoteResources _noResources = (
  iconSets: <IconSet>[],
  ruleProviders: <ClashProvider>[],
  scripts: <Script>[],
);

class ResourcesView extends ConsumerStatefulWidget {
  const ResourcesView({super.key});

  @override
  ConsumerState<ResourcesView> createState() => _ResourcesViewState();
}

class _ResourcesViewState extends ConsumerState<ResourcesView>
    with RouteMotionHoldMixin<ResourcesView>, RouteSettledMixin<ResourcesView> {
  _RemoteResources? _resources;
  var _fileInfos = const <String, FileInfo?>{};

  @override
  void initState() {
    super.initState();
    ref.listenManual(iconSetsProvider, (_, _) => _refreshResources());
    ref.listenManual(clashProvidersProvider, (_, _) => _refreshResources());
    ref.listenManual(scriptsProvider, (_, _) => _refreshResources());
  }

  @override
  void didSettleRoute() => unawaited(_load());

  Future<void> _load() async {
    await Future.wait<Object>([
      ref.read(iconSetsProvider.future),
      ref.read(clashProvidersProvider.future),
      ref.read(scriptsProvider.future),
    ]).catchError((Object _) => const <Object>[]);
    if (!mounted) {
      return;
    }
    final resources = _readResources();
    final loads = <String, Future<FileInfo?>>{
      for (final type in GeoResource.values)
        type.updatingKey: _geoFileInfo(type),
      for (final provider in resources.ruleProviders)
        provider.updatingKey: provider.fileInfo,
      for (final script in resources.scripts)
        script.updatingKey: script.fileInfo,
    };
    final fileInfos = await Future.wait([
      for (final load in loads.values) load.catchError((Object _) => null),
    ]);
    if (!mounted) {
      return;
    }
    setState(() {
      _resources = _readResources();
      _fileInfos = Map.fromIterables(loads.keys, fileInfos);
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
  );

  void _refreshResources() {
    if (_resources == null) {
      return;
    }
    updateWhenRouteSettled(() => setState(() => _resources = _readResources()));
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
    if (interval == null || interval <= 0) {
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
    final resources = _resources;
    final (:iconSets, :ruleProviders, :scripts) = resources ?? _noResources;
    final resourceKeys = [
      for (final geoResource in GeoResource.values) geoResource.updatingKey,
      for (final iconSet in iconSets) iconSet.updatingKey,
      for (final provider in ruleProviders) provider.updatingKey,
      for (final script in scripts) script.updatingKey,
    ];
    final isUpdating = ref.watch(
      updatingKeysProvider.select((keys) => resourceKeys.any(keys.contains)),
    );

    return CommonScaffold(
      title: appLocalizations.resources,
      iconActions: [
        IconButtonData(
          glyph: AppGlyphs.sync,
          tooltip: appLocalizations.update,
          isLoading: isUpdating,
          onPressed: _updateAll,
        ),
      ],
      menuItems: [
        CommonPopupMenuItem(
          glyph: AppGlyphs.toggle,
          label: appLocalizations.autoUpdate,
          subItems: [
            CommonPopupMenuItem(
              label: appLocalizations.turnOn,
              checked: autoUpdate,
              onPressed: () => _updateAutoUpdate(true),
            ),
            CommonPopupMenuItem(
              label: appLocalizations.turnOff,
              checked: !autoUpdate,
              onPressed: () => _updateAutoUpdate(false),
            ),
          ],
        ),
        CommonPopupMenuItem(
          glyph: AppGlyphs.clock,
          label: appLocalizations.resourceUpdateInterval,
          onPressed: _updateInterval,
        ),
      ],
      body: NullStatusSwitcher(
        isEmpty: resources == null,
        holdsArrival: true,
        nullStatus: const NullStatus(illustration: NullStatusIllustration.data),
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ).copyWith(top: context.appBarInset, bottom: 16),
          children: [
            generateSectionV3(
              title: appLocalizations.geoResources,
              items: [
                for (final geoResource in GeoResource.values)
                  _GeoResourceItem(geoResource, preloaded: _fileInfos),
              ],
            ),
            generateSectionV3(
              title: appLocalizations.iconSets,
              items: [
                for (final iconSet in iconSets)
                  _IconSetItem(iconSet, key: ValueKey(iconSet.id)),
              ],
            ),
            generateSectionV3(
              title: appLocalizations.ruleProviders,
              items: [
                for (final provider in ruleProviders)
                  _RuleProviderItem(
                    provider,
                    preloaded: _fileInfos,
                    key: ValueKey(provider.id),
                  ),
              ],
            ),
            generateSectionV3(
              title: appLocalizations.script,
              items: [
                for (final script in scripts)
                  _ScriptItem(
                    script,
                    preloaded: _fileInfos,
                    key: ValueKey(script.id),
                  ),
              ],
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
      context.showNotifier(
        context.appLocalizations.copySuccess,
        level: MessageLevel.success,
      );
    }
  }

  List<CommonPopupMenuItem> _menuItems(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final url = this.url;
    return [
      if (!isUpdating)
        CommonPopupMenuItem(
          glyph: AppGlyphs.sync,
          label: appLocalizations.sync,
          onPressed: () {
            globalState.safeRun<void>(onSync, title: title, silence: false);
          },
        ),
      if (onEdit != null)
        CommonPopupMenuItem(
          glyph: AppGlyphs.edit,
          label: appLocalizations.edit,
          onPressed: onEdit,
        ),
      if (url != null)
        CommonPopupMenuItem(
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
          ? const SizedBox.square(
              key: ValueKey('updating'),
              dimension: 24,
              child: Padding(
                padding: EdgeInsets.all(2),
                child: CommonCircleLoading(),
              ),
            )
          : chip == null
          ? const SizedBox.shrink()
          : TonalChip(
              key: const ValueKey('chip'),
              label: chip,
              color: colorScheme.secondaryContainer,
              foregroundColor: colorScheme.onSecondaryContainer,
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

Future<FileInfo?> _geoFileInfo(GeoResource type) async {
  final fileName = switch (type) {
    GeoResource.MMDB => MMDB,
    GeoResource.ASN => ASN,
    GeoResource.GEOIP => GEOIP,
    GeoResource.GEOSITE => GEOSITE,
  };
  final homePath = await appPath.homeDirPath;
  return File(join(homePath, fileName)).getFileInfo();
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
          dialogs.showMessage(
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
