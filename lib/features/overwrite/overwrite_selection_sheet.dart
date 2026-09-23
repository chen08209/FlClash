import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _maxRevealSteps = 6;

class OverwriteSelectionSection<T> {
  final String? label;
  final List<T> items;
  final String Function(BuildContext context, T item)? subtitleBuilder;

  const OverwriteSelectionSection({
    this.label,
    required this.items,
    this.subtitleBuilder,
  });
}

class OverwriteSelectionSheet<T> extends ConsumerStatefulWidget {
  final String title;
  final List<OverwriteSelectionSection<T>> sections;
  final String Function(T item) labelBuilder;
  final T? Function(WidgetRef ref) selectedOf;
  final ValueChanged<T> onSelected;
  final double? bottomHeightFactor;
  final String? emptyLabel;

  const OverwriteSelectionSheet({
    super.key,
    required this.title,
    required this.sections,
    required this.labelBuilder,
    required this.selectedOf,
    required this.onSelected,
    this.bottomHeightFactor = 0.70,
    this.emptyLabel,
  });

  @override
  ConsumerState<OverwriteSelectionSheet<T>> createState() =>
      _OverwriteSelectionSheetState<T>();
}

class _OverwriteSelectionSheetState<T>
    extends ConsumerState<OverwriteSelectionSheet<T>> {
  final _controller = ScrollController();
  final _selectedKey = GlobalKey();
  var _revealRequested = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _itemCount =>
      widget.sections.fold(0, (value, section) => value + section.items.length);

  List<int> get _sectionOffsets {
    final offsets = <int>[];
    var offset = 0;
    for (final section in widget.sections) {
      offsets.add(offset);
      offset += section.items.length;
    }
    return offsets;
  }

  int _indexOf(T? selected) {
    var index = 0;
    for (final section in widget.sections) {
      for (final item in section.items) {
        if (item == selected) {
          return index;
        }
        index++;
      }
    }
    return -1;
  }

  // The list builds lazily, so a selection below the first viewport has no
  // element to reveal yet. Each jump builds more children, which also sharpens
  // the sliver's own extent estimate for the next step.
  Future<void> _revealSelected(int index, int count) async {
    for (var step = 0; step < _maxRevealSteps; step++) {
      if (!mounted || !_controller.hasClients) {
        return;
      }
      final itemContext = _selectedKey.currentContext;
      if (itemContext != null && itemContext.mounted) {
        _alignSelected(itemContext);
        return;
      }
      final position = _controller.position;
      final target = (position.maxScrollExtent * index / count).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      if ((target - position.pixels).abs() < 1) {
        return;
      }
      _controller.jumpTo(target);
      await WidgetsBinding.instance.endOfFrame;
    }
  }

  void _alignSelected(BuildContext itemContext) {
    final box = itemContext.findRenderObject();
    if (box is! RenderBox || !box.hasSize) {
      return;
    }
    final position = _controller.position;
    final viewport = RenderAbstractViewport.of(box);
    final atTop = viewport.getOffsetToReveal(box, 0).offset;
    final atBottom = viewport.getOffsetToReveal(box, 1).offset;
    if (position.pixels >= atBottom && position.pixels <= atTop) {
      return;
    }
    _controller.jumpTo(
      viewport
          .getOffsetToReveal(box, 0.5)
          .offset
          .clamp(position.minScrollExtent, position.maxScrollExtent),
    );
  }

  Widget _buildItem(
    BuildContext context,
    OverwriteSelectionSection<T> section,
    T item,
    int index, {
    required bool isSelected,
    required bool isRevealTarget,
  }) {
    final position = ItemPosition.get(index, section.items.length);
    return ItemPositionProvider(
      key: isRevealTarget ? _selectedKey : null,
      position: position,
      child: DecorationListItem(
        onPressed: () => widget.onSelected(item),
        subtitle: section.subtitleBuilder != null
            ? TooltipLabel(section.subtitleBuilder!(context, item))
            : null,
        title: TooltipText(
          text: Text(
            widget.labelBuilder(item),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        isSelected: isSelected,
        trailing: isSelected ? const Icon(Icons.check) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = ref.sheetHeight(context, (widget.bottomHeightFactor ?? 1));
    final count = _itemCount;
    final selected = widget.selectedOf(ref);
    final selectedIndex = _indexOf(selected);
    final sectionOffsets = _sectionOffsets;
    if (!_revealRequested && selectedIndex > 0) {
      _revealRequested = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _revealSelected(selectedIndex, count),
      );
    }
    return AdaptiveSheetScaffold(
      sheetTransparentToolBar: true,
      body: SizedBox(
        height: height,
        child: NullStatusSwitcher(
          isEmpty: count == 0 && widget.emptyLabel != null,
          nullStatus: NullStatus(label: widget.emptyLabel ?? ''),
          child: CustomScrollView(
            controller: _controller,
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(height: context.sheetTopPadding),
              ),
              for (final (sectionIndex, section)
                  in widget.sections.indexed) ...[
                if (section.label != null) ...[
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: InfoHeader(info: Info(label: section.label!)),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 4)),
                ],
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList.builder(
                    itemCount: section.items.length,
                    itemBuilder: (context, index) {
                      final item = section.items[index];
                      return _buildItem(
                        context,
                        section,
                        item,
                        index,
                        isSelected: item == selected,
                        isRevealTarget:
                            sectionOffsets[sectionIndex] + index ==
                            selectedIndex,
                      );
                    },
                  ),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
      title: widget.title,
    );
  }
}
