import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/state.dart';

const _pageTransitionsTheme = PageTransitionsTheme(
  builders: <TargetPlatform, PageTransitionsBuilder>{
    TargetPlatform.android: commonSharedXPageTransitions,
    TargetPlatform.windows: commonSharedXPageTransitions,
    TargetPlatform.linux: commonSharedXPageTransitions,
    TargetPlatform.macOS: commonSharedXPageTransitions,
  },
);

const _actionIconTheme = ActionIconThemeData(
  backButtonIconBuilder: _backButtonIcon,
  closeButtonIconBuilder: _closeButtonIcon,
);

Widget _backButtonIcon(BuildContext context) =>
    GlyphIcon(AppGlyphs.backFor(Theme.of(context).platform));

Widget _closeButtonIcon(BuildContext context) =>
    const GlyphIcon(AppGlyphs.close);

/// A rebuilt ThemeData never equals the last, and ThemeCrossFade fades on that.
final _appThemes = <Brightness, ({Object inputs, ThemeData theme})>{};

ThemeData watchAppTheme(WidgetRef ref, Brightness brightness) {
  final locale = ref.watch(appSettingProvider.select((state) => state.locale));
  final themeSetting = ref.watch(
    themeSettingProvider.select(
      (state) => (fontFamily: state.fontFamily, pureBlack: state.pureBlack),
    ),
  );
  final colorScheme = ref.watch(genColorSchemeProvider(brightness));
  final plainDark = brightness == Brightness.dark && themeSetting.pureBlack
      ? ref.watch(genColorSchemeProvider(brightness, pureBlack: false))
      : null;
  final locales = [
    ?getLocaleForString(locale),
    ...WidgetsBinding.instance.platformDispatcher.locales,
  ];
  final inputs = (
    platform: defaultTargetPlatform,
    themeSetting: themeSetting,
    colorScheme: colorScheme,
    plainDark: plainDark,
    locales: locales.join(','),
  );
  if (_appThemes[brightness] case (
    inputs: final cached,
    :final theme,
  ) when cached == inputs) {
    return theme;
  }
  final theme = ThemeData(
    useMaterial3: true,
    pageTransitionsTheme: _pageTransitionsTheme,
    actionIconTheme: _actionIconTheme,
    colorScheme: colorScheme,
    fontFamily: themeSetting.fontFamily,
    fontFamilyFallback: appFontFamilyFallback(
      platform: defaultTargetPlatform,
      locales: locales,
      fontFamily: themeSetting.fontFamily,
    ),
    extensions: [
      if (brightness == Brightness.dark)
        ElevatedColorScheme(
          // Plain dark is pure black a level up, with the seed's tint that a
          // lift from black would lose.
          plainDark ?? colorScheme.elevated,
        ),
    ],
  ).withAppShapes.withAppSurfaces.withAppTypography;
  _appThemes[brightness] = (inputs: inputs, theme: theme);
  return theme;
}

class ThemeManager extends ConsumerWidget {
  final Widget child;

  const ThemeManager({super.key, required this.child});

  Widget _buildSystemUi(Widget child) {
    if (!system.isAndroid) {
      return child;
    }
    return Consumer(
      builder: (context, ref, _) {
        final brightness = ref.watch(currentBrightnessProvider);
        final iconBrightness = brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: iconBrightness,
            systemNavigationBarIconBrightness: iconBrightness,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarDividerColor: Colors.transparent,
            systemNavigationBarContrastEnforced: false,
          ),
          sized: false,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, ref) {
    final textScale = ref.read(
      themeSettingProvider.select((state) => state.textScale),
    );
    final double textScaleFactor = max(
      min(
        textScale.enable ? textScale.scale : systemTextScaleOf(context),
        maxTextScale,
      ),
      minTextScale,
    );

    final measure = Measure.of(context, textScaleFactor);
    globalState.measure = measure;
    return MeasureScope(
      measure: measure,
      child: AppViewScope(
        child: _AppMediaQuery(
          textScaler: TextScaler.linear(textScaleFactor),
          child: _LiquidGlassSetting(
            child: LayoutBuilder(
              builder: (_, constraints) {
                ref
                    .read(themeActionProvider.notifier)
                    .updateViewSize(
                      Size(constraints.maxWidth, constraints.maxHeight),
                    );
                return _buildSystemUi(child);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class AppViewScope extends ConsumerWidget {
  const AppViewScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ref.watch(isMobileViewProvider);
    return ViewScope(
      size: ref.watch(viewSizeProvider),
      isMobile: isMobile,
      windowControls: windowControlsOverPage(
        isMacOS: system.isMacOS,
        version: ref.watch(versionProvider),
        isMobileView: isMobile,
      ),
      child: child,
    );
  }
}

class _LiquidGlassSetting extends ConsumerWidget {
  const _LiquidGlassSetting({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(
      themeSettingProvider.select((state) => state.liquidGlass),
    );
    return LiquidGlassScope(
      enabled: mode != LiquidGlassMode.none,
      quality: mode == LiquidGlassMode.ultra
          ? LiquidGlassQuality.ultra
          : LiquidGlassQuality.standard,
      child: LiquidGlassHost(
        enabled: mode != LiquidGlassMode.none,
        child: child,
      ),
    );
  }
}

class _AppMediaQuery extends StatelessWidget {
  const _AppMediaQuery({required this.textScaler, required this.child});

  final TextScaler textScaler;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);
    final padding = data.padding;
    return MediaQuery(
      data: data.copyWith(
        textScaler: textScaler,
        padding: padding.copyWith(
          top: padding.top > data.size.height * 0.3 ? 20.0 : padding.top,
        ),
      ),
      child: child,
    );
  }
}
