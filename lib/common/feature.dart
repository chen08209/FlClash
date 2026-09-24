/// Features whose code stays but that ship switched off. A disabled feature
/// hides its setting and ignores the stored value, so switching it back on
/// restores what the user had chosen.
class Feature {
  const Feature({
    this.sidebarBlur = const bool.fromEnvironment('FEATURE_SIDEBAR_BLUR'),
    this.customProviders = const bool.fromEnvironment(
      'FEATURE_CUSTOM_PROVIDERS',
    ),
    this.customProxies = const bool.fromEnvironment('FEATURE_CUSTOM_PROXIES'),
  });

  final bool sidebarBlur;

  /// App-level proxy and rule providers, and profiles offered as providers.
  final bool customProviders;

  /// The proxies a custom overwrite keeps in place of the profile's own.
  final bool customProxies;
}

Feature feature = const Feature();
