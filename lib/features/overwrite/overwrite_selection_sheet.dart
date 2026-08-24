import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class OverwriteSelectionSheet<T> extends ConsumerWidget {
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

  Widget _buildItem(
    BuildContext context,
    OverwriteSelectionSection<T> section,
    T item,
    int index,
    bool isSelected,
  ) {
    final position = ItemPosition.get(index, section.items.length);
    return ItemPositionProvider(
      position: position,
      child: DecorationListItem(
        onPressed: () => onSelected(item),
        subtitle: section.subtitleBuilder != null
            ? Text(section.subtitleBuilder!(context, item))
            : null,
        title: TooltipText(
          text: Text(
            labelBuilder(item),
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
  Widget build(BuildContext context, ref) {
    final height = ref.sheetHeight(context, (bottomHeightFactor ?? 1));
    final isEmpty = sections.every((section) => section.items.isEmpty);
    final selected = selectedOf(ref);
    return AdaptiveSheetScaffold(
      sheetTransparentToolBar: true,
      body: SizedBox(
        height: height,
        child: isEmpty && emptyLabel != null
            ? NullStatus(label: emptyLabel!)
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(height: context.sheetTopPadding),
                  ),
                  for (final section in sections) ...[
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
                            item == selected,
                          );
                        },
                      ),
                    ),
                  ],
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
      ),
      title: title,
    );
  }
}
