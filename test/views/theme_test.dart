import 'dart:io';

import 'package:fl_clash/common/feature.dart';
import 'package:fl_clash/common/interface_style.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/theme.dart';
import 'package:fl_clash/views/theme_preview.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

InterfaceStyleTheme _androidInterfaceStyle(Ref ref) =>
    interfaceStyleThemeOf(ref.watch(themeSettingProvider), isAndroid: true);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  void useContainer({List<Override> overrides = const []}) {
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        ...overrides,
      ],
    );
    container.listen(themeSettingProvider, (_, _) {});
    container.listen(appSettingProvider, (_, _) {});
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(1400, 2400);
  }

  setUp(useContainer);

  tearDown(() => container.dispose());

  Future<void> pumpThemeView(WidgetTester tester, {bool? isAndroid}) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(child: ThemeView(isAndroid: isAndroid)),
      ),
    );
    await tester.pumpAndSettle();
  }

  ThemeProps readTheme() => container.read(themeSettingProvider);

  void updateTheme(ThemeProps Function(ThemeProps state) update) {
    container.read(themeSettingProvider.notifier).update(update);
  }

  MiniScreen livePreview(WidgetTester tester) {
    return tester.widget(
      find.descendant(
        of: find.byType(ThemeLivePreview),
        matching: find.byType(MiniScreen),
      ),
    );
  }

  CommonCard choiceCard(WidgetTester tester, String label) {
    return tester.widget(
      find.ancestor(of: find.text(label), matching: find.byType(CommonCard)),
    );
  }

  Finder switchIn(String label) {
    return find.descendant(
      of: find.ancestor(of: find.text(label), matching: find.byType(ListTile)),
      matching: find.byType(CommonSwitch),
    );
  }

  Finder colorFilterAround(String label) {
    return find.ancestor(
      of: find.text(label),
      matching: find.byType(ColorFiltered),
    );
  }

  group('theme mode', () {
    testWidgets('defaults to the dark theme', (tester) async {
      await pumpThemeView(tester);

      expect(readTheme().themeMode, ThemeMode.dark);
    });

    testWidgets('switches to light and back to dark', (tester) async {
      await pumpThemeView(tester);

      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();
      expect(readTheme().themeMode, ThemeMode.light);

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      expect(readTheme().themeMode, ThemeMode.dark);

      await tester.tap(find.text('Auto'));
      await tester.pumpAndSettle();
      expect(readTheme().themeMode, ThemeMode.system);
    });
  });

  group('primary color', () {
    testWidgets('blocks the back gesture only while a color is removable', (
      tester,
    ) async {
      await pumpThemeView(tester);
      RoutePopDisposition disposition() {
        return ModalRoute.of(
          tester.element(find.byType(ThemeView)),
        )!.popDisposition;
      }

      expect(disposition(), isNot(RoutePopDisposition.doNotPop));

      await tester.longPress(find.byType(ColorSchemeBox).at(1));
      await tester.pumpAndSettle();
      expect(disposition(), RoutePopDisposition.doNotPop);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(disposition(), isNot(RoutePopDisposition.doNotPop));
    });
  });

  group('sidebar blur', () {
    testWidgets('stays hidden while the feature is off', (tester) async {
      await pumpThemeView(tester);

      expect(find.text('Sidebar blur'), findsNothing);
    });

    testWidgets('shows a working toggle only on supported platforms', (
      tester,
    ) async {
      feature = const Feature(sidebarBlur: true);
      addTearDown(() => feature = const Feature());
      await pumpThemeView(tester);
      final toggle = find.text('Sidebar blur');

      expect(readTheme().sidebarBlur, isTrue);
      if (!Platform.isMacOS && !Platform.isWindows) {
        expect(toggle, findsNothing);
        return;
      }

      expect(toggle, findsOneWidget);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(readTheme().sidebarBlur, isFalse);
    });
  });

  group('pure black', () {
    testWidgets('switches both ways', (tester) async {
      await pumpThemeView(tester);

      expect(readTheme().pureBlack, isFalse);

      await tester.tap(find.text('Pure black'));
      await tester.pumpAndSettle();
      expect(readTheme().pureBlack, isTrue);

      await tester.tap(find.text('Standard'));
      await tester.pumpAndSettle();
      expect(readTheme().pureBlack, isFalse);
    });
  });

  group('home navigation', () {
    AppSettingProps readSetting() => container.read(appSettingProvider);

    testWidgets('picks a floating or docked bottom bar', (tester) async {
      await pumpThemeView(tester);

      expect(readSetting().floatingNavigationBar, isTrue);

      await tester.tap(find.text('Docked'));
      await tester.pumpAndSettle();
      expect(readSetting().floatingNavigationBar, isFalse);

      await tester.tap(find.text('Floating'));
      await tester.pumpAndSettle();
      expect(readSetting().floatingNavigationBar, isTrue);
    });

    testWidgets('picks a sliding or fading tab switch', (tester) async {
      await pumpThemeView(tester);

      expect(readSetting().tabAnimation, TabAnimation.slide);

      await tester.tap(find.text('Fade'));
      await tester.pumpAndSettle();
      expect(readSetting().tabAnimation, TabAnimation.fade);

      await tester.tap(find.text('Slide'));
      await tester.pumpAndSettle();
      expect(readSetting().tabAnimation, TabAnimation.slide);
    });
  });

  group('text scale', () {
    testWidgets('follows the system until custom is picked', (tester) async {
      await pumpThemeView(tester);

      expect(readTheme().textScale.enable, isFalse);
      expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNull);

      await tester.tap(find.text('Custom'));
      await tester.pumpAndSettle();

      expect(readTheme().textScale.enable, isTrue);
      expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNotNull);

      await tester.tap(find.text('Follow system'));
      await tester.pumpAndSettle();

      expect(readTheme().textScale.enable, isFalse);
    });

    testWidgets('writes the scale only when the drag ends', (tester) async {
      await pumpThemeView(tester);
      await tester.tap(find.text('Custom'));
      await tester.pumpAndSettle();
      final before = readTheme().textScale.scale;

      final slider = find.byType(Slider);
      final gesture = await tester.startGesture(tester.getCenter(slider));
      await gesture.moveBy(const Offset(120, 0));
      await tester.pump();
      expect(readTheme().textScale.scale, before);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(readTheme().textScale.scale, isNot(before));
    });

    testWidgets('resets a custom scale to 100%', (tester) async {
      container
          .read(themeSettingProvider.notifier)
          .update(
            (state) => state.copyWith.textScale(enable: true, scale: 1.2),
          );

      await pumpThemeView(tester);

      expect(find.text('120%'), findsOneWidget);

      await tester.tap(find.byTooltip('Reset').last);
      await tester.pumpAndSettle();

      expect(readTheme().textScale.scale, 1);
      expect(find.text('100%'), findsOneWidget);
    });
  });

  group('off Android', () {
    testWidgets('hides the interface style settings', (tester) async {
      await pumpThemeView(tester, isAndroid: false);

      expect(find.text('Interface style'), findsNothing);
      expect(find.text('Effects'), findsNothing);
      expect(find.text('Enable Monet colors'), findsNothing);
    });

    testWidgets('ignores a stored Miuix style', (tester) async {
      updateTheme(
        (state) => state.copyWith(
          interfaceStyle: InterfaceStyle.miuix,
          liquidGlass: true,
        ),
      );

      await pumpThemeView(tester, isAndroid: false);

      expect(livePreview(tester).interfaceStyle, const InterfaceStyleTheme());
      expect(find.byType(ColorSchemeBox), findsWidgets);
      expect(choiceCard(tester, 'Pure black').onPressed, isNotNull);
    });
  });

  group('on Android', () {
    setUp(() {
      container.dispose();
      useContainer(
        overrides: [
          interfaceStyleThemeProvider.overrideWith(_androidInterfaceStyle),
        ],
      );
    });

    List<MiniScreen> styleChoices(WidgetTester tester) {
      return tester
          .widgetList<MiniScreen>(
            find.descendant(
              of: find.byType(PreviewChoiceGroup<InterfaceStyle>),
              matching: find.byType(MiniScreen),
            ),
          )
          .toList();
    }

    testWidgets('picks the Material or the Miuix style', (tester) async {
      await pumpThemeView(tester, isAndroid: true);

      expect(readTheme().interfaceStyle, InterfaceStyle.material);

      await tester.tap(find.text('Miuix'));
      await tester.pumpAndSettle();
      expect(readTheme().interfaceStyle, InterfaceStyle.miuix);

      await tester.tap(find.text('Material'));
      await tester.pumpAndSettle();
      expect(readTheme().interfaceStyle, InterfaceStyle.material);
    });

    testWidgets('draws each style choice in its own look', (tester) async {
      await pumpThemeView(tester, isAndroid: true);

      final [material, miuix] = styleChoices(tester);
      expect(material.interfaceStyle.style, InterfaceStyle.material);
      expect(miuix.interfaceStyle.style, InterfaceStyle.miuix);
      expect(miuix.colorScheme, miuixColorScheme(Brightness.light));
      expect(material.colorScheme, isNot(miuix.colorScheme));

      updateTheme((state) => state.copyWith(miuixMonet: true));
      await tester.pumpAndSettle();

      final [_, monet] = styleChoices(tester);
      expect(monet.colorScheme, material.colorScheme);
    });

    testWidgets('previews the Miuix page with a glass bar', (tester) async {
      updateTheme(
        (state) => state.copyWith(
          interfaceStyle: InterfaceStyle.miuix,
          liquidGlass: true,
        ),
      );

      await pumpThemeView(tester, isAndroid: true);

      final screen = livePreview(tester);
      expect(screen.interfaceStyle.isMiuix, isTrue);
      expect(screen.interfaceStyle.liquidGlass, isTrue);
      expect(screen.colorScheme.surface, const Color(0xFF000000));
      expect(screen.colorScheme.surfaceContainer, const Color(0xFF242424));
      expect(screen.colorScheme.primary, const Color(0xFF277AF7));
      expect(
        find.descendant(
          of: find.byType(ThemeLivePreview),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is DecoratedBox &&
                widget.decoration is ShapeDecoration &&
                (widget.decoration as ShapeDecoration).color ==
                    const Color(0xFF242424).withValues(alpha: 0.4),
          ),
        ),
        findsOneWidget,
      );
    });

    testWidgets('offers Monet only for Miuix and colors only with it', (
      tester,
    ) async {
      await pumpThemeView(tester, isAndroid: true);

      expect(find.text('Enable Monet colors'), findsNothing);
      expect(find.byType(ColorSchemeBox), findsWidgets);

      await tester.tap(find.text('Miuix'));
      await tester.pumpAndSettle();

      expect(find.text('Enable Monet colors'), findsOneWidget);
      expect(find.text('Theme color'), findsNothing);
      expect(find.byType(ColorSchemeBox), findsNothing);

      await tester.tap(find.text('Enable Monet colors'));
      await tester.pumpAndSettle();

      expect(readTheme().miuixMonet, isTrue);
      expect(find.text('Theme color'), findsOneWidget);
      expect(find.byType(ColorSchemeBox), findsWidgets);
    });

    testWidgets('disables pure black on the stock Miuix palette', (
      tester,
    ) async {
      updateTheme(
        (state) => state.copyWith(interfaceStyle: InterfaceStyle.miuix),
      );

      await pumpThemeView(tester, isAndroid: true);

      expect(choiceCard(tester, 'Pure black').onPressed, isNull);
      expect(colorFilterAround('Pure black'), findsNothing);
      await tester.tap(find.text('Pure black'));
      await tester.pumpAndSettle();
      expect(readTheme().pureBlack, isFalse);

      updateTheme((state) => state.copyWith(miuixMonet: true));
      await tester.pumpAndSettle();

      expect(choiceCard(tester, 'Pure black').onPressed, isNotNull);
      await tester.tap(find.text('Pure black'));
      await tester.pumpAndSettle();
      expect(readTheme().pureBlack, isTrue);
    });

    testWidgets('writes each effect to the theme settings', (tester) async {
      await pumpThemeView(tester, isAndroid: true);

      expect(readTheme().barBlur, isFalse);
      await tester.tap(find.text('Blur bars'));
      await tester.pumpAndSettle();
      expect(readTheme().barBlur, isTrue);

      expect(readTheme().liquidGlass, isFalse);
      await tester.tap(find.text('Liquid glass'));
      await tester.pumpAndSettle();
      expect(readTheme().liquidGlass, isTrue);

      expect(readTheme().predictiveBack, isTrue);
      await tester.tap(find.text('Predictive back'));
      await tester.pumpAndSettle();
      expect(readTheme().predictiveBack, isFalse);
    });

    testWidgets('disables liquid glass while the bar is docked', (
      tester,
    ) async {
      container
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(floatingNavigationBar: false));

      await pumpThemeView(tester, isAndroid: true);
      final glassSwitch = switchIn('Liquid glass');

      expect(tester.widget<CommonSwitch>(glassSwitch).onChanged, isNull);
      expect(colorFilterAround('Liquid glass'), findsNothing);
      await tester.tap(find.text('Liquid glass'));
      await tester.tap(glassSwitch);
      await tester.pumpAndSettle();
      expect(readTheme().liquidGlass, isFalse);

      await tester.tap(find.text('Floating'));
      await tester.pumpAndSettle();

      expect(tester.widget<CommonSwitch>(glassSwitch).onChanged, isNotNull);
      await tester.tap(find.text('Liquid glass'));
      await tester.pumpAndSettle();
      expect(readTheme().liquidGlass, isTrue);
    });
  });

  group('mini screen', () {
    final colorScheme = miuixColorScheme(Brightness.light);
    const miuix = InterfaceStyleTheme(style: InterfaceStyle.miuix);
    const glass = InterfaceStyleTheme(liquidGlass: true);

    Future<void> pumpScreen(
      WidgetTester tester, {
      required bool floatingBar,
      InterfaceStyleTheme interfaceStyle = const InterfaceStyleTheme(),
      int selected = 0,
    }) {
      return tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: 160,
              height: 300,
              child: MiniScreen(
                colorScheme: colorScheme,
                floatingBar: floatingBar,
                interfaceStyle: interfaceStyle,
                selected: selected,
              ),
            ),
          ),
        ),
      );
    }

    Finder decorated(bool Function(Decoration decoration) test) {
      return find.byWidgetPredicate(
        (widget) => widget is DecoratedBox && test(widget.decoration),
      );
    }

    final solidBar = decorated(
      (decoration) =>
          decoration is ShapeDecoration &&
          (decoration.shadows?.isNotEmpty ?? false),
    );
    final glassBar = decorated(
      (decoration) =>
          decoration is ShapeDecoration &&
          decoration.color ==
              colorScheme.surfaceContainer.withValues(alpha: 0.4),
    );
    final miuixDockedBar = decorated(
      (decoration) => decoration is BoxDecoration,
    );
    final materialDockedBar = find.byWidgetPredicate(
      (widget) =>
          widget is ColoredBox && widget.color == colorScheme.surfaceContainer,
    );

    List<Color?> colorsIn(WidgetTester tester, Finder bar) {
      return [
        for (final box in tester.widgetList<DecoratedBox>(
          find.descendant(of: bar, matching: find.byType(DecoratedBox)),
        ))
          (box.decoration as ShapeDecoration).color,
      ];
    }

    final unselected = List.filled(3, colorScheme.onSurfaceVariant);

    testWidgets('keeps the Material bars', (tester) async {
      await pumpScreen(tester, floatingBar: true);
      expect(colorsIn(tester, solidBar), [
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
        ...unselected,
      ]);

      await pumpScreen(tester, floatingBar: false);
      expect(colorsIn(tester, materialDockedBar), [
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
        ...unselected,
      ]);
    });

    testWidgets('draws the Miuix floating and docked bars', (tester) async {
      await pumpScreen(tester, floatingBar: true, interfaceStyle: miuix);
      expect(colorsIn(tester, solidBar), [
        colorScheme.primary.withValues(alpha: 0.15),
        colorScheme.primary,
        ...List.filled(3, colorScheme.onSurface),
      ]);

      await pumpScreen(tester, floatingBar: false, interfaceStyle: miuix);
      final bar = tester.widget<DecoratedBox>(miuixDockedBar);
      expect(
        bar.decoration,
        BoxDecoration(
          color: colorScheme.surface,
          border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
        ),
      );
      expect(colorsIn(tester, miuixDockedBar), [
        colorScheme.onSurface,
        ...List.filled(3, colorScheme.onSurface.withValues(alpha: 0.4)),
      ]);
    });

    testWidgets('draws a translucent glass bar only while floating', (
      tester,
    ) async {
      await pumpScreen(tester, floatingBar: true, interfaceStyle: glass);
      expect(solidBar, findsNothing);
      expect(colorsIn(tester, glassBar), [
        Colors.black.withValues(alpha: 0.1),
        colorScheme.primary,
        ...List.filled(3, colorScheme.onSurface),
      ]);

      await pumpScreen(tester, floatingBar: false, interfaceStyle: glass);
      expect(glassBar, findsNothing);
      expect(materialDockedBar, findsOneWidget);
    });

    testWidgets('groups the Miuix list page into cards', (tester) async {
      final cards = decorated(
        (decoration) =>
            decoration is ShapeDecoration &&
            decoration.color == colorScheme.surfaceContainer,
      );

      await pumpScreen(tester, floatingBar: false, selected: 1);
      expect(cards, findsNothing);

      await pumpScreen(
        tester,
        floatingBar: false,
        interfaceStyle: miuix,
        selected: 1,
      );
      expect(cards, findsNWidgets(2));
    });
  });
}
