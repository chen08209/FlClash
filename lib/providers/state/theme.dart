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
      ),
    ),
  );
  final dynamicColor = ref.watch(dynamicColorProvider);
  if (color == null &&
      (ignoreConfig == true || themeSetting.primaryColor == null)) {
    final seed = switch (brightness) {
      Brightness.light => dynamicColor.lightSeed,
      Brightness.dark => dynamicColor.darkSeed,
    };
    return ColorScheme.fromSeed(
      seedColor: seed ?? dynamicColor.accentColor,
      brightness: brightness,
      dynamicSchemeVariant: themeSetting.schemeVariant,
    );
  }
  return ColorScheme.fromSeed(
    seedColor: color ?? Color(themeSetting.primaryColor!),
    brightness: brightness,
    dynamicSchemeVariant: themeSetting.schemeVariant,
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
