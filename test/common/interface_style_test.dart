import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _miuix = InterfaceStyleTheme(style: InterfaceStyle.miuix);

ProviderContainer _container(InterfaceStyleTheme interfaceStyle) {
  final container = ProviderContainer(
    overrides: [interfaceStyleThemeProvider.overrideWithValue(interfaceStyle)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('interface settings stay Material away from Android', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container
        .read(themeSettingProvider.notifier)
        .update(
          (state) => state.copyWith(
            interfaceStyle: InterfaceStyle.miuix,
            liquidGlass: true,
          ),
        );

    expect(container.read(interfaceStyleThemeProvider).isMiuix, isFalse);
    expect(container.read(interfaceStyleThemeProvider).liquidGlass, isFalse);
  });

  test('Android carries each interface setting into the extension', () {
    const base = ThemeProps();
    final cases = [
      (base, const InterfaceStyleTheme(predictiveBack: true)),
      (
        base.copyWith(interfaceStyle: InterfaceStyle.miuix),
        const InterfaceStyleTheme(
          style: InterfaceStyle.miuix,
          predictiveBack: true,
        ),
      ),
      (
        base.copyWith(miuixMonet: true),
        const InterfaceStyleTheme(miuixMonet: true, predictiveBack: true),
      ),
      (
        base.copyWith(barBlur: true),
        const InterfaceStyleTheme(barBlur: true, predictiveBack: true),
      ),
      (
        base.copyWith(liquidGlass: true),
        const InterfaceStyleTheme(liquidGlass: true, predictiveBack: true),
      ),
      (base.copyWith(predictiveBack: false), const InterfaceStyleTheme()),
    ];
    for (final (props, expected) in cases) {
      expect(
        interfaceStyleThemeOf(props, isAndroid: true),
        expected,
        reason: '$props',
      );
      expect(
        interfaceStyleThemeOf(props, isAndroid: false),
        const InterfaceStyleTheme(),
        reason: '$props',
      );
    }
  });

  test('Miuix without Monet uses the stock Miuix palette', () {
    final container = _container(_miuix);

    expect(
      container.read(genColorSchemeProvider(Brightness.light)),
      miuixColorScheme(Brightness.light),
    );
    expect(
      container.read(genColorSchemeProvider(Brightness.dark)),
      miuixColorScheme(Brightness.dark),
    );
    expect(miuixColorScheme(Brightness.light).surface, const Color(0xFFF7F7F7));
    expect(
      miuixColorScheme(Brightness.light).surfaceContainer,
      const Color(0xFFFFFFFF),
    );
    expect(miuixColorScheme(Brightness.dark).surface, const Color(0xFF000000));
  });

  test('Miuix with Monet and explicit colors keep the seeded scheme', () {
    const color = Color(0xFF00897B);
    final container = _container(_miuix);
    final variant = container.read(themeSettingProvider).schemeVariant;
    final seeded = ColorScheme.fromSeed(
      seedColor: color,
      brightness: Brightness.light,
      dynamicSchemeVariant: variant,
    );

    expect(
      container.read(genColorSchemeProvider(Brightness.light, color: color)),
      seeded,
    );

    container
        .read(themeSettingProvider.notifier)
        .update(
          (state) =>
              state.copyWith(miuixMonet: true, primaryColor: color.toARGB32()),
        );
    expect(container.read(genColorSchemeProvider(Brightness.light)), seeded);
  });

  test('the extension snaps between sides and replaces an earlier copy', () {
    const glass = InterfaceStyleTheme(liquidGlass: true);
    expect(_miuix.lerp(glass, 0.4), _miuix);
    expect(_miuix.lerp(glass, 0.6), glass);
    expect(_miuix.lerp(null, 0.9), _miuix);
    expect(
      _miuix.copyWith(barBlur: true, predictiveBack: true),
      const InterfaceStyleTheme(
        style: InterfaceStyle.miuix,
        barBlur: true,
        predictiveBack: true,
      ),
    );

    final theme = ThemeData()
        .withInterfaceStyle(glass)
        .withInterfaceStyle(_miuix);
    expect(theme.extension<InterfaceStyleTheme>(), _miuix);
    expect(
      theme.extensions.values.whereType<InterfaceStyleTheme>(),
      hasLength(1),
    );
  });

  testWidgets('context reads Material when no extension is installed', (
    tester,
  ) async {
    late InterfaceStyleTheme plain;
    late InterfaceStyleTheme styled;
    await tester.pumpWidget(
      Column(
        children: [
          Builder(
            builder: (context) {
              plain = context.interfaceStyle;
              return const SizedBox.shrink();
            },
          ),
          Theme(
            data: ThemeData().withInterfaceStyle(_miuix),
            child: Builder(
              builder: (context) {
                styled = context.interfaceStyle;
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );

    expect(plain, const InterfaceStyleTheme());
    expect(styled.isMiuix, isTrue);
  });
}
