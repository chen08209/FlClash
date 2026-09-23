import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:material_ui/material_ui.dart';

/// Below this many items a sheet is short enough to scan without a search.
const sheetSearchMinItemCount = 10;

class SearchField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  const SearchField({
    super.key,
    required this.onChanged,
    this.controller,
    this.focusNode,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleClear() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (_, value, _) {
        return TextField(
          controller: _controller,
          focusNode: widget.focusNode,
          textInputAction: TextInputAction.search,
          inputFormatters: TextInputLimits.limit(TextInputLimits.search),
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: appLocalizations.search,
            prefixIcon: const GlyphIcon(AppGlyphs.search, size: 20),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: appLocalizations.clearSearch,
                    onPressed: _handleClear,
                    icon: const GlyphIcon(AppGlyphs.close, size: 20),
                  ),
          ),
        );
      },
    );
  }
}
