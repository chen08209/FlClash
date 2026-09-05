typedef TrayMenuItemSelectedCallback = void Function();

sealed class TrayMenuItem {
  const TrayMenuItem();
}

final class TrayMenuAction extends TrayMenuItem {
  const TrayMenuAction({
    required this.label,
    this.enabled = true,
    this.onSelected,
  });

  final String label;
  final bool enabled;
  final TrayMenuItemSelectedCallback? onSelected;
}

final class TrayMenuCheckbox extends TrayMenuItem {
  const TrayMenuCheckbox({
    required this.label,
    required this.checked,
    this.enabled = true,
    this.onSelected,
  });

  final String label;
  final bool checked;
  final bool enabled;
  final TrayMenuItemSelectedCallback? onSelected;
}

final class TrayMenuSubmenu extends TrayMenuItem {
  const TrayMenuSubmenu({
    required this.label,
    required this.items,
    this.enabled = true,
  });

  final String label;
  final List<TrayMenuItem> items;
  final bool enabled;
}

final class TrayMenuSeparator extends TrayMenuItem {
  const TrayMenuSeparator();
}
