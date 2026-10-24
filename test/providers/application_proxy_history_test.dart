import 'dart:async';

import 'package:fl_clash/common/preferences.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/application_proxy.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/preferences.dart';

const _browser = (process: 'browser', path: '/apps/browser');
const _editor = (process: 'editor', path: '/apps/editor');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() async {
    await mockPreferences();
    container = ProviderContainer();
    globalState.container = container;
  });

  tearDown(() => container.dispose());

  test('observed apps survive a new provider container', () async {
    await container
        .read(applicationProxyHistoryProvider.notifier)
        .remember([_browser]);

    container.dispose();
    container = ProviderContainer();
    globalState.container = container;

    expect(
      await container.read(applicationProxyHistoryProvider.future),
      [_browser],
    );
  });

  test('concurrent discoveries retain every app without duplicates', () async {
    final history = container.read(applicationProxyHistoryProvider.notifier);
    await Future.wait([
      history.remember([_browser]),
      history.remember([_editor, _browser]),
      history.remember(const [(process: '', path: '')]),
    ]);

    expect(
      container.read(applicationProxyHistoryProvider).requireValue,
      unorderedEquals([_browser, _editor]),
    );
    expect(
      await preferences.getApplicationProxyHistory(),
      unorderedEquals([_browser, _editor]),
    );
  });

  test('unreadable cache entries do not discard valid applications', () async {
    await mockPreferences({
      'applicationProxyHistory':
          '[null,{"process":"browser","path":"/apps/browser"},'
          '{"process":42,"path":"/invalid"}]',
    });

    expect(
      await container.read(applicationProxyHistoryProvider.future),
      [_browser],
    );
  });

  test('request events record apps without an application panel', () async {
    final recorded = Completer<void>();
    container.listen(applicationProxyHistoryProvider, (_, next) {
      if (next.value?.contains(_browser) == true && !recorded.isCompleted) {
        recorded.complete();
      }
    });
    container.listen(requestsProvider, (_, _) {});
    container.read(requestsProvider.notifier).addRequest(
      TrackerInfo(
        id: 'closed-before-opening-panel',
        start: DateTime.utc(2026, 10, 24),
        metadata: const Metadata(process: 'browser', processPath: '/apps/browser'),
        chains: const ['DIRECT'],
        rule: 'MATCH',
        rulePayload: '',
      ),
    );

    await recorded.future;
    expect(
      container.read(applicationProxyHistoryProvider).requireValue,
      contains(_browser),
    );
  });
}
