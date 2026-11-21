import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';

import 'connection_filters.dart';

const connectionFacetBarWidth = 188.0;
const _shownValues = 5;
const _rowHeight = 32.0;

/// The facets beside a wide table, each value with how many connections
/// hold it; a tap toggles it as the strip's menus do.
class ConnectionFacetBar extends StatefulWidget {
  final ConnectionFilterController controller;
  final EdgeInsetsGeometry padding;

  const ConnectionFacetBar({
    super.key,
    required this.controller,
    this.padding = EdgeInsets.zero,
  });

  @override
  State<ConnectionFacetBar> createState() => _ConnectionFacetBarState();
}

class _ConnectionFacetBarState extends State<ConnectionFacetBar> {
  final _expanded = <RecordFacetKind>{};

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return ListenableBuilder(
      listenable: Listenable.merge([controller, controller.counted]),
      builder: (context, _) {
        final rows = [
          for (final kind in connectionFacetKinds)
            if (controller.valuesOf(kind).isNotEmpty) ..._rowsOf(kind),
        ];
        return PrismListView(
          padding: widget.padding,
          itemCount: rows.length,
          itemBuilder: (context, index) => rows[index](),
        );
      },
    );
  }

  /// Built as the list reaches them, since a facet shown whole can run long.
  List<Widget Function()> _rowsOf(RecordFacetKind kind) {
    final appLocalizations = context.appLocalizations;
    final controller = widget.controller;
    final facet = controller.facetOf(kind)!;
    final values = controller.valuesOf(kind);
    final selected = controller.selectedOf(kind);
    final expanded = _expanded.contains(kind);
    final shown = expanded ? values : values.take(_shownValues);
    return [
      () => _buildTitle(kind, cleared: selected.isNotEmpty),
      for (final value in shown)
        () => _FacetValue(
          label: facet.label(value),
          count: controller.countOfValue(kind, value),
          selected: selected.contains(value),
          onPressed: () => controller.toggle(RecordFilter(kind, value)),
        ),
      if (values.length > _shownValues)
        () => _FacetValue(
          label: expanded
              ? appLocalizations.showLess
              : appLocalizations.viewAll,
          muted: true,
          onPressed: () => setState(() {
            if (!_expanded.remove(kind)) {
              _expanded.add(kind);
            }
          }),
        ),
      () => const SizedBox(height: 16),
    ];
  }

  Widget _buildTitle(RecordFacetKind kind, {required bool cleared}) {
    final colorScheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      child: Row(
        spacing: 6,
        children: [
          Expanded(
            child: Text(
              connectionFacetTitle(kind),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.footnote
                  .of(context, emphasized: true)
                  .copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
          if (cleared)
            _FacetValue(
              label: ConnectionStatus.all.label,
              compact: true,
              onPressed: () => widget.controller.clear(kind),
            ),
        ],
      ),
    );
  }
}

class _FacetValue extends StatelessWidget {
  final String label;
  final int? count;
  final bool selected;
  final bool muted;
  final bool compact;
  final VoidCallback onPressed;

  const _FacetValue({
    required this.label,
    this.count,
    this.selected = false,
    this.muted = false,
    this.compact = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final style = AppTextStyle.footnote.of(context);
    final labelStyle = AppTextStyle.footnote.of(context, emphasized: selected);
    final muted = this.muted || compact;
    final count = this.count;
    return PressSurface(
      fill: Colors.transparent,
      shape: AppShape.all(AppCorner.fit(_rowHeight)),
      childFills: true,
      onPressed: onPressed,
      child: SizedBox(
        height: compact ? null : _rowHeight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 12),
          child: Row(
            spacing: 8,
            mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
            children: [
              Flexible(
                fit: compact ? FlexFit.loose : FlexFit.tight,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: labelStyle.copyWith(
                    color: muted
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onSurface,
                  ),
                ),
              ),
              if (count != null)
                Text(
                  '$count',
                  style: style.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              if (selected) const SelectionCheck(),
            ],
          ),
        ),
      ),
    );
  }
}
