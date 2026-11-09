import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:prism_ui/common_button.dart';

import '../helpers/app_paths.dart';
import '../helpers/test_app.dart';
import '../helpers/host_scaffold.dart';

class _ReleaseAdapter implements HttpClientAdapter {
  _ReleaseAdapter({required this.sums, required this.asset});

  final String sums;
  final ResponseBody Function() asset;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.uri.path.endsWith('/$releaseChecksumsName')) {
      return ResponseBody.fromString(sums, 200);
    }
    return asset();
  }

  @override
  void close({bool force = false}) {}
}

const _runningVersion = '0.8.95';

const _payload =
    '{"schemaVersion":2,"versions":[{"version":"0.8.96","tag":"v0.8.96",'
    '"date":"2026-08-16","prerelease":false,"groups":['
    '{"type":"breaking","entries":[{"id":"af20769","text":'
    '"Re-import backups"}]},'
    '{"type":"feat","entries":[{"id":"1a2b3c4","text":'
    '"Override scripts"}]}]}]}';

const _bulletsOnly =
    '<!-- flclash:changelog:begin -->\n'
    '- Override scripts\n'
    '<!-- flclash:changelog:end -->\n';

String _bodyWith(String payload) =>
    '$_bulletsOnly\n<!-- flclash:changelog:json\n$payload\n-->\n';

Map<String, dynamic> release(String? body) => <String, dynamic>{
  'tag_name': 'v0.8.96',
  'body': body,
};

Future<ProviderContainer> pumpApp(WidgetTester tester, {Locale? locale}) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  globalState.container = container;
  // appSettingProvider is autoDispose; in the app `configProvider` keeps it
  // alive, so the test has to hold a listener or edits are dropped.
  container.listen(appSettingProvider, (_, _) {}, fireImmediately: true);
  container
      .read(viewSizeProvider.notifier)
      .update((_) => const Size(1200, 800));

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TestApp(
        locale: locale,
        child: const HostScaffold(body: SizedBox.shrink()),
      ),
    ),
  );
  await tester.pump();
  return container;
}

/// The dialog blocks until the user answers, so tests must close it before
/// awaiting the call that opened it.
Future<void> tapCancel(WidgetTester tester) async {
  await tester.tap(find.byType(TextButton).first);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    globalState.packageInfo = PackageInfo(
      appName: 'FlClash',
      packageName: 'com.follow.clash',
      version: _runningVersion,
      buildNumber: '1',
    );
  });

  testWidgets('renders the grouped notes carried by the release', (
    tester,
  ) async {
    final container = await pumpApp(tester);

    final shown = container
        .read(commonActionProvider.notifier)
        .checkUpdateResultHandle(data: release(_bodyWith(_payload)));
    await tester.pumpAndSettle();

    expect(find.textContaining('v0.8.96'), findsOneWidget);
    expect(find.textContaining('Re-import backups'), findsOneWidget);
    expect(find.textContaining('Override scripts'), findsOneWidget);
    expect(find.textContaining('Breaking changes'), findsOneWidget);

    await tapCancel(tester);
    await shown;
  });

  testWidgets('localizes the group titles but not the entries', (tester) async {
    final container = await pumpApp(tester, locale: const Locale('zh', 'CN'));

    final shown = container
        .read(commonActionProvider.notifier)
        .checkUpdateResultHandle(data: release(_bodyWith(_payload)));
    await tester.pumpAndSettle();

    // Entry copy comes from the release payload and is English only; the group
    // headings still follow the app locale.
    expect(find.textContaining('新功能'), findsOneWidget);
    expect(find.textContaining('Override scripts'), findsOneWidget);

    await tapCancel(tester);
    await shown;
  });

  testWidgets('falls back to the bullets of a release without a payload', (
    tester,
  ) async {
    final container = await pumpApp(tester);

    final shown = container
        .read(commonActionProvider.notifier)
        .checkUpdateResultHandle(data: release(_bulletsOnly));
    await tester.pumpAndSettle();

    expect(find.textContaining('- Override scripts'), findsOneWidget);

    await tapCancel(tester);
    await shown;
  });

  testWidgets('stops reminding when an automatic check is dismissed', (
    tester,
  ) async {
    final container = await pumpApp(tester);

    final shown = container
        .read(commonActionProvider.notifier)
        .checkUpdateResultHandle(data: release(_bodyWith(_payload)));
    await tester.pumpAndSettle();
    await tapCancel(tester);
    await shown;

    expect(container.read(appSettingProvider).autoCheckUpdate, isFalse);
  });

  group('a build that updates itself', () {
    const asset = 'FlClash-0.8.96-android-arm64-v8a.apk';
    final package = utf8.encode('package');
    final digest = sha256.convert(package).toString();
    late Directory home;
    late String? Function() suffix;
    late HttpClientAdapter adapter;

    setUp(() async {
      home = await Directory.systemTemp.createTemp('self_update');
      await useAppPaths(home);
      suffix = resolveSelfUpdateSuffix;
      adapter = request.releaseDio.httpClientAdapter;
      resolveSelfUpdateSuffix = () => 'android-arm64-v8a.apk';
    });

    tearDown(() async {
      resolveSelfUpdateSuffix = suffix;
      request.releaseDio.httpClientAdapter = adapter;
      await home.delete(recursive: true);
    });

    /// Downloading touches the disk and an isolate, which only make progress
    /// outside the fake-async zone.
    Future<void> settleUntil(WidgetTester tester, bool Function() done) async {
      for (var i = 0; i < 50 && !done(); i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    bool shows(String text) => find.text(text).evaluate().isNotEmpty;

    Future<ProviderContainer> startUpdate(WidgetTester tester) async {
      final container = await pumpApp(tester);
      final shown = container
          .read(commonActionProvider.notifier)
          .checkUpdateResultHandle(data: release(_bulletsOnly), isUser: true);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Update'));
      await tester.pump();
      await shown;
      return container;
    }

    testWidgets('reports a file that fails its check', (tester) async {
      request.releaseDio.httpClientAdapter = _ReleaseAdapter(
        sums: '$digest  ./$asset\n',
        asset: () => ResponseBody.fromBytes(utf8.encode('tampered'), 200),
      );

      final container = await startUpdate(tester);
      expect(
        container.read(updateDownloadStateProvider),
        isA<UpdateDownloading>(),
      );
      await settleUntil(tester, () => shows('Update failed'));
      await tester.pumpAndSettle();

      expect(
        find.text('The downloaded update could not be verified.'),
        findsOneWidget,
      );
      expect(container.read(updateDownloadStateProvider), isNull);
      expect(File('${home.path}/update/$asset').existsSync(), isFalse);

      await tapCancel(tester);
    });

    testWidgets('downloads without blocking and waits to install', (
      tester,
    ) async {
      request.releaseDio.httpClientAdapter = _ReleaseAdapter(
        sums: '$digest  ./$asset\n',
        asset: () => ResponseBody.fromBytes(package, 200),
      );

      final container = await startUpdate(tester);
      expect(find.byType(ModalRoute), findsNothing);
      await settleUntil(
        tester,
        () => container.read(updateDownloadStateProvider) is UpdateReady,
      );

      final ready = container.read(updateDownloadStateProvider)! as UpdateReady;
      expect(ready.tag, 'v0.8.96');
      expect(File(ready.path).readAsBytesSync(), package);
      expect(shows('Update failed'), isFalse);

      await tester.runAsync(
        container.read(commonActionProvider.notifier).discardUpdate,
      );
      expect(container.read(updateDownloadStateProvider), isNull);
      expect(File(ready.path).existsSync(), isFalse);
      await tester.pump(const Duration(seconds: 10));
    });

    testWidgets('cancelling the download reports nothing', (tester) async {
      final partial = '${home.path}/update/$asset';
      final body = StreamController<Uint8List>();
      addTearDown(body.close);
      request.releaseDio.httpClientAdapter = _ReleaseAdapter(
        sums: '$digest  ./$asset\n',
        asset: () => ResponseBody(body.stream, 200),
      );

      final container = await startUpdate(tester);
      await settleUntil(tester, () => File(partial).existsSync());
      container.read(commonActionProvider.notifier).cancelUpdateDownload();
      await settleUntil(
        tester,
        () => container.read(updateDownloadStateProvider) == null,
      );
      await tester.pumpAndSettle();

      expect(container.read(updateDownloadStateProvider), isNull);
      expect(shows('Update failed'), isFalse);
    });
  });

  testWidgets('a manual check keeps the setting and reports a failure', (
    tester,
  ) async {
    final container = await pumpApp(tester);

    final shown = container
        .read(commonActionProvider.notifier)
        .checkUpdateResultHandle(isUser: true);
    await tester.pumpAndSettle();

    expect(find.text('Check for updates'), findsOneWidget);

    await tapCancel(tester);
    await shown;
    expect(container.read(appSettingProvider).autoCheckUpdate, isTrue);
  });
}
