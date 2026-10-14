import 'dart:async';
import 'dart:convert';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/custom/icon.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IconSetsView extends ConsumerStatefulWidget {
  const IconSetsView({super.key});

  @override
  ConsumerState<IconSetsView> createState() => _IconSetsViewState();
}

class _IconSetsViewState extends ConsumerState<IconSetsView> {
  late final IconSetsAction _iconSetsAction;

  @override
  void initState() {
    super.initState();
    _iconSetsAction = ref.read(iconSetsActionProvider.notifier);
  }

  Future<void> _run(FutureOr<IconSet> Function() task, {String? title}) {
    return globalState.loadingRun(task, title: title, tag: LoadingTag.iconSets);
  }

  Future<void> _handleImportFromUrl() async {
    final res = await dialogs.showNamedUrlInput(
      title: context.appLocalizations.importUrl,
    );
    if (res == null || !mounted) {
      return;
    }
    await _run(() => _iconSetsAction.importUrl(res.url, name: res.label));
  }

  Future<void> _handleImportFromFile() async {
    final file = await globalState.safeRun(picker.pickerFile);
    if (file == null) {
      return;
    }
    final bytes = await file.readBytes();
    if (!mounted) {
      return;
    }
    await _run(
      () => _iconSetsAction.importContent(
        file.name,
        utf8.decode(bytes, allowMalformed: true),
      ),
    );
  }

  Future<void> _handleEditOptions(IconSet iconSet) async {
    final appLocalizations = context.appLocalizations;
    if (!iconSet.isRemote) {
      final name = await dialogs.showCommonDialog<String>(
        child: InputDialog(
          title: appLocalizations.options,
          value: iconSet.name,
          labelText: appLocalizations.name,
          inputFormatters: TextInputLimits.limit(TextInputLimits.name),
          validator: (value) => value?.trim().isNotEmpty == true
              ? null
              : appLocalizations.emptyTip(appLocalizations.name),
        ),
      );
      if (name != null) {
        ref
            .read(iconSetsProvider.notifier)
            .put(iconSet.copyWith(name: name.trim()));
      }
      return;
    }
    final res = await dialogs.showNamedUrlInput(
      title: appLocalizations.options,
      label: iconSet.name,
      url: iconSet.url,
    );
    if (res == null || !mounted) {
      return;
    }
    final next = iconSet.copyWith(
      name: res.label.isNotEmpty ? res.label : iconSet.name,
      url: res.url,
    );
    if (next.url == iconSet.url) {
      ref.read(iconSetsProvider.notifier).put(next);
      return;
    }
    await _run(() => _iconSetsAction.sync(next), title: next.name);
  }

  Future<void> _handleDelete(IconSet iconSet) async {
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(text: appLocalizations.deleteTip(iconSet.name)),
    );
    if (res == true) {
      ref.read(iconSetsProvider.notifier).del(iconSet.id);
    }
  }

  void _handlePreview(IconSet iconSet) {
    unawaited(BaseNavigator.push(context, _IconSetPreviewView(iconSet.id)));
  }

  List<CommonPopupMenuItem> _buildMenuItems(IconSet iconSet) {
    final appLocalizations = context.appLocalizations;
    return [
      if (iconSet.isRemote)
        CommonPopupMenuItem(
          glyph: AppGlyphs.sync,
          label: appLocalizations.sync,
          onPressed: () {
            _run(() => _iconSetsAction.sync(iconSet), title: iconSet.name);
          },
        ),
      CommonPopupMenuItem(
        glyph: AppGlyphs.settings,
        label: appLocalizations.options,
        onPressed: () {
          _handleEditOptions(iconSet);
        },
      ),
      CommonPopupMenuItem(
        danger: true,
        glyph: AppGlyphs.delete,
        label: appLocalizations.delete,
        onPressed: () {
          _handleDelete(iconSet);
        },
      ),
    ];
  }

  Widget _buildItem(List<IconSet> iconSets, int index) {
    final appLocalizations = context.appLocalizations;
    final iconSet = iconSets[index];
    return SortableItem(
      key: ValueKey(iconSet.id),
      index: index,
      child: ContextMenuRegion(
        menuItems: _buildMenuItems(iconSet),
        child: ItemPositionProvider(
          position: ItemPosition.get(index, iconSets.length),
          child: DecorationListItem(
            contentPadding: const EdgeInsets.only(left: 16),
            leading: SizedBox.square(
              dimension: 32,
              child: IconTheme.merge(
                data: const IconThemeData(size: 32),
                child: CommonTargetIcon(src: iconSet.cover),
              ),
            ),
            title: ChipTitle(
              title: iconSet.name,
              chip: iconSet.icons.length.compact,
            ),
            subtitle: Text(
              iconSet.isRemote
                  ? appLocalizations.remote
                  : appLocalizations.local,
              style: context.listCaptionStyle,
            ),
            trailing: const DisclosureIndicator(),
            onPressed: () {
              _handlePreview(iconSet);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(List<IconSet> iconSets, {required bool loading}) {
    final appLocalizations = context.appLocalizations;
    return NullStatusSwitcher(
      isLoading: loading,
      isEmpty: iconSets.isEmpty,
      nullStatus: NullStatus(
        label: appLocalizations.nullTip(appLocalizations.iconSets),
        illustration: NullStatusIllustration.icons,
      ),
      child: ReorderableListView.builder(
        padding: const EdgeInsets.all(
          16,
        ).copyWith(top: context.contentTopPadding),
        buildDefaultDragHandles: false,
        itemCount: iconSets.length,
        itemBuilder: (_, index) => _buildItem(iconSets, index),
        proxyDecorator: (_, index, animation) {
          return commonProxyDecorator(
            _buildItem(iconSets, index),
            index,
            animation,
          );
        },
        onReorderItem: ref.read(iconSetsProvider.notifier).order,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final state = ref.watch(iconSetsProvider);
    final iconSets = state.value ?? [];
    return CommonScaffold(
      canSort: iconSets.length > 1,
      isLoading: ref.watch(loadingProvider(LoadingTag.iconSets)),
      actions: [
        CommonPopupBox(
          targetBuilder: (open) {
            return IconButton(
              tooltip: appLocalizations.add,
              onPressed: () {
                final isMobile = ref.read(isMobileViewProvider);
                open(offset: Offset(0, isMobile ? 0 : 20));
              },
              icon: const GlyphIcon(AppGlyphs.addCircle),
            );
          },
          popupBuilder: (_) => CommonPopupMenu(
            items: [
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
      body: _buildContent(iconSets, loading: state.isLoading),
      title: appLocalizations.iconSets,
    );
  }
}

class _IconSetPreviewView extends ConsumerStatefulWidget {
  const _IconSetPreviewView(this.iconSetId);

  final int iconSetId;

  @override
  ConsumerState<_IconSetPreviewView> createState() =>
      _IconSetPreviewViewState();
}

class _IconSetPreviewViewState extends ConsumerState<_IconSetPreviewView> {
  var _query = SearchQuery('');

  @override
  Widget build(BuildContext context) {
    final iconSet = ref.watch(
      iconSetsProvider.select(
        (state) => state.value
            ?.where((item) => item.id == widget.iconSetId)
            .firstOrNull,
      ),
    );
    final icons = (iconSet?.icons ?? const <IconSetIcon>[])
        .whereMatches(_query, (icon) => [icon.label])
        .toList();
    return CommonScaffold(
      title: iconSet?.name ?? context.appLocalizations.iconSets,
      searchState: AppBarSearchState(
        onSearch: (query) {
          setState(() {
            _query = SearchQuery(query);
          });
        },
      ),
      body: NullStatusSwitcher(
        isEmpty: icons.isEmpty,
        isSearching: _query.isNotEmpty,
        nullStatus: NullStatus(
          label: context.appLocalizations.nullTip(
            context.appLocalizations.icon,
          ),
          illustration: NullStatusIllustration.icons,
        ),
        child: Builder(
          builder: (context) => IconGridScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(height: context.contentTopPadding),
              ),
              SliverIconGrid(icons: icons),
              SliverToBoxAdapter(
                child: SizedBox(height: 20 + BottomInsetScope.of(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
