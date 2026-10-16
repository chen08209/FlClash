import 'package:fl_clash/ui/icons/icons.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/models.freezed.dart';

@freezed
abstract class IconButtonData with _$IconButtonData {
  const factory IconButtonData({
    required Glyph glyph,
    required VoidCallback? onPressed,
    String? tooltip,
    @Default(false) bool isLoading,

    /// Non-null makes the button a toggle that shows this state.
    bool? isSelected,
  }) = _IconButtonData;
}

@freezed
abstract class AppBarState with _$AppBarState {
  const factory AppBarState({AppBarSearchState? searchState}) = _AppBarState;
}

@freezed
abstract class AppBarSearchState with _$AppBarSearchState {
  const factory AppBarSearchState({
    required Function(String) onSearch,
    @Default(null) String? query,
  }) = _AppBarSearchState;
}
