import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/widget.freezed.dart';

@freezed
abstract class ActivateState with _$ActivateState {
  const factory ActivateState({
    required bool active,
  }) = _ActivateState;
}

@freezed
abstract class CommonMessage with _$CommonMessage {
  const factory CommonMessage({
    required String id,
    required String text,
    @Default(Duration(seconds: 3)) Duration duration,
  }) = _CommonMessage;
}

@freezed
abstract class AppBarState with _$AppBarState {
  const factory AppBarState({
    @Default([]) List<Widget> actions,
    AppBarSearchState? searchState,
    AppBarEditState? editState,
  }) = _AppBarState;
}

@freezed
abstract class AppBarSearchState with _$AppBarSearchState {
  const factory AppBarSearchState({
    required Function(String) onSearch,
    @Default(null) String? query,
  }) = _AppBarSearchState;
}

@freezed
abstract class AppBarEditState with _$AppBarEditState {
  const factory AppBarEditState({
    @Default(0) int editCount,
    required Function() onExit,
  }) = _AppBarEditState;
}
