/// Backdrop drawn behind the Flutter content. Anything but [none] needs the
/// content to paint a translucent background to be visible, and
/// `DesktopWindow.isEffectSupported` tells whether the platform can draw it.
enum WindowEffect { none, transparent, blur, acrylic, mica }
