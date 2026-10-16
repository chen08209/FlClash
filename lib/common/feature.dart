/// Build-time switches for features whose code stays either way, each
/// defaulting to how it ships. A disabled feature with a setting hides it and
/// ignores the stored value, so switching it back on restores what the user
/// had chosen.
class Feature {
  const Feature({
    this.sidebarBlur = const bool.fromEnvironment('FEATURE_SIDEBAR_BLUR'),
  });

  final bool sidebarBlur;
}

Feature feature = const Feature();
