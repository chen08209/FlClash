import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/overwrite/overwrite.dart';
import 'package:fl_clash/models/models.dart' hide FileInfo;
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class NameAddEntry {
  final String title;
  final String? subtitle;

  const NameAddEntry({required this.title, this.subtitle});
}

class NameAddSection {
  final String label;
  final String? scene;
  final List<NameAddEntry> entries;

  const NameAddSection({
    required this.label,
    required this.entries,
    this.scene,
  });
}

typedef NameAddSectionsBuilder =
    List<NameAddSection> Function(BuildContext context, WidgetRef ref);

class NameAddPicker extends ConsumerStatefulWidget {
  final String title;

  final String stageTagPrefix;

  final List<String?> scenes;
  final ProxyGroup Function(ProxyGroup state, Set<dynamic> staged) apply;
  final NameAddSectionsBuilder sectionsBuilder;
  final double heightFactor;

  const NameAddPicker({
    super.key,
    required this.title,
    required this.stageTagPrefix,
    required this.apply,
    required this.sectionsBuilder,
    this.scenes = const [null],
    this.heightFactor = 0.8,
  });

  @override
  ConsumerState<NameAddPicker> createState() => _NameAddPickerState();
}

class _NameAddPickerState extends ConsumerState<NameAddPicker>
    with UniqueKeyStateMixin, OverwriteStageFlowMixin<NameAddPicker> {
  var _query = SearchQuery('');

  void _handleSearch(String query) {
    setState(() {
      _query = SearchQuery(query);
    });
  }

  String _tagOf(String? scene) =>
      scene == null ? widget.stageTagPrefix : '${widget.stageTagPrefix}_$scene';

  @override
  void initState() {
    super.initState();
    for (final scene in widget.scenes) {
      listenForStageChanges(
        tag: _tagOf(scene),
        scene: scene,
        duration: const Duration(milliseconds: 350),
        apply: widget.apply,
      );
    }
  }

  Widget _buildItem({
    required NameAddEntry entry,
    required ItemPosition position,
    required bool dismiss,
    required VoidCallback onAdd,
  }) {
    final subtitle = entry.subtitle;
    return ExternalDismissible(
      effect: ExternalDismissibleEffect.resize,
      key: ValueKey(entry.title),
      dismiss: dismiss,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ItemPositionProvider(
          position: position,
          child: DecorationListItem(
            minVerticalPadding: 8,
            title: TooltipText(
              text: Text(
                entry.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            subtitle: subtitle == null ? null : Text(subtitle),
            trailing: CommonMinIconButtonTheme(
              child: IconButton.filledTonal(
                tooltip: context.appLocalizations.add,
                onPressed: onAdd,
                icon: const GlyphIcon(AppGlyphs.add, size: 18, fill: 1),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSection(NameAddSection section, bool isLast) {
    final dismissed = ref.watch(
      itemsProvider(section.scene == null ? key : '${key}_${section.scene}'),
    );
    final entries = section.entries;
    List<String>? titles;
    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverToBoxAdapter(
          child: InfoHeader(info: Info(label: section.label)),
        ),
      ),
      SuperSliverList.builder(
        itemCount: entries.length,
        itemBuilder: (_, index) {
          final entry = entries[index];
          return _buildItem(
            entry: entry,
            position: dismissed.isEmpty
                ? ItemPosition.get(index, entries.length)
                : ItemPosition.calculateVisualPosition(
                    index,
                    titles ??= [for (final entry in entries) entry.title],
                    dismissed,
                  ),
            dismiss: dismissed.contains(entry.title),
            onAdd: () {
              handleStage(entry.title, section.scene);
            },
          );
        },
      ),
      if (!isLast) const SliverToBoxAdapter(child: SizedBox(height: 8)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final height = ref.sheetHeight(context, widget.heightFactor);
    final allSections = widget.sectionsBuilder(context, ref);
    final sections = [
      for (final section in allSections)
        NameAddSection(
          label: section.label,
          scene: section.scene,
          entries: section.entries
              .whereMatches(_query, (entry) => [entry.title, entry.subtitle])
              .toList(),
        ),
    ].where((section) => section.entries.isNotEmpty).toList();
    final entryCount = allSections.fold(
      0,
      (count, section) => count + section.entries.length,
    );
    return SizedBox(
      height: height,
      child: CommonScaffold(
        title: widget.title,
        searchState: _query.isNotEmpty || entryCount >= sheetSearchMinItemCount
            ? AppBarSearchState(onSearch: _handleSearch)
            : null,
        body: Builder(
          builder: (context) => NullStatusSwitcher(
            isEmpty: sections.isEmpty,
            isSearching: _query.isNotEmpty,
            nullStatus: NullStatus(label: appLocalizations.noData),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(height: context.sheetTopPadding),
                ),
                for (var i = 0; i < sections.length; i++)
                  ..._buildSection(sections[i], i == sections.length - 1),
                SliverToBoxAdapter(
                  child: SizedBox(height: 16 + BottomInsetScope.of(context)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
