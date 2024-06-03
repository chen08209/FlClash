import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/navigation.freezed.dart';

@freezed
class NavigationItem with _$NavigationItem {
  const factory NavigationItem({
    required Icon icon,
    required String label,
    final String? description,
    required Widget fragment,
    @Default(true) bool keep,
    String? path,
    @Default([NavigationItemMode.mobile, NavigationItemMode.desktop])
    List<NavigationItemMode> modes,
  }) = _NavigationItem;
}
