import 'package:fl_clash/manager/locale_manager.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  Future<void> pumpLocaleManager(WidgetTester tester, Locale locale) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          locale: locale,
          setTheme: false,
          child: const LocaleManager(child: SizedBox.shrink()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('publishes a locale only once its messages are loaded', (
    tester,
  ) async {
    final published = <String>[];
    container.listen(loadedLocaleProvider, (prev, next) {
      published.add('$next@${Intl.getCurrentLocale()}');
    });

    await pumpLocaleManager(tester, const Locale('en'));
    await pumpLocaleManager(tester, const Locale('zh', 'CN'));

    expect(container.read(loadedLocaleProvider), const Locale('zh', 'CN'));
    expect(published, <String>['en@en', 'zh_CN@zh_CN']);
  });

  testWidgets('a rebuild in the same locale publishes nothing new', (
    tester,
  ) async {
    await pumpLocaleManager(tester, const Locale('en'));
    var publishes = 0;
    container.listen(loadedLocaleProvider, (prev, next) => publishes++);

    await pumpLocaleManager(tester, const Locale('en'));

    expect(publishes, 0);
    expect(container.read(loadedLocaleProvider), const Locale('en'));
  });
}
