import 'package:fl_clash/common/theme.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ListItem.input limits dialog text by maxLength', (tester) async {
    String? changedValue;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          viewSizeProvider.overrideWithBuild((_, _) => const Size(1200, 1000)),
        ],
        child: _TestApp(
          child: Scaffold(
            body: ListItem.input(
              title: const Text('Port'),
              delegate: InputDelegate(
                title: 'Port',
                value: '',
                maxLength: 5,
                onChanged: (value) {
                  changedValue = value;
                },
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Port'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '123456789');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(changedValue, '12345');
  });

  testWidgets('ListInputPage reorders using final insertion index', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: _TestApp(
          child: ListInputPage(
            title: 'Items',
            items: ['a', 'b', 'c'],
            titleBuilder: _textBuilder,
          ),
        ),
      ),
    );

    final listView = tester.widget<ReorderableListView>(
      find.byType(ReorderableListView),
    );

    listView.onReorderItem!(0, 2);
    await tester.pump();

    expect(_top(tester, 'b'), lessThan(_top(tester, 'c')));
    expect(_top(tester, 'c'), lessThan(_top(tester, 'a')));
  });
}

Widget _textBuilder(String value) {
  return Text(value);
}

double _top(WidgetTester tester, String text) {
  return tester.getTopLeft(find.text(text)).dy;
}

class _TestApp extends StatelessWidget {
  final Widget child;

  const _TestApp({required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        return child!;
      },
      home: child,
    );
  }
}
