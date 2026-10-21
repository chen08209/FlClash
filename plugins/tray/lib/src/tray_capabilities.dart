import 'package:flutter/foundation.dart';

final class TrayCapabilities {
  const TrayCapabilities({
    required this.supported,
    required this.title,
    required this.toolTip,
    required this.iconEvents,
    required this.menuControl,
  });

  final bool supported;
  final bool title;
  final bool toolTip;
  final bool iconEvents;
  final bool menuControl;

  // AppKit can orphan a status item's tooltip panel across sleep and title
  // resizes, leaving an empty box under the menu bar until the app quits.
  static const TrayCapabilities macOS = TrayCapabilities(
    supported: true,
    title: true,
    toolTip: false,
    iconEvents: true,
    menuControl: true,
  );

  static const TrayCapabilities windows = TrayCapabilities(
    supported: true,
    title: false,
    toolTip: true,
    iconEvents: true,
    menuControl: true,
  );

  static const TrayCapabilities linux = TrayCapabilities(
    supported: true,
    title: true,
    toolTip: true,
    iconEvents: false,
    menuControl: false,
  );

  static const TrayCapabilities none = TrayCapabilities(
    supported: false,
    title: false,
    toolTip: false,
    iconEvents: false,
    menuControl: false,
  );

  static TrayCapabilities of(TargetPlatform platform) {
    return switch (platform) {
      TargetPlatform.macOS => macOS,
      TargetPlatform.windows => windows,
      TargetPlatform.linux => linux,
      _ => none,
    };
  }
}
