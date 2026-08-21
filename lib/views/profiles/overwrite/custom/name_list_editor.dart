import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/overwrite/overwrite.dart';
import 'package:fl_clash/models/models.dart' hide FileInfo;
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

class NameListEditorLabels {
  final String title;
  final String section;
  final String empty;
  final String includeAll;
  final String includeAllTip;

  const NameListEditorLabels({
    required this.title,
    required this.section,
    required this.empty,
    required this.includeAll,
    required this.includeAllTip,
  });
}

class NameListEditorLens {
  final List<String> Function(ProxyGroup state) namesOf;
  final ProxyGroup Function(ProxyGroup state, List<String> names) withNames;
  final bool Function(ProxyGroup state) includeAllOf;
  final ProxyGroup Function(ProxyGroup state, bool includeAll) withIncludeAll;

  const NameListEditorLens({
    required this.namesOf,
    required this.withNames,
    required this.includeAllOf,
    required this.withIncludeAll,
  });
}

class NameListEditor extends ConsumerStatefulWidget {
  final String stageTag;
  final NameListEditorLabels labels;
  final NameListEditorLens lens;
  final WidgetBuilder addViewBuilder;
  final bool Function(WidgetRef ref, int profileId, String name) isValidOf;
  final String Function(BuildContext context, String name) invalidMessageOf;
  final String? Function(String name)? subtitleOf;
  final double dragIconPadding;

  const NameListEditor({
    super.key,
    required this.stageTag,
    required this.labels,
    required this.lens,
    required this.addViewBuilder,
    required this.isValidOf,
    required this.invalidMessageOf,
    this.subtitleOf,
    this.dragIconPadding = 12,
  });

  @override
  ConsumerState<NameListEditor> createState() => _NameListEditorState();
}

class _NameListEditorState extends ConsumerState<NameListEditor>
    with UniqueKeyStateMixin, OverwriteStageFlowMixin<NameListEditor> {
  ProxyGroup _removeStaged(ProxyGroup state, Set<dynamic> staged) {
    final next = List<String>.from(widget.lens.namesOf(state));
    next.removeWhere(staged.contains);
    return widget.lens.withNames(state, next);
  }

  @override
  void initState() {
    super.initState();
    listenForStageChanges(tag: widget.stageTag, apply: _removeStaged);
  }

  void _handleToAddView() {
    Navigator.of(context).push(PagedSheetRoute(builder: widget.addViewBuilder));
  }

  void _handleReorder(int oldIndex, int newIndex) {
    ref.read(proxyGroupProvider.notifier).update((state) {
      final next = widget.lens
          .namesOf(state)
          .copyAndReorder(oldIndex, newIndex);
      return widget.lens.withNames(state, next);
    });
  }

  void _handleChangeIncludeAll() {
    ref
        .read(proxyGroupProvider.notifier)
        .update(
          (state) => widget.lens.withIncludeAll(
            state,
            !widget.lens.includeAllOf(state),
          ),
        );
  }

  Widget _buildItem({
    required String name,
    required int index,
    required int length,
    required ItemPosition position,
    required bool dismiss,
  }) {
    return OverwriteDismissItem(
      key: ValueKey(name),
      title: name,
      subtitle: widget.subtitleOf?.call(name),
      position: position,
      dismiss: dismiss,
      index: index,
      dragIconPadding: widget.dragIconPadding,
      isValidOf: widget.isValidOf,
      invalidMessageOf: widget.invalidMessageOf,
      onRemove: () => handleStage(name),
      onDismissed: () {
        handleRealStage(tag: widget.stageTag, apply: _removeStaged);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final include = ref.watch(
      proxyGroupProvider.select(
        (state) => OverwriteIncludeSelectorState(
          includeAll: widget.lens.includeAllOf(state),
          names: widget.lens.namesOf(state),
        ),
      ),
    );
    final dismissItems = ref.watch(itemsProvider(key));
    final names = include.names;
    final height = ref.sheetHeight(context, 0.85);
    Widget itemAt(int index) {
      return _buildItem(
        name: names[index],
        position: ItemPosition.calculateVisualPosition(
          index,
          names,
          dismissItems,
        ),
        dismiss: dismissItems.contains(names[index]),
        index: index,
        length: names.length,
      );
    }

    return SizedBox(
      height: height,
      child: AdaptiveSheetScaffold(
        title: widget.labels.title,
        sheetTransparentToolBar: true,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(height: context.sheetTopPadding + 8),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: _IncludeAllCard(
                  label: widget.labels.includeAll,
                  tip: widget.labels.includeAllTip,
                  value: include.includeAll,
                  onChanged: _handleChangeIncludeAll,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: InfoHeader(
                  info: Info(label: widget.labels.section),
                  actions: [
                    CommonMinFilledButtonTheme(
                      child: FilledButton.tonal(
                        onPressed: _handleToAddView,
                        child: Text(appLocalizations.add),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (names.isNotEmpty)
              SliverReorderableList(
                itemBuilder: (_, index) => itemAt(index),
                itemCount: names.length,
                proxyDecorator: (child, index, animation) =>
                    commonProxyDecorator(itemAt(index), index, animation),
                onReorderItem: _handleReorder,
              )
            else
              SliverFillRemaining(
                hasScrollBody: false,
                child: NullStatus(label: widget.labels.empty),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
    );
  }
}

class _IncludeAllCard extends StatelessWidget {
  const _IncludeAllCard({
    required this.label,
    required this.tip,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String tip;
  final bool value;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      radius: 20,
      type: CommonCardType.filled,
      child: ListItem.toggle(
        minTileHeight: 54,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            CommonMinIconButtonTheme(
              child: IconButton(
                tooltip: context.appLocalizations.tip,
                padding: EdgeInsets.zero,
                onPressed: () {
                  dialogs.showMessage(
                    title: context.appLocalizations.tip,
                    message: TextSpan(text: tip),
                    cancelable: false,
                  );
                },
                icon: Icon(
                  size: 16.ap,
                  Icons.info_outline,
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        value: value,
        onChanged: (_) {
          onChanged();
        },
      ),
    );
  }
}
