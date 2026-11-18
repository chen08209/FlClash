import 'package:fl_clash/common/app_localizations.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/tools.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  test('load resolves accessors for every supported locale', () async {
    for (final locale in AppLocalizations.supportedLocales) {
      final appLocalizations = loadAppLocalizations(locale);

      expect(currentAppLocalizations.localeName, appLocalizations.localeName);
      expect(appLocalizations.dashboard, isNotEmpty);
      expect(appLocalizations.proxies, isNotEmpty);
      expect(appLocalizations.settings, isNotEmpty);
      expect(appLocalizations.secondsCount(30), contains('30'));
      expect(appLocalizations.geoUpdated('geoip'), contains('geoip'));
    }
  });

  test('delegate recognizes only supported locales', () {
    expect(AppLocalizations.delegate.isSupported(const Locale('en')), isTrue);
    expect(AppLocalizations.delegate.isSupported(const Locale('de')), isFalse);
    expect(
      AppLocalizations.delegate.shouldReload(AppLocalizations.delegate),
      isFalse,
    );
  });

  test('Slovak loads its labels and uses Slovak plural forms', () async {
    const locale = Locale('sk');
    expect(AppLocalizations.supportedLocales, contains(locale));
    final slovak = await appLocalizationsDelegate.load(locale);

    expect(slovak.sk, 'Slovenčina');
    expect(slovak.settings, 'Nastavenia');
    expect(slovak.rulesCount(4, '4'), '4 pravidlá');
    expect(slovak.liveStatusPosition(2, 5), '2 z 5');
    expect(
      slovak.profileExpiresIn('24. 11.', 2),
      'Platnosť do 24. 11. · zostávajú 2 dni',
    );

    const seconds = <(num, String)>[
      (0, '0 sekúnd'),
      (1, '1 sekunda'),
      (2, '2 sekundy'),
      (4, '4 sekundy'),
      (5, '5 sekúnd'),
      (11, '11 sekúnd'),
      (21, '21 sekúnd'),
      (1.5, '1.5 sekundy'),
    ];
    for (final (count, expected) in seconds) {
      expect(slovak.secondsCount(count), expected);
    }
  });

  testWidgets('selecting Slovak in Tools switches the app language', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          moreToolsSelectorStateProvider.overrideWithValue(
            const MoreToolsSelectorState(navigationItems: []),
          ),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            final locale = ref.watch(
              appSettingProvider.select((state) => state.locale),
            );
            return TestApp(
              locale: getLocaleForString(locale) ?? const Locale('en'),
              child: const ToolsView(),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
    final option = find.text('Slovak');
    await tester.ensureVisible(option);
    await tester.pumpAndSettle();
    await tester.tap(option.hitTestable());
    await tester.pumpAndSettle();

    expect(find.text('Jazyk'), findsOneWidget);
    expect(find.text('Slovenčina'), findsOneWidget);
  });
}
