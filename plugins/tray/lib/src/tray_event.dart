import 'tray_menu.dart';

sealed class TrayEvent {
  const TrayEvent();
}

final class TrayIconActivated extends TrayEvent {
  const TrayIconActivated();
}

final class TrayMenuRequested extends TrayEvent {
  const TrayMenuRequested();
}

final class TrayMenuItemSelected extends TrayEvent {
  const TrayMenuItemSelected(this.item);

  final TrayMenuItem item;
}
