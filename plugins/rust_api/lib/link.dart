library;

import 'src/rust/api/link.dart' as native;

/// The links the desktop app is opened with: its launch arguments, a
/// relaunch's, and on macOS URL events. Each is delivered once.
Stream<Uri> desktopLinks() {
  return native.linkStream().expand((link) {
    final uri = Uri.tryParse(link);
    return uri == null ? const <Uri>[] : [uri];
  });
}
