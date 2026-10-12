import 'dart:io';

import 'package:fl_clash/common/feature.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
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

  Finder choice(String section, String label) => find.descendant(
    of: find.ancestor(
      of: find.text(section),
      matching: find.byType(PreviewChoiceGroup<bool>),
    ),
    matching: find.widgetWithText(CommonCard, label),
  );

  testWidgets(
    'buttons share the bottom bar card style and change independently',
    (tester) async {
      await pumpThemeView(tester);
      expect(
        tester.getTopLeft(find.text('Buttons')).dy,
        lessThan(tester.getTopLeft(find.text('Bottom bar')).dy),
      );
      final buttonFloating = choice('Buttons', 'Floating');
      final barFloating = choice('Bottom bar', 'Floating');
      expect(tester.getSize(buttonFloating), tester.getSize(barFloating));
      expect(container.read(appSettingProvider).floatingPageActions, isFalse);
      for (final floatingBar in [true, false]) {
        await tester.tap(
          choice('Bottom bar', floatingBar ? 'Floating' : 'Docked'),
        );
        await tester.pumpAndSettle();
        for (final floating in [true, false]) {
          await tester.tap(choice('Buttons', floating ? 'Floating' : 'Docked'));
          await tester.pumpAndSettle();
          final settings = container.read(appSettingProvider);
          expect(settings.floatingPageActions, floating);
          expect(settings.floatingNavigationBar, floatingBar);
          final preview = tester.widget<MiniScreen>(
            find.descendant(
              of: find.byType(ThemeLivePreview),
              matching: find.byType(MiniScreen),
            ),
          );
          expect(preview.floatingAction, floating);
          expect(preview.floatingBar, floatingBar);
        }
      }
    },
  );

  group('home navigation', () {
    AppSettingProps readSetting() => container.read(appSettingProvider);

    testWidgets('shows matched choices below the bottom bar heading', (
      tester,
    ) async {
      await pumpThemeView(tester);

      final floating = choice('Bottom bar', 'Floating');
      final docked = choice('Bottom bar', 'Docked');
      final heading = find.text('Bottom bar');
      expect(floating, findsOneWidget);
      expect(docked, findsOneWidget);
      expect(heading, findsOneWidget);
      expect(
        tester.getTopLeft(floating).dy,
        greaterThan(tester.getTopLeft(heading).dy),
      );
      expect(
        tester.getTopLeft(docked).dy,
        greaterThan(tester.getTopLeft(heading).dy),
      );
      expect(
        tester
            .widget<MiniScreen>(
              find.descendant(of: floating, matching: find.byType(MiniScreen)),
            )
            .floatingBar,
        isTrue,
      );
      expect(
        tester
            .widget<MiniScreen>(
              find.descendant(of: docked, matching: find.byType(MiniScreen)),
            )
            .floatingBar,
        isFalse,
      );
      final trailingAction = find.byWidgetPredicate(
        (widget) =>
            widget is Positioned &&
            widget.width != null &&
            widget.height != null,
      );
      expect(
        find.descendant(of: floating, matching: trailingAction),
        findsOneWidget,
      );
      expect(
        find.descendant(of: docked, matching: trailingAction),
        findsNothing,
      );
    });

    testWidgets('picks a floating or docked bottom bar', (tester) async {
      await pumpThemeView(tester);

      expect(readSetting().floatingNavigationBar, isTrue);

      await tester.tap(choice('Bottom bar', 'Docked'));
      await tester.pumpAndSettle();
      expect(readSetting().floatingNavigationBar, isFalse);

      await tester.tap(choice('Bottom bar', 'Floating'));
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
}
