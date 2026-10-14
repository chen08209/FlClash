import 'dart:io';

import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/pages/error.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

final _stack = StackTrace.fromString('#0 boot (package:fl_clash/main.dart:1)');

Widget _screen({
  ThemeData? theme,
  AsyncCallback? onClearData,
  AsyncCallback? onExit,
}) {
  return MaterialApp(
    theme: theme,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    supportedLocales: AppLocalizations.delegate.supportedLocales,
    home: InitErrorScreen(
      error: StateError('boot failed'),
      stack: _stack,
      onClearData: onClearData ?? () async {},
      onExit: onExit ?? () async {},
    ),
  );
}

void main() {
  testWidgets('shows the error and its stack trace', (tester) async {
    await tester.pumpWidget(_screen());
    await tester.pump();

    expect(find.text('Startup failed'), findsOneWidget);
    expect(find.text('Error details'), findsOneWidget);
    expect(find.text('Stack trace'), findsOneWidget);
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

  testWidgets('the app shell follows the system locale', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('zh', 'CN')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(
      InitErrorApp(
        error: StateError('boot failed'),
        stack: _stack,
        onClearData: () async {},
        onExit: () async {},
      ),
    );
    await tester.pump();

    expect(find.text('启动失败'), findsOneWidget);
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
    await tester.pump();
    await tester.tap(find.text('Copy'));
    await tester.pump();

    expect(copied, hasLength(1));
    expect(copied.single, contains('boot failed'));
    expect(copied.single, contains(_stack.toString()));
    expect(find.text('Copied successfully'), findsOneWidget);
  });

  testWidgets('exit leaves through the exit callback', (tester) async {
    var exits = 0;
    await tester.pumpWidget(_screen(onExit: () async => exits++));
    await tester.pump();

    await tester.tap(find.text('Exit'));
    await tester.pump();

    expect(exits, 1);
  });

  testWidgets('clear data asks first, then clears and exits', (tester) async {
    final calls = <String>[];
    await tester.pumpWidget(
      _screen(
        onClearData: () async => calls.add('clear'),
        onExit: () async => calls.add('exit'),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Clear data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(calls, isEmpty);

    await tester.tap(find.text('Clear data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(calls, [
      'clear',
      'exit',
    ], reason: 'the cleared data is only reread on the next launch');
  });

  testWidgets('a failed clear stays on the screen and says why', (
    tester,
  ) async {
    var exits = 0;
    await tester.pumpWidget(
      _screen(
        onClearData: () async => throw const FileSystemException('locked'),
        onExit: () async => exits++,
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Clear data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(exits, 0);
    expect(find.textContaining("Couldn't clear the data"), findsOneWidget);
    final exitButton = tester.widget<FilledButton>(
      find.ancestor(of: find.text('Exit'), matching: find.byType(FilledButton)),
    );
    expect(exitButton.onPressed, isNotNull);
  });
}
