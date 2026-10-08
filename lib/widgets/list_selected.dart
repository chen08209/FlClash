part of 'list.dart';

class CommonSelectedListItem extends StatelessWidget {
  final bool isSelected;
  final bool isEditing;
  final Widget title;
  final VoidCallback onSelected;
  final VoidCallback onPressed;

  const CommonSelectedListItem({
    super.key,
    required this.isSelected,
    required this.onSelected,
    this.isEditing = false,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        color: Colors.transparent,
        child: CommonCard(
          radius: AppCorner.xl,
          type: CommonCardType.filled,
          isSelected: isSelected,
          onPressed: () {
            if (isEditing) {
              onSelected();
              return;
            }
            onPressed();
          },
          child: ListTile(
            minTileHeight: listRowMinHeight,
            minVerticalPadding: listRowVerticalPadding,
            titleTextStyle: context.listTitleStyle,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            trailing: SizedBox(
              width: 24,
              height: 24,
              child: CommonCheckBox(
                value: isSelected,
                isCircle: true,
                onChanged: (_) {
                  onSelected();
                },
              ),
            ),
            title: title,
          ),
        ),
      ),
    );
  }
}

class DecorationListItem extends StatefulWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool? isSelected;
  final double? horizontalTitleGap;
  final EdgeInsetsGeometry? contentPadding;
  final VoidCallback? onPressed;
  final double? minVerticalPadding;
  final bool invalid;

  const DecorationListItem({
    super.key,
    this.contentPadding,
    required this.title,
    this.leading,
    this.trailing,
    this.subtitle,
    this.isSelected,
    this.onPressed,
    this.horizontalTitleGap,
    this.minVerticalPadding,
    this.invalid = false,
  });

  @override
  State<DecorationListItem> createState() => _DecorationListItemState();
}

class _DecorationListItemState extends State<DecorationListItem> {
  final _states = WidgetStatesController();

  @override
  void dispose() {
    _states.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final proxyDecorator =
        ProxyDecoratorProvider.of(context)?.isProxyDecorator ?? false;
    final sortable = SortableItem.maybeOf(context);
    final sorting = sortable?.sorting ?? false;
    final position = ItemPositionProvider.of(context)?.position;
    final isStart = [
      ItemPosition.start,
      ItemPosition.startAndEnd,
    ].contains(position);
    final isEnd = [
      ItemPosition.end,
      ItemPosition.startAndEnd,
    ].contains(position);
    final borderRadius = AppRadius.vertical(
      top: isStart ? AppCorner.xl : AppCorner.none,
      bottom: isEnd ? AppCorner.xl : AppCorner.none,
    );
    return _ListRowSeparator(
      separated: !proxyDecorator && !isEnd,
      emphasized: (widget.isSelected ?? false) || widget.invalid,
      states: _states,
      endIndent: 14,
      child: CommonCard(
        shape: proxyDecorator ? LinearBorder.none : AppShape.of(borderRadius),
        isError: widget.invalid,
        isSelected: widget.isSelected,
        padding: EdgeInsets.zero,
        type: CommonCardType.filled,
        statesController: _states,
        inert: sorting,
        onPressed: proxyDecorator ? null : widget.onPressed,
        child: LayoutBuilder(
          builder: (_, constraints) {
            final tile = ListTile(
              leading: widget.leading == null
                  ? null
                  : IgnorePointer(ignoring: sorting, child: widget.leading),
              contentPadding:
                  widget.contentPadding ??
                  const EdgeInsets.only(right: 16, left: 16),
              title: _ListRowSeparatorStart(child: widget.title),
              subtitle: widget.subtitle,
              titleTextStyle: context.listTitleStyle,
              subtitleTextStyle: context.listSubtitleStyle,
              minVerticalPadding:
                  widget.minVerticalPadding ?? listRowVerticalPadding,
              minTileHeight: listRowMinHeight,
              horizontalTitleGap: widget.horizontalTitleGap,
              trailing: sortable == null
                  ? widget.trailing
                  : SortableTrailing(item: sortable, child: widget.trailing),
            );
            if (constraints.maxHeight >= double.infinity) {
              return tile;
            }
            return SizedBox(height: constraints.maxHeight, child: tile);
          },
        ),
      ),
    );
  }
}

class SelectedDecorationListItem extends StatelessWidget {
  final bool isSelected;
  final bool isEditing;
  final Widget title;
  final Widget? subtitle;
  final VoidCallback onSelected;
  final VoidCallback onPressed;
  final double? horizontalTitleGap;
  final Widget? leading;
  final bool invalid;
  final double? minVerticalPadding;

  const SelectedDecorationListItem({
    super.key,
    required this.isSelected,
    required this.onSelected,
    this.horizontalTitleGap,
    this.isEditing = false,
    this.invalid = false,
    required this.title,
    required this.onPressed,
    this.minVerticalPadding,
    this.subtitle,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return DecorationListItem(
      title: title,
      minVerticalPadding: minVerticalPadding,
      contentPadding: const EdgeInsets.only(left: 16, right: 0),
      isSelected: isSelected,
      invalid: invalid,
      leading: leading,
      horizontalTitleGap: horizontalTitleGap,
      onPressed: () {
        if (isEditing) {
          onSelected();
          return;
        }
        onPressed();
      },
      subtitle: subtitle,
      trailing: CommonCheckBox(
        value: isSelected,
        isCircle: true,
        onChanged: (_) {
          onSelected();
        },
      ),
    );
  }
}
