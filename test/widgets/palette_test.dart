import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/theme.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Palette updates color from hue, chroma, and tone controls', (
    tester,
  ) async {
    final controller = ValueNotifier<Color>(Colors.blue);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _TestApp(
        child: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(width: 700, child: Palette(controller: controller)),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(Slider), findsNWidgets(2));
    expect(find.text('Preview'), findsOneWidget);
    expect(find.text('Primary'), findsOneWidget);
    expect(find.text('100'), findsOneWidget);

    final initial = controller.value;
    tester.widget<Slider>(find.byType(Slider).first).onChanged!(180);
    await tester.pump();
    expect(controller.value, isNot(initial));

    final hueColor = controller.value;
    tester.widget<Slider>(find.byType(Slider).last).onChanged!(8);
    await tester.pump();
    expect(controller.value, isNot(hueColor));

    await tester.tap(find.text('0'));
    await tester.pump();
    expect(controller.value.computeLuminance(), lessThan(0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Palette lays out narrow tone and preview grids', (tester) async {
    final controller = ValueNotifier<Color>(Colors.white);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _TestApp(
        child: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(width: 32, child: Palette(controller: controller)),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('0'), findsOneWidget);
    expect(find.text('100'), findsOneWidget);
    expect(find.text('Primary'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        navigatorKey: globalState.navigatorKey,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.delegate.supportedLocales,
        builder: (context, child) {
          globalState.theme = CommonTheme.of(context, 1);
          globalState.measure = Measure.of(context, 1);
          return child!;
        },
        home: child,
      ),
    );
  }
}
