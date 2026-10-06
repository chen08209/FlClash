import 'package:fl_clash/common/shape.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:material_ui/material_ui.dart';

@immutable
class InterfaceStyleTheme extends ThemeExtension<InterfaceStyleTheme> {
  const InterfaceStyleTheme({
    this.style = InterfaceStyle.material,
    this.miuixMonet = false,
    this.barBlur = false,
    this.liquidGlass = false,
    this.predictiveBack = false,
  });

  final InterfaceStyle style;

  /// Off, Miuix runs on its stock palette rather than one seeded from a color.
  final bool miuixMonet;
  final bool barBlur;
  final bool liquidGlass;
  final bool predictiveBack;

  bool get isMiuix => style == InterfaceStyle.miuix;

  @override
  InterfaceStyleTheme copyWith({
    InterfaceStyle? style,
    bool? miuixMonet,
    bool? barBlur,
    bool? liquidGlass,
    bool? predictiveBack,
  }) {
    return InterfaceStyleTheme(
      style: style ?? this.style,
      miuixMonet: miuixMonet ?? this.miuixMonet,
      barBlur: barBlur ?? this.barBlur,
      liquidGlass: liquidGlass ?? this.liquidGlass,
      predictiveBack: predictiveBack ?? this.predictiveBack,
    );
  }

  @override
  InterfaceStyleTheme lerp(InterfaceStyleTheme? other, double t) {
    if (other == null || t < 0.5) {
      return this;
    }
    return other;
  }

  @override
  bool operator ==(Object other) {
    return other is InterfaceStyleTheme &&
        other.style == style &&
        other.miuixMonet == miuixMonet &&
        other.barBlur == barBlur &&
        other.liquidGlass == liquidGlass &&
        other.predictiveBack == predictiveBack;
  }

  @override
  int get hashCode =>
      Object.hash(style, miuixMonet, barBlur, liquidGlass, predictiveBack);
}

extension InterfaceStyleContext on BuildContext {
  InterfaceStyleTheme get interfaceStyle =>
      Theme.of(this).extension<InterfaceStyleTheme>() ??
      const InterfaceStyleTheme();
}

const _miuixDialogCorner = 32.0;
const _miuixDividerThickness = 0.75;
const _mutedAlpha = 0.38;

extension InterfaceStyleThemeData on ThemeData {
  ThemeData withInterfaceStyle(InterfaceStyleTheme interfaceStyle) {
    final themed = copyWith(
      extensions: [
        for (final extension in extensions.values)
          if (extension is! InterfaceStyleTheme) extension,
        interfaceStyle,
      ],
    );
    return interfaceStyle.isMiuix
        ? themed._withMiuixComponents(monet: interfaceStyle.miuixMonet)
        : themed;
  }

  ThemeData _withMiuixComponents({required bool monet}) {
    final colors = colorScheme;
    ({Color track, Color thumb}) switchColors(Set<WidgetState> states) =>
        miuixSwitchColors(
          colors,
          selected: states.contains(WidgetState.selected),
          enabled: !states.contains(WidgetState.disabled),
          monet: monet,
        );
    return copyWith(
      splashFactory: NoSplash.splashFactory,
      highlightColor: colors.onSurface.withValues(alpha: 0.1),
      focusColor: colors.onSurface.withValues(alpha: 0.08),
      hoverColor: colors.onSurface.withValues(alpha: 0.06),
      scaffoldBackgroundColor: colors.surface,
      canvasColor: colors.surface,
      cardTheme: cardTheme.copyWith(
        color: colors.surfaceContainer,
        elevation: 0,
      ),
      dialogTheme: dialogTheme.copyWith(
        backgroundColor: colors.surfaceContainer,
        shape: AppShape.all(_miuixDialogCorner),
      ),
      bottomSheetTheme: bottomSheetTheme.copyWith(
        backgroundColor: colors.surfaceContainer,
        modalBackgroundColor: colors.surfaceContainer,
      ),
      dividerTheme: dividerTheme.copyWith(
        color: colors.outlineVariant,
        thickness: _miuixDividerThickness,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => switchColors(states).thumb,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => switchColors(states).track,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
    );
  }
}

/// A Miuix switch: on, a primary track under an onPrimary thumb; off, the
/// stock palette's grey track and white thumb, or Monet's outline track under
/// a faint one. Disabled colors settle 38% of the way out of the surface.
({Color track, Color thumb}) miuixSwitchColors(
  ColorScheme colors, {
  required bool selected,
  required bool monet,
  bool enabled = true,
}) {
  final Color track;
  final Color thumb;
  if (selected) {
    track = colors.primary;
    thumb = colors.onPrimary;
  } else if (monet) {
    track = colors.outlineVariant;
    thumb = colors.onSurface.withValues(alpha: _mutedAlpha);
  } else {
    track = colors.secondary;
    thumb = colors.onSecondary;
  }
  if (enabled) {
    return (track: track, thumb: thumb);
  }
  Color dim(Color color) => Color.alphaBlend(
    color.withValues(alpha: color.a * _mutedAlpha),
    colors.surface,
  );
  return (track: dim(track), thumb: dim(thumb));
}

/// The stock Miuix palette (compose-miuix `lightColorScheme`/`darkColorScheme`)
/// mapped onto Material roles: pages on `surface`, cards on `surfaceContainer`.
ColorScheme miuixColorScheme(Brightness brightness) {
  return switch (brightness) {
    Brightness.light => _miuixLight,
    Brightness.dark => _miuixDark,
  };
}

const _miuixLight = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF3482FF),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFF5D9BFF),
  onPrimaryContainer: Color(0xFFFFFFFF),
  primaryFixed: Color(0xFF3482FF),
  primaryFixedDim: Color(0xFF5D9BFF),
  onPrimaryFixed: Color(0xFFFFFFFF),
  onPrimaryFixedVariant: Color(0xFFAECDFF),
  secondary: Color(0xFFE6E6E6),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFF0F0F0),
  onSecondaryContainer: Color(0xFF303030),
  secondaryFixed: Color(0xFFE6E6E6),
  secondaryFixedDim: Color(0xFFF0F0F0),
  onSecondaryFixed: Color(0xFF303030),
  onSecondaryFixedVariant: Color(0xFFA8A8A8),
  tertiary: Color(0xFF3482FF),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFEAF2FF),
  onTertiaryContainer: Color(0xFF3482FF),
  tertiaryFixed: Color(0xFFEAF2FF),
  tertiaryFixedDim: Color(0xFFEAF2FF),
  onTertiaryFixed: Color(0xFF3482FF),
  onTertiaryFixedVariant: Color(0xFF3482FF),
  error: Color(0xFFE94634),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFDF6F4),
  onErrorContainer: Color(0xFF410002),
  surface: Color(0xFFF7F7F7),
  onSurface: Color(0xFF000000),
  surfaceDim: Color(0xFFF7F7F7),
  surfaceBright: Color(0xFFFFFFFF),
  surfaceContainerLowest: Color(0xFFFFFFFF),
  surfaceContainerLow: Color(0xFFFFFFFF),
  surfaceContainer: Color(0xFFFFFFFF),
  surfaceContainerHigh: Color(0xFFE8E8E8),
  surfaceContainerHighest: Color(0xFFE8E8E8),
  onSurfaceVariant: Color(0x99000000),
  outline: Color(0xFFD9D9D9),
  outlineVariant: Color(0xFFE0E0E0),
  shadow: Color(0xFF000000),
  scrim: Color(0x4D000000),
  inverseSurface: Color(0xFF242424),
  onInverseSurface: Color(0xFFF2F2F2),
  inversePrimary: Color(0xFF277AF7),
  surfaceTint: Color(0x00000000),
);

const _miuixDark = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF277AF7),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFF338FE4),
  onPrimaryContainer: Color(0xFFFFFFFF),
  primaryFixed: Color(0xFF277AF7),
  primaryFixedDim: Color(0xFF338FE4),
  onPrimaryFixed: Color(0xFFFFFFFF),
  onPrimaryFixedVariant: Color(0xFF99C7F1),
  secondary: Color(0xFF505050),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFF434343),
  onSecondaryContainer: Color(0xFFD9D9D9),
  secondaryFixed: Color(0xFF505050),
  secondaryFixedDim: Color(0xFF434343),
  onSecondaryFixed: Color(0xFFD9D9D9),
  onSecondaryFixedVariant: Color(0xFF959595),
  tertiary: Color(0xFF4788FF),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFF2B3B54),
  onTertiaryContainer: Color(0xFF4788FF),
  tertiaryFixed: Color(0xFF2B3B54),
  tertiaryFixedDim: Color(0xFF2B3B54),
  onTertiaryFixed: Color(0xFF4788FF),
  onTertiaryFixedVariant: Color(0xFF4788FF),
  error: Color(0xFFF12522),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFF2E0603),
  onErrorContainer: Color(0xFFFFDAD6),
  surface: Color(0xFF000000),
  onSurface: Color(0xFFF2F2F2),
  surfaceDim: Color(0xFF000000),
  surfaceBright: Color(0xFF2D2D2D),
  surfaceContainerLowest: Color(0xFF000000),
  surfaceContainerLow: Color(0xFF242424),
  surfaceContainer: Color(0xFF242424),
  surfaceContainerHigh: Color(0xFF242424),
  surfaceContainerHighest: Color(0xFF2D2D2D),
  onSurfaceVariant: Color(0x80FFFFFF),
  outline: Color(0xFF404040),
  outlineVariant: Color(0xFF393939),
  shadow: Color(0xFF000000),
  scrim: Color(0x99000000),
  inverseSurface: Color(0xFFF7F7F7),
  onInverseSurface: Color(0xFF000000),
  inversePrimary: Color(0xFF3482FF),
  surfaceTint: Color(0x00000000),
);
