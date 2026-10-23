import 'package:fl_clash/common/input_limits.dart';
import 'package:fl_clash/ui/button.dart';
import 'package:fl_clash/ui/focus.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/l10n.dart';
import 'package:fl_clash/ui/shape.dart';
import 'package:fl_clash/ui/surface.dart';
import 'package:fl_clash/ui/typography.dart';
import 'package:material_ui/material_ui.dart';

/// Below this many items a sheet is short enough to scan without a search.
const sheetSearchMinItemCount = 10;

// As iOS 27 sets its field: the glyph's center 22 dp in, the clear button's 24.5.
const double _glyphInset = 12;
const double _textInset = 41;
const double _clearReach = 49;
const double _clearSize = 24;

/// A search field as iOS 27 draws one, on [fill] or on what stands behind it.
class SearchField extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final double? height;
  final Color? fill;
  final Glyph glyph;
  final String? hintText;
  final VoidCallback? onSubmitted;
  final Widget? trailing;

  const SearchField({
    super.key,
    this.onChanged,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.height,
    this.fill,
    this.glyph = AppGlyphs.search,
    this.hintText,
    this.onSubmitted,
    this.trailing,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  TextEditingController? _ownedController;

  TextEditingController get _controller =>
      widget.controller ?? (_ownedController ??= TextEditingController());

  @override
  void dispose() {
    _ownedController?.dispose();
    super.dispose();
  }

  void _handleClear() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final localizations = UiLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final remote = RemoteFocusAdapter.isEnabledOf(context);
    final pill = AppShape.input.copyWith(borderRadius: AppRadius.full);
    final trailing = widget.trailing;
    return ListenableBuilder(
      listenable: Listenable.merge([_controller, FocusMovedByKey.instance]),
      builder: (_, _) {
        final empty = _controller.text.isEmpty;
        final ringed = remote || FocusMovedByKey.instance.value;
        return TextField(
          controller: _controller,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          maxLines: 1,
          textAlignVertical: TextAlignVertical.center,
          textInputAction: TextInputAction.search,
          style: AppTextStyle.body.of(context),
          inputFormatters: TextInputLimits.limit(TextInputLimits.search),
          onChanged: widget.onChanged,
          onSubmitted: (_) => widget.onSubmitted?.call(),
          // Not dense: a dense decorator fits its fill to the text and ignores
          // the minimum height, which desktop's compact density left short.
          decoration: InputDecoration(
            constraints: BoxConstraints.tightFor(
              height: widget.height ?? TonalButtonSize.bar.button,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            filled: widget.fill != null,
            fillColor: widget.fill,
            hintText: widget.hintText ?? localizations.search,
            border: pill.copyWith(borderSide: BorderSide.none),
            enabledBorder: pill.copyWith(borderSide: BorderSide.none),
            focusedBorder: pill.copyWith(
              borderSide: ringed ? focusRingSide(colorScheme) : BorderSide.none,
            ),
            contentPadding: EdgeInsetsDirectional.only(
              end: empty && trailing == null ? 12 : 0,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsetsDirectional.only(start: _glyphInset),
              child: GlyphIcon(widget.glyph, size: 20),
            ),
            prefixIconConstraints: const BoxConstraints.tightFor(
              width: _textInset,
            ),
            suffixIcon: empty && trailing == null
                ? null
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ?trailing,
                      if (!empty)
                        SizedBox(
                          width: _clearReach,
                          child: IconButton(
                            tooltip: localizations.clearSearch,
                            onPressed: _handleClear,
                            style: IconButton.styleFrom(
                              foregroundColor: colorScheme.onSurface,
                              overlayColor: Colors.transparent,
                              splashFactory: NoSplash.splashFactory,
                            ),
                            icon: const GlyphIcon(
                              AppGlyphs.clearField,
                              size: _clearSize,
                              fill: 1,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 8),
                    ],
                  ),
            suffixIconConstraints: const BoxConstraints(),
          ),
        );
      },
    );
  }
}
