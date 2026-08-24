import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/theme.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('hides expiry when both values do not fit', (tester) async {
    const trafficLabel = '1KB / 1GB';

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.delegate.supportedLocales,
        builder: (context, child) {
          globalState.measure = Measure.of(context, 1);
          globalState.theme = CommonTheme.of(context, 1);
          return child!;
        },
        home: const Scaffold(
          body: SizedBox(
            width: 120,
            child: SubscriptionInfoView(
              subscriptionInfo: SubscriptionInfo(
                upload: 1024,
                total: 1073741824,
                expire: 4102444800,
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byTooltip(trafficLabel), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(SubscriptionInfoView),
        matching: find.byType(Text),
      ),
      findsOneWidget,
    );
  });

  testWidgets('keeps expiry at its intrinsic width when both values fit', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.delegate.supportedLocales,
        home: const Scaffold(
          body: SizedBox(
            width: 300,
            child: SubscriptionInfoView(
              subscriptionInfo: SubscriptionInfo(
                upload: 1024,
                total: 1073741824,
                expire: 4102444800,
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(
      find.descendant(
        of: find.byType(SubscriptionInfoView),
        matching: find.byType(Text),
      ),
      findsNWidgets(2),
    );
  });

  testWidgets('shows full subscription details in information rows', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.delegate.supportedLocales,
        builder: (context, child) {
          globalState.measure = Measure.of(context, 1);
          globalState.theme = CommonTheme.of(context, 1);
          return child!;
        },
        home: const Scaffold(
          body: SubscriptionInfoDetailView(
            subscriptionInfo: SubscriptionInfo(
              upload: 1024,
              download: 2048,
              total: 1073741824,
              expire: 4102444800,
            ),
          ),
        ),
      ),
    );

    final appLocalizations = AppLocalizations.current;
    expect(find.text(appLocalizations.trafficUsage), findsOneWidget);
    expect(find.text(appLocalizations.usedTraffic), findsOneWidget);
    expect(find.text(appLocalizations.totalTraffic), findsOneWidget);
    expect(find.text(appLocalizations.expireTime), findsOneWidget);
    expect(find.text('3KB'), findsOneWidget);
    expect(find.text('1GB'), findsOneWidget);
    expect(find.byType(DecorationListItem), findsNWidgets(3));
  });
}
