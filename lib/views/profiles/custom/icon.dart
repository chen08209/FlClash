import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/form/form.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _recommendedKey = 'recommended';
const _iconPlateSize = 56.0;
const _iconSize = 40.0;
const _iconLabelGap = 6.0;
const _isolatedMatchCount = 1000;

final _searchTexts = Expando<String>();

List<IconNameMatch> _matchIconNames(
  ({List<String> names, String target}) input,
) {
  return matchIconNames(input.names, input.target);
}

class _IconSource {
  const _IconSource({
    required this.key,
    required this.label,
    required this.icons,
  });

  final Object key;
  final String label;
  final List<IconSetIcon> icons;
}

IconSetIcon _recordIcon(IconRecord record) {
  final url = record.url;
  return IconSetIcon(
    name: url.startsWith('data:') ? '' : url.urlFileName,
    url: url,
  );
}

String _iconLabel(BuildContext context, IconSetIcon icon) {
  return icon.name.isEmpty ? context.appLocalizations.localImage : icon.label;
}

/// Pops with the chosen icon, an empty string to remove it, or null when the
/// sheet is left without a choice.
class IconPickerView extends ConsumerStatefulWidget {
  final String? value;
  final String groupName;

  const IconPickerView({super.key, this.value, this.groupName = ''});

  @override
  ConsumerState<IconPickerView> createState() => _IconPickerViewState();
}

class _IconPickerViewState extends ConsumerState<IconPickerView> {
  List<IconRecord>? _records;
  Object? _matchesKey;
  List<ScoredIcon>? _setMatches;
  Object? _sourceKey;
  Object? _sourcesKey;
  var _sources = const <_IconSource>[];
  var _query = SearchQuery('');

  String get _value => widget.value ?? '';

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final records = await database.iconRecordsDao.query('');
    if (mounted) {
      setState(() {
        _records = records;
      });
    }
  }

  /// Null until the first match over [iconSets] lands; a later set list keeps
  /// the previous matches meanwhile.
  List<ScoredIcon>? _setMatchesOf(List<IconSet> iconSets) {
    final key = (iconSets, widget.groupName);
    if (key == _matchesKey) {
      return _setMatches;
    }
    _matchesKey = key;
    final icons = [for (final iconSet in iconSets) ...iconSet.icons];
    if (icons.length < _isolatedMatchCount) {
      return _setMatches = icons.scoreFor(widget.groupName);
    }
    unawaited(_matchInIsolate(key, icons));
    return _setMatches;
  }

  Future<void> _matchInIsolate(Object key, List<IconSetIcon> icons) async {
    var matches = const <IconNameMatch>[];
    try {
      matches = await compute(_matchIconNames, (
        names: [for (final icon in icons) icon.name],
        target: widget.groupName,
      ));
    } catch (e) {
      commonPrint.log('icon match error $e', logLevel: LogLevel.warning);
    }
    if (mounted && key == _matchesKey) {
      setState(() {
        _setMatches = icons.scoredBy(matches);
      });
    }
  }

  List<_IconSource> _sourcesOf(
    List<IconSet> iconSets,
    List<ScoredIcon>? setMatches,
  ) {
    final appLocalizations = context.appLocalizations;
    final key = (
      iconSets,
      _records,
      appLocalizations,
      widget.groupName,
      setMatches,
    );
    if (key == _sourcesKey) {
      return _sources;
    }
    _sourcesKey = key;
    final recent = (_records ?? const <IconRecord>[]).map(_recordIcon).toList();
    final recommended = rankIconMatches([
      ...?setMatches,
      ...recent.scoreFor(widget.groupName),
    ]);
    final urls = {for (final icon in recommended) icon.url};
    final suggested = [
      ...recommended,
      for (final icon in recent)
        if (urls.add(icon.url)) icon,
    ];
    return _sources = [
      if (suggested.isNotEmpty)
        _IconSource(
          key: _recommendedKey,
          label: appLocalizations.recommendedIcons,
          icons: suggested,
        ),
      for (final iconSet in iconSets)
        if (iconSet.icons.isNotEmpty)
          _IconSource(
            key: iconSet.id,
            label: iconSet.name,
            icons: iconSet.icons,
          ),
    ];
  }

  Object? _initialSourceKey(List<_IconSource> sources) {
    if (_value.isNotEmpty) {
      for (final source in sources) {
        if (source.key is int &&
            source.icons.any((icon) => icon.url == _value)) {
          return source.key;
        }
      }
    }
    return sources.firstOrNull?.key;
  }

  void _handleSearch(String query) {
    setState(() {
      _query = SearchQuery(query);
    });
  }

  void _handleSelect(IconSetIcon icon) {
    Navigator.of(context).pop(icon.url);
  }

  void _handleRemove() {
    Navigator.of(context).pop('');
  }

  Future<void> _handleDeleteRecord(IconSetIcon icon) async {
    if (!(_records?.any((record) => record.url == icon.url) ?? false)) {
      return;
    }
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(
        text: appLocalizations.deleteTip(_iconLabel(context, icon)),
      ),
    );
    if (res != true) {
      return;
    }
    await database.iconRecordsDao.del(icon.url);
    if (mounted) {
      setState(() {
        _records = _records?.where((item) => item.url != icon.url).toList();
      });
    }
  }

  Future<void> _handleLink() async {
    final appLocalizations = context.appLocalizations;
    final url = await dialogs.showCommonDialog<String>(
      child: InputDialog(
        title: appLocalizations.iconUrl,
        value: _value.isUrl ? _value : '',
        labelText: appLocalizations.url,
        keyboardType: TextInputType.url,
        inputFormatters: TextInputLimits.limit(TextInputLimits.iconUrl),
        validator: (value) {
          final url = value?.trim() ?? '';
          if (url.isEmpty) {
            return appLocalizations.emptyTip(appLocalizations.url);
          }
          return url.isUrl
              ? null
              : appLocalizations.urlTip(appLocalizations.url);
        },
      ),
    );
    if (url != null && mounted) {
      Navigator.of(context).pop(url.trim());
    }
  }

  List<Widget> _buildSearchSlivers(List<_IconSource> sources) {
    final shown = <String>{};
    return [
      for (final source in sources)
        if ([
              for (final icon in source.icons.whereMatches(
                _query,
                (icon) => [icon.label],
                texts: _searchTexts,
              ))
                if (shown.add(icon.url)) icon,
            ]
            case final icons when icons.isNotEmpty) ...[
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: InfoHeader(info: Info(label: source.label)),
            ),
          ),
          _buildGrid(source, icons),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
        ],
    ];
  }

  Widget _buildGrid(_IconSource source, List<IconSetIcon> icons) {
    return SliverIconGrid(
      icons: icons,
      selected: _value,
      onSelected: _handleSelect,
      onLongPress: source.key == _recommendedKey ? _handleDeleteRecord : null,
    );
  }

  Widget _buildSourceBar(List<_IconSource> sources, Object? sourceKey) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        children: [
          for (final source in sources)
            SettingTextCard(
              source.label,
              isSelected: source.key == sourceKey,
              onPressed: () {
                setState(() {
                  _sourceKey = source.key;
                });
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final iconSets = ref.watch(iconSetsProvider).value ?? const <IconSet>[];
    final setMatches = _setMatchesOf(iconSets);
    final sources = _sourcesOf(iconSets, setMatches);
    final sourceKey = sources.any((source) => source.key == _sourceKey)
        ? _sourceKey
        : _initialSourceKey(sources);
    final source = sources
        .where((source) => source.key == sourceKey)
        .firstOrNull;
    final searchSlivers = _query.isNotEmpty
        ? _buildSearchSlivers(sources)
        : const <Widget>[];
    final isLoading = _records == null || setMatches == null;
    final isEmpty = _query.isNotEmpty
        ? searchSlivers.isEmpty
        : source == null && !isLoading;
    return CommonScaffold(
      title: appLocalizations.icon,
      searchState: AppBarSearchState(onSearch: _handleSearch),
      iconActions: [
        IconButtonData(
          glyph: AppGlyphs.link,
          tooltip: appLocalizations.iconUrl,
          onPressed: _handleLink,
        ),
      ],
      body: Builder(
        builder: (context) => IconGridScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(height: context.contentTopPadding),
            ),
            if (_value.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ).copyWith(bottom: 16),
                sliver: SliverToBoxAdapter(
                  child: _CurrentIcon(
                    src: _value,
                    iconSets: iconSets,
                    onRemove: _handleRemove,
                  ),
                ),
              ),
            if (isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: NullStatus(
                  label: _query.isNotEmpty
                      ? appLocalizations.noSearchResults
                      : appLocalizations.iconSetsEmptyTip,
                  illustration: _query.isNotEmpty
                      ? NullStatusIllustration.search
                      : NullStatusIllustration.icons,
                ),
              )
            else if (_query.isNotEmpty)
              ...searchSlivers
            else if (source != null && !isLoading) ...[
              SliverToBoxAdapter(child: _buildSourceBar(sources, sourceKey)),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              _buildGrid(source, source.icons),
            ],
            SliverToBoxAdapter(
              child: SizedBox(height: 20 + BottomInsetScope.of(context)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentIcon extends StatelessWidget {
  const _CurrentIcon({
    required this.src,
    required this.iconSets,
    required this.onRemove,
  });

  final String src;
  final List<IconSet> iconSets;
  final VoidCallback onRemove;

  ({String title, String? subtitle}) _describe(BuildContext context) {
    for (final iconSet in iconSets) {
      for (final icon in iconSet.icons) {
        if (icon.url == src) {
          return (title: icon.label, subtitle: iconSet.name);
        }
      }
    }
    if (src.startsWith('data:')) {
      return (title: context.appLocalizations.localImage, subtitle: null);
    }
    return (
      title: src.urlFileName.fileStem.takeFirstValid([src]),
      subtitle: Uri.tryParse(src)?.host,
    );
  }

  @override
  Widget build(BuildContext context) {
    final description = _describe(context);
    final subtitle = description.subtitle;
    return CommonCard(
      type: CommonCardType.filled,
      radius: AppCorner.xl,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          spacing: 12,
          children: [
            SizedBox.square(
              dimension: 40,
              child: IconTheme.merge(
                data: const IconThemeData(size: 40),
                child: CommonTargetIcon(src: src),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TooltipText(
                    text: Text(
                      description.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodyLarge,
                    ),
                  ),
                  if (subtitle != null && subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            EntryButton.remove(onPressed: onRemove),
          ],
        ),
      ),
    );
  }
}

class IconGridScrollView extends StatefulWidget {
  const IconGridScrollView({super.key, required this.slivers});

  final List<Widget> slivers;

  @override
  State<IconGridScrollView> createState() => _IconGridScrollViewState();
}

class _IconGridScrollViewState extends State<IconGridScrollView>
    with RouteSettledMixin<IconGridScrollView> {
  @override
  void didSettleRoute() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      scrollCacheExtent: arrivalScrollCacheExtent(routeSettled),
      slivers: widget.slivers,
    );
  }
}

class SliverIconGrid extends StatelessWidget {
  final List<IconSetIcon> icons;
  final String? selected;
  final ValueChanged<IconSetIcon>? onSelected;
  final ValueChanged<IconSetIcon>? onLongPress;

  const SliverIconGrid({
    super.key,
    required this.icons,
    this.selected,
    this.onSelected,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 88,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          mainAxisExtent:
              _iconPlateSize +
              _iconLabelGap +
              globalState.measure.bodySmallHeight,
        ),
        itemCount: icons.length,
        itemBuilder: (context, index) {
          final icon = icons[index];
          return _IconTile(
            icon: icon,
            isSelected: icon.url == selected,
            onPressed: onSelected != null ? () => onSelected!(icon) : null,
            onLongPress: onLongPress != null ? () => onLongPress!(icon) : null,
          );
        },
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.icon,
    required this.isSelected,
    this.onPressed,
    this.onLongPress,
  });

  final IconSetIcon icon;
  final bool isSelected;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final label = _iconLabel(context, icon);
    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: onPressed,
        onLongPress: onLongPress,
        onSecondaryTap: onLongPress,
        child: Column(
          spacing: _iconLabelGap,
          children: [
            Material(
              color: colorScheme.secondaryContainer,
              shape: isSelected
                  ? AppShape.md.copyWith(
                      side: BorderSide(color: colorScheme.primary, width: 2),
                    )
                  : AppShape.md,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                customBorder: AppShape.md,
                onTap: onPressed,
                onLongPress: onLongPress,
                child: SizedBox.square(
                  dimension: _iconPlateSize,
                  child: Center(
                    child: SizedBox.square(
                      dimension: _iconSize,
                      child: IconTheme.merge(
                        data: const IconThemeData(size: _iconSize),
                        child: CommonTargetIcon(src: icon.url),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
