/// Features whose code stays but that ship switched off. A disabled feature
/// hides its setting and ignores the stored value, so switching it back on
/// restores what the user had chosen.
class Feature {
  const Feature({
    this.sidebarBlur = const bool.fromEnvironment('FEATURE_SIDEBAR_BLUR'),
  });

  final bool sidebarBlur;
}

Feature feature = const Feature();
