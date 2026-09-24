typedef TrayMenuItemSelectedCallback = void Function();

/// How a platform that colors details should color one; others ignore it.
/// macOS draws a colored detail as a measurement, smaller with even digits.
enum TrayDetailTone { plain, success, warning, error }

sealed class TrayMenuItem {
  const TrayMenuItem();
}

final class TrayMenuAction extends TrayMenuItem {
  const TrayMenuAction({
    required this.label,
    this.detail,
    this.detailTone = TrayDetailTone.plain,
    this.enabled = true,
    this.onSelected,
  });

  final String label;
  final String? detail;
  final TrayDetailTone detailTone;
  final bool enabled;
  final TrayMenuItemSelectedCallback? onSelected;
}

final class TrayMenuCheckbox extends TrayMenuItem {
  const TrayMenuCheckbox({
    required this.label,
    required this.checked,
    this.detail,
    this.detailTone = TrayDetailTone.plain,
    this.enabled = true,
    this.onSelected,
  });

  final String label;
  final bool checked;
  final String? detail;
  final TrayDetailTone detailTone;
  final bool enabled;
  final TrayMenuItemSelectedCallback? onSelected;
}

final class TrayMenuSubmenu extends TrayMenuItem {
  const TrayMenuSubmenu({
    required this.label,
    required this.items,
    this.detail,
    this.detailTone = TrayDetailTone.plain,
    this.enabled = true,
  });

  final String label;
  final List<TrayMenuItem> items;
  final String? detail;
  final TrayDetailTone detailTone;
  final bool enabled;
}

final class TrayMenuSeparator extends TrayMenuItem {
  const TrayMenuSeparator();
}
