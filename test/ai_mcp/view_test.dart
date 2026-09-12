import 'package:fl_clash/ai_mcp/service.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/manager/ai_mcp_manager.dart';
import 'package:fl_clash/providers/ai_mcp.dart';
import 'package:fl_clash/views/ai_mcp.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';
import 'helpers.dart';

void main() {
  testWidgets(
    'unlock requires exactly three seconds and a manual confirmation; cancel grants nothing',
    (tester) async {
      bool? result;
      await tester.pumpWidget(
        TestApp(
          includeNavigatorKey: false,
          child: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await showDialog<bool>(
                    context: context,
                    builder: (_) => const AiMcpUnlockDialog(),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('open'));
      await tester.pump();
      final confirm = find.byKey(const Key('ai-mcp-confirm-unlock'));
      expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
      await tester.pump(const Duration(milliseconds: 2999));
      expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
      await tester.pump(const Duration(milliseconds: 1));
      expect(tester.widget<FilledButton>(confirm).onPressed, isNotNull);
      expect(result, isNull);
      await tester.tap(confirm);
      await tester.pumpAndSettle();
      expect(result, true);
      result = null;
      await tester.tap(find.text('open'));
      await tester.pump();
      expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
      final context = tester.element(confirm);
      await tester.tap(find.text(context.appLocalizations.cancel));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));
      expect(result, false);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'page copies usable secret config, unlocks, relocks, and rejects approval invalidated while dialog open',
    (tester) async {
      final service = AiMcpService(
        store: MemoryAiMcpStore(),
        backend: FakeAiMcpBackend(),
      );
      await tester.runAsync(() async {
        await service.initialize();
        await service.setPort(await availableMcpPort());
        await service.setEnabled(true);
      });
      addTearDown(service.dispose);
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
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
      await tester.pumpWidget(
        TestApp(
          includeNavigatorKey: false,
          overrides: [aiMcpServiceProvider.overrideWithValue(service)],
          child: const AiMcpView(),
        ),
      );
      await tester.pumpAndSettle();
      final copy = find.byKey(const Key('ai-mcp-copy'));
      await tester.scrollUntilVisible(
        copy,
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(copy);
      await tester.pump();
      expect(copied, service.connectionConfig);
      expect(copied, contains('Bearer '));
      final gate = find.byKey(const Key('ai-mcp-gate'));
      await tester.scrollUntilVisible(
        gate,
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(gate);
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      expect(service.advanced, false);
      await tester.tap(find.byKey(const Key('ai-mcp-confirm-unlock')));
      await tester.pumpAndSettle();
      expect(service.advanced, true);
      await tester.tap(gate);
      await tester.pump();
      expect(service.advanced, false);
      await tester.tap(gate);
      await tester.pump();
      service.lock();
      await tester.pump(const Duration(seconds: 3));
      await tester.tap(find.byKey(const Key('ai-mcp-confirm-unlock')));
      await tester.pumpAndSettle();
      expect(service.advanced, false);
      await tester.runAsync(() => service.setEnabled(false));
    },
  );

  testWidgets(
    'local storage errors visible and manager teardown relocks without reading disposed ref',
    (tester) async {
      final store = MemoryAiMcpStore()..fail = true;
      final service = AiMcpService(store: store, backend: FakeAiMcpBackend());
      addTearDown(service.dispose);
      await tester.pumpWidget(
        TestApp(
          includeNavigatorKey: false,
          overrides: [aiMcpServiceProvider.overrideWithValue(service)],
          child: const AiMcpManager(child: AiMcpView()),
        ),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(AiMcpView));
      expect(
        find.text(context.appLocalizations.aiMcpStorageError),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      expect(service.enabled, false);
      expect(service.advanced, false);
      expect(tester.takeException(), isNull);
    },
  );
}
