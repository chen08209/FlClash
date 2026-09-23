part of '../state.dart';

typedef DynamicColorSeeds = ({
  Color? lightSeed,
  Color? darkSeed,
  Color accentColor,
});

@Riverpod(keepAlive: true)
class DynamicColor extends _$DynamicColor {
  @override
  DynamicColorSeeds build() {
    return (
      lightSeed: null,
      darkSeed: null,
      accentColor: const Color(defaultPrimaryColor),
    );
  }

  void seed({Color? lightSeed, Color? darkSeed, required Color accentColor}) {
    state = (
      lightSeed: lightSeed,
      darkSeed: darkSeed,
      accentColor: accentColor,
    );
  }
}

@riverpod
ColorScheme genColorScheme(
  Ref ref,
  Brightness brightness, {
  Color? color,
  bool ignoreConfig = false,
}) {
  final themeSetting = ref.watch(
    themeSettingProvider.select(
      (state) => (
        primaryColor: state.primaryColor,
        schemeVariant: state.schemeVariant,
        pureBlack: state.pureBlack,
      ),
    ),
  );
  final dynamicColor = ref.watch(dynamicColorProvider);
  final Color seedColor;
  if (color == null &&
      (ignoreConfig == true || themeSetting.primaryColor == null)) {
    final seed = switch (brightness) {
      Brightness.light => dynamicColor.lightSeed,
      Brightness.dark => dynamicColor.darkSeed,
    };
    seedColor = seed ?? dynamicColor.accentColor;
  } else {
    seedColor = color ?? Color(themeSetting.primaryColor!);
  }
  return ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: brightness,
    dynamicSchemeVariant: themeSetting.schemeVariant,
  ).toPureBlack(themeSetting.pureBlack);
}

typedef WindowBlurRequest = ({bool enabled, Brightness brightness, Color tint});

@riverpod
WindowBlurRequest windowBlurRequest(Ref ref) {
  final enabled =
      feature.sidebarBlur &&
      ref.watch(themeSettingProvider.select((state) => state.sidebarBlur));
  final brightness = ref.watch(currentBrightnessProvider);
  final colorScheme = ref.watch(genColorSchemeProvider(brightness));
  return (
    enabled: enabled,
    brightness: brightness,
    tint: colorScheme.surfaceContainer,
  );
}

@riverpod
Brightness currentBrightness(Ref ref) {
  final themeMode = ref.watch(
    themeSettingProvider.select((state) => state.themeMode),
  );
  final systemBrightness = ref.watch(systemBrightnessProvider);
  return switch (themeMode) {
    ThemeMode.system => systemBrightness,
    ThemeMode.light => Brightness.light,
    ThemeMode.dark => Brightness.dark,
  };
}
