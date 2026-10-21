import 'dart:async';
import 'dart:io';

import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/common/system_fonts.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/font_family.dart';
import 'package:fl_clash/views/theme.dart';
import 'package:fl_clash/views/theme_preview.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(1400, 2400);
  });

  tearDown(() => container.dispose());

  Future<void> pumpThemeView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ThemeView()),
      ),
    );
    await tester.pumpAndSettle();
  }

  ThemeProps readTheme() => container.read(themeSettingProvider);

  group('theme mode', () {
    testWidgets('defaults to following the system', (tester) async {
      await pumpThemeView(tester);

      expect(readTheme().themeMode, ThemeMode.system);
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
    Finder swatch(int color) => find.byWidgetPredicate(
      (widget) =>
          widget is Semantics && widget.properties.label == Color(color).hex,
    );

    testWidgets('starts on blue among the system colors', (tester) async {
      container
          .read(themeSettingProvider.notifier)
          .update((_) => defaultThemeProps);
      await pumpThemeView(tester);

      expect(readTheme().primaryColor, 0xFF007AFF);
      for (final color in defaultPrimaryColors) {
        expect(swatch(color), findsOneWidget);
      }
      expect(find.byTooltip('Reset'), findsNothing);
    });

    testWidgets('picks a color and the style of its scheme', (tester) async {
      await pumpThemeView(tester);

      await tester.tap(swatch(0xFFCB30E0));
      await tester.pumpAndSettle();
      expect(readTheme().primaryColor, 0xFFCB30E0);

      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics && widget.properties.label == 'Follow system',
        ),
      );
      await tester.pumpAndSettle();
      expect(readTheme().primaryColor, isNull);

      await tester.tap(find.text('Color style'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Soft').last);
      await tester.pumpAndSettle();
      expect(readTheme().colorStyle, ColorStyle.soft);
    });

    testWidgets('deletes a color from its context menu', (tester) async {
      await pumpThemeView(tester);
      await tester.tap(swatch(0xFFFF8D28));
      await tester.pumpAndSettle();

      await tester.longPress(swatch(0xFFFF8D28));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(readTheme().primaryColors, isNot(contains(0xFFFF8D28)));
      expect(readTheme().primaryColor, defaultPrimaryColor);
      expect(swatch(0xFFFF8D28), findsNothing);
    });

    Future<void> editColor(WidgetTester tester, int color, String hex) async {
      await tester.longPress(swatch(color));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(HexColorField),
          matching: find.byType(TextField),
        ),
        hex,
      );
      await tester.pump();
      await tester.tap(find.byTooltip('Confirm'));
      await tester.pumpAndSettle();
    }

    testWidgets('edits a color in place from its context menu', (tester) async {
      await pumpThemeView(tester);
      await tester.tap(swatch(0xFFFF8D28));
      await tester.pumpAndSettle();
      final index = readTheme().primaryColors.indexOf(0xFFFF8D28);

      await editColor(tester, 0xFFFF8D28, '123456');

      expect(readTheme().primaryColors, isNot(contains(0xFFFF8D28)));
      expect(readTheme().primaryColors[index], 0xFF123456);
      expect(readTheme().primaryColor, 0xFF123456);
      expect(swatch(0xFF123456), findsOneWidget);
    });

    testWidgets('merges a color edited into one already listed', (
      tester,
    ) async {
      await pumpThemeView(tester);
      await tester.tap(swatch(0xFF007AFF));
      await tester.pumpAndSettle();
      final count = readTheme().primaryColors.length;

      await editColor(tester, 0xFFCB30E0, '007AFF');

      expect(readTheme().primaryColors, hasLength(count - 1));
      expect(readTheme().primaryColors, isNot(contains(0xFFCB30E0)));
      expect(readTheme().primaryColor, 0xFF007AFF);
      expect(swatch(0xFF007AFF), findsOneWidget);
    });

    testWidgets('adds a custom color once and selects it', (tester) async {
      await pumpThemeView(tester);
      final count = readTheme().primaryColors.length;

      for (var i = 0; i < 2; i++) {
        await tester.tap(find.byTooltip('Add'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.descendant(
            of: find.byType(HexColorField),
            matching: find.byType(TextField),
          ),
          '123456',
        );
        await tester.pump();
        await tester.tap(find.byTooltip('Confirm'));
        await tester.pumpAndSettle();
      }

      expect(readTheme().primaryColors, hasLength(count + 1));
      expect(readTheme().primaryColors.last, 0xFF123456);
      expect(readTheme().primaryColor, 0xFF123456);
      expect(swatch(0xFF123456), findsOneWidget);
    });

    testWidgets('keeps the custom color palette clear of the edge back '
        'swipe', (tester) async {
      const size = Size(400, 860);
      container.read(viewSizeProvider.notifier).value = size;
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.view.systemGestureInsets = const FakeViewPadding(
        left: 30,
        right: 30,
      );
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(child: ThemeView()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byTooltip('Add'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byTooltip('Add'));
      await tester.pumpAndSettle();

      final pad = tester.getRect(
        find.descendant(
          of: find.byType(Palette),
          matching: find.byType(AspectRatio),
        ),
      );
      expect(pad.left, 30);
      expect(pad.right, size.width - 30);
    });
  });

  group('sidebar blur', () {
    testWidgets('starts off, with a working toggle on supported platforms', (
      tester,
    ) async {
      await pumpThemeView(tester);
      final toggle = find.text('Background blur');

      expect(readTheme().sidebarBlur, isFalse);
      if (!Platform.isMacOS && !Platform.isWindows) {
        expect(toggle, findsNothing);
        return;
      }

      expect(toggle, findsOneWidget);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(readTheme().sidebarBlur, isTrue);
    });
  });

  group('liquid glass', () {
    testWidgets('is off until a tier is chosen, and switches back', (
      tester,
    ) async {
      await pumpThemeView(tester);
      final group = find.ancestor(
        of: find.text('Liquid Glass').first,
        matching: find.byType(PreviewChoiceGroup<LiquidGlassMode>),
      );
      Finder choice(String label) =>
          find.descendant(of: group, matching: find.text(label)).last;

      expect(readTheme().liquidGlass, LiquidGlassMode.none);

      await tester.tap(choice('Standard'));
      await tester.pumpAndSettle();
      expect(readTheme().liquidGlass, LiquidGlassMode.standard);

      await tester.tap(choice('None'));
      await tester.pumpAndSettle();
      expect(readTheme().liquidGlass, LiquidGlassMode.none);
    });
  });

  group('pure black', () {
    testWidgets('switches both ways', (tester) async {
      await pumpThemeView(tester);

      expect(readTheme().pureBlack, isFalse);

      await tester.tap(find.text('Pure black'));
      await tester.pumpAndSettle();
      expect(readTheme().pureBlack, isTrue);

      await tester.tap(find.text('Standard').first);
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

      expect(readSetting().tabAnimation, TabAnimation.fade);

      await tester.tap(find.text('Slide'));
      await tester.pumpAndSettle();
      expect(readSetting().tabAnimation, TabAnimation.slide);

      await tester.tap(find.text('Fade'));
      await tester.pumpAndSettle();
      expect(readSetting().tabAnimation, TabAnimation.fade);
    });

    testWidgets('the preview switches to the destination tapped', (
      tester,
    ) async {
      await pumpThemeView(tester);
      Finder inPreview(Type type) => find.descendant(
        of: find.byType(ThemeLivePreview),
        matching: find.byType(type),
      );
      int selected() =>
          tester.widget<MiniScreen>(inPreview(MiniScreen)).selected;

      for (final destination in [2, 1]) {
        await tester.tap(inPreview(GestureDetector).at(destination));
        await tester.pumpAndSettle();
        expect(selected(), destination);
      }
    });
  });

  group('font family', () {
    setUp(() {
      final reader = systemFontFamiliesReader;
      addTearDown(() => systemFontFamiliesReader = reader);
      systemFontFamiliesReader = () async => ['Alpha Sans', 'Beta Serif'];
    });

    Finder inPage(String text) => find.descendant(
      of: find.byType(FontFamilyView),
      matching: find.text(text),
    );

    final fontsIllustration = find.descendant(
      of: find.byType(FontFamilyView),
      matching: find.byKey(const ValueKey(NullStatusIllustration.fonts)),
    );

    String? previewFamilyOf(WidgetTester tester, String text) =>
        DefaultTextStyle.of(tester.element(inPage(text))).style.fontFamily;

    Future<void> pumpSettled(WidgetTester tester) async {
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
    }

    Future<void> openFonts(WidgetTester tester) async {
      await tester.tap(find.text('Aa').first);
      await tester.pumpAndSettle();
      await pumpSettled(tester);
    }

    testWidgets('picks an installed font on its page and back to default', (
      tester,
    ) async {
      await pumpThemeView(tester);

      expect(readTheme().fontFamily, isNull);
      expect(find.text('Default'), findsOneWidget);

      await openFonts(tester);
      expect(
        SheetProvider.of(tester.element(find.byType(FontFamilyView)))?.type,
        SheetType.sideSheet,
      );
      expect(inPage('Installed fonts'), findsOneWidget);
      expect(previewFamilyOf(tester, 'Beta Serif'), 'Beta Serif');

      await tester.tap(inPage('Beta Serif'));
      await tester.pumpAndSettle();
      expect(readTheme().fontFamily, 'Beta Serif');
      expect(find.byType(FontFamilyView), findsOneWidget);

      await tester.tap(inPage('Default'));
      await tester.pumpAndSettle();
      expect(readTheme().fontFamily, isNull);
    });

    testWidgets('lists the fonts as the sheet opens and gives the names '
        'their fonts once it has stopped', (tester) async {
      var reads = 0;
      systemFontFamiliesReader = () async {
        reads++;
        return ['Arrival Sans'];
      };
      await pumpThemeView(tester);

      await tester.tap(find.text('Aa').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 16));
      expect(reads, 1);
      expect(fontsIllustration, findsNothing);
      expect(inPage('Arrival Sans'), findsOneWidget);
      expect(
        isRouteMoving(tester.element(find.byType(FontFamilyView))),
        isTrue,
      );
      expect(previewFamilyOf(tester, 'Arrival Sans'), isNot('Arrival Sans'));

      await pumpSettled(tester);
      expect(previewFamilyOf(tester, 'Arrival Sans'), 'Arrival Sans');
    });

    testWidgets('shows the loading illustration while the fonts take long', (
      tester,
    ) async {
      final families = Completer<List<String>>();
      systemFontFamiliesReader = () => families.future;
      await pumpThemeView(tester);

      await tester.tap(find.text('Aa').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(fontsIllustration, findsNothing);

      await tester.pump(const Duration(milliseconds: 300));
      expect(fontsIllustration, findsOneWidget);
      expect(inPage('Default'), findsNothing);

      families.complete(['Alpha Sans']);
      await pumpSettled(tester);
      expect(inPage('Alpha Sans'), findsOneWidget);
      expect(fontsIllustration, findsNothing);
    });

    testWidgets('previews the chosen font on its card', (tester) async {
      container
          .read(themeSettingProvider.notifier)
          .update((state) => state.copyWith(fontFamily: 'Beta Serif'));
      await pumpThemeView(tester);

      expect(
        tester.widget<Text>(find.text('Beta Serif')).style?.fontFamily,
        'Beta Serif',
      );
      expect(
        tester.widget<Text>(find.text('Aa').first).style?.fontFamily,
        'Beta Serif',
      );
    });

    testWidgets('gives each name its own font one per frame', (tester) async {
      const families = ['Preview One', 'Preview Two', 'Preview Three'];
      var loaded = false;
      systemFontFamiliesReader = () async {
        loaded = true;
        return families;
      };
      await pumpThemeView(tester);
      await tester.tap(find.text('Aa').first);
      for (var i = 0; i < 20 && !loaded; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pump(const Duration(seconds: 1));

      int shown() => families
          .where(
            (family) =>
                inPage(family).evaluate().isNotEmpty &&
                previewFamilyOf(tester, family) == family,
          )
          .length;
      final counts = [shown()];
      while (counts.last < families.length && counts.length < 10) {
        await tester.pump();
        counts.add(shown());
      }

      expect(counts.first, lessThan(families.length));
      expect(counts.last, families.length);
      for (var i = 1; i < counts.length; i++) {
        expect(counts[i] - counts[i - 1], lessThanOrEqualTo(1));
      }
    });

    testWidgets('still offers the default when no font can be listed', (
      tester,
    ) async {
      systemFontFamiliesReader = () async => throw const OSError('fc', 1);
      await pumpThemeView(tester);

      await openFonts(tester);

      expect(inPage('Default'), findsOneWidget);
      expect(inPage('Installed fonts'), findsNothing);
      expect(fontsIllustration, findsNothing);
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
}
