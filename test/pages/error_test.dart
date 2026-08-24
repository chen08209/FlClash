import 'package:fl_clash/pages/error.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

final _stack = StackTrace.fromString('#0 boot (package:fl_clash/main.dart:1)');

Widget _screen({ThemeData? theme}) {
  return MaterialApp(
    theme: theme,
    home: InitErrorScreen(error: StateError('boot failed'), stack: _stack),
  );
}

void main() {
  testWidgets('shows the error and its stack trace', (tester) async {
    await tester.pumpWidget(_screen());

    expect(find.text('Init Failed'), findsOneWidget);
    expect(find.text('Error Details:'), findsOneWidget);
    expect(find.text('Stack Trace:'), findsOneWidget);
    expect(
      find.text(StateError('boot failed').toString()),
      findsOneWidget,
      reason: 'the raw error must stay readable when nothing else works',
    );
    expect(find.text(_stack.toString()), findsOneWidget);
  });

  testWidgets('renders in both brightness modes', (tester) async {
    for (final brightness in Brightness.values) {
      await tester.pumpWidget(
        _screen(theme: ThemeData(brightness: brightness)),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(InitErrorScreen), findsOneWidget);
    }
  });

  testWidgets('copies the error and stack trace to the clipboard', (
    tester,
  ) async {
    final copied = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied.add((call.arguments as Map)['text'] as String);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await tester.pumpWidget(_screen());
    await tester.tap(find.text('Copy Details'));
    await tester.pump();

    expect(copied, hasLength(1));
    expect(copied.single, contains('boot failed'));
    expect(copied.single, contains(_stack.toString()));
    expect(find.text('Error details copied to clipboard'), findsOneWidget);
  });
}
