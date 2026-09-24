import 'dart:math' as math;

import 'package:code_forge/code_forge.dart' show CodeForgeSuggestionDetails;
import 'package:fl_clash/common/common.dart';
import 'package:material_ui/material_ui.dart';

const _suggestionInset = 8.0;
const _suggestionItemGap = 4.0;
const _suggestionItemPadding = 10.0;
const _suggestionMinWidth = 160.0;
const _suggestionDetailGap = 16.0;
const _suggestionItemShape = AppShape.sm;
final _suggestionShape = AppShape.all(AppCorner.sm + _suggestionInset);

class EditorCompletionPopup extends StatefulWidget {
  final CodeForgeSuggestionDetails details;
  final TextStyle textStyle;

  const EditorCompletionPopup({
    super.key,
    required this.details,
    required this.textStyle,
  });

  @override
  State<EditorCompletionPopup> createState() => _EditorCompletionPopupState();
}

class _EditorCompletionPopupState extends State<EditorCompletionPopup> {
  final _scrollController = ScrollController();

  TextStyle get _detailStyle => widget.textStyle.copyWith(
    fontSize: (widget.textStyle.fontSize ?? 14) * 0.85,
  );

  double get _itemExtent =>
      (widget.textStyle.fontSize ?? 14) * 2 + _suggestionItemGap;

  // The list pads its ends by the inset less half a gap, so the first and
  // last highlight sit as far from the edge as from the sides.
  static const _listPadding = _suggestionInset - _suggestionItemGap / 2;

  @override
  void didUpdateWidget(covariant EditorCompletionPopup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.details.selectedIndex != oldWidget.details.selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _revealSelected());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _revealSelected() {
    final index = widget.details.selectedIndex;
    if (!mounted || index == null || !_scrollController.hasClients) {
      return;
    }
    final position = _scrollController.position;
    final top = index * _itemExtent;
    final bottom = top + _itemExtent + _listPadding * 2;
    final target = math.max(
      math.min(position.pixels, top),
      bottom - position.viewportDimension,
    );
    if (target != position.pixels) {
      _scrollController.jumpTo(
        target.clamp(position.minScrollExtent, position.maxScrollExtent),
      );
    }
  }

  static const _itemInset = _suggestionItemPadding + _suggestionInset;

  ({List<double> labels, double content}) _measureWidths(BuildContext context) {
    final painter = TextPainter(
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    );
    final widths = [
      for (final suggestion in widget.details.suggestions)
        _measure(painter, suggestion.label, widget.textStyle),
    ];
    var widest = 0.0;
    for (final (index, suggestion) in widget.details.suggestions.indexed) {
      var width = widths[index];
      if (suggestion.detail case final detail? when detail.isNotEmpty) {
        width += _suggestionDetailGap + _measure(painter, detail, _detailStyle);
      }
      widest = math.max(widest, width);
    }
    painter.dispose();
    return (labels: widths, content: widest + _itemInset * 2);
  }

  double _measure(TextPainter painter, String text, TextStyle style) {
    painter.text = TextSpan(text: text, style: style);
    painter.layout();
    return painter.width.ceilToDouble();
  }

  Widget _buildItem(
    BuildContext context,
    int index,
    double labelWidth,
    double rowWidth,
  ) {
    final colorScheme = context.colorScheme;
    final selected = index == widget.details.selectedIndex;
    final suggestion = widget.details.suggestions[index];
    final detail = suggestion.detail;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _suggestionItemGap / 2),
      child: InkWell(
        canRequestFocus: false,
        customBorder: _suggestionItemShape,
        splashColor: Colors.transparent,
        onTap: () => widget.details.onAccept(index),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: _suggestionItemPadding,
          ),
          decoration: ShapeDecoration(
            color: selected ? colorScheme.secondaryContainer : null,
            shape: _suggestionItemShape,
          ),
          child: Row(
            children: [
              SizedBox(
                width: math.min(labelWidth, rowWidth),
                child: Text(
                  suggestion.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: widget.textStyle.copyWith(
                    color: selected
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.onSurface,
                  ),
                ),
              ),
              if (detail != null &&
                  detail.isNotEmpty &&
                  rowWidth - labelWidth > _suggestionDetailGap) ...[
                const SizedBox(width: _suggestionDetailGap),
                Expanded(
                  child: Text(
                    detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: _detailStyle.copyWith(
                      color: selected
                          ? colorScheme.onSecondaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final widths = _measureWidths(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final width = widths.content
            .clamp(math.min(_suggestionMinWidth, maxWidth), maxWidth)
            .toDouble();
        final rowWidth = math.max(0.0, width - _itemInset * 2);
        return Material(
          type: MaterialType.card,
          elevation: 8,
          color: context.colorScheme.surfaceContainer,
          textStyle: widget.textStyle,
          clipBehavior: Clip.antiAlias,
          shape: _suggestionShape,
          child: SizedBox(
            width: width,
            child: ScrollConfiguration(
              behavior: const ShowBarScrollBehavior(
                scrollbarPadding: EdgeInsets.symmetric(
                  vertical: _suggestionInset,
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: _suggestionInset,
                  vertical: _listPadding,
                ),
                itemExtent: _itemExtent,
                itemCount: widget.details.suggestions.length,
                itemBuilder: (context, index) =>
                    _buildItem(context, index, widths.labels[index], rowWidth),
              ),
            ),
          ),
        );
      },
    );
  }
}
