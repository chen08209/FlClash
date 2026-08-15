import 'package:fl_clash/common/free_nodes.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/config/config.dart';
import 'package:fl_clash/views/profiles/profiles.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('profile title airport links split remaining app bar width', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('zh', 'CN'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.delegate.supportedLocales,
          home: Scaffold(
            appBar: AppBar(
              centerTitle: false,
              titleSpacing: 24,
              toolbarHeight: 68,
              title: buildProfilesTitleBarForTesting(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final qualityRect = tester.getRect(
      find.byKey(const Key('profiles_title_quality_airport_link')),
    );
    final budgetRect = tester.getRect(
      find.byKey(const Key('profiles_title_budget_airport_link')),
    );
    final titleRect = tester.getRect(
      find.byKey(const Key('profiles_title_label')),
    );
    final warningRect = tester.getRect(find.text('不要轻易购买小于0.05元/G的机场'));

    expect((qualityRect.width - budgetRect.width).abs(), lessThanOrEqualTo(1));
    expect(qualityRect.width, greaterThanOrEqualTo(140));
    expect(budgetRect.left, greaterThan(qualityRect.right));
    expect((qualityRect.top - titleRect.top).abs(), lessThanOrEqualTo(2));
    expect((budgetRect.top - titleRect.top).abs(), lessThanOrEqualTo(2));
    expect(warningRect.top, greaterThanOrEqualTo(qualityRect.bottom + 10));
  });

  testWidgets('config title airport links align with title and lower warning', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('zh', 'CN'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.delegate.supportedLocales,
          home: Scaffold(
            appBar: AppBar(
              centerTitle: false,
              titleSpacing: 24,
              toolbarHeight: 68,
              title: buildConfigTitleBarForTesting(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final qualityRect = tester.getRect(
      find.byKey(const Key('config_title_quality_airport_link')),
    );
    final budgetRect = tester.getRect(
      find.byKey(const Key('config_title_budget_airport_link')),
    );
    final titleRect = tester.getRect(
      find.byKey(const Key('config_title_label')),
    );
    final warningRect = tester.getRect(find.text('不要轻易购买小于0.05元/G的机场'));

    expect((qualityRect.width - budgetRect.width).abs(), lessThanOrEqualTo(1));
    expect(qualityRect.width, greaterThanOrEqualTo(140));
    expect(budgetRect.left, greaterThan(qualityRect.right));
    expect((qualityRect.top - titleRect.top).abs(), lessThanOrEqualTo(2));
    expect((budgetRect.top - titleRect.top).abs(), lessThanOrEqualTo(2));
    expect(warningRect.top, greaterThanOrEqualTo(qualityRect.bottom + 10));
  });

  testWidgets('shows source link next to profile creation time', (
    tester,
  ) async {
    final profile = Profile.normal(
      label: 'Test subscription',
      url: 'https://sub.example.com/clash.yaml',
    ).copyWith(sourceUrl: 'https://source.example.com');

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.delegate.supportedLocales,
          home: Scaffold(
            body: ProfileItem(
              profile: profile,
              groupValue: null,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('添加时间：'), findsOneWidget);
    expect(find.text('https://source.example.com'), findsOneWidget);
    expect(find.byTooltip('https://source.example.com'), findsOneWidget);

    final timeRect = tester.getRect(find.textContaining('添加时间：'));
    final linkRect = tester.getRect(
      find.byKey(const Key('profile_source_url_link')),
    );
    expect(linkRect.left, greaterThan(timeRect.right));
    expect(linkRect.left - timeRect.right, lessThanOrEqualTo(12));
  });

  testWidgets('hides source link when profile has no source url', (
    tester,
  ) async {
    final profile = Profile.normal(
      label: 'Test subscription',
      url: 'https://sub.example.com/clash.yaml',
    );

    await _pumpProfileItem(tester, profile);

    expect(find.textContaining('添加时间：'), findsOneWidget);
    expect(find.byKey(const Key('profile_source_url_link')), findsNothing);
    expect(find.text('https://source.example.com'), findsNothing);
  });

  testWidgets('opens source url from source link without confirmation dialog', (
    tester,
  ) async {
    final openedUrls = <String>[];
    final profile = _sourceProfile();

    await _pumpProfileItem(
      tester,
      profile,
      sourceUrlOpener: (_, url) async {
        openedUrls.add(url);
      },
    );

    await tester.tap(find.byKey(const Key('profile_source_url_link')));
    await tester.pump();

    expect(openedUrls, ['https://source.example.com']);
    expect(find.text('外部链接'), findsNothing);
  });

  testWidgets(
    'opens source url from secondary tap without confirmation dialog',
    (tester) async {
      final openedUrls = <String>[];
      final profile = _sourceProfile();

      await _pumpProfileItem(
        tester,
        profile,
        sourceUrlOpener: (_, url) async {
          openedUrls.add(url);
        },
      );

      await tester.tapAt(
        tester.getCenter(find.byType(ProfileItem)),
        buttons: kSecondaryButton,
      );
      await tester.pump();

      expect(openedUrls, ['https://source.example.com']);
      expect(find.text('外部链接'), findsNothing);
    },
  );

  testWidgets(
    'opens source url from profile menu without confirmation dialog',
    (tester) async {
      final openedUrls = <String>[];
      final profile = _sourceProfile();

      await _pumpProfileItem(
        tester,
        profile,
        sourceUrlOpener: (_, url) async {
          openedUrls.add(url);
        },
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('源订阅网站'));
      await tester.pumpAndSettle();

      expect(openedUrls, ['https://source.example.com']);
      expect(find.text('外部链接'), findsNothing);
    },
  );

  testWidgets(
    'free nodes profile progress hides technical fetch details and shows timing',
    (tester) async {
      final profile = freeNodesService.createProfile().copyWith(
        subscriptionInfo: const SubscriptionInfo(total: 1200),
      );
      final startedAt = DateTime.now().subtract(const Duration(seconds: 20));

      await _pumpProfileItem(
        tester,
        profile,
        freeNodesProgress: FreeNodesProgress(
          operation: 'Rust 高并发获取免费节点',
          completed: 25,
          total: 100,
          proxyCount: 1300,
          startedAt: startedAt,
        ),
      );

      expect(find.textContaining('获取中'), findsOneWidget);
      expect(find.textContaining('预计剩余'), findsOneWidget);
      expect(find.textContaining('已用'), findsOneWidget);
      expect(find.textContaining('Rust 高并发'), findsNothing);
      expect(find.textContaining('25/100'), findsNothing);
    },
  );

  testWidgets('free nodes profile progress shows actual used time', (
    tester,
  ) async {
    final profile = freeNodesService.createProfile().copyWith(
      subscriptionInfo: const SubscriptionInfo(total: 1200),
    );
    final startedAt = DateTime(2026, 6, 20, 9);

    await _pumpProfileItem(
      tester,
      profile,
      freeNodesProgress: FreeNodesProgress(
        operation: '已完成',
        done: true,
        proxyCount: 1300,
        startedAt: startedAt,
        finishedAt: startedAt.add(const Duration(minutes: 2, seconds: 5)),
      ),
    );

    expect(find.text('已完成 · 1300 个节点'), findsOneWidget);
    expect(find.text('本次用时 2分5秒'), findsOneWidget);
  });
}

Profile _sourceProfile() {
  return Profile.normal(
    label: 'Test subscription',
    url: 'https://sub.example.com/clash.yaml',
  ).copyWith(sourceUrl: 'https://source.example.com');
}

Future<void> _pumpProfileItem(
  WidgetTester tester,
  Profile profile, {
  Future<void> Function(BuildContext context, String url)? sourceUrlOpener,
  FreeNodesProgress? freeNodesProgress,
}) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  if (freeNodesProgress != null) {
    container.read(freeNodesFetchProgressProvider.notifier).value =
        freeNodesProgress;
  }
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.delegate.supportedLocales,
        home: Scaffold(
          body: ProfileItem(
            profile: profile,
            groupValue: null,
            onChanged: (_) {},
            sourceUrlOpener: sourceUrlOpener,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
